-- =====================================================================
--  NeoLearn - Toko Buku & Perlengkapan Belajar
--  Database : db_neolearn  (MySQL / MariaDB XAMPP)
--  Penyusun : Dhea Almas - NIRM 2023020113 - Kelas 7SIA6
--
--  Cara pakai: phpMyAdmin > tab "Import" > pilih file ini > "Go".
--  File ini aman di-import ulang: tabel lama dihapus lalu dibuat kembali.
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+07:00';
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS db_neolearn
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE db_neolearn;

DROP TABLE IF EXISTS detail_pesanan;
DROP TABLE IF EXISTS pesanan;
DROP TABLE IF EXISTS keranjang;
DROP TABLE IF EXISTS produk;
DROP TABLE IF EXISTS kategori;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. kategori
--    Collation utf8mb4_general_ci bersifat case-insensitive, sehingga
--    UNIQUE (nama) juga menolak "alat tulis" bila "Alat Tulis" sudah ada.
-- ---------------------------------------------------------------------
CREATE TABLE kategori (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  nama        VARCHAR(100)  NOT NULL,
  deskripsi   VARCHAR(255)  NULL,
  ikon        VARCHAR(50)   NULL,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_kategori_nama (nama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- 2. produk  (kategori 1 - N produk)
--    ON DELETE RESTRICT: kategori yang masih memiliki produk tidak bisa dihapus.
-- ---------------------------------------------------------------------
CREATE TABLE produk (
  id               INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  kategori_id      INT UNSIGNED   NOT NULL,
  nama             VARCHAR(150)   NOT NULL,
  harga            DECIMAL(12,2)  NOT NULL,
  stok             INT            NOT NULL DEFAULT 0,
  deskripsi        TEXT           NULL,
  gambar           VARCHAR(255)   NULL,
  penulis_merek    VARCHAR(120)   NOT NULL,
  jenjang          ENUM('SD','SMP','SMA/SMK','Perguruan Tinggi','Umum') NOT NULL DEFAULT 'Umum',
  format_produk    ENUM('Cetak','E-Book','Barang Fisik','Kelas Online','Kelas Offline') NOT NULL DEFAULT 'Cetak',
  detail_tambahan  VARCHAR(100)   NULL,
  is_best_seller   TINYINT(1)     NOT NULL DEFAULT 0,
  created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_produk_kategori (kategori_id),
  KEY idx_produk_nama (nama),
  CONSTRAINT fk_produk_kategori FOREIGN KEY (kategori_id)
    REFERENCES kategori (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_produk_harga CHECK (harga > 0),
  CONSTRAINT chk_produk_stok  CHECK (stok >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- 3. keranjang  (produk 1 - 0..1 keranjang; UNIQUE produk_id agar tidak dobel)
-- ---------------------------------------------------------------------
CREATE TABLE keranjang (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  produk_id     INT UNSIGNED  NOT NULL,
  jumlah        INT           NOT NULL DEFAULT 1,
  catatan_item  VARCHAR(255)  NULL,
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_keranjang_produk (produk_id),
  CONSTRAINT fk_keranjang_produk FOREIGN KEY (produk_id)
    REFERENCES produk (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_keranjang_jumlah CHECK (jumlah >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- 4. pesanan
-- ---------------------------------------------------------------------
CREATE TABLE pesanan (
  id             INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  nomor_pesanan  VARCHAR(20)    NOT NULL,
  nama_pemesan   VARCHAR(100)   NOT NULL,
  no_hp          VARCHAR(15)    NOT NULL,
  email          VARCHAR(120)   NULL,
  tipe_pesanan   ENUM('Ambil di Toko','Diantar','Digital/Kelas Online') NOT NULL,
  alamat         TEXT           NULL,
  catatan        VARCHAR(255)   NULL,
  subtotal       DECIMAL(12,2)  NOT NULL DEFAULT 0,
  biaya_layanan  DECIMAL(12,2)  NOT NULL DEFAULT 0,
  ongkir         DECIMAL(12,2)  NOT NULL DEFAULT 0,
  diskon         DECIMAL(12,2)  NOT NULL DEFAULT 0,
  total          DECIMAL(12,2)  NOT NULL DEFAULT 0,
  status         ENUM('Diproses','Selesai','Dibatalkan') NOT NULL DEFAULT 'Diproses',
  tanggal        DATETIME       NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pesanan_nomor (nomor_pesanan),
  KEY idx_pesanan_tanggal (tanggal),
  KEY idx_pesanan_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- 5. detail_pesanan  (pesanan 1 - N detail, produk 1 - N detail)
--    nama_produk & harga_satuan = snapshot saat transaksi.
-- ---------------------------------------------------------------------
CREATE TABLE detail_pesanan (
  id            INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  pesanan_id    INT UNSIGNED   NOT NULL,
  produk_id     INT UNSIGNED   NULL,
  nama_produk   VARCHAR(150)   NOT NULL,
  harga_satuan  DECIMAL(12,2)  NOT NULL,
  jumlah        INT            NOT NULL,
  catatan_item  VARCHAR(255)   NULL,
  subtotal      DECIMAL(12,2)  NOT NULL,
  PRIMARY KEY (id),
  KEY idx_detail_pesanan (pesanan_id),
  KEY idx_detail_produk (produk_id),
  CONSTRAINT fk_detail_pesanan FOREIGN KEY (pesanan_id)
    REFERENCES pesanan (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detail_produk FOREIGN KEY (produk_id)
    REFERENCES produk (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_detail_jumlah CHECK (jumlah >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================================
--  DATA SEED (orisinal - judul, penulis, merek & pengajar fiktif)
-- =====================================================================

INSERT INTO kategori (id, nama, deskripsi, ikon) VALUES
(1, 'Buku Pelajaran',        'Modul, buku latihan, dan bank soal untuk SD, SMP, dan SMA/SMK.', 'menu_book'),
(2, 'Buku Referensi Kuliah', 'Buku teks dan referensi untuk mahasiswa berbagai jurusan.',      'school'),
(3, 'Alat Tulis',            'Perlengkapan menulis dan belajar sehari-hari.',                  'edit'),
(4, 'Kelas Kursus',          'Kelas belajar online dan offline bersama pengajar NeoLearn. Stok = kuota peserta.', 'cast_for_education');

INSERT INTO produk
(id, kategori_id, nama, harga, stok, deskripsi, gambar, penulis_merek, jenjang, format_produk, detail_tambahan, is_best_seller) VALUES
-- Buku Pelajaran
(1, 1, 'Jago Matematika Kelas 4 SD: Modul Ceria', 68000, 25,
 'Modul matematika bergambar dengan pembahasan langkah demi langkah, permainan angka, dan 300 soal latihan bertingkat. Cocok untuk belajar mandiri di rumah.',
 'p01_jago_matematika_sd.png', 'Rina Kartikasari', 'SD', 'Cetak', '184 halaman', 1),
(2, 1, 'Latihan IPA Terpadu SMP Kelas 8', 79000, 18,
 'Ringkasan materi fisika, biologi, dan kimia dasar disertai eksperimen sederhana dan latihan soal model asesmen.',
 'p02_latihan_ipa_smp.png', 'Bayu Pradipta', 'SMP', 'Cetak', '232 halaman', 0),
(3, 1, 'Bank Soal UTBK-SNBT Saintek Edisi 2027', 145000, 30,
 'Lebih dari 1.500 soal latihan TPS dan literasi lengkap dengan pembahasan, strategi waktu, dan 5 paket tryout.',
 'p03_bank_soal_utbk.png', 'Tim Pena Cendekia', 'SMA/SMK', 'Cetak', '512 halaman', 1),
(4, 1, 'English Smart Talk untuk SMA', 55000, 99,
 'E-book percakapan bahasa Inggris sehari-hari, grammar praktis, dan latihan speaking dengan QR audio.',
 'p04_english_smart_talk.png', 'Nadia Prameswari', 'SMA/SMK', 'E-Book', '160 halaman', 0),
(5, 1, 'Menulis Itu Mudah: Modul Bahasa Indonesia SMP', 49000, 3,
 'Panduan menulis teks deskripsi, narasi, dan eksposisi dengan contoh karya siswa dan lembar kerja.',
 'p05_menulis_itu_mudah.png', 'Arif Wicaksana', 'SMP', 'Cetak', '148 halaman', 0),
-- Buku Referensi Kuliah
(6, 2, 'Pengantar Sistem Informasi: Konsep & Studi Kasus', 125000, 12,
 'Membahas komponen sistem informasi, proses bisnis, ERP, hingga transformasi digital dengan studi kasus UMKM Indonesia.',
 'p06_pengantar_si.png', 'Dr. Hendra Saputra', 'Perguruan Tinggi', 'Cetak', '348 halaman', 1),
(7, 2, 'Basis Data Relasional dari Nol', 115000, 10,
 'Perancangan ERD, normalisasi 1NF-3NF, SQL dasar hingga lanjut, transaksi, dan indeks dengan MySQL.',
 'p07_basis_data.png', 'Maya Lestari, M.Kom.', 'Perguruan Tinggi', 'Cetak', '296 halaman', 0),
(8, 2, 'Algoritma & Pemrograman dengan Dart', 89000, 99,
 'E-book pemrograman terstruktur: percabangan, perulangan, fungsi, rekursi, dan struktur data menggunakan bahasa Dart.',
 'p08_algoritma_dart.png', 'Fajar Nugroho', 'Perguruan Tinggi', 'E-Book', '274 halaman', 0),
(9, 2, 'Akuntansi Dasar untuk Mahasiswa Non-Akuntansi', 98000, 7,
 'Persamaan akuntansi, jurnal, buku besar, hingga laporan keuangan sederhana dengan bahasa yang ringan.',
 'p09_akuntansi_dasar.png', 'Sri Wahyuningsih', 'Perguruan Tinggi', 'Cetak', '260 halaman', 0),
(10, 2, 'Metodologi Penelitian Praktis untuk Skripsi', 135000, 15,
 'Langkah menyusun proposal, memilih metode kuantitatif/kualitatif, mengolah data, dan menulis bab pembahasan.',
 'p10_metodologi_penelitian.png', 'Prof. Bambang Irawan', 'Perguruan Tinggi', 'Cetak', '312 halaman', 0),
-- Alat Tulis
(11, 3, 'Set Pensil 2B NeoGraph', 36000, 60,
 'Pensil 2B untuk ujian berbasis LJK, grafit halus dan tidak mudah patah. Termasuk penghapus dan rautan mini.',
 'p11_pensil_2b.png', 'NeoGraph', 'Umum', 'Barang Fisik', 'isi 12 pcs', 1),
(12, 3, 'Pulpen Gel Smooth 0.5 mm Warna-Warni', 42000, 45,
 'Pulpen gel cepat kering dengan grip karet, tinta tidak tembus kertas. Cocok untuk mencatat dan bullet journal.',
 'p12_pulpen_gel.png', 'InkFlow', 'Umum', 'Barang Fisik', 'isi 6 pcs', 0),
(13, 3, 'Binder A5 Pastel + Kertas Isi', 58000, 20,
 'Binder 26 ring bersampul pastel dengan 100 lembar kertas bergaris dan 5 pembatas warna.',
 'p13_binder_a5.png', 'Notara', 'Umum', 'Barang Fisik', '26 ring, 100 lembar', 0),
(14, 3, 'Stabilo Pastel Highlighter', 45000, 35,
 'Highlighter warna pastel yang lembut di mata, ujung pahat 1-5 mm untuk menandai materi penting.',
 'p14_stabilo_pastel.png', 'BrightMark', 'Umum', 'Barang Fisik', 'isi 5 warna', 0),
(15, 3, 'Kalkulator Ilmiah CX-82 Pro', 165000, 9,
 'Kalkulator ilmiah 252 fungsi untuk statistik, trigonometri, dan matriks. Diizinkan untuk ujian sekolah.',
 'p15_kalkulator_ilmiah.png', 'Calcora', 'SMA/SMK', 'Barang Fisik', '252 fungsi', 0),
-- Kelas Kursus (stok = sisa kuota peserta)
(16, 4, 'Kelas Flutter Pemula: Aplikasi Pertamamu', 350000, 20,
 'Belajar membuat aplikasi Android dengan Flutter dan GetX dari nol hingga build APK. Termasuk sertifikat dan rekaman sesi.',
 'p16_kelas_flutter.png', 'Raka Mahendra', 'Perguruan Tinggi', 'Kelas Online', '8 pertemuan', 1),
(17, 4, 'Kelas Excel untuk Kuliah & Kerja', 275000, 15,
 'Rumus, pivot table, grafik, dan dashboard sederhana untuk tugas kuliah dan laporan kerja. Di ruang kelas NeoLearn.',
 'p17_kelas_excel.png', 'Dewi Anggraini', 'Perguruan Tinggi', 'Kelas Offline', '6 pertemuan', 0),
(18, 4, 'Kelas Intensif Persiapan UTBK', 450000, 0,
 'Pembahasan TPS, literasi, dan penalaran matematika bersama tutor berpengalaman, plus tryout mingguan.',
 'p18_kelas_utbk.png', 'Tim Tutor NeoLearn', 'SMA/SMK', 'Kelas Offline', '12 pertemuan', 0),
(19, 4, 'Kelas TOEFL Prediction Score Booster', 399000, 25,
 'Strategi listening, structure, dan reading TOEFL ITP dengan 3 kali simulasi tes.',
 'p19_kelas_toefl.png', 'Clara Wijaya', 'Umum', 'Kelas Online', '10 pertemuan', 0),
(20, 4, 'Kelas Menulis Karya Ilmiah', 199000, 30,
 'Teknik menulis artikel ilmiah, sitasi dengan reference manager, dan tips publikasi jurnal nasional.',
 'p20_kelas_karya_ilmiah.png', 'Dr. Yusuf Hidayat', 'Perguruan Tinggi', 'Kelas Online', '4 pertemuan', 0);

-- ---------------------------------------------------------------------
-- Contoh pesanan. Tanggal dibuat relatif terhadap waktu import supaya
-- grafik "7 hari terakhir" di dashboard langsung terisi.
-- Rumus biaya: layanan Rp2.000; ongkir Rp10.000 (Diantar);
-- diskon 10% jika subtotal >= Rp150.000; total = subtotal + layanan + ongkir - diskon.
-- ---------------------------------------------------------------------
SET @t1 = DATE_SUB(NOW(), INTERVAL 6 DAY);
SET @t2 = DATE_SUB(NOW(), INTERVAL 3 DAY);
SET @t3 = DATE_SUB(NOW(), INTERVAL 1 DAY);
SET @t4 = DATE_SUB(NOW(), INTERVAL 2 HOUR);

INSERT INTO pesanan
(id, nomor_pesanan, nama_pemesan, no_hp, email, tipe_pesanan, alamat, catatan,
 subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal) VALUES
(1, CONCAT('INV-', DATE_FORMAT(@t1, '%Y%m%d'), '-001'), 'Salsabila Putri', '081234567890', NULL,
 'Ambil di Toko', NULL, 'Diambil sepulang sekolah',
 217000, 2000, 0, 21700, 197300, 'Selesai', @t1),
(2, CONCAT('INV-', DATE_FORMAT(@t2, '%Y%m%d'), '-001'), 'Rizky Ramadhan', '085711223344', NULL,
 'Diantar', 'Jl. Melati No. 12, RT 03/RW 05, Kel. Sukamaju, Kota Bandung', 'Tolong dibungkus rapi',
 167000, 2000, 10000, 16700, 162300, 'Dibatalkan', @t2),
(3, CONCAT('INV-', DATE_FORMAT(@t3, '%Y%m%d'), '-001'), 'Aulia Rahmawati', '089876543210', 'aulia.rahma@mail.com',
 'Digital/Kelas Online', NULL, 'Kirim link kelas ke email',
 405000, 2000, 0, 40500, 366500, 'Selesai', @t3),
(4, CONCAT('INV-', DATE_FORMAT(@t4, '%Y%m%d'), '-001'), 'Bima Prasetyo', '082199887766', NULL,
 'Diantar', 'Perum Griya Asri Blok C2 No. 7, Kota Bekasi', NULL,
 194000, 2000, 10000, 19400, 186600, 'Diproses', @t4);

INSERT INTO detail_pesanan
(pesanan_id, produk_id, nama_produk, harga_satuan, jumlah, catatan_item, subtotal) VALUES
(1, 3,  'Bank Soal UTBK-SNBT Saintek Edisi 2027',          145000, 1, 'Minta sampul plastik', 145000),
(1, 11, 'Set Pensil 2B NeoGraph',                           36000, 2, NULL,                    72000),
(2, 6,  'Pengantar Sistem Informasi: Konsep & Studi Kasus', 125000, 1, NULL,                   125000),
(2, 12, 'Pulpen Gel Smooth 0.5 mm Warna-Warni',              42000, 1, 'Warna biru dominan',   42000),
(3, 16, 'Kelas Flutter Pemula: Aplikasi Pertamamu',         350000, 1, 'Jadwal sesi malam',   350000),
(3, 4,  'English Smart Talk untuk SMA',                      55000, 1, NULL,                    55000),
(4, 1,  'Jago Matematika Kelas 4 SD: Modul Ceria',           68000, 2, 'Untuk 2 anak',        136000),
(4, 13, 'Binder A5 Pastel + Kertas Isi',                     58000, 1, 'Warna mint',           58000);

-- Contoh isi keranjang agar halaman keranjang langsung bisa dicoba.
INSERT INTO keranjang (produk_id, jumlah, catatan_item) VALUES
(7,  1, 'Minta sampul plastik'),
(14, 2, NULL);

ALTER TABLE kategori       AUTO_INCREMENT = 5;
ALTER TABLE produk         AUTO_INCREMENT = 21;
ALTER TABLE pesanan        AUTO_INCREMENT = 5;
