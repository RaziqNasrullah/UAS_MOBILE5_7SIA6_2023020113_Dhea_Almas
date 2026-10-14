<?php
/**
 * GET kategori/read.php            -> semua kategori + jumlah produk
 * GET kategori/read.php?id=1       -> satu kategori
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['GET']);

try {
    $db = getConnection();
    $sql = 'SELECT k.id, k.nama, k.deskripsi, k.ikon, k.created_at, k.updated_at,
                   COUNT(p.id) AS jumlah_produk
            FROM kategori k
            LEFT JOIN produk p ON p.kategori_id = k.id';

    if (isset($_GET['id'])) {
        $id = requireId($_GET['id']);
        $stmt = $db->prepare($sql . ' WHERE k.id = :id GROUP BY k.id');
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch();
        if (!$row) {
            sendResponse(false, 'Kategori tidak ditemukan.', null, 404);
        }
        sendResponse(true, 'Detail kategori.', castNumbers($row, ['id', 'jumlah_produk']));
    }

    $rows = $db->query($sql . ' GROUP BY k.id ORDER BY k.id ASC')->fetchAll();
    $rows = array_map(fn($r) => castNumbers($r, ['id', 'jumlah_produk']), $rows);
    sendResponse(true, 'Berhasil memuat ' . count($rows) . ' kategori.', $rows);
} catch (PDOException $e) {
    error_log('[kategori/read] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat kategori dari database.', null, 500);
}
