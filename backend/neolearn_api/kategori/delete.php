<?php
/**
 * POST|DELETE kategori/delete.php
 * Body JSON: { "id": 1 }   (atau query ?id=1)
 * Ditolak (409) jika kategori masih memiliki produk.
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['POST', 'DELETE']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? ($_GET['id'] ?? null), 'id kategori');

    $stmt = $db->prepare('SELECT k.nama, COUNT(p.id) AS jumlah
                          FROM kategori k LEFT JOIN produk p ON p.kategori_id = k.id
                          WHERE k.id = :id GROUP BY k.id');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    if (!$row) {
        sendResponse(false, 'Kategori tidak ditemukan.', null, 404);
    }
    if ((int) $row['jumlah'] > 0) {
        sendResponse(false, 'Kategori "' . $row['nama'] . '" tidak dapat dihapus karena masih memiliki '
            . $row['jumlah'] . ' produk. Pindahkan atau hapus produknya terlebih dahulu.', null, 409);
    }

    $db->prepare('DELETE FROM kategori WHERE id = :id')->execute([':id' => $id]);
    sendResponse(true, 'Kategori "' . $row['nama'] . '" berhasil dihapus.', ['id' => $id]);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        sendResponse(false, 'Kategori tidak dapat dihapus karena masih dipakai produk.', null, 409);
    }
    error_log('[kategori/delete] ' . $e->getMessage());
    sendResponse(false, 'Gagal menghapus kategori.', null, 500);
}
