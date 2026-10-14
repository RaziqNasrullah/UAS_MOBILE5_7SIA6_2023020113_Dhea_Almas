import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Riwayat pesanan: urut terbaru + filter status (warna berbeda per status).
class PesananView extends GetView<PesananController> {
  const PesananView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: controller.fetchPesanan,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final s in PesananController.filterList)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: controller.statusFilter.value == s,
                        onSelected: (_) => controller.setFilter(s),
                        selectedColor: s == 'Semua' ? AppColors.primary : AppColors.status(s),
                        labelStyle: TextStyle(
                          color: controller.statusFilter.value == s ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.pesananList.isEmpty) {
                return const LoadingView(message: 'Memuat riwayat pesanan...');
              }
              final err = controller.errorMessage.value;
              if (err != null) return ErrorState(message: err, onRetry: controller.fetchPesanan);
              if (controller.pesananList.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pesanan',
                  message: controller.statusFilter.value == 'Semua'
                      ? 'Pesanan yang kamu buat akan muncul di sini.'
                      : 'Tidak ada pesanan berstatus ${controller.statusFilter.value}.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchPesanan(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: controller.pesananList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PesananCard(pesanan: controller.pesananList[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PesananCard extends StatelessWidget {
  const _PesananCard({required this.pesanan});

  final Pesanan pesanan;

  IconData get _tipeIcon {
    switch (pesanan.tipePesanan) {
      case 'Diantar':
        return Icons.delivery_dining_rounded;
      case 'Digital/Kelas Online':
        return Icons.cloud_download_outlined;
      default:
        return Icons.storefront_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    final color = AppColors.status(p.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.pesananDetail, arguments: p.id),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(p.nomorPesanan, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  StatusBadge(status: p.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatter.tanggalWaktu(p.tanggal),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(p.namaPemesan, overflow: TextOverflow.ellipsis)),
                  Icon(_tipeIcon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(p.tipePesanan, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Text(
                    '${p.jumlahItem} produk - ${p.totalQty} item',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    Formatter.rupiah(p.total),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
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
