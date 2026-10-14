<?php
/**
 * GET produk/read.php
 * Query opsional:
 *   search=...        cari di nama produk ATAU penulis/merek/pengajar
 *   kategori_id=2     filter kategori
 *   best_seller=1     hanya produk best seller
 *   sort=terbaru|nama|harga_asc|harga_desc   (default: nama)
 *   limit=10
 * Nama kategori diambil dengan JOIN ke tabel kategori.
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['GET']);

try {
    $db = getConnection();
    $sql = 'SELECT p.*, k.nama AS nama_kategori
            FROM produk p
            JOIN kategori k ON p.kategori_id = k.id
            WHERE 1 = 1';
    $params = [];

    $search = isset($_GET['search']) ? trim((string) $_GET['search']) : '';
    if ($search !== '') {
        $sql .= ' AND (p.nama LIKE :s1 OR p.penulis_merek LIKE :s2)';
        $params[':s1'] = '%' . $search . '%';
        $params[':s2'] = '%' . $search . '%';
    }

    $kategoriId = intOrNull($_GET['kategori_id'] ?? null);
    if ($kategoriId !== null && $kategoriId > 0) {
        $sql .= ' AND p.kategori_id = :kategori_id';
        $params[':kategori_id'] = $kategoriId;
    }

    if (($_GET['best_seller'] ?? '') === '1') {
        $sql .= ' AND p.is_best_seller = 1';
    }

    $sortMap = [
        'terbaru'    => 'p.created_at DESC, p.id DESC',
        'nama'       => 'p.nama ASC',
        'harga_asc'  => 'p.harga ASC',
        'harga_desc' => 'p.harga DESC',
    ];
    $sort = $_GET['sort'] ?? 'nama';
    $sql .= ' ORDER BY ' . ($sortMap[$sort] ?? $sortMap['nama']);

    $limit = intOrNull($_GET['limit'] ?? null);
    if ($limit !== null && $limit > 0) {
        $sql .= ' LIMIT ' . min($limit, 100);
    }

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('formatProduk', $stmt->fetchAll());

    sendResponse(true, count($rows) > 0 ? 'Berhasil memuat ' . count($rows) . ' produk.' : 'Produk tidak ditemukan.', $rows);
} catch (PDOException $e) {
    error_log('[produk/read] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat produk dari database.', null, 500);
}
