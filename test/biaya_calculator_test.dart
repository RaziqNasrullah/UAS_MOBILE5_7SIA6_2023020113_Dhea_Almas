import 'package:flutter_test/flutter_test.dart';
import 'package:neolearn/app/data/services/api_config.dart';
import 'package:neolearn/app/utils/biaya_calculator.dart';

void main() {
  group('BiayaCalculator.hitung', () {
    test('Ambil di Toko, di bawah batas diskon', () {
      final r = BiayaCalculator.hitung(subtotal: 100000, tipePesanan: ApiConfig.tipeAmbil);
      expect(r.biayaLayanan, 2000);
      expect(r.ongkir, 0);
      expect(r.diskon, 0);
      expect(r.total, 102000);
    });

    test('Diantar, dapat diskon 10% (subtotal >= 150.000)', () {
      final r = BiayaCalculator.hitung(subtotal: 194000, tipePesanan: ApiConfig.tipeDiantar);
      expect(r.ongkir, 10000);
      expect(r.diskon, 19400);
      expect(r.total, 186600); // sama dengan seed INV pesanan #4
    });

    test('tepat 150.000 mendapat diskon', () {
      final r = BiayaCalculator.hitung(subtotal: 150000, tipePesanan: ApiConfig.tipeAmbil);
      expect(r.diskon, 15000);
      expect(r.total, 137000);
    });

    test('149.999 tidak mendapat diskon', () {
      final r = BiayaCalculator.hitung(subtotal: 149999, tipePesanan: ApiConfig.tipeAmbil);
      expect(r.diskon, 0);
    });

    test('Digital/Kelas Online tanpa ongkir', () {
      final r = BiayaCalculator.hitung(subtotal: 405000, tipePesanan: ApiConfig.tipeDigital);
      expect(r.ongkir, 0);
      expect(r.diskon, 40500);
      expect(r.total, 366500);
    });

    test('subtotal 0 menghasilkan total 0', () {
      final r = BiayaCalculator.hitung(subtotal: 0, tipePesanan: ApiConfig.tipeDiantar);
      expect(r.total, 0);
    });

    test('kurangUntukDiskon', () {
      expect(BiayaCalculator.kurangUntukDiskon(100000), 50000);
      expect(BiayaCalculator.kurangUntukDiskon(200000), 0);
    });
  });
}
