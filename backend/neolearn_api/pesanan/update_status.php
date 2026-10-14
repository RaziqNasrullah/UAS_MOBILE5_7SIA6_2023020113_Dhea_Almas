<?php
/**
 * POST|PUT pesanan/update_status.php
 * Body JSON: { "id": 1, "status": "Selesai" | "Dibatalkan" }
 *
 * Hanya pesanan berstatus "Diproses" yang dapat diubah.
 * Jika dibatalkan, stok/kuota dikembalikan dalam transaksi yang sama.
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['POST', 'PUT']);

$db = null;
try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? null, 'id pesanan');
    $status = strOrNull($body, 'status');
    if (!in_array($status, ['Selesai', 'Dibatalkan'], true)) {
        sendResponse(false, 'Status baru harus "Selesai" atau "Dibatalkan".', null, 422);
    }

    $db->beginTransaction();
    $stmt = $db->prepare('SELECT id, nomor_pesanan, status FROM pesanan WHERE id = :id FOR UPDATE');
    $stmt->execute([':id' => $id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        $db->rollBack();
        sendResponse(false, 'Pesanan tidak ditemukan.', null, 404);
    }
    if ($pesanan['status'] !== 'Diproses') {
        $db->rollBack();
        sendResponse(false, 'Pesanan ' . $pesanan['nomor_pesanan'] . ' sudah berstatus "' . $pesanan['status']
            . '" dan tidak dapat diubah lagi.', null, 409);
    }

    $db->prepare('UPDATE pesanan SET status = :s WHERE id = :id')->execute([':s' => $status, ':id' => $id]);

    $dikembalikan = 0;
    if ($status === 'Dibatalkan') {
        $stmt = $db->prepare('UPDATE produk p
                              JOIN detail_pesanan d ON d.produk_id = p.id
                              SET p.stok = p.stok + d.jumlah
                              WHERE d.pesanan_id = :id');
        $stmt->execute([':id' => $id]);
        $dikembalikan = $stmt->rowCount();
    }
    $db->commit();

    $pesan = $status === 'Dibatalkan'
        ? 'Pesanan ' . $pesanan['nomor_pesanan'] . ' dibatalkan. Stok/kuota ' . $dikembalikan . ' produk dikembalikan.'
        : 'Pesanan ' . $pesanan['nomor_pesanan'] . ' ditandai Selesai.';
    sendResponse(true, $pesan, ambilPesananLengkap($db, $id));
} catch (PDOException $e) {
    if ($db instanceof PDO && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log('[pesanan/update_status] ' . $e->getMessage());
    sendResponse(false, 'Gagal mengubah status pesanan.', null, 500);
}
