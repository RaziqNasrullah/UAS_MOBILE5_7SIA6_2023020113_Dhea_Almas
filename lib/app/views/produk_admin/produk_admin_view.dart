import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/produk_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/jenjang_badge.dart';
import '../../widgets/produk_image.dart';
import '../../widgets/state_views.dart';

/// Daftar produk admin. Nama kategori berasal dari query JOIN di server.
class ProdukAdminView extends GetView<ProdukController> {
  const ProdukAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => controller.search.value = v,
              decoration: const InputDecoration(
                hintText: 'Cari produk / penulis / merek',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.produkList.isEmpty) {
                return const LoadingView(message: 'Memuat produk...');
              }
              final err = controller.errorMessage.value;
              if (err != null) return ErrorState(message: err, onRetry: controller.fetchProduk);
              if (controller.produkList.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Produk tidak ditemukan',
                  actionLabel: 'Tambah Produk',
                  onAction: () => controller.openForm(),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchProduk,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: controller.produkList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = controller.produkList[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ProdukImage(url: p.imageUrl, width: 58, height: 76, borderRadius: 8),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.nama,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.namaKategori,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        Formatter.rupiah(p.harga),
                                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        p.isHabis ? p.labelHabis : '${p.labelStok}: ${p.stok}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: p.isHabis ? AppColors.danger : AppColors.textSecondary,
                                          fontWeight: p.isHabis ? FontWeight.w700 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      JenjangBadge(jenjang: p.jenjang, compact: true),
                                      if (p.isBestSeller)
                                        const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  tooltip: 'Ubah',
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                                  onPressed: () => controller.openForm(p),
                                ),
                                IconButton(
                                  tooltip: 'Hapus',
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                  onPressed: () => controller.delete(p),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
