import '../utils/parse.dart';
import 'detail_pesanan.dart';

class Pesanan {
  final int id;
  final String nomorPesanan;
  final String namaPemesan;
  final String noHp;
  final String? email;
  final String tipePesanan;
  final String? alamat;
  final String? catatan;
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;
  final String status;
  final DateTime? tanggal;
  final int jumlahItem;
  final int totalQty;
  final List<DetailPesanan> items;

  const Pesanan({
    required this.id,
    required this.nomorPesanan,
    required this.namaPemesan,
    required this.noHp,
    this.email,
    required this.tipePesanan,
    this.alamat,
    this.catatan,
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
    required this.status,
    this.tanggal,
    this.jumlahItem = 0,
    this.totalQty = 0,
    this.items = const [],
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map>().map((e) => DetailPesanan.fromJson(Map<String, dynamic>.from(e))).toList()
        : <DetailPesanan>[];
    return Pesanan(
      id: parseInt(json['id']),
      nomorPesanan: (json['nomor_pesanan'] ?? '').toString(),
      namaPemesan: (json['nama_pemesan'] ?? '').toString(),
      noHp: (json['no_hp'] ?? '').toString(),
      email: parseStringOrNull(json['email']),
      tipePesanan: (json['tipe_pesanan'] ?? '').toString(),
      alamat: parseStringOrNull(json['alamat']),
      catatan: parseStringOrNull(json['catatan']),
      subtotal: parseDouble(json['subtotal']),
      biayaLayanan: parseDouble(json['biaya_layanan']),
      ongkir: parseDouble(json['ongkir']),
      diskon: parseDouble(json['diskon']),
      total: parseDouble(json['total']),
      status: (json['status'] ?? 'Diproses').toString(),
      tanggal: parseDate(json['tanggal']),
      jumlahItem: parseInt(json['jumlah_item'], fallback: items.length),
      totalQty: parseInt(json['total_qty'], fallback: items.fold<int>(0, (s, e) => s + e.jumlah)),
      items: items,
    );
  }

  bool get bisaDiubah => status == 'Diproses';
}
