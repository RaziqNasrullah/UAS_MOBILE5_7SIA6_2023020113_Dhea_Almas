/// Konfigurasi API & konstanta bisnis NeoLearn (satu tempat).
///
/// Base URL default untuk emulator Android. Untuk HP fisik ganti dengan IP LAN
/// laptop, atau jalankan:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10/neolearn_api
class ApiConfig {
  ApiConfig._();

  /// Emulator Android -> 10.0.2.2 (= localhost laptop).
  static const String emulatorBaseUrl = 'http://10.0.2.2/neolearn_api';

  /// Contoh untuk HP fisik (HP & laptop satu Wi-Fi). Ganti IP sesuai `ipconfig`.
  static const String deviceBaseUrlExample = 'http://192.168.1.10/neolearn_api';

  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: emulatorBaseUrl);

  static const Duration timeout = Duration(seconds: 15);

  /// URL lengkap gambar produk di folder uploads/.
  static String imageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';
    if (fileName.startsWith('http')) return fileName;
    return '$baseUrl/uploads/$fileName';
  }

  // ---- Konstanta biaya (HARUS sama dengan config/database.php) ----
  static const double biayaLayanan = 2000;
  static const double ongkirDiantar = 10000;
  static const double diskonPersen = 10;
  static const double minSubtotalDiskon = 150000;

  // ---- Nilai enum ----
  static const String kategoriKelasKursus = 'Kelas Kursus';
  static const List<String> jenjangList = ['SD', 'SMP', 'SMA/SMK', 'Perguruan Tinggi', 'Umum'];
  static const List<String> formatList = ['Cetak', 'E-Book', 'Barang Fisik', 'Kelas Online', 'Kelas Offline'];
  static const List<String> formatDigital = ['E-Book', 'Kelas Online'];
  static const String tipeAmbil = 'Ambil di Toko';
  static const String tipeDiantar = 'Diantar';
  static const String tipeDigital = 'Digital/Kelas Online';
  static const List<String> tipePesananList = [tipeAmbil, tipeDiantar, tipeDigital];
  static const List<String> statusList = ['Diproses', 'Selesai', 'Dibatalkan'];

  static const String namaToko = 'NeoLearn';
  static const String taglineToko = 'Unlock Your Digital Learning Potential';
}
