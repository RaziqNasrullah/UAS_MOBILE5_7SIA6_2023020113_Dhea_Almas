<?php
/**
 * POST|DELETE keranjang/delete.php
 * Body JSON: { "id": 1 }
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['POST', 'DELETE']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? ($_GET['id'] ?? null), 'id keranjang');
    $stmt = $db->prepare('DELETE FROM keranjang WHERE id = :id');
    $stmt->execute([':id' => $id]);
    if ($stmt->rowCount() === 0) {
        sendResponse(false, 'Item keranjang tidak ditemukan.', null, 404);
    }
    sendResponse(true, 'Produk dihapus dari keranjang.', ['id' => $id]);
} catch (PDOException $e) {
    error_log('[keranjang/delete] ' . $e->getMessage());
    sendResponse(false, 'Gagal menghapus item keranjang.', null, 500);
}
