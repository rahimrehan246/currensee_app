import 'dart:convert';

import 'package:curreny/User/screens/contact/contactus.dart';
import 'package:curreny/User/screens/converter/converter_screen.dart';
import 'package:curreny/User/screens/exchange_rate/app_theme.dart';
import 'package:curreny/User/screens/exchange_rate/exchange_rate_screen.dart';
import 'package:curreny/User/screens/feedback/feedback_form.dart';
import 'package:curreny/User/screens/profile/profilescreen.dart';
import 'package:curreny/User/screens/registration/register_screen.dart';
import 'package:curreny/User/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PremiumDrawer extends StatelessWidget {
  const PremiumDrawer({super.key});

  // ================= NAVIGATION =================
  void _go(BuildContext context, int index) {
    Navigator.pop(context);

    Widget page;

    switch (index) {
      case 0:
        page = const ConverterScreen();
        break;
      case 1:
        page = const ExchangeRateScreen();
        break;
      case 2:
        page = const StatisticsScreen();
        break;
      case 3:
        page = const ProfileSetupScreen();
        break;
      case 4:
        page = const FeedbackFormPage();
        break;
      case 5:
        page = const ContactUsPage(); // ✅ NEW
        break;
      default:
        page = const ConverterScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ================= LOGOUT =================
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthApp()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppColors.kNavBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "User";
                String email = user.email ?? "";
                String? imageBase64;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  name = data['fullName'] ?? name;
                  email = data['email'] ?? email;
                  imageBase64 = data['profileImageBase64'];
                }

                ImageProvider? imageProvider;

                if (imageBase64 != null &&
                    imageBase64.isNotEmpty &&
                    imageBase64.contains('base64,')) {
                  final base64Str = imageBase64.split('base64,').last;
                  imageProvider = MemoryImage(base64Decode(base64Str));
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.kPurple,
                        AppColors.kPurpleDark,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(Icons.person,
                                color: Colors.white, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ================= MENU ITEMS =================
            _item(context, Icons.currency_exchange_rounded,
                "Currency Converter", 0),

            _item(context, Icons.swap_horiz_rounded,
                "Live Exchange Rate", 1),

            _item(context, Icons.bar_chart_rounded,
                "Statistics", 2),

            _item(context, Icons.person_outline_rounded,
                "Profile", 3),

            _item(context, Icons.feedback_outlined,
                "Feedback", 4),

            _item(context, Icons.contact_mail_outlined,
                "Contact Us", 5), // ✅ NEW

            const Spacer(),

            Divider(
              color: Colors.white.withOpacity(0.08),
              thickness: 1,
              indent: 24,
              endIndent: 24,
            ),

            _itemLogout(context),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _go(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.kTextSecondary, size: 20),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  Widget _itemLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _logout(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.red.withOpacity(0.08),
            border: Border.all(
              color: Colors.red.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}