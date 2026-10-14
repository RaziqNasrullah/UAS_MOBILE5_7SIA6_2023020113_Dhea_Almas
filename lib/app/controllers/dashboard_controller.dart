import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';
import '../models/dashboard_summary.dart';

class DashboardController extends GetxController {
  DashboardController(this._service);

  final DashboardService _service;

  final summary = Rxn<DashboardSummary>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      summary.value = await _service.getSummary();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
