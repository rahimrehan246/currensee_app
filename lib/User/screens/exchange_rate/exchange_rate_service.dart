// lib/services/exchange_rate_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:curreny/User/screens/exchange_rate/currency_model.dart';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate.host/latest';
  static const String _baseCurrency = 'EUR';
  static const Duration _timeout = Duration(seconds: 15);

  // Currency metadata
  static const Map<String, Map<String, String>> _currencyMeta = {
    'USD': {
      'name': 'US Dollar',
      'countryName': 'United States',
      'flag': '🇺🇸',
    },
    'AUD': {
      'name': 'Australian Dollar',
      'countryName': 'Australia',
      'flag': '🇦🇺',
    },
    'NZD': {
      'name': 'New Zealand Dollar',
      'countryName': 'New Zealand',
      'flag': '🇳🇿',
    },
    'CAD': {
      'name': 'Canadian Dollar',
      'countryName': 'Canada',
      'flag': '🇨🇦',
    },
    'BDT': {
      'name': 'Bangladeshi Taka',
      'countryName': 'Bangladesh',
      'flag': '🇧🇩',
    },
  };

  static const List<String> _targetCurrencies = [
    'USD',
    'AUD',
    'NZD',
    'CAD',
    'BDT',
  ];

  // Simulated previous rates for change % calculation
  static final Map<String, double> _previousRates = {};
  static final Random _random = Random();

  Future<List<CurrencyRate>> fetchRates() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?base=$_baseCurrency&symbols=${_targetCurrencies.join(',')}',
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final exchangeResponse = ExchangeRateResponse.fromJson(json);
        return _buildCurrencyRates(exchangeResponse.rates);
      } else {
        // Fallback to mock data if API fails
        return _getMockRates();
      }
    } catch (e) {
      // Return mock data on any error
      return _getMockRates();
    }
  }

  List<CurrencyRate> _buildCurrencyRates(Map<String, double> rates) {
    final List<CurrencyRate> result = [];

    for (final code in _targetCurrencies) {
      final meta = _currencyMeta[code];
      if (meta == null) continue;

      final rate = rates[code] ?? _getFallbackRate(code);
      final prevRate = _previousRates[code];
      double changePercent;

      if (prevRate != null && prevRate != 0) {
        changePercent = ((rate - prevRate) / prevRate) * 100;
        // Clamp to realistic range
        changePercent = changePercent.clamp(-5.0, 5.0);
      } else {
        // Generate realistic simulated change
        changePercent = _simulateChange(code);
      }

      _previousRates[code] = rate;

      result.add(
        CurrencyRate(
          code: code,
          name: meta['name']!,
          countryName: meta['countryName']!,
          flagEmoji: meta['flag']!,
          rate: rate,
          changePercent: changePercent,
          baseAmount: 1.0,
          baseCode: _baseCurrency,
        ),
      );
    }

    return result;
  }

  double _simulateChange(String code) {
    // Realistic simulated % changes per currency
    const Map<String, double> baseChanges = {
      'USD': 0.42,
      'AUD': -0.31,
      'NZD': 0.18,
      'CAD': -0.25,
      'BDT': 0.67,
    };
    final base = baseChanges[code] ?? 0.0;
    final noise = (_random.nextDouble() - 0.5) * 0.2;
    return base + noise;
  }

  double _getFallbackRate(String code) {
    const Map<String, double> fallback = {
      'USD': 1.0821,
      'AUD': 1.6543,
      'NZD': 1.7832,
      'CAD': 1.4621,
      'BDT': 119.45,
    };
    return fallback[code] ?? 1.0;
  }

  List<CurrencyRate> _getMockRates() {
    return _buildCurrencyRates({
      'USD': 1.0821,
      'AUD': 1.6543,
      'NZD': 1.7832,
      'CAD': 1.4621,
      'BDT': 119.45,
    });
  }
}
