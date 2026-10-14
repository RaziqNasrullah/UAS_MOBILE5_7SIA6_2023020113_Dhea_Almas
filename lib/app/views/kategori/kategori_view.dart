import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/state_views.dart';

class KategoriView extends GetView<KategoriController> {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.kategoriList.isEmpty) {
          return const LoadingView(message: 'Memuat kategori...');
        }
        final err = controller.errorMessage.value;
        if (err != null) return ErrorState(message: err, onRetry: controller.fetchKategori);
        if (controller.kategoriList.isEmpty) {
          return EmptyState(
            icon: Icons.category_outlined,
            title: 'Belum ada kategori',
            actionLabel: 'Tambah Kategori',
            onAction: () => controller.openForm(),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchKategori,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: controller.kategoriList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final k = controller.kategoriList[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.sky.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(CategoryChip.iconFor(k.ikon), color: AppColors.primary),
                  ),
                  title: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (k.deskripsi != null)
                        Text(
                          k.deskripsi!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        '${k.jumlahProduk} produk',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Ubah',
                        icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                        onPressed: () => controller.openForm(k),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        onPressed: () => controller.delete(k),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
