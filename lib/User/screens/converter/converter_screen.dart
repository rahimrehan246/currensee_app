import 'dart:convert';
import 'dart:math' as math;
import 'package:curreny/User/screens/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:country_flags/country_flags.dart';

// ── Colors ───────────────────────────────────────────────────────────────────
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

// ── Currency Data ─────────────────────────────────────────────────────────────
class CurrencyItem {
  final String code;
  final String flag;
  final String name;

  const CurrencyItem({
    required this.code,
    required this.flag,
    required this.name,
  });
}
const List<CurrencyItem> kCurrencies = [
  CurrencyItem(code: "USD", flag: "us", name: "US Dollar"),
  CurrencyItem(code: "PKR", flag: "pk", name: "Pakistani Rupee"),
  CurrencyItem(code: "BDT", flag: "bd", name: "Bangladeshi Taka"),
  CurrencyItem(code: "EUR", flag: "eu", name: "Euro"),
  CurrencyItem(code: "GBP", flag: "gb", name: "British Pound"),
  CurrencyItem(code: "AED", flag: "ae", name: "UAE Dirham"),
  CurrencyItem(code: "SAR", flag: "sa", name: "Saudi Riyal"),
  CurrencyItem(code: "INR", flag: "in", name: "Indian Rupee"),
  CurrencyItem(code: "CAD", flag: "ca", name: "Canadian Dollar"),
  CurrencyItem(code: "JPY", flag: "jp", name: "Japanese Yen"),
  CurrencyItem(code: "CNY", flag: "cn", name: "Chinese Yuan"),
  CurrencyItem(code: "CHF", flag: "ch", name: "Swiss Franc"),
  CurrencyItem(code: "AUD", flag: "au", name: "Australian Dollar"),
  CurrencyItem(code: "NZD", flag: "nz", name: "New Zealand Dollar"),
  CurrencyItem(code: "SGD", flag: "sg", name: "Singapore Dollar"),
  CurrencyItem(code: "HKD", flag: "hk", name: "Hong Kong Dollar"),
  CurrencyItem(code: "SEK", flag: "se", name: "Swedish Krona"),
  CurrencyItem(code: "NOK", flag: "no", name: "Norwegian Krone"),
  CurrencyItem(code: "DKK", flag: "dk", name: "Danish Krone"),
  CurrencyItem(code: "TRY", flag: "tr", name: "Turkish Lira"),
  CurrencyItem(code: "ZAR", flag: "za", name: "South African Rand"),
  CurrencyItem(code: "BRL", flag: "br", name: "Brazilian Real"),
  CurrencyItem(code: "MXN", flag: "mx", name: "Mexican Peso"),
  CurrencyItem(code: "RUB", flag: "ru", name: "Russian Ruble"),
  CurrencyItem(code: "KRW", flag: "kr", name: "South Korean Won"),
  CurrencyItem(code: "THB", flag: "th", name: "Thai Baht"),
  CurrencyItem(code: "MYR", flag: "my", name: "Malaysian Ringgit"),
  CurrencyItem(code: "IDR", flag: "id", name: "Indonesian Rupiah"),
  CurrencyItem(code: "EGP", flag: "eg", name: "Egyptian Pound"),
  CurrencyItem(code: "QAR", flag: "qa", name: "Qatari Riyal"),
  CurrencyItem(code: "KWD", flag: "kw", name: "Kuwaiti Dinar"),
  CurrencyItem(code: "BHD", flag: "bh", name: "Bahraini Dinar"),
  CurrencyItem(code: "OMR", flag: "om", name: "Omani Rial"),
];

// ── Main Screen ───────────────────────────────────────────────────────────────
class ConverterScreen extends StatefulWidget {


  final String? fromCurrency;
  final String? toCurrency;

  const ConverterScreen({
    super.key,
    this.fromCurrency,
    this.toCurrency,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
  
}

class _ConverterScreenState extends State<ConverterScreen>
    with TickerProviderStateMixin {
      String _getCurrencySymbol(String code) {
  switch (code) {
    case "USD":
    case "CAD":
    case "AUD":
    case "NZD":
    case "SGD":
    case "HKD":
      return "\$";

    case "EUR":
      return "€";

    case "GBP":
      return "£";

    case "JPY":
    case "CNY":
      return "¥";

    case "INR":
      return "₹";

    case "PKR":
      return "₨";

    case "BDT":
      return "৳"; // 🇧🇩 Bangladesh Taka

    case "KRW":
      return "₩";

    case "RUB":
      return "₽";

    case "TRY":
      return "₺";

    case "THB":
      return "฿";

    default:
      return code;
  }

}
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
late String _fromCurrency;
late String _toCurrency;

  double _result = 0;
  double _exchangeRate = 0;
  bool _isLoading = false;
  bool _hasResult = false;

  late AnimationController _pulseController;
  late AnimationController _swapController;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

 @override
void initState() {
  super.initState();

  final from = widget.fromCurrency;
  final to = widget.toCurrency;

  _fromCurrency = (from != null && kCurrencies.any((c) => c.code == from))
      ? from
      : "EUR"; // ya USD jo default chaho

  _toCurrency = (to != null && kCurrencies.any((c) => c.code == to))
      ? to
      : "PKR";
_toCurrency = kCurrencies.any((c) => c.code == widget.toCurrency)
    ? widget.toCurrency!
    : "PKR";
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    _pulseController.dispose();
    _swapController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  CurrencyItem _getCurrency(String code) {
    return kCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kCurrencies.first,
    );
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final url = "https://open.er-api.com/v6/latest/$_fromCurrency";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _exchangeRate = (data["rates"][_toCurrency] as num).toDouble();
final amount = double.tryParse(_amountController.text);
if (amount == null) {
  _showError("Enter valid number");
  return;
}
        setState(() {
          _result = amount * _exchangeRate;
          _isLoading = false;
          _hasResult = true;
        });

        _resultController.forward(from: 0);
        HapticFeedback.mediumImpact();
      } else {
        setState(() => _isLoading = false);
        _showError("Failed to fetch rates. Please try again.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Network error. Check your connection.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kCardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder),
        ),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: kWhite)),
          ],
        ),
      ),
    );
  }

  void _swapCurrencies() {
    HapticFeedback.selectionClick();
    _swapController.forward(from: 0);
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      if (_hasResult) {
void _swapCurrencies() {
  HapticFeedback.selectionClick();
  _swapController.forward(from: 0);

  setState(() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
  });

  if (_amountController.text.isNotEmpty) {
    _convertCurrency();
  }
}      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      drawer: const PremiumDrawer(),
      
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    _buildBalanceCard(),
                    const SizedBox(height: 28),
                    _buildSectionLabel("Currency Converter"),
                    const SizedBox(height: 14),
                    _buildConverterCard(),
                    const SizedBox(height: 20),
                    if (_hasResult) ...[
                      _buildResultCard(),
                      const SizedBox(height: 20),
                    ],
                    _buildRateInfoRow(),
                    const SizedBox(height: 28),
                    _buildSectionLabel("Quick Rates"),
                    const SizedBox(height: 14),
                    _buildQuickRatesRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────
Widget _buildTopBar() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ================= MENU BUTTON =================
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: kWhite,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ================= TITLE AREA =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [kWhite, kPurpleLight],
                ).createShader(bounds),
                child: const Text(
                  "Converter",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            const Color(0xFF00E676),
                            const Color(0xFF69F0AE),
                            _pulseController.value,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      "Live Exchange Rates",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _iconButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kBorder),
      ),
      child: Icon(icon, color: kSecondary, size: 20),
    );
  }

  // ── Balance Card ─────────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPurple, kPurpleDark],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative orb
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "TOTAL BALANCE",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "\$12,450.00",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.trending_up, color: Color(0xFF69F0AE),
                            size: 14),
                        SizedBox(width: 4),
                        Text(
                          "+2.4%",
                          style: TextStyle(
                            color: Color(0xFF69F0AE),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withOpacity(0.12)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _balanceMiniCard("USD", "\$4,820"),
                  _balanceMiniCard("EUR", "€3,210"),
                  _balanceMiniCard("GBP", "£4,420"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceMiniCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: kWhite,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: kWhite,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  // ── Converter Card ─────────────────────────────────────────────────────────────
  Widget _buildConverterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          // Amount input
          _buildAmountField(),
          const SizedBox(height: 16),
          // Currency selectors + swap
          _buildCurrencyRow(),
          const SizedBox(height: 20),
          // Convert button
          _buildConvertButton(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            "AMOUNT",
            style: TextStyle(
              color: kSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
              child: Text(
  _getCurrencySymbol(_fromCurrency),
  style: const TextStyle(
    color: kSecondary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    hintStyle: TextStyle(color: kBorder, fontSize: 22),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _amountController.clear();
                  setState(() {
                    _hasResult = false;
                    _result = 0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: kSecondary, size: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyRow() {
    return Row(
      children: [
        Expanded(child: _buildCurrencySelector(_fromCurrency, "FROM", (v) {
          if (v != null) setState(() => _fromCurrency = v);
        })),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _buildSwapButton(),
        ),
        Expanded(child: _buildCurrencySelector(_toCurrency, "TO", (v) {
          if (v != null) setState(() => _toCurrency = v);
        })),
      ],
    );
  }

  Widget _buildCurrencySelector(
      String value, String label, Function(String?) onChanged) {
    final currency = _getCurrency(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: kSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: kNavy,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: kSecondary, size: 18),
              style: const TextStyle(color: kWhite),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              selectedItemBuilder: (context) {
                return kCurrencies.map((c) {
                  return Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        c.flag,
                        height: 18,
                        width: 24,
                        
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c.code,
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: kCurrencies.map((c) {
                return DropdownMenuItem(
                  value: c.code,
                  child: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        c.flag,
                        height: 18,
                        width: 24,
                        
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.code,
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            c.name,
                            style: const TextStyle(
                              color: kSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AnimatedBuilder(
        animation: _swapController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _swapController.value * math.pi,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _swapCurrencies,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPurple, kPurpleDark],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kPurple.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.swap_horiz_rounded,
                color: kWhite, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
  Colors.white.withOpacity(0.08),
),
        ),
        onPressed: _isLoading ? null : _convertCurrency,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
                  ? [kPurpleDark, kPurpleDark]
                  : [kPurple, kPurpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: kPurple.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: kWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.currency_exchange, color: kWhite, size: 18),
                      SizedBox(width: 10),
                      Text(
                        "Convert Currency",
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Result Card ───────────────────────────────────────────────────────────────
  Widget _buildResultCard() {
    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _resultAnimation.value)),
          child: Opacity(
            opacity: _resultAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: kPurple.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF69F0AE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "CONVERTED AMOUNT",
                      style: TextStyle(
                        color: kSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: _result.toStringAsFixed(2)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Copied to clipboard"),
                        duration: Duration(seconds: 1),
                        backgroundColor: kNavy,
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kNavy,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy_rounded,
                            color: kSecondary, size: 12),
                        SizedBox(width: 5),
                        Text(
                          "Copy",
                          style: TextStyle(
                            color: kSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result >= 1000000
                            ? "${(_result / 1000000).toStringAsFixed(2)}M"
                            : _result >= 1000
                                ? "${(_result / 1000).toStringAsFixed(2)}K"
                                : _result.toStringAsFixed(2),
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCurrency(_toCurrency).name,
                        style: const TextStyle(
                          color: kSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildCurrencyBadge(_fromCurrency),
                    const SizedBox(height: 6),
                    const Icon(Icons.arrow_downward_rounded,
                        color: kPurpleLight, size: 16),
                    const SizedBox(height: 6),
                    _buildCurrencyBadge(_toCurrency),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBadge(String code) {
    final c = _getCurrency(code);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountryFlag.fromCountryCode(
            c.flag,
            height: 14,
            width: 20,
            
          ),
          const SizedBox(width: 6),
          Text(
            c.code,
            style: const TextStyle(
              color: kWhite,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rate Info Row ─────────────────────────────────────────────────────────────
  Widget _buildRateInfoRow() {
    if (!_hasResult) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: kSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(4)} $_toCurrency",
              style: const TextStyle(
                color: kSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: kPurple.withOpacity(0.3)),
            ),
            child: const Text(
              "Live",
              style: TextStyle(
                color: kPurpleLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Rates Row ───────────────────────────────────────────────────────────
  Widget _buildQuickRatesRow() {
    final List<Map<String, String>> quickRates = [
      {"from": "us", "code": "USD", "label": "Dollar"},
      {"from": "eu", "code": "EUR", "label": "Euro"},
      {"from": "gb", "code": "GBP", "label": "Pound"},
      {"from": "ae", "code": "AED", "label": "Dirham"},
    ];

    return Row(
      children: quickRates.map((q) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: q == quickRates.last ? 0 : 10,
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                CountryFlag.fromCountryCode(
                  q["from"]!,
                  height: 22,
                  width: 30,
                  
                ),
                const SizedBox(height: 8),
                Text(
                  q["code"]!,
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  q["label"]!,
                  style: const TextStyle(
                    color: kSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      
    );
    
  }
  
}
