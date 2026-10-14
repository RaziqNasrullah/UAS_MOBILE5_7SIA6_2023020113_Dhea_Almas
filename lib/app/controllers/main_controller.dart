import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../routes/app_routes.dart';

/// Mengatur tab bottom navigation & navigasi lintas halaman.
class MainController extends GetxController {
  static const tabBeranda = 0;
  static const tabKatalog = 1;
  static const tabKeranjang = 2;
  static const tabPesanan = 3;
  static const tabAdmin = 4;

  final currentIndex = 0.obs;

  final isCheckingServer = false.obs;
  final serverStatus = RxnString();
  final serverOk = RxnBool();

  void changeTab(int index) => currentIndex.value = index;

  /// Pindah ke tab tertentu dari halaman mana pun.
  static void goToTab(int index) {
    if (Get.currentRoute != Routes.main) {
      Get.until((route) => route.settings.name == Routes.main);
    }
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(index);
    }
  }

  static void goToCart() => goToTab(tabKeranjang);

  /// Cek koneksi ke index.php API.
  Future<void> cekServer() async {
    isCheckingServer.value = true;
    try {
      final res = await Get.find<ApiService>().get('');
      serverOk.value = true;
      serverStatus.value = res.message;
    } on ApiException catch (e) {
      serverOk.value = false;
      serverStatus.value = e.message;
    } catch (e) {
      serverOk.value = false;
      serverStatus.value = 'Gagal cek server: $e';
    } finally {
      isCheckingServer.value = false;
    }
  }
}
