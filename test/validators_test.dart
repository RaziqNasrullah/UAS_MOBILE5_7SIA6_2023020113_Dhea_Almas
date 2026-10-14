import 'package:flutter_test/flutter_test.dart';
import 'package:neolearn/app/utils/validators.dart';

void main() {
  group('Validators.namaKategori', () {
    const existing = ['Buku Pelajaran', 'Alat Tulis'];

    test('kosong ditolak', () {
      expect(Validators.namaKategori('', existing), isNotNull);
      expect(Validators.namaKategori('   ', existing), isNotNull);
    });

    test('duplikat ditolak (case-insensitive & spasi tepi)', () {
      expect(Validators.namaKategori('alat tulis', existing), contains('sudah ada'));
      expect(Validators.namaKategori('  BUKU PELAJARAN ', existing), contains('sudah ada'));
    });

    test('nama baru diterima', () {
      expect(Validators.namaKategori('Kelas Kursus', existing), isNull);
    });
  });

  group('Validators.noHp', () {
    test('valid: 10-13 digit diawali 08', () {
      expect(Validators.noHp('0812345678'), isNull); // 10 digit
      expect(Validators.noHp('0812345678901'), isNull); // 13 digit
      expect(Validators.noHp('0812-3456-7890'), isNull); // strip diabaikan
    });

    test('tidak valid', () {
      expect(Validators.noHp(''), isNotNull);
      expect(Validators.noHp('081234567'), isNotNull); // 9 digit
      expect(Validators.noHp('08123456789012'), isNotNull); // 14 digit
      expect(Validators.noHp('0912345678'), contains('08'));
      expect(Validators.noHp('0812abc456'), contains('angka'));
      expect(Validators.noHp('+6281234567'), isNotNull);
    });
  });

  group('Validators.email', () {
    test('wajib jika ada Kelas Kursus', () {
      expect(Validators.email('', wajibDiisi: true), isNotNull);
      expect(Validators.email('', wajibDiisi: false), isNull);
    });

    test('format', () {
      expect(Validators.email('dhea@mail.com', wajibDiisi: true), isNull);
      expect(Validators.email('dhea.almas+kelas@kampus.ac.id', wajibDiisi: true), isNull);
      expect(Validators.email('dhea@', wajibDiisi: true), isNotNull);
      expect(Validators.email('dhea mail.com', wajibDiisi: false), isNotNull);
    });
  });

  group('Validators harga, stok, alamat', () {
    test('harga harus > 0', () {
      expect(Validators.harga('75000'), isNull);
      expect(Validators.harga('0'), isNotNull);
      expect(Validators.harga('abc'), isNotNull);
      expect(Validators.harga(''), isNotNull);
    });

    test('stok bilangan bulat >= 0', () {
      expect(Validators.stok('0'), isNull);
      expect(Validators.stok('25'), isNull);
      expect(Validators.stok('-1'), isNotNull);
      expect(Validators.stok('2.5'), isNotNull);
      expect(Validators.stok('', label: 'Kuota Peserta'), contains('Kuota Peserta'));
    });

    test('alamat wajib hanya jika Diantar', () {
      expect(Validators.alamat('', wajibDiisi: false), isNull);
      expect(Validators.alamat('', wajibDiisi: true), isNotNull);
      expect(Validators.alamat('Jl. A', wajibDiisi: true), isNotNull);
      expect(Validators.alamat('Jl. Kenanga No. 5, Bandung', wajibDiisi: true), isNull);
    });
  });
}
