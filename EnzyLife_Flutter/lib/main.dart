import 'package:flutter/material.dart';
import 'app_color.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_navbar.dart';
import 'auth/login_page.dart';
import 'edukasi/edukasi_page.dart';
import 'belanja/belanja_page.dart';
import 'profil/profil_page.dart';
import 'belanja/shopping_cart.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'models/artikel.dart';
import 'models/infografik.dart';
import 'edukasi/detail_artikel_page.dart';
import 'edukasi/detail_infografik_page.dart';
import 'widgets/page_header_card.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ambil token dari local storage
  final token = await AuthService.getToken();

  if (token != null) {
    await CartState.instance.loadCartForUser();
  }

  runApp(MyApp(
    isLoggedIn: token != null,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnzyLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4CAF50),
        useMaterial3: true,
      ),

      // Splash screen dulu, baru ke login/main
      home: SplashScreen(
        nextScreen: isLoggedIn
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }
}
//  MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<bool> _activatedPages = [true, false, false, false];

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
      _activatedPages[index] = true;
    });
  }

  // Buka keranjang dari mana saja
  void _openCart() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  // Titik 3 — menu kontekstual per tab
  void _openMenu() {
    // Semua tab pakai modal yang sama seperti edukasi
    showEducationMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppHeader(
        onCartTap: _openCart,
        onMenuTap: _openMenu,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          _activatedPages[1] ? const EducationScreen() : const SizedBox.shrink(),
          _activatedPages[2] ? const BelanjaScreen() : const SizedBox.shrink(),
          _activatedPages[3] ? const ProfilScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

//  HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Pengguna';
  List<ArtikelModel> _artikelList = [];
  List<InfografikModel> _infografikList = [];
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    _loadContent();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getUser();

    if (user != null) {
      final rawName = user['name']?.toString().trim() ?? '';
      setState(() {
        userName = (rawName.isEmpty || rawName == '-') ? 'Pengguna Baru' : rawName;
      });
    }
  }

  Future<void> _loadContent() async {
    final artikel = await ApiService.getArtikel();
    final infografik = await ApiService.getInfografik();

    if (!mounted) return;

    // Sort descending berdasarkan created_at (terbaru di awal)
    artikel.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    infografik.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      // Ambil 4 artikel terbaru
      _artikelList = artikel.take(4).toList();
      // Ambil 6 infografik terbaru
      _infografikList = infografik.take(6).toList();
      _isLoadingContent = false;
    });
  }

  static const _favorites = [
    _FavoriteData(label: 'Artikel', icon: Icons.article_outlined),
    _FavoriteData(label: 'Kalkulator',   icon: Icons.calculate_outlined),
    _FavoriteData(label: 'Produk',  icon: Icons.eco_outlined),
    _FavoriteData(label: 'Profil',   icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: PageHeaderCard(
              badge: '👋  Selamat datang',
              title: '$userName!',
              subtitle: 'Hidup sehat dimulai dari sini. Mari berkontribusi untuk bumi dengan menggunakan eco enzim.',
              rightWidget: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Menu favorit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Menu favorit anda'),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _favorites.map((f) => _FavoriteItem(data: f)).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Artikel Terbaru ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(title: 'Artikel Terbaru'),
                    TextButton(
                      onPressed: () {
                        // Navigate ke tab Edukasi (index 1)
                        final mainState = context.findAncestorStateOfType<_MainScreenState>();
                        mainState?._onTabTap(1);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green500,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _isLoadingContent
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _artikelList.isEmpty
                        ? const _EmptyContentCard(
                            icon: Icons.article_outlined,
                            message: 'Belum ada artikel tersedia',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: _artikelList.length,
                            itemBuilder: (_, i) => _ArtikelCard(artikel: _artikelList[i]),
                          ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Infografik Terbaru ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(title: 'Infografik Terbaru'),
                    TextButton(
                      onPressed: () {
                        final mainState = context.findAncestorStateOfType<_MainScreenState>();
                        mainState?._onTabTap(1);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green500,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _isLoadingContent
                    ? const SizedBox.shrink()
                    : _infografikList.isEmpty
                        ? const _EmptyContentCard(
                            icon: Icons.image_outlined,
                            message: 'Belum ada infografik tersedia',
                          )
                        : SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _infografikList.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => _InfografikCard(infografik: _infografikList[i]),
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

// ── Section title ──────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.2,
      ),
    );
  }
}

// ── Favorite menu ─────────────────────────────
class _FavoriteData {
  final String label;
  final IconData icon;
  const _FavoriteData({required this.label, required this.icon});
}

class _FavoriteItem extends StatelessWidget {
  final _FavoriteData data;
  const _FavoriteItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
              child: Icon(data.icon, color: AppColors.green500, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty content placeholder ─────────────────
class _EmptyContentCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyContentCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppColors.green500),
          ),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── Artikel card (data dari API) ──────────────
class _ArtikelCard extends StatelessWidget {
  final ArtikelModel artikel;
  const _ArtikelCard({required this.artikel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailArtikelPage(item: artikel)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail dari database
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.network(
                  'http://127.0.0.1:8000/gambar/${artikel.gambar}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.green50,
                    child: Center(
                      child: Icon(Icons.article_outlined, size: 36,
                          color: AppColors.green500.withOpacity(0.4)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge kategori
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        artikel.kategori,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                            color: AppColors.green500),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artikel.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Baca selengkapnya →',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Infografik card (horizontal scroll) ───────
class _InfografikCard extends StatelessWidget {
  final InfografikModel infografik;
  const _InfografikCard({required this.infografik});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailInfografikPage(item: infografik)),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail dari database
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: 160,
                child: Image.network(
                  'http://127.0.0.1:8000/gambar/${infografik.gambar}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.green50,
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 36,
                          color: AppColors.green500.withOpacity(0.4)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      infografik.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      infografik.createdAt.split('T')[0],
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
