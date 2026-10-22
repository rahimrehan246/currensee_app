// ===============================
// 📁 lib/widgets/bottom_nav_bar.dart
// ===============================

import 'package:curreny/user/screens/exchange_rate/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        color: AppColors.kNavBg,

        border: Border.all(
          color: AppColors.kCardBorder,
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.kPurple.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),

          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // CONVERTER
            _NavItem(
              icon: Icons.currency_exchange_rounded,
              label: 'Converter',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),

            // EXCHANGE
            _NavItem(
              icon: Icons.trending_up_rounded,
              label: 'Exchange',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),

            // STATISTICS
            _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Statistics',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),

            // PROFILE
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          color: isActive
              ? AppColors.kPurple.withOpacity(0.10)
              : Colors.transparent,

          border: isActive
              ? Border.all(
                  color: AppColors.kPurple.withOpacity(0.30),
                  width: 1,
                )
              : null,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // PREMIUM ICON
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppColors.kPurple,
                          AppColors.kPurpleDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,

                color: isActive
                    ? null
                    : AppColors.kCardBorder.withOpacity(0.22),

                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.kPurple.withOpacity(0.40),
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.22),
                          blurRadius: 6,
                        ),
                      ],
              ),

              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? Colors.white
                    : AppColors.kTextSecondary,
              ),
            ),

            const SizedBox(height: 4),

            // LABEL
            Text(
              label,

              style: GoogleFonts.poppins(
                fontSize: 9.5,
                letterSpacing: 0.2,

                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w500,

                color: isActive
                    ? Colors.white
                    : AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}