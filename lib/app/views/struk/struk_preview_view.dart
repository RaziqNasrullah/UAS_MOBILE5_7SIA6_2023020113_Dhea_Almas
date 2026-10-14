import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../controllers/struk_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/state_views.dart';

/// Preview struk PDF + simpan ke perangkat + bagikan.
class StrukPreviewView extends GetView<StrukController> {
  const StrukPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = controller.pesanan.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(p == null ? 'Struk' : 'Struk ${p.nomorPesanan}'),
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            onPressed: p == null ? null : controller.bagikan,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: p == null
          ? EmptyState(title: 'Data struk tidak tersedia', actionLabel: 'Kembali', onAction: Get.back)
          : PdfPreview(
              build: (_) => controller.buildPdf(),
              pdfFileName: controller.fileName,
              allowPrinting: true,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              scrollViewDecoration: const BoxDecoration(color: AppColors.background),
              loadingWidget: const LoadingView(message: 'Menyiapkan struk...'),
              onError: (_, error) => ErrorState(message: 'Gagal membuat PDF: $error', onRetry: () => Get.back()),
            ),
      bottomNavigationBar: p == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => controller.savedPath.value == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Tersimpan: ${controller.savedPath.value}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.success),
                              ),
                            ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isSaving.value ? null : controller.simpan,
                              icon: const Icon(Icons.download_rounded),
                              label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan ke Perangkat'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: controller.bagikan,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Bagikan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
