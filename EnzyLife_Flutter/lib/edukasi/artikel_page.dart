import 'package:flutter/material.dart';
import '/app_color.dart';
import '/widgets/sub_page_appbar.dart';
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

  List<ArtikelModel> _artikel = [];
  List<InfografikModel> _infografik = [];
  bool _isLoading = true;

  @override
    void dispose() {
      _search.dispose();
      super.dispose();
    }

  @override
  void initState() {
    super.initState();
    fetchArtikel();
  }

  Future<void> fetchArtikel() async {

    final artikel = await ApiService.getArtikel();
    final infografik = await ApiService.getInfografik();


    setState(() {
      _artikel = artikel;
      _infografik = infografik;
      _isLoading = false;
    });
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

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Artikel & Infografik'),
      body: Column(
        children: [
          // ── Header card ──────────────────────
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text('Artikel & Infografik',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.text1)),
                  const SizedBox(height: 6),
                  Text('Kumpulan artikel dan infografik seputar Eco Enzim',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),
          ),

          // ── Search bar ───────────────────────
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 14, color: AppColors.text1),
              decoration: InputDecoration(
                hintText: 'Cari artikel atau infografik...',
                hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.hint),
                        onPressed: () { setState(() => _query = ''); _search.clear(); })
                    : null,
                filled: true,
                fillColor: AppColors.bgPage,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // ── Filter tabs ──────────────────────
          Container(
            color: AppColors.bgCard,
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
                    onTap: () => setState(() => _filter = f),
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

          const Divider(height: 1, color: AppColors.divider),

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
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        children: content,
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailArtikelPage(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
                child:  Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      'http://localhost:8000/gambar/${item.gambar}',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: AppColors.green50,
                          child: Icon(
                            Icons.article_outlined,
                            size: 44,
                            color: AppColors.green500.withOpacity(0.25),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.kategori,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.judul,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.text1, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(item.ringkasan,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('Admin',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      const Spacer(),
                      Text(item.createdAt.split('T')[0],
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailInfografikPage(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail kiri — portrait style
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 100, height: 120,
                color: const Color(0xFFE8F5E9),
                child: Image.network(
                        'http://localhost:8000/gambar/${item.gambar}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppColors.green50,
                            child: Icon(
                              Icons.article_outlined,
                              size: 44,
                              color: AppColors.green500.withOpacity(0.25),
                            ),
                          );
                        },
                      ),
              ),
            ),
            // Konten kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Infografik',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0))),
                    ),
                    const SizedBox(height: 8),
                    Text(item.judul,
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.text1, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(item.deskripsi,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(item.createdAt.split('T')[0],
                            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                        const Spacer(),
                        const Text('Lihat →',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: AppColors.green500)),
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