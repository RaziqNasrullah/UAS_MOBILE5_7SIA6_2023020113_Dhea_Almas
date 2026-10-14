import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/pesanan_service.dart';
import '../models/pesanan.dart';

/// Riwayat pesanan (urut terbaru) + filter status.
class PesananController extends GetxController {
  PesananController(this._service);

  final PesananService _service;

  static const filterList = ['Semua', 'Diproses', 'Selesai', 'Dibatalkan'];

  final pesananList = <Pesanan>[].obs;
  final statusFilter = 'Semua'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever<String>(statusFilter, (_) => fetchPesanan());
    fetchPesanan();
  }

  void setFilter(String status) => statusFilter.value = status;

  Future<void> fetchPesanan({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      pesananList.assignAll(await _service.getAll(status: statusFilter.value));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
