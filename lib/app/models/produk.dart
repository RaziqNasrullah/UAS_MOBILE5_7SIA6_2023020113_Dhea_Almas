import '../data/services/api_config.dart';
import '../utils/parse.dart';

class Produk {
  final int id;
  final int kategoriId;
  final String namaKategori;
  final String nama;
  final double harga;
  final int stok;
  final String deskripsi;
  final String? gambar;
  final String penulisMerek;
  final String jenjang;
  final String formatProduk;
  final String? detailTambahan;
  final bool isBestSeller;
  final DateTime? createdAt;

  const Produk({
    required this.id,
    required this.kategoriId,
    required this.namaKategori,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.gambar,
    required this.penulisMerek,
    required this.jenjang,
    required this.formatProduk,
    this.detailTambahan,
    this.isBestSeller = false,
    this.createdAt,
  });

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
    id: parseInt(json['id']),
    kategoriId: parseInt(json['kategori_id']),
    namaKategori: (json['nama_kategori'] ?? '').toString(),
    nama: (json['nama'] ?? '').toString(),
    harga: parseDouble(json['harga']),
    stok: parseInt(json['stok']),
    deskripsi: (json['deskripsi'] ?? '').toString(),
    gambar: parseStringOrNull(json['gambar']),
    penulisMerek: (json['penulis_merek'] ?? '').toString(),
    jenjang: (json['jenjang'] ?? 'Umum').toString(),
    formatProduk: (json['format_produk'] ?? 'Cetak').toString(),
    detailTambahan: parseStringOrNull(json['detail_tambahan']),
    isBestSeller: parseBool(json['is_best_seller']),
    createdAt: parseDate(json['created_at']),
  );

  /// Body JSON untuk create/update.
  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'kategori_id': kategoriId,
    'nama': nama,
    'harga': harga,
    'stok': stok,
    'deskripsi': deskripsi,
    'gambar': gambar,
    'penulis_merek': penulisMerek,
    'jenjang': jenjang,
    'format_produk': formatProduk,
    'detail_tambahan': detailTambahan,
    'is_best_seller': isBestSeller,
  };

  String get imageUrl => ApiConfig.imageUrl(gambar);
  bool get isHabis => stok <= 0;
  bool get isKelas => namaKategori.trim().toLowerCase() == ApiConfig.kategoriKelasKursus.toLowerCase();
  bool get isDigital => ApiConfig.formatDigital.contains(formatProduk);

  /// "Stok" atau "Sisa kuota" untuk kelas.
  String get labelStok => isKelas ? 'Sisa kuota' : 'Stok';
  String get labelHabis => isKelas ? 'Kuota Penuh' : 'Habis';
  String get satuanStok => isKelas ? 'peserta' : (formatProduk == 'Barang Fisik' ? 'unit' : 'eksemplar');

  /// Label untuk penulis/merek/pengajar sesuai kategori.
  String get labelPenulis {
    if (isKelas) return 'Pengajar';
    if (formatProduk == 'Barang Fisik') return 'Merek';
    return 'Penulis';
  }
}
