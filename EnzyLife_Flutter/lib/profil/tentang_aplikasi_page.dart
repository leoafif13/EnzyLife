import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Tentang Aplikasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo + nama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 12),
                  const Text('EnzyLife',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                          color: AppColors.green500, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('Versi 1.0.0',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Hidup sehat dimulai dari sini',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info aplikasi
            _InfoSection(
              title: 'Tentang',
              items: [
                _InfoRow(label: 'Versi Aplikasi', value: '1.0.0'),
                _InfoRow(label: 'Platform', value: 'Android & iOS'),
                _InfoRow(label: 'Terakhir Diperbarui', value: 'April 2026'), // TODO
              ],
            ),

            const SizedBox(height: 12),

            _InfoSection(
              title: 'Pengembang',
              items: [
                _InfoRow(label: 'Nama Tim', value: 'Tim EnzyLife'), // TODO
                _InfoRow(label: 'Email', value: 'contact@enzylife.id'), // TODO
                _InfoRow(label: 'Website', value: 'www.enzylife.id'), // TODO
              ],
            ),

            const SizedBox(height: 12),

            // Links
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Kebijakan Privasi',
                    onTap: () {}, // TODO
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                  _LinkTile(
                    icon: Icons.description_outlined,
                    label: 'Syarat & Ketentuan',
                    onTap: () {}, // TODO
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                  _LinkTile(
                    icon: Icons.star_outline_rounded,
                    label: 'Beri Rating di App Store',
                    onTap: () {}, // TODO
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('© 2026 EnzyLife. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.grey[500], letterSpacing: 0.3)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(items[i].label,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        Text(items[i].value,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                                color: AppColors.text1)),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(height: 1, color: const Color(0xFFF5F5F5),
                        margin: const EdgeInsets.symmetric(horizontal: 16)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.green50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: AppColors.green500),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.text1))),
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}