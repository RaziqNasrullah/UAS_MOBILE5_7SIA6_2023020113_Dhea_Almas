import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Pesan sukses/error/info seragam memakai Get.snackbar.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Berhasil'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_rounded);

  static void error(String message, {String title = 'Gagal'}) =>
      _show(title, message, AppColors.danger, Icons.error_rounded, seconds: 4);

  static void warning(String message, {String title = 'Perhatian'}) =>
      _show(title, message, AppColors.warning, Icons.warning_amber_rounded, seconds: 3);

  static void info(String message, {String title = 'Info'}) =>
      _show(title, message, AppColors.secondary, Icons.info_rounded);

  static void _show(String title, String message, Color color, IconData icon, {int seconds = 3}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: Duration(seconds: seconds),
      shouldIconPulse: false,
    );
  }
}
