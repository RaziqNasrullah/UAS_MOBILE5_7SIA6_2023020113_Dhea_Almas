<?php
/**
 * POST kategori/create.php
 * Body JSON: { "nama": "...", "deskripsi": "...", "ikon": "..." }
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_validasi.php';
requireMethod(['POST']);

try {
    $db = getConnection();
    $data = validasiKategori($db, getRequestBody());

    $stmt = $db->prepare('INSERT INTO kategori (nama, deskripsi, ikon) VALUES (:nama, :deskripsi, :ikon)');
    $stmt->execute([':nama' => $data['nama'], ':deskripsi' => $data['deskripsi'], ':ikon' => $data['ikon']]);

    $data['id'] = (int) $db->lastInsertId();
    $data['jumlah_produk'] = 0;
    sendResponse(true, 'Kategori "' . $data['nama'] . '" berhasil ditambahkan.', $data, 201);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        sendResponse(false, 'Nama kategori sudah digunakan.', null, 409);
    }
    error_log('[kategori/create] ' . $e->getMessage());
    sendResponse(false, 'Gagal menyimpan kategori.', null, 500);
}
