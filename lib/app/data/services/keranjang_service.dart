import '../../models/keranjang_item.dart';
import 'api_service.dart';

class KeranjangService {
  KeranjangService(this._api);
  final ApiService _api;

  Future<List<KeranjangItem>> getAll() async {
    final res = await _api.get('keranjang/read.php');
    return mapList(asMap(res.data)['items'], KeranjangItem.fromJson);
  }

  Future<ApiResponse> add(int produkId, int jumlah, {String? catatan}) =>
      _api.post('keranjang/add.php', body: {'produk_id': produkId, 'jumlah': jumlah, 'catatan_item': catatan});

  Future<ApiResponse> updateQty(int id, int jumlah) =>
      _api.post('keranjang/update_qty.php', body: {'id': id, 'jumlah': jumlah});

  Future<ApiResponse> updateCatatan(int id, String? catatan) =>
      _api.post('keranjang/update_catatan.php', body: {'id': id, 'catatan_item': catatan});

  Future<ApiResponse> delete(int id) => _api.post('keranjang/delete.php', body: {'id': id});

  Future<ApiResponse> clear() => _api.post('keranjang/clear.php');
}
