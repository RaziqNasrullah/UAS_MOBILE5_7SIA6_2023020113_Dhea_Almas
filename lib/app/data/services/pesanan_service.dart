import '../../models/pesanan.dart';
import 'api_service.dart';

class PesananService {
  PesananService(this._api);
  final ApiService _api;

  Future<List<Pesanan>> getAll({String? status}) async {
    final res = await _api.get(
      'pesanan/read.php',
      query: {'status': (status == null || status == 'Semua') ? null : status},
    );
    return mapList(res.data, Pesanan.fromJson);
  }

  Future<Pesanan> getById(int id) async {
    final res = await _api.get('pesanan/detail.php', query: {'id': id});
    return Pesanan.fromJson(asMap(res.data));
  }

  Future<Pesanan> checkout({
    required String namaPemesan,
    required String noHp,
    String? email,
    required String tipePesanan,
    String? alamat,
    String? catatan,
  }) async {
    final res = await _api.post(
      'pesanan/checkout.php',
      body: {
        'nama_pemesan': namaPemesan,
        'no_hp': noHp,
        'email': email,
        'tipe_pesanan': tipePesanan,
        'alamat': alamat,
        'catatan': catatan,
      },
    );
    return Pesanan.fromJson(asMap(res.data));
  }

  Future<({Pesanan pesanan, String message})> updateStatus(int id, String status) async {
    final res = await _api.post('pesanan/update_status.php', body: {'id': id, 'status': status});
    return (pesanan: Pesanan.fromJson(asMap(res.data)), message: res.message);
  }
}
