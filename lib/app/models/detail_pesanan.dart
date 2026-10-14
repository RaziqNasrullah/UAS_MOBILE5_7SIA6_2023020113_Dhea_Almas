import '../utils/parse.dart';

class DetailPesanan {
  final int id;
  final int pesananId;
  final int? produkId;
  final String namaProduk;
  final double hargaSatuan;
  final int jumlah;
  final String? catatanItem;
  final double subtotal;
  final String? namaKategori;

  const DetailPesanan({
    required this.id,
    required this.pesananId,
    this.produkId,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.jumlah,
    this.catatanItem,
    required this.subtotal,
    this.namaKategori,
  });

  factory DetailPesanan.fromJson(Map<String, dynamic> json) => DetailPesanan(
    id: parseInt(json['id']),
    pesananId: parseInt(json['pesanan_id']),
    produkId: parseIntOrNull(json['produk_id']),
    namaProduk: (json['nama_produk'] ?? '').toString(),
    hargaSatuan: parseDouble(json['harga_satuan']),
    jumlah: parseInt(json['jumlah']),
    catatanItem: parseStringOrNull(json['catatan_item']),
    subtotal: parseDouble(json['subtotal']),
    namaKategori: parseStringOrNull(json['nama_kategori']),
  );
}
