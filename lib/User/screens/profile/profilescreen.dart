// ============================================================
//  PREMIUM DARK PROFILE SETUP SCREEN
//  Stack : Flutter + Firebase Auth + Firestore
//  Image : Base64 → Firestore (NO Firebase Storage — no timeout)
//  Design: Fintech dark UI — Binance / Revolut style
//  FIXES:
//   ✅ Image.file REMOVED — Image.memory used (web + mobile both)
//   ✅ Firebase Storage REMOVED — no timeout possible
//   ✅ Image → base64 → Firestore (instant, no network for image)
//   ✅ dart:io import guarded — no web crash
//   ✅ All validations: name, phone, email, address, dob, gender
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
//  GRADIENTS & SHADOWS
// ─────────────────────────────────────────────────────────────
const kPurpleGradient = LinearGradient(
  colors: [kPurpleDark, kPurple, kPurpleLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAvatarBorderGradient = SweepGradient(
  colors: [kPurpleLight, kPurple, kPurpleDark, kPurpleLight],
  startAngle: 0,
  endAngle: math.pi * 2,
);

List<BoxShadow> kPurpleGlow({double blur = 24, double spread = 0}) => [
  BoxShadow(
    color: kPurple.withOpacity(0.45),
    blurRadius: blur,
    spreadRadius: spread,
  ),
];

final kSubtleGlow = [
  BoxShadow(color: kPurple.withOpacity(0.22), blurRadius: 14, spreadRadius: -2),
];

// ─────────────────────────────────────────────────────────────
//  COUNTRY DATA
// ─────────────────────────────────────────────────────────────
class CountryData {
  final String name, code, currency, flag;
  const CountryData({
    required this.name,
    required this.code,
    required this.currency,
    required this.flag,
  });
}

const List<CountryData> kCountries = [
  CountryData(name: 'Afghanistan',    code: 'AF', currency: 'AFN', flag: '🇦🇫'),
  CountryData(name: 'Albania',        code: 'AL', currency: 'ALL', flag: '🇦🇱'),
  CountryData(name: 'Algeria',        code: 'DZ', currency: 'DZD', flag: '🇩🇿'),
  CountryData(name: 'Argentina',      code: 'AR', currency: 'ARS', flag: '🇦🇷'),
  CountryData(name: 'Australia',      code: 'AU', currency: 'AUD', flag: '🇦🇺'),
  CountryData(name: 'Austria',        code: 'AT', currency: 'EUR', flag: '🇦🇹'),
  CountryData(name: 'Bangladesh',     code: 'BD', currency: 'BDT', flag: '🇧🇩'),
  CountryData(name: 'Belgium',        code: 'BE', currency: 'EUR', flag: '🇧🇪'),
  CountryData(name: 'Brazil',         code: 'BR', currency: 'BRL', flag: '🇧🇷'),
  CountryData(name: 'Canada',         code: 'CA', currency: 'CAD', flag: '🇨🇦'),
  CountryData(name: 'China',          code: 'CN', currency: 'CNY', flag: '🇨🇳'),
  CountryData(name: 'Colombia',       code: 'CO', currency: 'COP', flag: '🇨🇴'),
  CountryData(name: 'Czech Republic', code: 'CZ', currency: 'CZK', flag: '🇨🇿'),
  CountryData(name: 'Denmark',        code: 'DK', currency: 'DKK', flag: '🇩🇰'),
  CountryData(name: 'Egypt',          code: 'EG', currency: 'EGP', flag: '🇪🇬'),
  CountryData(name: 'Finland',        code: 'FI', currency: 'EUR', flag: '🇫🇮'),
  CountryData(name: 'France',         code: 'FR', currency: 'EUR', flag: '🇫🇷'),
  CountryData(name: 'Germany',        code: 'DE', currency: 'EUR', flag: '🇩🇪'),
  CountryData(name: 'Ghana',          code: 'GH', currency: 'GHS', flag: '🇬🇭'),
  CountryData(name: 'Greece',         code: 'GR', currency: 'EUR', flag: '🇬🇷'),
  CountryData(name: 'Hong Kong',      code: 'HK', currency: 'HKD', flag: '🇭🇰'),
  CountryData(name: 'Hungary',        code: 'HU', currency: 'HUF', flag: '🇭🇺'),
  CountryData(name: 'India',          code: 'IN', currency: 'INR', flag: '🇮🇳'),
  CountryData(name: 'Indonesia',      code: 'ID', currency: 'IDR', flag: '🇮🇩'),
  CountryData(name: 'Iran',           code: 'IR', currency: 'IRR', flag: '🇮🇷'),
  CountryData(name: 'Iraq',           code: 'IQ', currency: 'IQD', flag: '🇮🇶'),
  CountryData(name: 'Ireland',        code: 'IE', currency: 'EUR', flag: '🇮🇪'),
  CountryData(name: 'Israel',         code: 'IL', currency: 'ILS', flag: '🇮🇱'),
  CountryData(name: 'Italy',          code: 'IT', currency: 'EUR', flag: '🇮🇹'),
  CountryData(name: 'Japan',          code: 'JP', currency: 'JPY', flag: '🇯🇵'),
  CountryData(name: 'Jordan',         code: 'JO', currency: 'JOD', flag: '🇯🇴'),
  CountryData(name: 'Kenya',          code: 'KE', currency: 'KES', flag: '🇰🇪'),
  CountryData(name: 'Kuwait',         code: 'KW', currency: 'KWD', flag: '🇰🇼'),
  CountryData(name: 'Lebanon',        code: 'LB', currency: 'LBP', flag: '🇱🇧'),
  CountryData(name: 'Malaysia',       code: 'MY', currency: 'MYR', flag: '🇲🇾'),
  CountryData(name: 'Mexico',         code: 'MX', currency: 'MXN', flag: '🇲🇽'),
  CountryData(name: 'Morocco',        code: 'MA', currency: 'MAD', flag: '🇲🇦'),
  CountryData(name: 'Netherlands',    code: 'NL', currency: 'EUR', flag: '🇳🇱'),
  CountryData(name: 'New Zealand',    code: 'NZ', currency: 'NZD', flag: '🇳🇿'),
  CountryData(name: 'Nigeria',        code: 'NG', currency: 'NGN', flag: '🇳🇬'),
  CountryData(name: 'Norway',         code: 'NO', currency: 'NOK', flag: '🇳🇴'),
  CountryData(name: 'Oman',           code: 'OM', currency: 'OMR', flag: '🇴🇲'),
  CountryData(name: 'Pakistan',       code: 'PK', currency: 'PKR', flag: '🇵🇰'),
  CountryData(name: 'Philippines',    code: 'PH', currency: 'PHP', flag: '🇵🇭'),
  CountryData(name: 'Poland',         code: 'PL', currency: 'PLN', flag: '🇵🇱'),
  CountryData(name: 'Portugal',       code: 'PT', currency: 'EUR', flag: '🇵🇹'),
  CountryData(name: 'Qatar',          code: 'QA', currency: 'QAR', flag: '🇶🇦'),
  CountryData(name: 'Romania',        code: 'RO', currency: 'RON', flag: '🇷🇴'),
  CountryData(name: 'Russia',         code: 'RU', currency: 'RUB', flag: '🇷🇺'),
  CountryData(name: 'Saudi Arabia',   code: 'SA', currency: 'SAR', flag: '🇸🇦'),
  CountryData(name: 'Singapore',      code: 'SG', currency: 'SGD', flag: '🇸🇬'),
  CountryData(name: 'South Africa',   code: 'ZA', currency: 'ZAR', flag: '🇿🇦'),
  CountryData(name: 'South Korea',    code: 'KR', currency: 'KRW', flag: '🇰🇷'),
  CountryData(name: 'Spain',          code: 'ES', currency: 'EUR', flag: '🇪🇸'),
  CountryData(name: 'Sri Lanka',      code: 'LK', currency: 'LKR', flag: '🇱🇰'),
  CountryData(name: 'Sweden',         code: 'SE', currency: 'SEK', flag: '🇸🇪'),
  CountryData(name: 'Switzerland',    code: 'CH', currency: 'CHF', flag: '🇨🇭'),
  CountryData(name: 'Taiwan',         code: 'TW', currency: 'TWD', flag: '🇹🇼'),
  CountryData(name: 'Thailand',       code: 'TH', currency: 'THB', flag: '🇹🇭'),
  CountryData(name: 'Turkey',         code: 'TR', currency: 'TRY', flag: '🇹🇷'),
  CountryData(name: 'UAE',            code: 'AE', currency: 'AED', flag: '🇦🇪'),
  CountryData(name: 'Ukraine',        code: 'UA', currency: 'UAH', flag: '🇺🇦'),
  CountryData(name: 'United Kingdom', code: 'GB', currency: 'GBP', flag: '🇬🇧'),
  CountryData(name: 'United States',  code: 'US', currency: 'USD', flag: '🇺🇸'),
  CountryData(name: 'Vietnam',        code: 'VN', currency: 'VND', flag: '🇻🇳'),
];

// ─────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────
class UserProfile {
  final String   uid, fullName, email, phone;
  final String   country, currency, gender, dob, address;
  final String   profileImageBase64;
  final int      age;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.currency,
    required this.gender,
    required this.dob,
    required this.age,
    required this.address,
    required this.profileImageBase64,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid':                uid,
    'fullName':           fullName,
    'email':              email,
    'phone':              phone,
    'country':            country,
    'currency':           currency,
    'gender':             gender,
    'dob':                dob,
    'age':                age,
    'address':            address,
    'profileImageBase64': profileImageBase64,
    'createdAt':          Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────
//  WIDGET — _PremiumField
// ─────────────────────────────────────────────────────────────
class _PremiumField extends StatefulWidget {
  final String                     label, hint;
  final TextEditingController      controller;
  final Widget?                    prefix, suffix;
  final bool                       readOnly;
  final int                        maxLines;
  final TextInputType              keyboardType;
  final List<TextInputFormatter>?  formatters;
  final String? Function(String?)? validator;
  final VoidCallback?              onTap;
  final void Function(String)?    onChanged;
  final TextCapitalization         cap;

  const _PremiumField({
    required this.label,
    required this.hint,
    required this.controller,
    this.prefix,
    this.suffix,
    this.readOnly     = false,
    this.maxLines     = 1,
    this.keyboardType = TextInputType.text,
    this.formatters,
    this.validator,
    this.onTap,
    this.onChanged,
    this.cap          = TextCapitalization.none,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focus   = FocusNode();
  bool  _focused = false;

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
          fontSize: 11, fontWeight: FontWeight.w600,
          color: _focused ? kPurpleLight : kSecondary,
          letterSpacing: 0.6,
        ),
        child: Text(widget.label.toUpperCase()),
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
          boxShadow: _focused ? kSubtleGlow : null,
        ),
        child: TextFormField(
          controller:         widget.controller,
          focusNode:          _focus,
          readOnly:           widget.readOnly,
          maxLines:           widget.maxLines,
          keyboardType:       widget.keyboardType,
          inputFormatters:    widget.formatters,
          validator:          widget.validator,
          onChanged:          widget.onChanged,
          onTap:              widget.onTap,
          textCapitalization: widget.cap,
          style: GoogleFonts.poppins(
            color: widget.readOnly ? kSecondary : kWhite,
            fontSize: 14, fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText:  widget.hint,
            hintStyle: GoogleFonts.poppins(
              color: kSecondary.withOpacity(0.45), fontSize: 13,
            ),
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
            filled:     true,
            fillColor:  widget.readOnly ? kInputBg.withOpacity(0.55) : kInputBg,
            border:             _ob(),
            enabledBorder:      _ob(),
            focusedBorder:      _ob(),
            errorBorder:        _eb(),
            focusedErrorBorder: _eb(focused: true),
            errorStyle: GoogleFonts.poppins(
              color: kErrorRed, fontSize: 11, fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: widget.maxLines > 1 ? 14 : 0,
            ),
          ),
        ),
      ),
    ],
  );

  OutlineInputBorder _ob() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );
  OutlineInputBorder _eb({bool focused = false}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: kErrorRed, width: focused ? 1.5 : 1.0),
  );
}

// ─────────────────────────────────────────────────────────────
//  WIDGET — _PremiumButton
// ─────────────────────────────────────────────────────────────
class _PremiumButton extends StatelessWidget {
  final String       label;
  final VoidCallback? onTap;
  final bool         loading;
  final Widget?      icon;

  const _PremiumButton({
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: 200.ms,
      height: 56,
      decoration: BoxDecoration(
        gradient: onTap != null
            ? kPurpleGradient
            : const LinearGradient(colors: [kBorder, kNavy]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onTap != null ? kPurpleGlow(blur: 32, spread: -2) : null,
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: kWhite),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(label, style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: kWhite, letterSpacing: 0.3,
                  )),
                ],
              ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  WIDGET — _SectionHeader
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String  title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: kPurpleLight, size: 16),
    ),
    const SizedBox(width: 10),
    Text(title, style: GoogleFonts.poppins(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: kSecondary, letterSpacing: 1.1,
    )),
    const SizedBox(width: 12),
    Expanded(child: Container(height: 1, color: kBorder)),
  ]);
}

// ─────────────────────────────────────────────────────────────
//  WIDGET — _CountryPickerSheet
// ─────────────────────────────────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();
  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _search = TextEditingController();
  List<CountryData> _list = kCountries;

  void _filter(String q) {
    final ql = q.toLowerCase();
    setState(() => _list = kCountries.where((c) =>
      c.name.toLowerCase().contains(ql) ||
      c.currency.toLowerCase().contains(ql) ||
      c.code.toLowerCase().contains(ql),
    ).toList());
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.88,
    maxChildSize: 0.96,
    minChildSize: 0.5,
    builder: (_, ctrl) => Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: kBorder),
      ),
      child: Column(children: [
        const SizedBox(height: 12),
        Center(child: Container(
          width: 38, height: 4,
          decoration: BoxDecoration(
            color: kBorder, borderRadius: BorderRadius.circular(2),
          ),
        )),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: kPurpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.language_rounded, color: kWhite, size: 18),
            ),
            const SizedBox(width: 12),
            Text('Select Country', style: GoogleFonts.poppins(
              fontSize: 17, fontWeight: FontWeight.w700, color: kWhite,
            )),
          ]),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _search,
            onChanged:  _filter,
            style: GoogleFonts.poppins(color: kWhite, fontSize: 13),
            decoration: InputDecoration(
              hintText:   'Search country or currency…',
              hintStyle:  GoogleFonts.poppins(
                color: kSecondary.withOpacity(0.55), fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: kSecondary, size: 18),
              filled:     true,
              fillColor:  kInputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPurple, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            controller:  ctrl,
            itemCount:   _list.length,
            itemBuilder: (_, i) {
              final c = _list[i];
              return InkWell(
                onTap: () => Navigator.pop(context, c),
                splashColor: kPurple.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Row(children: [
                    Text(c.flag, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(c.name, style: GoogleFonts.poppins(
                      color: kWhite, fontSize: 14, fontWeight: FontWeight.w500,
                    ))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPurple.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kPurple.withOpacity(0.28)),
                      ),
                      child: Text(c.currency, style: GoogleFonts.poppins(
                        color: kPurpleLight, fontSize: 11, fontWeight: FontWeight.w700,
                      )),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  MAIN SCREEN — ProfileSetupScreen
// ─────────────────────────────────────────────────────────────
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {

  // Controllers
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _ageCtrl     = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dobCtrl     = TextEditingController();

  // ✅ FIX: Uint8List — works on web + mobile. No File, no Image.file
  Uint8List?   _imageBytes;
  bool         _isSaving      = false;
  DateTime?    _selectedDob;
  String       _selectedGender  = '';
  CountryData? _selectedCountry;

  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _prefillEmail();
  }

  void _prefillEmail() {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.email != null) _emailCtrl.text = u!.email!;
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl,
      _ageCtrl, _addressCtrl, _dobCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── Pick image ───────────────────────────────────────────────
  // ✅ readAsBytes() — no dart:io, no Image.file, works on web + mobile
  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source:       ImageSource.gallery,
        imageQuality: 50,
        maxWidth:     600,
        maxHeight:    600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _snack('Could not pick image: $e', error: true);
    }
  }

  // ── Pick DOB ─────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context:     context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate:   DateTime(1920),
      lastDate:    DateTime(now.year - 10, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPurple, onPrimary: kWhite,
            surface: kCardBg, onSurface: kWhite,
          ),
          dialogBackgroundColor: kNavy,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: kPurpleLight),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final age = now.year - picked.year
        - ((now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) ? 1 : 0);
    setState(() {
      _selectedDob  = picked;
      _dobCtrl.text = DateFormat('dd / MM / yyyy').format(picked);
      _ageCtrl.text = '$age years';
    });
  }

  // ── Pick country ─────────────────────────────────────────────
  Future<void> _pickCountry() async {
    final result = await showModalBottomSheet<CountryData>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder:            (_) => const _CountryPickerSheet(),
    );
    if (result != null) setState(() => _selectedCountry = result);
  }

  // ─────────────────────────────────────────────────────────────
  //  SAVE — Image → base64 → Firestore. No Storage. No timeout.
  // ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedGender.isEmpty) {
      _snack('Please select your gender', error: true); return;
    }
    if (_selectedCountry == null) {
      _snack('Please select your country', error: true); return;
    }
    if (_selectedDob == null) {
      _snack('Please select your date of birth', error: true); return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in — please sign in again');

      // ✅ Convert bytes → base64 string. Instant. No network needed.
      String base64Image = '';
      if (_imageBytes != null && _imageBytes!.isNotEmpty) {
        base64Image = 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
      }

      // Age
      final dob = _selectedDob!;
      final now = DateTime.now();
      final age = now.year - dob.year
          - ((now.month < dob.month ||
              (now.month == dob.month && now.day < dob.day)) ? 1 : 0);

      final profile = UserProfile(
        uid:                user.uid,
        fullName:           _nameCtrl.text.trim(),
        email:              _emailCtrl.text.trim(),
        phone:              _phoneCtrl.text.trim(),
        country:            _selectedCountry!.name,
        currency:           _selectedCountry!.currency,
        gender:             _selectedGender,
        dob:                _dobCtrl.text.trim(),
        age:                age,
        address:            _addressCtrl.text.trim(),
        profileImageBase64: base64Image,
        createdAt:          DateTime.now(),
      );

      // ✅ Single Firestore call — always works, no Storage rules needed
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      _snack('Profile saved successfully 🎉');

      // Uncomment to navigate:
      // if (mounted) Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseException catch (e) {
      _snack('[${e.code}] ${e.message ?? "Firebase error"}', error: true);
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Snackbar ─────────────────────────────────────────────────
  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: error ? kErrorRed : kPurpleLight, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.poppins(
          fontSize: 13, color: kWhite, fontWeight: FontWeight.w500,
        ))),
      ]),
      backgroundColor: error ? const Color(0xFF1A0D18) : kNavy,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: error ? kErrorRed.withOpacity(0.3) : kPurple.withOpacity(0.3),
        ),
      ),
      margin:   const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ));
  }

  Widget _ico(IconData d) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Icon(d, color: kSecondary, size: 18),
  );

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: Stack(children: [

      // Animated ambient glows
      AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          final t = _bgCtrl.value;
          return Stack(children: [
            Positioned(
              top:  -60 + 30 * math.sin(t * math.pi),
              left: -40 + 20 * math.cos(t * math.pi),
              child: _glow(340, kPurple, 0.18 + 0.06 * t),
            ),
            Positioned(
              bottom: 80 + 20 * math.cos(t * math.pi),
              right:  -70 + 20 * math.sin(t * math.pi),
              child: _glow(280, kPurpleDark, 0.14 + 0.05 * t),
            ),
          ]);
        },
      ),

      SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildAvatar()),
            SliverToBoxAdapter(child: _buildForm()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    ]),
  );

  Widget _glow(double size, Color c, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [c.withOpacity(opacity), Colors.transparent],
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────
// HEADER WITH DRAWER BUTTON
// ─────────────────────────────────────────────────────────────

Widget _buildHeader() => Padding(
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
  child: Row(
    children: [

      // ── SIMPLE BACK BUTTON ──
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: kWhite,
          size: 20,
        ),
      ),

      const SizedBox(width: 14),

      // ── TITLE ──
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete Your Profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: kWhite,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Setup your account details',
              style: GoogleFonts.poppins(
                color: kSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // ── EMPTY SPACE (NO DRAWER, NO REFRESH) ──
      const SizedBox(width: 10),
    ],
  ),
);  // ── Avatar ───────────────────────────────────────────────────
  Widget _buildAvatar() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Center(
      child: Column(children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [

            // Pulse glow
            Container(
              width: 124, height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: kPurpleGlow(blur: 38, spread: 6),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scaleXY(begin: 0.97, end: 1.03, duration: 2000.ms, curve: Curves.easeInOut),

            // Gradient ring + image
            Container(
              width: 120, height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: kAvatarBorderGradient,
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Container(
                  color: kCardBg,
                  // ✅ FIX: Image.memory — works on web AND mobile
                  // No Image.file, no dart:io, no kIsWeb check needed
                  child: _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_rounded,
                            color: kSecondary, size: 40,
                          ),
                        )
                      : const Icon(Icons.person_rounded, color: kSecondary, size: 54),
                ),
              ),
            ),

            // Camera badge
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: kPurpleGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 2),
                  boxShadow: kPurpleGlow(blur: 12),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: kWhite, size: 16),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scaleXY(begin: 1, end: 1.1, duration: 1400.ms, curve: Curves.easeInOut),
            ),
          ]),
        ),

        const SizedBox(height: 12),
        Text(
          _imageBytes != null ? 'Tap to change photo' : 'Upload Profile Photo',
          style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500, color: kPurpleLight,
          ),
        ),
      ]),
    ),
  ).animate().fadeIn(delay: 300.ms, duration: 600.ms)
   .scaleXY(begin: 0.88, end: 1, curve: Curves.easeOut);

  // ── Form ─────────────────────────────────────────────────────
  Widget _buildForm() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // ══ PERSONAL INFO ══
        const _SectionHeader(title: 'PERSONAL INFO', icon: Icons.person_outline_rounded)
          .animate().fadeIn(delay: 350.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 20),

        _PremiumField(
          label:      'Full Name',
          hint:       'Enter your full name',
          controller: _nameCtrl,
          prefix:     _ico(Icons.badge_outlined),
          cap:        TextCapitalization.words,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            LengthLimitingTextInputFormatter(60),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Full name is required';
            if (v.trim().length < 3) return 'Name must be at least 3 characters';
            return null;
          },
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 16),

        _PremiumField(
          label:        'Email Address',
          hint:         'Auto-fetched from account',
          controller:   _emailCtrl,
          readOnly:     true,
          prefix:       _ico(Icons.email_outlined),
          suffix:       const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.lock_outline_rounded, color: kSecondary, size: 15),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Email is required' : null,
        ).animate().fadeIn(delay: 440.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 16),

        _PremiumField(
          label:        'Phone Number',
          hint:         '+92 300 1234567',
          controller:   _phoneCtrl,
          prefix:       _ico(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
            LengthLimitingTextInputFormatter(18),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Phone number is required';
            final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
            if (digits.length < 10) return 'Enter at least 10 digits';
            if (digits.length > 15) return 'Phone number too long';
            return null;
          },
        ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 32),

        // ══ LOCATION ══
        const _SectionHeader(title: 'LOCATION & CURRENCY', icon: Icons.language_rounded)
          .animate().fadeIn(delay: 520.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 20),

        _buildCountrySelector()
          .animate().fadeIn(delay: 560.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 32),

        // ══ IDENTITY ══
        const _SectionHeader(title: 'IDENTITY', icon: Icons.fingerprint_rounded)
          .animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 20),

        _PremiumField(
          label:     'Date of Birth',
          hint:      'Select your birth date',
          controller: _dobCtrl,
          readOnly:  true,
          prefix:    _ico(Icons.calendar_today_outlined),
          suffix:    _ico(Icons.arrow_drop_down_rounded),
          onTap:     _pickDob,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Date of birth is required' : null,
        ).animate().fadeIn(delay: 640.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 16),

        _PremiumField(
          label:      'Age',
          hint:       'Auto-calculated',
          controller: _ageCtrl,
          readOnly:   true,
          prefix:     _ico(Icons.cake_outlined),
          suffix:     const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.auto_awesome_rounded, color: kSecondary, size: 14),
          ),
        ).animate().fadeIn(delay: 670.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 16),

        _buildGenderSelector()
          .animate().fadeIn(delay: 700.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 32),

        // ══ ADDRESS ══
        const _SectionHeader(title: 'ADDRESS', icon: Icons.home_outlined)
          .animate().fadeIn(delay: 730.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 20),

        _PremiumField(
          label:      'Full Address',
          hint:       'Street, City, State, ZIP',
          controller: _addressCtrl,
          prefix:     _ico(Icons.location_on_outlined),
          maxLines:   3,
          cap:        TextCapitalization.sentences,
          formatters: [LengthLimitingTextInputFormatter(200)],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Address is required';
            if (v.trim().length < 10) return 'Please enter a complete address';
            return null;
          },
        ).animate().fadeIn(delay: 760.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 36),

        // ══ CTA ══
        _PremiumButton(
          label:   'Complete Profile',
          loading: _isSaving,
          onTap:   _save,
          icon:    const Icon(Icons.check_circle_outline_rounded, color: kWhite, size: 18),
        ).animate().fadeIn(delay: 820.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: () { /* Navigator.pushReplacementNamed(context, '/home'); */ },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(child: Text(
              'Skip for now',
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: kSecondary,
                decoration:      TextDecoration.underline,
                decorationColor: kSecondary.withOpacity(0.4),
              ),
            )),
          ),
        ).animate().fadeIn(delay: 870.ms),
      ]),
    ),
  );

  // ── Country selector ─────────────────────────────────────────
  Widget _buildCountrySelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('COUNTRY & CURRENCY', style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: kSecondary, letterSpacing: 0.6,
      )),
      const SizedBox(height: 7),
      GestureDetector(
        onTap: _pickCountry,
        child: AnimatedContainer(
          duration: 200.ms,
          height: 52,
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _selectedCountry != null ? kPurple : kBorder,
              width: _selectedCountry != null ? 1.6 : 1.0,
            ),
            boxShadow: _selectedCountry != null ? kSubtleGlow : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            if (_selectedCountry != null)
              Text(_selectedCountry!.flag, style: const TextStyle(fontSize: 22))
            else
              Icon(Icons.flag_outlined, color: kSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _selectedCountry != null
                  ? '${_selectedCountry!.name}   ·   ${_selectedCountry!.currency}'
                  : 'Select your country',
              style: GoogleFonts.poppins(
                color: _selectedCountry != null
                    ? kWhite
                    : kSecondary.withOpacity(0.45),
                fontSize: 14,
              ),
            )),
            if (_selectedCountry != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kPurple.withOpacity(0.3)),
                ),
                child: Text(_selectedCountry!.currency, style: GoogleFonts.poppins(
                  fontSize: 10, color: kPurpleLight, fontWeight: FontWeight.w700,
                )),
              )
            else
              Icon(Icons.arrow_drop_down_rounded, color: kSecondary, size: 22),
          ]),
        ),
      ),
    ],
  );

  // ── Gender selector ──────────────────────────────────────────
  Widget _buildGenderSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('GENDER', style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: kSecondary, letterSpacing: 0.6,
      )),
      const SizedBox(height: 10),
      Row(
        children: ['Male', 'Female', 'Other'].asMap().entries.map((e) {
          final idx      = e.key;
          final g        = e.value;
          final selected = _selectedGender == g;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedGender = g),
            child: AnimatedContainer(
              duration: 180.ms,
              margin: EdgeInsets.only(right: idx < 2 ? 8 : 0),
              height: 46,
              decoration: BoxDecoration(
                color: selected ? kPurple.withOpacity(0.18) : kInputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? kPurple : kBorder,
                  width: selected ? 1.6 : 1.0,
                ),
                boxShadow: selected ? kSubtleGlow : null,
              ),
              child: Center(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check_circle_rounded, color: kPurpleLight, size: 13),
                    const SizedBox(width: 5),
                  ],
                  Text(g, style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: selected ? kPurpleLight : kSecondary,
                  )),
                ],
              )),
            ),
          ));
        }).toList(),
      ),
    ],
  );
}