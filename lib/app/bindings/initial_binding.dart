import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/keranjang_service.dart';
import '../data/services/pesanan_service.dart';
import '../data/services/produk_service.dart';

/// Dependency global: service API + CartController (permanen, dipakai badge di semua halaman).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.lazyPut<KategoriService>(() => KategoriService(Get.find()), fenix: true);
    Get.lazyPut<ProdukService>(() => ProdukService(Get.find()), fenix: true);
    Get.lazyPut<KeranjangService>(() => KeranjangService(Get.find()), fenix: true);
    Get.lazyPut<PesananService>(() => PesananService(Get.find()), fenix: true);
    Get.lazyPut<DashboardService>(() => DashboardService(Get.find()), fenix: true);
    Get.put<CartController>(CartController(Get.find()), permanent: true);
  }
}
