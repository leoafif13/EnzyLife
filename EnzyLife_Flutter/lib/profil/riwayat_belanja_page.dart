import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import 'ulasan_page.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import 'detail_riwayat_belanja_page.dart';
import '../services/format_helper.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/page_header_card.dart';
import '../widgets/purchase_bottom_sheet.dart';

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
  OrderStatus? _filter;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final orders = await ApiService.getOrderHistory();
    if (!mounted) return;
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  static String _fmt(int price) => formatPrice(price);

  List<OrderModel> get _filtered {
    final list = _allOrders.where((o) {
      if (_filter != null && o.orderStatus != _filter) return false;
      if (_query.isEmpty) return true;
      final queryLower = _query.toLowerCase();
      if (o.id.toString().contains(queryLower)) return true;
      return o.items.any((item) =>
          (item.product?.name ?? '').toLowerCase().contains(queryLower));
    }).toList();
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  Widget _buildFilterTab(OrderStatus? status, String label) {
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
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : AppColors.text2,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(
        title: 'Riwayat Belanja',
      ),
      body: Column(
        children: [
          // Header card
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeaderCard(
              badge: '🛍️  Riwayat Belanja',
              title: 'Daftar Transaksi',
              subtitle: 'Pantau status pesanan, riwayat belanja produk eco enzyme, serta lakukan pembayaran dan ulasan dalam satu tempat.',
              icon: Icons.eco_rounded,
            ),
          ),

          // Search bar
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SearchBarField(
              controller: _searchController,
              hintText: 'Cari pesanan anda..',
              onChanged: (v) => setState(() => _query = v),
              showClearButton: _query.isNotEmpty,
              onClear: () {
                setState(() => _query = '');
                _searchController.clear();
              },
            ),
          ),

          // Filter tabs
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab(null, 'Semua'),
                  ...OrderStatus.values.map((status) => _buildFilterTab(status, status.label)),
                ],
              ),
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
        ? 'http://127.0.0.1:8000/gambar/produk/${firstItem.product!.image.split('/').last}'
        : null;

    String dateStr = order.createdAt;
    if (order.createdAt.contains('T')) {
      final parts = order.createdAt.split('T');
      final datePart = parts[0];
      final timePart = parts[1].split('.')[0];
      final timeFormatted = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
      dateStr = '$datePart $timeFormatted';
    }

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
                              color: order.statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(order.statusDescription,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: order.statusColor)),
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
            _OrderActions(order: order, onRefresh: onRefresh),
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
  final VoidCallback onRefresh;
  const _OrderActions({required this.order, required this.onRefresh});

  Future<void> _cancelOrder(BuildContext context, OrderModel order) async {
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

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.green500)),
    );

    final res = await ApiService.cancelOrder(order.id);

    if (!context.mounted) return;
    Navigator.of(context).pop(); // pop loading

    if (res != null && res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Pesanan berhasil dibatalkan'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Refresh list
      onRefresh();
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
  }

  @override
  Widget build(BuildContext context) {
    switch (order.orderStatus) {
      case OrderStatus.selesai:
        final firstItem = order.items.isNotEmpty ? order.items.first : null;
        final isCancelled = order.statusPemesanan == 'DIBATALKAN';
        
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                onPressed: () async {
                  if (order.items.length == 1) {
                    final item = order.items.first;
                    final refresh = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => UlasanScreen(
                          productName: item.product?.name ?? 'Eco Enzim',
                          orderId: order.id.toString(),
                          productId: item.product?.id ?? 0,
                          existingRating: item.existingRating,
                          existingComment: item.existingComment,
                          existingTags: item.existingTags,
                        ),
                      ),
                    );
                    if (refresh == true) {
                      onRefresh();
                    }
                  } else {
                    _showProductSelectionSheet(context, order, onRefresh);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                    order.items.every((item) => item.isReviewed) ? 'Ubah Ulasan' : 'Beri Ulasan',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );

      case OrderStatus.dikirim:
        return const SizedBox.shrink();

      case OrderStatus.dipesan:
        if (order.metodePembayaran == 'ONLINE') {
          if (order.statusPemesanan == 'MENUNGGU_PEMBAYARAN') {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelOrder(context, order),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      foregroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batalkan',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailRiwayatBelanjaPage(order: order),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Bayar Sekarang',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            );
          } else {
            // Sudah dibayar, tidak bisa dibatalkan (sembunyikan tombol)
            return const SizedBox.shrink();
          }
        }

        // Default (misal COD) masih bisa dibatalkan jika belum selesai/dikirim
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _cancelOrder(context, order),
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

// ── Empty state ───────────────────────────────
class _EmptyOrders extends StatelessWidget {
  final OrderStatus? status;
  const _EmptyOrders({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status?.label.toLowerCase() ?? 'transaksi';
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
          Text('Belum ada $label',
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