import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/midtrans_helper.dart';
import '../services/format_helper.dart';
import '../widgets/purchase_bottom_sheet.dart';
import 'ulasan_page.dart';
import 'riwayat_belanja_page.dart';


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

  static String _fmt(int price) => formatPrice(price);

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
                          statusPemesanan: 'DIPROSES',
                          createdAt: _order.createdAt,
                          items: _order.items,
                          isReviewed: _order.isReviewed,
                          existingRating: _order.existingRating,
                          existingComment: _order.existingComment,
                          existingTags: _order.existingTags,
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

  Future<void> _reloadOrder() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getOrderHistory();
      final updatedOrder = orders.firstWhere((o) => o.id == _order.id);
      setState(() {
        _order = updatedOrder;
        _isLoading = false;
        if (_order.statusPemesanan != 'MENUNGGU_PEMBAYARAN') {
          _hasPaid = true;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.cancelOrder(_order.id);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res != null && res['success'] == true) {
        _hasPaid = true; // triggers refresh in parent screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Pesanan berhasil dibatalkan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        setState(() {
          _order = OrderModel(
            id: _order.id,
            totalHarga: _order.totalHarga,
            metodePembayaran: _order.metodePembayaran,
            jenisCod: _order.jenisCod,
            statusPemesanan: 'DIBATALKAN',
            createdAt: _order.createdAt,
            items: _order.items,
            isReviewed: _order.isReviewed,
            existingRating: _order.existingRating,
            existingComment: _order.existingComment,
            existingTags: _order.existingTags,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal membatalkan pesanan. Silakan coba lagi.'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  bool get _hasActions {
    if (_order.orderStatus == OrderStatus.selesai) return true;
    if (_order.orderStatus == OrderStatus.dipesan) {
      final bool canPay = _order.statusPemesanan == 'MENUNGGU_PEMBAYARAN' && _order.metodePembayaran == 'ONLINE';
      final bool canCancel = (_order.metodePembayaran != 'ONLINE' || _order.statusPemesanan == 'MENUNGGU_PEMBAYARAN');
      return canPay || canCancel;
    }
    return false;
  }

  Widget _buildActions(BuildContext context) {
    final firstItem = _order.items.isNotEmpty ? _order.items.first : null;
    final isCancelled = _order.statusPemesanan == 'DIBATALKAN';

    switch (_order.orderStatus) {
      case OrderStatus.selesai:
        if (isCancelled) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final product = firstItem?.product;
                if (product != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => PurchaseBottomSheet(product: product),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.green500),
                foregroundColor: AppColors.green500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Beli lagi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final product = firstItem?.product;
                  if (product != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => PurchaseBottomSheet(product: product),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.green500),
                  foregroundColor: AppColors.green500,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Beli lagi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_order.items.length == 1) {
                    final item = _order.items.first;
                    final refresh = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => UlasanScreen(
                          productName: item.product?.name ?? 'Eco Enzim',
                          orderId: _order.id.toString(),
                          productId: item.product?.id ?? 0,
                          existingRating: item.existingRating,
                          existingComment: item.existingComment,
                          existingTags: item.existingTags,
                        ),
                      ),
                    );
                    if (refresh == true) {
                      setState(() => _hasPaid = true);
                      _reloadOrder();
                    }
                  } else {
                    _showProductSelectionSheet(context, _order, () {
                      setState(() => _hasPaid = true);
                      _reloadOrder();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                    _order.items.every((item) => item.isReviewed) ? 'Ubah Ulasan' : 'Beri Ulasan',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );

      case OrderStatus.dikirim:
        return const SizedBox.shrink();

      case OrderStatus.dipesan:
        final bool canPay = _order.statusPemesanan == 'MENUNGGU_PEMBAYARAN' && _order.metodePembayaran == 'ONLINE';
        final bool canCancel = (_order.metodePembayaran != 'ONLINE' || _order.statusPemesanan == 'MENUNGGU_PEMBAYARAN');

        if (canPay || canCancel) {
          return Row(
            children: [
              if (canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _cancelOrder(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      foregroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Batalkan Pesanan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (canCancel && canPay) const SizedBox(width: 10),
              if (canPay)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_order.snapToken != null) {
                              setState(() => _isLoading = true);
                              await MidtransPayHelper.pay(_order.snapToken!);
                              final verifyRes = await ApiService.payOrder(_order.id, simulate: false);
                              setState(() => _isLoading = false);
                              if (verifyRes != null && verifyRes['success'] == true) {
                                _reloadOrder();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(verifyRes?['message'] ?? 'Pembayaran belum diselesaikan atau sedang diproses.'),
                                    backgroundColor: Colors.orange[850],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } else {
                              _processPayment();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Bayar Sekarang',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = _order.createdAt;
    if (_order.createdAt.contains('T')) {
      final parts = _order.createdAt.split('T');
      final datePart = parts[0];
      final timePart = parts[1].split('.')[0];
      final timeFormatted = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
      dateStr = '$datePart $timeFormatted';
    }

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
                          color: _order.statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _order.statusDescription,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _order.statusColor,
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
                  if (_hasActions) ...[
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    _buildActions(context),
                  ],
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
                          ? 'http://127.0.0.1:8000/gambar/produk/${prod.image.split('/').last}'
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
    );
  }

  void _showProductSelectionSheet(BuildContext context, OrderModel order, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (subCtx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Pilih Produk untuk Diulas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
                  itemBuilder: (ctx, idx) {
                    final item = order.items[idx];
                    final prod = item.product;
                    if (prod == null) return const SizedBox.shrink();
                    final imageUrl = prod.image.isNotEmpty
                        ? 'http://127.0.0.1:8000/gambar/produk/${prod.image.split('/').last}'
                        : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              height: 60,
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
                                  prod.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.isReviewed ? 'Sudah Diulas' : 'Belum Diulas',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: item.isReviewed ? AppColors.green700 : Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          item.isReviewed
                              ? OutlinedButton(
                                  onPressed: () async {
                                    Navigator.of(subCtx).pop();
                                    final refresh = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => UlasanScreen(
                                          productName: prod.name,
                                          orderId: order.id.toString(),
                                          productId: prod.id,
                                          existingRating: item.existingRating,
                                          existingComment: item.existingComment,
                                          existingTags: item.existingTags,
                                        ),
                                      ),
                                    );
                                    if (refresh == true) {
                                      onRefresh();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.green500),
                                    foregroundColor: AppColors.green500,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'Ubah',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(subCtx).pop();
                                    final refresh = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => UlasanScreen(
                                          productName: prod.name,
                                          orderId: order.id.toString(),
                                          productId: prod.id,
                                        ),
                                      ),
                                    );
                                    if (refresh == true) {
                                      onRefresh();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green500,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'Beri',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
