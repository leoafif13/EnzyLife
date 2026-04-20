import 'package:flutter/material.dart';
import 'app_color.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_navbar.dart';
import 'login_page.dart';
import 'edukasi_page.dart';
import 'belanja_page.dart';
import 'profil_page.dart';
import 'shopping_cart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnzyLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4CAF50),
        useMaterial3: true,
      ),
      home: const MainScreen(),
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

  static const _pageConfigs = [
    _PageConfig(label: 'Beranda', action: HeaderAction.logout),
    _PageConfig(label: 'Edukasi', action: HeaderAction.list),
    _PageConfig(label: 'Belanja', action: HeaderAction.cart),
    _PageConfig(label: 'Akun',    action: HeaderAction.none),
  ];

  final _pages = <Widget>[
    HomeScreen(),
    EducationScreen(),
    BelanjaScreen(),
    ProfilScreen(),
  ];

  void _handleAction(HeaderAction action) {
    if (action == HeaderAction.logout) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }
    if (action == HeaderAction.list && _selectedIndex == 1) {
      showEducationMenu(context);
      return;
    }
    if (action == HeaderAction.cart && _selectedIndex == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tombol ${action.name} ditekan'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _pageConfigs[_selectedIndex];
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppHeader(
        action: config.action,
        onActionTap: () => _handleAction(config.action),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

//  HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _articles = [
    _ArticleData(title: 'Kegiatan Membuat Eco Enzim di SDN 010 Batam', author: 'Admin'),
    _ArticleData(title: 'Kegiatan Membuat Eco Enzim di SDN 010 Batam', author: 'Admin'),
    _ArticleData(title: 'Manfaat Eco Enzim untuk Lingkungan Sekitar',   author: 'Admin'),
    _ArticleData(title: 'Cara Mudah Membuat Eco Enzim di Rumah',        author: 'Admin'),
  ];

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
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Rafi Akhbar!', // TODO: dari session/auth
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🌿  Hidup sehat dimulai dari sini',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.green900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
              ],
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

          // Pembaruan terkini
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(title: 'Pembaruan terkini'),
                    TextButton(
                      onPressed: () {},
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _articles.length,
                  itemBuilder: (_, i) => _ArticleCard(data: _articles[i]),
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
  const _SectionTitle({super.key, required this.title});

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
  const _FavoriteItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 72,
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

// ── Article card ──────────────────────────────
class _ArticleData {
  final String title;
  final String author;
  const _ArticleData({required this.title, required this.author});
}

class _ArticleCard extends StatelessWidget {
  final _ArticleData data;
  const _ArticleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 100,
                color: AppColors.green50,
                child: Center(
                  child: Icon(Icons.image_outlined, size: 36,
                      color: AppColors.green500.withOpacity(0.4)),
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
                      data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(data.author,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
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

// ── Placeholder halaman lain ──────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman $label',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Page config helper ────────────────────────
class _PageConfig {
  final String label;
  final HeaderAction action;
  const _PageConfig({required this.label, required this.action});
}