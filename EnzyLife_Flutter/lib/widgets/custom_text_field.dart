import 'package:flutter/material.dart';
import '../app_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green900)),
      const SizedBox(height: 6),
      TextField(
        controller: controller, keyboardType: keyboardType, maxLines: maxLines,
        readOnly: readOnly,
        textInputAction: textInputAction,
        style: const TextStyle(fontSize: 13, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
          prefixIcon: maxLines == 1 ? Icon(icon, color: readOnly ? Colors.grey[400] : AppColors.green500, size: 18) : null,
          filled: true,
          fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: maxLines > 1 ? 14 : 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border.withAlpha(120), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.green500, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border.withAlpha(120), width: 1.0),
          ),
        ),
      ),
    ],
  );
}
