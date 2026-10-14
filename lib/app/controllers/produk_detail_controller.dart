import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/produk_service.dart';
import '../models/produk.dart';
import 'cart_controller.dart';

/// Detail produk. Objek produk dikirim lewat Get.arguments, lalu
/// dimuat ulang dari server agar stok selalu terbaru.
class ProdukDetailController extends GetxController {
  ProdukDetailController(this._produkService);

  final ProdukService _produkService;
  final CartController cart = Get.find<CartController>();

  final produk = Rxn<Produk>();
  final qty = 1.obs;
  final isAdding = false.obs;
  final isRefreshing = false.obs;
  final catatanC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Produk) {
      produk.value = arg;
      refreshProduk();
    }
  }

  int get sisaBisaDitambah {
    final p = produk.value;
    if (p == null) return 0;
    return (p.stok - cart.qtyOfProduk(p.id)).clamp(0, p.stok);
  }

  Future<void> refreshProduk() async {
    final p = produk.value;
    if (p == null) return;
    isRefreshing.value = true;
    try {
      produk.value = await _produkService.getById(p.id);
      if (qty.value > sisaBisaDitambah && sisaBisaDitambah > 0) qty.value = sisaBisaDitambah;
    } on ApiException catch (_) {
      // tetap tampilkan data dari argumen jika gagal refresh
    } catch (_) {
    } finally {
      isRefreshing.value = false;
    }
  }

  void setQty(int v) => qty.value = v;

  Future<void> addToCart() async {
    final p = produk.value;
    if (p == null || isAdding.value) return;
    isAdding.value = true;
    final ok = await cart.addToCart(
      produkId: p.id,
      nama: p.nama,
      jumlah: qty.value,
      stok: p.stok,
      isKelas: p.isKelas,
      catatan: catatanC.text.trim().isEmpty ? null : catatanC.text.trim(),
    );
    isAdding.value = false;
    if (ok) {
      qty.value = 1;
      catatanC.clear();
    }
  }

  @override
  void onClose() {
    catatanC.dispose();
    super.onClose();
  }
}
