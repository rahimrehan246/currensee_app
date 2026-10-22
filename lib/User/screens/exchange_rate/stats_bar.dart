// lib/widgets/stats_bar.dart

import 'package:curreny/User/screens/exchange_rate/currency_model.dart';
import 'package:curreny/user/screens/exchange_rate/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsBar extends StatelessWidget {
  final List<CurrencyRate> rates;

  const StatsBar({super.key, required this.rates});

  @override
  Widget build(BuildContext context) {
    final positiveCount = rates.where((r) => r.isPositive).length;
    final negativeCount = rates.length - positiveCount;
    final bestRate = rates.isEmpty
        ? null
        : rates.reduce((a, b) => a.changePercent > b.changePercent ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F1830), Color(0xFF0A1020)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.kCardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPurple.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(
              label: 'Gaining',
              value: '$positiveCount',
              color: AppColors.kPositive,
              icon: Icons.trending_up_rounded,
            ),
            _Divider(),
            _StatItem(
              label: 'Losing',
              value: '$negativeCount',
              color: AppColors.kNegative,
              icon: Icons.trending_down_rounded,
            ),
            _Divider(),
            _StatItem(
              label: 'Best',
              value: bestRate?.code ?? '--',
              color: AppColors.kGold,
              icon: Icons.star_rounded,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
          begin: -0.2,
          end: 0,
          duration: 400.ms,
          delay: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.kCardBorder,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
   return Expanded(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.12),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 15,
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.kWhite,
              ),
            ),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);  }
}
