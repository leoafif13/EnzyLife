import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // TODO: simpan preferensi ke SharedPreferences / API
  bool _notifPesanan    = true;
  bool _notifPromo      = true;
  bool _notifArtikel    = false;
  bool _notifPengingat  = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Notifikasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotifSection(
              title: 'Transaksi',
              items: [
                _NotifItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Update Pesanan',
                  desc: 'Status pengiriman dan konfirmasi pesanan',
                  value: _notifPesanan,
                  onChanged: (v) => setState(() => _notifPesanan = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NotifSection(
              title: 'Konten',
              items: [
                _NotifItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Promo & Penawaran',
                  desc: 'Diskon dan penawaran spesial untukmu',
                  value: _notifPromo,
                  onChanged: (v) => setState(() => _notifPromo = v),
                ),
                _NotifItem(
                  icon: Icons.article_outlined,
                  label: 'Artikel Baru',
                  desc: 'Artikel edukasi terbaru seputar Eco Enzim',
                  value: _notifArtikel,
                  onChanged: (v) => setState(() => _notifArtikel = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NotifSection(
              title: 'Pengingat',
              items: [
                _NotifItem(
                  icon: Icons.alarm_outlined,
                  label: 'Pengingat Eco Enzim',
                  desc: 'Notifikasi jadwal perawatan eco enzim kamu',
                  value: _notifPengingat,
                  onChanged: (v) => setState(() => _notifPengingat = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifSection extends StatelessWidget {
  final String title;
  final List<_NotifItem> items;

  const _NotifSection({required this.title, required this.items});

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
                  items[i],
                  if (!isLast)
                    Container(
                        margin: const EdgeInsets.only(left: 66),
                        height: 1, color: const Color(0xFFF5F5F5)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifItem({
    required this.icon, required this.label, required this.desc,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppColors.text1)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.green500,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}