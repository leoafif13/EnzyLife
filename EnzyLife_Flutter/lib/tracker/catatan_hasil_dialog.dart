import 'package:flutter/material.dart';
import '../app_color.dart';
import '../services/api_service.dart';

class CatatanHasilDialog extends StatefulWidget {
  final int trackerId;
  final Function(String? catatanHasil)? onSelesai;

  const CatatanHasilDialog({
    Key? key,
    required this.trackerId,
    this.onSelesai,
  }) : super(key: key);

  @override
  State<CatatanHasilDialog> createState() => _CatatanHasilDialogState();
}

class _CatatanHasilDialogState extends State<CatatanHasilDialog> {
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final catatan = _catatanController.text.trim().isNotEmpty
        ? _catatanController.text.trim()
        : null;

    final res = await ApiService.selesaiTracker(
      trackerId: widget.trackerId,
      catatanHasil: catatan,
    );

    setState(() => _isLoading = false);

    if (res != null && res['success'] == true) {
      if (mounted) {
        Navigator.pop(context, true);
        widget.onSelesai?.call(catatan);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal menyelesaikan tracking'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
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
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_rounded, color: AppColors.green700, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Selesaikan Tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.text3),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.stars_rounded, color: AppColors.green700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selamat! Anda berhak mendapatkan badge "Ulasan Terverifikasi ✅" pada ulasan produk ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.green700,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catatan Hasil Akhir Pemakaian',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text2),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _catatanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ceritakan hasil akhir pemakaian produk selama tracking (misal: tanaman bertambah subur, lantai tidak berminyak, dll)...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.hint),
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
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Selesai & Lanjut Ulasan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
