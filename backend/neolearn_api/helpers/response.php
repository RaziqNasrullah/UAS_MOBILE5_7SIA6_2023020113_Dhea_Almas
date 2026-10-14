<?php
/**
 * Helper respons JSON seragam:
 *   { "success": true|false, "message": "...", "data": ... }
 *
 * Setiap endpoint cukup: require_once __DIR__ . '/../helpers/response.php';
 */

require_once __DIR__ . '/../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Warning/notice PHP tidak boleh merusak format JSON.
ini_set('display_errors', '0');
error_reporting(E_ALL);
set_error_handler(function (int $severity, string $message, string $file, int $line): bool {
    // Hormati operator @ (mis. @getimagesize) yang sengaja meredam warning.
    if (!(error_reporting() & $severity)) {
        return false;
    }
    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Pengaman terakhir: exception yang tidak tertangkap tetap dikembalikan sebagai JSON.
set_exception_handler(function (Throwable $e): void {
    if ($e instanceof PDOException) {
        $msg = 'Gagal terhubung/mengakses database. Pastikan MySQL XAMPP aktif dan database db_neolearn sudah di-import.';
    } else {
        $msg = 'Terjadi kesalahan pada server.';
    }
    error_log('[neolearn_api] ' . $e->getMessage());
    sendResponse(false, $msg, null, 500);
});

/**
 * Mengirim respons JSON lalu menghentikan script.
 */
function sendResponse(bool $success, string $message, $data = null, int $status = 200): void
{
    http_response_code($status);
    echo json_encode(
        ['success' => $success, 'message' => $message, 'data' => $data],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
    exit;
}

/**
 * Menolak method HTTP yang tidak diizinkan (405).
 */
function requireMethod(array $allowed): void
{
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    if (!in_array($method, $allowed, true)) {
        header('Allow: ' . implode(', ', $allowed));
        sendResponse(false, 'Method ' . $method . ' tidak diizinkan. Gunakan ' . implode('/', $allowed) . '.', null, 405);
    }
}

/**
 * Membaca body request: JSON (application/json) atau form-data / x-www-form-urlencoded.
 */
function getRequestBody(): array
{
    $raw = file_get_contents('php://input');
    if ($raw !== false && trim($raw) !== '') {
        $json = json_decode($raw, true);
        if (is_array($json)) {
            return $json;
        }
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (stripos($contentType, 'application/json') !== false) {
            sendResponse(false, 'Body request bukan JSON yang valid.', null, 400);
        }
        parse_str($raw, $form);
        if (!empty($form)) {
            return $form;
        }
    }
    return $_POST;
}

/** Mengambil string yang sudah di-trim; null jika kosong. */
function strOrNull(array $body, string $key): ?string
{
    if (!isset($body[$key]) || is_array($body[$key])) {
        return null;
    }
    $v = trim((string) $body[$key]);
    return $v === '' ? null : $v;
}

/** Mengambil integer positif dari body / query. */
function intOrNull($value): ?int
{
    if ($value === null || $value === '' || is_array($value)) {
        return null;
    }
    if (filter_var($value, FILTER_VALIDATE_INT) === false) {
        return null;
    }
    return (int) $value;
}

/** Validasi id wajib (> 0) dari body atau query. */
function requireId($value, string $label = 'id'): int
{
    $id = intOrNull($value);
    if ($id === null || $id <= 0) {
        sendResponse(false, ucfirst($label) . ' wajib diisi dan harus berupa angka.', null, 422);
    }
    return $id;
}

/** Konversi kolom angka hasil query agar JSON berisi number, bukan string. */
function castNumbers(array $row, array $ints = [], array $floats = []): array
{
    foreach ($ints as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $row[$k] = (int) $row[$k];
        }
    }
    foreach ($floats as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $row[$k] = (float) $row[$k];
        }
    }
    return $row;
}

/** Bentuk JSON produk (dengan nama kategori dari JOIN). */
function formatProduk(array $row): array
{
    $row = castNumbers($row, ['id', 'kategori_id', 'stok', 'is_best_seller'], ['harga']);
    $row['is_best_seller'] = (bool) $row['is_best_seller'];
    return $row;
}

/** Hitung rincian biaya checkout (dipakai ulang di server, sumber kebenaran). */
function hitungBiaya(float $subtotal, string $tipePesanan): array
{
    $biayaLayanan = (float) BIAYA_LAYANAN;
    $ongkir = $tipePesanan === 'Diantar' ? (float) ONGKIR_DIANTAR : 0.0;
    $diskon = $subtotal >= MIN_SUBTOTAL_DISKON ? round($subtotal * DISKON_PERSEN / 100, 2) : 0.0;
    $total = $subtotal + $biayaLayanan + $ongkir - $diskon;
    return [
        'subtotal'      => $subtotal,
        'biaya_layanan' => $biayaLayanan,
        'ongkir'        => $ongkir,
        'diskon'        => $diskon,
        'total'         => $total,
    ];
}
