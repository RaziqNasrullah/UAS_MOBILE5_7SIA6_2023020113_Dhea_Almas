# NeoLearn — Toko Buku & Perlengkapan Belajar

<img src="assets/images/logo_neolearn.png" width="160" align="right" alt="Logo NeoLearn">

Aplikasi mobile **Flutter + GetX** untuk toko **NeoLearn**: katalog dan pemesanan **buku pelajaran, buku referensi kuliah, alat tulis, dan kelas kursus**, dengan backend **REST API PHP (PDO)** dan database **MySQL/MariaDB XAMPP**.

| | |
|---|---|
| Mahasiswa | **Dhea Almas** — NIRM **2023020113** — Kelas **7SIA6** |
| Package Android | `com.dheaalmas.neolearn` |
| Toolchain | Flutter **3.41.6** (stable) · Dart **3.11.4** |
| Android | AGP 8.11.1 · Kotlin 2.2.20 · Gradle 8.14 (template `flutter create` 3.41.6) |

```
Flutter (GetX)  ──HTTP/JSON──►  REST API PHP (XAMPP htdocs)  ──PDO──►  MySQL db_neolearn
```

---

## 1. Clone proyek

Gunakan branch ini agar folder tidak kosong saat di-clone:

```bash
git clone -b claude/new-session-9vcfsf https://github.com/RaziqNasrullah/UAS_MOBILE5_7SIA6_2023020113_Dhea_Almas.git
cd UAS_MOBILE5_7SIA6_2023020113_Dhea_Almas
```

## 2. Struktur folder

```
├── lib/
│   ├── main.dart
│   └── app/
│       ├── models/         kategori, produk, keranjang_item, pesanan, detail_pesanan, dashboard_summary
│       ├── controllers/    main, home, kategori, produk, katalog, cart, checkout, pesanan, pesanan_detail, dashboard, struk
│       ├── views/          satu folder per halaman (splash, home, katalog, produk_detail, cart, checkout, …)
│       ├── routes/         app_routes.dart (nama route) + app_pages.dart (GetPage + binding)
│       ├── data/services/  api_config, api_service (http), kategori/produk/keranjang/pesanan/dashboard_service
│       ├── widgets/        ProdukCard, CategoryChip, CartBadgeIcon, CustomTextField, SummaryCard, QtyStepper, …
│       ├── bindings/       binding per halaman + InitialBinding
│       ├── theme/          app_theme.dart (ThemeData), app_colors.dart
│       └── utils/          formatter, validators, biaya_calculator, pdf_generator, app_snackbar
├── backend/neolearn_api/   REST API PHP → salin ke C:\xampp\htdocs\neolearn_api
├── database/db_neolearn.sql  skema + data seed (import lewat phpMyAdmin)
├── docs/                   kebutuhan, diagram (puml + png), ERD & normalisasi, black box testing, panduan laporan, screenshot
├── scripts/                zip_source.sh / zip_source.ps1
└── test/                   unit & widget test
```

## 3. Setup backend (XAMPP)

1. Buka **XAMPP Control Panel**, lalu **Start** modul **Apache** dan **MySQL**.
2. Buka `http://localhost/phpmyadmin` → tab **Import** → pilih `database/db_neolearn.sql` → **Go**.
   Hasilnya database `db_neolearn` dengan 5 tabel, 4 kategori, 20 produk, 4 contoh pesanan, dan 2 item keranjang.
3. Salin folder `backend/neolearn_api` ke `C:\xampp\htdocs\neolearn_api`:
   ```powershell
   xcopy /E /I /Y backend\neolearn_api C:\xampp\htdocs\neolearn_api
   ```
4. Cek di browser: `http://localhost/neolearn_api/`. Respons yang benar:
   ```json
   {"success":true,"message":"NeoLearn API aktif dan terhubung ke database db_neolearn.", ...}
   ```
5. Konfigurasi koneksi ada di `C:\xampp\htdocs\neolearn_api\config\database.php` (default XAMPP: `root` tanpa password).

### Endpoint API & contoh curl

Semua respons berformat `{ "success": true|false, "message": "...", "data": ... }` dengan status HTTP 200/201/400/404/405/409/422/500.

| Modul | Endpoint |
|---|---|
| Kategori | `kategori/read.php` (GET), `create.php`, `update.php`, `delete.php` (POST JSON) |
| Produk | `produk/read.php?search=&kategori_id=&best_seller=1&sort=terbaru`, `detail.php?id=`, `create.php`, `update.php`, `delete.php`, `upload_gambar.php` (multipart `gambar`) |
| Keranjang | `keranjang/read.php`, `add.php`, `update_qty.php`, `update_catatan.php`, `delete.php`, `clear.php` |
| Pesanan | `pesanan/checkout.php`, `read.php?status=`, `detail.php?id=`, `update_status.php` |
| Dashboard | `dashboard/summary.php` |

```bash
B=http://localhost/neolearn_api
curl "$B/produk/read.php?search=dart&kategori_id=2"
curl -X POST -H "Content-Type: application/json" -d '{"nama":"alat tulis"}' $B/kategori/create.php        # 409 duplikat
curl -X POST -H "Content-Type: application/json" -d '{"id":1}' $B/kategori/delete.php                     # 409 masih ada produk
curl -X POST -H "Content-Type: application/json" -d '{"produk_id":16,"jumlah":1,"catatan_item":"jadwal sesi sore"}' $B/keranjang/add.php
curl -X POST -H "Content-Type: application/json" -d '{"nama_pemesan":"Dhea Almas","no_hp":"081234567890","email":"dhea@mail.com","tipe_pesanan":"Diantar","alamat":"Jl. Kenanga No. 5, Bandung"}' $B/pesanan/checkout.php
curl -X POST -H "Content-Type: application/json" -d '{"id":5,"status":"Dibatalkan"}' $B/pesanan/update_status.php
curl -F "gambar=@sampul.png" $B/produk/upload_gambar.php
curl $B/dashboard/summary.php
```
> Di Windows PowerShell gunakan `curl.exe` dan escape tanda kutip, atau uji lewat Postman.

## 4. Mengatur Base URL API

Base URL ada di **satu file**, `lib/app/data/services/api_config.dart`:

| Perangkat | Base URL |
|---|---|
| Emulator Android (default) | `http://10.0.2.2/neolearn_api` |
| HP fisik (satu Wi-Fi dengan laptop) | `http://<IP-LAN-laptop>/neolearn_api` |

Bisa juga tanpa mengubah kode:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/neolearn_api
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10/neolearn_api
```

- **Cek IP laptop:** jalankan `ipconfig` di CMD, lalu lihat **IPv4 Address** pada adapter Wi-Fi (mis. `192.168.1.10`).
- **Firewall:** saat pertama kali Apache berjalan, izinkan akses di jaringan **Private**. Jika HP tidak bisa terhubung, buka *Windows Defender Firewall → Allow an app* lalu centang **Apache HTTP Server** (Private). Uji dari browser HP: `http://192.168.1.10/neolearn_api/`.
- Halaman **Toko → Cek Koneksi Server** di aplikasi menampilkan base URL aktif dan status koneksi.
- HTTP lokal tetap berjalan di APK release karena `AndroidManifest.xml` (main) memuat permission `INTERNET`, `usesCleartextTraffic="true"`, dan `networkSecurityConfig="@xml/network_security_config"`.

## 5. Menjalankan aplikasi Flutter

```bash
flutter doctor                       # cek toolchain (Flutter 3.41.6 / Dart 3.11.4)
flutter pub get                      # unduh dependency
flutter emulators                    # daftar emulator
flutter emulators --launch <nama>    # jalankan emulator, mis. Pixel_7_API_35
flutter devices                      # pastikan emulator/HP terdeteksi
flutter run                          # jalankan (debug)
flutter analyze                      # analisis kode -> "No issues found!"
flutter test                         # unit & widget test (34 test)
flutter clean                        # bersihkan build jika ada error aneh
flutter build apk --release          # build APK release
```

Ikon launcher sudah dibuat dari logo. Untuk membuat ulang: `dart run flutter_launcher_icons`.

## 6. Build & instal APK

- Lokasi APK: `build/app/outputs/flutter-apk/app-release.apk`
- Instal lewat USB (USB debugging aktif): `adb install -r build/app/outputs/flutter-apk/app-release.apk`
- Atau salin file APK ke HP, buka dari File Manager, lalu izinkan *Install unknown apps*.

## 7. Fitur

| No | Fitur | Lokasi utama |
|---|---|---|
| 1 | Analisis & perancangan (kebutuhan, Use Case, Activity, ERD + normalisasi) | `docs/` |
| 2 | GetX: `GetMaterialApp`, `GetPage`, `Get.toNamed` + `arguments`, ThemeData, custom widget | `lib/main.dart`, `lib/app/routes`, `lib/app/theme`, `lib/app/widgets` |
| 3 | CRUD Kategori + validasi kosong & duplikat (aplikasi & server) | `kategori_controller.dart`, `backend/.../kategori/` |
| 4 | CRUD Produk + dropdown kategori (FK) + gambar + atribut pendidikan + JOIN nama kategori | `produk_controller.dart`, `backend/.../produk/` |
| 5 | Pencarian realtime (Obx + debounce 400 ms) + filter ChoiceChip | `katalog_controller.dart`, `katalog_view.dart` |
| 6 | Beranda (sapaan waktu), Katalog GridView, Detail + catatan | `views/home`, `views/katalog`, `views/produk_detail` |
| 7 | Keranjang reaktif (CartController), validasi stok, badge | `cart_controller.dart`, `cart_badge_icon.dart` |
| 8 | Checkout + INV-YYYYMMDD-NNN + biaya/diskon + transaksi stok | `checkout_controller.dart`, `backend/.../pesanan/checkout.php` |
| 9 | Riwayat & detail pesanan, ubah status, stok kembali saat batal | `views/pesanan*`, `update_status.php` |
| 10 | Dashboard (kartu ringkasan, BarChart, LineChart, PieChart) | `views/dashboard`, `dashboard/summary.php` |
| 11 | Struk PDF: preview, simpan, bagikan | `utils/pdf_generator.dart`, `views/struk` |
| 12 | Error handling, black box testing, unit test, build release | `api_service.dart`, `docs/black_box_testing.md`, `test/` |

Aturan biaya (sama di `api_config.dart` & `config/database.php`, dihitung ulang di server): layanan **Rp2.000**, ongkir **Rp10.000** (Diantar), diskon pelajar **10%** jika subtotal ≥ **Rp150.000**.

## 8. Troubleshooting

| Masalah | Solusi |
|---|---|
| `The current Dart SDK version is … version solving failed` | Pastikan `flutter --version` menunjukkan **3.41.6 / Dart 3.11.4**. Jangan menaikkan `sdk:` di pubspec. Hapus `pubspec.lock` lalu `flutter pub get`. Jangan memakai `flutter pub add` dari SDK yang lebih baru. |
| Error compile `ZLibDecoder.decodeLazy` di package pdf/image | Constraint `image: ">=4.5.0 <4.11.0"` harus tetap ada di pubspec. |
| Gradle/AGP mismatch, `Unresolved reference 'compilerOptions'` | Folder `android/` harus hasil template Flutter 3.41.6 (AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, `kotlinOptions`). Jangan upgrade ke AGP 9. Jalankan `flutter clean` lalu build ulang. Gunakan JDK 17 (`flutter doctor -v`). |
| Data kosong / "Tidak dapat terhubung ke server" | Pastikan Apache & MySQL XAMPP **Start**, `db_neolearn` sudah di-import, `http://localhost/neolearn_api/` menampilkan `success: true`, dan base URL benar (emulator `10.0.2.2`, HP pakai IP LAN). |
| HP fisik tidak bisa akses API | HP & laptop harus satu Wi-Fi. Izinkan Apache di firewall. Tes URL API di browser HP. |
| Gambar produk tidak muncul | Pastikan folder `uploads/` ikut tersalin ke `htdocs/neolearn_api/uploads`. |
| Upload gambar gagal "izin folder" | Pastikan folder `uploads` bisa ditulis (default XAMPP Windows sudah bisa). |

## 9. Bahan pengumpulan

1. **Source code (.zip)** tanpa `build/`: `bash scripts/zip_source.sh` atau `powershell -ExecutionPolicy Bypass -File scripts\zip_source.ps1`
2. **APK release**: `build/app/outputs/flutter-apk/app-release.apk`
3. **Laporan PDF**: ikuti `docs/panduan_laporan.md` (berisi daftar screenshot). Tabel pengujian ada di `docs/black_box_testing.md` dan contoh struk di `docs/contoh_struk_INV-20261014-002.pdf`.

## 10. Status verifikasi

- `flutter analyze` → **No issues found!** (Flutter 3.41.6)
- `flutter test` → **34 test lulus**
- Seluruh endpoint API diuji dengan curl terhadap MariaDB (lihat `docs/black_box_testing.md`)
- Alur UI diuji pada build web dari kode yang sama (screenshot di `docs/screenshots/`)
- **`flutter build apk --release` belum diuji** di lingkungan pengembangan ini, karena Android SDK tidak bisa diunduh (akses `dl.google.com` diblokir). Folder `android/` adalah template asli Flutter 3.41.6, dan hanya `AndroidManifest.xml`, `res/xml/network_security_config.xml`, serta ikon launcher yang diubah. Jalankan build di laptop sesuai Bagian 5–6.
