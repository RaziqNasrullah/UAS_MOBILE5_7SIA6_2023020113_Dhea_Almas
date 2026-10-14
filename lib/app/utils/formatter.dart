import 'package:intl/intl.dart';

/// Format rupiah & tanggal (locale Indonesia).
class Formatter {
  Formatter._();

  static final NumberFormat _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  /// 145000 -> "Rp145.000"
  static String rupiah(num value) => _rupiah.format(value).replaceAll(' ', '');

  /// Tanggal lengkap: "14 Okt 2026, 13:05"
  static String tanggalWaktu(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
  }

  /// "Selasa, 14 Oktober 2026"
  static String tanggalPanjang(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
  }

  /// Label sumbu grafik: "14/10"
  static String tanggalPendek(DateTime d) => DateFormat('dd/MM').format(d);

  /// Nama hari singkat: "Sel"
  static String hariSingkat(DateTime d) => DateFormat('EEE', 'id_ID').format(d);

  /// 1250000 -> "1,3 jt", 85000 -> "85 rb" (untuk label grafik)
  static String ringkas(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1).replaceAll('.', ',')} jt';
    }
    if (value >= 1000) return '${(value / 1000).round()} rb';
    return value.toStringAsFixed(0);
  }
}

/// Sapaan sesuai waktu, bernuansa belajar.
class Sapaan {
  Sapaan._();

  static String waktu(DateTime now) {
    final h = now.hour;
    if (h >= 4 && h < 11) return 'pagi';
    if (h >= 11 && h < 15) return 'siang';
    if (h >= 15 && h < 18) return 'sore';
    return 'malam';
  }

  static String judul(DateTime now) => 'Selamat ${waktu(now)}!';

  static String pesan(DateTime now) {
    switch (waktu(now)) {
      case 'pagi':
        return 'Siap belajar hari ini? Awali dengan semangat baru.';
      case 'siang':
        return 'Istirahat sejenak, lalu lanjutkan belajarmu.';
      case 'sore':
        return 'Waktunya mengulang materi hari ini.';
      default:
        return 'Belajar sebentar sebelum tidur, yuk!';
    }
  }
}
