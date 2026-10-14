<?php
/**
 * POST|PUT keranjang/update_qty.php
 * Body JSON: { "id": 1, "jumlah": 3 }   (1 <= jumlah <= stok)
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['POST', 'PUT']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? null, 'id keranjang');
    $jumlah = intOrNull($body['jumlah'] ?? null);
    if ($jumlah === null || $jumlah < 1) {
        sendResponse(false, 'Jumlah minimal 1. Gunakan tombol hapus untuk mengeluarkan produk.', null, 422);
    }

    $item = ambilItemKeranjang($db, $id);
    if ($item === null) {
        sendResponse(false, 'Item keranjang tidak ditemukan.', null, 404);
    }
    if ($jumlah > $item['stok']) {
        sendResponse(false, 'Jumlah melebihi ' . labelStok($item['nama_kategori']) . ' yang tersedia (' . $item['stok'] . ').', null, 409);
    }

    $db->prepare('UPDATE keranjang SET jumlah = :jumlah WHERE id = :id')->execute([':jumlah' => $jumlah, ':id' => $id]);
    sendResponse(true, 'Jumlah diperbarui.', ambilItemKeranjang($db, $id));
} catch (PDOException $e) {
    error_log('[keranjang/update_qty] ' . $e->getMessage());
    sendResponse(false, 'Gagal memperbarui jumlah.', null, 500);
}
