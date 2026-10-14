<?php
/**
 * POST produk/upload_gambar.php   (multipart/form-data)
 * Field file: "gambar"  (jpg/jpeg/png/webp, maks 2 MB)
 * Field opsional: "produk_id" -> langsung mengganti gambar produk tersebut.
 * Respons data: { "gambar": "upload_xxx.jpg" }
 */
require_once __DIR__ . '/../helpers/response.php';
requireMethod(['POST']);

try {
    if (!isset($_FILES['gambar'])) {
        sendResponse(false, 'File gambar wajib dikirim pada field "gambar".', null, 422);
    }
    $file = $_FILES['gambar'];
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $pesan = in_array($file['error'], [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true)
            ? 'Ukuran gambar terlalu besar (maks 2 MB).'
            : 'Upload gambar gagal (kode ' . $file['error'] . ').';
        sendResponse(false, $pesan, null, 422);
    }
    if ($file['size'] > UPLOAD_MAX_BYTES) {
        sendResponse(false, 'Ukuran gambar maksimal 2 MB.', null, 422);
    }

    $info = @getimagesize($file['tmp_name']);
    $mimeExt = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    if ($info === false || !isset($mimeExt[$info['mime']])) {
        sendResponse(false, 'File harus berupa gambar JPG, PNG, atau WEBP.', null, 422);
    }

    if (!is_dir(UPLOAD_DIR)) {
        mkdir(UPLOAD_DIR, 0775, true);
    }
    $namaFile = 'upload_' . date('YmdHis') . '_' . bin2hex(random_bytes(4)) . '.' . $mimeExt[$info['mime']];
    if (!move_uploaded_file($file['tmp_name'], UPLOAD_DIR . $namaFile)) {
        sendResponse(false, 'Gagal menyimpan file gambar di server (cek izin folder uploads).', null, 500);
    }

    $produkId = intOrNull($_POST['produk_id'] ?? null);
    if ($produkId !== null && $produkId > 0) {
        $stmt = getConnection()->prepare('UPDATE produk SET gambar = :g WHERE id = :id');
        $stmt->execute([':g' => $namaFile, ':id' => $produkId]);
    }

    sendResponse(true, 'Gambar berhasil diunggah.', ['gambar' => $namaFile], 201);
} catch (PDOException $e) {
    error_log('[produk/upload_gambar] ' . $e->getMessage());
    sendResponse(false, 'Gambar tersimpan tetapi gagal memperbarui data produk.', null, 500);
}
