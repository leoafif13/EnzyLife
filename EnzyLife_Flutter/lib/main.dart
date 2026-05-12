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

  final _pages = <Widget>[
    HomeScreen(),
    EducationScreen(),
    BelanjaScreen(),
    ProfilScreen(),
  ];

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

// ── Global menu bottom sheet ──────────────────
class _GlobalMenu extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onLogout;
  const _GlobalMenu({required this.selectedIndex, required this.onLogout});

  static const _tabLabels = ['Beranda', 'Edukasi', 'Belanja', 'Akun'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Menu — ${_tabLabels[selectedIndex]}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _MenuRow(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () => Navigator.pop(context),
          ),
          _MenuRow(
            icon: Icons.help_outline_rounded,
            label: 'Bantuan',
            onTap: () => Navigator.pop(context),
          ),
          _MenuRow(
            icon: Icons.info_outline_rounded,
            label: 'Tentang Aplikasi',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          _MenuRow(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            color: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.text1;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c,
                )),
          ],
        ),
      ),
    );
  }
}