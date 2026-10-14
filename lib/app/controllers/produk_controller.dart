import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/services/api_config.dart';
import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/confirm_dialog.dart';
import 'app_refresh.dart';

/// CRUD produk (admin) + relasi kategori + upload gambar.
class ProdukController extends GetxController {
  ProdukController(this._produkService, this._kategoriService);

  final ProdukService _produkService;
  final KategoriService _kategoriService;

  final produkList = <Produk>[].obs;
  final kategoriList = <Kategori>[].obs;
  final search = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  // ---- state form ----
  final formKey = GlobalKey<FormState>();
  final namaC = TextEditingController();
  final hargaC = TextEditingController();
  final stokC = TextEditingController();
  final deskripsiC = TextEditingController();
  final penulisC = TextEditingController();
  final detailC = TextEditingController();
  final editing = Rxn<Produk>();
  final kategoriId = RxnInt();
  final jenjang = 'Umum'.obs;
  final formatProduk = 'Cetak'.obs;
  final isBestSeller = false.obs;
  final pickedBytes = Rxn<Uint8List>();
  String? _pickedName;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    debounce<String>(search, (_) => fetchProduk(), time: const Duration(milliseconds: 400));
    fetchKategori();
    fetchProduk();
  }

  /// Kategori yang dipilih adalah Kelas Kursus -> label stok jadi "Kuota Peserta".
  bool get isKelasDipilih => kategoriList.firstWhereOrNull((k) => k.id == kategoriId.value)?.isKelasKursus ?? false;

  String get labelStok => isKelasDipilih ? 'Kuota Peserta' : 'Stok';

  String get labelPenulis {
    if (isKelasDipilih) return 'Nama Pengajar';
    if (formatProduk.value == 'Barang Fisik') return 'Merek';
    return 'Penulis';
  }

  Future<void> fetchKategori() async {
    try {
      kategoriList.assignAll(await _kategoriService.getAll());
    } on ApiException catch (e) {
      errorMessage.value ??= e.message;
    } catch (_) {}
  }

  Future<void> fetchProduk({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      produkList.assignAll(await _produkService.getAll(search: search.value));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openForm([Produk? p]) async {
    if (kategoriList.isEmpty) await fetchKategori();
    editing.value = p;
    namaC.text = p?.nama ?? '';
    hargaC.text = p == null ? '' : p.harga.toStringAsFixed(0);
    stokC.text = p == null ? '' : '${p.stok}';
    deskripsiC.text = p?.deskripsi ?? '';
    penulisC.text = p?.penulisMerek ?? '';
    detailC.text = p?.detailTambahan ?? '';
    kategoriId.value = p?.kategoriId;
    jenjang.value = p?.jenjang ?? 'Umum';
    formatProduk.value = p?.formatProduk ?? 'Cetak';
    isBestSeller.value = p?.isBestSeller ?? false;
    pickedBytes.value = null;
    _pickedName = null;
    Get.toNamed(Routes.produkForm);
  }

  void onKategoriChanged(int? id) {
    kategoriId.value = id;
    // Bantu isi format yang masuk akal untuk kelas.
    if (isKelasDipilih && !formatProduk.value.startsWith('Kelas')) {
      formatProduk.value = 'Kelas Online';
    }
  }

  Future<void> pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        AppSnackbar.warning('Ukuran gambar maksimal 2 MB. Pilih gambar lain.');
        return;
      }
      pickedBytes.value = bytes;
      _pickedName = file.name.isEmpty ? 'gambar.jpg' : file.name;
    } catch (e) {
      AppSnackbar.error('Gagal memilih gambar: $e');
    }
  }

  void removePickedImage() {
    pickedBytes.value = null;
    _pickedName = null;
  }

  Future<void> save() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.error('Lengkapi data produk yang wajib diisi.');
      return;
    }
    if (kategoriId.value == null) {
      AppSnackbar.error('Kategori wajib dipilih.');
      return;
    }
    isSaving.value = true;
    try {
      String? gambar = editing.value?.gambar;
      if (pickedBytes.value != null) {
        gambar = await _produkService.uploadGambar(pickedBytes.value!, _pickedName ?? 'gambar.jpg');
      }
      final data = Produk(
        id: editing.value?.id ?? 0,
        kategoriId: kategoriId.value!,
        namaKategori: '',
        nama: namaC.text.trim(),
        harga: double.parse(hargaC.text.trim().replaceAll('.', '').replaceAll(',', '.')),
        stok: int.parse(stokC.text.trim()),
        deskripsi: deskripsiC.text.trim(),
        gambar: gambar,
        penulisMerek: penulisC.text.trim(),
        jenjang: jenjang.value,
        formatProduk: formatProduk.value,
        detailTambahan: detailC.text.trim().isEmpty ? null : detailC.text.trim(),
        isBestSeller: isBestSeller.value,
      );
      final res = editing.value == null ? await _produkService.create(data) : await _produkService.update(data);
      Get.back();
      AppSnackbar.success(res.message);
      await fetchProduk(silent: true);
      AppRefresh.produk();
      AppRefresh.kategori();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan produk: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(Produk p) async {
    final ok = await showConfirmDialog(
      title: 'Hapus produk?',
      message: '"${p.nama}" akan dihapus. Riwayat pesanan tetap tersimpan.',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.danger,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;
    try {
      final res = await _produkService.delete(p.id);
      produkList.removeWhere((e) => e.id == p.id);
      AppSnackbar.success(res.message);
      AppRefresh.produk();
      AppRefresh.kategori();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menghapus produk: $e');
    }
  }

  List<String> get jenjangList => ApiConfig.jenjangList;
  List<String> get formatList => ApiConfig.formatList;

  @override
  void onClose() {
    for (final c in [namaC, hargaC, stokC, deskripsiC, penulisC, detailC]) {
      c.dispose();
    }
    super.onClose();
  }
}
