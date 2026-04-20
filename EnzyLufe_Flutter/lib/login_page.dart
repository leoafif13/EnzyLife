import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_color.dart';
import 'register_page.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;
  bool _isLoading           = false;

  late final AnimationController _floatController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset>  _slideUp;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );
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
    await Future.delayed(const Duration(seconds: 2)); // TODO: ganti dengan request API login
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green900,
      body: Stack(
        children: [
          _BackgroundOrbs(floatController: _floatController),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(position: _slideUp, child: const _LogoSection()),
                  ),
                ),
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
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
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

// ── Background orbs ───────────────────────────
class _BackgroundOrbs extends StatelessWidget {
  final AnimationController floatController;
  const _BackgroundOrbs({required this.floatController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _OrbPainter(floatController.value),
      ),
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
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.12 + dy1), size.width * 0.28,
        Paint()..color = const Color(0xFF2E7D32).withOpacity(0.55));
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.07 + dy2), size.width * 0.22,
        Paint()..color = const Color(0xFF388E3C).withOpacity(0.4));
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.38 - dy1 * 0.5), size.width * 0.1,
        Paint()..color = const Color(0xFF4CAF50).withOpacity(0.25));
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ── Logo section ──────────────────────────────
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        const Text('EnzyLife',
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Hidup sehat dimulai dari sini',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, letterSpacing: 0.2)),
      ],
    );
  }
}

// ── Form card ─────────────────────────────────
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
          const Text('Masuk',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: AppColors.green900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Selamat datang kembali!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 28),

          _InputField(controller: emailController, label: 'Email',
              hint: 'contoh@email.com', icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          _InputField(
            controller: passwordController, label: 'Password',
            hint: '••••••••', icon: Icons.lock_outline_rounded,
            obscure: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[600], size: 20),
              onPressed: onTogglePassword,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {}, // TODO: implementasi lupa password
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.green700,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4)),
              child: const Text('Lupa password?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.green500.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Masuk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Belum punya akun? ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Daftar sekarang',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.green500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable input field ──────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller, required this.label,
    required this.hint, required this.icon,
    this.obscure = false, this.keyboardType, this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.green900, letterSpacing: 0.1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.text1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.green500, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.green50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.green500, width: 1.5)),
          ),
        ),
      ],
    );
  }
}