import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/expandable_tile.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const _faqItems = [
    _Item(
        q: 'Bagaimana cara memesan produk?',
        a: 'Pilih produk di halaman Belanja, atur jumlah, lalu klik "Beli Sekarang" atau "Keranjang". Lanjutkan ke halaman Pemesanan untuk memilih metode pengambilan dan pembayaran.'),
    _Item(
        q: 'Bagaimana cara melacak pesanan saya?',
        a: 'Buka menu Profil → Riwayat Belanja, lalu pilih pesanan dengan status "Dikirim". Informasi kurir dan nomor WhatsApp akan ditampilkan di sana.'),
    _Item(
        q: 'Apakah produk bisa dikembalikan?',
        a: 'Ya. Jika produk rusak atau tidak sesuai pesanan, Anda dapat mengajukan pengembalian dalam 2×24 jam setelah pesanan diterima melalui menu Riwayat Belanja.'),
    _Item(
        q: 'Bagaimana cara menghubungi customer service?',
        a: 'Anda dapat menghubungi kami melalui email enzylifesupport@gmail.com atau WhatsApp 0812-3456-7890 pada jam operasional kami.'),
    _Item(
        q: 'Metode pembayaran apa saja yang tersedia?',
        a: 'Kami menerima pembayaran Online (transfer bank / Midtrans) serta COD yang dapat dibayar di rumah atau diambil langsung di lab kami.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Bantuan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontak langsung
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green900, AppColors.green700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Butuh bantuan lebih?',
                      style: TextStyle(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Tim kami siap membantu kamu',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 14),
                  _ContactInfoRow(icon: Icons.email_outlined, text: 'enzylifesupport@gmail.com'),
                  const SizedBox(height: 10),
                  _ContactInfoRow(icon: Icons.phone_outlined, text: '0812-3456-7890 (WhatsApp)'),
                  const SizedBox(height: 10),
                  _ContactInfoRow(icon: Icons.access_time_outlined, text: 'Senin–Sabtu, 08.00–17.00 WIB'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Pertanyaan Umum',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text1)),
            const SizedBox(height: 14),

            ..._faqItems.map((it) => ExpandableTile(
                  key: ValueKey(it.q),
                  title: it.q,
                  content: it.a,
                  leading: const QBadge(),
                )).toList(),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _Item {
  final String q, a;
  const _Item({required this.q, required this.a});
}