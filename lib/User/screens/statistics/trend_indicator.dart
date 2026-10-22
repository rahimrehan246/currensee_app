import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kCardBg = Color(0xFF0D1526);
const kBorder = Color(0xFF1E2A45);
const kSecondary = Color(0xFFA0A7B8);
const kWhite = Color(0xFFFFFFFF);

class TrendIndicator extends StatelessWidget {
  final String trend;
  final double percentageChange;

  const TrendIndicator({
    super.key,
    required this.trend,
    required this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTrendConfig(trend);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  config.color.withOpacity(0.3),
                  config.color.withOpacity(0.05),
                ],
              ),
              border: Border.all(color: config.color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                config.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: 1800.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                curve: Curves.easeInOut,
              ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Trend',
                  style: GoogleFonts.poppins(
                    color: kSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.label,
                  style: GoogleFonts.poppins(
                    color: config.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.description,
                  style: GoogleFonts.poppins(
                    color: kSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: config.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  percentageChange >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: config.color,
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  '${percentageChange.abs().toStringAsFixed(2)}%',
                  style: GoogleFonts.poppins(
                    color: config.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0);
  }

  _TrendConfig _getTrendConfig(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
        return _TrendConfig(
          color: const Color(0xFF00C896),
          emoji: '📈',
          label: 'Bullish',
          description: 'Strong upward momentum detected',
        );
      case 'bearish':
        return _TrendConfig(
          color: const Color(0xFFFF4757),
          emoji: '📉',
          label: 'Bearish',
          description: 'Downward pressure observed',
        );
      default:
        return _TrendConfig(
          color: const Color(0xFFFFA502),
          emoji: '➖',
          label: 'Stable',
          description: 'Consolidating in a narrow range',
        );
    }
  }
}

class _TrendConfig {
  final Color color;
  final String emoji;
  final String label;
  final String description;

  _TrendConfig({
    required this.color,
    required this.emoji,
    required this.label,
    required this.description,
  });
}
