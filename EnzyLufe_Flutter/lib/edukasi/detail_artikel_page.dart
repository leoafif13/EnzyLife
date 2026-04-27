import 'package:flutter/material.dart';
import '/app_color.dart';
import '/widgets/sub_page_appbar.dart';
import 'artikel_page.dart';

class DetailArtikelPage extends StatelessWidget {
  final ArtikelItem item;
  const DetailArtikelPage({super.key, required this.item});

  // Konten artikel per id
  static const _bodies = {
    'a1': '''
Eco enzim adalah cairan multifungsi yang dihasilkan dari proses fermentasi tiga bahan utama: limbah organik (kulit buah dan sayuran), gula merah atau molase, dan air bersih. Proses fermentasi berlangsung selama minimal tiga bulan sebelum cairan siap digunakan.

Istilah "eco enzim" pertama kali dipopulerkan oleh Dr. Rosukon Poompanvong dari Thailand pada tahun 1980-an. Beliau menemukan bahwa cairan fermentasi ini mengandung enzim-enzim aktif yang bermanfaat bagi tanah, tanaman, dan lingkungan sekitar.

**Mengapa Disebut "Ajaib"?**

Pertama, bahan bakunya adalah sampah dapur yang biasanya langsung dibuang. Kedua, prosesnya sangat sederhana — cukup mencampur bahan dengan perbandingan yang tepat dan menunggu. Ketiga, manfaat yang dihasilkan sangat beragam, mulai dari pupuk organik, pembersih alami, hingga pengusir serangga.

**Komposisi dan Rasio**

Rumus dasar eco enzim menggunakan perbandingan 1:3:10, yaitu:
- 1 bagian gula merah (sebagai sumber energi bagi mikroorganisme)
- 3 bagian limbah organik segar (kulit buah, sayuran)
- 10 bagian air bersih (bukan air mengandung klorin)

Campuran ini kemudian difermentasi dalam wadah tertutup, dengan sedikit ruang udara untuk proses gasifikasi alami.

**Proses Fermentasi**

Pada bulan pertama, campuran akan menghasilkan gas akibat aktivitas mikroorganisme. Pastikan membuka tutup wadah setiap hari untuk melepas gas agar tidak meledak. Pada bulan kedua dan ketiga, bau mulai berubah dari asam menjadi aroma buah yang khas, tanda fermentasi berjalan dengan baik.

Setelah tiga bulan, saring cairan dari ampasnya. Cairan jernih kecokelatan yang dihasilkan itulah eco enzim siap pakai. Ampasnya pun masih bisa dimanfaatkan sebagai kompos.
''',
    'a2': '''
Kebanyakan orang hanya mengenal eco enzim sebagai pupuk tanaman. Padahal, cairan fermentasi ini memiliki lebih dari selusin kegunaan yang sering diabaikan.

**1. Pupuk Cair Organik**
Campurkan 30 ml eco enzim dengan 1 liter air, semprotkan ke tanah atau daun tanaman. Hasilnya, tanaman tumbuh lebih subur karena enzim membantu aktivitas mikroba tanah yang mengurai nutrisi.

**2. Pestisida Alami**
Senyawa ozon (O3) yang terkandung dalam eco enzim efektif mengusir hama seperti kutu daun dan ulat. Semprotkan langsung ke tanaman yang terkena serangan.

**3. Pembersih Lantai**
Campurkan 1 sendok makan eco enzim dengan 1 liter air hangat. Lantai menjadi bersih, bebas kuman, dan aroma segar tanpa bahan kimia berbahaya.

**4. Pengharum Ruangan**
Tuangkan sedikit eco enzim ke diffuser atau semprotkan ke udara. Aromanya yang khas dapat menetralisir bau tidak sedap secara alami.

**5. Deterjen Tambahan**
Tambahkan 2-3 sendok makan ke mesin cuci bersama deterjen biasa. Pakaian lebih bersih dan serat kain lebih terawat.

**6. Perawatan Kulit (Diluted)**
Beberapa pengguna melaporkan manfaat eco enzim encer sebagai toner wajah alami. Namun konsultasikan dengan dokter kulit sebelum mencoba.

**7. Pengolahan Air Limbah**
Di beberapa negara, eco enzim digunakan dalam skala besar untuk mengolah limbah cair domestik sebelum dibuang ke sungai.
''',
    'a3': '''
Rabu pagi, 01 April 2026. Halaman SDN 010 Batam terlihat lebih ramai dari biasanya. Puluhan siswa kelas 4, 5, dan 6 berkumpul di area terbuka dengan meja-meja yang sudah dilengkapi peralatan: toples besar, kulit jeruk dan mangga, gula merah, serta air.

**Awal Mula Program**

Kegiatan ini bermula dari kepedulian kepala sekolah terhadap isu sampah organik yang semakin mengkhawatirkan di Batam. Berkoordinasi dengan Tim EnzyLife, sekolah akhirnya mengadakan workshop sehari penuh tentang pembuatan eco enzim.

**Antusias Luar Biasa**

"Saya tidak menyangka anak-anak sebegitu antusias," ujar salah satu guru pendamping. Mereka berlomba mengupas kulit buah dengan rapi, menimbang bahan sesuai instruksi, dan mencatat setiap langkah di buku tulis masing-masing.

Satu hal yang menarik perhatian: seorang siswa kelas 5 bernama Faiz spontan bertanya, "Bu, berarti sampah di rumah saya bisa jadi pupuk yang berguna?" Pertanyaan sederhana itu menggambarkan perubahan pola pikir yang terjadi.

**Proses Pembuatan**

Setiap kelompok yang terdiri dari 5-6 siswa membuat eco enzim dengan komposisi:
- 300 gram gula merah
- 900 gram kulit buah (jeruk, mangga, pepaya)
- 3 liter air bersih

Toples-toples itu kemudian diberi label nama kelompok dan akan disimpan di sekolah selama tiga bulan. Rencananya, hasilnya akan digunakan untuk menyiram kebun mini sekolah.

**Harapan ke Depan**

Program ini diharapkan bisa berlanjut dan menjadi kurikulum tetap pendidikan lingkungan di sekolah-sekolah lain di Batam. Tim EnzyLife berkomitmen untuk mendampingi siswa selama proses fermentasi berlangsung.
''',
    'a4': '''
Perdebatan antara pupuk organik dan kimia sudah berlangsung lama. Untuk menjawab pertanyaan ini secara empiris, kami melakukan uji coba selama 30 hari menggunakan tiga plot tanaman cabai rawit dengan kondisi tanah dan paparan sinar matahari yang identik.

**Metodologi**

- Plot A: Pupuk kimia NPK (15-15-15) standar
- Plot B: Eco enzim 30 ml / liter, disiram 3 hari sekali
- Plot C: Kontrol (tanpa pupuk)

Setiap plot berisi 10 tanaman dengan bibit dari sumber yang sama.

**Hasil Minggu ke-2**

Plot A menunjukkan pertumbuhan paling cepat — daun lebih hijau dan batang lebih tinggi. Plot B tumbuh lebih lambat tapi daun terlihat lebih tebal dan berkilap. Plot C tumbuh normal tanpa anomali.

**Hasil Minggu ke-4**

Kejutan muncul di akhir uji coba. Plot A memang menghasilkan lebih banyak buah secara kuantitas, tapi ukurannya lebih kecil dan rasa buah sedikit pahit. Plot B menghasilkan lebih sedikit buah, tapi ukuran lebih besar dan rasa jauh lebih pedas serta manis.

**Analisis**

Eco enzim bekerja tidak langsung — ia memperbaiki struktur tanah dan meningkatkan populasi mikroba bermanfaat, sehingga efeknya terasa lebih lama. Pupuk kimia memberikan nutrisi instan yang mempercepat pertumbuhan jangka pendek, tapi bisa mengurangi kualitas buah.

**Kesimpulan**

Untuk hasil optimal, kombinasi keduanya bisa menjadi pilihan: gunakan pupuk kimia di awal tanam, lalu beralih ke eco enzim saat tanaman mulai berbunga.
''',
    'a5': '''
"Eco enzim saya bau busuk, bukan asam manis." Ini adalah keluhan paling sering dari pemula. Kami kumpulkan 8 kesalahan umum dan cara mengatasinya.

**1. Salah Perbandingan**
Ini penyebab paling umum. Banyak yang asal-asalan takaran. Gunakan timbangan dapur, bukan kira-kira. Rasio 1:3:10 (gula:organik:air) adalah harga mati.

**2. Menggunakan Air PAM Langsung**
Air PAM mengandung klorin yang membunuh mikroorganisme baik. Diamkan air PAM selama 12 jam atau gunakan air sumur/galon.

**3. Wadah Tidak Bersih**
Sisa sabun atau deterjen di wadah bisa mengganggu fermentasi. Bilas wadah dengan air panas tanpa sabun sebelum digunakan.

**4. Tidak Cukup Ruang Udara**
Isi wadah maksimal 80% saja. Sisanya untuk ruang gas fermentasi. Kalau penuh, toples bisa meledak atau gasket rusak.

**5. Terlalu Banyak Membuka Tutup**
Buka tutup setiap hari di bulan pertama, tapi jangan lebih dari itu. Kontak berlebihan dengan udara luar bisa mengkontaminasi fermentasi.

**6. Bahan Organik Sudah Membusuk**
Gunakan kulit buah segar, bukan yang sudah berlendir atau berjamur. Bahan busuk akan menghasilkan fermentasi yang salah.

**7. Suhu Terlalu Panas**
Simpan di tempat teduh dengan suhu 25-35°C. Hindari terkena sinar matahari langsung yang membuat suhu dalam wadah melonjak.

**8. Tidak Sabar**
Eco enzim butuh minimal 3 bulan. Banyak yang membuka di bulan kedua karena tidak sabar. Hasilnya tentu belum optimal.
''',
  };

  @override
  Widget build(BuildContext context) {
    final body = _bodies[item.id] ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: item.category,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded,
                color: AppColors.text1, size: 22),
            onPressed: () {}, // TODO: simpan artikel
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.text1, size: 22),
            onPressed: () {}, // TODO: share artikel
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: AppColors.green50),
                  // TODO: ganti dengan Image.network(url) / Image.asset(path)
                  Icon(Icons.article_outlined, size: 64,
                      color: AppColors.green500.withOpacity(0.2)),
                  Positioned(
                    bottom: 14, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.green500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item.category,
                          style: const TextStyle(color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            // Konten
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(item.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.text1, height: 1.3)),
                  const SizedBox(height: 12),

                  // Meta
                  Row(
                    children: [
                      _MetaBadge(icon: Icons.person_outline, label: item.author),
                      const SizedBox(width: 12),
                      _MetaBadge(icon: Icons.schedule_outlined, label: item.readTime),
                      const SizedBox(width: 12),
                      _MetaBadge(icon: Icons.calendar_today_outlined, label: item.date),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),

                  // Excerpt
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.green200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppColors.green500, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.excerpt,
                              style: const TextStyle(fontSize: 13, color: AppColors.green900,
                                  height: 1.6, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Body artikel
                  if (body.isNotEmpty)
                    _ArticleBody(body: body)
                  else
                    Text('Isi konten artikel',
                        style: TextStyle(fontSize: 13, color: Colors.orange[700],
                            fontStyle: FontStyle.italic)),

                  const SizedBox(height: 32),

                  // Tags
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: ['Eco Enzim', item.category, 'EnzyLife']
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.bgPage,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text('#$tag',
                                  style: const TextStyle(fontSize: 12, color: AppColors.text2)),
                            ))
                        .toList(),
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

// ── Meta badge ────────────────────────────────
class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 12, color: Colors.grey[400]),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
    ],
  );
}

// ── Render body teks dengan markdown sederhana ─
class _ArticleBody extends StatelessWidget {
  final String body;
  const _ArticleBody({required this.body});

  @override
  Widget build(BuildContext context) {
    final lines = body.trim().split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(line.replaceAll('**', ''),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 7, right: 8),
                  decoration: const BoxDecoration(color: AppColors.green500, shape: BoxShape.circle)),
              Expanded(child: Text(line.substring(2),
                  style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6))),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line,
              style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.7)),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}