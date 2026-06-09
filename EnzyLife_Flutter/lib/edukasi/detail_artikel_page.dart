import 'package:flutter/material.dart';
import '../models/artikel.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';


class DetailArtikelPage extends StatelessWidget {
  final ArtikelModel item;
  const DetailArtikelPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final body = item.isiKonten;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: item.kategori,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'http://127.0.0.1:8000/gambar/${item.gambar}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: AppColors.green50,
                          child: Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: AppColors.green500.withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: 14,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.kategori,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                  Text(item.judul,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.text1, height: 1.3)),
                  const SizedBox(height: 12),

                  // Meta
                  Row(
                    children: [
                      _MetaBadge(icon: Icons.person_outline, label: 'Admin'),
                      const SizedBox(width: 12),
                      _MetaBadge(icon: Icons.calendar_today_outlined, label: item.createdAt.split('T')[0]),
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
                          child: Text(item.ringkasan,
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
                    children: ['Eco Enzim', item.kategori, 'EnzyLife']
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