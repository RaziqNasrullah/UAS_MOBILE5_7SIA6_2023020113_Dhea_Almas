import '../data/services/api_config.dart';

/// Rincian biaya checkout. Server menghitung ulang dengan rumus yang sama.
class RincianBiaya {
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;

  const RincianBiaya({
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
  });

  bool get dapatDiskon => diskon > 0;
}

class BiayaCalculator {
  BiayaCalculator._();

  /// - Biaya layanan Rp2.000
  /// - Ongkir Rp10.000 jika Diantar, selain itu Rp0
  /// - Diskon pelajar 10% jika subtotal >= Rp150.000
  /// - Total = subtotal + layanan + ongkir - diskon
  static RincianBiaya hitung({required double subtotal, required String tipePesanan}) {
    if (subtotal <= 0) {
      return const RincianBiaya(subtotal: 0, biayaLayanan: 0, ongkir: 0, diskon: 0, total: 0);
    }
    const layanan = ApiConfig.biayaLayanan;
    final ongkir = tipePesanan == ApiConfig.tipeDiantar ? ApiConfig.ongkirDiantar : 0.0;
    final diskon = subtotal >= ApiConfig.minSubtotalDiskon
        ? (subtotal * ApiConfig.diskonPersen / 100 * 100).roundToDouble() / 100
        : 0.0;
    return RincianBiaya(
      subtotal: subtotal,
      biayaLayanan: layanan,
      ongkir: ongkir,
      diskon: diskon,
      total: subtotal + layanan + ongkir - diskon,
    );
  }

  /// Sisa belanja agar mendapat diskon pelajar (0 jika sudah memenuhi).
  static double kurangUntukDiskon(double subtotal) {
    final kurang = ApiConfig.minSubtotalDiskon - subtotal;
    return kurang > 0 ? kurang : 0;
  }
}
