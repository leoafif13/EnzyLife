import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../models/infografik.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════
//  DetailInfografikPage
// ══════════════════════════════════════════════
class DetailInfografikPage extends StatelessWidget {
  final InfografikModel item;
  const DetailInfografikPage({super.key, required this.item});

  List<InfografikModel> get _allItems {
    return ApiService.cachedInfografik;
  }

  @override
  Widget build(BuildContext context) {
    final rekomendasi =
    _allItems.where((x) => x.id != item.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(
        title: 'Infografik',
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
                  Text(item.judul,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: AppColors.text1, height: 1.3)),
                  const SizedBox(height: 10),
                  // Meta: author + tanggal
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.green500),
                      const SizedBox(width: 4),
                      Text('Admin',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.green500),
                      const SizedBox(width: 4),
                      Text(
                        item.createdAt.split('T')[0],
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      const Icon(Icons.image_outlined,
                          size: 13, color: AppColors.green500),
                      const SizedBox(width: 4), Text('1 gambar',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      'http://127.0.0.1:8000/gambar/${item.gambar}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      item.deskripsi,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: AppColors.text1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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

// ── Card rekomendasi infografik lain ──────────
class _RekomendasiCard extends StatelessWidget {
  final InfografikModel item;
  const _RekomendasiCard({required this.item});

  @override
  Widget build(BuildContext context) {

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
              child: Image.network(
                      'http://127.0.0.1:8000/gambar/${item.gambar}',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
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
                    Text(item.judul,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.text1, height: 1.3)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(
                          item.createdAt.split('T')[0],
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