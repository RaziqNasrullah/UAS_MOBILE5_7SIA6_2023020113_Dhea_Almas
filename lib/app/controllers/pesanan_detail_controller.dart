import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/pesanan_service.dart';
import '../models/pesanan.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/confirm_dialog.dart';
import 'app_refresh.dart';

/// Detail pesanan. Menerima id pesanan (int) lewat Get.arguments.
class PesananDetailController extends GetxController {
  PesananDetailController(this._service);

  final PesananService _service;

  late final int pesananId;
  final pesanan = Rxn<Pesanan>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    pesananId = arg is int ? arg : int.tryParse('$arg') ?? 0;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    if (pesananId <= 0) {
      errorMessage.value = 'ID pesanan tidak valid.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      pesanan.value = await _service.getById(pesananId);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ubahStatus(String status) async {
    final p = pesanan.value;
    if (p == null || isUpdating.value) return;
    final batal = status == 'Dibatalkan';
    final ok = await showConfirmDialog(
      title: batal ? 'Batalkan pesanan?' : 'Tandai selesai?',
      message: batal
          ? 'Pesanan ${p.nomorPesanan} akan dibatalkan dan stok/kuota produk dikembalikan. '
                'Status tidak dapat diubah lagi.'
          : 'Pesanan ${p.nomorPesanan} akan ditandai Selesai dan dihitung sebagai pendapatan. '
                'Status tidak dapat diubah lagi.',
      confirmLabel: batal ? 'Ya, Batalkan' : 'Ya, Selesai',
      confirmColor: batal ? AppColors.danger : AppColors.success,
      icon: batal ? Icons.cancel_outlined : Icons.task_alt_rounded,
    );
    if (!ok) return;

    isUpdating.value = true;
    try {
      final result = await _service.updateStatus(p.id, status);
      pesanan.value = result.pesanan;
      AppSnackbar.success(result.message);
      AppRefresh.pesanan();
      if (batal) AppRefresh.produk();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
      if (e.statusCode == 409) fetchDetail();
    } catch (e) {
      AppSnackbar.error('Gagal mengubah status: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  void bukaStruk() {
    final p = pesanan.value;
    if (p == null) return;
    Get.toNamed(Routes.struk, arguments: p);
  }
}
