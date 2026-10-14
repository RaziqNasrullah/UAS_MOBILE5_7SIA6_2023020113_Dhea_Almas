<?php
/**
 * GET keranjang/read.php
 * data: { items: [...], total_item: n, total_qty: n, total: Rp }
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['GET']);

try {
    $rows = getConnection()->query(SQL_KERANJANG . ' ORDER BY kr.created_at ASC, kr.id ASC')->fetchAll();
    $items = array_map('formatKeranjang', $rows);
    $totalQty = array_sum(array_column($items, 'jumlah'));
    $total = array_sum(array_column($items, 'subtotal'));
    sendResponse(true, count($items) > 0 ? 'Keranjang berisi ' . count($items) . ' produk.' : 'Keranjang masih kosong.', [
        'items'      => $items,
        'total_item' => count($items),
        'total_qty'  => (int) $totalQty,
        'total'      => (float) $total,
    ]);
} catch (PDOException $e) {
    error_log('[keranjang/read] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat keranjang.', null, 500);
}
