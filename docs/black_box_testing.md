# Black Box Testing — NeoLearn

**Penguji:** Dhea Almas (2023020113 · 7SIA6) · **Tanggal uji:** 14 Oktober 2026

## Lingkungan & metode pengujian

Pengujian dilakukan dengan tiga cara. Kolom **Hasil Aktual** menyebut cara yang dipakai:

| Kode | Metode | Keterangan |
|---|---|---|
| **[API]** | Request `curl` langsung ke REST API PHP + MariaDB 10.11 | Menguji validasi server, transaksi, dan isi database (dicek dengan query SQL). |
| **[UI]** | Kode Flutter yang sama di-build sebagai web (Chromium, layar 412×870) lalu dioperasikan otomatis, terhubung ke API & database di atas | Menguji alur layar, validasi form, snackbar, dan state reaktif. Screenshot ada di folder [`screenshots/`](screenshots/). |
| **[UT]** | `flutter test` (34 unit & widget test) | Validator, kalkulasi biaya, parsing model, pembuatan PDF, penanganan error API. |

> **Belum diuji di HP/emulator Android.** Lingkungan pengujian tidak dapat mengunduh Android SDK (akses `dl.google.com` diblokir), sehingga `flutter build apk --release` dan fitur khusus Android (galeri `image_picker`, simpan PDF ke folder Download, share sheet, HTTP cleartext di APK release) **belum dijalankan**. Baris yang terkait ditandai **"Perlu diuji di HP"**. Setelah mengujinya di emulator atau HP, perbarui kolom Hasil Aktual & Status.

## Tabel pengujian

| No | Fitur | Skenario | Hasil yang Diharapkan | Hasil Aktual | Status |
|---|---|---|---|---|---|
| 1 | Kategori | Simpan kategori dengan nama kosong | Ditolak, pesan "Nama kategori wajib diisi" | [UI] Pesan validasi muncul di form. [API] HTTP 422 "Nama kategori tidak boleh kosong." | Lulus |
| 2 | Kategori | Tambah kategori "alat tulis" (sudah ada "Alat Tulis") | Ditolak karena duplikat (case-insensitive) | [UI] Pesan `Kategori "alat tulis" sudah ada` (lihat `31_kategori_duplikat.jpg`). [API] HTTP 409. | Lulus |
| 3 | Kategori | Tambah, ubah, lalu hapus kategori baru "Perlengkapan Lab" | Data tersimpan, berubah, lalu terhapus | [API] 201 → 200 → 200; dicek di tabel `kategori`. | Lulus |
| 4 | Kategori | Hapus kategori "Buku Pelajaran" yang masih punya 5 produk | Ditolak dengan pesan jelas | [UI] Snackbar "Tidak dapat dihapus … masih memiliki 5 produk" (`30_kategori_hapus_ditolak.jpg`). [API] HTTP 409. | Lulus |
| 5 | Produk | Tambah produk dengan harga 0 / stok "abc" / jenjang tidak valid | Ditolak dengan pesan sesuai | [API] HTTP 422 untuk ketiganya. [UT] `Validators.harga` & `Validators.stok` menolak. | Lulus |
| 6 | Produk | Upload gambar (PNG) lalu tambah produk "Penggaris Besi 30 cm"; ubah harga tanpa mengganti gambar; hapus | Gambar tersimpan di `uploads/`, produk muncul dengan nama kategori hasil JOIN, gambar lama dipertahankan saat update, file upload ikut terhapus | [API] Upload 201, create 201 (`nama_kategori` = "Alat Tulis"), update 200 (gambar tetap), delete 200, file `upload_*` terhapus. | Lulus |
| 7 | Produk | Upload file .txt sebagai gambar | Ditolak | [API] HTTP 422 "File harus berupa gambar JPG, PNG, atau WEBP." | Lulus |
| 8 | Produk | Pilih gambar dari galeri HP di form produk | Preview gambar tampil, tersimpan setelah Simpan | Belum diuji: `image_picker` galeri membutuhkan perangkat Android. | Perlu diuji di HP |
| 9 | Produk | Pilih kategori "Kelas Kursus" di form produk | Label "Stok" → "Kuota Peserta", "Penulis" → "Nama Pengajar", format → Kelas Online | [UI] Label & format berubah (`34_produk_form_kelas.jpg`). | Lulus |
| 10 | Pencarian | Ketik "lestari" (nama penulis) di katalog | Muncul "Basis Data Relasional dari Nol" | [UI] 1 produk tampil setelah debounce (`03_katalog_search.jpg`). | Lulus |
| 11 | Pencarian | Ketik "zzz" | Tampil "Produk tidak ditemukan" + tombol Reset Filter | [UI] Empty state tampil (`05_katalog_kosong.jpg`). | Lulus |
| 12 | Filter | Pilih chip "Kelas Kursus", lalu cari "flutter" | 5 kelas tampil, lalu hanya "Kelas Flutter Pemula" | [UI] 5 produk → 1 produk (`04_…`, `04b_…`). | Lulus |
| 13 | Detail & Keranjang | Tambah "Kelas Flutter Pemula" dengan catatan "Jadwal sesi malam" | Snackbar sukses, badge bertambah, catatan tersimpan | [UI] Snackbar "Berhasil" (`08_detail_added.jpg`); tabel `keranjang` berisi catatan "Jadwal sesi malam". | Lulus |
| 14 | Keranjang | Edit catatan item Stabilo menjadi "warna kuning & hijau" | Catatan tersimpan & tampil | [UI] Dialog catatan → "Catatan disimpan." (`11_edit_catatan.jpg`); DB terupdate. | Lulus |
| 15 | Keranjang | Tekan + melebihi stok (stok Stabilo diset 3, qty 3) | Jumlah tetap 3, muncul peringatan stok | [UI] Snackbar "Jumlah tidak boleh melebihi stok yang tersedia (3)." (`10_keranjang_melebihi_stok.jpg`). [API] update_qty 4 → HTTP 409. | Lulus |
| 16 | Keranjang | Subtotal, total & badge saat qty berubah | Berubah otomatis tanpa reload | [UI] Subtotal Rp90.000 → Rp135.000, total Rp555.000 → Rp600.000, badge 4 → 5. | Lulus |
| 17 | Produk habis | Buka detail "Kelas Intensif Persiapan UTBK" (kuota 0) | Tombol nonaktif bertuliskan "Kuota Penuh" | [UI] Tombol abu-abu "Kuota Penuh" (`06_detail_kuota_penuh.jpg`). [API] add → 409 "Kuota kelas sudah penuh." | Lulus |
| 18 | Checkout | Tekan "Buat Pesanan" dengan form kosong | Semua field wajib menampilkan error | [UI] Error nama, no HP, email + snackbar "Periksa kembali data pemesan" (`14_checkout_validasi.jpg`). [API] 422 "Nama pemesan wajib diisi." | Lulus |
| 19 | Checkout | No HP "0912345" | Ditolak: harus diawali 08 dan 10–13 digit | [UI] "Nomor HP harus diawali 08" (`15_checkout_hp_salah.jpg`). [API] 422. [UT] lulus. | Lulus |
| 20 | Checkout | Pilih Diantar tanpa mengisi alamat | Alamat muncul & wajib diisi | [UI] Field alamat muncul, "Alamat wajib diisi untuk pesanan Diantar" (`16b_alamat_wajib.jpg`). [API] 422. | Lulus |
| 21 | Checkout | Keranjang berisi Kelas Kursus, email dikosongkan | Field email muncul & wajib | [UI] "Email wajib diisi untuk pesanan Kelas Kursus". [API] 422. | Lulus |
| 22 | Checkout | Keranjang berisi buku cetak, coba pilih "Digital/Kelas Online" | Opsi nonaktif / ditolak | [UI] Opsi abu-abu dengan keterangan. [API] 422 "hanya untuk pesanan yang seluruh itemnya E-Book atau Kelas Online". | Lulus |
| 23 | Checkout | Checkout sukses (Diantar, subtotal Rp600.000) | Pesanan tersimpan, stok berkurang, keranjang kosong, halaman sukses | [UI] Halaman sukses INV-20261014-002 (`18_checkout_sukses.jpg`). DB: stok 10→9, 3→0, 20→19; keranjang 0 baris; 3 detail dengan catatan. | Lulus |
| 24 | Perhitungan biaya | Subtotal 600.000, Diantar | Layanan 2.000 + ongkir 10.000 − diskon 60.000 = 552.000 | [UI] Rincian sesuai (`17_checkout_rincian.jpg`); DB total 552000.00. [UT] 7 kasus termasuk batas 149.999/150.000. | Lulus |
| 25 | Nomor INV | Checkout 2× pada hari yang sama setelah seed INV-…-001 | Nomor INV-YYYYMMDD-002 lalu -003 | [API] INV-20261014-002 lalu INV-20261014-003. | Lulus |
| 26 | Checkout (transaksi) | Stok berubah menjadi lebih kecil dari jumlah di keranjang sebelum checkout | Rollback, tidak ada pesanan baru, pesan stok tidak cukup | [API] HTTP 409 "Stok … tidak mencukupi (tersedia 1, diminta 3)"; jumlah pesanan & stok tidak berubah. | Lulus |
| 27 | Riwayat | Buka tab Pesanan & filter "Selesai" | Urut terbaru, warna status beda, filter berfungsi | [UI] Urutan 14 Okt → 8 Okt, badge oranye/hijau/merah (`20_riwayat.jpg`, `21_…`). | Lulus |
| 28 | Ubah status | Batalkan pesanan INV-20261014-002 | Dialog konfirmasi, status Dibatalkan, stok kembali, tombol aksi hilang | [UI] Dialog → "Stok/kuota 3 produk dikembalikan" (`23_…`, `24_…`). DB stok kembali 10/3/20. | Lulus |
| 29 | Ubah status | Ubah lagi pesanan yang sudah Dibatalkan | Ditolak | [API] HTTP 409 "sudah berstatus Dibatalkan dan tidak dapat diubah lagi". [UI] Tombol aksi tidak ditampilkan. | Lulus |
| 30 | Dashboard | Buka Dashboard Penjualan | Total pesanan, pendapatan (hanya Selesai), terlaris, 3 grafik | [UI] 5 pesanan, Rp563.800 (= 197.300 + 366.500), BarChart, LineChart, PieChart tampil (`26_…`–`28_…`). | Lulus |
| 31 | Struk PDF | Buat struk pesanan | Berisi logo & nama NeoLearn, no pesanan, tanggal, tipe & alamat/email, item + catatan, rincian biaya, total, nama pemesan | [UT] PDF valid. File hasil generator dirender: semua elemen ada ([`contoh_struk_INV-20261014-002.png`](contoh_struk_INV-20261014-002.png)). | Lulus |
| 32 | Struk PDF | Preview di aplikasi, Simpan ke perangkat, Bagikan | Preview tampil, file tersimpan di folder Download aplikasi (path di snackbar), share sheet terbuka | Belum diuji: preview/simpan/bagikan memakai plugin native Android (`printing`, `path_provider`). | Perlu diuji di HP |
| 33 | Error handling | Server API mati saat aplikasi dibuka | Tampilan error + tombol "Coba Lagi", aplikasi tidak crash | [UI] "Oops, terjadi masalah … Coba Lagi" di Beranda & Katalog (`35_…`, `36_…`). [UT] SocketException → pesan koneksi. | Lulus |
| 34 | Error handling | MySQL mati, API Apache masih hidup | JSON error 500 yang jelas | [API] `{"success":false,"message":"API aktif, tetapi gagal terhubung ke database…"}` HTTP 500. | Lulus |
| 35 | Error handling | Respons kosong / bukan JSON | Pesan error ramah | [UT] ApiException "respons kosong" / "bukan JSON". | Lulus |
| 36 | Deployment | `flutter build apk --release`, instal di HP, akses API via IP LAN | APK terpasang bernama NeoLearn dengan ikon logo; data tampil | Belum diuji (Android SDK tidak tersedia di lingkungan uji). `flutter analyze` bersih & `flutter test` 34/34 lulus. | Perlu diuji di HP |

**Ringkasan:** 33 skenario lulus. 3 skenario (No. 8, 32, 36) perlu diuji di HP/emulator Android.
