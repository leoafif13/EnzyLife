import 'package:flutter/material.dart';
import 'app_color.dart';
import 'edukasi/artikel_page.dart';
import 'edukasi/kalkulator_page.dart';
import 'edukasi/faq_page.dart';

// ══════════════════════════════════════════════
//  showEducationMenu — dipanggil dari main.dart
//  saat icon list di header tab Edukasi ditekan
// ══════════════════════════════════════════════
void showEducationMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const _EducationMenuModal(),
    transitionBuilder: (_, anim, __, child) {
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

  static const _menuItems = [
    _MenuItem(label: 'Artikel & Infografik', icon: Icons.article_outlined),
    _MenuItem(label: 'Kalkulator Eco Enzim', icon: Icons.calculate_outlined),
    _MenuItem(label: 'FAQ',                  icon: Icons.help_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
        right: 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 230,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
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
                  color: AppColors.green50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        color: AppColors.green500, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Fitur Edukasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.green900),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: const Color(0xFFEEEEEE)),

              // Menu items
              ...List.generate(_menuItems.length, (i) {
                final item = _menuItems[i];
                final isLast = i == _menuItems.length - 1;

                // Routes: index 0 = Tentang (scroll ke atas edukasi_page),
                // 1 = Artikel, 2 = Kalkulator, 3 = FAQ
                final routes = <Widget>[
                  const ArtikelScreen(),
                  const KalkulatorScreen(),
                  const FaqScreen(),
                ];

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => routes[i]),
                        );
                      },
                      borderRadius: isLast
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(20))
                          : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(item.icon,
                                size: 18, color: AppColors.green500),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text1,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded,
                                size: 16, color: AppColors.hint),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 1,
                        color: AppColors.divider,
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
//  EducationScreen — konten tab Edukasi
// ══════════════════════════════════════════════
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const _sections = [
    _EduSection(
      title: 'Mengenal Eco Enzim lebih jauh',
      items: [
        _EduItem(hasVideo: true,  caption: ''), // TODO: isi caption
        _EduItem(hasVideo: true,  caption: ''), // TODO: isi caption
      ],
    ),
    _EduSection(
      title: 'Manfaat Eco Enzim',
      items: [
        _EduItem(hasVideo: false, caption: ''), // TODO: isi caption
        _EduItem(hasVideo: false, caption: ''), // TODO: isi caption
      ],
    ),
    _EduSection(
      title: 'Cara Membuat Eco Enzim',
      items: [
        _EduItem(hasVideo: false, caption: ''), // TODO: isi caption
        _EduItem(hasVideo: false, caption: ''), // TODO: isi caption
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
          const _HeroBanner(),
          const SizedBox(height: 12),
          const _IntroCard(),
          const SizedBox(height: 4),
          ..._sections.map((s) => _SectionBlock(section: s)),
        ],
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green900, AppColors.green700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.heroShadow,
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
                    style: TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
                  '', // TODO: isi deskripsi singkat hero banner
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

// ── Intro card dengan expand/collapse ─────────
class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            'Tentang Eco Enzim',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Eco Enzim adalah cairan serbaguna hasil fermentasi limbah organik seperti kulit buah dan sayuran, gula merah, dan air. Dapat digunakan sebagai pupuk, pembersih alami, hingga pestisida organik.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Section model ─────────────────────────────
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

// ── Section block ─────────────────────────────
class _SectionBlock extends StatelessWidget {
  final _EduSection section;
  const _SectionBlock({super.key, required this.section});

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
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.green500, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.2,
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

// ── Card item 16:9 + caption ──────────────────
class _EduItemCard extends StatelessWidget {
  final _EduItem item;
  final int index;
  const _EduItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail 16:9
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // TODO: ganti Container dengan:
                  // Image.network('url', fit: BoxFit.cover, width: double.infinity)
                  // atau Image.asset('assets/images/nama.jpg', fit: BoxFit.cover)
                  Container(color: AppColors.green50),
                  if (item.hasVideo)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.green500.withOpacity(0.88),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 30),
                    )
                  else
                    Icon(Icons.image_outlined,
                        size: 40,
                        color: AppColors.green500.withOpacity(0.3)),
                ],
              ),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: item.caption.isNotEmpty
                ? Text(
                    item.caption,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.text2, height: 1.6),
                  )
                : Text(
                    'Caption',
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