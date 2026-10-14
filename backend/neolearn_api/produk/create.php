<?php
/**
 * POST produk/create.php
 * Body JSON: { kategori_id, nama, harga, stok, deskripsi, gambar, penulis_merek,
 *              jenjang, format_produk, detail_tambahan, is_best_seller }
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_validasi.php';
requireMethod(['POST']);

try {
    $db = getConnection();
    $params = validasiProduk($db, getRequestBody());

    $stmt = $db->prepare('INSERT INTO produk
        (kategori_id, nama, harga, stok, deskripsi, gambar, penulis_merek, jenjang, format_produk, detail_tambahan, is_best_seller)
        VALUES (:kategori_id, :nama, :harga, :stok, :deskripsi, :gambar, :penulis_merek, :jenjang, :format_produk, :detail_tambahan, :is_best_seller)');
    $stmt->execute($params);

    $produk = ambilProduk($db, (int) $db->lastInsertId());
    sendResponse(true, 'Produk "' . $produk['nama'] . '" berhasil ditambahkan.', $produk, 201);
} catch (PDOException $e) {
    error_log('[produk/create] ' . $e->getMessage());
    sendResponse(false, 'Gagal menyimpan produk.', null, 500);
}
