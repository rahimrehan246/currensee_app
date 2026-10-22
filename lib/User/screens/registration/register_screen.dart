import 'package:curreny/User/screens/converter/converter_screen.dart';
import 'package:curreny/admin/currencyx_admin_panel.dart';
import 'package:curreny/user/screens/registration/firestore_eservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurrencyX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '.SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF070B14),
      ),
      home: const AuthGateway(),
    );
  }
}

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
const kGold = Color(0xFFFFD166);
const kGoldDark = Color(0xFFE5A50A);

// ── Gateway (Tab controller) ─────────────────────────────────────────────────
class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kBg,
      body: TabBarView(
        controller: _tab,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LoginScreen(onSwitch: () => _tab.animateTo(1)),
          RegisterScreen(onSwitch: () => _tab.animateTo(0)),
        ],
      ),
    );
  }
}

// ── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginScreen({super.key, required this.onSwitch});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ── Email / Password Login ──────────────────────────────────────────────
  Future<void> _handleEmailLogin() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) return;

      if (!mounted) return;

      // ── Admin check ─────────────────────────────────────────────────────
      final emailLower = user.email?.toLowerCase() ?? '';
      final isAdmin = FirestoreService.isAdminEmail(emailLower) ||
          await FirestoreService.isAdminByUid(user.uid);

      if (!mounted) return;

      if (isAdmin) {
        // Ensure admin document exists
        await FirestoreService.ensureAdminDoc(user: user);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ConverterScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_mapFirebaseError(e.code))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  // ── Google Login ────────────────────────────────────────────────────────
  // ── Google Login ────────────────────────────────────────────────────────
Future<void> _handleGoogleLogin() async {
  final messenger = ScaffoldMessenger.of(context);
  setState(() => _loading = true);

  try {
    UserCredential userCredential;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }

    final user = userCredential.user;

    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    // save google user
    await FirestoreService.saveGoogleUser(user: user);

    final emailLower = user.email?.toLowerCase().trim() ?? '';

    // ADMIN CHECK
    final isAdmin =
        FirestoreService.isAdminEmail(emailLower) ||
        await FirestoreService.isAdminByUid(user.uid);

    if (!mounted) return;

    // ── ADMIN PANEL ─────────────────────────────
    if (isAdmin) {
      await FirestoreService.ensureAdminDoc(user: user);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdminShell(),
        ),
        (route) => false,
      );

      return;
    }

    // ── USER PANEL ──────────────────────────────
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ConverterScreen(),
      ),
      (route) => false,
    );

  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text(_mapFirebaseError(e.code))),
    );
  } catch (e) {
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text('Google sign-in error: $e')),
    );
  }

  if (mounted) {
    setState(() => _loading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Premium fintech themed header
            const _FintechHeader(
              title: 'Sign in to your\nAccount',
              subtitle: 'Welcome back! Enter your credentials.',
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InputField(
                    controller: _email,
                    hint: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _pass,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PurpleButton(
                    label: 'Log In',
                    loading: _loading,
                    onTap: _handleEmailLogin,
                  ),
                  const SizedBox(height: 24),

_OrDivider(),

const SizedBox(height: 8),

SizedBox(
  width: double.infinity,

  child: _SocialButton(
    label: 'Google',
    isGoogle: true,
    onTap: _handleGoogleLogin,
  ),
),
const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: kSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: widget.onSwitch,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: kPurpleLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Register Screen ───────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const RegisterScreen({super.key, required this.onSwitch});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _repeat = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _repeat.dispose();
    super.dispose();
  }

  // ── Email / Password Register ───────────────────────────────────────────
  Future<void> _handleRegister() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _pass.text.trim().isEmpty ||
        _repeat.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_pass.text != _repeat.text) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_name.text.trim());

        // Save to "customers" collection (no duplicate due to uid check)
        await FirestoreService.saveCustomer(
          user: user,
          name: _name.text.trim(),
        );
      }

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Redirect to Login tab
      widget.onSwitch();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(_mapFirebaseError(e.code))));
    } catch (e) {
      if (!mounted) return;
      messenger
          .showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _FintechHeader(
              title: 'Create your\nAccount',
              subtitle: 'Join thousands of users today.',
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InputField(
                    controller: _name,
                    hint: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _email,
                    hint: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _pass,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure1,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure1 = !_obscure1),
                      child: Icon(
                        _obscure1
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _repeat,
                    hint: 'Repeat Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure2,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure2 = !_obscure2),
                      child: Icon(
                        _obscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PurpleButton(
                    label: 'Create Account',
                    loading: _loading,
                    onTap: _handleRegister,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: kSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: widget.onSwitch,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: kPurpleLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Firebase Error Mapper ─────────────────────────────────────────────────────
String _mapFirebaseError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'invalid-credential':
      return 'Invalid credentials. Please try again.';
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different sign-in method.';
    default:
      return 'Authentication failed. Please try again.';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PREMIUM FINTECH HEADER (replaces _CurvedHeader + animated blobs)
// ══════════════════════════════════════════════════════════════════════════════

class _FintechHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FintechHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        height: 340,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.35, 0.7, 1.0],
            colors: [
              Color(0xFF0B1530),
              Color(0xFF0E1B35),
              Color(0xFF120D2E),
              Color(0xFF0D0A20),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── World map grid lines (fintech globe aesthetic) ─────────────
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),
            // ── Glowing orb – top right ────────────────────────────────────
            Positioned(
              top: -40,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kPurple.withOpacity(0.35),
                      kPurple.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Small gold accent orb ─────────────────────────────────────
            Positioned(
              bottom: 80,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kGold.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Floating currency cards ───────────────────────────────────
            Positioned(
              right: 20,
              bottom: 55,
              child: Transform.rotate(
                angle: 0.12,
                child: const _CurrencyCard(
                  flag: '🇺🇸',
                  code: 'USD',
                  rate: '1.0000',
                  color: Color(0xFF1C3A5E),
                ),
              ),
            ),
            Positioned(
              right: 110,
              bottom: 80,
              child: Transform.rotate(
                angle: -0.1,
                child: const _CurrencyCard(
                  flag: '🇪🇺',
                  code: 'EUR',
                  rate: '0.9218',
                  color: Color(0xFF1A1A4A),
                ),
              ),
            ),
            // ── Text + logo ───────────────────────────────────────────────
            Positioned(
              top: 56,
              left: 24,
              right: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  _FintechLogo(),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // ── Bottom glow line ──────────────────────────────────────────
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 1,
                  width: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        kPurple.withOpacity(0.5),
                        kGold.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fintech Logo ──────────────────────────────────────────────────────────────
class _FintechLogo extends StatelessWidget {
  const _FintechLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo Box
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPurpleDark,
                kPurple,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: const Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Currency',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'X',
                    style: TextStyle(
                      color: kGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: kGold.withOpacity(0.25),
                ),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: kGold,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
// ── Currency Card (floating UI element) ──────────────────────────────────────
class _CurrencyCard extends StatelessWidget {
  final String flag;
  final String code;
  final String rate;
  final Color color;

  const _CurrencyCard({
    required this.flag,
    required this.code,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                code,
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rate,
            style: TextStyle(
              color: kWhite.withOpacity(0.55),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          // Mini sparkline bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: code == 'USD' ? 1.0 : 0.72,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                code == 'USD' ? const Color(0xFF34A853) : kPurpleLight,
              ),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid Painter (fintech map lines) ─────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2A45).withOpacity(0.4)
      ..strokeWidth = 0.5;

    const step = 28.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Diagonal accent lines (premium touch)
    final accentPaint = Paint()
      ..color = kPurple.withOpacity(0.08)
      ..strokeWidth = 1;

    for (double i = -size.height; i < size.width; i += 56) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Curve Clipper ─────────────────────────────────────────────────────────────
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height + 20,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 60,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Purple Button ─────────────────────────────────────────────────────────────
class _PurpleButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PurpleButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_PurpleButton> createState() => _PurpleButtonState();
}

class _PurpleButtonState extends State<_PurpleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPurpleLight, kPurple, kPurpleDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPurple.withOpacity(0.55),
                blurRadius: 28,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: kPurple.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: kWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? kPurple.withOpacity(0.7) : kBorder,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: kPurple.withOpacity(0.12),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            widget.icon,
            size: 18,
            color: _focused ? kPurpleLight : kSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focused = f),
              child: TextField(
                controller: widget.controller,
                obscureText: widget.obscure,
                keyboardType: widget.keyboardType,
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: kSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            widget.suffix!,
            const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

// ── Or Divider ────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, kBorder],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: TextStyle(color: kSecondary, fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kBorder, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────
class _SocialButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isGoogle;
  final VoidCallback? onTap;

  const _SocialButton({
    super.key,
    required this.label,
    this.icon,
    this.isGoogle = false,
    this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 56,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF111B30)
              : const Color(0xFF0D1526),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isGoogle)
              const _MiniGoogleIcon()
            else
              Icon(widget.icon, color: kWhite, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: kWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Google Icon ──────────────────────────────────────────────────────────
class _MiniGoogleIcon extends StatelessWidget {
  const _MiniGoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    void drawArc(double start, double sweep, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(
            Rect.fromCircle(center: c, radius: r), start, sweep, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    drawArc(math.pi, math.pi / 2, const Color(0xFFEA4335));
    drawArc(math.pi * 3 / 2, math.pi / 2, const Color(0xFFFBBC05));
    drawArc(0, math.pi / 2, const Color(0xFF34A853));
    drawArc(math.pi / 2, math.pi / 2, const Color(0xFF4285F4));

    canvas.drawCircle(c, r * 0.4, Paint()..color = const Color(0xFF0D1526));

    final tabRect = Rect.fromLTRB(
        c.dx, c.dy - r * 0.13, size.width + r * 0.2, c.dy + r * 0.13);
    canvas.drawRect(tabRect, Paint()..color = const Color(0xFF4285F4));
    canvas.drawCircle(c, r * 0.4, Paint()..color = const Color(0xFF0D1526));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}