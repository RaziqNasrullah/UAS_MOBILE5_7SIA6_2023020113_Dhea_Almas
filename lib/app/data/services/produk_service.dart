import '../../models/produk.dart';
import 'api_service.dart';

class ProdukService {
  ProdukService(this._api);
  final ApiService _api;

  Future<List<Produk>> getAll({
    String? search,
    int? kategoriId,
    bool bestSeller = false,
    String? sort,
    int? limit,
  }) async {
    final res = await _api.get(
      'produk/read.php',
      query: {
        'search': search?.trim(),
        'kategori_id': kategoriId,
        'best_seller': bestSeller ? 1 : null,
        'sort': sort,
        'limit': limit,
      },
    );
    return mapList(res.data, Produk.fromJson);
  }

  Future<Produk> getById(int id) async {
    final res = await _api.get('produk/detail.php', query: {'id': id});
    return Produk.fromJson(asMap(res.data));
  }

  Future<ApiResponse> create(Produk p) => _api.post('produk/create.php', body: p.toJson());

  Future<ApiResponse> update(Produk p) => _api.post('produk/update.php', body: p.toJson());

  Future<ApiResponse> delete(int id) => _api.post('produk/delete.php', body: {'id': id});

  /// Upload gambar, mengembalikan nama file di server.
  Future<String> uploadGambar(List<int> bytes, String filename) async {
    final res = await _api.upload('produk/upload_gambar.php', field: 'gambar', bytes: bytes, filename: filename);
    return asMap(res.data)['gambar'].toString();
  }
}
