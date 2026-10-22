import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'analytics_service.dart';

const kPurple = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kPurpleDark = Color(0xFF3A1ACC);
const kCardBg = Color(0xFF0D1526);
const kBorder = Color(0xFF1E2A45);
const kSecondary = Color(0xFFA0A7B8);
const kWhite = Color(0xFFFFFFFF);
const kNavy = Color(0xFF0E1B35);

class ChartWidget extends StatefulWidget {
  final List<HistoricalRate> rates;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final bool isPositive;

  const ChartWidget({
    super.key,
    required this.rates,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isPositive,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  static const periods = ['1D', '1W', '1M', '6M', '1Y'];

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeInOut,
    );
    _lineController.forward();
  }

  @override
  void didUpdateWidget(covariant ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rates != widget.rates) {
      _lineController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  List<FlSpot> get _spots {
    if (widget.rates.isEmpty) return [];
    return widget.rates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.rate);
    }).toList();
  }

  double get _minY {
    if (widget.rates.isEmpty) return 0;
    final min = widget.rates.map((r) => r.rate).reduce((a, b) => a < b ? a : b);
    return min * 0.998;
  }

  double get _maxY {
    if (widget.rates.isEmpty) return 1;
    final max = widget.rates.map((r) => r.rate).reduce((a, b) => a > b ? a : b);
    return max * 1.002;
  }

  Color get _lineColor =>
      widget.isPositive ? const Color(0xFF00C896) : const Color(0xFFFF4757);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period selector chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = periods[i];
              final isSelected = p == widget.selectedPeriod;
              return GestureDetector(
                onTap: () => widget.onPeriodChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [kPurple, kPurpleLight],
                          )
                        : null,
                    color: isSelected ? null : kNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kPurple : kBorder,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kPurple.withOpacity(0.4),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    p,
                    style: GoogleFonts.poppins(
                      color: isSelected ? kWhite : kSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Chart container
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: kPurple.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.rates.isEmpty
              ? _EmptyChart()
              : AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (_, __) => _buildChart(),
                ),
        ).animate().fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildChart() {
    final spots = _spots;
    if (spots.isEmpty) return _EmptyChart();

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,touchTooltipData: LineTouchTooltipData(
  getTooltipColor: (_) => kNavy,
              tooltipBorder: const BorderSide(color: kPurple, width: 1),
              tooltipRoundedRadius: 12,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((ts) {
                  final rate = widget.rates[ts.x.toInt()];
                  return LineTooltipItem(
                    '${rate.rate.toStringAsFixed(4)}\n',
                    GoogleFonts.poppins(
                      color: kWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: _formatDate(rate.date),
                        style: GoogleFonts.poppins(
                          color: kSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (_maxY - _minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: kBorder.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, _) => Text(
                  _formatRate(value),
                  style: GoogleFonts.poppins(
                    color: kSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (spots.length / 4).floorToDouble().clamp(1, 999),
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < widget.rates.length) {
                    return Text(
                      _formatBottomLabel(widget.rates[idx].date),
                      style: GoogleFonts.poppins(
                        color: kSecondary,
                        fontSize: 9,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: _minY,
          maxY: _maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: _lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              shadow: Shadow(
                color: _lineColor.withOpacity(0.4),
                blurRadius: 8,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _lineColor.withOpacity(0.25),
                    _lineColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ),
    );
  }

  String _formatRate(double v) {
    if (v >= 100) return v.toStringAsFixed(0);
    if (v >= 10) return v.toStringAsFixed(2);
    return v.toStringAsFixed(3);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _formatBottomLabel(DateTime d) {
    switch (widget.selectedPeriod) {
      case '1D':
        return '${d.hour}h';
      case '1W':
        return _weekday(d.weekday);
      case '1M':
        return '${d.day}';
      default:
        return _month(d.month);
    }
  }

  String _weekday(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  String _month(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_rounded,
              color: kSecondary.withOpacity(0.3), size: 48),
          const SizedBox(height: 8),
          Text(
            'No chart data available',
            style: GoogleFonts.poppins(color: kSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
