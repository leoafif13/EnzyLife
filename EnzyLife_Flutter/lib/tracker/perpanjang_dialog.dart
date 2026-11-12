import 'package:flutter/material.dart';
import '../app_color.dart';
import '../services/api_service.dart';

class PerpanjangDialog extends StatefulWidget {
  final int trackerId;
  final VoidCallback? onSuccess;

  const PerpanjangDialog({
    Key? key,
    required this.trackerId,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<PerpanjangDialog> createState() => _PerpanjangDialogState();
}

class _PerpanjangDialogState extends State<PerpanjangDialog> {
  int _durasiMinggu = 1;
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final res = await ApiService.perpanjangTracker(
      trackerId: widget.trackerId,
      durasiTambahanMinggu: _durasiMinggu,
    );

    setState(() => _isLoading = false);

    if (res != null && res['success'] == true) {
      if (mounted) {
        Navigator.pop(context, true);
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracker berhasil diperpanjang $_durasiMinggu minggu! 🔄'),
            backgroundColor: AppColors.green700,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal memperpanjang tracker'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.update_rounded, color: Colors.blueAccent, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Perpanjang Tracking',
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
            const Text(
              'Masih ingin mendampingi pemakaian produk untuk melihat hasil lebih maksimal? Anda bisa memperpanjang masa tracking hingga 2 minggu lagi (maks total 5 minggu).',
              style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Durasi Perpanjangan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceCard(
                    minggu: 1,
                    label: '+1 Minggu',
                    sublabel: 'Total 4 Minggu',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceCard(
                    minggu: 2,
                    label: '+2 Minggu',
                    sublabel: 'Total 5 Minggu (Maks)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                        'Konfirmasi Perpanjangan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required int minggu,
    required String label,
    required String sublabel,
  }) {
    final isSelected = _durasiMinggu == minggu;
    return InkWell(
      onTap: () => setState(() => _durasiMinggu = minggu),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green50 : AppColors.bgPage,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.green500 : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.green500 : AppColors.text3,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.green700 : AppColors.text1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.green700 : AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
