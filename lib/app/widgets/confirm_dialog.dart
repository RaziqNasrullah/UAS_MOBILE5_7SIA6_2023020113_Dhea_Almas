import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Dialog konfirmasi (Get.dialog). Mengembalikan true jika pengguna setuju.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  String cancelLabel = 'Batal',
  Color confirmColor = AppColors.primary,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: Icon(icon, color: confirmColor, size: 36),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text(cancelLabel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor, minimumSize: const Size(100, 44)),
          onPressed: () => Get.back(result: true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
