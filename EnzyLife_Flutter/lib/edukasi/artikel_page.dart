import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import '../widgets/search_bar_field.dart';
import 'detail_artikel_page.dart';
import 'detail_infografik_page.dart';
import '../models/artikel.dart';
import '../models/infografik.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════
//  Filter enum
// ══════════════════════════════════════════════
enum _Filter { semua, artikel, infografik }

// ══════════════════════════════════════════════
//  ArtikelScreen
// ══════════════════════════════════════════════
class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  _Filter _filter = _Filter.semua;
  String _query = '';
  final _search = TextEditingController();
  late final ScrollController _scrollController;
  int _limit = 5;

  List<ArtikelModel> _artikel = [];
  List<InfografikModel> _infografik = [];
  bool _isLoading = true;

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchArtikel();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final totalCount = _calculateTotalCount();
    if (_limit < totalCount) {
      setState(() {
        _limit += 5;
      });
    }
  }

  int _calculateTotalCount() {
    final filteredArtikelCount = _artikel.where((item) {
      if (_query.isEmpty) return true;
      return item.judul.toLowerCase().contains(_query.toLowerCase()) ||
          item.ringkasan.toLowerCase().contains(_query.toLowerCase());
    }).length;

    final filteredInfografikCount = _infografik.where((item) {
      if (_query.isEmpty) return true;
      return item.judul.toLowerCase().contains(_query.toLowerCase()) ||
          item.deskripsi.toLowerCase().contains(_query.toLowerCase());
    }).length;

    int total = 0;
    if (_filter != _Filter.infografik) total += filteredArtikelCount;
    if (_filter != _Filter.artikel) total += filteredInfografikCount;
    return total;
  }

  Future<void> fetchArtikel() async {
    // Cache-first loading
    if (ApiService.cachedArtikel.isNotEmpty || ApiService.cachedInfografik.isNotEmpty) {
      setState(() {
        _artikel = ApiService.cachedArtikel;
        _infografik = ApiService.cachedInfografik;
        _isLoading = false;
      });
    }

    try {
      final artikel = await ApiService.getArtikel();
      final infografik = await ApiService.getInfografik();

      if (mounted) {
        setState(() {
          _artikel = artikel;
          _infografik = infografik;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final filteredArtikel = _artikel.where((item) {
      if (_query.isEmpty) return true;

      return item.judul.toLowerCase().contains(_query.toLowerCase()) ||
          item.ringkasan.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    final filteredInfografik = _infografik.where((item) {
      if (_query.isEmpty) return true;

      return item.judul.toLowerCase().contains(_query.toLowerCase()) ||
          item.deskripsi.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    final List<Widget> content = [];

    if (_filter != _Filter.infografik) {
      content.addAll(
        filteredArtikel.map((item) => _ArtikelCard(item: item)),
      );
    }

    if (_filter != _Filter.artikel) {
      content.addAll(
        filteredInfografik.map((item) => _InfografikCard(item: item)),
      );
    }

    final totalContent = content.length;
    final showLoadingFooter = totalContent > _limit;
    final visibleContent = content.take(_limit).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Artikel & Infografik'),
      body: Column(
        children: [
          // ── Header card ──────────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: const PageHeaderCard(
              badge: '📚  Artikel',
              title: 'Artikel & Infografik',
              subtitle: 'Kumpulan artikel dan infografik seputar Eco Enzim',
              icon: Icons.article_outlined,
            ),
          ),

          // ── Search bar ───────────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SearchBarField(
              controller: _search,
              hintText: 'Cari artikel atau infografik...',
              onChanged: (v) => setState(() {
                _query = v;
                _limit = 5;
              }),
              showClearButton: _query.isNotEmpty,
              onClear: () {
                setState(() {
                  _query = '';
                  _limit = 5;
                });
                _search.clear();
              },
            ),
          ),

          // ── Filter tabs ──────────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: _Filter.values.map((f) {
                final active = _filter == f;
                final label  = f == _Filter.semua ? 'Semua'
                             : f == _Filter.artikel ? 'Artikel' : 'Infografik';
                final icon   = f == _Filter.semua ? Icons.grid_view_rounded
                             : f == _Filter.artikel ? Icons.article_outlined
                             : Icons.image_outlined;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _filter = f;
                      _limit = 5;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppColors.green500 : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active ? AppColors.green500 : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14,
                              color: active ? Colors.white : AppColors.text2),
                          const SizedBox(width: 5),
                          Text(label,
                              style: TextStyle(fontSize: 12,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                  color: active ? Colors.white : AppColors.text2)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── List konten ──────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : content.isEmpty
                    ? _EmptyState(
                        query: _query,
                        filter: _filter,
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...visibleContent,
                          if (showLoadingFooter)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
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

// ── Artikel card ──────────────────────────────
class _ArtikelCard extends StatelessWidget {
  final ArtikelModel item;
  const _ArtikelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressCard(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailArtikelPage(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail 16:9 with Hero
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: 'http://127.0.0.1:8000/gambar/${item.gambar}',
                  child: Image.network(
                    'http://127.0.0.1:8000/gambar/${item.gambar}',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.green50,
                        child: Icon(
                          Icons.article_outlined,
                          size: 44,
                          color: AppColors.green500.withAlpha(50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag above title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.kategori.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.green700,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    item.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Summary
                  Text(
                    item.ringkasan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),

                  // Metadata Row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.text3),
                      const SizedBox(width: 4),
                      Text(
                        item.createdAt.split('T')[0],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text3,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Baca Selengkapnya →',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Infografik card (landscape, lebih tinggi) ─
class _InfografikCard extends StatelessWidget {
  final InfografikModel item;
  const _InfografikCard({required this.item});
  
  @override
  Widget build(BuildContext context) {
    return _AnimatedPressCard(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailInfografikPage(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withAlpha(80)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail left with Hero
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 105,
                height: 135,
                child: Hero(
                  tag: 'http://127.0.0.1:8000/gambar/${item.gambar}',
                  child: Image.network(
                    'http://127.0.0.1:8000/gambar/${item.gambar}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.green50,
                        child: Icon(
                          Icons.article_outlined,
                          size: 36,
                          color: AppColors.green500.withAlpha(50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Right Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge info blue
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined, size: 11, color: Color(0xFF1565C0)),
                          SizedBox(width: 4),
                          Text(
                            'INFOGRAFIK',
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Footer Row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.text3),
                        const SizedBox(width: 4),
                        Text(
                          item.createdAt.split('T')[0],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text3,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Lihat →',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green500,
                          ),
                        ),
                      ],
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

// ── Tactile Press Scale Animation Wrapper ─────
class _AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<_AnimatedPressCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  final _Filter filter;
  const _EmptyState({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 34, color: AppColors.green500),
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty
                ? 'Tidak ada hasil untuk "$query"'
                : filter == _Filter.artikel
                    ? 'Belum ada artikel tersedia'
                    : filter == _Filter.infografik
                        ? 'Belum ada infografik tersedia'
                        : 'Belum ada konten tersedia',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.text1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text('Coba kata kunci lain atau ubah filter',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}