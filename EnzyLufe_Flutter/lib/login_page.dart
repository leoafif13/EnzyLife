import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'register_page.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;
  bool _isLoading           = false;

  late final AnimationController _floatController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Color palette ──────────────────────────────
  static const _green900 = Color(0xFF1B5E20);
  static const _green700 = Color(0xFF388E3C);
  static const _green500 = Color(0xFF4CAF50);
  static const _green200 = Color(0xFFA5D6A7);
  static const _green50  = Color(0xFFE8F5E9);
  static const _white    = Colors.white;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green900,
      body: Stack(
        children: [
          // ── Dekoratif: lingkaran organik background ──
          _BackgroundOrbs(floatController: _floatController),

          // ── Konten utama ────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top: logo area
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _LogoSection(),
                    ),
                  ),
                ),

                // Bottom: form card
                Expanded(
                  flex: 7,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _FormCard(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        isLoading: _isLoading,
                        onTogglePassword: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        onLogin: _handleLogin,
                      ),
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

// ══════════════════════════════════════════════
//  Background dekoratif: blob melayang
// ══════════════════════════════════════════════
class _BackgroundOrbs extends StatelessWidget {
  final AnimationController floatController;
  const _BackgroundOrbs({required this.floatController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (_, __) {
        final t = floatController.value;
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _OrbPainter(t),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final dy1 = math.sin(t * math.pi) * 18;
    final dy2 = math.cos(t * math.pi) * 14;

    // Orb kiri atas
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.12 + dy1),
      size.width * 0.28,
      Paint()..color = const Color(0xFF2E7D32).withOpacity(0.55),
    );

    // Orb kanan atas
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.07 + dy2),
      size.width * 0.22,
      Paint()..color = const Color(0xFF388E3C).withOpacity(0.4),
    );

    // Orb kecil tengah kiri
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.38 - dy1 * 0.5),
      size.width * 0.1,
      Paint()..color = const Color(0xFF4CAF50).withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ══════════════════════════════════════════════
//  Logo section
// ══════════════════════════════════════════════
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo dalam lingkaran putih
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'EnzyLife',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hidup sehat dimulai dari sini',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
//  Form card
// ══════════════════════════════════════════════
class _FormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _FormCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
  });

  static const _green500 = Color(0xFF4CAF50);
  static const _green700 = Color(0xFF388E3C);
  static const _green50  = Color(0xFFE8F5E9);
  static const _grey600  = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          const Text(
            'Masuk',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selamat datang kembali!',
            style: TextStyle(
              fontSize: 14,
              color: _grey600,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 28),

          // Field email
          _InputField(
            controller: emailController,
            label: 'Email',
            hint: 'contoh@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Field password
          _InputField(
            controller: passwordController,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _grey600,
                size: 20,
              ),
              onPressed: onTogglePassword,
            ),
          ),

          // Lupa password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: _green700,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              child: const Text(
                'Lupa password?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tombol login
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green500,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _green500.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),

          const Spacer(),

          // Daftar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum punya akun? ',
                style: TextStyle(fontSize: 14, color: _grey600),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Daftar sekarang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _green500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Reusable input field
// ══════════════════════════════════════════════
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon: Icon(icon, color: _green500, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _green50,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _green500, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}