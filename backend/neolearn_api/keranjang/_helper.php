<?php
/**
 * Query bersama keranjang: item + data produk + nama kategori.
 */
const SQL_KERANJANG = 'SELECT kr.id, kr.produk_id, kr.jumlah, kr.catatan_item, kr.created_at,
        p.nama, p.harga, p.stok, p.gambar, p.penulis_merek, p.jenjang, p.format_produk,
        p.detail_tambahan, p.kategori_id, k.nama AS nama_kategori,
        (p.harga * kr.jumlah) AS subtotal
    FROM keranjang kr
    JOIN produk p ON kr.produk_id = p.id
    JOIN kategori k ON p.kategori_id = k.id';

function formatKeranjang(array $row): array
{
    return castNumbers($row, ['id', 'produk_id', 'jumlah', 'stok', 'kategori_id'], ['harga', 'subtotal']);
}

function ambilItemKeranjang(PDO $db, int $id): ?array
{
    $stmt = $db->prepare(SQL_KERANJANG . ' WHERE kr.id = :id');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    return $row ? formatKeranjang($row) : null;
}

function labelStok(string $namaKategori): string
{
    return strcasecmp($namaKategori, KATEGORI_KELAS_KURSUS) === 0 ? 'kuota peserta' : 'stok';
}
