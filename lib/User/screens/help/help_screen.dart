// lib/User/screens/help/help_page.dart

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

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static final List<_HelpSection> _sections = [
    _HelpSection(
      icon: Icons.currency_exchange_rounded,
      title: 'Currency Converter',
      description:
          'Convert any amount between currencies instantly. Pick a base and target currency, enter an amount, and get a live-style converted value with a clean breakdown.',
    ),
    _HelpSection(
      icon: Icons.show_chart_rounded,
      title: 'Exchange Rate',
      description:
          'Track real-time exchange rates for major world currencies. Rates auto-refresh, and you can see whether a currency is trending up or down at a glance.',
    ),
    _HelpSection(
      icon: Icons.bar_chart_rounded,
      title: 'Statistics & Charts',
      description:
          'Dive into performance analytics with interactive charts. Compare currency movement over time and spot trends with our visual statistics dashboard.',
    ),
    _HelpSection(
      icon: Icons.person_rounded,
      title: 'Profile System',
      description:
          'Manage your personal profile, preferences, and saved currencies. Your profile keeps your favorite pairs and settings ready whenever you open the app.',
    ),
    _HelpSection(
      icon: Icons.support_agent_rounded,
      title: 'Contact Support',
      description:
          'Stuck on something? Reach out to our support team directly from the app and we will get back to you as soon as possible.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // ================= BACKGROUND GLOWS =================
          Positioned(
            top: -90,
            right: -70,
            child: _GlowCircle(color: kPurple.withOpacity(0.14), size: 260),
          ),
          Positioned(
            bottom: 60,
            left: -90,
            child: _GlowCircle(color: kPurpleDark.withOpacity(0.10), size: 220),
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
                              'Help & Support',
                              style: GoogleFonts.poppins(
                                color: kWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Everything you need to use the app smoothly',
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

                  // ================= HELP SECTIONS =================
                  ...List.generate(_sections.length, (index) {
                    final section = _sections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GlassCard(
                        icon: section.icon,
                        title: section.title,
                        description: section.description,
                      )
                          .animate()
                          .fadeIn(
                            duration: 450.ms,
                            delay: (120 * index).ms,
                          )
                          .slideY(
                            begin: 0.12,
                            end: 0,
                            duration: 450.ms,
                            delay: (120 * index).ms,
                            curve: Curves.easeOutCubic,
                          ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ================= CONTACT FOOTER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [kPurple, kPurpleDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPurple.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.headset_mic_rounded, color: kWhite, size: 30),
                        const SizedBox(height: 12),
                        Text(
                          'Still need help?',
                          style: GoogleFonts.poppins(
                            color: kWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Our support team is just a tap away.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: kWhite.withOpacity(0.75),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: (120 * _sections.length).ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        delay: (120 * _sections.length).ms,
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

class _HelpSection {
  final IconData icon;
  final String title;
  final String description;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GlassCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [kPurple.withOpacity(0.25), kPurpleDark.withOpacity(0.25)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: kPurpleLight.withOpacity(0.3)),
            ),
            child: Icon(icon, color: kPurpleLight, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: kWhite,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: kSecondary,
                    fontSize: 12.5,
                    height: 1.5,
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