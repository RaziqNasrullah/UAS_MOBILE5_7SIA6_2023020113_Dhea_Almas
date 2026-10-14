<?php
/**
 * Validasi bersama untuk create/update kategori.
 * Nama wajib diisi & tidak boleh duplikat (case-insensitive, mengabaikan spasi tepi).
 */
function validasiKategori(PDO $db, array $body, ?int $exceptId = null): array
{
    $nama = strOrNull($body, 'nama');
    if ($nama === null) {
        sendResponse(false, 'Nama kategori tidak boleh kosong.', null, 422);
    }
    if (mb_strlen($nama) > 100) {
        sendResponse(false, 'Nama kategori maksimal 100 karakter.', null, 422);
    }
    $deskripsi = strOrNull($body, 'deskripsi');
    if ($deskripsi !== null && mb_strlen($deskripsi) > 255) {
        sendResponse(false, 'Deskripsi maksimal 255 karakter.', null, 422);
    }

    $sql = 'SELECT id FROM kategori WHERE LOWER(TRIM(nama)) = LOWER(:nama)';
    $params = [':nama' => $nama];
    if ($exceptId !== null) {
        $sql .= ' AND id <> :id';
        $params[':id'] = $exceptId;
    }
    $stmt = $db->prepare($sql . ' LIMIT 1');
    $stmt->execute($params);
    if ($stmt->fetch()) {
        sendResponse(false, 'Kategori "' . $nama . '" sudah ada. Gunakan nama lain.', null, 409);
    }

    return [
        'nama'      => $nama,
        'deskripsi' => $deskripsi,
        'ikon'      => strOrNull($body, 'ikon'),
    ];
}
