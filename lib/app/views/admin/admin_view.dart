import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../data/services/api_config.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Menu admin toko: dashboard, kelola kategori, kelola produk, cek server.
class AdminView extends GetView<MainController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Toko')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/logo_mark.png', width: 56, height: 56),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin NeoLearn', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      Text(
                        'Kelola katalog, pesanan, dan laporan penjualan',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.insights_rounded,
            color: AppColors.primary,
            title: 'Dashboard Penjualan',
            subtitle: 'Total pesanan, pendapatan, produk terlaris & grafik',
            onTap: () => Get.toNamed(Routes.dashboard),
          ),
          _MenuTile(
            icon: Icons.category_rounded,
            color: AppColors.secondary,
            title: 'Kelola Kategori',
            subtitle: 'Tambah, ubah, dan hapus kategori produk',
            onTap: () => Get.toNamed(Routes.kategori),
          ),
          _MenuTile(
            icon: Icons.library_books_rounded,
            color: AppColors.accent,
            title: 'Kelola Produk',
            subtitle: 'Buku, modul, alat tulis & kelas kursus',
            onTap: () => Get.toNamed(Routes.produkAdmin),
          ),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            color: AppColors.mint,
            title: 'Riwayat Pesanan',
            subtitle: 'Ubah status pesanan & cetak struk',
            onTap: () => controller.changeTab(MainController.tabPesanan),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dns_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Koneksi Server', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Base URL API:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SelectableText(ApiConfig.baseUrl, style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    'Emulator: http://10.0.2.2/neolearn_api - HP fisik: http://<IP-laptop>/neolearn_api '
                    '(ubah di api_config.dart atau --dart-define=API_BASE_URL=...)',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final ok = controller.serverOk.value;
                    final msg = controller.serverStatus.value;
                    if (msg == null) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (ok == true ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            ok == true ? Icons.check_circle_rounded : Icons.error_rounded,
                            size: 18,
                            color: ok == true ? AppColors.success : AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text(msg, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    );
                  }),
                  Obx(
                    () => OutlinedButton.icon(
                      onPressed: controller.isCheckingServer.value ? null : controller.cekServer,
                      icon: controller.isCheckingServer.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.wifi_tethering_rounded),
                      label: const Text('Cek Koneksi Server'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'NeoLearn v1.0.0 - Dhea Almas (2023020113) - 7SIA6',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
