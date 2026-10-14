# Panduan Penyusunan Laporan UAS — NeoLearn

**Identitas:** Dhea Almas — NIRM 2023020113 — Kelas 7SIA6
**Judul:** Aplikasi Mobile Toko Buku & Perlengkapan Belajar "NeoLearn" Berbasis Flutter GetX dan MySQL (XAMPP)

## Susunan Laporan

1. **Halaman judul**: judul, logo NeoLearn (`assets/images/logo_neolearn.png`), nama, NIRM, kelas, mata kuliah, tahun.
2. **Bab 1 — Pendahuluan**: latar belakang (kebutuhan belanja buku & kelas secara digital), rumusan masalah, tujuan, batasan (Android, server lokal XAMPP, tanpa payment gateway).
3. **Bab 2 — Analisis & Perancangan**
   - 2.1 Kebutuhan fungsional & non-fungsional → salin dari [`kebutuhan.md`](kebutuhan.md)
   - 2.2 Use Case Diagram → [`diagram/use_case.png`](diagram/use_case.png)
   - 2.3 Activity Diagram checkout → [`diagram/activity_checkout.png`](diagram/activity_checkout.png)
   - 2.4 ERD + normalisasi 1NF–3NF → [`diagram/erd.png`](diagram/erd.png), [`erd_normalisasi.md`](erd_normalisasi.md)
   - 2.5 Arsitektur 3 lapis: Flutter (GetX) → HTTP/JSON → PHP (PDO) → MySQL
4. **Bab 3 — Implementasi**
   - Struktur folder GetX (models, controllers, views, routes, data/services, widgets, bindings, theme, utils)
   - Routing `GetMaterialApp` + `GetPage` + `Get.toNamed(arguments: …)` (`lib/app/routes/`)
   - ThemeData & custom widget (`lib/app/theme/app_theme.dart`, `lib/app/widgets/`)
   - Potongan kode penting: debounce pencarian (`katalog_controller.dart`), keranjang reaktif (`cart_controller.dart`), transaksi checkout (`backend/neolearn_api/pesanan/checkout.php`), struk PDF (`lib/app/utils/pdf_generator.dart`)
   - Screenshot setiap halaman (daftar di bawah)
5. **Bab 4 — Pengujian**: tabel Black Box Testing dari [`black_box_testing.md`](black_box_testing.md), hasil `flutter test` (34 test lulus), contoh struk PDF ([`contoh_struk_INV-20261014-002.pdf`](contoh_struk_INV-20261014-002.pdf)).
6. **Bab 5 — Penutup**: kesimpulan & saran (mis. login multi-user, payment gateway, notifikasi).
7. **Lampiran**: link repository + perintah clone, langkah instalasi (README).

## Daftar Screenshot yang Perlu Diambil (dari HP/emulator)

Folder [`screenshots/`](screenshots/) berisi tangkapan layar hasil pengujian **versi web** (kode yang sama). Untuk laporan, sebaiknya ambil ulang screenshot dari **emulator/HP Android**:

| No | Halaman | Yang perlu terlihat | Contoh |
|---|---|---|---|
| 1 | Splash | Logo NeoLearn | – |
| 2 | Beranda | Sapaan waktu, kategori, banner diskon, best seller, badge keranjang | `01_home.jpg` |
| 3 | Katalog | Grid produk + chip kategori | `02_katalog.jpg` |
| 4 | Katalog — pencarian | Hasil cari "lestari" | `03_katalog_search.jpg` |
| 5 | Katalog — filter + cari | Chip Kelas Kursus + kata "flutter" | `04b_filter_search.jpg` |
| 6 | Detail produk | Badge jenjang, format, detail tambahan, catatan | `07_detail_kelas.jpg` |
| 7 | Detail produk kuota penuh | Tombol "Kuota Penuh" nonaktif | `06_detail_kuota_penuh.jpg` |
| 8 | Keranjang | Catatan item, qty, subtotal, total, info diskon | `09_keranjang.jpg` |
| 9 | Keranjang — melebihi stok | Snackbar peringatan | `10_keranjang_melebihi_stok.jpg` |
| 10 | Checkout — validasi | Error form kosong / no HP salah | `14_…`, `15_…` |
| 11 | Checkout — Diantar | Field alamat & rincian biaya | `16b_…`, `17_…` |
| 12 | Pesanan berhasil | Nomor INV & total | `18_checkout_sukses.jpg` |
| 13 | Preview struk PDF | PdfPreview + tombol Simpan & Bagikan | (ambil di HP) |
| 14 | Snackbar path simpan PDF | Path folder Download | (ambil di HP) |
| 15 | Riwayat pesanan | Warna status & filter | `20_riwayat.jpg` |
| 16 | Detail pesanan + dialog batal | Item, catatan, rincian, dialog | `22_…`, `23_…` |
| 17 | Dashboard | Kartu ringkasan & 3 grafik | `26_…`–`28_…` |
| 18 | Kelola Kategori | List + error duplikat + hapus ditolak | `29_…`–`31_…` |
| 19 | Kelola Produk + form | JOIN nama kategori, form & label Kuota Peserta | `32_…`–`34_…` |
| 20 | Error server mati | Tombol Coba Lagi | `35_server_mati.jpg` |
| 21 | Ikon launcher di HP | Ikon NeoLearn di home screen | (ambil di HP) |
| 22 | phpMyAdmin | 5 tabel db_neolearn & relasi (Designer) | (ambil di laptop) |
