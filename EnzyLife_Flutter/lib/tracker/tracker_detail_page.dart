import 'package:flutter/material.dart';
import '../app_color.dart';
import '../config/app_config.dart';
import '../models/product_tracker.dart';
import '../models/user_routine.dart';
import '../services/api_service.dart';
import '../widgets/sub_page_appbar.dart';
import 'routine_setup_sheet.dart';
import 'weekly_recap_dialog.dart';
import 'panduan_penggunaan_page.dart';
import 'catatan_hasil_dialog.dart';
import '../edukasi/kalkulator_page.dart';
import '../profil/ulasan_page.dart';

class TrackerDetailPage extends StatefulWidget {
  final int trackerId;

  const TrackerDetailPage({
    super.key,
    required this.trackerId,
  });

  @override
  State<TrackerDetailPage> createState() => _TrackerDetailPageState();
}

class _TrackerDetailPageState extends State<TrackerDetailPage> {
  ProductTracker? _tracker;
  RoutineDashboardData? _routineDashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getTrackerDetail(widget.trackerId),
        ApiService.getRoutineDashboard(trackerId: widget.trackerId),
      ]);

      if (mounted) {
        setState(() {
          _tracker = results[0] as ProductTracker?;
          _routineDashboard = results[1] as RoutineDashboardData?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openRoutineSetupSheet() {
    final existingCategories = _routineDashboard?.routines.map((r) => r.kategoriNama).toList() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoutineSetupSheet(
        trackerId: widget.trackerId,
        pemesananId: _tracker?.pemesananId,
        produkId: _tracker?.produkId,
        productKategoriList: _tracker?.product?.kategoriList,
        existingKategoriList: existingCategories,
        onSuccess: _loadAll,
      ),
    );
  }

  void _openWeeklyRecap() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WeeklyRecapDialog(
        trackerId: widget.trackerId,
        onCompleted: _loadAll,
      ),
    );
  }

  void _openSelesai() {
    showDialog(
      context: context,
      builder: (_) => CatatanHasilDialog(
        trackerId: widget.trackerId,
        onSelesai: (catatan) {
          _loadAll();
          if (_tracker?.product != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UlasanPage(
                  orderId: _tracker!.pemesananId,
                  productId: _tracker!.produkId,
                  productName: _tracker!.product!.name,
                  productImage: _tracker!.product!.image,
                  trackerId: _tracker!.id,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _openSimulationDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.science_rounded, color: AppColors.green700, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulasi Progres Siklus (Testing)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text1),
                        ),
                        Text(
                          'Uji alur Rekap Hari ke-7, Minggu 2, Minggu 3 (Mandiri/Ulasan), atau Minggu 4',
                          style: TextStyle(fontSize: 11.5, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              _buildSimulateTile(
                title: 'Lompat ke Akhir Minggu ke-1 (Uji Rekap Siklus 1)',
                subtitle: 'Memunculkan banner & form evaluasi Rekap Siklus 1.',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFFF57F17),
                target: 'minggu_1_hari_7',
              ),
              _buildSimulateTile(
                title: 'Lompat ke Akhir Minggu ke-2 (Uji Rekap Siklus 2)',
                subtitle: 'Memunculkan banner & form evaluasi Rekap Siklus 2.',
                icon: Icons.calendar_view_week_rounded,
                color: AppColors.green700,
                target: 'minggu_2_hari_7',
              ),
              _buildSimulateTile(
                title: 'Lompat ke Minggu ke-3 (Mandiri & Ulasan)',
                subtitle: 'Memunculkan status Mandiri & tombol Ulasan Terverifikasi.',
                icon: Icons.verified_rounded,
                color: const Color(0xFF2E7D32),
                target: 'minggu_3',
              ),
              _buildSimulateTile(
                title: 'Lompat ke Minggu ke-4 (Selesai Penuh)',
                subtitle: 'Fase akhir pembiasaan penggunaan mandiri.',
                icon: Icons.military_tech_rounded,
                color: Colors.deepPurple,
                target: 'minggu_4',
              ),
              _buildSimulateTile(
                title: 'Reset ke Hari Ini (Minggu 1 Hari 1)',
                subtitle: 'Kembalikan progres ke hari pertama normal.',
                icon: Icons.restart_alt_rounded,
                color: Colors.grey[700]!,
                target: 'reset',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulateTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String target,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.text1)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.text3),
      onTap: () async {
        Navigator.pop(context);
        setState(() => _isLoading = true);
        final res = await ApiService.simulateRoutineProgress(
          trackerId: widget.trackerId,
          target: target,
        );
        setState(() => _isLoading = false);
        if (res != null && res['success'] == true) {
          _loadAll();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Simulasi berhasil dijalankan!'),
                backgroundColor: AppColors.green700,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildQuickTestChip(String label, String target) {
    return InkWell(
      onTap: () async {
        setState(() => _isLoading = true);
        final res = await ApiService.simulateRoutineProgress(
          trackerId: widget.trackerId,
          target: target,
        );
        setState(() => _isLoading = false);
        if (res != null && res['success'] == true) {
          _loadAll();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Simulasi berhasil dijalankan!'),
                backgroundColor: AppColors.green700,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.green200),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: AppColors.green700,
          ),
        ),
      ),
    );
  }

  Future<void> _handleBatalkanTracker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Tracking?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tracking yang dibatalkan tidak dapat dilanjutkan lagi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali', style: TextStyle(color: AppColors.text3)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await ApiService.batalkanTracker(widget.trackerId);
      if (res != null && res['success'] == true) {
        _loadAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tracker berhasil dibatalkan')),
          );
        }
      }
    }
  }

  Future<void> _handleCheckin(UserRoutineItem item) async {
    if (item.hasCheckedToday) {
      // Opsi untuk batalkan checkin hari ini
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Batalkan Catatan Hari Ini?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text('Anda sudah mencatat pemakaian ${item.kategoriNama} hari ini. Ingin membatalkannya?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Kembali', style: TextStyle(color: AppColors.text3)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Batalkan'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final res = await ApiService.routineUncheckin(item.id);
        if (res != null && res['success'] == true) {
          _loadAll();
        }
      }
      return;
    }

    // 1-Tap Check-in
    final res = await ApiService.routineCheckin(item.id);
    if (res != null && res['success'] == true) {
      _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Catatan pemakaian ${item.kategoriNama} dicatat! ✨'),
            backgroundColor: AppColors.green700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal mencatat pemakaian'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Tracker Penggunaan Produk',
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined, color: AppColors.green700),
            tooltip: 'Simulasi Siklus / Testing',
            onPressed: _openSimulationDialog,
          ),
          if (_tracker != null && _tracker!.isAktif)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.text1),
              onSelected: (val) {
                if (val == 'simulasi') _openSimulationDialog();
                if (val == 'batal') _handleBatalkanTracker();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'simulasi',
                  child: Row(
                    children: [
                      Icon(Icons.science_rounded, color: AppColors.green700, size: 20),
                      SizedBox(width: 8),
                      Text('Uji Coba Siklus (Testing)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'batal',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Batalkan Tracking', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green500),
            )
          : _tracker == null
              ? _buildErrorState()
              : RefreshIndicator(
                  color: AppColors.green500,
                  onRefresh: _loadAll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Info Produk
                        _buildProductHeroCard(),
                        const SizedBox(height: 16),

                        // Cek apakah sudah ada rutinitas yang di-setup
                        if (_routineDashboard == null || !_routineDashboard!.hasRoutines)
                          _buildSetupPromptCard()
                        else ...[
                          // Banner Rekap jika hari ke-7
                          if (_routineDashboard!.isRecapReady && _tracker!.isAktif) ...[
                            _buildRecapBanner(),
                            const SizedBox(height: 16),
                          ],

                          // Banner Mandiri & Review jika masuk minggu ke-3 atau ke-4
                          if (_routineDashboard!.canUnlockVerifiedReview && _tracker!.isAktif) ...[
                            _buildMandiriActionBanner(),
                            const SizedBox(height: 16),
                          ],

                          // Card Siklus 3-4 Minggu & Streak
                          _buildCycleProgressCard(),
                          const SizedBox(height: 16),

                          // Strip Kalender Mingguan ("Only Today")
                          _buildWeeklyCalendarStrip(),
                          const SizedBox(height: 20),

                          // List Kategori Penggunaan Produk (1-Tap Checkin)
                          _buildRoutinesSection(),
                          const SizedBox(height: 20),

                          // Shortcuts Panduan & Kalkulator
                          _buildShortcutsSection(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.text3),
          const SizedBox(height: 12),
          const Text('Data tracker tidak ditemukan', style: TextStyle(color: AppColors.text2)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green500,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeroCard() {
    final prod = _tracker!.product;
    final kategori = prod?.kategori ?? 'Eco Enzyme';

    Color statusColor;
    Color statusBgColor;
    String statusLabel;

    switch (_tracker!.status) {
      case 'AKTIF':
        statusColor = AppColors.green700;
        statusBgColor = AppColors.green50;
        statusLabel = 'Aktif (3-4 Minggu)';
        break;
      case 'SELESAI':
        statusColor = const Color(0xFF2E7D32);
        statusBgColor = const Color(0xFFE8F5E9);
        statusLabel = 'Mandiri & Selesai ✅';
        break;
      case 'DIBATALKAN':
        statusColor = Colors.red[700]!;
        statusBgColor = const Color(0xFFFFEBEE);
        statusLabel = 'Dibatalkan';
        break;
      default:
        statusColor = AppColors.text3;
        statusBgColor = AppColors.bgPage;
        statusLabel = _tracker!.status;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: AppColors.bgPage,
              child: prod?.image != null && prod!.image.isNotEmpty
                  ? Image.network(
                      '${AppConfig.webBaseUrl}/gambar/produk/${prod.image.split('/').last}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_rounded,
                        color: AppColors.green500,
                        size: 32,
                      ),
                    )
                  : const Icon(Icons.eco_rounded, color: AppColors.green500, size: 32),
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 8),
                Text(
                  prod?.name ?? 'Eco Enzyme',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Dimulai: ${_tracker!.tanggalMulai}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card ajakan jika pengguna belum memilih kategori penggunaan untuk produk ini
  Widget _buildSetupPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.green700, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tentukan Kategori Penggunaan Produk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Produk ini bisa dipakai untuk kompor & dapur, pel lantai, cuci piring, penyubur tanaman, dll. Pilih kategori yang Anda butuhkan, sistem akan memandu takaran pengenceran dan target rutin selama 3-4 minggu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.45),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openRoutineSetupSheet,
              icon: const Icon(Icons.add_task_rounded, size: 20),
              label: const Text(
                'Pilih Kategori Penggunaan',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner Rekap Mingguan Hari ke-7
  Widget _buildRecapBanner() {
    final siklus = _routineDashboard?.siklusKe ?? 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fact_check_rounded, color: Color(0xFFF57F17), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekap Minggu ke-$siklus Selesai! 🎉',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57F17),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lihat evaluasi hasil pemakaian dan lanjut ke siklus berikutnya.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _openWeeklyRecap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57F17),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Buka Rekap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Banner jika sudah mencapai minggu ke-3 atau ke-4 (Mandiri & Berhak Ulasan Terverifikasi)
  Widget _buildMandiriActionBanner() {
    final siklus = _routineDashboard?.siklusKe ?? 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.green700, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Memasuki Minggu ke-$siklus: Anda Sudah Mandiri! 🌟',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Setelah 3-4 minggu pemakaian rutin, Anda diasumsikan telah mahir dan terbiasa menggunakan produk secara mandiri. Anda kini berhak menyelesaikan tracker & memberikan Ulasan Terverifikasi.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF2E7D32), height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openSelesai,
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: const Text(
                'Selesaikan Tracker & Tulis Ulasan Terverifikasi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card Progres Siklus 3-4 Minggu & Ringkasan Rutinitas
  Widget _buildCycleProgressCard() {
    final siklus = _routineDashboard?.siklusKe ?? 1;
    final hariKe = _routineDashboard?.hariKe ?? 1;
    final maxSiklus = _routineDashboard?.maxSiklus ?? 4;
    final totalCheckinMingguIni = _routineDashboard?.routines.fold<int>(
      0, (sum, r) => sum + r.totalCheckin,
    ) ?? 0;
    final totalKategori = _routineDashboard?.routines.length ?? 0;

    final progressRatio = ((siklus - 1) * 7 + hariKe) / (maxSiklus * 7);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perjalanan Menuju Mandiri',
                    style: TextStyle(fontSize: 12, color: AppColors.text3, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minggu ke-$siklus dari $maxSiklus Minggu (Hari $hariKe/7)',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progressRatio * 100).toStringAsFixed(0)}% Selesai',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stepper Visual 4 Minggu
          Row(
            children: List.generate(maxSiklus, (index) {
              final weekNum = index + 1;
              final isPassed = weekNum < siklus;
              final isCurrent = weekNum == siklus;

              Color dotColor;
              if (isPassed) {
                dotColor = AppColors.green500;
              } else if (isCurrent) {
                dotColor = AppColors.green700;
              } else {
                dotColor = Colors.grey[300]!;
              }

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (index < maxSiklus - 1) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Mgg 1: Adaptasi', textAlign: TextAlign.left, style: TextStyle(fontSize: 10, color: AppColors.text3)),
              ),
              const Expanded(
                child: Text('Mgg 2: Rutin', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.text3)),
              ),
              Expanded(
                child: Text(
                  'Mgg 3: Mandiri ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: siklus >= 3 ? AppColors.green700 : AppColors.text3,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Mgg 4: Kebiasaan',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: siklus >= 4 ? AppColors.green700 : AppColors.text3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),

          // Ringkasan Aktivitas Rutinitas
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.task_alt_rounded, color: AppColors.green700, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${totalCheckinMingguIni}x Pemakaian',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text1,
                          ),
                        ),
                        const Text(
                          'Tercatat Minggu Ini',
                          style: TextStyle(fontSize: 11, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.divider),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category_rounded, color: Color(0xFF2E7D32), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalKategori Kategori',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text1,
                          ),
                        ),
                        const Text(
                          'Area Penggunaan Aktif',
                          style: TextStyle(fontSize: 11, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Baris Uji Coba Cepat Siklus (Testing Alur 1-4 Minggu)
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgPage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_rounded, size: 15, color: AppColors.green700),
                const SizedBox(width: 6),
                const Text(
                  'Uji Alur:',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.text2),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickTestChip('Rekap Minggu 1', 'minggu_1_hari_7'),
                        const SizedBox(width: 6),
                        _buildQuickTestChip('Rekap Minggu 2', 'minggu_2_hari_7'),
                        const SizedBox(width: 6),
                        _buildQuickTestChip('Minggu 3 (Mandiri)', 'minggu_3'),
                        const SizedBox(width: 6),
                        _buildQuickTestChip('Minggu 4', 'minggu_4'),
                        const SizedBox(width: 6),
                        _buildQuickTestChip('Reset (Hari 1)', 'reset'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Kategori Rutinitas & 1-Tap Check-In
  Widget _buildRoutinesSection() {
    final routines = _routineDashboard?.routines ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kategori Penggunaan Produk',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.text1,
              ),
            ),
            if (_tracker!.isAktif)
              TextButton.icon(
                onPressed: _openRoutineSetupSheet,
                icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.green700),
                label: const Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (routines.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Belum ada kategori rutinitas aktif.',
                style: TextStyle(color: AppColors.text3, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _buildRoutineCard(routine);
            },
          ),
      ],
    );
  }

  /// Strip Kalender Mingguan ("Only Today")
  Widget _buildWeeklyCalendarStrip() {
    final calendarDays = _routineDashboard?.calendarDays ?? [];
    if (calendarDays.isEmpty) return const SizedBox.shrink();

    final routines = _routineDashboard?.routines ?? [];
    final siklus = _routineDashboard?.siklusKe ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.green700),
                  const SizedBox(width: 8),
                  Text(
                    'Kalender Minggu ke-$siklus',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Only Today',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Catatan pemakaian hanya dapat diisi pada hari ini (tanggal lalu terkunci otomatis).',
            style: TextStyle(fontSize: 11, color: AppColors.text3),
          ),
          const SizedBox(height: 14),

          // 7 Hari dalam Siklus
          Row(
            children: calendarDays.map((day) {
              final checkedCount = routines
                  .where((r) => r.checkedDates.contains(day.date))
                  .length;
              final isPartiallyDone = checkedCount > 0;

              Color bgColor;
              Color borderColor;
              Color dayNameColor;
              Color dateColor;
              Widget statusWidget;

              if (day.isToday) {
                bgColor = AppColors.green50;
                borderColor = AppColors.green500;
                dayNameColor = AppColors.green700;
                dateColor = AppColors.green700;
                if (isPartiallyDone) {
                  statusWidget = Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.green500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 11, color: Colors.white),
                  );
                } else {
                  statusWidget = Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.green700,
                      shape: BoxShape.circle,
                    ),
                  );
                }
              } else if (day.isPast) {
                bgColor = AppColors.bgPage;
                borderColor = AppColors.border;
                dayNameColor = AppColors.text3;
                dateColor = AppColors.text2;
                if (isPartiallyDone) {
                  statusWidget = const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.green500);
                } else {
                  statusWidget = const Icon(Icons.remove_rounded, size: 15, color: AppColors.text3);
                }
              } else {
                // Hari ke depan (Future)
                bgColor = AppColors.bgPage.withValues(alpha: 0.5);
                borderColor = AppColors.border.withValues(alpha: 0.5);
                dayNameColor = AppColors.text3.withValues(alpha: 0.6);
                dateColor = AppColors.text3.withValues(alpha: 0.6);
                statusWidget = Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.text3.withValues(alpha: 0.4));
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor,
                      width: day.isToday ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.dayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: dayNameColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.dayNum.split(' ').first,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: dateColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      statusWidget,
                      const SizedBox(height: 3),
                      Text(
                        day.isToday
                            ? 'Hari ini'
                            : day.isPast
                                ? (isPartiallyDone ? 'Tercatat' : 'Off')
                                : 'Terkunci',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                          color: day.isToday
                              ? AppColors.green700
                              : dayNameColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(UserRoutineItem item) {
    // Tentukan icon berdasarkan nama kategori
    IconData icon = Icons.cleaning_services_rounded;
    if (item.kategoriNama.contains('Dapur')) {
      icon = Icons.kitchen_rounded;
    } else if (item.kategoriNama.contains('Lantai') || item.kategoriNama.contains('Pel')) {
      icon = Icons.cleaning_services_rounded;
    } else if (item.kategoriNama.contains('Piring')) {
      icon = Icons.local_dining_rounded;
    } else if (item.kategoriNama.contains('Pakaian')) {
      icon = Icons.local_laundry_service_rounded;
    } else if (item.kategoriNama.contains('Mandi')) {
      icon = Icons.bathtub_rounded;
    } else if (item.kategoriNama.contains('Saluran')) {
      icon = Icons.plumbing_rounded;
    } else if (item.kategoriNama.contains('Bau')) {
      icon = Icons.air_rounded;
    } else if (item.kategoriNama.contains('Pupuk') || item.kategoriNama.contains('Tanaman')) {
      icon = Icons.yard_rounded;
    } else if (item.kategoriNama.contains('Pestisida')) {
      icon = Icons.eco_rounded;
    } else if (item.kategoriNama.contains('Kompos')) {
      icon = Icons.compost_rounded;
    } else if (item.kategoriNama.contains('Purifier')) {
      icon = Icons.filter_drama_rounded;
    }

    // Status target label
    Color statusBadgeColor = AppColors.green50;
    Color statusTextColor = AppColors.green700;
    if (item.statusLabel == 'Optimal') {
      statusBadgeColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
    } else if (item.statusLabel == 'Tercapai') {
      statusBadgeColor = const Color(0xFFE3F2FD);
      statusTextColor = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.hasCheckedToday ? AppColors.green500 : AppColors.border,
          width: item.hasCheckedToday ? 1.5 : 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.hasCheckedToday ? AppColors.green50 : AppColors.bgPage,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: item.hasCheckedToday ? AppColors.green700 : AppColors.text2,
                  size: 24,
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
                        Text(
                          item.kategoriNama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Minggu ke-${item.siklusKe} (Hari ${item.hariKe}/7)',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: statusBadgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${item.targetMin}-${item.targetMax}x seminggu • Progres: ${item.totalCheckin}x tercatat',
                      style: const TextStyle(fontSize: 12, color: AppColors.text2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card Panduan Takaran & Air (Bukan Cuma Eco Enzyme Saja)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCEDC8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 16, color: AppColors.green700),
                    const SizedBox(width: 6),
                    const Text(
                      'Panduan Takaran & Campuran:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green700,
                      ),
                    ),
                    const Spacer(),
                    if (item.wadahLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.green200),
                        ),
                        child: Text(
                          item.wadahLabel!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.ringkasanTakaran,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rasio Campuran: ${item.rasioLabel} • Air: ${item.airLabel ?? "Sesuai takaran wadah"}',
                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                const Text(
                  '💡 Cukup racik sekali di wadah, gunakan/semprot rutin setiap hari hingga habis.',
                  style: TextStyle(fontSize: 10.5, color: AppColors.green700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Rekomendasi Jeda Waktu (Agar pas 2x seminggu / Rutin terjaga)
          if (item.jadwalRekomendasi != null && item.jadwalRekomendasi!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: item.hasCheckedToday ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item.hasCheckedToday ? const Color(0xFFC8E6C9) : const Color(0xFFFFECB3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.hasCheckedToday ? Icons.check_circle_outline_rounded : Icons.schedule_rounded,
                    size: 16,
                    color: item.hasCheckedToday ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.jadwalRekomendasi!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: item.hasCheckedToday ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Tombol Check-In ("Only Today")
          if (_tracker!.isAktif)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: item.hasCheckedToday ? null : () => _handleCheckin(item),
                icon: Icon(
                  item.hasCheckedToday ? Icons.check_circle_rounded : Icons.check_rounded,
                  size: 18,
                  color: item.hasCheckedToday ? Colors.grey[500] : Colors.white,
                ),
                label: Text(
                  item.hasCheckedToday ? 'Sudah Dicatat Hari Ini' : 'Catat Pemakaian Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: item.hasCheckedToday ? Colors.grey[600] : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFEEEEEE),
                  disabledForegroundColor: Colors.grey[600],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Shortcut ke Kalkulator dan Panduan Pengenceran
  Widget _buildShortcutsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bantuan Takaran & Pengenceran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KalkulatorScreen()),
                    );
                  },
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Kalkulator Dosis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green700,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PanduanPenggunaanPage(
                          initialKategori: _tracker?.product?.kategori,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('Panduan Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green700,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
