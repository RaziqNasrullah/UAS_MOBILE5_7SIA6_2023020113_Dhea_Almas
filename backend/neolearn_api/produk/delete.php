<?php
/**
 * POST|DELETE produk/delete.php
 * Body JSON: { "id": 1 }
 * Riwayat pesanan tetap aman karena detail_pesanan menyimpan snapshot nama & harga
 * (FK produk_id ON DELETE SET NULL). Item di keranjang ikut terhapus (CASCADE).
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['POST', 'DELETE']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? ($_GET['id'] ?? null), 'id produk');

    $stmt = $db->prepare('SELECT nama, gambar FROM produk WHERE id = :id');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    if (!$row) {
        sendResponse(false, 'Produk tidak ditemukan.', null, 404);
    }

    $db->prepare('DELETE FROM produk WHERE id = :id')->execute([':id' => $id]);

    // Hapus file gambar hasil upload (gambar seed bawaan diawali "p" + angka tetap disimpan).
    if (!empty($row['gambar']) && strpos($row['gambar'], 'upload_') === 0) {
        $path = UPLOAD_DIR . basename($row['gambar']);
        if (is_file($path)) {
            @unlink($path);
        }
    }

    sendResponse(true, 'Produk "' . $row['nama'] . '" berhasil dihapus.', ['id' => $id]);
} catch (PDOException $e) {
    error_log('[produk/delete] ' . $e->getMessage());
    sendResponse(false, 'Gagal menghapus produk.', null, 500);
}
