import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:neolearn/app/models/detail_pesanan.dart';
import 'package:neolearn/app/models/pesanan.dart';
import 'package:neolearn/app/utils/pdf_generator.dart';

Pesanan _contohPesanan() => Pesanan(
  id: 4,
  nomorPesanan: 'INV-20261014-001',
  namaPemesan: 'Bima Prasetyo — "Kelas 7"', // em dash -> harus disanitasi
  noHp: '082199887766',
  tipePesanan: 'Diantar',
  alamat: 'Perum Griya Asri Blok C2 No. 7, Kota Bekasi',
  catatan: 'Tolong cepat \u{1F4DA}', // emoji buku -> dibuang
  subtotal: 194000,
  biayaLayanan: 2000,
  ongkir: 10000,
  diskon: 19400,
  total: 186600,
  status: 'Diproses',
  tanggal: DateTime(2026, 10, 14, 11, 30),
  totalQty: 3,
  items: const [
    DetailPesanan(
      id: 1,
      pesananId: 4,
      produkId: 1,
      namaProduk: 'Jago Matematika Kelas 4 SD: Modul Ceria',
      hargaSatuan: 68000,
      jumlah: 2,
      catatanItem: 'Untuk 2 anak ’ya’',
      subtotal: 136000,
    ),
    DetailPesanan(
      id: 2,
      pesananId: 4,
      produkId: 13,
      namaProduk: 'Binder A5 Pastel + Kertas Isi',
      hargaSatuan: 58000,
      jumlah: 1,
      subtotal: 58000,
    ),
  ],
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('StrukPdfGenerator.latin1Safe', () {
    test('mengganti em dash, kutip miring, dan membuang emoji', () {
      expect(StrukPdfGenerator.latin1Safe('A — B'), 'A - B');
      expect(StrukPdfGenerator.latin1Safe('“Halo” ‘x’'), '"Halo" \'x\'');
      expect(StrukPdfGenerator.latin1Safe('Buku \u{1F4DA}'), 'Buku ');
      expect(StrukPdfGenerator.latin1Safe('Rp145.000 café'), 'Rp145.000 café');
    });

    test('hasil selalu dalam rentang Latin-1', () {
      final out = StrukPdfGenerator.latin1Safe('Tes … • 中文 \u{1F600}');
      expect(out.runes.every((r) => r <= 0xFF), isTrue);
    });
  });

  test('build menghasilkan dokumen PDF valid (dengan & tanpa logo)', () async {
    final tanpaLogo = await StrukPdfGenerator.build(_contohPesanan());
    expect(String.fromCharCodes(tanpaLogo.take(5)), '%PDF-');
    expect(tanpaLogo.length, greaterThan(1000));

    final logo = File('assets/images/logo_mark.png').readAsBytesSync();
    final denganLogo = await StrukPdfGenerator.build(_contohPesanan(), logoBytes: logo);
    expect(String.fromCharCodes(denganLogo.take(5)), '%PDF-');
    expect(denganLogo.length, greaterThan(tanpaLogo.length));
  });

  test('nama file struk', () {
    expect(StrukPdfGenerator.namaFile(_contohPesanan()), 'Struk_INV-20261014-001.pdf');
  });
}
