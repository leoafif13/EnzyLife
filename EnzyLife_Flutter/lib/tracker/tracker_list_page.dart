import 'package:flutter/material.dart';
import '../app_color.dart';
import '../config/app_config.dart';
import '../models/product_tracker.dart';
import '../services/api_service.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import 'tracker_detail_page.dart';
import '../profil/riwayat_belanja_page.dart';

class TrackerListPage extends StatefulWidget {
  const TrackerListPage({super.key});

  @override
  State<TrackerListPage> createState() => _TrackerListPageState();
}

class _TrackerListPageState extends State<TrackerListPage> {
  int _selectedTab = 0; // 0 = Aktif, 1 = Selesai, 2 = Dibatalkan
  List<ProductTracker> _trackers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrackers();
  }

  Future<void> _loadTrackers() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getTrackers();
    if (mounted) {
      setState(() {
        _trackers = data;
        _isLoading = false;
      });
    }
  }

  List<ProductTracker> get _activeTrackers =>
      _trackers.where((t) => t.isAktif).toList();

  List<ProductTracker> get _completedTrackers =>
      _trackers.where((t) => t.isSelesai).toList();

  List<ProductTracker> get _cancelledTrackers =>
      _trackers.where((t) => t.isDibatalkan).toList();

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0
        ? _activeTrackers
        : (_selectedTab == 1 ? _completedTrackers : _cancelledTrackers);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Tracker Penggunaan'),
      body: Column(
        children: [
          // Header Card
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeaderCard(
              badge: '🧪  Tracker Produk',
              title: 'Daftar Tracker Pemakaian',
              subtitle:
                  'Pantau pemakaian produk enzim secara rutin selama 3-5 minggu dan dapatkan badge Ulasan Terverifikasi.',
              icon: Icons.track_changes_rounded,
            ),
          ),

          // Filter pill tabs (3 Kategori: Aktif, Selesai, Dibatalkan)
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterTab(
                    index: 0,
                    label: 'Sedang Aktif (${_activeTrackers.length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    index: 1,
                    label: 'Selesai (${_completedTrackers.length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    index: 2,
                    label: 'Dibatalkan (${_cancelledTrackers.length})',
                  ),
                ],
              ),
            ),
          ),

          // List content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green500),
                  )
                : _buildTrackerList(currentList, tabIndex: _selectedTab),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({required int index, required String label}) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.green500 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.green500 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerList(List<ProductTracker> list, {required int tabIndex}) {
    if (list.isEmpty) {
      IconData emptyIcon;
      String emptyTitle;
      String emptySubtitle;

      if (tabIndex == 0) {
        emptyIcon = Icons.eco_outlined;
        emptyTitle = 'Belum Ada Tracker Aktif';
        emptySubtitle =
            'Mulai dampingi pemakaian produk dari pesanan selesai untuk mendapatkan badge Ulasan Terverifikasi ✅.';
      } else if (tabIndex == 1) {
        emptyIcon = Icons.check_circle_outline_rounded;
        emptyTitle = 'Belum Ada Tracker Selesai';
        emptySubtitle =
            'Selesaikan tracking pemakaian selama 3-5 minggu untuk mencatat hasil dan mendapatkan badge Ulasan Terverifikasi ✅.';
      } else {
        emptyIcon = Icons.cancel_outlined;
        emptyTitle = 'Tidak Ada Tracker yang Dibatalkan';
        emptySubtitle =
            'Semua tracking produk yang Anda hentikan atau batalkan di tengah jalan akan tersimpan di sini.';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tabIndex == 2 ? const Color(0xFFFFEBEE) : AppColors.green50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emptyIcon,
                  size: 48,
                  color: tabIndex == 2 ? Colors.red[600] : AppColors.green500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4),
              ),
              if (tabIndex == 0) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiwayatBelanjaScreen()),
                    ).then((_) => _loadTrackers());
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Buka Riwayat Belanja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.green500,
      onRefresh: _loadTrackers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tracker = list[index];
          return _buildTrackerCard(tracker);
        },
      ),
    );
  }

  Widget _buildTrackerCard(ProductTracker tracker) {
    final prod = tracker.product;
    final kategori = prod?.kategori ?? 'Umum';

    Color statusColor;
    Color statusBgColor;
    String statusLabel;
    switch (tracker.status) {
      case 'AKTIF':
        statusColor = AppColors.green700;
        statusBgColor = AppColors.green50;
        statusLabel = 'Aktif (3 Minggu)';
        break;
      case 'PERPANJANGAN':
        statusColor = const Color(0xFF1976D2);
        statusBgColor = const Color(0xFFE3F2FD);
        statusLabel = 'Diperpanjang';
        break;
      case 'SELESAI':
        statusColor = const Color(0xFF2E7D32);
        statusBgColor = const Color(0xFFE8F5E9);
        statusLabel = 'Selesai ✅';
        break;
      case 'DIBATALKAN':
        statusColor = Colors.red[700]!;
        statusBgColor = const Color(0xFFFFEBEE);
        statusLabel = 'Dibatalkan';
        break;
      default:
        statusColor = AppColors.text3;
        statusBgColor = AppColors.bgPage;
        statusLabel = tracker.status;
    }

    final totalHari = tracker.status == 'PERPANJANGAN' ? 35 : 21;
    final progres = (tracker.hariKe / totalHari).clamp(0.0, 1.0);
    final isDibatalkan = tracker.status == 'DIBATALKAN';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackerDetailPage(trackerId: tracker.id),
          ),
        ).then((_) => _loadTrackers());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDibatalkan ? Colors.red[100]! : AppColors.border,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.bgPage,
                    child: prod?.image != null && prod!.image.isNotEmpty
                        ? Image.network(
                            '${AppConfig.webBaseUrl}/gambar/produk/${prod.image.split('/').last}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.eco_rounded,
                              color: AppColors.green500,
                              size: 28,
                            ),
                          )
                        : const Icon(Icons.eco_rounded, color: AppColors.green500, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...(prod != null && prod.kategoriList.isNotEmpty
                                  ? prod.kategoriList
                                  : [kategori])
                              .map(
                            (kat) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                kat,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green700,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prod?.name ?? 'Produk Enzim',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDibatalkan
                            ? 'Tracking dihentikan pada hari ke-${tracker.hariKe}'
                            : 'Mulai: ${tracker.tanggalMulai} • Batas: ${tracker.batasAkhir ?? tracker.tanggalSelesai}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDibatalkan ? Colors.red[600] : AppColors.text3,
                          fontWeight: isDibatalkan ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDibatalkan
                      ? 'Berjalan hingga hari ke-${tracker.hariKe} dari $totalHari hari'
                      : 'Hari ke-${tracker.hariKe} dari $totalHari hari',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2),
                ),
                Text(
                  '${(progres * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDibatalkan ? Colors.grey[600] : AppColors.green700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progres,
                minHeight: 6,
                backgroundColor: AppColors.bgPage,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDibatalkan ? Colors.grey[400]! : AppColors.green500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 16, color: AppColors.text3),
                const SizedBox(width: 4),
                Text(
                  '${tracker.logsCount} catatan pemakaian',
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
                const Spacer(),
                Text(
                  isDibatalkan ? 'Lihat Riwayat' : 'Buka Tracker',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDibatalkan ? Colors.grey[700] : AppColors.green500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDibatalkan ? Colors.grey[600] : AppColors.green500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
