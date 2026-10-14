import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';

class HomeController extends GetxController {
  HomeController(this._kategoriService, this._produkService);

  final KategoriService _kategoriService;
  final ProdukService _produkService;

  final kategoriList = <Kategori>[].obs;
  final bestSellerList = <Produk>[].obs;
  final terbaruList = <Produk>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final now = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    now.value = DateTime.now();
    try {
      final results = await Future.wait([
        _kategoriService.getAll(),
        _produkService.getAll(bestSeller: true, limit: 10),
        _produkService.getAll(sort: 'terbaru', limit: 8),
      ]);
      kategoriList.assignAll(results[0] as List<Kategori>);
      bestSellerList.assignAll(results[1] as List<Produk>);
      terbaruList.assignAll(results[2] as List<Produk>);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
