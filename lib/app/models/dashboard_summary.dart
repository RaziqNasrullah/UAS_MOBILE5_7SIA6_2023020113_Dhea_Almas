import '../utils/parse.dart';

class ProdukTerlaris {
  final int? produkId;
  final String namaProduk;
  final int totalTerjual;
  final double totalPenjualan;

  const ProdukTerlaris({
    this.produkId,
    required this.namaProduk,
    required this.totalTerjual,
    required this.totalPenjualan,
  });

  factory ProdukTerlaris.fromJson(Map<String, dynamic> j) => ProdukTerlaris(
    produkId: parseIntOrNull(j['produk_id']),
    namaProduk: (j['nama_produk'] ?? '').toString(),
    totalTerjual: parseInt(j['total_terjual']),
    totalPenjualan: parseDouble(j['total_penjualan']),
  );
}

class PendapatanHarian {
  final DateTime tanggal;
  final double pendapatan;
  final int jumlahPesanan;

  const PendapatanHarian({required this.tanggal, required this.pendapatan, required this.jumlahPesanan});

  factory PendapatanHarian.fromJson(Map<String, dynamic> j) => PendapatanHarian(
    tanggal: parseDate(j['tanggal']) ?? DateTime.now(),
    pendapatan: parseDouble(j['pendapatan']),
    jumlahPesanan: parseInt(j['jumlah_pesanan']),
  );
}

class PenjualanKategori {
  final String namaKategori;
  final int totalTerjual;
  final double totalPenjualan;

  const PenjualanKategori({required this.namaKategori, required this.totalTerjual, required this.totalPenjualan});

  factory PenjualanKategori.fromJson(Map<String, dynamic> j) => PenjualanKategori(
    namaKategori: (j['nama_kategori'] ?? '').toString(),
    totalTerjual: parseInt(j['total_terjual']),
    totalPenjualan: parseDouble(j['total_penjualan']),
  );
}

class DashboardSummary {
  final int totalPesanan;
  final double totalPendapatan;
  final int pesananDiproses;
  final int pesananSelesai;
  final int pesananDibatalkan;
  final int totalProduk;
  final int produkHabis;
  final List<ProdukTerlaris> produkTerlaris;
  final List<PendapatanHarian> pendapatanHarian;
  final List<PenjualanKategori> penjualanKategori;

  const DashboardSummary({
    required this.totalPesanan,
    required this.totalPendapatan,
    required this.pesananDiproses,
    required this.pesananSelesai,
    required this.pesananDibatalkan,
    required this.totalProduk,
    required this.produkHabis,
    required this.produkTerlaris,
    required this.pendapatanHarian,
    required this.penjualanKategori,
  });

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
      raw is List ? raw.whereType<Map>().map((e) => f(Map<String, dynamic>.from(e))).toList() : <T>[];

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    totalPesanan: parseInt(j['total_pesanan']),
    totalPendapatan: parseDouble(j['total_pendapatan']),
    pesananDiproses: parseInt(j['pesanan_diproses']),
    pesananSelesai: parseInt(j['pesanan_selesai']),
    pesananDibatalkan: parseInt(j['pesanan_dibatalkan']),
    totalProduk: parseInt(j['total_produk']),
    produkHabis: parseInt(j['produk_habis']),
    produkTerlaris: _list(j['produk_terlaris'], ProdukTerlaris.fromJson),
    pendapatanHarian: _list(j['pendapatan_harian'], PendapatanHarian.fromJson),
    penjualanKategori: _list(j['penjualan_kategori'], PenjualanKategori.fromJson),
  );

  ProdukTerlaris? get terlaris => produkTerlaris.isEmpty ? null : produkTerlaris.first;
}
