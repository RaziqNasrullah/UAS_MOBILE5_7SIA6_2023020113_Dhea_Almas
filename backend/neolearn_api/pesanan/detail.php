<?php
/**
 * GET pesanan/detail.php?id=1
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['GET']);

try {
    $id = requireId($_GET['id'] ?? null, 'id pesanan');
    $pesanan = ambilPesananLengkap(getConnection(), $id);
    if ($pesanan === null) {
        sendResponse(false, 'Pesanan tidak ditemukan.', null, 404);
    }
    sendResponse(true, 'Detail pesanan ' . $pesanan['nomor_pesanan'] . '.', $pesanan);
} catch (PDOException $e) {
    error_log('[pesanan/detail] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat detail pesanan.', null, 500);
}
