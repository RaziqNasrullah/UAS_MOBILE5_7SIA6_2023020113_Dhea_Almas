<?php
/**
 * GET pesanan/read.php[?status=Diproses|Selesai|Dibatalkan]
 * Urut terbaru (ORDER BY tanggal DESC).
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['GET']);

try {
    $sql = 'SELECT p.*, COUNT(d.id) AS jumlah_item, COALESCE(SUM(d.jumlah), 0) AS total_qty
            FROM pesanan p
            LEFT JOIN detail_pesanan d ON d.pesanan_id = p.id';
    $params = [];
    $status = isset($_GET['status']) ? trim((string) $_GET['status']) : '';
    if ($status !== '' && $status !== 'Semua') {
        if (!in_array($status, STATUS_LIST, true)) {
            sendResponse(false, 'Status tidak valid. Pilihan: ' . implode(', ', STATUS_LIST) . '.', null, 422);
        }
        $sql .= ' WHERE p.status = :status';
        $params[':status'] = $status;
    }
    $sql .= ' GROUP BY p.id ORDER BY p.tanggal DESC, p.id DESC';

    $stmt = getConnection()->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('formatPesanan', $stmt->fetchAll());
    sendResponse(true, count($rows) > 0 ? 'Berhasil memuat ' . count($rows) . ' pesanan.' : 'Belum ada pesanan.', $rows);
} catch (PDOException $e) {
    error_log('[pesanan/read] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat riwayat pesanan.', null, 500);
}
