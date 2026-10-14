<?php
/**
 * POST|PUT kategori/update.php
 * Body JSON: { "id": 1, "nama": "...", "deskripsi": "...", "ikon": "..." }
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_validasi.php';
requireMethod(['POST', 'PUT']);

try {
    $db = getConnection();
    $body = getRequestBody();
    $id = requireId($body['id'] ?? null, 'id kategori');

    $cek = $db->prepare('SELECT id FROM kategori WHERE id = :id');
    $cek->execute([':id' => $id]);
    if (!$cek->fetch()) {
        sendResponse(false, 'Kategori tidak ditemukan.', null, 404);
    }

    $data = validasiKategori($db, $body, $id);
    $stmt = $db->prepare('UPDATE kategori SET nama = :nama, deskripsi = :deskripsi, ikon = :ikon WHERE id = :id');
    $stmt->execute([':nama' => $data['nama'], ':deskripsi' => $data['deskripsi'], ':ikon' => $data['ikon'], ':id' => $id]);

    $data['id'] = $id;
    sendResponse(true, 'Kategori berhasil diperbarui.', $data);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        sendResponse(false, 'Nama kategori sudah digunakan.', null, 409);
    }
    error_log('[kategori/update] ' . $e->getMessage());
    sendResponse(false, 'Gagal memperbarui kategori.', null, 500);
}
