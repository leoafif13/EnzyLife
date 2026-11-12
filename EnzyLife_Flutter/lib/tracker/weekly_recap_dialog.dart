import 'package:flutter/material.dart';
import '../app_color.dart';
import '../models/weekly_recap.dart';
import '../services/api_service.dart';

class WeeklyRecapDialog extends StatefulWidget {
  final int? trackerId;
  final VoidCallback? onCompleted;

  const WeeklyRecapDialog({
    super.key,
    this.trackerId,
    this.onCompleted,
  });

  @override
  State<WeeklyRecapDialog> createState() => _WeeklyRecapDialogState();
}

class _WeeklyRecapDialogState extends State<WeeklyRecapDialog> {
  WeeklyRecapData? _recapData;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _selectedChip = '✨ Efektif';
  final _catatanController = TextEditingController();

  final List<String> _chips = [
    '🌟 Sangat Efektif',
    '✨ Efektif',
    '👌 Cukup Efektif',
    '⏳ Belum Terlihat Efek',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecap();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadRecap() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getWeeklyRecap(trackerId: widget.trackerId);
    if (mounted) {
      setState(() {
        _recapData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRecap({bool tandaiSelesai = false}) async {
    setState(() => _isSubmitting = true);
    final res = await ApiService.submitWeeklyRecap(
      trackerId: widget.trackerId,
      chipFeedback: _selectedChip,
      catatanRefleksi: _catatanController.text.trim(),
      tandaiSelesai: tandaiSelesai,
    );
    setState(() => _isSubmitting = false);

    if (res != null && res['success'] == true) {
      if (mounted) {
        Navigator.pop(context, true);
        widget.onCompleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Rekap mingguan disimpan!'),
            backgroundColor: AppColors.green700,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal menyimpan rekap'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.green500),
              SizedBox(height: 16),
              Text('Menghitung rekap mingguan...'),
            ],
          ),
        ),
      );
    }

    if (_recapData == null) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 40, color: AppColors.text3),
              const SizedBox(height: 12),
              const Text('Data rekap belum tersedia atau siklus belum selesai.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green500),
                child: const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final data = _recapData!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🎉', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rekap Siklus ${data.siklusKe} Selesai!',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text1,
                          ),
                        ),
                        Text(
                          'Evaluasi pemakaian 7 hari (${data.tanggalMulai} - ${data.tanggalSelesai})',
                          style: const TextStyle(fontSize: 11, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.text3),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Banner Ulasan Terverifikasi jika Siklus 3
              if (data.canUnlockVerifiedReview) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: Color(0xFFF57F17), size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hebat! Anda telah menuntaskan 3 Minggu. Anda berhak mendapat badge "Ulasan Terverifikasi ✅".',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Card Status Tiap Kategori
              const Text(
                'Hasil Pemakaian Kategori:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1),
              ),
              const SizedBox(height: 8),
              ...data.items.map((it) {
                Color statusBg;
                Color statusColor;
                switch (it.statusPencapaian) {
                  case 'OPTIMAL':
                    statusBg = AppColors.green50;
                    statusColor = AppColors.green700;
                    break;
                  case 'TERCAPAI':
                    statusBg = const Color(0xFFE8F5E9);
                    statusColor = const Color(0xFF2E7D32);
                    break;
                  case 'BELUM_TERCAPAI':
                    statusBg = const Color(0xFFFFF3E0);
                    statusColor = const Color(0xFFE65100);
                    break;
                  default:
                    statusBg = AppColors.bgPage;
                    statusColor = AppColors.text2;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.kategoriNama,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${it.totalCheckin}x dipakai • Est. ${it.estimasiMlTerpakai.toStringAsFixed(0)} ml',
                              style: const TextStyle(fontSize: 11, color: AppColors.text3),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          it.statusDisplayLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Ringkasan Pencapaian Rutinitas 1 Minggu
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.green200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_outlined, color: AppColors.green700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Siklus Minggu ke-${data.siklusKe} Tuntas!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kebiasaan pemakaian Anda tercatat dengan baik selama 7 hari.',
                            style: TextStyle(fontSize: 11.5, color: AppColors.text2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Catatan Efektivitas Produk
              const Text(
                'Catatan Efektivitas Produk:',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.text1),
              ),
              const SizedBox(height: 2),
              const Text(
                'Bagaimana efektivitas produk yang Anda rasakan selama 1 minggu pemakaian ini?',
                style: TextStyle(fontSize: 11.5, color: AppColors.text3),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _chips.map((chip) {
                  final isSelected = _selectedChip == chip;
                  return ChoiceChip(
                    label: Text(chip),
                    selected: isSelected,
                    selectedColor: AppColors.green500,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                    backgroundColor: AppColors.bgPage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedChip = chip);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Input Catatan Efektivitas Produk
              TextField(
                controller: _catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan efektivitas produk secara menyeluruh atau per kategori (misal: pakaian lebih bersih & wangi, minyak rontok, bau ruangan hilang, dsb.)...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.hint, height: 1.3),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.green500, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Mulai Siklus Berikutnya / Selesai Mandiri
              if (data.siklusKe >= 4) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitRecap(tandaiSelesai: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Selesai & Mandiri Tanpa Dipandu 🏆',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitRecap(tandaiSelesai: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Mulai Siklus ${data.siklusKe + 1} 🚀',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                if (data.siklusKe >= 3) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => _submitRecap(tandaiSelesai: true),
                      child: const Text(
                        'Saya Sudah Terbiasa Mandiri (Selesaikan Tracker)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
