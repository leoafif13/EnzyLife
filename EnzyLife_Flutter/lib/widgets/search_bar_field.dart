import 'package:flutter/material.dart';
import '../app_color.dart';

// ══════════════════════════════════════════════
//  SearchBarField — TextField search standar
//  dengan styling konsisten di seluruh app.
//
//  Cara pakai (tanpa clear button):
//    SearchBarField(
//      controller: _controller,
//      hintText: 'Cari produk...',
//      onChanged: (v) => setState(() => _query = v),
//    )
//
//  Cara pakai (dengan clear button):
//    SearchBarField(
//      controller: _controller,
//      hintText: 'Cari artikel...',
//      onChanged: (v) => setState(() => _query = v),
//      showClearButton: _query.isNotEmpty,
//      onClear: () { setState(() => _query = ''); _controller.clear(); },
//    )
// ══════════════════════════════════════════════
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  /// Tampilkan tombol X untuk menghapus query
  final bool showClearButton;

  /// Callback saat tombol X ditekan
  final VoidCallback? onClear;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.showClearButton = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.text1),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint, size: 20),
        suffixIcon: showClearButton
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.hint),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.bgPage,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
