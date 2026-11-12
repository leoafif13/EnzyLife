import 'package:flutter/material.dart';
import '../app_color.dart';
import '../models/user_routine.dart';
import '../services/api_service.dart';
import '../widgets/sub_page_appbar.dart';
import 'routine_setup_sheet.dart';
import 'weekly_recap_dialog.dart';
import 'panduan_penggunaan_page.dart';
import '../profil/riwayat_belanja_page.dart';

class RoutineTrackerPage extends StatefulWidget {
  final int? pemesananId;
  final int? produkId;

  const RoutineTrackerPage({
    super.key,
    this.pemesananId,
    this.produkId,
  });

  @override
  State<RoutineTrackerPage> createState() => _RoutineTrackerPageState();
}

class _RoutineTrackerPageState extends State<RoutineTrackerPage> {
  RoutineDashboardData? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getRoutineDashboard();
    if (mounted) {
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    }
  }

  void _openSetupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoutineSetupSheet(
        pemesananId: widget.pemesananId,
        produkId: widget.produkId,
        onSuccess: _loadDashboard,
      ),
    );
  }

  void _openWeeklyRecap() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WeeklyRecapDialog(
        onCompleted: _loadDashboard,
      ),
    );
  }

  Future<void> _handleCheckin(UserRoutineItem item) async {
    if (item.hasCheckedToday) {
      // Opsi untuk batalkan
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
          _loadDashboard();
        }
      }
      return;
    }

    // Eksekusi Check-in
    final res = await ApiService.routineCheckin(item.id);
    if (res != null && res['success'] == true) {
      _loadDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Catatan pemakaian disimpan! ✨'),
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
        title: 'Tracker Rutinitas',
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.text1),
            tooltip: 'Atur Rutinitas',
            onPressed: _openSetupSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green500),
            )
          : (_dashboard == null || !_dashboard!.hasRoutines)
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.green500,
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCycleCard(),
                        const SizedBox(height: 16),
                        if (_dashboard!.isRecapReady) ...[
                          _buildRecapReadyBanner(),
                          const SizedBox(height: 16),
                        ],
                        _buildVolumeForecastCard(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rutinitas Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text1,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PanduanPenggunaanPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.menu_book_rounded, size: 16),
                              label: const Text('Panduan Rasio', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: AppColors.green700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._dashboard!.routines.map((item) => _buildRoutineCard(item)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.track_changes_rounded, size: 54, color: AppColors.green500),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Rutinitas Aktif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text1),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bangun kebiasaan ramah lingkungan dengan memantau pemakaian Eco Enzyme per siklus 7 hari.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openSetupSheet,
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text('Mulai Setup Rutinitas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCycleCard() {
    final d = _dashboard!;
    final progress = (d.hariKe / 7.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Siklus ${d.siklusKe} Mingguan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green700,
                  ),
                ),
              ),
              if (d.canUnlockVerifiedReview)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFFF57F17)),
                      SizedBox(width: 4),
                      Text(
                        'Minggu ke-3 Tercapai ✅',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF57F17)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hari ke-${d.hariKe} dari 7 Hari',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check-in pemakaian secara rutin untuk menjaga kebersihan rumah & kesehatan lingkungan.',
            style: TextStyle(fontSize: 12.5, color: AppColors.text3),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgPage,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapReadyBanner() {
    final d = _dashboard!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green500, width: 1.2),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekap Siklus ${d.siklusKe} Sudah Siap!',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.green700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lihat estimasi volume terpakai dan prediksi sisa botol.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF2E7D32)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _openWeeklyRecap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green500,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Buka Rekap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeForecastCard() {
    final d = _dashboard!;
    final sisaMinggu = d.prediksiSisaMinggu != null
        ? '${d.prediksiSisaMinggu!.toStringAsFixed(1)} minggu'
        : '-';

    final isStokMenipis = d.prediksiSisaMinggu != null && d.prediksiSisaMinggu! <= 1.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.opacity_rounded, color: AppColors.green500, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Estimasi Pemakaian & Stok',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.text1),
              ),
              const Spacer(),
              if (isStokMenipis)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Stok Menipis',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Terpakai Siklus Ini', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                    const SizedBox(height: 2),
                    Text(
                      '±${d.totalTerpakaiSiklusMl.toStringAsFixed(0)} ml',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.green700),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sisa Stok Botol', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                    const SizedBox(height: 2),
                    Text(
                      '±${d.stokSisaMl.toStringAsFixed(0)} ml (~$sisaMinggu)',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.text1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isStokMenipis) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Stok Anda diprediksi habis dalam 1 minggu.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.text2),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiwayatBelanjaScreen()),
                    );
                  },
                  child: const Text('Beli Botol Lagi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineCard(UserRoutineItem item) {
    IconData icon;
    if (item.kategoriNama.contains('Dapur')) {
      icon = Icons.kitchen_rounded;
    } else if (item.kategoriNama.contains('Pel')) {
      icon = Icons.cleaning_services_rounded;
    } else if (item.kategoriNama.contains('Tanaman')) {
      icon = Icons.yard_rounded;
    } else if (item.kategoriNama.contains('Piring')) {
      icon = Icons.water_drop_rounded;
    } else {
      icon = Icons.plumbing_rounded;
    }

    final double progressRatio = item.targetMax > 0
        ? (item.totalCheckin / item.targetMax).clamp(0.0, 1.0)
        : 0.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.hasCheckedToday ? AppColors.green500.withValues(alpha: 0.4) : AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(
                      item.kategoriNama,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.tipeTarget} • ±${item.takaranMlPerPakai.toStringAsFixed(0)} ml/pakai',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.text3),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.hasCheckedToday ? AppColors.green50 : AppColors.bgPage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.hasCheckedToday ? AppColors.green700 : AppColors.text3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.targetProgressText,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text2),
              ),
              if (item.daysSinceLast != null && item.daysSinceLast! > 1)
                Text(
                  'Terakhir ${item.daysSinceLast} hari lalu',
                  style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: AppColors.bgPage,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green500),
            ),
          ),
          const SizedBox(height: 14),

          // Tombol 1-tap Checkin
          SizedBox(
            width: double.infinity,
            height: 42,
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
}
