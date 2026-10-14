<?php
/**
 * POST|DELETE keranjang/clear.php  -> kosongkan keranjang
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['POST', 'DELETE']);

try {
    $jumlah = getConnection()->exec('DELETE FROM keranjang');
    sendResponse(true, 'Keranjang dikosongkan.', ['dihapus' => (int) $jumlah]);
} catch (PDOException $e) {
    error_log('[keranjang/clear] ' . $e->getMessage());
    sendResponse(false, 'Gagal mengosongkan keranjang.', null, 500);
}
