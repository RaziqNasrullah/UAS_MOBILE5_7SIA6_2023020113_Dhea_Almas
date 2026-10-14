import 'package:get/get.dart';

import 'dashboard_controller.dart';
import 'home_controller.dart';
import 'katalog_controller.dart';
import 'pesanan_controller.dart';
import 'produk_controller.dart';

/// Memuat ulang data di halaman lain yang sedang aktif setelah ada perubahan
/// (mis. stok berkurang setelah checkout, produk baru ditambahkan).
class AppRefresh {
  AppRefresh._();

  static void produk() {
    if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchAll(silent: true);
    if (Get.isRegistered<KatalogController>()) Get.find<KatalogController>().fetchProduk(silent: true);
    if (Get.isRegistered<ProdukController>()) Get.find<ProdukController>().fetchProduk(silent: true);
  }

  static void kategori() {
    if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchAll(silent: true);
    if (Get.isRegistered<KatalogController>()) Get.find<KatalogController>().fetchKategori();
  }

  static void pesanan() {
    if (Get.isRegistered<PesananController>()) Get.find<PesananController>().fetchPesanan(silent: true);
    if (Get.isRegistered<DashboardController>()) Get.find<DashboardController>().fetchSummary(silent: true);
  }
}
