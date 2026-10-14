import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_config.dart';
import '../data/services/api_service.dart';
import '../data/services/pesanan_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import '../utils/biaya_calculator.dart';
import '../utils/validators.dart';
import 'app_refresh.dart';
import 'cart_controller.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._pesananService);

  final PesananService _pesananService;
  final CartController cart = Get.find<CartController>();

  final formKey = GlobalKey<FormState>();
  final namaC = TextEditingController();
  final hpC = TextEditingController();
  final emailC = TextEditingController();
  final alamatC = TextEditingController();
  final catatanC = TextEditingController();

  final tipePesanan = ApiConfig.tipeAmbil.obs;
  final isSubmitting = false.obs;

  bool get isDiantar => tipePesanan.value == ApiConfig.tipeDiantar;
  bool get emailWajib => cart.hasKelasKursus;
  bool get bolehDigital => cart.allDigital;

  RincianBiaya get rincian => BiayaCalculator.hitung(subtotal: cart.totalHarga, tipePesanan: tipePesanan.value);

  void setTipe(String? tipe) {
    if (tipe == null) return;
    if (tipe == ApiConfig.tipeDigital && !bolehDigital) {
      AppSnackbar.warning('Tipe Digital/Kelas Online hanya untuk pesanan yang semua itemnya E-Book atau Kelas Online.');
      return;
    }
    tipePesanan.value = tipe;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (cart.isEmpty) {
      AppSnackbar.warning('Keranjang kosong.');
      return;
    }
    final melebihi = cart.items.where((e) => e.melebihiStok).toList();
    if (melebihi.isNotEmpty) {
      AppSnackbar.error(
        'Jumlah "${melebihi.first.nama}" melebihi ${melebihi.first.labelStok} tersedia (${melebihi.first.stok}).',
      );
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.error('Periksa kembali data pemesan yang belum valid.');
      return;
    }
    if (tipePesanan.value == ApiConfig.tipeDigital && !bolehDigital) {
      AppSnackbar.error('Tipe Digital/Kelas Online tidak bisa dipilih untuk pesanan ini.');
      return;
    }

    isSubmitting.value = true;
    try {
      final pesanan = await _pesananService.checkout(
        namaPemesan: namaC.text.trim(),
        noHp: Validators.normalisasiHp(hpC.text.trim()),
        email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
        tipePesanan: tipePesanan.value,
        alamat: isDiantar ? alamatC.text.trim() : null,
        catatan: catatanC.text.trim().isEmpty ? null : catatanC.text.trim(),
      );
      cart.clearLocal();
      AppRefresh.produk();
      AppRefresh.pesanan();
      Get.offNamed(Routes.checkoutSukses, arguments: pesanan);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message, title: 'Checkout gagal');
      if (e.statusCode == 409 || e.statusCode == 422) cart.fetchCart(silent: true);
    } catch (e) {
      AppSnackbar.error('Terjadi kesalahan saat checkout: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    namaC.dispose();
    hpC.dispose();
    emailC.dispose();
    alamatC.dispose();
    catatanC.dispose();
    super.onClose();
  }
}
