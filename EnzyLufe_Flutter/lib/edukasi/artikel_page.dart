import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  int _perPage = 5;

  // TODO: ganti dengan data artikel dari API / database
  static const _articles = [
    _Article(title: 'Kegiatan Menanam Tumbuhan dan Membuat Eco Enzim', author: 'Admin'),
    _Article(title: 'Manfaat Eco Enzim untuk Lingkungan Sekitar',       author: 'Admin'),
    _Article(title: 'Cara Mudah Membuat Eco Enzim di Rumah',            author: 'Admin'),
    _Article(title: 'Eco Enzim sebagai Pembersih Alami',                author: 'Admin'),
    _Article(title: 'Sejarah dan Asal Usul Eco Enzim',                  author: 'Admin'),
    _Article(title: 'Tips Menyimpan Eco Enzim dengan Benar',            author: 'Admin'),
    _Article(title: 'Eco Enzim untuk Pertanian Organik',                author: 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = _articles.take(_perPage).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Artikel & Infografik'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'Artikel',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // TODO: ganti dengan deskripsi artikel
                    'Kumpulan artikel informatif seputar Eco Enzim. Dapatkan wawasan, tips, dan informasi terbaru yang disajikan secara akurat dan mudah dipahami.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter per halaman
            Row(
              children: [
                const Text(
                  'Tampilkan',
                  style: TextStyle(fontSize: 13, color: AppColors.text2),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _perPage,
                      isDense: true,
                      items: [5, 10, 20]
                          .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text('$v', style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _perPage = v ?? 5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'per halaman',
                  style: TextStyle(fontSize: 13, color: AppColors.text2),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Daftar artikel
            ...shown.map((a) => _ArticleCard(article: a)),

            // Load more
            if (_perPage < _articles.length)
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _perPage += 5),
                  child: const Text(
                    'Tampilkan lebih banyak',
                    style: TextStyle(
                      color: AppColors.green500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Article {
  final String title;
  final String author;
  const _Article({required this.title, required this.author});
}

class _ArticleCard extends StatelessWidget {
  final _Article article;
  const _ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: navigasi ke detail artikel
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
                    // TODO: ganti dengan Image.network(url) atau Image.asset(path)
                    Container(color: AppColors.green50),
                    Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: AppColors.green500.withOpacity(0.3),
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
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            article.author,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const Text(
                        'Baca selengkapnya →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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