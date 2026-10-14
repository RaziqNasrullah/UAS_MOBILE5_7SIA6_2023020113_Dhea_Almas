import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/main_controller.dart';
import '../../data/services/api_config.dart';
import '../../models/keranjang_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/biaya_calculator.dart';
import '../../utils/formatter.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/produk_image.dart';
import '../../widgets/qty_stepper.dart';
import '../../widgets/state_views.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Keranjang (${controller.totalQty})')),
        actions: [
          Obx(
            () => controller.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Kosongkan keranjang',
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        title: 'Kosongkan keranjang?',
                        message: 'Semua produk di keranjang akan dihapus.',
                        confirmLabel: 'Kosongkan',
                        confirmColor: AppColors.danger,
                        icon: Icons.delete_sweep_outlined,
                      );
                      if (ok) controller.clearCart();
                    },
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const LoadingView(message: 'Memuat keranjang...');
        }
        final err = controller.errorMessage.value;
        if (err != null && controller.items.isEmpty) {
          return ErrorState(message: err, onRetry: controller.fetchCart);
        }
        if (controller.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang masih kosong',
            message: 'Yuk pilih buku, alat tulis, atau kelas favoritmu.',
            actionLabel: 'Jelajahi Katalog',
            onAction: () => MainController.goToTab(MainController.tabKatalog),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchCart(silent: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _CartItemCard(item: controller.items[i]),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) return const SizedBox.shrink();
        final total = controller.totalHarga;
        final kurang = BiayaCalculator.kurangUntukDiskon(total);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: kurang > 0 ? const Color(0xFFFFF4E6) : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  kurang > 0
                      ? 'Tambah ${Formatter.rupiah(kurang)} lagi untuk diskon pelajar ${ApiConfig.diskonPersen.toInt()}%'
                      : 'Selamat! Kamu dapat diskon pelajar ${ApiConfig.diskonPersen.toInt()}% saat checkout',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kurang > 0 ? const Color(0xFF9A5A1C) : AppColors.success,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total (${controller.totalQty} item)',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                        Text(
                          Formatter.rupiah(total),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.checkout),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Checkout'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CartItemCard extends GetView<CartController> {
  const _CartItemCard({required this.item});

  final KeranjangItem item;

  Future<void> _editCatatan() async {
    final c = TextEditingController(text: item.catatanItem ?? '');
    final hasil = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Catatan Item'),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 255,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: item.isKelas ? 'Contoh: jadwal sesi sore' : 'Contoh: minta sampul plastik / warna biru',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(90, 42)),
            onPressed: () => Get.back(result: c.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (hasil != null) await controller.updateCatatan(item, hasil);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.busyIds.contains(item.id);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProdukImage(url: item.imageUrl, width: 70, height: 92, borderRadius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.namaKategori} - ${item.formatProduk}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Formatter.rupiah(item.harga)} / item',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                        Text(
                          '${item.isKelas ? 'Sisa kuota' : 'Stok'}: ${item.stok}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: item.melebihiStok ? AppColors.danger : AppColors.textSecondary,
                            fontWeight: item.melebihiStok ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: busy
                        ? null
                        : () async {
                            final ok = await showConfirmDialog(
                              title: 'Hapus produk?',
                              message: '"${item.nama}" akan dihapus dari keranjang.',
                              confirmLabel: 'Hapus',
                              confirmColor: AppColors.danger,
                              icon: Icons.delete_outline_rounded,
                            );
                            if (ok) controller.removeItem(item);
                          },
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _editCatatan,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.catatanItem ?? 'Tambah catatan (opsional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: item.catatanItem == null ? AppColors.textSecondary : AppColors.textPrimary,
                            fontStyle: item.catatanItem == null ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit_rounded, size: 16, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  QtyStepper(
                    value: item.jumlah,
                    max: item.stok,
                    enabled: !busy,
                    onChanged: (v) => v > item.jumlah ? controller.increment(item) : controller.decrement(item),
                    onMaxReached: () => controller.increment(item),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        Formatter.rupiah(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
