<?php
/**
 * POST|PUT keranjang/update_catatan.php
 * Body JSON: { "id": 1, "catatan_item": "warna biru" }  (kosong = hapus catatan)
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['POST', 'PUT']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? null, 'id keranjang');
    $catatan = strOrNull($body, 'catatan_item');
    if ($catatan !== null && mb_strlen($catatan) > 255) {
        sendResponse(false, 'Catatan item maksimal 255 karakter.', null, 422);
    }
    if (ambilItemKeranjang($db, $id) === null) {
        sendResponse(false, 'Item keranjang tidak ditemukan.', null, 404);
    }
    $db->prepare('UPDATE keranjang SET catatan_item = :c WHERE id = :id')->execute([':c' => $catatan, ':id' => $id]);
    sendResponse(true, $catatan === null ? 'Catatan dihapus.' : 'Catatan disimpan.', ambilItemKeranjang($db, $id));
} catch (PDOException $e) {
    error_log('[keranjang/update_catatan] ' . $e->getMessage());
    sendResponse(false, 'Gagal menyimpan catatan.', null, 500);
}
