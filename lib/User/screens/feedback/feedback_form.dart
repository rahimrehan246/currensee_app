import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Color palette ────────────────────────────────────────────────────────────
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurrencyX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPurple),
        useMaterial3: true,
      ),
      home: const FeedbackFormPage(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FEEDBACK FORM PAGE
// ════════════════════════════════════════════════════════════════════════════
class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  int _rating = 0;
  final Set<String> _selectedCategories = {};
  bool? _recommend;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Exchange Rates', 'icon': Icons.trending_up},
    {'label': 'App Design', 'icon': Icons.dashboard_outlined},
    {'label': 'Speed', 'icon': Icons.bolt_outlined},
    {'label': 'Converter', 'icon': Icons.swap_horiz},
    {'label': 'Rate Alerts', 'icon': Icons.notifications_outlined},
    {'label': 'Analytics', 'icon': Icons.bar_chart_outlined},
  ];

  final List<String> _ratingLabels = [
    '',
    'Very Poor',
    'Not Good',
    "It's Okay",
    'Good',
    'Excellent!',
  ];

  // ── Submit to Firebase ──────────────────────────────────────────────────
  Future<void> _submitForm() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please give a rating first'),
          backgroundColor: const Color(0xFF3A1ACC),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'rating': _rating,
        'categories': _selectedCategories.toList(),
        'feedback': _feedbackController.text.trim(),
        'recommend': _recommend,
        'email': _emailController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _submitted = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _submitted = false;
      _rating = 0;
      _selectedCategories.clear();
      _recommend = null;
      _feedbackController.clear();
      _emailController.clear();
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ── Scaffold ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
  backgroundColor: kNavy,
  foregroundColor: kWhite,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kWhite),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  title: const Text(
    'App Feedback',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: kWhite,
    ),
  ),
),
      body: _submitted ? _buildSuccessScreen() : _buildForm(),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildRatingCard(),
          const SizedBox(height: 12),
          _buildCategoryCard(),
          const SizedBox(height: 12),
          _buildFeedbackCard(),
          const SizedBox(height: 12),
          _buildRecommendCard(),
          const SizedBox(height: 12),
          _buildEmailCard(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPurple.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              color: kWhite,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Your Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kWhite,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your feedback helps us improve',
                style: TextStyle(fontSize: 13, color: kSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Generic card shell ────────────────────────────────────────────────────
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Rating ────────────────────────────────────────────────────────────────
  Widget _buildRatingCard() {
    return _buildCard(
      title: 'OVERALL RATING',
      icon: Icons.star_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      key: ValueKey(filled),
                      size: 38,
                      color: filled ? Colors.amber : Colors.white24,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _rating > 0 ? 1 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating > 0 ? _ratingLabels[_rating] : 'Tap a star to rate',
              style: TextStyle(
                fontSize: 13,
                color: _rating > 0 ? kPurpleLight : kSecondary,
                fontWeight: _rating > 0 ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips ────────────────────────────────────────────────────────
  Widget _buildCategoryCard() {
    return _buildCard(
      title: 'WHAT DID YOU LIKE?',
      icon: Icons.label_outline,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.map((cat) {
          final selected = _selectedCategories.contains(cat['label']);
          return GestureDetector(
            onTap: () => setState(() {
              selected
                  ? _selectedCategories.remove(cat['label'])
                  : _selectedCategories.add(cat['label'] as String);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? kPurple.withOpacity(0.18) : kInputBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? kPurple : kBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 15,
                    color: selected ? kPurpleLight : kSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected ? kWhite : kSecondary,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Text feedback ─────────────────────────────────────────────────────────
  Widget _buildFeedbackCard() {
    return _buildCard(
      title: 'YOUR FEEDBACK',
      icon: Icons.chat_bubble_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            maxLength: 300,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: kWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What should we improve? Any suggestions?',
              hintStyle: const TextStyle(fontSize: 14, color: kSecondary),
              filled: true,
              fillColor: kInputBg,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPurple, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_feedbackController.text.length}/300',
            style: const TextStyle(fontSize: 12, color: kSecondary),
          ),
        ],
      ),
    );
  }

  // ── Recommend ─────────────────────────────────────────────────────────────
  Widget _buildRecommendCard() {
    return _buildCard(
      title: 'WOULD YOU RECOMMEND US?',
      icon: Icons.people_outline,
      child: Row(
        children: [
          Expanded(
            child: _recButton(true, Icons.thumb_up_outlined, 'Yes, definitely'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _recButton(false, Icons.thumb_down_outlined, 'Not yet'),
          ),
        ],
      ),
    );
  }

  Widget _recButton(bool value, IconData icon, String label) {
    final selected = _recommend == value;
    final isYes = value;
    return GestureDetector(
      onTap: () => setState(() => _recommend = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? (isYes
                    ? kPurple.withOpacity(0.18)
                    : Colors.red.withOpacity(0.12))
              : kInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? (isYes ? kPurple : Colors.red.shade700) : kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? (isYes ? kPurpleLight : Colors.red.shade400)
                  : kSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? (isYes ? kWhite : Colors.red.shade300)
                    : kSecondary,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Email ─────────────────────────────────────────────────────────────────
  Widget _buildEmailCard() {
    return _buildCard(
      title: 'EMAIL (OPTIONAL)',
      icon: Icons.mail_outline,
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: kWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'you@example.com',
          hintStyle: const TextStyle(fontSize: 14, color: kSecondary),
          filled: true,
          fillColor: kInputBg,
          prefixIcon: const Icon(
            Icons.alternate_email,
            size: 18,
            color: kSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPurple, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitForm,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          _isLoading ? 'Submitting...' : 'Submit Feedback',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPurple,
          foregroundColor: kWhite,
          disabledBackgroundColor: kPurpleDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Success screen ────────────────────────────────────────────────────────
  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: kPurple.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: kPurple.withOpacity(0.40),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 50,
                color: kPurpleLight,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: kWhite,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your feedback has been received.\nWe will keep improving our app for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: kSecondary, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPurpleLight,
                  side: const BorderSide(color: kPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Another',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  STATISTICS PAGE
// ════════════════════════════════════════════════════════════════════════════
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPurple),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading stats',
                style: const TextStyle(color: kSecondary),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 64, color: kBorder),
                  SizedBox(height: 16),
                  Text(
                    'No feedback yet',
                    style: TextStyle(color: kSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // ── Compute stats ────────────────────────────────────────────────
          final total = docs.length;
          double ratingSum = 0;
          int yesCount = 0;
          int ratedCount = 0;
          final Map<String, int> catCounts = {};
          final Map<int, int> ratingDist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final rating = (data['rating'] ?? 0) as int;
            if (rating > 0) {
              ratingSum += rating;
              ratedCount++;
              ratingDist[rating] = (ratingDist[rating] ?? 0) + 1;
            }

            if (data['recommend'] == true) yesCount++;

            final cats = data['categories'];
            if (cats is List) {
              for (final c in cats) {
                catCounts[c.toString()] = (catCounts[c.toString()] ?? 0) + 1;
              }
            }
          }

          final avgRating = ratedCount > 0 ? ratingSum / ratedCount : 0.0;
          final recommendPct = total > 0 ? (yesCount / total * 100) : 0.0;

          final sortedCats = catCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // ── Top metric cards ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        'Total Responses',
                        total.toString(),
                        Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        'Avg Rating',
                        avgRating.toStringAsFixed(1),
                        Icons.star_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        'Recommend',
                        '${recommendPct.toStringAsFixed(0)}%',
                        Icons.thumb_up_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Rating distribution ─────────────────────────────────
                _sectionTitle('Rating Distribution'),
                const SizedBox(height: 12),
                _statCard(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = ratingDist[star] ?? 0;
                      final pct = ratedCount > 0 ? count / ratedCount : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: kPurpleLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$star',
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor: kInputBg,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        kPurple,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '$count',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: kSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Top categories ──────────────────────────────────────
                _sectionTitle('Top Categories'),
                const SizedBox(height: 12),
                _statCard(
                  child: sortedCats.isEmpty
                      ? const Text(
                          'No category data',
                          style: TextStyle(color: kSecondary),
                        )
                      : Column(
                          children: sortedCats.take(6).map((entry) {
                            final pct = total > 0 ? entry.value / total : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: kWhite,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value}  (${(pct * 100).toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                          color: kSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: kInputBg,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            kPurpleLight,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                // ── Recommend breakdown ─────────────────────────────────
                _sectionTitle('Recommendation'),
                const SizedBox(height: 12),
                _statCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _recBar(
                          'Yes',
                          yesCount,
                          total,
                          kPurple,
                          Icons.thumb_up_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _recBar(
                          'Not yet',
                          total - yesCount,
                          total,
                          const Color(0xFF993C1D),
                          Icons.thumb_down_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: kPurpleLight),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: kSecondary)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: kSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _statCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: child,
    );
  }

  Widget _recBar(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          '${(pct * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: kSecondary)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: kInputBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
