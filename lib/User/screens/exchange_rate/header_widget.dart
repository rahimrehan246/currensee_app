// lib/widgets/header_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curreny/user/screens/exchange_rate/app_theme.dart';

class HeaderWidget extends StatelessWidget {
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  const HeaderWidget({
    super.key,
    this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // ================= LEFT SIDE =================
          Row(
            children: [

              // ================= DRAWER BUTTON =================
             Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: Builder(
    builder: (context) => GestureDetector(
      onTap: () {
        Scaffold.of(context).openDrawer();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.kCardBg,
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: const Icon(
          Icons.menu_rounded,
          color: AppColors.kWhite,
          size: 22,
        ),
      ),
    ),
  ),
),
              const SizedBox(width: 16),

              // ================= TITLE =================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    'Exchange Rate',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kWhite,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(
                        begin: -0.2,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 4),

                  Row(
                    children: [

                      _LiveIndicator(),

                      const SizedBox(width: 8),

                      Text(
                        lastUpdated != null
                            ? 'Updated ${_formatTime(lastUpdated!)}'
                            : 'Live rates',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 100.ms,
                      ),
                ],
              ),
            ],
          ),

          // ================= REFRESH BUTTON =================
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.kPurple,
                    AppColors.kPurpleDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kPurple.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.kWhite,
                size: 22,
              ),
            ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _LiveIndicator extends StatefulWidget {
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.kPositive,
          boxShadow: [
            BoxShadow(
              color: AppColors.kPositive.withOpacity(
                0.3 + _controller.value * 0.5,
              ),
              blurRadius: 6 + _controller.value * 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}