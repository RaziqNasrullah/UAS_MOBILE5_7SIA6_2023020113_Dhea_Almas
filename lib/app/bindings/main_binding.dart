import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/katalog_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/pesanan_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController(Get.find(), Get.find()));
    Get.lazyPut<KatalogController>(() => KatalogController(Get.find(), Get.find()));
    Get.lazyPut<PesananController>(() => PesananController(Get.find()));
  }
}
