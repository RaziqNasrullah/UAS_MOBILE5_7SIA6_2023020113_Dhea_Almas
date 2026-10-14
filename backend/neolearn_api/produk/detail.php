<?php
/**
 * GET produk/detail.php?id=1
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['GET']);

try {
    $id = requireId($_GET['id'] ?? null, 'id produk');
    $stmt = getConnection()->prepare('SELECT p.*, k.nama AS nama_kategori
                                      FROM produk p JOIN kategori k ON p.kategori_id = k.id
                                      WHERE p.id = :id');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    if (!$row) {
        sendResponse(false, 'Produk tidak ditemukan.', null, 404);
    }
    sendResponse(true, 'Detail produk.', formatProduk($row));
} catch (PDOException $e) {
    error_log('[produk/detail] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat detail produk.', null, 500);
}
