import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class DetailRiwayatBelanjaPage extends StatefulWidget {
  final OrderModel order;

  const DetailRiwayatBelanjaPage({super.key, required this.order});

  @override
  State<DetailRiwayatBelanjaPage> createState() => _DetailRiwayatBelanjaPageState();
}

class _DetailRiwayatBelanjaPageState extends State<DetailRiwayatBelanjaPage> {
  late OrderModel _order;
  bool _isLoading = false;
  bool _hasPaid = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'MENUNGGU_PEMBAYARAN':
        return const Color(0xFFE65100);
      case 'DIPROSES':
      case 'DIKEMAS':
        return const Color(0xFF512DA8);
      case 'SIAP_DIAMBIL':
      case 'SELESAI':
        return AppColors.green700;
      case 'DIKIRIM':
        return const Color(0xFF1565C0);
      case 'DIBATALKAN':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'MENUNGGU_PEMBAYARAN':
        return const Color(0xFFFFF3E0);
      case 'DIPROSES':
      case 'DIKEMAS':
        return const Color(0xFFEDE7F6);
      case 'SIAP_DIAMBIL':
      case 'SELESAI':
        return AppColors.green50;
      case 'DIKIRIM':
        return const Color(0xFFE3F2FD);
      case 'DIBATALKAN':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  static String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.payOrder(_order.id);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res != null && res['success'] == true) {
        _hasPaid = true;
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.green500),
                ),
                const SizedBox(height: 16),
                const Text('Pembayaran Berhasil!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text1)),
                const SizedBox(height: 8),
                Text(
                  'Pembayaran untuk pesanan #${_order.id} berhasil dikonfirmasi. Pesanan Anda akan segera diproses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // pop dialog
                      // Update local state to reflect paid status
                      setState(() {
                        _order = OrderModel(
                          id: _order.id,
                          totalHarga: _order.totalHarga,
                          metodePembayaran: _order.metodePembayaran,
                          jenisCod: _order.jenisCod,
                          statusPemesanan: 'DIKEMAS',
                          createdAt: _order.createdAt,
                          items: _order.items,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500, foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res?['message'] ?? 'Gagal memproses pembayaran. Silakan coba lagi.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _order.createdAt.contains('T')
        ? _order.createdAt.split('T')[0]
        : _order.createdAt;

    String paymentText = _order.metodePembayaran;
    if (_order.metodePembayaran == 'COD') {
      if (_order.jenisCod == 'BAYAR_DI_RUMAH') {
        paymentText = 'COD (Diantar ke Rumah)';
      } else if (_order.jenisCod == 'AMBIL_TEMPAT') {
        paymentText = 'COD (Ambil Sendiri di Lab)';
      } else {
        paymentText = 'COD';
      }
    } else {
      paymentText = 'Transfer / Online';
    }

    final bool canPay = _order.statusPemesanan == 'MENUNGGU_PEMBAYARAN' && _order.metodePembayaran == 'ONLINE';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Detail Pesanan',
        onBack: () => Navigator.of(context).pop(_hasPaid),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesanan #${_order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(_order.statusPemesanan),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _order.statusDescription,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: getStatusColor(_order.statusPemesanan),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Tanggal Pemesanan', value: dateStr),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Metode Pembayaran', value: paymentText),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // WhatsApp Alert (hanya jika DIKIRIM)
            if (_order.statusPemesanan == 'DIKIRIM') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Pengiriman',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pesanan Anda sedang dalam proses pengiriman. Petugas kurir kami akan segera menghubungi Anda via WhatsApp melalui nomor telepon Anda yang terdaftar.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1B5E20),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Produk Dipesan Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _order.items.length,
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: AppColors.divider),
                    ),
                    itemBuilder: (context, idx) {
                      final item = _order.items[idx];
                      final prod = item.product;
                      final imageUrl = (prod?.image != null && prod!.image.isNotEmpty)
                          ? 'http://localhost:8000/gambar/produk/${prod.image.split('/').last}'
                          : null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: AppColors.green50,
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.image_outlined,
                                          color: AppColors.green500,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.green500,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prod?.name ?? 'Produk',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x ${_fmt(item.price)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _fmt(item.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Pembayaran Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'Total Belanja', value: _fmt(_order.totalHarga), isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canPay
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: const Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Bayar Sekarang',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.text1 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.green500 : AppColors.text1,
          ),
        ),
      ],
    );
  }
}
