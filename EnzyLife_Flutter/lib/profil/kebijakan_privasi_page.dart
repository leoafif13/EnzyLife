import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/expandable_tile.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  static const _sections = [
    _Section(
      title: '1. Informasi yang Kami Kumpulkan',
      content:
          'Kami mengumpulkan informasi yang Anda berikan saat mendaftar dan menggunakan aplikasi, '
          'meliputi nama lengkap, alamat email, nomor telepon, alamat pengiriman, serta riwayat '
          'pesanan dan ulasan produk. Kami juga mengumpulkan data teknis seperti jenis perangkat '
          'dan versi aplikasi secara anonim untuk membantu meningkatkan layanan.',
    ),
    _Section(
      title: '2. Cara Kami Menggunakan Informasi',
      content:
          'Informasi digunakan untuk memproses pesanan, mengirimkan produk, menghubungi Anda '
          'terkait status pesanan, serta memberikan layanan pelanggan. Jika Anda menyetujui, kami '
          'juga dapat mengirim informasi promo dan edukasi produk eco-enzim. Kami tidak menjual '
          'data pribadi Anda kepada pihak ketiga.',
    ),
    _Section(
      title: '3. Keamanan Data',
      content:
          'Kami melindungi data Anda dengan enkripsi saat transmisi dan penyimpanan yang aman di '
          'server kami. Akses dibatasi hanya untuk petugas yang berkepentingan. Meski tidak ada '
          'sistem yang sepenuhnya kebal, kami terus meningkatkan perlindungan secara berkala.',
    ),
    _Section(
      title: '4. Hak Pengguna',
      content:
          'Anda berhak mengakses, memperbaiki, atau menghapus data pribadi Anda kapan saja melalui '
          'menu Edit Profil di aplikasi. Untuk permintaan penghapusan akun secara permanen, silakan '
          'hubungi kami melalui email yang tersedia di bawah ini.',
    ),
    _Section(
      title: '5. Perubahan Kebijakan',
      content:
          'Kebijakan ini dapat diperbarui dari waktu ke waktu. Perubahan yang material akan kami '
          'informasikan melalui aplikasi atau email. Penggunaan aplikasi setelah pembaruan berarti '
          'Anda menyetujui kebijakan terbaru.',
    ),
    _Section(
      title: '6. Hubungi Kami',
      content:
          'Jika ada pertanyaan terkait kebijakan privasi ini, hubungi kami di '
          'enzylifesupport@gmail.com atau WhatsApp 0812-3456-7890. Tim kami siap membantu pada '
          'jam operasional Senin–Sabtu, 08.00–17.00 WIB.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Kebijakan Privasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
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
                  const Text('Kebijakan Privasi',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.text1)),
                  const SizedBox(height: 6),
                  Text('Terakhir diperbarui: Juli 2026', // TODO
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ..._sections.map((s) => ExpandableTile(
                  key: ValueKey(s.title),
                  title: s.title,
                  content: s.content,
                )).toList(),
          ],
        ),
      ),
    );
  }
}

class _Section {
  final String title, content;
  const _Section({required this.title, required this.content});
}