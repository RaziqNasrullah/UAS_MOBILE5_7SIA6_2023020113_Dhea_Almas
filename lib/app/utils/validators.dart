/// Kumpulan validator form. Mengembalikan pesan error (String) atau null jika valid.
class Validators {
  Validators._();

  static String? wajib(String? v, {String label = 'Field ini'}) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  /// Nama kategori: wajib & tidak duplikat (case-insensitive, abaikan spasi tepi).
  static String? namaKategori(String? v, Iterable<String> namaLain) {
    final err = wajib(v, label: 'Nama kategori');
    if (err != null) return err;
    final n = v!.trim().toLowerCase();
    if (namaLain.any((e) => e.trim().toLowerCase() == n)) {
      return 'Kategori "${v.trim()}" sudah ada';
    }
    if (v.trim().length > 100) return 'Maksimal 100 karakter';
    return null;
  }

  static String? harga(String? v) {
    final err = wajib(v, label: 'Harga');
    if (err != null) return err;
    final n = double.tryParse(v!.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (n == null) return 'Harga harus berupa angka';
    if (n <= 0) return 'Harga harus lebih dari 0';
    return null;
  }

  static String? stok(String? v, {String label = 'Stok'}) {
    final err = wajib(v, label: label);
    if (err != null) return err;
    final n = int.tryParse(v!.trim());
    if (n == null) return '$label harus berupa bilangan bulat';
    if (n < 0) return '$label tidak boleh negatif';
    return null;
  }

  /// No HP Indonesia: angka 10-13 digit, diawali 08. Spasi/strip diabaikan.
  static String? noHp(String? v) {
    final err = wajib(v, label: 'Nomor HP');
    if (err != null) return err;
    final s = normalisasiHp(v!);
    if (!RegExp(r'^[0-9]+$').hasMatch(s)) return 'Nomor HP hanya boleh berisi angka';
    if (!s.startsWith('08')) return 'Nomor HP harus diawali 08';
    if (s.length < 10 || s.length > 13) return 'Nomor HP harus 10-13 digit';
    return null;
  }

  static String normalisasiHp(String v) => v.replaceAll(RegExp(r'[\s-]'), '');

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[A-Za-z]{2,}$');

  static String? email(String? v, {required bool wajibDiisi}) {
    if (v == null || v.trim().isEmpty) {
      return wajibDiisi ? 'Email wajib diisi untuk pesanan Kelas Kursus' : null;
    }
    if (!_email.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? alamat(String? v, {required bool wajibDiisi}) {
    if (!wajibDiisi) return null;
    if (v == null || v.trim().isEmpty) return 'Alamat wajib diisi untuk pesanan Diantar';
    if (v.trim().length < 10) return 'Alamat terlalu singkat (min. 10 karakter)';
    return null;
  }
}
