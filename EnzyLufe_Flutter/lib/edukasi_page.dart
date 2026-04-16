import 'package:flutter/material.dart';
import 'edukasi/artikel_page.dart';
import 'edukasi/kalkulator_page.dart';
import 'edukasi/faq_page.dart';

// ══════════════════════════════════════════════
//  Educationpage
//  Dipanggil dari MainScreen index 1
//  Modal fitur dibuka via showEducationMenu(context)
//  yang dipanggil dari onActionTap header di main.dart
// ══════════════════════════════════════════════

// Fungsi global untuk buka modal dari header
void showEducationMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const _EducationMenuModal(),
    transitionBuilder: (_, anim, __, child) {
      // Animasi: muncul dari kanan atas, expand ke bawah-kiri
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return Align(
        alignment: Alignment.topRight,
        child: FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, -0.1),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(curved),
              alignment: Alignment.topRight,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════
//  Modal fitur edukasi
// ══════════════════════════════════════════════
class _EducationMenuModal extends StatelessWidget {
  const _EducationMenuModal();

  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);

  static const _menuItems = [
    _MenuItem(label: 'Tentang Eco Enzim',    icon: Icons.info_outline_rounded),
    _MenuItem(label: 'Artikel & Infografik', icon: Icons.article_outlined),
    _MenuItem(label: 'Kalkulator Eco Enzim', icon: Icons.calculate_outlined),
    _MenuItem(label: 'FAQ',                  icon: Icons.help_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Posisi modal: bawah AppBar kanan
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
        right: 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 230,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header modal
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                decoration: const BoxDecoration(
                  color: _green50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined, color: _green500, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Fitur Edukasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _green900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 18, color: _green900),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: const Color(0xFFEEEEEE)),

              // Menu items
              ...List.generate(_menuItems.length, (i) {
                final item = _menuItems[i];
                final isLast = i == _menuItems.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        final routes = [
                          const ArtikelScreen(),
                          const ArtikelScreen(),    // Infografik – pakai ArtikelScreen dulu, pisah nanti
                          const KalkulatorScreen(),
                          const FaqScreen(),
                        ];
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => routes[i]),
                        );
                      },
                      borderRadius: isLast
                          ? const BorderRadius.vertical(bottom: Radius.circular(20))
                          : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 18, color: _green500),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded,
                                size: 16, color: Color(0xFFBDBDBD)),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 1,
                        color: const Color(0xFFF0F0F0),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  const _MenuItem({required this.label, required this.icon});
}

// ══════════════════════════════════════════════
//  EducationScreen widget utama
// ══════════════════════════════════════════════
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const _sections = [
    _EduSection(
      title: 'Mengenal Eco Enzim lebih jauh',
      items: [
        _EduItem(
          hasVideo: true,
          caption: '',
        ),
        _EduItem(
          hasVideo: true,
          caption: '',
        ),
      ],
    ),
    _EduSection(
      title: 'Manfaat Eco Enzim',
      items: [
        _EduItem(
          hasVideo: false,
          // TODO: ganti '' dengan caption manfaat pertama
          caption: '',
        ),
        _EduItem(
          hasVideo: false,
          // TODO: ganti '' dengan caption manfaat kedua
          caption: '',
        ),
      ],
    ),
    _EduSection(
      title: 'Cara Membuat Eco Enzim',
      items: [
        _EduItem(
          hasVideo: false,
          // TODO: ganti '' dengan caption langkah pertama
          caption: '',
        ),
        _EduItem(
          hasVideo: false,
          // TODO: ganti '' dengan caption langkah kedua
          caption: '',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(),
          const SizedBox(height: 12),
          _IntroCard(),
          const SizedBox(height: 4),
          ..._sections.map((s) => _SectionBlock(section: s)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Hero banner
// ══════════════════════════════════════════════
class _HeroBanner extends StatelessWidget {
  static const _green900 = Color(0xFF1B5E20);
  static const _green700 = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green900, _green700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green900.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🌿  Edukasi',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tentang Eco Enzim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  // TODO: ganti '' dengan deskripsi singkat hero banner
                  '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Intro card dengan expand/collapse
// ══════════════════════════════════════════════
class _IntroCard extends StatefulWidget {
  @override
  State<_IntroCard> createState() => _IntroCardState();
}

class _IntroCardState extends State<_IntroCard> {
  bool _expanded = false;
  static const _green500 = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: _green500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Apa itu Eco Enzim?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            // TODO: ganti '' dengan teks penjelasan lengkap eco enzim
            '',
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text( 'Eco Enzim adalah cairan serbaguna yang dihasilkan dari fermentasi limbah organik seperti kulit buah dan sayuran',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _green500),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Section + item model
// ══════════════════════════════════════════════
class _EduSection {
  final String title;
  final List<_EduItem> items;
  const _EduSection({required this.title, required this.items});
}

class _EduItem {
  final bool hasVideo;
  final String caption;
  const _EduItem({required this.hasVideo, required this.caption});
}

// ══════════════════════════════════════════════
//  Section block
// ══════════════════════════════════════════════
class _SectionBlock extends StatelessWidget {
  final _EduSection section;
  const _SectionBlock({super.key, required this.section});

  static const _green500 = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: _green500, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A), letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.items.asMap().entries.map(
            (e) => _EduItemCard(item: e.value, index: e.key),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Card item: rasio 16:9 landscape + caption
// ══════════════════════════════════════════════
class _EduItemCard extends StatelessWidget {
  final _EduItem item;
  final int index;
  const _EduItemCard({super.key, required this.item, required this.index});

  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // ── Thumbnail 16:9 ─────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // TODO: ganti Container di bawah dengan:
                  // Image.network('url_gambar_atau_thumbnail', fit: BoxFit.cover,
                  //   width: double.infinity, height: double.infinity)
                  // atau Image.asset('assets/images/nama_file.jpg', fit: BoxFit.cover)
                  Container(color: _green50),

                  if (item.hasVideo)
                    // Tombol play video
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: _green500.withOpacity(0.88),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    )
                  else
                    Icon(Icons.image_outlined, size: 40, color: _green500.withOpacity(0.3)),
                ],
              ),
            ),
          ),

          // ── Caption ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: item.caption.isNotEmpty
                ? Text(
                    item.caption,
                    style: const TextStyle(
                      fontSize: 13, color: Color(0xFF444444), height: 1.6),
                  )
                : Text(
                    // Penanda TODO yang terlihat jelas
                    '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}