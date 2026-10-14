import 'package:flutter_test/flutter_test.dart';
import 'package:neolearn/app/models/dashboard_summary.dart';
import 'package:neolearn/app/models/kategori.dart';
import 'package:neolearn/app/models/keranjang_item.dart';
import 'package:neolearn/app/models/pesanan.dart';
import 'package:neolearn/app/models/produk.dart';

void main() {
  test('Kategori.fromJson', () {
    final k = Kategori.fromJson({'id': '4', 'nama': 'Kelas Kursus', 'deskripsi': '', 'jumlah_produk': 5});
    expect(k.id, 4);
    expect(k.deskripsi, isNull);
    expect(k.jumlahProduk, 5);
    expect(k.isKelasKursus, isTrue);
  });

  test('Produk.fromJson toleran angka berupa string (DECIMAL MySQL)', () {
    final p = Produk.fromJson({
      'id': '18',
      'kategori_id': 4,
      'nama_kategori': 'Kelas Kursus',
      'nama': 'Kelas Intensif Persiapan UTBK',
      'harga': '450000.00',
      'stok': '0',
      'deskripsi': 'Tryout mingguan',
      'gambar': 'p18_kelas_utbk.png',
      'penulis_merek': 'Tim Tutor NeoLearn',
      'jenjang': 'SMA/SMK',
      'format_produk': 'Kelas Offline',
      'detail_tambahan': '12 pertemuan',
      'is_best_seller': '0',
      'created_at': '2026-10-14 08:00:00',
    });
    expect(p.id, 18);
    expect(p.harga, 450000);
    expect(p.isHabis, isTrue);
    expect(p.isKelas, isTrue);
    expect(p.labelHabis, 'Kuota Penuh');
    expect(p.labelStok, 'Sisa kuota');
    expect(p.labelPenulis, 'Pengajar');
    expect(p.isBestSeller, isFalse);
    expect(p.imageUrl, endsWith('/uploads/p18_kelas_utbk.png'));
    expect(p.createdAt, DateTime(2026, 10, 14, 8));

    final json = p.toJson();
    expect(json['kategori_id'], 4);
    expect(json['format_produk'], 'Kelas Offline');
  });

  test('KeranjangItem subtotal & copyWith', () {
    final item = KeranjangItem.fromJson({
      'id': 1,
      'produk_id': 5,
      'jumlah': 2,
      'catatan_item': 'minta sampul plastik',
      'nama': 'Menulis Itu Mudah',
      'harga': '49000.00',
      'stok': 3,
      'format_produk': 'Cetak',
      'nama_kategori': 'Buku Pelajaran',
    });
    expect(item.subtotal, 98000);
    expect(item.isDigital, isFalse);
    final lebih = item.copyWith(jumlah: 4);
    expect(lebih.melebihiStok, isTrue);
    expect(item.copyWith(hapusCatatan: true).catatanItem, isNull);
  });

  test('Pesanan.fromJson dengan items', () {
    final p = Pesanan.fromJson({
      'id': 3,
      'nomor_pesanan': 'INV-20261013-001',
      'nama_pemesan': 'Aulia Rahmawati',
      'no_hp': '089876543210',
      'email': 'aulia.rahma@mail.com',
      'tipe_pesanan': 'Digital/Kelas Online',
      'alamat': null,
      'subtotal': '405000.00',
      'biaya_layanan': 2000,
      'ongkir': 0,
      'diskon': '40500.00',
      'total': '366500.00',
      'status': 'Selesai',
      'tanggal': '2026-10-13 13:30:29',
      'items': [
        {
          'id': 5,
          'pesanan_id': 3,
          'produk_id': 16,
          'nama_produk': 'Kelas Flutter',
          'harga_satuan': 350000,
          'jumlah': 1,
          'subtotal': 350000,
        },
        {
          'id': 6,
          'pesanan_id': 3,
          'produk_id': null,
          'nama_produk': 'English Smart Talk',
          'harga_satuan': '55000',
          'jumlah': '1',
          'subtotal': '55000',
        },
      ],
    });
    expect(p.total, 366500);
    expect(p.items, hasLength(2));
    expect(p.items[1].produkId, isNull);
    expect(p.totalQty, 2);
    expect(p.bisaDiubah, isFalse);
    expect(p.tanggal!.day, 13);
  });

  test('DashboardSummary.fromJson', () {
    final s = DashboardSummary.fromJson({
      'total_pesanan': 4,
      'total_pendapatan': 563800,
      'pesanan_diproses': 1,
      'pesanan_selesai': 2,
      'pesanan_dibatalkan': 1,
      'produk_terlaris': [
        {'produk_id': 1, 'nama_produk': 'Jago Matematika', 'total_terjual': '2', 'total_penjualan': '136000'},
      ],
      'pendapatan_harian': [
        {'tanggal': '2026-10-08', 'pendapatan': 197300, 'jumlah_pesanan': 1},
      ],
      'penjualan_kategori': [
        {'nama_kategori': 'Kelas Kursus', 'total_terjual': 1, 'total_penjualan': 350000},
      ],
    });
    expect(s.totalPendapatan, 563800);
    expect(s.terlaris!.totalTerjual, 2);
    expect(s.pendapatanHarian.single.tanggal, DateTime(2026, 10, 8));
    expect(s.penjualanKategori.single.namaKategori, 'Kelas Kursus');
  });

  test('DashboardSummary aman untuk data kosong', () {
    final s = DashboardSummary.fromJson({});
    expect(s.totalPesanan, 0);
    expect(s.terlaris, isNull);
    expect(s.produkTerlaris, isEmpty);
  });
}
