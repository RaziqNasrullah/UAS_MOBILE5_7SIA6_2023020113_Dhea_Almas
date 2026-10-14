import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/katalog_controller.dart';
import '../../controllers/main_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/produk_card.dart';
import '../../widgets/state_views.dart';

/// Katalog: GridView + pencarian realtime (Obx + debounce) + filter ChoiceChip.
class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog'),
        actions: const [
          CartBadgeIcon(onPressed: MainController.goToCart),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Obx(
              () => TextField(
                controller: controller.searchC,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, atau merek...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: controller.clearSearch,
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      label: 'Semua',
                      icon: Icons.apps_rounded,
                      selected: controller.selectedKategoriId.value == null,
                      onSelected: () => controller.selectKategori(null),
                    ),
                  ),
                  for (final k in controller.kategoriList)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CategoryChip(
                        label: k.nama,
                        icon: CategoryChip.iconFor(k.ikon),
                        selected: controller.selectedKategoriId.value == k.id,
                        onSelected: () => controller.selectKategori(k.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.produkList.isEmpty) {
                return const LoadingView(message: 'Mencari produk...');
              }
              final err = controller.errorMessage.value;
              if (err != null) {
                return ErrorState(message: err, onRetry: controller.refreshAll);
              }
              if (controller.produkList.isEmpty) {
                final q = controller.searchQuery.value;
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Produk tidak ditemukan',
                  message: q.isEmpty
                      ? 'Belum ada produk di kategori ${controller.selectedKategoriNama}.'
                      : 'Tidak ada hasil untuk "$q" di kategori ${controller.selectedKategoriNama}.',
                  actionLabel: 'Reset Filter',
                  onAction: () {
                    controller.clearSearch();
                    controller.selectKategori(null);
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchProduk(silent: true),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                        child: Row(
                          children: [
                            Text(
                              '${controller.produkList.length} produk',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '- ${controller.selectedKategoriNama}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            if (controller.isLoading.value)
                              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate((_, i) {
                          final p = controller.produkList[i];
                          return ProdukCard(
                            produk: p,
                            onTap: () => Get.toNamed(Routes.produkDetail, arguments: p),
                          );
                        }, childCount: controller.produkList.length),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
