import 'package:flutter/material.dart';

// ══════════════════════════════════════════════
//  AppColors — satu sumber warna untuk seluruh app
//  Import di tiap file: import '../app_colors.dart';
//  atau sesuaikan path relatifnya
// ══════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Green palette
  static const green900 = Color(0xFF1B5E20);
  static const green700 = Color(0xFF388E3C);
  static const green500 = Color(0xFF4CAF50);
  static const green200 = Color(0xFFA5D6A7);
  static const green50  = Color(0xFFE8F5E9);

  // Neutral
  static const bgPage   = Color(0xFFF5F5F5);
  static const bgCard   = Colors.white;
  static const text1    = Color(0xFF1A1A1A);
  static const text2    = Color(0xFF555555);
  static const text3    = Color(0xFF757575);
  static const divider  = Color(0xFFF0F0F0);
  static const border   = Color(0xFFE0E0E0);
  static const hint     = Color(0xFFBDBDBD);

  // Shadow helper
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get heroShadow => [
    BoxShadow(
      color: green900.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}