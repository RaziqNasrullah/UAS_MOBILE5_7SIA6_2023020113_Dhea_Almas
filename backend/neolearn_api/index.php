<?php
/**
 * Cek status API: buka http://localhost/neolearn_api/ di browser.
 */
require_once __DIR__ . '/helpers/response.php';

try {
    $db = getConnection();
    $jumlahProduk = (int) $db->query('SELECT COUNT(*) FROM produk')->fetchColumn();
    sendResponse(true, 'NeoLearn API aktif dan terhubung ke database ' . DB_NAME . '.', [
        'app'           => 'NeoLearn API',
        'versi'         => '1.0.0',
        'database'      => DB_NAME,
        'jumlah_produk' => $jumlahProduk,
        'waktu_server'  => date('Y-m-d H:i:s'),
    ]);
} catch (PDOException $e) {
    sendResponse(false, 'API aktif, tetapi gagal terhubung ke database: pastikan MySQL XAMPP berjalan dan db_neolearn sudah di-import.', null, 500);
}
