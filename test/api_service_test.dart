import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:neolearn/app/data/services/api_service.dart';
import 'package:neolearn/app/data/services/produk_service.dart';

void main() {
  ApiService api(MockClientHandler handler) => ApiService(client: MockClient(handler), baseUrl: 'http://test/api');

  test('respons sukses diparsing menjadi model', () async {
    final service = ProdukService(
      api((req) async {
        expect(req.url.path, '/api/produk/read.php');
        expect(req.url.queryParameters['search'], 'dart');
        expect(req.url.queryParameters.containsKey('kategori_id'), isFalse);
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'ok',
            'data': [
              {
                'id': 8,
                'kategori_id': 2,
                'nama_kategori': 'Buku Referensi Kuliah',
                'nama': 'Algoritma',
                'harga': '89000.00',
                'stok': 99,
              },
            ],
          }),
          200,
        );
      }),
    );
    final list = await service.getAll(search: 'dart');
    expect(list.single.namaKategori, 'Buku Referensi Kuliah');
    expect(list.single.harga, 89000);
  });

  test('pesan error server (409) diteruskan ke ApiException', () async {
    final s = api(
      (_) async =>
          http.Response(jsonEncode({'success': false, 'message': 'Kuota kelas sudah penuh.', 'data': null}), 409),
    );
    expect(
      () => s.post('keranjang/add.php', body: {'produk_id': 18}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'Kuota kelas sudah penuh.')
            .having((e) => e.statusCode, 'statusCode', 409),
      ),
    );
  });

  test('respons kosong & bukan JSON ditangani', () async {
    expect(
      () => api((_) async => http.Response('', 200)).get('x'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('kosong'))),
    );
    expect(
      () => api((_) async => http.Response('<b>Fatal error</b>', 500)).get('x'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('bukan JSON'))),
    );
  });

  test('server mati (SocketException) menjadi pesan koneksi', () async {
    final s = api((_) async => throw const SocketException('Connection refused'));
    expect(
      () => s.get('produk/read.php'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.isConnectionError, 'isConnectionError', isTrue)
            .having((e) => e.message, 'message', contains('Tidak dapat terhubung')),
      ),
    );
  });
}
