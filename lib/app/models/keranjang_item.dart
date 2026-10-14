import '../data/services/api_config.dart';
import '../utils/parse.dart';

class KeranjangItem {
  final int id;
  final int produkId;
  final int jumlah;
  final String? catatanItem;
  final String nama;
  final double harga;
  final int stok;
  final String? gambar;
  final String penulisMerek;
  final String jenjang;
  final String formatProduk;
  final String? detailTambahan;
  final int kategoriId;
  final String namaKategori;

  const KeranjangItem({
    required this.id,
    required this.produkId,
    required this.jumlah,
    this.catatanItem,
    required this.nama,
    required this.harga,
    required this.stok,
    this.gambar,
    this.penulisMerek = '',
    this.jenjang = 'Umum',
    this.formatProduk = 'Cetak',
    this.detailTambahan,
    this.kategoriId = 0,
    this.namaKategori = '',
  });

  factory KeranjangItem.fromJson(Map<String, dynamic> json) => KeranjangItem(
    id: parseInt(json['id']),
    produkId: parseInt(json['produk_id']),
    jumlah: parseInt(json['jumlah'], fallback: 1),
    catatanItem: parseStringOrNull(json['catatan_item']),
    nama: (json['nama'] ?? '').toString(),
    harga: parseDouble(json['harga']),
    stok: parseInt(json['stok']),
    gambar: parseStringOrNull(json['gambar']),
    penulisMerek: (json['penulis_merek'] ?? '').toString(),
    jenjang: (json['jenjang'] ?? 'Umum').toString(),
    formatProduk: (json['format_produk'] ?? 'Cetak').toString(),
    detailTambahan: parseStringOrNull(json['detail_tambahan']),
    kategoriId: parseInt(json['kategori_id']),
    namaKategori: (json['nama_kategori'] ?? '').toString(),
  );

  KeranjangItem copyWith({int? jumlah, String? catatanItem, bool hapusCatatan = false}) => KeranjangItem(
    id: id,
    produkId: produkId,
    jumlah: jumlah ?? this.jumlah,
    catatanItem: hapusCatatan ? null : (catatanItem ?? this.catatanItem),
    nama: nama,
    harga: harga,
    stok: stok,
    gambar: gambar,
    penulisMerek: penulisMerek,
    jenjang: jenjang,
    formatProduk: formatProduk,
    detailTambahan: detailTambahan,
    kategoriId: kategoriId,
    namaKategori: namaKategori,
  );

  /// Subtotal per item dihitung di sisi aplikasi agar langsung reaktif.
  double get subtotal => harga * jumlah;
  String get imageUrl => ApiConfig.imageUrl(gambar);
  bool get isKelas => namaKategori.trim().toLowerCase() == ApiConfig.kategoriKelasKursus.toLowerCase();
  bool get isDigital => ApiConfig.formatDigital.contains(formatProduk);
  bool get melebihiStok => jumlah > stok;
  String get labelStok => isKelas ? 'kuota' : 'stok';
}
