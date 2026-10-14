import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../controllers/produk_detail_controller.dart';
import '../../models/produk.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/jenjang_badge.dart';
import '../../widgets/produk_image.dart';
import '../../widgets/qty_stepper.dart';
import '../../widgets/state_views.dart';

class ProdukDetailView extends GetView<ProdukDetailController> {
  const ProdukDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: const [
          CartBadgeIcon(onPressed: MainController.goToCart),
          SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final p = controller.produk.value;
        if (p == null) {
          return EmptyState(
            title: 'Produk tidak ditemukan',
            message: 'Data produk tidak dikirim ke halaman ini.',
            actionLabel: 'Kembali',
            onAction: Get.back,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshProduk,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ProdukImage(url: p.imageUrl, width: 210, height: 280, borderRadius: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Chip(icon: Icons.category_rounded, label: p.namaKategori),
                        JenjangBadge(jenjang: p.jenjang),
                        if (p.isBestSeller)
                          const _Chip(icon: Icons.star_rounded, label: 'Best Seller', color: AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(p.nama, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${p.labelPenulis}: ${p.penulisMerek}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Formatter.rupiah(p.harga),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    _InfoGrid(produk: p),
                    const SizedBox(height: 18),
                    const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(p.deskripsi, style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 18),
                    if (!p.isHabis) ...[
                      const Text(
                        'Catatan untuk produk ini (opsional)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller.catatanC,
                        maxLength: 255,
                        decoration: InputDecoration(
                          hintText: p.isKelas
                              ? 'Contoh: jadwal sesi sore'
                              : (p.formatProduk == 'Barang Fisik'
                                    ? 'Contoh: warna biru'
                                    : 'Contoh: minta sampul plastik'),
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final p = controller.produk.value;
        if (p == null) return const SizedBox.shrink();
        final sisa = controller.sisaBisaDitambah;
        final habis = p.isHabis;
        final penuhDiKeranjang = !habis && sisa <= 0;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                QtyStepper(
                  value: controller.qty.value,
                  max: sisa < 1 ? 1 : sisa,
                  enabled: !habis && !penuhDiKeranjang,
                  onChanged: controller.setQty,
                  onMaxReached: () => Get.snackbar(
                    'Batas ${p.isKelas ? 'kuota' : 'stok'}',
                    'Maksimal $sisa ${p.satuanStok} lagi yang bisa ditambahkan.',
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: habis || penuhDiKeranjang || controller.isAdding.value ? null : controller.addToCart,
                    icon: controller.isAdding.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(habis ? Icons.block_rounded : Icons.add_shopping_cart_rounded),
                    label: Text(
                      habis ? p.labelHabis : (penuhDiKeranjang ? 'Maks. di Keranjang' : 'Tambah ke Keranjang'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.color = AppColors.secondary});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.produk});

  final Produk produk;

  @override
  Widget build(BuildContext context) {
    final p = produk;
    final stokColor = p.isHabis ? AppColors.danger : (p.stok <= 5 ? AppColors.warning : AppColors.success);
    final items = <(IconData, String, String, Color?)>[
      (
        p.isKelas ? Icons.groups_rounded : Icons.inventory_2_rounded,
        p.labelStok,
        p.isHabis ? p.labelHabis : '${p.stok} ${p.satuanStok}',
        stokColor,
      ),
      (Icons.auto_stories_rounded, 'Format', p.formatProduk, null),
      (Icons.straighten_rounded, 'Detail', p.detailTambahan ?? '-', null),
      (Icons.school_rounded, 'Jenjang', p.jenjang, AppColors.jenjang(p.jenjang)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.7,
      children: [
        for (final it in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(it.$1, color: it.$4 ?? AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.$2, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        it.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: it.$4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
