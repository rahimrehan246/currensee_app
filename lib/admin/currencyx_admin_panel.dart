// ============================================================
//  CURRENCYX — COMPLETE PREMIUM ADMIN PANEL v2.0
//
//  FOLDER STRUCTURE:
//  lib/
//   ├── admin/
//   │   ├── admin_shell.dart          ← Sidebar + shell (this file: AdminShell)
//   │   ├── dashboard/
//   │   │   └── dashboard_screen.dart ← Stats + recent activity
//   │   ├── users/
//   │   │   ├── users_screen.dart     ← All 3 user tabs
//   │   │   └── edit_user_page.dart   ← Edit user
//   │   ├── feedback/
//   │   │   ├── feedback_screen.dart  ← Feedback list + stats
//   │   │   └── feedback_detail_page.dart
//   │   ├── contacts/
//   │   │   ├── contacts_screen.dart  ← Contact us list
//   │   │   └── contact_detail_page.dart
//   │   ├── profiles/
//   │   │   ├── profiles_screen.dart  ← Profiles list
//   │   │   └── profile_detail_page.dart
//   │   └── shared/
//   │       ├── app_colors.dart
//   │       ├── app_widgets.dart      ← Reusable widgets
//   │       └── confirm_delete_dialog.dart
//
//  NOTE: All code is in a single file for easy copy-paste.
//  Split into the folder structure above when integrating.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curreny/User/screens/registration/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

// ════════════════════════════════════════════════════════════
//  SECTION 1 — DESIGN TOKENS  (app_colors.dart)
// ════════════════════════════════════════════════════════════

const kBg          = Color(0xFF070B14);
const kNavy        = Color(0xFF0E1B35);
const kPurple      = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kPurpleDark  = Color(0xFF3A1ACC);
const kWhite       = Color(0xFFFFFFFF);
const kSecondary   = Color(0xFFA0A7B8);
const kBorder      = Color(0xFF1E2A45);
const kCardBg      = Color(0xFF0D1526);
const kInputBg     = Color(0xFF0A1020);
const kErrorRed    = Color(0xFFFF4D6A);
const kGold        = Color(0xFFFFD166);
const kGoldDark    = Color(0xFFE5A50A);
const kGreen       = Color(0xFF00D68F);
const kTeal        = Color(0xFF00C9B1);
const kSidebar     = Color(0xFF080E1C);

const kPurpleGradient = LinearGradient(
  colors: [kPurpleDark, kPurple, kPurpleLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGoldGradient = LinearGradient(
  colors: [kGoldDark, kGold],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGreenGradient = LinearGradient(
  colors: [Color(0xFF00A36C), kGreen],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kTealGradient = LinearGradient(
  colors: [Color(0xFF009B8A), kTeal],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

List<BoxShadow> kGlow(Color c, {double blur = 20}) => [
  BoxShadow(color: c.withOpacity(0.32), blurRadius: blur, spreadRadius: -2),
];

List<BoxShadow> get kCardShadow => [
  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6)),
];

// ════════════════════════════════════════════════════════════
//  SECTION 2 — MODELS
// ════════════════════════════════════════════════════════════

enum AdminSection { dashboard, users, feedback, contacts, profiles, settings }

class AppUser {
  final String id, name, email, type;
  final String? photoUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc, String type) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      id: doc.id,
      name: (d['fullName'] ?? d['name'] ?? d['displayName'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      type: type,
      photoUrl: d['photoURL']?.toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FeedbackEntry {
  final String id;
  final int rating;
  final String feedback, email;
  final List<String> categories;
  final bool? recommend;
  final DateTime? submittedAt;

  const FeedbackEntry({
    required this.id,
    required this.rating,
    required this.feedback,
    required this.email,
    required this.categories,
    this.recommend,
    this.submittedAt,
  });

  factory FeedbackEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return FeedbackEntry(
      id: doc.id,
      rating: (d['rating'] ?? 0) as int,
      feedback: (d['feedback'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      categories: List<String>.from(d['categories'] ?? []),
      recommend: d['recommend'] as bool?,
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ContactEntry {
  final String id, name, email, subject, message;
  final DateTime? createdAt;

  const ContactEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.createdAt,
  });

  factory ContactEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ContactEntry(
      id: doc.id,
      name: (d['name'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      subject: (d['subject'] ?? '').toString(),
      message: (d['message'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserProfile {
  final String id, fullName, email, phone, country, currency, gender, dob, address;
  final int age;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.currency,
    required this.gender,
    required this.dob,
    required this.address,
    required this.age,
    this.createdAt,
  });

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: doc.id,
      fullName: (d['fullName'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      country: (d['country'] ?? '').toString(),
      currency: (d['currency'] ?? '').toString(),
      gender: (d['gender'] ?? '').toString(),
      dob: (d['dob'] ?? '').toString(),
      address: (d['address'] ?? '').toString(),
      age: (d['age'] ?? 0) as int,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 3 — SHARED WIDGETS  (app_widgets.dart)
// ════════════════════════════════════════════════════════════

/// Premium reusable stat card
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final int animDelay;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: kGlow(glowColor, blur: 16),
          ),
          child: Icon(icon, color: kWhite, size: 20),
        ),
        const SizedBox(height: 16),
        Text(value, style: GoogleFonts.poppins(
          color: kWhite, fontSize: 26, fontWeight: FontWeight.w700,
          height: 1,
        )),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 12, fontWeight: FontWeight.w500,
        )),
      ]),
    )
    .animate(delay: Duration(milliseconds: animDelay))
    .fadeIn(duration: 500.ms)
    .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

/// Live stat card that reads from Firestore count
class LiveStatCard extends StatelessWidget {
  final String label, collection;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final int animDelay;

  const LiveStatCard({
    super.key,
    required this.label,
    required this.collection,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (_, snap) {
        final count = snap.data?.docs.length ?? 0;
        return StatCard(
          label: label,
          value: '$count',
          icon: icon,
          gradient: gradient,
          glowColor: glowColor,
          animDelay: animDelay,
        );
      },
    );
  }
}

/// Generic loading skeleton card
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: height,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(duration: 1200.ms, color: kBorder.withOpacity(0.5));
  }
}

/// Generic empty state
class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: kPurple.withOpacity(0.25)),
          ),
          child: Icon(icon, color: kPurpleLight, size: 32),
        ),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.poppins(
          color: kWhite, fontSize: 16, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 12,
        )),
      ]),
    );
  }
}

/// Generic error state
class ErrorState extends StatelessWidget {
  final String error;
  const ErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: kErrorRed, size: 44),
        const SizedBox(height: 12),
        Text('Error loading data', style: GoogleFonts.poppins(
          color: kWhite, fontSize: 15, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        Text(error, style: GoogleFonts.poppins(color: kSecondary, fontSize: 11),
             textAlign: TextAlign.center),
      ]),
    );
  }
}

/// Reusable action button (Edit / Delete / View)
class ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(
          color: color, fontSize: 11, fontWeight: FontWeight.w600,
        )),
      ]),
    ),
  );
}

/// Confirm delete dialog (reusable)
class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;
  const ConfirmDeleteDialog({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: kCardBg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: kErrorRed.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: kErrorRed.withOpacity(0.3)),
          ),
          child: const Icon(Icons.delete_forever_rounded, color: kErrorRed, size: 28),
        ),
        const SizedBox(height: 16),
        Text('Confirm Delete', style: GoogleFonts.poppins(
          color: kWhite, fontSize: 18, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 8),
        Text(
          'Delete "$itemName"? This action cannot be undone.',
          style: GoogleFonts.poppins(color: kSecondary, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: kInputBg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: kBorder),
              ),
              child: Center(child: Text('Cancel', style: GoogleFonts.poppins(
                color: kSecondary, fontSize: 14, fontWeight: FontWeight.w600,
              ))),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: kErrorRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: kErrorRed.withOpacity(0.4)),
                boxShadow: kGlow(kErrorRed, blur: 12),
              ),
              child: Center(child: Text('Delete', style: GoogleFonts.poppins(
                color: kErrorRed, fontSize: 14, fontWeight: FontWeight.w700,
              ))),
            ),
          )),
        ]),
      ]),
    ),
  );
}

/// Reusable snackbar helper
void showSnack(BuildContext context, String msg, {bool error = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(
        error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: error ? kErrorRed : kGreen, size: 16,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.poppins(
        color: kWhite, fontSize: 13, fontWeight: FontWeight.w500,
      ))),
    ]),
    backgroundColor: kCardBg,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: (error ? kErrorRed : kGreen).withOpacity(0.3)),
    ),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}

/// Reusable premium text field for edit screens
class PremiumEditField extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? formatters;
  final int maxLines;

  const PremiumEditField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.formatters,
    this.maxLines = 1,
  });

  @override
  State<PremiumEditField> createState() => _PremiumEditFieldState();
}

class _PremiumEditFieldState extends State<PremiumEditField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AnimatedDefaultTextStyle(
        duration: 200.ms,
        style: GoogleFonts.poppins(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: _focused ? kPurpleLight : kSecondary,
          letterSpacing: 0.8,
        ),
        child: Text(widget.label),
      ),
      const SizedBox(height: 7),
      AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? kPurple : kBorder,
            width: _focused ? 1.6 : 1.0,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: kPurple.withOpacity(0.15), blurRadius: 12)]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.formatters,
          maxLines: widget.maxLines,
          style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              color: kSecondary.withOpacity(0.45), fontSize: 13,
            ),
            prefixIcon: Icon(widget.icon, color: kSecondary, size: 18),
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Date formatter helper
String formatDate(DateTime? dt) {
  if (dt == null) return 'Unknown';
  return '${dt.day.toString().padLeft(2, '0')}/'
         '${dt.month.toString().padLeft(2, '0')}/'
         '${dt.year}';
}

// ════════════════════════════════════════════════════════════
//  SECTION 4 — ADMIN SHELL  (admin_shell.dart)
//  Sidebar + navigation + tab controller
// ════════════════════════════════════════════════════════════

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> with TickerProviderStateMixin {
  AdminSection _current = AdminSection.dashboard;
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }
Future<void> _logout() async {

  await FirebaseAuth.instance.signOut();

  if (!mounted) return;

  Navigator.of(context).pushAndRemoveUntil(

    MaterialPageRoute(
      builder: (_) => const AuthApp(),
    ),

    (route) => false,
  );
}
  static const _navItems = [
    _NavItem(AdminSection.dashboard, Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(AdminSection.users,     Icons.people_outline_rounded, 'Users'),
    _NavItem(AdminSection.feedback,  Icons.rate_review_outlined, 'Feedback'),
    _NavItem(AdminSection.contacts,  Icons.mail_outline_rounded, 'Contact Us'),
    _NavItem(AdminSection.profiles,  Icons.person_pin_outlined, 'Profiles'),
    _NavItem(AdminSection.settings,  Icons.settings_outlined, 'Settings'),
  ];

  Widget _body() => switch (_current) {
    AdminSection.dashboard => const DashboardScreen(),
    AdminSection.users     => const UsersScreen(),
    AdminSection.feedback  => const FeedbackScreen(),
    AdminSection.contacts  => const ContactsScreen(),
    AdminSection.profiles  => const ProfilesScreen(),
    AdminSection.settings  => const SettingsScreen(),
  };

 @override
Widget build(BuildContext context) {

  final isMobile =
      MediaQuery.of(context).size.width < 900;

  return Scaffold(
    backgroundColor: kBg,

    drawer: isMobile
        ? Drawer(
            backgroundColor: Colors.transparent,
            child: _Sidebar(
              current: _current,
              navItems: _navItems,
              onSelect: (s) {
                setState(() => _current = s);
                Navigator.pop(context);
              },
              onLogout: _logout,
              bgCtrl: _bgCtrl,
            ),
          )
        : null,

    body: Row(
      children: [

        // DESKTOP SIDEBAR
        if (!isMobile)
          _Sidebar(
            current: _current,
            navItems: _navItems,
            onSelect: (s) =>
                setState(() => _current = s),
            onLogout: _logout,
            bgCtrl: _bgCtrl,
          ),

        // MAIN CONTENT
        Expanded(
          child: Stack(
            children: [

              // BACKGROUND GLOW
              AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) {

                  final t = _bgCtrl.value;

                  return Stack(
                    children: [

                      Positioned(
                        top: -80 +
                            40 * math.sin(t * math.pi),
                        right: -60,
                        child: _Glow(
                          320,
                          kPurple,
                          0.12 + 0.04 * t,
                        ),
                      ),

                      Positioned(
                        bottom: 60 +
                            20 * math.cos(t * math.pi),
                        left: -80,
                        child: _Glow(
                          240,
                          kGold,
                          0.06 + 0.02 * t,
                        ),
                      ),
                    ],
                  );
                },
              ),

              SafeArea(
                child: Column(
                  children: [

                    // MOBILE TOP BAR
                    if (isMobile)
                      Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Row(
                          children: [

                            Builder(
                              builder: (context) =>
                                  IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Scaffold.of(context)
                                      .openDrawer();
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: _body(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

class _NavItem {
  final AdminSection section;
  final IconData icon;
  final String label;
  const _NavItem(this.section, this.icon, this.label);
}

class _Sidebar extends StatelessWidget {
  final AdminSection current;
  final List<_NavItem> navItems;
  final void Function(AdminSection) onSelect;
  final VoidCallback onLogout;
  final AnimationController bgCtrl;

  const _Sidebar({
    required this.current,
    required this.navItems,
    required this.onSelect,
    required this.onLogout,
    required this.bgCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
    MediaQuery.of(context)
                .size
                .width <
            700
        ? 260
        : 220,
      color: kSidebar,
      child: Column(children: [
        // ── Logo ───────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(children: [
                Row(
      children: [
        // Logo Box
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPurpleDark,
                kPurple,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: const Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Currency',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'X',
                    style: TextStyle(
                      color: kGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: kGold.withOpacity(0.25),
                ),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: kGold,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    ),

              const SizedBox(height: 16),
              Container(height: 1, color: kBorder),
            ]),
          ),
        ),

        // ── Nav items ──────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: navItems.map((item) {
                final active = current == item.section;
                return _NavTile(
                  item: item,
                  active: active,
                  onTap: () => onSelect(item.section),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Admin info + logout ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          child: Column(children: [
            Container(height: 1, color: kBorder),
            const SizedBox(height: 12),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (_, snap) {
                final data = snap.data?.data() as Map<String, dynamic>? ?? {};
                final name = (data['name'] ?? data['fullName'] ?? 'Admin').toString();
                final email = (data['email'] ?? '').toString();
                return Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: kPurpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: kGlow(kPurple, blur: 12),
                    ),
                    child: Center(child: Text(
                      name.isEmpty ? 'A' : name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: kWhite, fontSize: 14, fontWeight: FontWeight.w700,
                      ),
                    )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.poppins(
                        color: kWhite, fontSize: 12, fontWeight: FontWeight.w600,
                      ), overflow: TextOverflow.ellipsis),
                      Text(email, style: GoogleFonts.poppins(
                        color: kSecondary, fontSize: 9,
                      ), overflow: TextOverflow.ellipsis),
                    ],
                  )),
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: kErrorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: kErrorRed.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.logout_rounded, color: kErrorRed, size: 15),
                    ),
                  ),
                ]);
              },
            ),
            const SizedBox(height: 4),
            Row(children: [
              Container(width: 7, height: 7,
                decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Online', style: GoogleFonts.poppins(
                color: kGreen, fontSize: 10, fontWeight: FontWeight.w500,
              )),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          gradient: active ? kPurpleGradient : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? kGlow(kPurple, blur: 14) : null,
        ),
        child: Row(children: [
          Icon(item.icon,
            color: active ? kWhite : kSecondary, size: 18),
          const SizedBox(width: 10),
          Text(item.label, style: GoogleFonts.poppins(
            color: active ? kWhite : kSecondary,
            fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          )),
        ]),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Glow(this.size, this.color, this.opacity);

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 5 — DASHBOARD SCREEN  (dashboard_screen.dart)
// ════════════════════════════════════════════════════════════

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
@override
Widget build(BuildContext context) {
  return Column(
    children: [

      _buildHeader(),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            32,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ── Stats grid ──────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {

                  final isMobile =
                      constraints.maxWidth < 700;

                  final stats = [

                    const LiveStatCard(
                      label: 'Total Users',
                      collection: 'customers',
                      icon:
                          Icons.people_outline_rounded,
                      gradient: kPurpleGradient,
                      glowColor: kPurple,
                      animDelay: 0,
                    ),

                    const LiveStatCard(
                      label: 'Feedback',
                      collection: 'feedback',
                      icon:
                          Icons.star_outline_rounded,
                      gradient: kGoldGradient,
                      glowColor: kGold,
                      animDelay: 80,
                    ),

                    const LiveStatCard(
                      label: 'Contact Us',
                      collection: 'contact',
                      icon:
                          Icons.mail_outline_rounded,
                      gradient: kGreenGradient,
                      glowColor: kGreen,
                      animDelay: 160,
                    ),

                    const LiveStatCard(
                      label: 'Profiles',
                      collection: 'users',
                      icon:
                          Icons.person_pin_outlined,
                      gradient: kTealGradient,
                      glowColor: kTeal,
                      animDelay: 240,
                    ),
                  ];

                  return GridView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount: stats.length,

                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount:
                          isMobile ? 1 : 2,

                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,

                      mainAxisExtent:
                          isMobile ? 150 : 180,
                    ),

                    itemBuilder: (context, index) {

                      return stats[index];
                    },
                  );
                },
              ),

              const SizedBox(height: 28),

            // ── Section title ───────────────────────────────
            _SectionLabel(label: 'RECENT ACTIVITY'),
            const SizedBox(height: 14),

            // ── Recent feedback ─────────────────────────────
            _RecentSection(
              title: 'Latest Feedback',
              icon: Icons.rate_review_outlined,
              color: kGold,
              child: _RecentFeedbackList(),
            ),
            const SizedBox(height: 16),

            // ── Recent contacts ─────────────────────────────
            _RecentSection(
              title: 'Latest Messages',
              icon: Icons.mail_outline_rounded,
              color: kGreen,
              child: _RecentContactList(),
            ),
            const SizedBox(height: 16),

            // ── Recent users ────────────────────────────────
            _RecentSection(
              title: 'New Users',
              icon: Icons.people_outline_rounded,
              color: kPurpleLight,
              child: _RecentUsersList(),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildHeader() {
    return Wrap(
  alignment:
      WrapAlignment.spaceBetween,

  crossAxisAlignment:
      WrapCrossAlignment.center,

  runSpacing: 12,children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dashboard', style: GoogleFonts.poppins(
            color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
          )),
          Text('Welcome back, Admin', style: GoogleFonts.poppins(
            color: kSecondary, fontSize: 12,
          )),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_today_outlined, color: kSecondary, size: 14),
            const SizedBox(width: 6),
            Text(
              _todayLabel(),
              style: GoogleFonts.poppins(color: kSecondary, fontSize: 11),
            ),
          ]),
        ),
      ]
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, end: 0);
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: GoogleFonts.poppins(
      color: kSecondary, fontSize: 11,
      fontWeight: FontWeight.w700, letterSpacing: 1.2,
    )),
    const SizedBox(width: 12),
    Expanded(child: Container(height: 1, color: kBorder)),
  ]);
}

class _RecentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _RecentSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.poppins(
              color: kWhite, fontSize: 13, fontWeight: FontWeight.w600,
            )),
          ]),
        ),
        Container(height: 1, color: kBorder),
        child,
      ]),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

class _RecentFeedbackList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('submittedAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(
              color: kPurple, strokeWidth: 2,
            )),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('No feedback yet', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          );
        }
        return Column(
          children: docs.map((doc) {
            final entry = FeedbackEntry.fromDoc(doc);
            return _FeedbackMiniTile(entry: entry);
          }).toList(),
        );
      },
    );
  }
}

class _FeedbackMiniTile extends StatelessWidget {
  final FeedbackEntry entry;
  const _FeedbackMiniTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGold.withOpacity(0.25)),
          ),
          child: Center(child: Text(
            '${entry.rating}★',
            style: GoogleFonts.poppins(
              color: kGold, fontSize: 11, fontWeight: FontWeight.w700,
            ),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.feedback.isEmpty ? '(No text)' : entry.feedback,
              style: GoogleFonts.poppins(color: kWhite, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (entry.email.isNotEmpty)
              Text(entry.email, style: GoogleFonts.poppins(
                color: kSecondary, fontSize: 10,
              )),
          ],
        )),
        Text(formatDate(entry.submittedAt), style: GoogleFonts.poppins(
          color: kSecondary.withOpacity(0.6), fontSize: 9,
        )),
      ]),
    );
  }
}

class _RecentContactList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contact')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(
              color: kPurple, strokeWidth: 2,
            )),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('No messages yet', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          );
        }
        return Column(
          children: docs.map((doc) {
            final entry = ContactEntry.fromDoc(doc);
            return _ContactMiniTile(entry: entry);
          }).toList(),
        );
      },
    );
  }
}

class _ContactMiniTile extends StatelessWidget {
  final ContactEntry entry;
  const _ContactMiniTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreen.withOpacity(0.25)),
          ),
          child: Center(child: Text(
            entry.name.isEmpty ? '?' : entry.name[0].toUpperCase(),
            style: GoogleFonts.poppins(
              color: kGreen, fontSize: 14, fontWeight: FontWeight.w700,
            ),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.name.isEmpty ? 'Anonymous' : entry.name,
              style: GoogleFonts.poppins(
                color: kWhite, fontSize: 12, fontWeight: FontWeight.w600,
              )),
            Text(entry.subject, style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 10,
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
        Text(formatDate(entry.createdAt), style: GoogleFonts.poppins(
          color: kSecondary.withOpacity(0.6), fontSize: 9,
        )),
      ]),
    );
  }
}

class _RecentUsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(
              color: kPurple, strokeWidth: 2,
            )),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('No users yet', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          );
        }
        return Column(
          children: docs.map((doc) {
            final user = AppUser.fromDoc(doc, 'customer');
            return _UserMiniTile(user: user);
          }).toList(),
        );
      },
    );
  }
}

class _UserMiniTile extends StatelessWidget {
  final AppUser user;
  const _UserMiniTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final letters = user.name.trim().split(' ')
        .where((w) => w.isNotEmpty).take(2)
        .map((w) => w[0].toUpperCase()).join();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kPurple.withOpacity(0.28)),
          ),
          child: Center(child: Text(
            letters.isEmpty ? '?' : letters,
            style: GoogleFonts.poppins(
              color: kPurpleLight, fontSize: 12, fontWeight: FontWeight.w700,
            ),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name.isEmpty ? 'Unnamed' : user.name,
              style: GoogleFonts.poppins(
                color: kWhite, fontSize: 12, fontWeight: FontWeight.w600,
              )),
            Text(user.email, style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 10,
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
        Text(formatDate(user.createdAt), style: GoogleFonts.poppins(
          color: kSecondary.withOpacity(0.6), fontSize: 9,
        )),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 6 — USERS SCREEN  (users_screen.dart)
//  Tabs: Customers | Google Users | Admins
// ════════════════════════════════════════════════════════════

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static const _tabs = [
    (label: 'Customers', collection: 'customers', type: 'customer'),
    (label: 'Google', collection: 'google_users', type: 'google'),
    (label: 'Admins', collection: 'admins', type: 'admin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Users', style: GoogleFonts.poppins(
              color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
            )),
            Text('Manage all user accounts', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms),

      // Tab bar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final active = _tab.index == i;
              return Expanded(child: GestureDetector(
                onTap: () => _tab.animateTo(i),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(_tabs[i].collection)
                      .snapshots(),
                  builder: (_, snap) {
                    final count = snap.data?.docs.length ?? 0;
                    return AnimatedContainer(
                      duration: 180.ms,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: active ? kPurpleGradient : null,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: active ? kGlow(kPurple, blur: 14) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_tabs[i].label, style: GoogleFonts.poppins(
                            color: active ? kWhite : kSecondary,
                            fontSize: 11, fontWeight: FontWeight.w600,
                          )),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? kWhite.withOpacity(0.22)
                                    : kPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text('$count', style: GoogleFonts.poppins(
                                color: active ? kWhite : kPurpleLight,
                                fontSize: 9, fontWeight: FontWeight.w700,
                              )),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ));
            }),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

      const SizedBox(height: 12),

      Expanded(
        child: TabBarView(
          controller: _tab,
          physics: const ClampingScrollPhysics(),
          children: _tabs.map((t) => _UserListTab(
            collection: t.collection,
            userType: t.type,
          )).toList(),
        ),
      ),
    ]);
  }
}

class _UserListTab extends StatelessWidget {
  final String collection, userType;
  const _UserListTab({required this.collection, required this.userType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 4,
            itemBuilder: (_, __) => const SkeletonCard(),
          );
        }
        if (snap.hasError) return ErrorState(error: snap.error.toString());
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return EmptyState(
            title: 'No users yet',
            subtitle: '$collection is empty',
            icon: Icons.people_outline_rounded,
          );
        }
        final users = docs.map((d) => AppUser.fromDoc(d, userType)).toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          itemCount: users.length,
          itemBuilder: (ctx, i) => _UserCard(
            user: users[i],
            collection: collection,
            index: i,
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final String collection;
  final int index;

  const _UserCard({
    required this.user,
    required this.collection,
    required this.index,
  });

  Color get _typeColor => switch (user.type) {
    'google' => kGold,
    'admin'  => kErrorRed,
    _        => kPurpleLight,
  };

  String get _typeLabel => switch (user.type) {
    'google' => 'GOOGLE',
    'admin'  => 'ADMIN',
    _        => 'CUSTOMER',
  };

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(itemName: user.name),
    );
    if (confirmed != true) return;
    try {
      await FirebaseFirestore.instance
          .collection(collection).doc(user.id).delete();
      if (context.mounted) showSnack(context, '${user.name} deleted');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Delete failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = user.name.trim().split(' ')
        .where((w) => w.isNotEmpty).take(2)
        .map((w) => w[0].toUpperCase()).join();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _typeColor.withOpacity(0.45), width: 2),
                boxShadow: kGlow(_typeColor, blur: 10),
              ),
              child: ClipOval(child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? Image.network(user.photoUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(letters))
                  : _initials(letters)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(
                    user.name.isEmpty ? 'Unnamed' : user.name,
                    style: GoogleFonts.poppins(
                      color: kWhite, fontSize: 14, fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _typeColor.withOpacity(0.3)),
                    ),
                    child: Text(_typeLabel, style: GoogleFonts.poppins(
                      color: _typeColor, fontSize: 8, fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    )),
                  ),
                ]),
                const SizedBox(height: 3),
                Text(user.email, style: GoogleFonts.poppins(
                  color: kSecondary, fontSize: 11,
                ), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.calendar_today_outlined,
                    color: kSecondary.withOpacity(0.5), size: 10),
                  const SizedBox(width: 4),
                  Text(formatDate(user.createdAt), style: GoogleFonts.poppins(
                    color: kSecondary.withOpacity(0.5), fontSize: 9,
                  )),
                ]),
              ],
            )),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            ActionBtn(
              label: 'Edit',
              icon: Icons.edit_outlined,
              color: kPurpleLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => EditUserPage(user: user, collection: collection),
              )),
            ),
            const SizedBox(width: 8),
            ActionBtn(
              label: 'Reset PW',
              icon: Icons.lock_reset_rounded,
              color: kGold,
              onTap: () => _sendPasswordReset(context),
            ),
            const Spacer(),
            ActionBtn(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              color: kErrorRed,
              onTap: () => _delete(context),
            ),
          ]),
        ),
      ]),
    )
    .animate(delay: (50 * index).ms)
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }

  Widget _initials(String letters) => Container(
    color: kNavy,
    child: Center(child: Text(
      letters.isEmpty ? '?' : letters,
      style: GoogleFonts.poppins(
        color: _typeColor, fontSize: 16, fontWeight: FontWeight.w700,
      ),
    )),
  );

  Future<void> _sendPasswordReset(BuildContext context) async {
    if (user.email.isEmpty) {
      showSnack(context, 'No email for this user', error: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
      if (context.mounted) showSnack(context, 'Reset email sent to ${user.email}');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Error: $e', error: true);
    }
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 7 — EDIT USER PAGE  (edit_user_page.dart)
// ════════════════════════════════════════════════════════════

class EditUserPage extends StatefulWidget {
  final AppUser user;
  final String collection;
  const EditUserPage({super.key, required this.user, required this.collection});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty) { showSnack(context, 'Name is required', error: true); return; }
    if (!email.contains('@')) { showSnack(context, 'Invalid email', error: true); return; }
    setState(() => _saving = true);
    try {
      final nameField = widget.collection == 'google_users' ? 'name' : 'fullName';
      await FirebaseFirestore.instance
          .collection(widget.collection).doc(widget.user.id)
          .update({
            nameField: name,
            'email': email,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        showSnack(context, 'Updated successfully!');
        await Future.delayed(1000.ms);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _buildHeader(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 8),
            PremiumEditField(
              label: 'FULL NAME',
              hint: 'Enter full name',
              controller: _nameCtrl,
              icon: Icons.badge_outlined,
              formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 16),
            PremiumEditField(
              label: 'EMAIL',
              hint: 'Enter email address',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: 200.ms,
                height: 54,
                decoration: BoxDecoration(
                  gradient: kPurpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kGlow(kPurple, blur: 24),
                ),
                child: Center(child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: kWhite))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.save_outlined, color: kWhite, size: 18),
                        const SizedBox(width: 8),
                        Text('Save Changes', style: GoogleFonts.poppins(
                          color: kWhite, fontSize: 15, fontWeight: FontWeight.w600,
                        )),
                      ])),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ]),
        )),
      ]),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kBorder),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: kWhite, size: 20),
        ),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Edit User', style: GoogleFonts.poppins(
          color: kWhite, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        Text(widget.collection, style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 11,
        )),
      ]),
    ]),
  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.08, end: 0);
}

// ════════════════════════════════════════════════════════════
//  SECTION 8 — FEEDBACK SCREEN  (feedback_screen.dart)
// ════════════════════════════════════════════════════════════

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Feedback', style: GoogleFonts.poppins(
              color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
            )),
            Text('User ratings & reviews', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms),

      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedback')
              .orderBy('submittedAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 4,
                itemBuilder: (_, __) => const SkeletonCard(height: 110),
              );
            }
            if (snap.hasError) return ErrorState(error: snap.error.toString());
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const EmptyState(
                title: 'No feedback yet',
                subtitle: 'Feedback collection is empty',
                icon: Icons.rate_review_outlined,
              );
            }
            final entries = docs.map(FeedbackEntry.fromDoc).toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              itemCount: entries.length,
              itemBuilder: (ctx, i) => _FeedbackCard(
                entry: entries[i],
                index: i,
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackEntry entry;
  final int index;
  const _FeedbackCard({required this.entry, required this.index});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        itemName: entry.email.isEmpty ? 'this feedback' : entry.email,
      ),
    );
    if (confirmed != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('feedback').doc(entry.id).delete();
      if (context.mounted) showSnack(context, 'Feedback deleted');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Delete failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Stars
              Row(children: List.generate(5, (i) => Icon(
                i < entry.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: i < entry.rating ? kGold : kSecondary.withOpacity(0.3),
                size: 16,
              ))),
              const Spacer(),
              if (entry.recommend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (entry.recommend! ? kGreen : kErrorRed).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (entry.recommend! ? kGreen : kErrorRed).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    entry.recommend! ? 'Would recommend' : 'Would not',
                    style: GoogleFonts.poppins(
                      color: entry.recommend! ? kGreen : kErrorRed,
                      fontSize: 9, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(formatDate(entry.submittedAt), style: GoogleFonts.poppins(
                color: kSecondary.withOpacity(0.6), fontSize: 9,
              )),
            ]),
            if (entry.feedback.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.feedback, style: GoogleFonts.poppins(
                color: kWhite, fontSize: 13, height: 1.5,
              )),
            ],
            if (entry.categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: entry.categories.map((cat) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kPurple.withOpacity(0.25)),
                  ),
                  child: Text(cat, style: GoogleFonts.poppins(
                    color: kPurpleLight, fontSize: 9, fontWeight: FontWeight.w600,
                  )),
                )).toList(),
              ),
            ],
            if (entry.email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.email_outlined, color: kSecondary, size: 11),
                const SizedBox(width: 5),
                Text(entry.email, style: GoogleFonts.poppins(
                  color: kSecondary, fontSize: 10,
                )),
              ]),
            ],
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            ActionBtn(
              label: 'View',
              icon: Icons.open_in_new_rounded,
              color: kPurpleLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FeedbackDetailPage(entry: entry),
              )),
            ),
            const Spacer(),
            ActionBtn(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              color: kErrorRed,
              onTap: () => _delete(context),
            ),
          ]),
        ),
      ]),
    )
    .animate(delay: (50 * index).ms)
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 9 — FEEDBACK DETAIL PAGE  (feedback_detail_page.dart)
// ════════════════════════════════════════════════════════════

class FeedbackDetailPage extends StatelessWidget {
  final FeedbackEntry entry;
  const FeedbackDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _Header(title: 'Feedback Detail', subtitle: 'ID: ${entry.id}'),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // Rating card
            _DetailCard(
              title: 'Rating',
              icon: Icons.star_outline_rounded,
              iconColor: kGold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                    i < entry.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < entry.rating ? kGold : kSecondary.withOpacity(0.3),
                    size: 28,
                  )),
                  const SizedBox(width: 12),
                  Text('${entry.rating}/5', style: GoogleFonts.poppins(
                    color: kGold, fontSize: 20, fontWeight: FontWeight.w700,
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            if (entry.feedback.isNotEmpty)
              _DetailCard(
                title: 'Comment',
                icon: Icons.chat_bubble_outline,
                iconColor: kPurpleLight,
                child: Text(entry.feedback, style: GoogleFonts.poppins(
                  color: kWhite, fontSize: 14, height: 1.65,
                )),
              ),
            if (entry.categories.isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailCard(
                title: 'Categories',
                icon: Icons.label_outline_rounded,
                iconColor: kTeal,
                child: Wrap(
                  spacing: 8, runSpacing: 6,
                  children: entry.categories.map((cat) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kPurple.withOpacity(0.3)),
                    ),
                    child: Text(cat, style: GoogleFonts.poppins(
                      color: kPurpleLight, fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  )).toList(),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Details',
              icon: Icons.info_outline_rounded,
              iconColor: kSecondary,
              child: Column(children: [
                _DetailRow('Email', entry.email.isEmpty ? 'N/A' : entry.email),
                _DetailRow('Recommend', entry.recommend == null
                    ? 'N/A'
                    : (entry.recommend! ? 'Yes' : 'No')),
                _DetailRow('Submitted', formatDate(entry.submittedAt)),
              ]),
            ),
          ]),
        )),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 10 — CONTACTS SCREEN  (contacts_screen.dart)
// ════════════════════════════════════════════════════════════

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Contact Us', style: GoogleFonts.poppins(
              color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
            )),
            Text('Messages from users', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms),

      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('contact')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 4,
                itemBuilder: (_, __) => const SkeletonCard(height: 100),
              );
            }
            if (snap.hasError) return ErrorState(error: snap.error.toString());
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const EmptyState(
                title: 'No messages yet',
                subtitle: 'Contact collection is empty',
                icon: Icons.mail_outline_rounded,
              );
            }
            final entries = docs.map(ContactEntry.fromDoc).toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              itemCount: entries.length,
              itemBuilder: (ctx, i) => _ContactCard(
                entry: entries[i],
                index: i,
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _ContactCard extends StatelessWidget {
  final ContactEntry entry;
  final int index;
  const _ContactCard({required this.entry, required this.index});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(itemName: entry.name),
    );
    if (confirmed != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('contact').doc(entry.id).delete();
      if (context.mounted) showSnack(context, 'Contact deleted');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Delete failed: $e', error: true);
    }
  }

  Future<void> _edit(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditContactPage(entry: entry),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: kGreen.withOpacity(0.25)),
                ),
                child: Center(child: Text(
                  entry.name.isEmpty ? '?' : entry.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: kGreen, fontSize: 16, fontWeight: FontWeight.w700,
                  ),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name.isEmpty ? 'Anonymous' : entry.name,
                    style: GoogleFonts.poppins(
                      color: kWhite, fontSize: 14, fontWeight: FontWeight.w600,
                    )),
                  Text(entry.email, style: GoogleFonts.poppins(
                    color: kSecondary, fontSize: 11,
                  ), overflow: TextOverflow.ellipsis),
                ],
              )),
              Text(formatDate(entry.createdAt), style: GoogleFonts.poppins(
                color: kSecondary.withOpacity(0.55), fontSize: 9,
              )),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withOpacity(0.15)),
              ),
              child: Text('Subject: ${entry.subject}', style: GoogleFonts.poppins(
                color: kGreen, fontSize: 11, fontWeight: FontWeight.w600,
              )),
            ),
            const SizedBox(height: 8),
            Text(entry.message, style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12, height: 1.5,
            ), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            ActionBtn(
              label: 'Edit',
              icon: Icons.edit_outlined,
              color: kPurpleLight,
              onTap: () => _edit(context),
            ),
            const SizedBox(width: 8),
            ActionBtn(
              label: 'View',
              icon: Icons.open_in_new_rounded,
              color: kTeal,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ContactDetailPage(entry: entry),
              )),
            ),
            const Spacer(),
            ActionBtn(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              color: kErrorRed,
              onTap: () => _delete(context),
            ),
          ]),
        ),
      ]),
    )
    .animate(delay: (50 * index).ms)
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 11 — EDIT CONTACT PAGE
// ════════════════════════════════════════════════════════════

class EditContactPage extends StatefulWidget {
  final ContactEntry entry;
  const EditContactPage({super.key, required this.entry});

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _messageCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: widget.entry.name);
    _emailCtrl   = TextEditingController(text: widget.entry.email);
    _subjectCtrl = TextEditingController(text: widget.entry.subject);
    _messageCtrl = TextEditingController(text: widget.entry.message);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _subjectCtrl.dispose(); _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('contact').doc(widget.entry.id)
          .update({
            'name':      _nameCtrl.text.trim(),
            'email':     _emailCtrl.text.trim(),
            'subject':   _subjectCtrl.text.trim(),
            'message':   _messageCtrl.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        showSnack(context, 'Contact updated!');
        await Future.delayed(1000.ms);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _Header(title: 'Edit Contact', subtitle: 'contact'),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            PremiumEditField(label: 'NAME', hint: 'Full name', controller: _nameCtrl,
              icon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            PremiumEditField(label: 'EMAIL', hint: 'Email address', controller: _emailCtrl,
              icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            PremiumEditField(label: 'SUBJECT', hint: 'Subject', controller: _subjectCtrl,
              icon: Icons.subject_rounded),
            const SizedBox(height: 14),
            PremiumEditField(label: 'MESSAGE', hint: 'Message', controller: _messageCtrl,
              icon: Icons.chat_bubble_outline_rounded, maxLines: 4),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: 200.ms, height: 54,
                decoration: BoxDecoration(
                  gradient: kPurpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kGlow(kPurple, blur: 24),
                ),
                child: Center(child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: kWhite))
                    : Text('Save Changes', style: GoogleFonts.poppins(
                        color: kWhite, fontSize: 15, fontWeight: FontWeight.w600))),
              ),
            ),
          ]),
        )),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 12 — CONTACT DETAIL PAGE
// ════════════════════════════════════════════════════════════

class ContactDetailPage extends StatelessWidget {
  final ContactEntry entry;
  const ContactDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _Header(title: 'Message Detail', subtitle: 'contact'),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            _DetailCard(
              title: 'Sender',
              icon: Icons.person_outline_rounded,
              iconColor: kGreen,
              child: Column(children: [
                _DetailRow('Name', entry.name.isEmpty ? 'N/A' : entry.name),
                _DetailRow('Email', entry.email.isEmpty ? 'N/A' : entry.email),
                _DetailRow('Date', formatDate(entry.createdAt)),
              ]),
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Subject',
              icon: Icons.subject_rounded,
              iconColor: kTeal,
              child: Text(entry.subject, style: GoogleFonts.poppins(
                color: kWhite, fontSize: 15, fontWeight: FontWeight.w600,
              )),
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Message',
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: kPurpleLight,
              child: Text(entry.message, style: GoogleFonts.poppins(
                color: kWhite, fontSize: 14, height: 1.7,
              )),
            ),
          ]),
        )),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 13 — PROFILES SCREEN  (profiles_screen.dart)
// ════════════════════════════════════════════════════════════

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Profiles', style: GoogleFonts.poppins(
              color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
            )),
            Text('Detailed user profiles', style: GoogleFonts.poppins(
              color: kSecondary, fontSize: 12,
            )),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms),

      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 4,
                itemBuilder: (_, __) => const SkeletonCard(height: 105),
              );
            }
            if (snap.hasError) return ErrorState(error: snap.error.toString());
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const EmptyState(
                title: 'No profiles yet',
                subtitle: 'Users collection is empty',
                icon: Icons.person_pin_outlined,
              );
            }
            final profiles = docs.map(UserProfile.fromDoc).toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              itemCount: profiles.length,
              itemBuilder: (ctx, i) => _ProfileCard(
                profile: profiles[i],
                index: i,
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final int index;
  const _ProfileCard({required this.profile, required this.index});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(itemName: profile.fullName),
    );
    if (confirmed != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(profile.id).delete();
      if (context.mounted) showSnack(context, '${profile.fullName} profile deleted');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Delete failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = profile.fullName.trim().split(' ')
        .where((w) => w.isNotEmpty).take(2)
        .map((w) => w[0].toUpperCase()).join();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: kTealGradient,
                shape: BoxShape.circle,
                boxShadow: kGlow(kTeal, blur: 10),
              ),
              child: Center(child: Text(
                letters.isEmpty ? '?' : letters,
                style: GoogleFonts.poppins(
                  color: kWhite, fontSize: 16, fontWeight: FontWeight.w700,
                ),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName.isEmpty ? 'Unnamed' : profile.fullName,
                  style: GoogleFonts.poppins(
                    color: kWhite, fontSize: 14, fontWeight: FontWeight.w600,
                  )),
                Text(profile.email, style: GoogleFonts.poppins(
                  color: kSecondary, fontSize: 11,
                ), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  if (profile.country.isNotEmpty) ...[
                    const Icon(Icons.location_on_outlined, color: kTeal, size: 10),
                    const SizedBox(width: 3),
                    Text(profile.country, style: GoogleFonts.poppins(
                      color: kTeal, fontSize: 9, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(width: 8),
                  ],
                  if (profile.currency.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: kGold.withOpacity(0.28)),
                      ),
                      child: Text(profile.currency, style: GoogleFonts.poppins(
                        color: kGold, fontSize: 8, fontWeight: FontWeight.w700,
                      )),
                    ),
                  if (profile.age > 0) ...[
                    const SizedBox(width: 8),
                    Text('Age: ${profile.age}', style: GoogleFonts.poppins(
                      color: kSecondary, fontSize: 9,
                    )),
                  ],
                ]),
              ],
            )),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            ActionBtn(
              label: 'Edit',
              icon: Icons.edit_outlined,
              color: kPurpleLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => EditProfilePage(profile: profile),
              )),
            ),
            const SizedBox(width: 8),
            ActionBtn(
              label: 'View',
              icon: Icons.open_in_new_rounded,
              color: kTeal,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ProfileDetailPage(profile: profile),
              )),
            ),
            const Spacer(),
            ActionBtn(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              color: kErrorRed,
              onTap: () => _delete(context),
            ),
          ]),
        ),
      ]),
    )
    .animate(delay: (50 * index).ms)
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 14 — EDIT PROFILE PAGE
// ════════════════════════════════════════════════════════════

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: widget.profile.fullName);
    _emailCtrl   = TextEditingController(text: widget.profile.email);
    _phoneCtrl   = TextEditingController(text: widget.profile.phone);
    _addressCtrl = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(widget.profile.id)
          .update({
            'fullName':  _nameCtrl.text.trim(),
            'email':     _emailCtrl.text.trim(),
            'phone':     _phoneCtrl.text.trim(),
            'address':   _addressCtrl.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        showSnack(context, 'Profile updated!');
        await Future.delayed(1000.ms);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _Header(title: 'Edit Profile', subtitle: 'users'),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            PremiumEditField(label: 'FULL NAME', hint: 'Full name', controller: _nameCtrl,
              icon: Icons.badge_outlined),
            const SizedBox(height: 14),
            PremiumEditField(label: 'EMAIL', hint: 'Email', controller: _emailCtrl,
              icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            PremiumEditField(label: 'PHONE', hint: 'Phone number', controller: _phoneCtrl,
              icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            PremiumEditField(label: 'ADDRESS', hint: 'Address', controller: _addressCtrl,
              icon: Icons.location_on_outlined, maxLines: 3),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: 200.ms, height: 54,
                decoration: BoxDecoration(
                  gradient: kPurpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kGlow(kPurple, blur: 24),
                ),
                child: Center(child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: kWhite))
                    : Text('Save Changes', style: GoogleFonts.poppins(
                        color: kWhite, fontSize: 15, fontWeight: FontWeight.w600))),
              ),
            ),
          ]),
        )),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 15 — PROFILE DETAIL PAGE
// ════════════════════════════════════════════════════════════

class ProfileDetailPage extends StatelessWidget {
  final UserProfile profile;
  const ProfileDetailPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(children: [
        _Header(title: 'Profile Detail', subtitle: 'users'),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            _DetailCard(
              title: 'Personal Info',
              icon: Icons.person_outline_rounded,
              iconColor: kTeal,
              child: Column(children: [
                _DetailRow('Full Name', profile.fullName),
                _DetailRow('Email', profile.email),
                _DetailRow('Phone', profile.phone.isEmpty ? 'N/A' : profile.phone),
                _DetailRow('Gender', profile.gender.isEmpty ? 'N/A' : profile.gender),
                _DetailRow('Date of Birth', profile.dob.isEmpty ? 'N/A' : profile.dob),
                _DetailRow('Age', profile.age == 0 ? 'N/A' : '${profile.age} years'),
              ]),
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Location & Currency',
              icon: Icons.language_rounded,
              iconColor: kGold,
              child: Column(children: [
                _DetailRow('Country', profile.country.isEmpty ? 'N/A' : profile.country),
                _DetailRow('Currency', profile.currency.isEmpty ? 'N/A' : profile.currency),
                _DetailRow('Address', profile.address.isEmpty ? 'N/A' : profile.address),
              ]),
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Account',
              icon: Icons.info_outline_rounded,
              iconColor: kSecondary,
              child: Column(children: [
                _DetailRow('User ID', profile.id),
                _DetailRow('Joined', formatDate(profile.createdAt)),
              ]),
            ),
          ]),
        )),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  SECTION 16 — SETTINGS SCREEN
// ════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings', style: GoogleFonts.poppins(
          color: kWhite, fontSize: 22, fontWeight: FontWeight.w700,
        )).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Admin panel configuration', style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 12,
        )).animate().fadeIn(delay: 80.ms, duration: 400.ms),
        const SizedBox(height: 24),

        _SettingsSection(title: 'ACCOUNT', items: [
          _SettingsItem(
            icon: Icons.person_outline_rounded,
            label: 'Admin Profile',
            sub: 'Manage your admin details',
            color: kPurpleLight,
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.lock_reset_rounded,
            label: 'Change Password',
            sub: 'Reset your admin password',
            color: kGold,
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.email != null) {
                FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                showSnack(context, 'Reset email sent to ${user.email}');
              }
            },
          ),
        ]),

        const SizedBox(height: 16),

        _SettingsSection(title: 'COLLECTIONS', items: [
          _SettingsItem(
            icon: Icons.people_outline_rounded,
            label: 'Customers Collection',
            sub: 'customers',
            color: kPurpleLight,
            trailing: _CollectionCount('customers'),
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google Users',
            sub: 'google_users',
            color: kGold,
            trailing: _CollectionCount('google_users'),
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.rate_review_outlined,
            label: 'Feedback',
            sub: 'feedback',
            color: kGreen,
            trailing: _CollectionCount('feedback'),
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.mail_outline_rounded,
            label: 'Contact',
            sub: 'contact',
            color: kTeal,
            trailing: _CollectionCount('contact'),
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.person_pin_outlined,
            label: 'Profiles',
            sub: 'users',
            color: kGold,
            trailing: _CollectionCount('users'),
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 16),
_SettingsSection(
  title: 'DANGER ZONE',
  items: [
    _SettingsItem(
      icon: Icons.logout_rounded,
      label: 'Sign Out',
      sub: 'Log out of admin panel',
      color: kErrorRed,

      onTap: () {
        FirebaseAuth.instance.signOut().then((_) {

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AuthApp(),
            ),
            (route) => false,
          );

        });
      },
    ),
  ],
),
      ]),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.2,
        )),
      ),
      Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final last = i == items.length - 1;
            return Column(children: [
              GestureDetector(
                onTap: item.onTap,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: item.color.withOpacity(0.25)),
                      ),
                      child: Icon(item.icon, color: item.color, size: 16),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: GoogleFonts.poppins(
                          color: kWhite, fontSize: 13, fontWeight: FontWeight.w600,
                        )),
                        Text(item.sub, style: GoogleFonts.poppins(
                          color: kSecondary, fontSize: 10,
                        )),
                      ],
                    )),
                    item.trailing ??
                      Icon(Icons.chevron_right_rounded, color: kSecondary, size: 18),
                  ]),
                ),
              ),
              if (!last) Container(
                height: 1, margin: const EdgeInsets.symmetric(horizontal: 16),
                color: kBorder,
              ),
            ]);
          }),
        ),
      ),
    ]).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}

class _SettingsItem {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
    this.trailing,
  });
}

class _CollectionCount extends StatelessWidget {
  final String collection;
  const _CollectionCount(this.collection);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (_, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kPurple.withOpacity(0.25)),
          ),
          child: Text('$count', style: GoogleFonts.poppins(
            color: kPurpleLight, fontSize: 11, fontWeight: FontWeight.w700,
          )),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION 17 — SHARED DETAIL WIDGETS
// ════════════════════════════════════════════════════════════

/// Reusable back header for detail / edit pages
class _Header extends StatelessWidget {
  final String title, subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: kCardBg, borderRadius: BorderRadius.circular(13),
            border: Border.all(color: kBorder),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: kWhite, size: 20),
        ),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(
          color: kWhite, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        Text(subtitle, style: GoogleFonts.poppins(
          color: kSecondary, fontSize: 11,
        )),
      ]),
    ]),
  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.08, end: 0);
}

/// Reusable detail card
class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconColor.withOpacity(0.25)),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(
            color: kSecondary, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.6,
          )),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}

/// Reusable key-value row for detail pages
class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          child: Text(label, style: GoogleFonts.poppins(
            color: kSecondary, fontSize: 12,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: GoogleFonts.poppins(
          color: kWhite, fontSize: 12, fontWeight: FontWeight.w500,
        ))),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  USAGE:
//
//  In your app, navigate to AdminShell:
//
//  MaterialPageRoute(builder: (_) => const AdminShell())
//
//  Make sure your pubspec.yaml includes:
//   - cloud_firestore: ^5.x.x
//   - firebase_auth: ^5.x.x
//   - google_fonts: ^6.x.x
//   - flutter_animate: ^4.x.x
//
//  Firestore collections used:
//   - customers       (users from email registration)
//   - google_users    (users from Google sign-in)
//   - admins          (admin accounts)
//   - feedback        (user feedback with rating, categories, etc.)
//   - contact         (contact us messages: name, email, subject, message)
//   - users           (detailed user profiles)
// ════════════════════════════════════════════════════════════
