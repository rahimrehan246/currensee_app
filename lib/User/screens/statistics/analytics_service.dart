import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRate {
  final String from;
  final String to;
  final double rate;
  final DateTime timestamp;

  ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.timestamp,
  });
}

class HistoricalRate {
  final DateTime date;
  final double rate;

  HistoricalRate({required this.date, required this.rate});
}

class CurrencyStats {
  final double currentRate;
  final double highestRate;
  final double lowestRate;
  final double averageRate;
  final double percentageChange;
  final List<HistoricalRate> historicalRates;
  final String trend; // 'bullish', 'bearish', 'stable'

  CurrencyStats({
    required this.currentRate,
    required this.highestRate,
    required this.lowestRate,
    required this.averageRate,
    required this.percentageChange,
    required this.historicalRates,
    required this.trend,
  });
}

class TopMover {
  final String currency;
  final double changePercent;
  final bool isGain;

  TopMover({
    required this.currency,
    required this.changePercent,
    required this.isGain,
  });
}

class AnalyticsService {
  static const String _baseUrl = 'https://api.exchangerate.host';
  static const Duration _timeout = Duration(seconds: 15);

  // Cache
  static final Map<String, CurrencyStats> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(seconds: 30);

  static Future<Map<String, double>> fetchLatestRates(String base) async {
    try {
      final uri = Uri.parse('$_baseUrl/latest?base=$base');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['rates'] != null) {
          final rawRates = data['rates'] as Map<String, dynamic>;
          return rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
      }
    } catch (_) {}

    // Fallback mock rates
    return _getMockRates(base);
  }

  static Future<CurrencyStats> fetchStats({
    required String from,
    required String to,
    required String period, // '1D','1W','1M','6M','1Y'
  }) async {
    final cacheKey = '$from$to$period';
    final now = DateTime.now();

    if (_cache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        now.difference(_cacheTimestamps[cacheKey]!) < _cacheDuration) {
      return _cache[cacheKey]!;
    }

    final result = await _fetchStatsFromApi(from: from, to: to, period: period);
    _cache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = now;
    return result;
  }

  static Future<CurrencyStats> _fetchStatsFromApi({
    required String from,
    required String to,
    required String period,
  }) async {
    try {
      final dates = _getDateRange(period);
      final startDate = _formatDate(dates.$1);
      final endDate = _formatDate(dates.$2);

      final uri = Uri.parse(
        '$_baseUrl/timeseries?start_date=$startDate&end_date=$endDate&base=$from&symbols=$to',
      );
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['rates'] != null) {
          final ratesMap = data['rates'] as Map<String, dynamic>;
          final historicalRates = <HistoricalRate>[];

          final sortedDates = ratesMap.keys.toList()..sort();
          for (final dateStr in sortedDates) {
            final dayRates = ratesMap[dateStr] as Map<String, dynamic>;
            if (dayRates.containsKey(to)) {
              historicalRates.add(HistoricalRate(
                date: DateTime.parse(dateStr),
                rate: (dayRates[to] as num).toDouble(),
              ));
            }
          }

          if (historicalRates.isNotEmpty) {
            return _computeStats(historicalRates, from, to);
          }
        }
      }
    } catch (_) {}

    return _getMockStats(from, to, period);
  }

  static CurrencyStats _computeStats(
      List<HistoricalRate> rates, String from, String to) {
    final values = rates.map((r) => r.rate).toList();
    final current = values.last;
    final first = values.first;
    final highest = values.reduce((a, b) => a > b ? a : b);
    final lowest = values.reduce((a, b) => a < b ? a : b);
    final average = values.reduce((a, b) => a + b) / values.length;
    final pctChange = ((current - first) / first) * 100;

    String trend;
    if (pctChange > 0.5) {
      trend = 'bullish';
    } else if (pctChange < -0.5) {
      trend = 'bearish';
    } else {
      trend = 'stable';
    }

    return CurrencyStats(
      currentRate: current,
      highestRate: highest,
      lowestRate: lowest,
      averageRate: average,
      percentageChange: pctChange,
      historicalRates: rates,
      trend: trend,
    );
  }

  static Future<List<TopMover>> fetchTopMovers(String base) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();
      final uri = Uri.parse(
        '$_baseUrl/timeseries?start_date=${_formatDate(yesterday)}&end_date=${_formatDate(today)}&base=$base',
      );
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['rates'] != null) {
          final ratesMap = data['rates'] as Map<String, dynamic>;
          final sortedDates = ratesMap.keys.toList()..sort();
          if (sortedDates.length >= 2) {
            final prevRates =
                ratesMap[sortedDates.first] as Map<String, dynamic>;
            final currRates =
                ratesMap[sortedDates.last] as Map<String, dynamic>;
            final movers = <TopMover>[];

            const targetCurrencies = [
              'EUR', 'GBP', 'JPY', 'AED', 'PKR', 'CAD', 'AUD', 'CHF'
            ];
            for (final cur in targetCurrencies) {
              if (prevRates.containsKey(cur) && currRates.containsKey(cur)) {
                final prev = (prevRates[cur] as num).toDouble();
                final curr = (currRates[cur] as num).toDouble();
                final change = ((curr - prev) / prev) * 100;
                movers.add(TopMover(
                  currency: cur,
                  changePercent: change.abs(),
                  isGain: change >= 0,
                ));
              }
            }

            movers.sort((a, b) =>
                b.changePercent.compareTo(a.changePercent));
            return movers.take(6).toList();
          }
        }
      }
    } catch (_) {}

    return _getMockTopMovers();
  }

  static (DateTime, DateTime) _getDateRange(String period) {
    final now = DateTime.now();
    DateTime start;
    switch (period) {
      case '1D':
        start = now.subtract(const Duration(days: 1));
        break;
      case '1W':
        start = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        start = now.subtract(const Duration(days: 30));
        break;
      case '6M':
        start = now.subtract(const Duration(days: 180));
        break;
      case '1Y':
        start = now.subtract(const Duration(days: 365));
        break;
      default:
        start = now.subtract(const Duration(days: 30));
    }
    return (start, now);
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ── Mock fallbacks ──────────────────────────────────────────────────────────

  static Map<String, double> _getMockRates(String base) {
    const usdRates = {
      'PKR': 278.50, 'EUR': 0.92, 'GBP': 0.79, 'AED': 3.67,
      'JPY': 149.50, 'CAD': 1.36, 'AUD': 1.53, 'CHF': 0.88,
      'INR': 83.12, 'CNY': 7.24, 'SAR': 3.75, 'SGD': 1.34,
    };
    if (base == 'USD') return usdRates;

    final baseRate = usdRates[base] ?? 1.0;
    return usdRates.map(
      (k, v) => MapEntry(k, v / baseRate),
    )..['USD'] = 1.0 / baseRate;
  }

  static CurrencyStats _getMockStats(String from, String to, String period) {
    final count = _pointCount(period);
    final baseRate = _getBaseRate(from, to);
    final rand = DateTime.now().millisecondsSinceEpoch;
    final rates = List.generate(count, (i) {
      final noise = ((rand + i * 17) % 200 - 100) / 1000;
      final trend = i / count * 0.02;
      return HistoricalRate(
        date: DateTime.now().subtract(Duration(
            days: (_daysForPeriod(period) * (count - i) / count).round())),
        rate: baseRate * (1 + noise + trend),
      );
    });
    return _computeStats(rates, from, to);
  }

  static int _pointCount(String period) {
    switch (period) {
      case '1D': return 24;
      case '1W': return 7;
      case '1M': return 30;
      case '6M': return 26;
      case '1Y': return 52;
      default: return 30;
    }
  }

  static int _daysForPeriod(String period) {
    switch (period) {
      case '1D': return 1;
      case '1W': return 7;
      case '1M': return 30;
      case '6M': return 180;
      case '1Y': return 365;
      default: return 30;
    }
  }

  static double _getBaseRate(String from, String to) {
    const rates = {
      'USD_PKR': 278.50, 'USD_EUR': 0.92, 'USD_GBP': 0.79,
      'USD_AED': 3.67, 'EUR_USD': 1.087, 'GBP_USD': 1.265,
      'EUR_GBP': 0.859, 'AED_PKR': 75.88,
    };
    return rates['${from}_$to'] ?? rates['${to}_$from']?.let((r) => 1 / r) ?? 1.0;
  }

  static List<TopMover> _getMockTopMovers() => [
    TopMover(currency: 'EUR', changePercent: 1.24, isGain: true),
    TopMover(currency: 'GBP', changePercent: 0.87, isGain: true),
    TopMover(currency: 'PKR', changePercent: 2.10, isGain: false),
    TopMover(currency: 'JPY', changePercent: 0.65, isGain: false),
    TopMover(currency: 'AED', changePercent: 0.32, isGain: true),
    TopMover(currency: 'CAD', changePercent: 0.18, isGain: true),
  ];
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
