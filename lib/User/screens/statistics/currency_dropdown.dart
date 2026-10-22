import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

const kNavy = Color(0xFF0E1B35);
const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kWhite = Color(0xFFFFFFFF);
const kSecondary = Color(0xFFA0A7B8);
const kBorder = Color(0xFF1E2A45);
const kCardBg = Color(0xFF0D1526);
const kInputBg = Color(0xFF0A1020);

class CurrencyInfo {
  final String code;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const allCurrencies = [
  CurrencyInfo(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
  CurrencyInfo(code: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰'),
  CurrencyInfo(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
  CurrencyInfo(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
  CurrencyInfo(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
  CurrencyInfo(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵'),
  CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', flag: '🇨🇦'),
  CurrencyInfo(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺'),
  CurrencyInfo(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
  CurrencyInfo(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳'),
  CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳'),
  CurrencyInfo(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
  CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', flag: '🇸🇬'),
  CurrencyInfo(code: 'HKD', name: 'Hong Kong Dollar', flag: '🇭🇰'),
  CurrencyInfo(code: 'NZD', name: 'New Zealand Dollar', flag: '🇳🇿'),
];

class CurrencySelector extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final Function(String) onFromChanged;
  final Function(String) onToChanged;
  final List<String> searchResults;

  const CurrencySelector({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onFromChanged,
    required this.onToChanged,
    required this.searchResults,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _swapController;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    _swapController.forward(from: 0);
    final temp = widget.fromCurrency;
    widget.onFromChanged(widget.toCurrency);
    widget.onToChanged(temp);
  }

  List<CurrencyInfo> get _availableCurrencies {
    if (widget.searchResults.isEmpty) return allCurrencies;
    return allCurrencies
        .where((c) => widget.searchResults.contains(c.code))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CurrencyDropdown(
              label: 'FROM',
              selected: widget.fromCurrency,
              currencies: _availableCurrencies,
              onChanged: widget.onFromChanged,
            ),
          ),
          const SizedBox(width: 12),

          // Animated swap button
          GestureDetector(
            onTap: _handleSwap,
            child: AnimatedBuilder(
              animation: _swapController,
              builder: (_, child) => Transform.rotate(
                angle: _swapController.value * 3.14159,
                child: child,
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPurple, kPurpleLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kPurple.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: kWhite,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: _CurrencyDropdown(
              label: 'TO',
              selected: widget.toCurrency,
              currencies: _availableCurrencies,
              onChanged: widget.onToChanged,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String label;
  final String selected;
  final List<CurrencyInfo> currencies;
  final Function(String) onChanged;

  const _CurrencyDropdown({
    required this.label,
    required this.selected,
    required this.currencies,
    required this.onChanged,
  });

  CurrencyInfo get _selectedInfo =>
      currencies.firstWhere(
        (c) => c.code == selected,
        orElse: () => allCurrencies.firstWhere(
          (c) => c.code == selected,
          orElse: () => const CurrencyInfo(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: kSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kInputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Text(_selectedInfo.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected,
                        style: GoogleFonts.poppins(
                          color: kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CurrencyPickerSheet(
        currencies: currencies.isEmpty ? allCurrencies : currencies,
        selected: selected,
        onSelect: onChanged,
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final List<CurrencyInfo> currencies;
  final String selected;
  final Function(String) onSelect;

  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  List<CurrencyInfo> get _filtered => widget.currencies
      .where((c) =>
          c.code.toLowerCase().contains(_query.toLowerCase()) ||
          c.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Currency',
              style: GoogleFonts.poppins(
                color: kWhite,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(color: kWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search currencies...',
                hintStyle:
                    GoogleFonts.poppins(color: kSecondary, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: kSecondary, size: 20),
                filled: true,
                fillColor: kInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPurple),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected = c.code == widget.selected;
                return GestureDetector(
                  onTap: () {
                    widget.onSelect(c.code);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPurple.withOpacity(0.15)
                          : kInputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? kPurple.withOpacity(0.5) : kBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(c.flag,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.code,
                                style: GoogleFonts.poppins(
                                  color: kWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                c.name,
                                style: GoogleFonts.poppins(
                                  color: kSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: kPurple, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
