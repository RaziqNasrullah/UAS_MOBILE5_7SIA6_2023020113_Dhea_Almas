<?php
/**
 * GET dashboard/summary.php
 *
 * - total_pesanan       : semua pesanan (beserta rincian per status)
 * - total_pendapatan    : SUM(total) HANYA pesanan berstatus "Selesai"
 * - produk_terlaris     : 5 besar SUM(jumlah) detail_pesanan, tidak termasuk pesanan "Dibatalkan"
 * - pendapatan_harian   : pendapatan (Selesai) 7 hari terakhir, hari kosong = 0
 * - penjualan_kategori  : nilai penjualan per kategori (tidak termasuk "Dibatalkan")
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['GET']);

try {
    $db = getConnection();

    $ringkas = $db->query("SELECT
            COUNT(*) AS total_pesanan,
            COALESCE(SUM(CASE WHEN status = 'Selesai' THEN total ELSE 0 END), 0) AS total_pendapatan,
            SUM(status = 'Diproses')   AS pesanan_diproses,
            SUM(status = 'Selesai')    AS pesanan_selesai,
            SUM(status = 'Dibatalkan') AS pesanan_dibatalkan
        FROM pesanan")->fetch();

    $terlaris = $db->query("SELECT d.produk_id, d.nama_produk,
                                   SUM(d.jumlah) AS total_terjual,
                                   SUM(d.subtotal) AS total_penjualan
                            FROM detail_pesanan d
                            JOIN pesanan ps ON d.pesanan_id = ps.id
                            WHERE ps.status <> 'Dibatalkan'
                            GROUP BY d.produk_id, d.nama_produk
                            ORDER BY total_terjual DESC, total_penjualan DESC
                            LIMIT 5")->fetchAll();
    $terlaris = array_map(
        fn($r) => castNumbers($r, ['produk_id', 'total_terjual'], ['total_penjualan']),
        $terlaris
    );

    // 7 hari terakhir termasuk hari ini.
    $stmt = $db->query("SELECT DATE(tanggal) AS tgl, SUM(total) AS pendapatan, COUNT(*) AS jumlah
                        FROM pesanan
                        WHERE status = 'Selesai' AND tanggal >= CURDATE() - INTERVAL 6 DAY
                        GROUP BY DATE(tanggal)");
    $perTanggal = [];
    foreach ($stmt->fetchAll() as $r) {
        $perTanggal[$r['tgl']] = $r;
    }
    $harian = [];
    for ($i = 6; $i >= 0; $i--) {
        $tgl = date('Y-m-d', strtotime("-$i day"));
        $harian[] = [
            'tanggal'       => $tgl,
            'pendapatan'    => isset($perTanggal[$tgl]) ? (float) $perTanggal[$tgl]['pendapatan'] : 0.0,
            'jumlah_pesanan' => isset($perTanggal[$tgl]) ? (int) $perTanggal[$tgl]['jumlah'] : 0,
        ];
    }

    $kategori = $db->query("SELECT COALESCE(k.nama, 'Produk Dihapus') AS nama_kategori,
                                   SUM(d.jumlah) AS total_terjual,
                                   SUM(d.subtotal) AS total_penjualan
                            FROM detail_pesanan d
                            JOIN pesanan ps ON d.pesanan_id = ps.id
                            LEFT JOIN produk p ON d.produk_id = p.id
                            LEFT JOIN kategori k ON p.kategori_id = k.id
                            WHERE ps.status <> 'Dibatalkan'
                            GROUP BY COALESCE(k.nama, 'Produk Dihapus')
                            ORDER BY total_penjualan DESC")->fetchAll();
    $kategori = array_map(fn($r) => castNumbers($r, ['total_terjual'], ['total_penjualan']), $kategori);

    $produkStats = $db->query('SELECT COUNT(*) AS total_produk, SUM(stok = 0) AS produk_habis FROM produk')->fetch();

    sendResponse(true, 'Ringkasan penjualan.', [
        'total_pesanan'      => (int) $ringkas['total_pesanan'],
        'total_pendapatan'   => (float) $ringkas['total_pendapatan'],
        'pesanan_diproses'   => (int) $ringkas['pesanan_diproses'],
        'pesanan_selesai'    => (int) $ringkas['pesanan_selesai'],
        'pesanan_dibatalkan' => (int) $ringkas['pesanan_dibatalkan'],
        'total_produk'       => (int) $produkStats['total_produk'],
        'produk_habis'       => (int) $produkStats['produk_habis'],
        'produk_terlaris'    => $terlaris,
        'pendapatan_harian'  => $harian,
        'penjualan_kategori' => $kategori,
    ]);
} catch (PDOException $e) {
    error_log('[dashboard/summary] ' . $e->getMessage());
    sendResponse(false, 'Gagal memuat ringkasan dashboard.', null, 500);
}
