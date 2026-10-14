<?php
/**
 * POST pesanan/checkout.php
 * Body JSON: { nama_pemesan, no_hp, email, tipe_pesanan, alamat, catatan }
 *
 * Item diambil dari tabel keranjang (sumber kebenaran di server).
 * Seluruh proses berjalan dalam SATU transaksi:
 *   lock keranjang+produk (FOR UPDATE) -> validasi stok -> hitung biaya ->
 *   insert pesanan & detail -> kurangi stok -> kosongkan keranjang -> commit.
 * Jika ada yang gagal -> rollBack.
 */
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_helper.php';
requireMethod(['POST']);

$db = null;
try {
    $db = getConnection();
    $body = getRequestBody();

    // ---------- Validasi form ----------
    $nama = strOrNull($body, 'nama_pemesan');
    if ($nama === null) {
        sendResponse(false, 'Nama pemesan wajib diisi.', null, 422);
    }
    if (mb_strlen($nama) > 100) {
        sendResponse(false, 'Nama pemesan maksimal 100 karakter.', null, 422);
    }
    $noHp = preg_replace('/[\s-]/', '', (string) ($body['no_hp'] ?? ''));
    if (!preg_match('/^08[0-9]{8,11}$/', $noHp)) {
        sendResponse(false, 'Nomor HP harus berupa angka 10-13 digit dan diawali 08.', null, 422);
    }
    $tipe = strOrNull($body, 'tipe_pesanan');
    if (!in_array($tipe, TIPE_PESANAN_LIST, true)) {
        sendResponse(false, 'Tipe pesanan tidak valid. Pilihan: ' . implode(', ', TIPE_PESANAN_LIST) . '.', null, 422);
    }
    $alamat = strOrNull($body, 'alamat');
    if ($tipe === 'Diantar' && ($alamat === null || mb_strlen($alamat) < 10)) {
        sendResponse(false, 'Alamat pengiriman wajib diisi (minimal 10 karakter) untuk pesanan Diantar.', null, 422);
    }
    if ($tipe !== 'Diantar') {
        $alamat = null;
    }
    $email = strOrNull($body, 'email');
    if ($email !== null && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        sendResponse(false, 'Format email tidak valid.', null, 422);
    }
    $catatan = strOrNull($body, 'catatan');
    if ($catatan !== null && mb_strlen($catatan) > 255) {
        sendResponse(false, 'Catatan maksimal 255 karakter.', null, 422);
    }

    // ---------- Transaksi ----------
    $db->beginTransaction();

    $stmt = $db->query('SELECT kr.id AS keranjang_id, kr.jumlah, kr.catatan_item,
                               p.id AS produk_id, p.nama, p.harga, p.stok, p.format_produk,
                               k.nama AS nama_kategori
                        FROM keranjang kr
                        JOIN produk p ON kr.produk_id = p.id
                        JOIN kategori k ON p.kategori_id = k.id
                        ORDER BY kr.id
                        FOR UPDATE');
    $items = $stmt->fetchAll();
    if (count($items) === 0) {
        $db->rollBack();
        sendResponse(false, 'Keranjang kosong. Tambahkan produk terlebih dahulu.', null, 422);
    }

    $adaKelas = false;
    $semuaDigital = true;
    $subtotal = 0.0;
    foreach ($items as $it) {
        $isKelas = strcasecmp($it['nama_kategori'], KATEGORI_KELAS_KURSUS) === 0;
        $adaKelas = $adaKelas || $isKelas;
        $semuaDigital = $semuaDigital && in_array($it['format_produk'], FORMAT_DIGITAL, true);
        if ((int) $it['jumlah'] > (int) $it['stok']) {
            $db->rollBack();
            $label = $isKelas ? 'Kuota kelas' : 'Stok';
            sendResponse(false, $label . ' "' . $it['nama'] . '" tidak mencukupi (tersedia ' . $it['stok']
                . ', diminta ' . $it['jumlah'] . '). Ubah jumlah di keranjang.', [
                'produk_id' => (int) $it['produk_id'],
                'stok'      => (int) $it['stok'],
            ], 409);
        }
        $subtotal += (float) $it['harga'] * (int) $it['jumlah'];
    }

    if ($adaKelas && $email === null) {
        $db->rollBack();
        sendResponse(false, 'Email wajib diisi karena pesanan berisi Kelas Kursus (untuk mengirim info & akses kelas).', null, 422);
    }
    if ($tipe === 'Digital/Kelas Online' && !$semuaDigital) {
        $db->rollBack();
        sendResponse(false, 'Tipe "Digital/Kelas Online" hanya untuk pesanan yang seluruh itemnya E-Book atau Kelas Online.', null, 422);
    }

    $biaya = hitungBiaya($subtotal, $tipe);
    $tanggal = date('Y-m-d H:i:s');
    $nomor = buatNomorPesanan($db, $tanggal);

    $stmt = $db->prepare('INSERT INTO pesanan
        (nomor_pesanan, nama_pemesan, no_hp, email, tipe_pesanan, alamat, catatan,
         subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal)
        VALUES (:nomor, :nama, :hp, :email, :tipe, :alamat, :catatan,
                :subtotal, :layanan, :ongkir, :diskon, :total, \'Diproses\', :tanggal)');
    $stmt->execute([
        ':nomor'    => $nomor,
        ':nama'     => $nama,
        ':hp'       => $noHp,
        ':email'    => $email,
        ':tipe'     => $tipe,
        ':alamat'   => $alamat,
        ':catatan'  => $catatan,
        ':subtotal' => $biaya['subtotal'],
        ':layanan'  => $biaya['biaya_layanan'],
        ':ongkir'   => $biaya['ongkir'],
        ':diskon'   => $biaya['diskon'],
        ':total'    => $biaya['total'],
        ':tanggal'  => $tanggal,
    ]);
    $pesananId = (int) $db->lastInsertId();

    $insDetail = $db->prepare('INSERT INTO detail_pesanan
        (pesanan_id, produk_id, nama_produk, harga_satuan, jumlah, catatan_item, subtotal)
        VALUES (:pid, :produk_id, :nama, :harga, :jumlah, :catatan, :subtotal)');
    $kurangiStok = $db->prepare('UPDATE produk SET stok = stok - :j WHERE id = :id AND stok >= :j2');

    foreach ($items as $it) {
        $insDetail->execute([
            ':pid'       => $pesananId,
            ':produk_id' => $it['produk_id'],
            ':nama'      => $it['nama'],
            ':harga'     => $it['harga'],
            ':jumlah'    => $it['jumlah'],
            ':catatan'   => $it['catatan_item'],
            ':subtotal'  => (float) $it['harga'] * (int) $it['jumlah'],
        ]);
        $kurangiStok->execute([':j' => $it['jumlah'], ':id' => $it['produk_id'], ':j2' => $it['jumlah']]);
        if ($kurangiStok->rowCount() !== 1) {
            throw new RuntimeException('Stok berubah saat checkout: ' . $it['nama']);
        }
    }

    $db->exec('DELETE FROM keranjang');
    $db->commit();

    sendResponse(true, 'Pesanan ' . $nomor . ' berhasil dibuat.', ambilPesananLengkap($db, $pesananId), 201);
} catch (Throwable $e) {
    if ($db instanceof PDO && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log('[pesanan/checkout] ' . $e->getMessage());
    if ($e instanceof RuntimeException) {
        sendResponse(false, 'Stok berubah ketika pesanan diproses. Silakan muat ulang keranjang dan coba lagi.', null, 409);
    }
    sendResponse(false, 'Checkout gagal, seluruh perubahan dibatalkan. Silakan coba lagi.', null, 500);
}
