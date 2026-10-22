import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Color palette ─────────────────────────────────────────────────────────────
const kBg          = Color(0xFF070B14);
const kNavy        = Color(0xFF0E1B35);
const kPurple      = Color(0xFF5B2EFF);
const kPurpleLight = Color(0xFF7B52FF);
const kPurpleDark  = Color(0xFF3A1ACC);
const kWhite       = Color(0xFFFFFFFF);
const kSecondary   = Color(0xFFA0A7B8);
const kBorder      = Color(0xFF1E2A45);
const kCardBg      = Color(0xFF0D1526);
const kInputBg     = Color(0xFF0A1020);

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
        colorScheme: ColorScheme.fromSeed(seedColor: kPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ContactUsPage(),
    );
  }
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _nameFocus     = FocusNode();
  final _emailFocus    = FocusNode();
  final _subjectFocus  = FocusNode();
  final _messageFocus  = FocusNode();

  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _isLoading  = false;
  bool _submitted  = false;

  late AnimationController _successAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _subjectFocus.dispose();
    _messageFocus.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validateSubject(String? v) {
    if (v == null || v.trim().isEmpty) return 'Subject is required';
    if (v.trim().length < 3) return 'Subject must be at least 3 characters';
    return null;
  }

  String? _validateMessage(String? v) {
    if (v == null || v.trim().isEmpty) return 'Message is required';
    if (v.trim().length < 10) return 'Message must be at least 10 characters';
    return null;
  }

  // ── Firebase submit ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('contact').add({
        'name'      : _nameCtrl.text.trim(),
        'email'     : _emailCtrl.text.trim(),
        'subject'   : _subjectCtrl.text.trim(),
        'message'   : _messageCtrl.text.trim(),
        'createdAt' : FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
        _submitted = true;
      });
      _successAnim.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: kWhite, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Failed to send: ${e.toString()}')),
            ],
          ),
          backgroundColor: const Color(0xFF7B0000),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Reset form ──────────────────────────────────────────────────────────────
  void _reset() {
    _successAnim.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _formKey.currentState?.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
      setState(() => _submitted = false);
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _submitted
            ? _buildSuccessScreen(key: const ValueKey('success'))
            : _buildForm(key: const ValueKey('form')),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kWhite, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Contact Us',
        style: TextStyle(
          color: kWhite,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────────
  Widget _buildForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            const SizedBox(height: 24),
            _buildSectionLabel('Personal Info'),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildField(
                  controller : _nameCtrl,
                  focusNode  : _nameFocus,
                  nextFocus  : _emailFocus,
                  label      : 'Full Name',
                  hint       : 'e.g. Ali Hassan',
                  icon       : Icons.person_outline_rounded,
                  validator  : _validateName,
                  textInputAction: TextInputAction.next,
                ),
                _divider(),
                _buildField(
                  controller : _emailCtrl,
                  focusNode  : _emailFocus,
                  nextFocus  : _subjectFocus,
                  label      : 'Email Address',
                  hint       : 'you@example.com',
                  icon       : Icons.alternate_email_rounded,
                  keyboard   : TextInputType.emailAddress,
                  validator  : _validateEmail,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Your Message'),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildField(
                  controller : _subjectCtrl,
                  focusNode  : _subjectFocus,
                  nextFocus  : _messageFocus,
                  label      : 'Subject',
                  hint       : 'What is this about?',
                  icon       : Icons.subject_rounded,
                  validator  : _validateSubject,
                  textInputAction: TextInputAction.next,
                ),
                _divider(),
                _buildField(
                  controller : _messageCtrl,
                  focusNode  : _messageFocus,
                  label      : 'Message',
                  hint       : 'Write your message here... (min 10 characters)',
                  icon       : Icons.chat_bubble_outline_rounded,
                  maxLines   : 6,
                  validator  : _validateMessage,
                  textInputAction: TextInputAction.done,
                  onChanged  : (_) => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_messageCtrl.text.length} / 1000',
                style: const TextStyle(fontSize: 11, color: kSecondary),
              ),
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            _buildContactInfoRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPurple.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPurple.withOpacity(0.40)),
            ),
            child: const Icon(Icons.support_agent_rounded, color: kPurpleLight, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'d love to hear from you',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kWhite,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Our team usually replies within 24 hours',
                  style: TextStyle(fontSize: 12, color: kSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: kSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: kBorder);
  }

  // ── Single text field ───────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard       = TextInputType.text,
    int maxLines                  = 1,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.done,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller      : controller,
        focusNode       : focusNode,
        keyboardType    : keyboard,
        maxLines        : maxLines,
        maxLength       : maxLines > 1 ? 1000 : null,
        validator       : validator,
        textInputAction : textInputAction,
        style           : const TextStyle(color: kWhite, fontSize: 14),
        onChanged       : onChanged,
        onFieldSubmitted : (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        cursorColor: kPurpleLight,
        decoration: InputDecoration(
          labelText     : label,
          labelStyle    : const TextStyle(color: kSecondary, fontSize: 13),
          hintText      : hint,
          hintStyle     : const TextStyle(color: Color(0xFF4A5368), fontSize: 13),
          filled        : true,
          fillColor     : Colors.transparent,
          counterText   : '',
          prefixIcon    : Padding(
            padding: const EdgeInsets.only(left: 4, right: 2),
            child: Icon(icon, size: 19, color: kSecondary),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder  : InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical  : maxLines > 1 ? 14 : 0,
          ),
          errorStyle: const TextStyle(
            color    : Color(0xFFFF6B6B),
            fontSize : 11,
            height   : 1.4,
          ),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  // ── Gradient submit button ──────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  colors: [kPurple, kPurpleLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isLoading ? kPurpleDark : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: kPurple.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: kWhite, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Send Message',
                      style: TextStyle(
                        color      : kWhite,
                        fontSize   : 16,
                        fontWeight : FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContactInfoRow() {
    return Row(
      children: [
        Expanded(child: _infoChip(Icons.email_outlined,   'support@currencyx.io')),
        const SizedBox(width: 10),
        Expanded(child: _infoChip(Icons.access_time_rounded, 'Mon–Fri, 9–6 PM')),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kPurpleLight),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: kSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Success screen ──────────────────────────────────────────────────────────
  Widget _buildSuccessScreen({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPurple.withOpacity(0.12),
                  border: Border.all(color: kPurple.withOpacity(0.35), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPurple.withOpacity(0.20),
                      ),
                    ),
                    const Icon(
                      Icons.check_rounded,
                      size: 44,
                      color: kPurpleLight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Message Sent!',
              style: TextStyle(
                fontSize   : 26,
                fontWeight : FontWeight.w700,
                color      : kWhite,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank you for reaching out.\nOur team will get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize : 14,
                color    : kSecondary,
                height   : 1.6,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GestureDetector(
                onTap: _reset,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPurple, kPurpleLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kPurple.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Send Another Message',
                      style: TextStyle(
                        color      : kWhite,
                        fontSize   : 15,
                        fontWeight : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: kSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}