// lib/widgets/shimmer_card.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:curreny/user/screens/exchange_rate/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: AppColors.kCardBg,
        highlightColor: const Color(0xFF1A2540),
        period: const Duration(milliseconds: 1200),
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.kCardBg,
            border: Border.all(
              color: AppColors.kCardBorder,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Flag shimmer
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.kCardBorder,
                  ),
                ),
                const SizedBox(width: 16),
                // Text shimmers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: AppColors.kCardBorder,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.kCardBorder,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 24,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.kCardBorder,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side shimmer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 14,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: AppColors.kCardBorder,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 26,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.kCardBorder,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
