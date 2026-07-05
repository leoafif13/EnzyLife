import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../app_color.dart';
import '../auth/login_page.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'verification_page.dart';
import '../belanja/belanja_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;
  bool _agreeTerms      = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    // VALIDASI
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.register(
        name,
        email,
        password,
        confirmPassword,
      );

      if (response['token'] != null) {
        await AuthService.saveToken(response['token']);
        // SIMPAN DATA USER
        await AuthService.saveUser(response['user']);
        await CartState.instance.loadCartForUser();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => VerificationScreen(email: email),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Register gagal',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn(
        clientId: '446261249929-lrlmjp2qmsieej3vbgd9r0pc44vfi1gf.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken ?? googleAuth.accessToken;

      if (idToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan token Google. Silakan coba lagi.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final result = await AuthService.loginWithGoogle(idToken);

      if (result['token'] != null) {
        await AuthService.saveToken(result['token']);
        await AuthService.saveUser(result['user']);
        await CartState.instance.loadCartForUser();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Google berhasil'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else if (result['needs_verification'] == true) {
        // Fallback safety: tidak harusnya terjadi untuk Google login
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => VerificationScreen(email: result['user']?['email'] ?? ''),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login Google gagal'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat masuk Google: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Syarat & Ketentuan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green900,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Syarat & Ketentuan Penggunaan EnzyLife',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terakhir diperbarui: Juni 2026',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 16),
                      _buildTermItem(
                        '1. Penerimaan Ketentuan',
                        'Dengan mendaftar dan menggunakan aplikasi EnzyLife, Anda menyetujui untuk terikat oleh Syarat dan Ketentuan ini serta Kebijakan Privasi kami. Jika Anda tidak menyetujui salah satu bagian dari ketentuan ini, Anda tidak diperkenankan menggunakan layanan kami.',
                      ),
                      _buildTermItem(
                        '2. Akun Pengguna',
                        'Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun dan password Anda. Anda setuju untuk bertanggung jawab atas semua aktivitas yang terjadi di bawah akun Anda. EnzyLife berhak membatasi atau menghentikan akun yang terindikasi melakukan pelanggaran.',
                      ),
                      _buildTermItem(
                        '3. Layanan Belanja & Eco-Enzyme',
                        'EnzyLife menyediakan platform edukasi dan e-commerce produk ramah lingkungan berbasis Eco-Enzyme. Informasi produk, stok, dan harga yang tertera dapat berubah sewaktu-waktu tanpa pemberitahuan sebelumnya. Pembayaran produk difasilitasi melalui gateway pembayaran resmi yang aman.',
                      ),
                      _buildTermItem(
                        '4. Kebijakan Konten & Edukasi',
                        'Seluruh konten edukasi berupa artikel, infografik, dan panduan pembuatan Eco-Enzyme di aplikasi EnzyLife dilindungi oleh hak cipta. Pengguna diperbolehkan membagikan konten untuk tujuan edukatif non-komersial dengan mencantumkan sumber asli EnzyLife.',
                      ),
                      _buildTermItem(
                        '5. Batasan Tanggung Jawab',
                        'EnzyLife tidak bertanggung jawab atas kerugian langsung maupun tidak langsung yang disebabkan oleh penggunaan produk atau informasi dari aplikasi ini yang tidak sesuai dengan instruksi keselamatan pembuatan atau pemakaian Eco-Enzyme.',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              // Footer Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Saya Mengerti',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermItem(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.green700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green900,
      body: Stack(
        children: [
          _RegisterOrbs(floatController: _floatController),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(position: _slideUp, child: const _TopSection()),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Buat Akun',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                                      color: AppColors.green900, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text('Isi data diri kamu untuk mulai',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              const SizedBox(height: 28),

                              _InputField(controller: _nameController,
                                  label: 'Nama Lengkap', hint: 'John Doe',
                                  icon: Icons.person_outline_rounded),
                              const SizedBox(height: 16),

                              _InputField(controller: _emailController,
                                  label: 'Email', hint: 'contoh@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),

                              _InputField(
                                controller: _passwordController,
                                label: 'Password', hint: 'Min. 8 karakter',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.grey[600], size: 20),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _InputField(
                                controller: _confirmController,
                                label: 'Konfirmasi Password', hint: 'Ulangi password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.grey[600], size: 20),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Checkbox syarat & ketentuan
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24, height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                                      activeColor: AppColors.green500,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                        children: [
                                          const TextSpan(text: 'Saya setuju dengan '),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: GestureDetector(
                                              onTap: _showTermsModal,
                                              child: const Text(
                                                'Syarat & Ketentuan',
                                                style: TextStyle(
                                                  color: AppColors.green500,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(text: ' yang berlaku'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity, height: 52,
                                child: ElevatedButton(
                                  onPressed: (_isLoading || !_agreeTerms) ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green500,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.green500.withOpacity(0.45),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                      : const Text('Daftar',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Divider atau ──────────────
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey[300], height: 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('atau',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey[300], height: 1)),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ── Lanjutkan dengan Google ────
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : _handleGoogleLogin,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                                    foregroundColor: AppColors.text1,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google_logo.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Lanjutkan dengan Google',
                                          style: TextStyle(fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.text1)),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sudah punya akun? ',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                                    child: const Text('Masuk',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                            color: AppColors.green500)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

// ── Top section ───────────────────────────────
class _TopSection extends StatelessWidget {
  const _TopSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EnzyLife',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            Text('Daftar dan mulai perjalananmu',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

// ── Background orbs ───────────────────────────
class _RegisterOrbs extends StatelessWidget {
  final AnimationController floatController;
  const _RegisterOrbs({required this.floatController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _RegisterOrbPainter(floatController.value),
      ),
    );
  }
}

class _RegisterOrbPainter extends CustomPainter {
  final double t;
  _RegisterOrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final dy1 = math.sin(t * math.pi) * 16;
    final dy2 = math.cos(t * math.pi) * 12;
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.08 + dy1), size.width * 0.32,
        Paint()..color = const Color(0xFF2E7D32).withOpacity(0.5));
    canvas.drawCircle(Offset(size.width * 0.0, size.height * 0.18 + dy2), size.width * 0.18,
        Paint()..color = const Color(0xFF388E3C).withOpacity(0.4));
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.28 - dy1 * 0.6), size.width * 0.08,
        Paint()..color = const Color(0xFF4CAF50).withOpacity(0.3));
  }

  @override
  bool shouldRepaint(_RegisterOrbPainter old) => old.t != t;
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
