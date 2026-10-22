// lib/widgets/currency_card.dart

import 'package:curreny/User/screens/converter/converter_screen.dart';
import 'package:curreny/User/screens/exchange_rate/currency_model.dart';
import 'package:curreny/user/screens/exchange_rate/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyCard extends StatefulWidget {
  final CurrencyRate currency;
  final int index;

  const CurrencyCard({
    super.key,
    required this.currency,
    required this.index,
  });

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.currency;
    final isPositive = c.isPositive;
    final changeColor = isPositive ? AppColors.kPositive : AppColors.kNegative;
    final changeBg = isPositive ? AppColors.kPositiveBg : AppColors.kNegativeBg;
    final changeSign = isPositive ? '+' : '';

    return Animate(
      effects: [
        FadeEffect(
          duration: 500.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOut,
        ),
        SlideEffect(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
          duration: 500.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOut,
        ),
      ],
     

  

child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConverterScreen(
          fromCurrency: "EURO",
          toCurrency: c.code,
        ),
      ),
    );
  },

  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),


  child: AnimatedScale(     scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1A30), Color(0xFF0D1526)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.kCardBorder.withOpacity(0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kPurple.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Flag Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.kBg,
                      border: Border.all(
                        color: AppColors.kCardBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kPurple.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        c.flagEmoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Currency Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Currency Code + Country
                        Row(
                          children: [
                            Text(
                              c.code,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.kWhite,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Glowing dot indicator
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: changeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: changeColor.withOpacity(0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.countryName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.kTextSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Exchange Rate Text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.kPurpleSoft,
                            border: Border.all(
                              color: AppColors.kPurple.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            c.exchangeText,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.kPurple,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Change Percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rate value
                      Text(
                        c.rate.toStringAsFixed(4),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kWhite,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Change badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: changeBg,
                          border: Border.all(
                            color: changeColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: changeColor,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$changeSign${c.changePercent.abs().toStringAsFixed(2)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: changeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
