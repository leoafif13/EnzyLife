import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import 'artikel_page.dart';

// ══════════════════════════════════════════════
//  Model slide infografik
// ══════════════════════════════════════════════
class _Slide {
  final String judul, caption, imageAsset;
  const _Slide({required this.judul, required this.caption, required this.imageAsset});
}

// ══════════════════════════════════════════════
//  Data per infografik
// ══════════════════════════════════════════════
const _data = {
  'i1': [
    _Slide(
      judul: 'Perbandingan Bahan: 1 : 3 : 10',
      imageAsset: 'assets/images/infografik/pembuatan_rasio.png',
      caption: 'Gunakan perbandingan 1 bagian gula merah, 3 bagian kulit buah segar, dan 10 bagian air bersih. Hindari air PAM — gunakan air sumur atau galon yang bebas klorin.',
    ),
    _Slide(
      judul: 'Cara Menyiapkan Wadah yang Benar',
      imageAsset: 'assets/images/infografik/pembuatan_wadah.png',
      caption: 'Gunakan wadah plastik bertutup rapat. Isi hanya 80% — sisakan ruang untuk gas fermentasi. Jangan gunakan wadah logam karena dapat bereaksi dengan asam organik.',
    ),
    _Slide(
      judul: 'Jadwal Perawatan Selama Fermentasi',
      imageAsset: 'assets/images/infografik/pembuatan_jadwal.png',
      caption: 'Bulan 1: buka tutup setiap hari untuk melepas gas. Bulan 2: cukup 3x seminggu. Bulan 3: seminggu sekali. Setelah 3 bulan, saring dan simpan di botol gelap.',
    ),
  ],
  'i2': [
    _Slide(
      judul: 'Eco Enzim sebagai Pupuk Cair Organik',
      imageAsset: 'assets/images/infografik/manfaat_pupuk.png',
      caption: 'Encerkan 30ml eco enzim ke dalam 1 liter air, semprotkan ke tanah atau daun 2-3x seminggu. Tanaman lebih subur karena enzim aktif meningkatkan aktivitas mikroba tanah.',
    ),
    _Slide(
      judul: 'Pembersih Rumah Tanpa Bahan Kimia',
      imageAsset: 'assets/images/infografik/manfaat_pembersih.png',
      caption: 'Campurkan 1 sdm eco enzim dalam 1 liter air hangat. Efektif membersihkan lantai, wastafel, dan permukaan dapur. Bebas racun, aman untuk keluarga dan hewan peliharaan.',
    ),
    _Slide(
      judul: 'Pestisida Alami Anti Hama',
      imageAsset: 'assets/images/infografik/manfaat_pestisida.png',
      caption: 'Semprotkan langsung ke tanaman yang terkena hama. Senyawa ozon (O3) dalam eco enzim efektif mengusir kutu daun, ulat, dan serangga pengganggu tanpa merusak ekosistem.',
    ),
  ],
  'i3': [
    _Slide(
      judul: 'Kulit Sitrus — Bahan Terbaik ⭐⭐⭐',
      imageAsset: 'assets/images/infografik/bahan_sitrus.png',
      caption: 'Kulit jeruk, lemon, dan limau kaya limonene dan flavonoid. Menghasilkan eco enzim beraroma segar dengan aktivitas antimikroba tertinggi. Sangat direkomendasikan untuk pemula.',
    ),
    _Slide(
      judul: 'Kulit Nanas & Pepaya — Pilihan Unggulan ⭐⭐⭐',
      imageAsset: 'assets/images/infografik/bahan_nanas.png',
      caption: 'Kulit nanas mengandung bromelain yang mempercepat fermentasi. Kulit pepaya kaya papain. Keduanya cocok dicampur dengan sitrus untuk hasil eco enzim yang lebih aktif secara enzimatis.',
    ),
    _Slide(
      judul: 'Bahan yang HARUS Dihindari ❌',
      imageAsset: 'assets/images/infografik/bahan_hindari.png',
      caption: 'Jangan pernah menggunakan daging, ikan, atau bahan hewani — fermentasinya akan menghasilkan bau busuk yang sangat menyengat dan tidak dapat digunakan. Gunakan hanya limbah nabati segar.',
    ),
  ],
};

// Semua infografik untuk rekomendasi
const _allItems = [
  ArtikelItem(
    id: 'i1', title: 'Infografik: Proses Pembuatan Eco Enzim',
    author: 'Admin', date: '07 Apr 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Panduan visual langkah demi langkah membuat eco enzim dari kulit buah, gula merah, dan air dengan rasio 1:3:10.',
    isInfografik: true,
  ),
  ArtikelItem(
    id: 'i2', title: 'Infografik: Manfaat Eco Enzim dalam 1 Halaman',
    author: 'Admin', date: '03 Apr 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Rangkuman lengkap semua manfaat eco enzim disajikan dalam satu infografik menarik.',
    isInfografik: true,
  ),
  ArtikelItem(
    id: 'i3', title: 'Infografik: Perbandingan Bahan Organik untuk Eco Enzim',
    author: 'Admin', date: '25 Mar 2026', category: 'Infografik', readTime: '1 menit',
    excerpt: 'Tidak semua sampah dapur cocok untuk eco enzim. Infografik ini membandingkan kualitas dari berbagai bahan organik.',
    isInfografik: true,
  ),
];

// ══════════════════════════════════════════════
//  DetailInfografikPage
// ══════════════════════════════════════════════
class DetailInfografikPage extends StatelessWidget {
  final ArtikelItem item;
  const DetailInfografikPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final slides = _data[item.id] ?? [];
    final rekomendasi = _allItems.where((x) => x.id != item.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Infografik',
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded,
                color: AppColors.text1, size: 22),
            onPressed: () {}, // TODO: simpan
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.text1, size: 22),
            onPressed: () {}, // TODO: share
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header info ─────────────────────
            Container(
              color: AppColors.bgCard,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Infografik',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0))),
                  ),
                  const SizedBox(height: 10),
                  Text(item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: AppColors.text1, height: 1.3)),
                  const SizedBox(height: 10),
                  // Meta: author + tanggal
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.green500),
                      const SizedBox(width: 4),
                      Text(item.author,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.green500),
                      const SizedBox(width: 4),
                      Text(item.date,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      const Icon(Icons.image_outlined,
                          size: 13, color: AppColors.green500),
                      const SizedBox(width: 4),
                      Text('${slides.length} gambar',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Slides scroll vertikal ───────────
            if (slides.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('Tambahkan gambar infografik',
                      style: TextStyle(fontSize: 13, color: Colors.orange[700],
                          fontStyle: FontStyle.italic)),
                ),
              )
            else
              ...slides.asMap().entries.map((e) =>
                  _SlideCard(slide: e.value, index: e.key, total: slides.length)),

            // ── Divider ──────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider, height: 32),
            ),

            // ── Rekomendasi infografik lain ──────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: const Text('Infografik Lainnya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.text1)),
            ),

            ...rekomendasi.map((info) => _RekomendasiCard(item: info)),
          ],
        ),
      ),
    );
  }
}

// ── Satu slide: judul + gambar + caption ──────
class _SlideCard extends StatelessWidget {
  final _Slide slide;
  final int index, total;
  const _SlideCard({
    super.key, required this.slide,
    required this.index, required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul slide + nomor
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor slide
                Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(
                      color: AppColors.green500, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(slide.judul,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.text1, height: 1.3)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${ index + 1}/$total',
                      style: const TextStyle(fontSize: 10, color: AppColors.green700,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Gambar poster
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: AspectRatio(
              aspectRatio: 3 / 4, // portrait — khas infografik
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: index % 2 == 0
                            ? [AppColors.green50, const Color(0xFFDCEDC8)]
                            : [const Color(0xFFE8F5E9), AppColors.green50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // TODO: ganti Column placeholder ini dengan:
                  // Image.asset(slide.imageAsset, fit: BoxFit.contain,
                  //   width: double.infinity, height: double.infinity)
                  // atau Image.network(url, fit: BoxFit.contain)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 56,
                          color: AppColors.green500.withOpacity(0.25)),
                      const SizedBox(height: 8),
                      Text('Gambar Infografik ${index + 1}',
                          style: TextStyle(fontSize: 13,
                              color: AppColors.green700.withOpacity(0.5))),
                      const SizedBox(height: 4),
                      Text('assets: ${slide.imageAsset.split('/').last}',
                          style: TextStyle(fontSize: 10,
                              color: Colors.grey[400], fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Caption
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                      color: AppColors.green500, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('i',
                        style: TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(slide.caption,
                      style: const TextStyle(fontSize: 13, color: AppColors.green900,
                          height: 1.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card rekomendasi infografik lain ──────────
class _RekomendasiCard extends StatelessWidget {
  final ArtikelItem item;
  const _RekomendasiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final slides = _data[item.id] ?? [];

    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DetailInfografikPage(item: item))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail kecil
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 90, height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green900, AppColors.green700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26),
                    const SizedBox(height: 4),
                    Text('${slides.length} slide',
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
                // TODO: ganti dengan thumbnail gambar pertama slide
              ),
            ),
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
                    const SizedBox(height: 6),
                    Text(item.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.text1, height: 1.3)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.grey[400]),
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