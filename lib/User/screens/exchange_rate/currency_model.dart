// lib/models/currency_model.dart

class CurrencyRate {
  final String code;
  final String name;
  final String countryName;
  final String flagEmoji;
  final double rate;
  final double changePercent;
  final double baseAmount;
  final String baseCode;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.countryName,
    required this.flagEmoji,
    required this.rate,
    required this.changePercent,
    required this.baseAmount,
    required this.baseCode,
  });

  bool get isPositive => changePercent >= 0;

  String get exchangeText =>
      '1 ${baseCode.toUpperCase()} = ${rate.toStringAsFixed(4)} ${code.toUpperCase()}';

  CurrencyRate copyWith({
    String? code,
    String? name,
    String? countryName,
    String? flagEmoji,
    double? rate,
    double? changePercent,
    double? baseAmount,
    String? baseCode,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      countryName: countryName ?? this.countryName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      rate: rate ?? this.rate,
      changePercent: changePercent ?? this.changePercent,
      baseAmount: baseAmount ?? this.baseAmount,
      baseCode: baseCode ?? this.baseCode,
    );
  }
}

class ExchangeRateResponse {
  final bool success;
  final String base;
  final DateTime date;
  final Map<String, double> rates;

  ExchangeRateResponse({
    required this.success,
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    final ratesMap = <String, double>{};
    if (json['rates'] != null) {
      (json['rates'] as Map<String, dynamic>).forEach((key, value) {
        ratesMap[key] = (value as num).toDouble();
      });
    }

    return ExchangeRateResponse(
      success: json['success'] ?? true,
      base: json['base'] ?? 'EUR',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      rates: ratesMap,
    );
  }
}
