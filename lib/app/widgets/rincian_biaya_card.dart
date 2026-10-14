import 'package:flutter/material.dart';

import '../data/services/api_config.dart';
import '../theme/app_colors.dart';
import '../utils/formatter.dart';

/// Kartu rincian biaya: subtotal, layanan, ongkir, diskon, total.
class RincianBiayaCard extends StatelessWidget {
  const RincianBiayaCard({
    super.key,
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
    this.totalQty,
  });

  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;
  final int? totalQty;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {Color? color, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: color ?? AppColors.textSecondary)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
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
            const Text('Rincian Biaya', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            row(totalQty == null ? 'Subtotal' : 'Subtotal ($totalQty item)', Formatter.rupiah(subtotal)),
            row('Biaya layanan', Formatter.rupiah(biayaLayanan)),
            row('Ongkir', ongkir > 0 ? Formatter.rupiah(ongkir) : 'Gratis'),
            row(
              'Diskon pelajar ${ApiConfig.diskonPersen.toInt()}%',
              diskon > 0 ? '- ${Formatter.rupiah(diskon)}' : Formatter.rupiah(0),
              color: diskon > 0 ? AppColors.success : null,
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                Text(
                  Formatter.rupiah(total),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
