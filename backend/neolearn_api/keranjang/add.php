<?php
/**
 * POST keranjang/add.php
 * Body JSON: { "produk_id": 1, "jumlah": 2, "catatan_item": "minta sampul plastik" }
 * Jika produk sudah ada di keranjang, jumlah ditambahkan (UNIQUE produk_id).
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['POST']);

$db = null;
try {
    $db = getConnection();
    $body = getRequestBody();
    $produkId = requireId($body['produk_id'] ?? null, 'id produk');
    $jumlah = intOrNull($body['jumlah'] ?? 1);
    if ($jumlah === null || $jumlah < 1) {
        sendResponse(false, 'Jumlah minimal 1.', null, 422);
    }
    $catatan = strOrNull($body, 'catatan_item');
    if ($catatan !== null && mb_strlen($catatan) > 255) {
        sendResponse(false, 'Catatan item maksimal 255 karakter.', null, 422);
    }

    $db->beginTransaction();
    $stmt = $db->prepare('SELECT p.nama, p.stok, k.nama AS nama_kategori
                          FROM produk p JOIN kategori k ON p.kategori_id = k.id
                          WHERE p.id = :id FOR UPDATE');
    $stmt->execute([':id' => $produkId]);
    $produk = $stmt->fetch();
    if (!$produk) {
        $db->rollBack();
        sendResponse(false, 'Produk tidak ditemukan.', null, 404);
    }
    $label = labelStok($produk['nama_kategori']);
    if ((int) $produk['stok'] <= 0) {
        $db->rollBack();
        $pesan = $label === 'kuota peserta' ? 'Kuota kelas sudah penuh.' : 'Stok produk habis.';
        sendResponse(false, $pesan, null, 409);
    }

    $stmt = $db->prepare('SELECT id, jumlah FROM keranjang WHERE produk_id = :id FOR UPDATE');
    $stmt->execute([':id' => $produkId]);
    $ada = $stmt->fetch();
    $jumlahBaru = $jumlah + ($ada ? (int) $ada['jumlah'] : 0);

    if ($jumlahBaru > (int) $produk['stok']) {
        $db->rollBack();
        $sisa = (int) $produk['stok'] - ($ada ? (int) $ada['jumlah'] : 0);
        $pesan = 'Jumlah melebihi ' . $label . ' (tersedia ' . $produk['stok'] . ').';
        if ($ada) {
            $pesan .= ' Di keranjang sudah ada ' . $ada['jumlah'] . ', maksimal bisa ditambah ' . max($sisa, 0) . '.';
        }
        sendResponse(false, $pesan, null, 409);
    }

    if ($ada) {
        $sql = 'UPDATE keranjang SET jumlah = :jumlah' . ($catatan !== null ? ', catatan_item = :catatan' : '') . ' WHERE id = :id';
        $params = [':jumlah' => $jumlahBaru, ':id' => $ada['id']];
        if ($catatan !== null) {
            $params[':catatan'] = $catatan;
        }
        $db->prepare($sql)->execute($params);
        $id = (int) $ada['id'];
    } else {
        $db->prepare('INSERT INTO keranjang (produk_id, jumlah, catatan_item) VALUES (:produk_id, :jumlah, :catatan)')
           ->execute([':produk_id' => $produkId, ':jumlah' => $jumlahBaru, ':catatan' => $catatan]);
        $id = (int) $db->lastInsertId();
    }
    $db->commit();

    sendResponse(true, '"' . $produk['nama'] . '" ditambahkan ke keranjang.', ambilItemKeranjang($db, $id), $ada ? 200 : 201);
} catch (PDOException $e) {
    if ($db instanceof PDO && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log('[keranjang/add] ' . $e->getMessage());
    sendResponse(false, 'Gagal menambahkan ke keranjang.', null, 500);
}
