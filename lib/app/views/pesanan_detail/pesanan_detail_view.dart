import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_detail_controller.dart';
import '../../models/pesanan.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/rincian_biaya_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

class PesananDetailView extends GetView<PesananDetailController> {
  const PesananDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          Obx(
            () => controller.pesanan.value == null
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Cetak struk',
                    onPressed: controller.bukaStruk,
                    icon: const Icon(Icons.print_outlined),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final p = controller.pesanan.value;
        if (controller.isLoading.value && p == null) return const LoadingView(message: 'Memuat detail pesanan...');
        final err = controller.errorMessage.value;
        if (err != null && p == null) return ErrorState(message: err, onRetry: controller.fetchDetail);
        if (p == null) return const SizedBox.shrink();
        return RefreshIndicator(
          onRefresh: controller.fetchDetail,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _HeaderCard(pesanan: p),
              const SizedBox(height: 12),
              _InfoPemesan(pesanan: p),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Pesanan (${p.items.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      for (final it in p.items) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.sky.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${it.jumlah}x',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.namaProduk, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      '${Formatter.rupiah(it.hargaSatuan)}${it.namaKategori != null ? ' - ${it.namaKategori}' : ''}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (it.catatanItem != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          'Catatan: ${it.catatanItem}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(Formatter.rupiah(it.subtotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        if (it != p.items.last) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              RincianBiayaCard(
                subtotal: p.subtotal,
                biayaLayanan: p.biayaLayanan,
                ongkir: p.ongkir,
                diskon: p.diskon,
                total: p.total,
                totalQty: p.totalQty,
              ),
              if (!p.bisaDiubah) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.status(p.status).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.status(p.status), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pesanan sudah ${p.status.toLowerCase()} sehingga status tidak dapat diubah lagi.',
                          style: TextStyle(color: AppColors.status(p.status), fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final p = controller.pesanan.value;
        if (p == null) return const SizedBox.shrink();
        final busy = controller.isUpdating.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: p.bisaDiubah
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                          ),
                          onPressed: busy ? null : () => controller.ubahStatus('Dibatalkan'),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          onPressed: busy ? null : () => controller.ubahStatus('Selesai'),
                          icon: busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.task_alt_rounded),
                          label: const Text('Selesai'),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: controller.bukaStruk,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Cetak Struk PDF'),
                  ),
          ),
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.pesanan});

  final Pesanan pesanan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nomor Pesanan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  pesanan.nomorPesanan,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatter.tanggalWaktu(pesanan.tanggal),
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: StatusBadge(status: pesanan.status),
          ),
        ],
      ),
    );
  }
}

class _InfoPemesan extends StatelessWidget {
  const _InfoPemesan({required this.pesanan});

  final Pesanan pesanan;

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Info Pemesan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            row(Icons.person_outline_rounded, 'Nama', p.namaPemesan),
            row(Icons.phone_android_rounded, 'No. HP', p.noHp),
            if (p.email != null) row(Icons.email_outlined, 'Email', p.email!),
            row(Icons.local_shipping_outlined, 'Tipe', p.tipePesanan),
            if (p.alamat != null) row(Icons.location_on_outlined, 'Alamat', p.alamat!),
            if (p.catatan != null) row(Icons.notes_rounded, 'Catatan', p.catatan!),
          ],
        ),
      ),
    );
  }
}
