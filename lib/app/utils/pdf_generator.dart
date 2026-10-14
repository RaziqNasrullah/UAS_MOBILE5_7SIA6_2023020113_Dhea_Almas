import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/services/api_config.dart';
import '../models/pesanan.dart';
import 'formatter.dart';

/// Pembuat struk PDF pesanan NeoLearn (kertas struk 80 mm).
///
/// Font bawaan PDF (Helvetica) hanya mendukung Latin-1, jadi semua teks
/// dilewatkan ke [latin1Safe] terlebih dahulu.
class StrukPdfGenerator {
  StrukPdfGenerator._();

  static const PdfColor _primary = PdfColor.fromInt(0xFF1B5E6E);
  static const PdfColor _grey = PdfColor.fromInt(0xFF5E6E7C);

  /// Ganti karakter non Latin-1 (em dash, kutip miring, emoji, dll).
  static String latin1Safe(String input) {
    const map = {
      '—': '-',
      '–': '-',
      '‒': '-',
      '−': '-',
      '‘': "'",
      '’': "'",
      '‚': "'",
      '′': "'",
      '“': '"',
      '”': '"',
      '„': '"',
      '″': '"',
      '…': '...',
      '•': '-',
      ' ': ' ',
      ' ': ' ',
      ' ': ' ',
    };
    final buf = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      if (map.containsKey(ch)) {
        buf.write(map[ch]);
      } else if (rune <= 0xFF) {
        buf.write(ch);
      }
      // karakter lain (emoji, aksara non-latin) dibuang
    }
    return buf.toString();
  }

  static String _rp(num v) => latin1Safe(Formatter.rupiah(v));

  static String namaFile(Pesanan p) => 'Struk_${p.nomorPesanan}.pdf';

  static Future<Uint8List> build(Pesanan p, {Uint8List? logoBytes, PdfPageFormat? format}) async {
    final doc = pw.Document(
      title: 'Struk ${p.nomorPesanan}',
      author: ApiConfig.namaToko,
      creator: '${ApiConfig.namaToko} App',
    );
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;
    final t = latin1Safe;

    pw.Widget row(String label, String value, {bool bold = false, double size = 8.5, PdfColor? color}) {
      final style = pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      );
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 5, child: pw.Text(t(label), style: style)),
            pw.Expanded(
              flex: 6,
              child: pw.Text(t(value), style: style, textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );
    }

    pw.Widget divider() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Divider(height: 0.5, thickness: 0.6, color: PdfColors.grey500, borderStyle: pw.BorderStyle.dashed),
    );

    doc.addPage(
      pw.Page(
        pageFormat: format ?? PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (logo != null) pw.Center(child: pw.Image(logo, width: 58, height: 58)),
            pw.SizedBox(height: 2),
            pw.Text(
              ApiConfig.namaToko,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _primary),
            ),
            pw.Text(
              'Toko Buku & Perlengkapan Belajar',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: _grey),
            ),
            pw.Text(
              t(ApiConfig.taglineToko),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 7, color: _grey, fontStyle: pw.FontStyle.italic),
            ),
            divider(),
            pw.Text(
              'STRUK PESANAN',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            row('No. Pesanan', p.nomorPesanan, bold: true),
            row('Tanggal', Formatter.tanggalWaktu(p.tanggal)),
            row('Pemesan', p.namaPemesan),
            row('No. HP', p.noHp),
            row('Tipe Pesanan', p.tipePesanan),
            if (p.email != null) row('Email', p.email!),
            row('Status', p.status),
            if (p.alamat != null) ...[
              pw.SizedBox(height: 2),
              pw.Text('Alamat Pengiriman:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
              pw.Text(t(p.alamat!), style: const pw.TextStyle(fontSize: 8.5)),
            ],
            divider(),
            for (final it in p.items) ...[
              pw.Text(t(it.namaProduk), style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
              row('${it.jumlah} x ${_rp(it.hargaSatuan)}', _rp(it.subtotal)),
              if (it.catatanItem != null)
                pw.Text(
                  t('Catatan: ${it.catatanItem}'),
                  style: pw.TextStyle(fontSize: 7.5, color: _grey, fontStyle: pw.FontStyle.italic),
                ),
              pw.SizedBox(height: 3),
            ],
            divider(),
            row('Subtotal (${p.totalQty} item)', _rp(p.subtotal)),
            row('Biaya Layanan', _rp(p.biayaLayanan)),
            row('Ongkir', _rp(p.ongkir)),
            row('Diskon Pelajar', p.diskon > 0 ? '- ${_rp(p.diskon)}' : _rp(0)),
            pw.SizedBox(height: 3),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F4F8)),
              child: row('TOTAL BAYAR', _rp(p.total), bold: true, size: 10.5, color: _primary),
            ),
            if (p.catatan != null) ...[
              pw.SizedBox(height: 5),
              pw.Text(t('Catatan pesanan: ${p.catatan}'), style: const pw.TextStyle(fontSize: 8)),
            ],
            divider(),
            pw.Text(
              'Terima kasih telah belajar bersama NeoLearn!',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Simpan struk ini sebagai bukti pemesanan.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 7.5, color: _grey),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              t('Dicetak: ${Formatter.tanggalWaktu(DateTime.now())}'),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 6.5, color: _grey),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }
}
