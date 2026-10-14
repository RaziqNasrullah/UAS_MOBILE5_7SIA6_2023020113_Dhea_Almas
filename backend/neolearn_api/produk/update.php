<?php
/**
 * POST|PUT produk/update.php
 * Body JSON: { id, ...field sama seperti create }
 * Jika "gambar" tidak dikirim / kosong, gambar lama dipertahankan.
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_validasi.php';
requireMethod(['POST', 'PUT']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? null, 'id produk');

    $lama = ambilProduk($db, $id);
    if ($lama === null) {
        sendResponse(false, 'Produk tidak ditemukan.', null, 404);
    }

    $params = validasiProduk($db, $body);
    if ($params[':gambar'] === null) {
        $params[':gambar'] = $lama['gambar'];
    }
    $params[':id'] = $id;

    $stmt = $db->prepare('UPDATE produk SET
        kategori_id = :kategori_id, nama = :nama, harga = :harga, stok = :stok, deskripsi = :deskripsi,
        gambar = :gambar, penulis_merek = :penulis_merek, jenjang = :jenjang, format_produk = :format_produk,
        detail_tambahan = :detail_tambahan, is_best_seller = :is_best_seller
        WHERE id = :id');
    $stmt->execute($params);

    // Jumlah di keranjang tidak boleh melebihi stok baru.
    $db->prepare('UPDATE keranjang SET jumlah = :stok WHERE produk_id = :id AND jumlah > :stok2')
       ->execute([':stok' => max($params[':stok'], 1), ':id' => $id, ':stok2' => max($params[':stok'], 1)]);

    sendResponse(true, 'Produk berhasil diperbarui.', ambilProduk($db, $id));
} catch (PDOException $e) {
    error_log('[produk/update] ' . $e->getMessage());
    sendResponse(false, 'Gagal memperbarui produk.', null, 500);
}
