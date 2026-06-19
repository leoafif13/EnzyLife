import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'services/auth_service.dart';
import 'auth/login_page.dart';
import 'auth/verification_page.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Widget? _resolvedNextScreen;
  late AnimationController _entryController;
  late AnimationController _bubbleController;
  late AnimationController _pulseController;
  late AnimationController _spinController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;
  late Animation<double> _logoPulse;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _loadingOpacity;

  final List<_Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _checkAuthAndVerification();

    // Entry animations controller
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Bubble drift and orb float controller (infinite loop)
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Pulse controller for logo breathing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Spin controller for rotating outer ring
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Elastic pop-in for logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Subtle spin on entry
    _logoRotate = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Logo breathing pulse
    _logoPulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Slide and fade for texts
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start entry animations
    _entryController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // Generate random background bubbles
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _bubbles.add(
        _Bubble(
          xPercent: random.nextDouble(),
          yPercent: random.nextDouble() * 1.2,
          radius: random.nextDouble() * 25 + 8,
          speed: random.nextDouble() * 0.15 + 0.05,
          opacity: random.nextDouble() * 0.22 + 0.04,
        ),
      );
    }

    // Navigate setelah 3.2 detik agar animasi transisi terlihat matang
    Future.delayed(const Duration(milliseconds: 3200), () => _navigate());
  }

  Future<void> _checkAuthAndVerification() async {
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _resolvedNextScreen = const LoginScreen();
        });
      }
      return;
    }

    try {
      final user = await AuthService.fetchUserProfile();
      if (user != null) {
        if (user['unauthorized'] == true) {
          if (mounted) {
            setState(() {
              _resolvedNextScreen = const LoginScreen();
            });
          }
        } else {
          // Simpan data user terbaru secara lokal
          await AuthService.saveUser(user);
          if (mounted) {
            setState(() {
              if (user['email_verified_at'] == null) {
                _resolvedNextScreen = VerificationScreen(email: user['email'] ?? '');
              } else {
                _resolvedNextScreen = const MainScreen();
              }
            });
          }
        }
      } else {
        // Jika offline atau error jaringan, gunakan cache lokal
        final cachedUser = await AuthService.getUser();
        if (mounted) {
          setState(() {
            if (cachedUser != null) {
              if (cachedUser['email_verified_at'] == null) {
                _resolvedNextScreen = VerificationScreen(email: cachedUser['email'] ?? '');
              } else {
                _resolvedNextScreen = const MainScreen();
              }
            } else {
              _resolvedNextScreen = const LoginScreen();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resolvedNextScreen = const LoginScreen();
        });
      }
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    // Tunggu jika proses async _checkAuthAndVerification belum selesai (maksimal 10 detik/100 retries)
    int retries = 0;
    while (_resolvedNextScreen == null && retries < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }

    final nextScreen = _resolvedNextScreen ?? const LoginScreen();

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    final destination = onboardingDone
        ? nextScreen
        : OnboardingScreen(nextScreen: nextScreen);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _bubbleController.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Beautiful animated gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20), // deep forest green
                  Color(0xFF2E7D32), // rich green
                  Color(0xFF4CAF50), // organic green
                ],
              ),
            ),
          ),

          // 2. Animated bubbling background effect (drifting enzyme bubbles + large floating green orbs)
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _BackgroundPainter(
                  bubbles: _bubbles,
                  progress: _bubbleController.value,
                ),
                child: Container(),
              );
            },
          ),

          // 3. Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with Spinning Outer Ring & Pulse
                AnimatedBuilder(
                  animation: Listenable.merge([_entryController, _pulseController]),
                  builder: (context, child) {
                    final currentScale = _logoScale.value *
                        (_pulseController.isAnimating ? _logoPulse.value : 1.0);
                    return Transform.scale(
                      scale: currentScale,
                      child: Transform.rotate(
                        angle: _logoRotate.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Spinning outer ring (similar to onboarding style)
                      RotationTransition(
                        turns: _spinController,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 3.5,
                            ),
                          ),
                        ),
                      ),
                      // Main logo container
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Slide & Fade Text Title & Subtitle
                AnimatedBuilder(
                  animation: _entryController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlide,
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Text(
                        'EnzyLife',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Eco Enzyme untuk Hidup Lebih Baik',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Smooth Loading Spinner
                AnimatedBuilder(
                  animation: _entryController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _loadingOpacity.value,
                      child: child,
                    );
                  },
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
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

// ── Background bubble model ────────────────────
class _Bubble {
  double xPercent;
  double yPercent;
  final double radius;
  final double speed;
  final double opacity;

  _Bubble({
    required this.xPercent,
    required this.yPercent,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

// ── Background painter for large floating orbs (login style) + small rising bubbles ──
class _BackgroundPainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;

  _BackgroundPainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw large floating green orbs (similar to LoginScreen background)
    // We use sine/cosine functions driven by the progress to make them move gently up & down
    final dy1 = math.sin(progress * 2 * math.pi) * 22;
    final dy2 = math.cos(progress * 2 * math.pi) * 16;

    // Orb 1 (top-left)
    paint.color = const Color(0xFF2E7D32).withValues(alpha: 0.45);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15 + dy1),
      size.width * 0.32,
      paint,
    );

    // Orb 2 (top-right)
    paint.color = const Color(0xFF388E3C).withValues(alpha: 0.35);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08 + dy2),
      size.width * 0.25,
      paint,
    );

    // Orb 3 (mid-left)
    paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.20);
    canvas.drawCircle(
      Offset(size.width * -0.05, size.height * 0.42 - dy1 * 0.6),
      size.width * 0.18,
      paint,
    );

    // 2. Draw small rising enzyme bubbles (Onboarding/Splash bubbles)
    for (var bubble in bubbles) {
      double currentY = size.height * bubble.yPercent -
          (progress * size.height * bubble.speed);
      
      if (currentY < -bubble.radius) {
        currentY = size.height + bubble.radius;
      }

      final double currentX = size.width * bubble.xPercent;

      paint.color = Colors.white.withValues(alpha: bubble.opacity);
      canvas.drawCircle(
        Offset(currentX, currentY),
        bubble.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
