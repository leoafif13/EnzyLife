import 'package:flutter/material.dart';
import '../app_color.dart';
import 'artikel_page.dart';
import 'kalkulator_page.dart';
import 'faq_page.dart';
import '../widgets/page_header_card.dart';
import '../widgets/zoomable_image_dialog.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
        _EduItem(
          hasVideo: true,
          caption: 'Video Edukasi Eco Enzyme',
          videoId: 'EwvJbebrlbk',
        ),
      ],
    ),

    _EduSection(
      title: 'Manfaat Eco Enzim',
      items: [
        _EduItem(
          hasVideo: false,
          image: 'assets/images/edukasi/eco1.jpg',
          caption:
              'Kenapa Harus Menggunakan Eco Enzim\n\nKarena kandungannya, eco Enzyme memiliki banyak cara untuk membantu siklus alam seperti memudahkan pertumbuhan tanaman (sebagai fertilizer), mengobati tanah dan juga membersihkan air yang tercemar. Selain itu bisa juga ditambahkan ke produk pembersih rumah tangga seperti shampoo, pencuci piring, deterjen, dll.\n\nPembersih enzim ini 100% natural dan bebas dari bahan kimia, mudah terurai dan lembut di tangan dan lingkungan. Cairan ini juga penolak serangga alami yang membuat semut, serangga dll menjauh. Saking alaminya, setelah digunakan untuk pel, cairan ini juga bisa dipakai untuk menyiram tanaman. Eco Enzyme juga dapat digunakan untuk merangsang hormon tanaman untuk meningkatkan kualitas buah dan sayuran dan untuk meningkatkan hasil panen.',
        ),
      ],
    ),

    _EduSection(
      title: 'Panduan Pembuatan Eco Enzim',
      items: [
        _EduItem(
          hasVideo: false,
          image: 'assets/images/edukasi/pembuatan.png',
          caption:
              'Campurkan gula merah, bahan organik (kulit buah/sayuran segar), dan air dengan rasio 1:3:10 ke dalam wadah plastik bermulut lebar, lalu fermentasikan selama 3 bulan.',
        ),
      ],
    ),

    _EduSection(
      title: 'Cara Penggunaan Eco Enzim',
      items: [
        _EduItem(
          hasVideo: false,
          image: 'assets/images/edukasi/penggunaan-benar.png',
          caption:
              'Campurkan Eco Enzim dengan air sesuai kebutuhan sebelum digunakan sebagai pembersih.',
        ),
        _EduItem(
          hasVideo: false,
          image: 'assets/images/edukasi/penggunaan-salah.png',
          caption:
              'Eco Enzim juga dapat digunakan sebagai pupuk cair dengan pengenceran yang tepat.',
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: PageHeaderCard(
              badge: '🌿  Edukasi',
              title: 'Tentang Eco Enzim',
              subtitle: 'Eco Enzim adalah cairan serbaguna hasil fermentasi limbah organik seperti kulit buah dan sayuran, gula merah, dan air. Dapat digunakan sebagai pupuk, pembersih alami, hingga pestisida organik.',
              icon: Icons.eco_rounded,
            ),
          ),
          const SizedBox(height: 4),
          ..._sections.map((s) => _SectionBlock(section: s)),
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
  final String? videoId;
  final String? image;

  const _EduItem({
    required this.hasVideo,
    required this.caption,
    this.videoId,
    this.image,
  });
}

// ── Section block ─────────────────────────────
class _SectionBlock extends StatelessWidget {
  final _EduSection section;
  const _SectionBlock({required this.section});

  IconData _getSectionIcon(String title) {
    if (title.toLowerCase().contains('mengenal')) return Icons.menu_book_rounded;
    if (title.toLowerCase().contains('manfaat')) return Icons.spa_outlined;
    if (title.toLowerCase().contains('pembuatan')) return Icons.science_outlined;
    if (title.toLowerCase().contains('cara')) return Icons.integration_instructions_outlined;
    return Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getSectionIcon(section.title);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.green700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
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
class _EduItemCard extends StatefulWidget {
  final _EduItem item;
  final int index;
  const _EduItemCard({required this.item, required this.index});

  @override
  State<_EduItemCard> createState() => _EduItemCardState();
}

class _EduItemCardState extends State<_EduItemCard> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.item.hasVideo && widget.item.videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.item.videoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
          origin: 'https://www.youtube-nocookie.com',
          userAgent: 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail 16:9
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.item.hasVideo && _controller != null
                ? YoutubePlayer(controller: _controller!)
                : widget.item.image != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: widget.item.image!,
                              child: Image.asset(
                                widget.item.image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              onTap: () => openFullscreenImage(context, widget.item.image!, isNetwork: false),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(140),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(color: Colors.black12),
            ),
          ),

          // Caption & badge info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge indicator
                if (widget.item.hasVideo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, color: Color(0xFFC62828), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'VIDEO EDUKASI',
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: AppColors.green700, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'PANDUAN & MANFAAT',
                          style: TextStyle(
                            color: AppColors.green900,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                // Caption text
                widget.item.caption.isNotEmpty
                    ? (widget.item.caption.contains('Kenapa Harus Menggunakan Eco Enzim')
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kenapa Harus Menggunakan Eco Enzim',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.item.caption.replaceAll('Kenapa Harus Menggunakan Eco Enzim\n\n', '').replaceAll('Kenapa Harus Menggunakan Eco Enzim\n', ''),
                                style: const TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text2, 
                                    height: 1.6),
                              ),
                            ],
                          )
                        : Text(
                            widget.item.caption,
                            style: const TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.w500,
                                color: AppColors.text2, 
                                height: 1.6),
                          ))
                    : Text(
                        'Informasi edukasi lengkap mengenai eco enzyme.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
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
