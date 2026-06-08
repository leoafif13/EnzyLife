import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget nextScreen;
  const OnboardingScreen({super.key, required this.nextScreen});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  double _scrollOffset = 0.0;
  int _currentPage = 0;

  late AnimationController _bubbleController;
  late AnimationController _spinController;
  final List<_OnboardingBubble> _bubbles = [];

  // Gradient themes matching each onboarding page
  final List<List<Color>> _pageGradients = [
    [const Color(0xFF1B5E20), const Color(0xFF388E3C)], // Deep forest & Leaf green
    [const Color(0xFF0F5257), const Color(0xFF0B6623)], // Teal dark & Fresh green
    [const Color(0xFF004D40), const Color(0xFF4DB6AC)], // Emerald & Mint teal
  ];

  static const _pages = [
    _OnboardingData(
      icon: Icons.eco_outlined,
      title: 'Selamat Datang di EnzyLife',
      description:
          'Aplikasi edukasi dan belanja eco enzyme. '
          'Temukan berbagai informasi seputar eco enzyme dan manfaatnya untuk kehidupan sehari-hari.',
    ),
    _OnboardingData(
      icon: Icons.article_outlined,
      title: 'Belajar Lewat Artikel & Infografik',
      description:
          'Akses artikel, infografik, dan video edukasi '
          'seputar pembuatan dan pemanfaatan eco enzyme secara lengkap.',
    ),
    _OnboardingData(
      icon: Icons.shopping_bag_outlined,
      title: 'Belanja Produk Eco Enzyme',
      description:
          'Beli berbagai produk eco enzyme berkualitas '
          'langsung dari aplikasi dengan mudah dan cepat.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _controller.addListener(() {
      if (_controller.hasClients) {
        setState(() {
          _scrollOffset = _controller.page ?? 0.0;
        });
      }
    });

    // Bubble drift controller
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Constant spinning for artwork rings
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate random background bubbles
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _bubbles.add(
        _OnboardingBubble(
          xPercent: random.nextDouble(),
          yPercent: random.nextDouble() * 1.2,
          radius: random.nextDouble() * 18 + 6,
          speed: random.nextDouble() * 0.12 + 0.04,
          opacity: random.nextDouble() * 0.20 + 0.03,
        ),
      );
    }
  }

  // Smoothly interpolate background gradient color based on swipe position
  List<Color> _getCurrentGradient() {
    int index = _scrollOffset.floor();
    double t = _scrollOffset - index;
    
    if (index >= _pageGradients.length - 1) {
      return _pageGradients.last;
    }
    
    final startGrad = _pageGradients[index];
    final endGrad = _pageGradients[index + 1];
    
    final top = Color.lerp(startGrad[0], endGrad[0], t) ?? startGrad[0];
    final bottom = Color.lerp(startGrad[1], endGrad[1], t) ?? startGrad[1];
    
    return [top, bottom];
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubbleController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final currentGradient = _getCurrentGradient();
    final primaryThemeColor = currentGradient[0];

    return Scaffold(
      body: Stack(
        children: [
          // 1. Morphing Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: currentGradient,
              ),
            ),
          ),

          // 2. Background Bubbles
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _OnboardingBubblePainter(
                  bubbles: _bubbles,
                  progress: _bubbleController.value,
                ),
                child: Container(),
              );
            },
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: AnimatedOpacity(
                      opacity: isLast ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: isLast,
                        child: TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Swipe Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) {
                      return _OnboardingPage(
                        data: _pages[i],
                        index: i,
                        scrollOffset: _scrollOffset,
                        spinController: _spinController,
                      );
                    },
                  ),
                ),

                // Dot indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedTheme(
                      data: Theme.of(context).copyWith(
                        elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryThemeColor,
                            elevation: 8,
                            shadowColor: Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: isLast
                            ? _finish
                            : () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            key: ValueKey<bool>(isLast),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'Mulai Sekarang' : 'Lanjut',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.arrow_forward_rounded
                                    : Icons.chevron_right_rounded,
                                size: 20,
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

// ── Onboarding Page Element with Parallax and Opacity Animations ─────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int index;
  final double scrollOffset;
  final AnimationController spinController;

  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.scrollOffset,
    required this.spinController,
  });

  @override
  Widget build(BuildContext context) {
    // Relative scroll offset: focus=0.0, exitLeft=1.0, exitRight=-1.0
    final double relativePosition = scrollOffset - index;
    final double absPos = relativePosition.abs();

    // Animated transforms calculations
    final double opacity = (1.0 - absPos * 1.5).clamp(0.0, 1.0);
    final double scale = (1.0 - absPos * 0.25).clamp(0.6, 1.0);
    final double artworkParallax = relativePosition * -130.0;
    final double textParallax = relativePosition * 90.0;
    final double rotationAngle = relativePosition * 0.35; // rad

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Artwork/Graphic Circle
          Transform.translate(
            offset: Offset(artworkParallax, 0),
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotationAngle,
                child: Opacity(
                  opacity: opacity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Spinning accent circle (dashed style)
                      RotationTransition(
                        turns: spinController,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 3.5,
                            ),
                          ),
                        ),
                      ),
                      // Oppositely spinning dotted circle
                      RotationTransition(
                        turns: Tween<double>(begin: 1.0, end: 0.0)
                            .animate(spinController),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Main glassmorphic circle
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Icon(
                          data.icon,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Animated Typography Page Content
          Transform.translate(
            offset: Offset(textParallax, 0),
            child: Opacity(
              opacity: opacity,
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.6,
                        shadows: const [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onboarding Data ─────────────────────────────────
class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ── Background bubble model ──────────────────────────
class _OnboardingBubble {
  double xPercent;
  double yPercent;
  final double radius;
  final double speed;
  final double opacity;

  _OnboardingBubble({
    required this.xPercent,
    required this.yPercent,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

// ── Background bubble custom painter ──────────────────
class _OnboardingBubblePainter extends CustomPainter {
  final List<_OnboardingBubble> bubbles;
  final double progress;

  _OnboardingBubblePainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

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
  bool shouldRepaint(covariant _OnboardingBubblePainter oldDelegate) => true;
}

