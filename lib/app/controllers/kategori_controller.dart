import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../models/kategori.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';
import 'app_refresh.dart';

/// CRUD kategori + validasi kosong & duplikat.
class KategoriController extends GetxController {
  KategoriController(this._service);

  final KategoriService _service;

  final kategoriList = <Kategori>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  // ---- state form ----
  final formKey = GlobalKey<FormState>();
  final namaC = TextEditingController();
  final deskripsiC = TextEditingController();
  final editing = Rxn<Kategori>();
  final ikon = 'category'.obs;

  static const ikonPilihan = ['menu_book', 'school', 'edit', 'cast_for_education', 'science', 'category'];

  @override
  void onInit() {
    super.onInit();
    fetchKategori();
  }

  Future<void> fetchKategori() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      kategoriList.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void openForm([Kategori? k]) {
    editing.value = k;
    namaC.text = k?.nama ?? '';
    deskripsiC.text = k?.deskripsi ?? '';
    ikon.value = k?.ikon ?? 'category';
    Get.toNamed(Routes.kategoriForm);
  }

  /// Validasi duplikat di sisi aplikasi (server juga memvalidasi).
  String? validateNama(String? v) {
    final lain = kategoriList.where((k) => k.id != editing.value?.id).map((k) => k.nama);
    return Validators.namaKategori(v, lain);
  }

  Future<void> save() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    final data = Kategori(
      id: editing.value?.id ?? 0,
      nama: namaC.text.trim(),
      deskripsi: deskripsiC.text.trim().isEmpty ? null : deskripsiC.text.trim(),
      ikon: ikon.value,
    );
    try {
      final res = editing.value == null ? await _service.create(data) : await _service.update(data);
      Get.back();
      AppSnackbar.success(res.message);
      await fetchKategori();
      AppRefresh.kategori();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan kategori: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(Kategori k) async {
    if (k.jumlahProduk > 0) {
      AppSnackbar.error(
        'Kategori "${k.nama}" masih memiliki ${k.jumlahProduk} produk. Pindahkan atau hapus produknya terlebih dahulu.',
        title: 'Tidak dapat dihapus',
      );
      return;
    }
    final ok = await showConfirmDialog(
      title: 'Hapus kategori?',
      message: 'Kategori "${k.nama}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.danger,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;
    try {
      final res = await _service.delete(k.id);
      kategoriList.removeWhere((e) => e.id == k.id);
      AppSnackbar.success(res.message);
      AppRefresh.kategori();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message, title: 'Tidak dapat dihapus');
    } catch (e) {
      AppSnackbar.error('Gagal menghapus kategori: $e');
    }
  }

  @override
  void onClose() {
    namaC.dispose();
    deskripsiC.dispose();
    super.onClose();
  }
}
