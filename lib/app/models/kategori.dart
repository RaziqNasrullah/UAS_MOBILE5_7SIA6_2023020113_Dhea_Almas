import '../utils/parse.dart';

class Kategori {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? ikon;
  final int jumlahProduk;

  const Kategori({required this.id, required this.nama, this.deskripsi, this.ikon, this.jumlahProduk = 0});

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    id: parseInt(json['id']),
    nama: (json['nama'] ?? '').toString(),
    deskripsi: parseStringOrNull(json['deskripsi']),
    ikon: parseStringOrNull(json['ikon']),
    jumlahProduk: parseInt(json['jumlah_produk']),
  );

  Map<String, dynamic> toJson() => {if (id > 0) 'id': id, 'nama': nama, 'deskripsi': deskripsi, 'ikon': ikon};

  bool get isKelasKursus => nama.trim().toLowerCase() == 'kelas kursus';
}
