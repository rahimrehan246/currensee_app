import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'analytics_service.dart';
import 'chart_widget.dart';
import 'stats_card.dart';
import 'currency_dropdown.dart';
import 'loading_shimmer.dart';
import 'trend_indicator.dart';

// ── Color palette ───────────────────────────────────────────────────────────

const kBg = Color(0xFF070B14);
const kNavy = Color(0xFF0E1B35);
const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kPurpleDark = Color(0xFF3A1ACC);
const kWhite = Color(0xFFFFFFFF);
const kSecondary = Color(0xFFA0A7B8);
const kBorder = Color(0xFF1E2A45);
const kCardBg = Color(0xFF0D1526);
const kInputBg = Color(0xFF0A1020);

// ── Entry point ─────────────────────────────────────────────────────────────

void main() {
  runApp(const CurrencyAnalyticsApp());
}

class CurrencyAnalyticsApp extends StatelessWidget {
  const CurrencyAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kPurple),
      ),
      home: const StatisticsScreen(),
    );
  }
}

// ── Statistics Screen ────────────────────────────────────────────────────────

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String _fromCurrency = 'USD';
  String _toCurrency = 'PKR';
  String _selectedPeriod = '1M';
  String _searchQuery = '';

  CurrencyStats? _stats;
  List<TopMover> _topMovers = [];
  bool _isLoading = true;
  bool _isMoversLoading = true;
  String? _errorMessage;

  final Set<String> _favorites = {'USD', 'EUR', 'GBP'};
  final _searchController = TextEditingController();
  Timer? _refreshTimer;
  late AnimationController _blobController;
  DateTime _lastUpdated = DateTime.now();

  // ── Init / Dispose ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _fetchData();
    _fetchMovers();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  // ── Data Fetching ──────────────────────────────────────────────────────────

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData(silent: true);
      _fetchMovers(silent: true);
    });
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final stats = await AnalyticsService.fetchStats(
        from: _fromCurrency,
        to: _toCurrency,
        period: _selectedPeriod,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data. Please retry.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMovers({bool silent = false}) async {
    if (!silent) setState(() => _isMoversLoading = true);
    try {
      final movers = await AnalyticsService.fetchTopMovers(_fromCurrency);
      if (mounted) setState(() { _topMovers = movers; _isMoversLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isMoversLoading = false);
    }
  }

  void _onCurrencyChanged() {
    _fetchData();
    _fetchMovers();
  }

  void _onPeriodChanged(String p) {
    setState(() => _selectedPeriod = p);
    _fetchData();
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  List<String> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return allCurrencies
        .where((c) =>
            c.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .map((c) => c.code)
        .toList();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Animated blobs background
          _AnimatedBlobs(controller: _blobController),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Header ──────────────────────────────────────────
                        _Header(
                          lastUpdated: _lastUpdated,
                          onRefresh: () {
                            _fetchData();
                            _fetchMovers();
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Search ──────────────────────────────────────────
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),

                        const SizedBox(height: 16),
                        if (_searchQuery.isNotEmpty && _searchResults.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length.clamp(0, 5),
      separatorBuilder: (_, __) => Divider(
        color: kBorder.withOpacity(0.4),
        height: 1,
      ),
      itemBuilder: (_, i) {
        final code = _searchResults[i];

        final currency = allCurrencies.firstWhere(
          (c) => c.code == code,
        );

        return ListTile(
          leading: Text(
            currency.flag,
            style: const TextStyle(fontSize: 20),
          ),
          title: Text(
            currency.code,
            style: GoogleFonts.poppins(
              color: kWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            currency.name,
            style: GoogleFonts.poppins(
              color: kSecondary,
              fontSize: 12,
            ),
          ),
          onTap: () {
            setState(() {
              _fromCurrency = currency.code;
              _searchQuery = '';
              _searchController.clear();
            });

            _onCurrencyChanged();
          },
        );
      },
    ),
  ),

                        // ── Currency Selector ───────────────────────────────
                        CurrencySelector(
                          fromCurrency: _fromCurrency,
                          toCurrency: _toCurrency,
                          searchResults: _searchResults,
                          onFromChanged: (v) {
                            setState(() => _fromCurrency = v);
                            _onCurrencyChanged();
                          },
                          onToChanged: (v) {
                            setState(() => _toCurrency = v);
                            _onCurrencyChanged();
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── Chart section ───────────────────────────────────
                        _SectionTitle(
                          title: 'Price Chart',
                          subtitle: '$_fromCurrency / $_toCurrency',
                        ),

                        const SizedBox(height: 12),

                        if (_isLoading)
                          const ChartShimmer()
                        else if (_errorMessage != null)
                          _ErrorCard(
                            message: _errorMessage!,
                            onRetry: _fetchData,
                          )
                        else if (_stats != null)
                          ChartWidget(
                            rates: _stats!.historicalRates,
                            selectedPeriod: _selectedPeriod,
                            onPeriodChanged: _onPeriodChanged,
                            isPositive: _stats!.percentageChange >= 0,
                          ),

                        const SizedBox(height: 24),

                        // ── Trend ───────────────────────────────────────────
                        _SectionTitle(
                          title: 'Market Trend',
                          subtitle: 'Based on rate movement',
                        ),

                        const SizedBox(height: 12),

                        if (_isLoading)
                          const ShimmerBox(
                              width: double.infinity, height: 90, radius: 20)
                        else if (_stats != null)
                          TrendIndicator(
                            trend: _stats!.trend,
                            percentageChange: _stats!.percentageChange,
                          ),

                        const SizedBox(height: 24),

                        // ── Stats grid ──────────────────────────────────────
                        _SectionTitle(
                          title: 'Market Stats',
                          subtitle: 'Period analytics',
                        ),

                        const SizedBox(height: 12),

                        if (_isLoading)
                          const StatsShimmer()
                        else if (_stats != null)
                          StatsGrid(
                            currentRate: _stats!.currentRate,
                            highestRate: _stats!.highestRate,
                            lowestRate: _stats!.lowestRate,
                            averageRate: _stats!.averageRate,
                            percentageChange: _stats!.percentageChange,
                            fromCurrency: _fromCurrency,
                            toCurrency: _toCurrency,
                          ),

                        const SizedBox(height: 24),

                        // ── Favorites ───────────────────────────────────────
                        _SectionTitle(
                          title: 'Favorites',
                          subtitle: 'Tap ★ to manage',
                        ),

                        const SizedBox(height: 12),

                        _FavoritesBar(
                          favorites: _favorites,
                          fromCurrency: _fromCurrency,
                          onToggle: (code) =>
                              setState(() => _favorites.contains(code)
                                  ? _favorites.remove(code)
                                  : _favorites.add(code)),
                          onSelect: (code) {
                            setState(() => _fromCurrency = code);
                            _onCurrencyChanged();
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── Top Movers ──────────────────────────────────────
                        _SectionTitle(
                          title: 'Top Movers',
                          subtitle: '24h change',
                        ),

                        const SizedBox(height: 12),

                        if (_isMoversLoading)
                          const TopMoversShimmer()
                        else
                          _TopMoversList(movers: _topMovers),

                        const SizedBox(height: 32),
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

// ── Subwidgets ───────────────────────────────────────────────────────────────

class _AnimatedBlobs extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBlobs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Stack(
          children: [
            Positioned(
              top: -80 + math.sin(t * math.pi) * 40,
              right: -80 + math.cos(t * math.pi * 0.7) * 30,
              child: _Blob(
                size: 260,
                color: kPurple.withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 200 + math.cos(t * math.pi) * 50,
              left: -60 + math.sin(t * math.pi * 0.5) * 20,
              child: _Blob(
                size: 200,
                color: kPurpleDark.withOpacity(0.14),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 20)],
      ),
    );
  }
}
class _Header extends StatelessWidget {
  final DateTime lastUpdated;
  final VoidCallback onRefresh;

  const _Header({
    super.key,
    required this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [

        // ── BACK BUTTON (SIMPLE) ──
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),

        const SizedBox(width: 14),

        // ── TITLE ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Analytics',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated $time',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        
      ],
    );
  }
}
  class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search currencies — USD, PKR, EUR...',
          hintStyle: GoogleFonts.poppins(color: kSecondary, fontSize: 13),
          prefixIcon:
              const Icon(Icons.search_rounded, color: kSecondary, size: 20),
suffixIcon: controller.value.text.isNotEmpty              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: kSecondary, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPurple, kPurpleLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: kWhite,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: kSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFFFF4757), size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.poppins(color: kSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPurple, kPurpleLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: kWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesBar extends StatelessWidget {
  final Set<String> favorites;
  final String fromCurrency;
  final Function(String) onToggle;
  final Function(String) onSelect;

  const _FavoritesBar({
    required this.favorites,
    required this.fromCurrency,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final allCodes = allCurrencies.map((c) => c.code).toList();
    final displayed = {
      ...favorites,
      ...allCodes.take(5),
    }.toList();

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayed.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final code = displayed[i];
          final isFav = favorites.contains(code);
          final isActive = code == fromCurrency;
          return GestureDetector(
            onTap: () => onSelect(code),
            onLongPress: () => onToggle(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [kPurple, kPurpleLight])
                    : null,
                color: isActive ? null : kCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? kPurple : (isFav ? kPurpleLight.withOpacity(0.4) : kBorder),
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: kPurple.withOpacity(0.3), blurRadius: 12)]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    allCurrencies
                        .firstWhere((c) => c.code == code,
                            orElse: () => const CurrencyInfo(
                                code: '', name: '', flag: '💱'))
                        .flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    code,
                    style: GoogleFonts.poppins(
                      color: isActive ? kWhite : kSecondary,
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isFav) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      color: isActive ? kWhite.withOpacity(0.7) : kPurpleLight,
                      size: 12,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }
}

class _TopMoversList extends StatelessWidget {
  final List<TopMover> movers;

  const _TopMoversList({required this.movers});

  @override
  Widget build(BuildContext context) {
    if (movers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Center(
          child: Text(
            'No movers data available',
            style: GoogleFonts.poppins(color: kSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: movers.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        final color = m.isGain
            ? const Color(0xFF00C896)
            : const Color(0xFFFF4757);
        final info = allCurrencies.firstWhere(
          (c) => c.code == m.currency,
          orElse: () =>
              CurrencyInfo(code: m.currency, name: m.currency, flag: '💱'),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      info.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.currency,
                        style: GoogleFonts.poppins(
                          color: kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        info.name,
                        style: GoogleFonts.poppins(
                          color: kSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m.isGain
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${m.changePercent.toStringAsFixed(2)}%',
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: 100 + i * 80),
                  duration: 400.ms)
              .slideX(
                  begin: 0.05,
                  end: 0,
                  delay: Duration(milliseconds: 100 + i * 80)),
        );
      }).toList(),
    );
  }
}
