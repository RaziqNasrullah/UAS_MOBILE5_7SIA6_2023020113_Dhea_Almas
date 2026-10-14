import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Error API yang sudah diterjemahkan menjadi pesan ramah pengguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  /// true jika server tidak bisa dihubungi (mati/timeout/tidak ada jaringan).
  bool get isConnectionError => statusCode == null;

  @override
  String toString() => message;
}

/// Respons standar { success, message, data }.
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  const ApiResponse({required this.success, required this.message, required this.data, required this.statusCode});
}

/// Pembungkus package http: timeout, parsing JSON, dan penanganan error terpusat.
class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String baseUrl;

  static const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'};

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final q = <String, String>{};
    query?.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) q[k] = v.toString();
    });
    return Uri.parse('$baseUrl/$path').replace(queryParameters: q.isEmpty ? null : q);
  }

  Future<ApiResponse> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _client.get(_uri(path, query), headers: _jsonHeaders));

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) =>
      _send(() => _client.post(_uri(path), headers: _jsonHeaders, body: jsonEncode(body ?? const {})));

  /// Upload file multipart (dipakai untuk gambar produk).
  Future<ApiResponse> upload(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
  }) {
    return _send(() async {
      final req = http.MultipartRequest('POST', _uri(path))
        ..headers['Accept'] = 'application/json'
        ..files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
      if (fields != null) req.fields.addAll(fields);
      final streamed = await _client.send(req);
      return http.Response.fromStream(streamed);
    }, timeout: const Duration(seconds: 40));
  }

  Future<ApiResponse> _send(Future<http.Response> Function() request, {Duration timeout = ApiConfig.timeout}) async {
    final http.Response res;
    try {
      res = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'Server tidak merespons (timeout). Pastikan XAMPP (Apache & MySQL) aktif dan alamat API benar.',
      );
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server $baseUrl. Pastikan XAMPP aktif, HP & laptop satu jaringan, '
        'dan firewall mengizinkan Apache.',
      );
    } on http.ClientException catch (e) {
      throw ApiException('Koneksi ke server gagal: ${e.message}');
    } on HandshakeException {
      throw const ApiException('Koneksi aman gagal. Gunakan alamat http:// untuk server lokal XAMPP.');
    }
    return parseResponse(res);
  }

  /// Parsing respons; dipisah agar mudah diuji.
  static ApiResponse parseResponse(http.Response res) {
    final body = utf8.decode(res.bodyBytes, allowMalformed: true).trim();
    if (body.isEmpty) {
      throw ApiException('Server mengirim respons kosong (HTTP ${res.statusCode}).', statusCode: res.statusCode);
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      final hint = res.statusCode == 404
          ? 'Endpoint tidak ditemukan (404). Cek folder neolearn_api di htdocs.'
          : 'Respons server bukan JSON (HTTP ${res.statusCode}). Cek error PHP di folder backend.';
      throw ApiException(hint, statusCode: res.statusCode);
    }
    if (decoded is! Map) {
      throw ApiException('Format respons server tidak dikenali.', statusCode: res.statusCode);
    }

    final map = Map<String, dynamic>.from(decoded);
    final success = map['success'] == true;
    final message = (map['message'] ?? '').toString();
    if (!success || res.statusCode >= 400) {
      throw ApiException(
        message.isEmpty ? 'Permintaan gagal (HTTP ${res.statusCode}).' : message,
        statusCode: res.statusCode,
        data: map['data'],
      );
    }
    return ApiResponse(success: true, message: message, data: map['data'], statusCode: res.statusCode);
  }
}

/// Helper mengubah `data` berupa list JSON menjadi list model.
List<T> mapList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is! List) return <T>[];
  return data.whereType<Map>().map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
}

Map<String, dynamic> asMap(dynamic data) => data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
