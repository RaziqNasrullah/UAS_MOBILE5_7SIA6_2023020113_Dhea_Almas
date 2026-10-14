import 'package:get/get.dart';

import '../data/services/api_config.dart';
import '../data/services/api_service.dart';
import '../data/services/keranjang_service.dart';
import '../models/keranjang_item.dart';
import '../utils/app_snackbar.dart';

/// State keranjang (permanen). Data disimpan di tabel `keranjang` lewat API,
/// state di controller ini agar subtotal, total & badge langsung reaktif.
class CartController extends GetxController {
  CartController(this._service);

  final KeranjangService _service;

  final items = <KeranjangItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// id item yang sedang diproses (untuk loading per baris).
  final busyIds = <int>{}.obs;

  int get totalQty => items.fold(0, (s, e) => s + e.jumlah);
  int get totalItem => items.length;
  double get totalHarga => items.fold(0.0, (s, e) => s + e.subtotal);
  bool get isEmpty => items.isEmpty;

  /// Ada produk kategori Kelas Kursus -> email wajib saat checkout.
  bool get hasKelasKursus => items.any((e) => e.isKelas);

  /// Semua item E-Book / Kelas Online -> boleh tipe "Digital/Kelas Online".
  bool get allDigital => items.isNotEmpty && items.every((e) => e.isDigital);

  /// Ada barang fisik/cetak -> tipe digital tidak boleh dipilih.
  bool get hasPhysical => items.any((e) => !ApiConfig.formatDigital.contains(e.formatProduk));

  int qtyOfProduk(int produkId) => items.firstWhereOrNull((e) => e.produkId == produkId)?.jumlah ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      items.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat keranjang: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Tambah produk ke keranjang. Mengembalikan true jika berhasil.
  Future<bool> addToCart({
    required int produkId,
    required String nama,
    required int jumlah,
    required int stok,
    bool isKelas = false,
    String? catatan,
  }) async {
    final label = isKelas ? 'kuota kelas' : 'stok';
    if (stok <= 0) {
      AppSnackbar.warning(isKelas ? 'Kuota kelas sudah penuh.' : 'Stok produk habis.');
      return false;
    }
    final sudahAda = qtyOfProduk(produkId);
    if (sudahAda + jumlah > stok) {
      AppSnackbar.warning('Jumlah melebihi $label (tersedia $stok). Di keranjang sudah ada $sudahAda.');
      return false;
    }
    try {
      final res = await _service.add(produkId, jumlah, catatan: catatan);
      final item = KeranjangItem.fromJson(asMap(res.data));
      final idx = items.indexWhere((e) => e.id == item.id);
      if (idx >= 0) {
        items[idx] = item;
      } else {
        items.add(item);
      }
      AppSnackbar.success(res.message.isEmpty ? '"$nama" ditambahkan ke keranjang.' : res.message);
      return true;
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
      return false;
    } catch (e) {
      AppSnackbar.error('Gagal menambahkan ke keranjang: $e');
      return false;
    }
  }

  Future<void> increment(KeranjangItem item) async {
    if (item.jumlah >= item.stok) {
      AppSnackbar.warning('Jumlah tidak boleh melebihi ${item.labelStok} yang tersedia (${item.stok}).');
      return;
    }
    await _setQty(item, item.jumlah + 1);
  }

  Future<void> decrement(KeranjangItem item) async {
    if (item.jumlah <= 1) {
      AppSnackbar.info('Jumlah minimal 1. Gunakan ikon hapus untuk mengeluarkan produk.');
      return;
    }
    await _setQty(item, item.jumlah - 1);
  }

  Future<void> _setQty(KeranjangItem item, int qty) async {
    final idx = items.indexWhere((e) => e.id == item.id);
    if (idx < 0) return;
    final lama = items[idx];
    items[idx] = lama.copyWith(jumlah: qty); // update optimistis agar total langsung berubah
    busyIds.add(item.id);
    try {
      await _service.updateQty(item.id, qty);
    } on ApiException catch (e) {
      items[idx] = lama;
      AppSnackbar.error(e.message);
      if (e.statusCode == 409) fetchCart(silent: true);
    } catch (e) {
      items[idx] = lama;
      AppSnackbar.error('Gagal mengubah jumlah: $e');
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> updateCatatan(KeranjangItem item, String catatan) async {
    final idx = items.indexWhere((e) => e.id == item.id);
    if (idx < 0) return;
    final c = catatan.trim();
    try {
      final res = await _service.updateCatatan(item.id, c.isEmpty ? null : c);
      items[idx] = items[idx].copyWith(catatanItem: c, hapusCatatan: c.isEmpty);
      AppSnackbar.success(res.message);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan catatan: $e');
    }
  }

  Future<void> removeItem(KeranjangItem item) async {
    busyIds.add(item.id);
    try {
      await _service.delete(item.id);
      items.removeWhere((e) => e.id == item.id);
      AppSnackbar.success('"${item.nama}" dihapus dari keranjang.');
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menghapus item: $e');
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> clearCart() async {
    try {
      await _service.clear();
      items.clear();
      AppSnackbar.success('Keranjang dikosongkan.');
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal mengosongkan keranjang: $e');
    }
  }

  /// Dipanggil setelah checkout sukses (server sudah mengosongkan tabel keranjang).
  void clearLocal() => items.clear();
}
