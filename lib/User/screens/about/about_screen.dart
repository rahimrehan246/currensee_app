// lib/User/screens/about/about_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

const kBg = Color(0xFF070B14);
const kNavy = Color(0xFF0E1B35);
const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kPurpleDark = Color(0xFF3A1ACC);
const kWhite = Color(0xFFFFFFFF);
const kSecondary = Color(0xFFA0A7B8);
const kBorder = Color(0xFF1E2A45);
const kCardBg = Color(0xFF0D1526);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<_Feature> _features = [
    _Feature(icon: Icons.currency_exchange_rounded, label: 'Real-time Currency Converter'),
    _Feature(icon: Icons.show_chart_rounded, label: 'Live Exchange Rate Tracking'),
    _Feature(icon: Icons.bar_chart_rounded, label: 'Statistics & Performance Charts'),
    _Feature(icon: Icons.bolt_rounded, label: 'Fast, Smooth, Premium Experience'),
    _Feature(icon: Icons.person_rounded, label: 'Personalized User Profile'),
    _Feature(icon: Icons.feedback_rounded, label: 'Built-in Feedback System'),
  ];

  static const List<_Tech> _tech = [
    _Tech(icon: Icons.flutter_dash_rounded, label: 'Flutter & Dart'),
    _Tech(icon: Icons.cloud_rounded, label: 'Firebase Backend'),
    _Tech(icon: Icons.api_rounded, label: 'Live Currency APIs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // ================= BACKGROUND GLOWS =================
          Positioned(
            top: -80,
            left: -70,
            child: _GlowCircle(color: kPurple.withOpacity(0.14), size: 250),
          ),
          Positioned(
            bottom: 40,
            right: -90,
            child: _GlowCircle(color: kPurpleDark.withOpacity(0.10), size: 230),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= CUSTOM HEADER =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: kCardBg,
                            border: Border.all(color: kBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: kWhite,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About App',
                              style: GoogleFonts.poppins(
                                color: kWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Premium Currency Converter & Analytics Tool',
                              style: GoogleFonts.poppins(
                                color: kSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 450.ms).slideY(
                        begin: -0.2,
                        end: 0,
                        duration: 450.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 28),

                  // ================= OUR MISSION =================
                  _SectionCard(
                    icon: Icons.flag_rounded,
                    title: 'Our Mission',
                    child: Text(
                      'We believe managing money across currencies should feel effortless. '
                      'Our mission is to give you fast, reliable, and beautifully presented '
                      'currency data so you can make smarter financial decisions, anywhere in the world.',
                      style: GoogleFonts.poppins(
                        color: kSecondary,
                        fontSize: 12.5,
                        height: 1.6,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 100.ms)
                      .slideY(begin: 0.12, end: 0, duration: 450.ms, delay: 100.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 16),

                  // ================= WHAT THE APP OFFERS =================
                  _SectionCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'What the App Offers',
                    child: Column(
                      children: List.generate(_features.length, (index) {
                        final feature = _features[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: kPurple.withOpacity(0.15),
                                ),
                                child: Icon(feature.icon, color: kPurpleLight, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature.label,
                                  style: GoogleFonts.poppins(
                                    color: kWhite.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms, delay: (80 * index).ms)
                            .slideX(begin: 0.08, end: 0, duration: 350.ms, delay: (80 * index).ms);
                      }),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 180.ms)
                      .slideY(begin: 0.12, end: 0, duration: 450.ms, delay: 180.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 16),

                  // ================= TECHNOLOGY USED =================
                  _SectionCard(
                    icon: Icons.memory_rounded,
                    title: 'Technology Used',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_tech.length, (index) {
                        final tech = _tech[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: kNavy.withOpacity(0.6),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tech.icon, color: kPurpleLight, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                tech.label,
                                style: GoogleFonts.poppins(
                                  color: kWhite.withOpacity(0.9),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms, delay: (90 * index).ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 350.ms,
                              delay: (90 * index).ms,
                              curve: Curves.easeOut,
                            );
                      }),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 260.ms)
                      .slideY(begin: 0.12, end: 0, duration: 450.ms, delay: 260.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 28),

                  // ================= FOOTER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [kPurple, kPurpleDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPurple.withOpacity(0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: kWhite, size: 26),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Built for Smarter Money Decisions',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: kWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thank you for trusting us with your finances.\nWe are constantly improving, just for you.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: kWhite.withOpacity(0.75),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 340.ms)
                      .scale(
                        begin: const Offset(0.93, 0.93),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        delay: 340.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});
}

class _Tech {
  final IconData icon;
  final String label;

  const _Tech({required this.icon, required this.label});
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kCardBg.withOpacity(0.7),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [kPurple.withOpacity(0.25), kPurpleDark.withOpacity(0.25)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: kPurpleLight.withOpacity(0.3)),
                ),
                child: Icon(icon, color: kPurpleLight, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}