// ============================================================
//  CURRENCYX — SMOOTH PREMIUM SPLASH SCREEN
//  Optimized + Lag Free + Same Premium UI
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curreny/user/screens/registration/auth_gate.dart';

// ════════════════════════════════════════════════════════════
// COLORS
// ════════════════════════════════════════════════════════════

const _kBg = Color(0xFF070B14);
const _kPurple = Color(0xFF5B2EFF);
const _kPurpleDark = Color(0xFF3A1ACC);
const _kGold = Color(0xFFFFD166);
const _kWhite = Colors.white;
const _kSecondary = Color(0xFFA0A7B8);
const _kBorder = Color(0xFF1E2A45);
const _kGreen = Color(0xFF00D68F);

// ════════════════════════════════════════════════════════════
// SPLASH SCREEN
// ════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> _steps = [
    "Initializing...",
    "Loading rates...",
    "Almost ready...",
    "Welcome!",
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // SINGLE CONTROLLER = SMOOTH PERFORMANCE
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _startSteps();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const AuthGate(),
          ),
        ),
      );
    });
  }

  void _startSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _currentStep = i;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // BACKGROUND
          const _Background(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // LOGO
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    return Transform.scale(
                      scale: 0.8 + (_controller.value * 0.2),
                      child: Opacity(
                        opacity: _controller.value,
                        child: child,
                      ),
                    );
                  },
                  child: const _Logo(),
                ),

                const SizedBox(height: 28),

                // TITLE
                const _Title(),

                const SizedBox(height: 10),

                // TAGLINE
                const _Tagline(),

                const SizedBox(height: 18),

                // FEATURES
                const _Features(),

                const Spacer(),

                // STEP TEXT
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _steps[_currentStep],
                    key: ValueKey(_steps[_currentStep]),
                    style: GoogleFonts.poppins(
                      color: _kSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // PROGRESS BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: _controller.value,
                      backgroundColor: _kBorder,
                      valueColor: const AlwaysStoppedAnimation(_kPurple),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // VERSION
                Text(
                  "v2.0 • Powered by CurrencyX",
                  style: GoogleFonts.poppins(
                    color: _kSecondary.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// BACKGROUND
// ════════════════════════════════════════════════════════════

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF070B14),
            Color(0xFF0E1B35),
            Color(0xFF111827),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPurple.withOpacity(0.15),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// LOGO
// ════════════════════════════════════════════════════════════

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            _kPurpleDark,
            _kPurple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.4),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Icon(
        Icons.currency_exchange,
        color: _kWhite,
        size: 44,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// TITLE
// ════════════════════════════════════════════════════════════

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Currency",
            style: GoogleFonts.poppins(
              color: _kWhite,
              fontSize: 38,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: "X",
            style: GoogleFonts.poppins(
              color: _kGold,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// TAGLINE
// ════════════════════════════════════════════════════════════

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Text(
      "Smart Currency Converter",
      style: GoogleFonts.poppins(
        color: _kSecondary,
        fontSize: 14,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// FEATURES
// ════════════════════════════════════════════════════════════

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _FeaturePill(
          icon: Icons.bolt_rounded,
          text: "Live Rates",
          color: _kGold,
        ),
        SizedBox(width: 8),
        _FeaturePill(
          icon: Icons.swap_horiz_rounded,
          text: "170+",
          color: _kPurple,
        ),
        SizedBox(width: 8),
        _FeaturePill(
          icon: Icons.trending_up_rounded,
          text: "Analytics",
          color: _kGreen,
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}