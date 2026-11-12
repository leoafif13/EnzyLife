import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import 'tracker_constants.dart';

class PanduanPenggunaanPage extends StatelessWidget {
  final String? initialKategori;

  const PanduanPenggunaanPage({
    super.key,
    this.initialKategori,
  });

  @override
  Widget build(BuildContext context) {
    final panduan = TrackerConstants.getPanduan(initialKategori);
    final langkahList = (panduan['langkah'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Panduan Penggunaan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            PageHeaderCard(
              badge: '🌿  ${panduan['grup'] ?? 'Panduan'}',
              title: initialKategori ?? 'Penggunaan Enzim',
              subtitle: panduan['deskripsi'] ?? 'Panduan praktis pengenceran dan aplikasi produk enzim.',
              icon: Icons.eco_rounded,
            ),

            const SizedBox(height: 16),

            // Takaran & Frekuensi Card
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.water_drop_rounded,
                    iconColor: Colors.blueAccent,
                    title: 'Rasio Pengenceran',
                    value: panduan['rasio'] ?? '-',
                    subtitle: 'Bahan: ${panduan['pelarut'] ?? 'Air'}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.calendar_today_rounded,
                    iconColor: Colors.orange,
                    title: 'Frekuensi',
                    value: panduan['frekuensi'] ?? '-',
                    subtitle: '${panduan['reminderPerMinggu'] ?? 1}x seminggu',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Langkah-langkah
            const Text(
              'Langkah Pembuatan & Aplikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.text1,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(langkahList.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.green50,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        langkahList[index].toString(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.text1,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // Tips card
            if (panduan['tips'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFF176)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF57F17), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tips Praktis',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF57F17),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            panduan['tips'].toString(),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF5D4037),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.text3,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}
