import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Halaman sukses checkout. Data pesanan diterima lewat Get.arguments.
class CheckoutSuksesView extends StatelessWidget {
  const CheckoutSuksesView({super.key});

  void _keBeranda() {
    Get.until((r) => r.settings.name == Routes.main);
    MainController.goToTab(MainController.tabBeranda);
  }

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    final Pesanan? p = arg is Pesanan ? arg : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _keBeranda();
      },
      child: Scaffold(
        body: SafeArea(
          child: p == null
              ? EmptyState(title: 'Data pesanan tidak tersedia', actionLabel: 'Ke Beranda', onAction: _keBeranda)
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) => Transform.scale(scale: v, child: child),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 84),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pesanan Berhasil Dibuat!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Terima kasih sudah belajar bersama NeoLearn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _row('Nomor Pesanan', p.nomorPesanan, bold: true),
                            _row('Tanggal', Formatter.tanggalWaktu(p.tanggal)),
                            _row('Pemesan', p.namaPemesan),
                            _row('Tipe Pesanan', p.tipePesanan),
                            _row('Jumlah Item', '${p.totalQty} item'),
                            if (p.diskon > 0) _row('Hemat (diskon pelajar)', Formatter.rupiah(p.diskon)),
                            const Divider(height: 22),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                                Text(
                                  Formatter.rupiah(p.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: StatusBadge(status: p.status),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.struk, arguments: p),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Lihat Struk PDF'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(Routes.pesananDetail, arguments: p.id),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Detail Pesanan'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(onPressed: _keBeranda, child: const Text('Kembali ke Beranda')),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
      ],
    ),
  );
}
