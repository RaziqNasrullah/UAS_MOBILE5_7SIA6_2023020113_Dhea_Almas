<?php
/**
 * Fungsi bersama modul pesanan.
 */
function formatPesanan(array $row): array
{
    return castNumbers(
        $row,
        ['id', 'jumlah_item', 'total_qty'],
        ['subtotal', 'biaya_layanan', 'ongkir', 'diskon', 'total']
    );
}

function formatDetail(array $row): array
{
    return castNumbers($row, ['id', 'pesanan_id', 'produk_id', 'jumlah'], ['harga_satuan', 'subtotal']);
}

/** Ambil pesanan lengkap dengan item-itemnya; null jika tidak ada. */
function ambilPesananLengkap(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM pesanan WHERE id = :id');
    $stmt->execute([':id' => $id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        return null;
    }
    $stmt = $db->prepare('SELECT d.*, k.nama AS nama_kategori
                          FROM detail_pesanan d
                          LEFT JOIN produk p ON d.produk_id = p.id
                          LEFT JOIN kategori k ON p.kategori_id = k.id
                          WHERE d.pesanan_id = :id ORDER BY d.id ASC');
    $stmt->execute([':id' => $id]);
    $items = array_map('formatDetail', $stmt->fetchAll());

    $pesanan = formatPesanan($pesanan);
    $pesanan['items'] = $items;
    $pesanan['jumlah_item'] = count($items);
    $pesanan['total_qty'] = (int) array_sum(array_column($items, 'jumlah'));
    return $pesanan;
}

/**
 * Nomor pesanan INV-YYYYMMDD-NNN, NNN reset setiap hari.
 * Dipanggil di dalam transaksi; baris terakhir hari ini dikunci (FOR UPDATE).
 */
function buatNomorPesanan(PDO $db, string $tanggal): string
{
    $prefix = 'INV-' . date('Ymd', strtotime($tanggal)) . '-';
    $stmt = $db->prepare('SELECT nomor_pesanan FROM pesanan WHERE nomor_pesanan LIKE :p
                          ORDER BY nomor_pesanan DESC LIMIT 1 FOR UPDATE');
    $stmt->execute([':p' => $prefix . '%']);
    $last = $stmt->fetchColumn();
    $urut = $last ? ((int) substr($last, -3)) + 1 : 1;
    return $prefix . str_pad((string) $urut, 3, '0', STR_PAD_LEFT);
}
