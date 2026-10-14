<?php
/**
 * Konfigurasi koneksi database & konstanta bisnis NeoLearn.
 *
 * Default XAMPP: host localhost, user root, password kosong.
 * Konstanta biaya HARUS sama dengan lib/app/data/services/api_config.dart.
 */

date_default_timezone_set('Asia/Jakarta');

define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_NAME', 'db_neolearn');
define('DB_USER', 'root');
define('DB_PASS', '');

// ---- Konstanta perhitungan biaya checkout ----
define('BIAYA_LAYANAN', 2000);          // Rp2.000 per pesanan
define('ONGKIR_DIANTAR', 10000);        // Rp10.000 jika tipe "Diantar"
define('DISKON_PERSEN', 10);            // diskon pelajar 10% ...
define('MIN_SUBTOTAL_DISKON', 150000);  // ... jika subtotal >= Rp150.000

// ---- Nilai enum yang valid ----
define('KATEGORI_KELAS_KURSUS', 'Kelas Kursus');
define('JENJANG_LIST', ['SD', 'SMP', 'SMA/SMK', 'Perguruan Tinggi', 'Umum']);
define('FORMAT_LIST', ['Cetak', 'E-Book', 'Barang Fisik', 'Kelas Online', 'Kelas Offline']);
define('FORMAT_DIGITAL', ['E-Book', 'Kelas Online']);
define('TIPE_PESANAN_LIST', ['Ambil di Toko', 'Diantar', 'Digital/Kelas Online']);
define('STATUS_LIST', ['Diproses', 'Selesai', 'Dibatalkan']);

// ---- Upload gambar ----
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('UPLOAD_MAX_BYTES', 2 * 1024 * 1024); // 2 MB

/**
 * Membuat koneksi PDO (satu instance per request).
 */
function getConnection(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }
    $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);
    $pdo->exec("SET time_zone = '+07:00'");
    return $pdo;
}
