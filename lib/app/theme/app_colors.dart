import 'package:flutter/material.dart';

/// Palet warna NeoLearn, diambil dari logo (teal tua, biru, biru muda, peach, mint).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B5E6E);
  static const Color primaryDark = Color(0xFF124754);
  static const Color secondary = Color(0xFF2A6A93);
  static const Color accent = Color(0xFFF4A259);
  static const Color mint = Color(0xFF5CC2A7);
  static const Color sky = Color(0xFFBDE8F7);
  static const Color background = Color(0xFFF3F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2D3A);
  static const Color textSecondary = Color(0xFF5E6E7C);
  static const Color border = Color(0xFFDCE7EE);

  static const Color success = Color(0xFF2E9E6A);
  static const Color warning = Color(0xFFE59A0B);
  static const Color danger = Color(0xFFE5484D);

  /// Warna badge per jenjang pendidikan.
  static Color jenjang(String jenjang) {
    switch (jenjang) {
      case 'SD':
        return const Color(0xFFEF7B45);
      case 'SMP':
        return const Color(0xFF2E9E6A);
      case 'SMA/SMK':
        return const Color(0xFF2A6A93);
      case 'Perguruan Tinggi':
        return const Color(0xFF7B5CC7);
      default:
        return const Color(0xFF4F7A84);
    }
  }

  /// Warna status pesanan.
  static Color status(String status) {
    switch (status) {
      case 'Selesai':
        return success;
      case 'Dibatalkan':
        return danger;
      default:
        return warning;
    }
  }
}
