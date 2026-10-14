import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';

/// Katalog: pencarian realtime (debounce 400 ms) + filter kategori (ChoiceChip).
class KatalogController extends GetxController {
  KatalogController(this._produkService, this._kategoriService);

  final ProdukService _produkService;
  final KategoriService _kategoriService;

  final searchC = TextEditingController();
  final produkList = <Produk>[].obs;
  final kategoriList = <Kategori>[].obs;
  final searchQuery = ''.obs;
  final selectedKategoriId = RxnInt();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    // Pencarian realtime: menunggu 400 ms setelah berhenti mengetik.
    debounce<String>(searchQuery, (_) => fetchProduk(), time: const Duration(milliseconds: 400));
    // Filter kategori langsung memuat ulang.
    ever<int?>(selectedKategoriId, (_) => fetchProduk());
    fetchKategori();
    fetchProduk();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  void clearSearch() {
    searchC.clear();
    searchQuery.value = '';
  }

  void selectKategori(int? id) => selectedKategoriId.value = id;

  String get selectedKategoriNama {
    final id = selectedKategoriId.value;
    if (id == null) return 'Semua';
    return kategoriList.firstWhereOrNull((k) => k.id == id)?.nama ?? 'Semua';
  }

  Future<void> fetchKategori() async {
    try {
      kategoriList.assignAll(await _kategoriService.getAll());
    } on ApiException catch (e) {
      errorMessage.value ??= e.message;
    } catch (_) {
      // daftar chip kategori bersifat pelengkap; error utama ditangani fetchProduk
    }
  }

  Future<void> fetchProduk({bool silent = false}) async {
    final reqId = ++_requestId;
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _produkService.getAll(search: searchQuery.value, kategoriId: selectedKategoriId.value);
      if (reqId != _requestId) return; // abaikan respons lama
      produkList.assignAll(data);
    } on ApiException catch (e) {
      if (reqId == _requestId) errorMessage.value = e.message;
    } catch (e) {
      if (reqId == _requestId) errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      if (reqId == _requestId) isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await fetchKategori();
    await fetchProduk();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
