import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class UlasanScreen extends StatefulWidget {
  final String productName;
  final String orderId;

  const UlasanScreen({
    super.key,
    required this.productName,
    required this.orderId,
  });

  @override
  State<UlasanScreen> createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  int _rating          = 0;
  bool _isLoading      = false;
  final _ulasanCtrl    = TextEditingController();
  final List<String>   _selectedTags = [];

  // Tag cepat
  static const _quickTags = [
    'Produk sesuai deskripsi',
    'Pengiriman cepat',
    'Kemasan aman',
    'Kualitas bagus',
    'Seller responsif',
    'Harga worth it',
    'Akan beli lagi',
    'Aroma segar',
  ];

  static const _ratingLabels = ['', 'Sangat Buruk', 'Buruk', 'Cukup', 'Bagus', 'Sangat Bagus'];

  @override
  void dispose() {
    _ulasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih rating terlebih dahulu'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // TODO: POST ke API ulasan
    setState(() => _isLoading = false);

    if (!mounted) return;

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
              child: const Icon(Icons.check_circle_outline_rounded,
                  size: 40, color: AppColors.green500),
            ),
            const SizedBox(height: 16),
            const Text('Ulasan Terkirim!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.text1)),
            const SizedBox(height: 8),
            Text('Terima kasih atas ulasanmu. Ulasanmu sangat membantu pembeli lain.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // kembali ke riwayat belanja
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Tulis Ulasan'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Info produk ─────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 56, height: 56,
                            color: AppColors.green50,
                            child: Icon(Icons.image_outlined, size: 24,
                                color: AppColors.green500.withOpacity(0.3)),
                            // TODO: gambar produk
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.productName,
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700, color: AppColors.text1)),
                              const SizedBox(height: 4),
                              Text('Order #${widget.orderId}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Rating bintang ──────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Text('Seberapa puas kamu dengan produk ini?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.text1)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final star = i + 1;
                            return GestureDetector(
                              onTap: () => setState(() => _rating = star),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedScale(
                                  scale: _rating >= star ? 1.2 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(
                                    _rating >= star
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 40,
                                    color: _rating >= star
                                        ? const Color(0xFFFFC107)
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: _rating > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _rating > 0 ? _ratingLabels[_rating] : '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.green500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Tag cepat ───────────────────────
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
                        const Text('Pilih yang sesuai (opsional)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.text1)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _quickTags.map((tag) {
                            final selected = _selectedTags.contains(tag);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (selected) _selectedTags.remove(tag);
                                else _selectedTags.add(tag);
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.green500 : AppColors.bgPage,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? AppColors.green500 : AppColors.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: selected
                                          ? FontWeight.w600 : FontWeight.w400,
                                      color: selected ? Colors.white : AppColors.text2,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Tulis ulasan ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ceritakan pengalamanmu',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.text1)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ulasanCtrl,
                          maxLines: 5,
                          maxLength: 500,
                          style: const TextStyle(fontSize: 13, color: AppColors.text1),
                          decoration: InputDecoration(
                            hintText: 'Tulis ulasanmu di sini... (opsional)\n\nContoh: Produknya sesuai deskripsi, kemasan rapi, dan aroma eco enzim-nya segar. Akan beli lagi!',
                            hintStyle: TextStyle(color: Colors.grey[400],
                                fontSize: 13, height: 1.5),
                            filled: true,
                            fillColor: AppColors.bgPage,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.green500, width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Upload foto placeholder
                        GestureDetector(
                          onTap: () {}, // TODO: image picker
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.border,
                                  style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 28, color: Colors.grey[400]),
                                const SizedBox(height: 6),
                                Text('Tambah Foto (opsional)',
                                    style: TextStyle(fontSize: 12,
                                        color: Colors.grey[500])),
                                Text('Maks. 3 foto, format JPG/PNG',
                                    style: TextStyle(fontSize: 11,
                                        color: Colors.grey[400])),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol kirim ─────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                  blurRadius: 12, offset: const Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.green500.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5,
                            color: Colors.white))
                    : const Text('Kirim Ulasan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}