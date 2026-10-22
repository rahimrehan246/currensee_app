// lib/screens/exchange_rate_screen.dart

import 'dart:async';
import 'package:curreny/User/screens/exchange_rate/currency_model.dart';
import 'package:curreny/user/screens/home/drawer.dart';
import 'package:curreny/user/screens/exchange_rate/app_theme.dart';
import 'package:curreny/user/screens/exchange_rate/currency_card.dart';
import 'package:curreny/user/screens/exchange_rate/exchange_rate_service.dart';
import 'package:curreny/user/screens/exchange_rate/header_widget.dart';
import 'package:curreny/user/screens/exchange_rate/shimmer_card.dart';
import 'package:curreny/user/screens/exchange_rate/stats_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

enum LoadState { loading, loaded, error }

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final ExchangeRateService _service = ExchangeRateService();
  List<CurrencyRate> _rates = [];
  LoadState _loadState = LoadState.loading;
  DateTime? _lastUpdated;
  Timer? _autoRefreshTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchRates(silent: true),
    );
  }

  Future<void> _fetchRates({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loadState = LoadState.loading;
        _errorMessage = null;
      });
    }

    try {
      final rates = await _service.fetchRates();
      if (mounted) {
        setState(() {
          _rates = rates;
          _loadState = LoadState.loaded;
          _lastUpdated = DateTime.now();
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadState = LoadState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.kBg,

    body: Stack(
      children: [

        // ================= BACKGROUND EFFECTS =================
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.kPurple.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.kPurpleDark.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ================= MAIN CONTENT =================
        SafeArea(
          child: Column(
            children: [

              // ================= TOP BAR =================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  10,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ================= BACK BUTTON =================
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 2),

                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ================= TITLE =================
                    Column(
                      mainAxisSize: MainAxisSize.min,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          "Exchange Rates",

                          style: GoogleFonts.poppins(
                            color: AppColors.kWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "Live Currency Market",

                          style: GoogleFonts.poppins(
                            color:
                                AppColors.kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= BODY =================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _fetchRates(),

                  color: AppColors.kPurple,

                  backgroundColor:
                      AppColors.kCardBg,

                  displacement: 40,

                  child: CustomScrollView(
                    physics:
                        const BouncingScrollPhysics(
                      parent:
                          AlwaysScrollableScrollPhysics(),
                    ),

                    slivers: [

                      // ================= BASE CURRENCY =================
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            24,
                            8,
                            24,
                            16,
                          ),

                          child: _BaseCurrencyBar(),
                        ),
                      ),

                      // ================= STATS =================
                      if (_loadState ==
                              LoadState.loaded &&
                          _rates.isNotEmpty)

                        SliverToBoxAdapter(
                          child: StatsBar(
                            rates: _rates,
                          ),
                        ),

                      // ================= LOADING =================
                      if (_loadState ==
                          LoadState.loading)

                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(
                            (_, __) =>
                                const ShimmerCard(),

                            childCount: 5,
                          ),
                        ),

                      // ================= DATA =================
                      if (_loadState ==
                          LoadState.loaded)

                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(

                            (_, index) => CurrencyCard(
                              currency: _rates[index],
                              index: index,
                            ),

                            childCount: _rates.length,
                          ),
                        ),

                      // ================= ERROR =================
                      if (_loadState ==
                          LoadState.error)

                        SliverToBoxAdapter(
                          child: _ErrorWidget(
                            onRetry: _fetchRates,
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 120),
                      ),
                    ],
                  ),
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

class _BaseCurrencyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.kPurple, AppColors.kPurpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPurple.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Text('🇪🇺', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EUR — Euro',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kWhite,
                    ),
                  ),
                  Text(
                    'Base Currency',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.kWhite.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  'EUR = 1.00',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kWhite,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 150.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: 150.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kNegative.withOpacity(0.1),
              border: Border.all(
                color: AppColors.kNegative.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: AppColors.kNegative,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connection Failed',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.kWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to fetch live rates.\nShowing cached data.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppColors.kPurple, AppColors.kPurpleDark],
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
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
