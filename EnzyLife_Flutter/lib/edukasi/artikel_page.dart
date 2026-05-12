import 'package:flutter/material.dart';
import '/app_color.dart';
import '/widgets/sub_page_appbar.dart';
import 'detail_artikel_page.dart';
import 'detail_infografik_page.dart';

// ══════════════════════════════════════════════
//  Model
// ══════════════════════════════════════════════
class ArtikelItem {
  final String id, title, author, date, category, readTime, excerpt;
  final bool isInfografik;
  const ArtikelItem({
    required this.id, required this.title, required this.author,
    required this.date, required this.category, required this.readTime,
    required this.excerpt, this.isInfografik = false,
  });
}

// ══════════════════════════════════════════════
//  Data konten
// ══════════════════════════════════════════════
const _allContent = [
  ArtikelItem(
    id: 'a1',
    title: 'Mengenal Eco Enzim: Cairan Ajaib dari Sampah Dapur',
    author: 'Admin', date: '09 Apr 2026', category: 'Pengenalan', readTime: '5 menit',
    excerpt: 'Eco enzim adalah cairan hasil fermentasi sampah organik yang memiliki segudang manfaat. Pelajari cara membuatnya dari nol dengan bahan-bahan sederhana di rumah.',
  ),
  ArtikelItem(
    id: 'a2',
    title: '7 Manfaat Eco Enzim yang Jarang Diketahui',
    author: 'Admin', date: '05 Apr 2026', category: 'Manfaat', readTime: '4 menit',
    excerpt: 'Selain sebagai pupuk, eco enzim ternyata bisa digunakan untuk membersihkan lantai, membasmi hama, bahkan sebagai pengharum ruangan alami yang ramah lingkungan.',
  ),
  ArtikelItem(
    id: 'a3',
    title: 'Kegiatan Membuat Eco Enzim di SDN 010 Batam',
    author: 'Admin', date: '01 Apr 2026', category: 'Kegiatan', readTime: '3 menit',
    excerpt: 'Siswa SDN 010 Batam antusias mengikuti kegiatan pembuatan eco enzim sebagai bagian dari program pendidikan lingkungan hidup yang digagas oleh Tim EnzyLife.',
  ),
  ArtikelItem(
    id: 'a4',
    title: 'Perbandingan Eco Enzim vs Pupuk Kimia untuk Tanaman',
    author: 'Admin', date: '28 Mar 2026', category: 'Pertanian', readTime: '6 menit',
    excerpt: 'Apakah eco enzim benar-benar lebih efektif dibanding pupuk kimia? Kami melakukan uji coba selama 30 hari pada tanaman cabai dan tomat. Hasilnya mengejutkan.',
  ),
  ArtikelItem(
    id: 'a5',
    title: 'Tips Fermentasi Eco Enzim agar Tidak Gagal',
    author: 'Admin', date: '20 Mar 2026', category: 'Tips', readTime: '4 menit',
    excerpt: 'Banyak pemula gagal membuat eco enzim karena kesalahan kecil yang bisa dihindari. Berikut 8 tips praktis agar fermentasi berhasil sempurna sejak percobaan pertama.',
  ),
  ArtikelItem(
    id: 'i1',
    title: 'Infografik: Proses Pembuatan Eco Enzim',
    author: 'Admin', date: '07 Apr 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Panduan visual langkah demi langkah membuat eco enzim dari kulit buah, gula merah, dan air dengan rasio 1:3:10.',
    isInfografik: true,
  ),
  ArtikelItem(
    id: 'i2',
    title: 'Infografik: Manfaat Eco Enzim dalam 1 Halaman',
    author: 'Admin', date: '03 Apr 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Rangkuman lengkap semua manfaat eco enzim — dari pertanian, kebersihan rumah, hingga lingkungan — disajikan dalam satu infografik menarik.',
    isInfografik: true,
  ),
  ArtikelItem(
    id: 'i3',
    title: 'Infografik: Perbandingan Bahan Organik untuk Eco Enzim',
    author: 'Admin', date: '25 Mar 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Tidak semua sampah dapur cocok untuk eco enzim. Infografik ini membandingkan kualitas hasil dari berbagai jenis bahan organik yang umum tersedia.',
    isInfografik: true,
  ),
];

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
  _Filter _filter    = _Filter.semua;
  String  _query     = '';
  final   _search    = TextEditingController();

  List<ArtikelItem> get _filtered {
    var list = _allContent.where((item) {
      if (_filter == _Filter.artikel    && item.isInfografik) return false;
      if (_filter == _Filter.infografik && !item.isInfografik) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
               item.excerpt.toLowerCase().contains(q) ||
               item.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
    return list;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

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
            child: items.isEmpty
                ? _EmptyState(query: _query, filter: _filter)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => items[i].isInfografik
                        ? _InfografikCard(item: items[i])
                        : _ArtikelCard(item: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Artikel card ──────────────────────────────
class _ArtikelCard extends StatelessWidget {
  final ArtikelItem item;
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: AppColors.green50),
                    // TODO: ganti dengan Image.network(url) / Image.asset(path)
                    Icon(Icons.article_outlined, size: 44,
                        color: AppColors.green500.withOpacity(0.25)),
                    // Badge kategori
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(item.category,
                            style: const TextStyle(color: Colors.white, fontSize: 10,
                                fontWeight: FontWeight.w600)),
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
                  Text(item.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.text1, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(item.excerpt,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(item.author,
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(item.readTime,
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      const Spacer(),
                      Text(item.date,
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
  final ArtikelItem item;
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.green900, AppColors.green700],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 30),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('INFO', style: TextStyle(color: Colors.white,
                              fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    // TODO: ganti dengan Image.network(url) / Image.asset
                  ],
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
                    Text(item.title,
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.text1, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(item.excerpt,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(item.date,
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