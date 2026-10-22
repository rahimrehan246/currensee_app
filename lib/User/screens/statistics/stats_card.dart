import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

const kCardBg = Color(0xFF0D1526);
const kBorder = Color(0xFF1E2A45);
const kSecondary = Color(0xFFA0A7B8);
const kWhite = Color(0xFFFFFFFF);
const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int animationDelay;
  final bool isHighlight;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.animationDelay = 0,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight
            ? kPurple.withOpacity(0.1)
            : kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlight
              ? kPurple.withOpacity(0.5)
              : accentColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          if (isHighlight)
            BoxShadow(
              color: kPurple.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: kSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 16,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: kSecondary.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animationDelay), duration: 500.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }
}

class StatsGrid extends StatelessWidget {
  final double currentRate;
  final double highestRate;
  final double lowestRate;
  final double averageRate;
  final double percentageChange;
  final String fromCurrency;
  final String toCurrency;

  const StatsGrid({
    super.key,
    required this.currentRate,
    required this.highestRate,
    required this.lowestRate,
    required this.averageRate,
    required this.percentageChange,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percentageChange >= 0;
    final changeColor =
        isPositive ? const Color(0xFF00C896) : const Color(0xFFFF4757);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
childAspectRatio: 1.35,      
children: [
        StatsCard(
          title: 'CURRENT RATE',
          value: currentRate.toStringAsFixed(4),
          subtitle: '$fromCurrency → $toCurrency',
          icon: Icons.show_chart_rounded,
          accentColor: kPurpleLight,
          animationDelay: 0,
          isHighlight: true,
        ),
        StatsCard(
          title: '% CHANGE',
          value:
              '${isPositive ? '+' : ''}${percentageChange.toStringAsFixed(2)}%',
          subtitle: 'Period movement',
          icon: isPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          accentColor: changeColor,
          animationDelay: 100,
        ),
        StatsCard(
          title: 'PERIOD HIGH',
          value: highestRate.toStringAsFixed(4),
          subtitle: 'Maximum rate',
          icon: Icons.arrow_circle_up_rounded,
          accentColor: const Color(0xFF00C896),
          animationDelay: 200,
        ),
        StatsCard(
          title: 'PERIOD LOW',
          value: lowestRate.toStringAsFixed(4),
          subtitle: 'Minimum rate',
          icon: Icons.arrow_circle_down_rounded,
          accentColor: const Color(0xFFFF4757),
          animationDelay: 300,
        ),
        StatsCard(
          title: 'AVERAGE RATE',
          value: averageRate.toStringAsFixed(4),
          subtitle: 'Mean over period',
          icon: Icons.analytics_rounded,
          accentColor: const Color(0xFFFFA502),
          animationDelay: 400,
        ),
        StatsCard(
          title: 'VOLATILITY',
          value:
              '${((highestRate - lowestRate) / averageRate * 100).toStringAsFixed(2)}%',
          subtitle: 'High-low spread',
          icon: Icons.waves_rounded,
          accentColor: const Color(0xFF00B4D8),
          animationDelay: 500,
        ),
      ],
    );
  }
}
