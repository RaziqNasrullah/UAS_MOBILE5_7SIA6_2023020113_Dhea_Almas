import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/main_controller.dart';
import '../../data/services/api_config.dart';
import '../../models/produk.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/produk_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _bukaKatalog({int? kategoriId}) {
    if (Get.isRegistered<KatalogController>()) {
      Get.find<KatalogController>().selectKategori(kategoriId);
    }
    MainController.goToTab(MainController.tabKatalog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAll(silent: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(onSearch: () => _bukaKatalog())),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value && controller.bestSellerList.isEmpty) {
                  return const SizedBox(height: 320, child: LoadingView(message: 'Memuat katalog NeoLearn...'));
                }
                final err = controller.errorMessage.value;
                if (err != null && controller.bestSellerList.isEmpty) {
                  return SizedBox(
                    height: 420,
                    child: ErrorState(message: err, onRetry: controller.fetchAll),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Kategori', actionLabel: 'Semua', onAction: () => _bukaKatalog()),
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.kategoriList.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final k = controller.kategoriList[i];
                          return _KategoriTile(
                            nama: k.nama,
                            jumlah: k.jumlahProduk,
                            icon: CategoryChip.iconFor(k.ikon),
                            color: _warnaKategori(i),
                            onTap: () => _bukaKatalog(kategoriId: k.id),
                          );
                        },
                      ),
                    ),
                    const _PromoBanner(),
                    SectionHeader(
                      title: 'Best Seller',
                      subtitle: 'Paling banyak dicari pelajar & mahasiswa',
                      actionLabel: 'Lihat',
                      onAction: () => _bukaKatalog(),
                    ),
                    _HorizontalProduk(list: controller.bestSellerList),
                    const SectionHeader(title: 'Produk Terbaru', subtitle: 'Baru masuk di NeoLearn'),
                    _HorizontalProduk(list: controller.terbaruList),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  static Color _warnaKategori(int i) {
    const c = [Color(0xFFEF7B45), AppColors.secondary, AppColors.mint, Color(0xFF7B5CC7)];
    return c[i % c.length];
  }
}

class _Header extends GetView<HomeController> {
  const _Header({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Image.asset('assets/images/logo_mark.png', width: 32, height: 32),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ApiConfig.namaToko,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text('Toko Buku & Perlengkapan Belajar', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ],
                ),
              ),
              const CartBadgeIcon(onPressed: MainController.goToCart),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() {
            final now = controller.now.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Sapaan.judul(now),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(Sapaan.pesan(now), style: const TextStyle(color: Colors.white, fontSize: 13.5)),
              ],
            );
          }),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onSearch,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Cari buku, alat tulis, atau kelas...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KategoriTile extends StatelessWidget {
  const _KategoriTile({
    required this.nama,
    required this.jumlah,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String nama;
  final int jumlah;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, height: 1.2),
                ),
                Text('$jumlah produk', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFE3C4), Color(0xFFFFF4E6)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: AppColors.accent, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diskon Pelajar 10%',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF9A5A1C)),
                ),
                Text(
                  'Untuk belanja minimal ${Formatter.rupiah(ApiConfig.minSubtotalDiskon)}. Otomatis saat checkout!',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7A4A1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalProduk extends StatelessWidget {
  const _HorizontalProduk({required this.list});

  final List<Produk> list;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Belum ada produk.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SizedBox(
      height: 272,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ProdukCard(
          width: 158,
          produk: list[i],
          onTap: () => Get.toNamed(Routes.produkDetail, arguments: list[i]),
        ),
      ),
    );
  }
}
