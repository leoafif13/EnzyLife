import 'package:flutter/material.dart';
import '../app_color.dart';

// ══════════════════════════════════════════════
//  PageHeaderCard — Card judul + subtitle standar
//  yang muncul di bagian atas sub-halaman.
//
//  Cara pakai:
//    PageHeaderCard(
//      title: 'Artikel & Infografik',
//      subtitle: 'Kumpulan artikel seputar Eco Enzim',
//    )
// ══════════════════════════════════════════════
class PageHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}
