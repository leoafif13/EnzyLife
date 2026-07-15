import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/artikel.dart';
import '../services/format_helper.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/zoomable_image_dialog.dart';
import '../widgets/chatbot_widget.dart';

class DetailArtikelPage extends StatelessWidget {
  final ArtikelModel item;
  const DetailArtikelPage({super.key, required this.item});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final Uri url = Uri.parse(urlString.trim());
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka link: $urlString'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = item.isiKonten;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(title: item.kategori.split(',').first.trim()),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag:
                              '${AppConfig.webBaseUrl}/gambar/${item.gambar}',
                          child: Image.network(
                            '${AppConfig.webBaseUrl}/gambar/${item.gambar}',
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
                            item.kategori.split(',').first.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            final imgUrl =
                                '${AppConfig.webBaseUrl}/gambar/${item.gambar}';
                            openFullscreenImage(
                              context,
                              imgUrl,
                              isNetwork: true,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 22,
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
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Meta
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _MetaBadge(
                            icon: Icons.person_outline,
                            label: 'Admin',
                          ),
                          _MetaBadge(
                            icon: Icons.calendar_today_outlined,
                            label: formatDate(item.createdAt.split('T')[0]),
                          ),
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
                            const Icon(
                              Icons.format_quote_rounded,
                              color: AppColors.green500,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.ringkasan,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.green900,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Body artikel
                      if (body.isNotEmpty)
                        _ArticleBody(body: body)
                      else
                        Text(
                          'Isi konten artikel',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            {
                                  ...item.kategori
                                      .split(',')
                                      .map((t) => t.trim())
                                      .where((t) => t.isNotEmpty),
                                  'EnzyLife',
                                }
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgPage,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.text2,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      if (item.tautan != null &&
                          item.tautan!.trim().isNotEmpty &&
                          item.tautan!.trim().toLowerCase() != 'null') ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(context, item.tautan!),
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Baca Selengkapnya di Sumber Resmi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const ChatbotWidget(),
        ],
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

  TextSpan _parseInlineMarkdown(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regExp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;
    for (final match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final lines = body.trim().split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text1,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 7, right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.green500,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineMarkdown(
                      line.substring(2),
                      const TextStyle(
                        fontSize: 13,
                        color: AppColors.text2,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: _parseInlineMarkdown(
                line,
                const TextStyle(
                  fontSize: 13,
                  color: AppColors.text2,
                  height: 1.7,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
