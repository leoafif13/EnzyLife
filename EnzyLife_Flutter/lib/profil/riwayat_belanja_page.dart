import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import 'ulasan_page.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import 'detail_riwayat_belanja_page.dart';

// ── Status pesanan ────────────────────────────
enum OrderStatus { dipesan, dikirim, selesai }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.dipesan: return 'Dipesan';
      case OrderStatus.dikirim: return 'Dikirim';
      case OrderStatus.selesai: return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.dipesan: return const Color(0xFFE65100);
      case OrderStatus.dikirim: return const Color(0xFF1565C0);
      case OrderStatus.selesai: return AppColors.green700;
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.dipesan: return const Color(0xFFFFF3E0);
      case OrderStatus.dikirim: return const Color(0xFFE3F2FD);
      case OrderStatus.selesai: return AppColors.green50;
    }
  }
}

class RiwayatBelanjaScreen extends StatefulWidget {
  const RiwayatBelanjaScreen({super.key});

  @override
  State<RiwayatBelanjaScreen> createState() => _RiwayatBelanjaScreenState();
}

class _RiwayatBelanjaScreenState extends State<RiwayatBelanjaScreen> {
  OrderStatus _filter = OrderStatus.selesai;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final orders = await ApiService.getOrderHistory();
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  static String _fmt(int price) => _fmtPrice(price);

  List<OrderModel> get _filtered =>
      _allOrders.where((o) => o.orderStatus == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Riwayat Belanja',
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.text1, size: 22),
            onPressed: () {}, // TODO: navigasi ke CartScreen
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text('Riwayat Belanja',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.text1)),
                  const SizedBox(height: 6),
                  Text('Jelajahi berbagai produk eco enzyme yang tersedia, lengkap dengan informasi, pengelolaan, dan kemudahan untuk melakukan pembelian',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),
          ),

          // Search bar
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 14, color: AppColors.text1),
                    decoration: InputDecoration(
                      hintText: 'Cari produk eco enzim..',
                      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.hint, size: 20),
                      filled: true,
                      fillColor: AppColors.bgPage,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.green500, size: 20),
                ),
              ],
            ),
          ),

          // Filter tabs
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: OrderStatus.values.map((status) {
                final active = _filter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.green500 : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active ? AppColors.green500 : AppColors.border),
                      ),
                      child: Text(status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? Colors.white : AppColors.text2,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Order list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.green500,
                    ),
                  )
                : _filtered.isEmpty
                    ? _EmptyOrders(status: _filter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _OrderCard(
                          order: _filtered[i],
                          fmtPrice: _fmt,
                          onRefresh: _loadHistory,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(int) fmtPrice;
  final VoidCallback onRefresh;

  const _OrderCard({
    required this.order,
    required this.fmtPrice,
    required this.onRefresh,
  });

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

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final otherItemsCount = order.items.length - 1;
    final totalQty = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final title = firstItem != null
        ? (otherItemsCount > 0
            ? '${firstItem.product?.name ?? 'Produk'} dan $otherItemsCount produk lainnya'
            : (firstItem.product?.name ?? 'Produk'))
        : 'Pesanan #${order.id}';
    
    final imageUrl = (firstItem?.product?.image != null && firstItem!.product!.image.isNotEmpty)
        ? 'http://localhost:8000/gambar/produk/${firstItem.product!.image.split('/').last}'
        : null;

    final dateStr = order.createdAt.split('T')[0];

    return GestureDetector(
      onTap: () async {
        final refresh = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailRiwayatBelanjaPage(order: order),
          ),
        );
        if (refresh == true) {
          onRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris produk
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 64, height: 64,
                    color: AppColors.green50,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              size: 24,
                              color: AppColors.green500,
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            size: 24,
                            color: AppColors.green500.withOpacity(0.3),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(title,
                                style: const TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w700, color: AppColors.text1)),
                          ),
                          const SizedBox(width: 8),
                          // Badge status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: getStatusBgColor(order.statusPemesanan),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(order.statusDescription,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: getStatusColor(order.statusPemesanan))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(firstItem?.product?.description ?? 'Eco enzyme premium quality',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${totalQty}pcs',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                  color: AppColors.text2)),
                          Text('Total: ${fmtPrice(order.totalHarga)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.text1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tanggal info
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text('Tanggal Pemesanan: $dateStr',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Action buttons per status
            _OrderActions(order: order),
          ],
        ),
      ),
    ),
    );
  }
}

// ── Action buttons per status ─────────────────
class _OrderActions extends StatelessWidget {
  final OrderModel order;
  const _OrderActions({required this.order});

  @override
  Widget build(BuildContext context) {
    switch (order.orderStatus) {
      case OrderStatus.selesai:
        final firstItem = order.items.isNotEmpty ? order.items.first : null;
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {}, // TODO: beli lagi — tambahkan produk ke cart
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.green500),
                  foregroundColor: AppColors.green500,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Beli lagi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UlasanScreen(
                    productName: firstItem?.product?.name ?? 'Eco Enzim',
                    orderId: order.id.toString(),
                  )),
                ), // navigasi ke halaman ulasan
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ulasan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );

      case OrderStatus.dikirim:
        return const SizedBox.shrink();

      case OrderStatus.dipesan:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {}, // TODO: batalkan pesanan
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red[300]!),
              foregroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batalkan Pesanan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        );
    }
  }
}

// ── Empty state ───────────────────────────────
class _EmptyOrders extends StatelessWidget {
  final OrderStatus status;
  const _EmptyOrders({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.green500),
          ),
          const SizedBox(height: 16),
          Text('Belum ada pesanan ${status.label.toLowerCase()}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.text1)),
          const SizedBox(height: 6),
          Text('Pesanan kamu akan muncul di sini',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── Helpers & Detail Bottom Sheet ────────────────
String _fmtPrice(int price) {
  final s = price.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp. $buf';
}