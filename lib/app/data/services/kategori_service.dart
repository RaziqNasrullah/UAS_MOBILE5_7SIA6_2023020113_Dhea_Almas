import '../../models/kategori.dart';
import 'api_service.dart';

class KategoriService {
  KategoriService(this._api);
  final ApiService _api;

  Future<List<Kategori>> getAll() async {
    final res = await _api.get('kategori/read.php');
    return mapList(res.data, Kategori.fromJson);
  }

  Future<ApiResponse> create(Kategori k) => _api.post('kategori/create.php', body: k.toJson());

  Future<ApiResponse> update(Kategori k) => _api.post('kategori/update.php', body: k.toJson());

  Future<ApiResponse> delete(int id) => _api.post('kategori/delete.php', body: {'id': id});
}
