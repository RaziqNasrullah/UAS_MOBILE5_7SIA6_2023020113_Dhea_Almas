<?php
/**
 * Validasi bersama create/update produk.
 * Wajib: kategori_id, nama, harga (> 0), stok (>= 0, bilangan bulat), deskripsi,
 *        penulis_merek, jenjang, format_produk. Opsional: detail_tambahan, gambar.
 */
function validasiProduk(PDO $db, array $body): array
{
    $kategoriId = intOrNull($body['kategori_id'] ?? null);
    if ($kategoriId === null || $kategoriId <= 0) {
        sendResponse(false, 'Kategori wajib dipilih.', null, 422);
    }
    $cek = $db->prepare('SELECT id FROM kategori WHERE id = :id');
    $cek->execute([':id' => $kategoriId]);
    if (!$cek->fetch()) {
        sendResponse(false, 'Kategori yang dipilih tidak ditemukan.', null, 422);
    }

    $nama = strOrNull($body, 'nama');
    if ($nama === null) {
        sendResponse(false, 'Nama produk tidak boleh kosong.', null, 422);
    }
    if (mb_strlen($nama) > 150) {
        sendResponse(false, 'Nama produk maksimal 150 karakter.', null, 422);
    }

    $hargaRaw = $body['harga'] ?? null;
    if ($hargaRaw === null || $hargaRaw === '' || !is_numeric($hargaRaw) || (float) $hargaRaw <= 0) {
        sendResponse(false, 'Harga harus berupa angka lebih dari 0.', null, 422);
    }

    $stok = intOrNull($body['stok'] ?? null);
    if ($stok === null || $stok < 0) {
        sendResponse(false, 'Stok/kuota harus berupa bilangan bulat 0 atau lebih.', null, 422);
    }

    $deskripsi = strOrNull($body, 'deskripsi');
    if ($deskripsi === null) {
        sendResponse(false, 'Deskripsi produk tidak boleh kosong.', null, 422);
    }

    $penulis = strOrNull($body, 'penulis_merek');
    if ($penulis === null) {
        sendResponse(false, 'Penulis/merek/pengajar tidak boleh kosong.', null, 422);
    }

    $jenjang = strOrNull($body, 'jenjang');
    if (!in_array($jenjang, JENJANG_LIST, true)) {
        sendResponse(false, 'Jenjang tidak valid. Pilihan: ' . implode(', ', JENJANG_LIST) . '.', null, 422);
    }

    $format = strOrNull($body, 'format_produk');
    if (!in_array($format, FORMAT_LIST, true)) {
        sendResponse(false, 'Format produk tidak valid. Pilihan: ' . implode(', ', FORMAT_LIST) . '.', null, 422);
    }

    $gambar = strOrNull($body, 'gambar');
    if ($gambar !== null && basename($gambar) !== $gambar) {
        sendResponse(false, 'Nama file gambar tidak valid.', null, 422);
    }

    $best = $body['is_best_seller'] ?? false;
    $best = ($best === true || $best === 1 || $best === '1' || $best === 'true') ? 1 : 0;

    return [
        ':kategori_id'     => $kategoriId,
        ':nama'            => $nama,
        ':harga'           => round((float) $hargaRaw, 2),
        ':stok'            => $stok,
        ':deskripsi'       => $deskripsi,
        ':gambar'          => $gambar,
        ':penulis_merek'   => $penulis,
        ':jenjang'         => $jenjang,
        ':format_produk'   => $format,
        ':detail_tambahan' => strOrNull($body, 'detail_tambahan'),
        ':is_best_seller'  => $best,
    ];
}

function ambilProduk(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT p.*, k.nama AS nama_kategori
                          FROM produk p JOIN kategori k ON p.kategori_id = k.id WHERE p.id = :id');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    return $row ? formatProduk($row) : null;
}
