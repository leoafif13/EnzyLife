import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class ArtikelTersimpanScreen extends StatelessWidget {
  const ArtikelTersimpanScreen({super.key});

  // TODO: ganti dengan data dari API/database
  static const _saved = [
    _SavedArticle(
      id: 'a1',
      title: 'Kegiatan Membuat Eco Enzim di SDN 010 Batam',
      author: 'Admin',
      date: '09 Apr 2026',
    ),
    _SavedArticle(
      id: 'a2',
      title: 'Manfaat Eco Enzim untuk Lingkungan Sekitar',
      author: 'Admin',
      date: '05 Apr 2026',
    ),
    _SavedArticle(
      id: 'a3',
      title: 'Cara Mudah Membuat Eco Enzim di Rumah',
      author: 'Admin',
      date: '01 Apr 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Artikel Tersimpan'),
      body: _saved.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _saved.length,
              itemBuilder: (_, i) => _SavedArticleCard(article: _saved[i]),
            ),
    );
  }
}

class _SavedArticle {
  final String id, title, author, date;
  const _SavedArticle({
    required this.id, required this.title,
    required this.author, required this.date,
  });
}

class _SavedArticleCard extends StatelessWidget {
  final _SavedArticle article;
  const _SavedArticleCard({super.key, required this.article});

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
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 90, height: 90,
                color: AppColors.green50,
                child: Icon(Icons.image_outlined, size: 28,
                    color: AppColors.green500.withOpacity(0.3)),
                // TODO: ganti dengan Image.network(url) / Image.asset
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.text1, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(article.author,
                            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(article.date,
                            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Baca selengkapnya →',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: AppColors.green500)),
                        GestureDetector(
                          onTap: () {}, // TODO: hapus dari tersimpan
                          child: Icon(Icons.bookmark_rounded,
                              size: 18, color: AppColors.green500),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.bookmark_outline_rounded, size: 36, color: AppColors.green500),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada artikel tersimpan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 6),
          Text('Simpan artikel favoritmu agar mudah dibaca lagi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}