import 'package:get/get.dart';

import '../controllers/pesanan_detail_controller.dart';

class PesananDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PesananDetailController>(() => PesananDetailController(Get.find()));
  }
}
