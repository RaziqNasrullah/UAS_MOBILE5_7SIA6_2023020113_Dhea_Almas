import 'package:get/get.dart';

import '../controllers/produk_detail_controller.dart';

class ProdukDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProdukDetailController>(() => ProdukDetailController(Get.find()));
  }
}
