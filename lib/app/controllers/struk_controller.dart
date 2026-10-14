import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../models/pesanan.dart';
import '../utils/app_snackbar.dart';
import '../utils/pdf_generator.dart';

/// Preview, simpan, dan bagikan struk PDF. Menerima objek Pesanan lewat Get.arguments.
class StrukController extends GetxController {
  final pesanan = Rxn<Pesanan>();
  final isSaving = false.obs;
  final savedPath = RxnString();

  Uint8List? _logo;
  Uint8List? _cache;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Pesanan) pesanan.value = arg;
  }

  String get fileName => pesanan.value == null ? 'Struk.pdf' : StrukPdfGenerator.namaFile(pesanan.value!);

  Future<Uint8List> buildPdf() async {
    if (_cache != null) return _cache!;
    final p = pesanan.value;
    if (p == null) throw Exception('Data pesanan tidak tersedia');
    try {
      _logo ??= (await rootBundle.load('assets/images/logo_mark.png')).buffer.asUint8List();
    } catch (_) {
      _logo = null; // struk tetap dibuat tanpa logo
    }
    _cache = await StrukPdfGenerator.build(p, logoBytes: _logo);
    return _cache!;
  }

  /// Simpan ke folder Download milik aplikasi:
  /// Android/data/com.dheaalmas.neolearn/files/Download/
  Future<void> simpan() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final bytes = await buildPdf();
      Directory? base;
      try {
        base = await getExternalStorageDirectory();
      } catch (_) {
        base = null;
      }
      base ??= await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}${Platform.pathSeparator}Download');
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      savedPath.value = file.path;
      AppSnackbar.success('Struk disimpan di:\n${file.path}', title: 'Struk tersimpan');
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan struk: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> bagikan() async {
    try {
      final bytes = await buildPdf();
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      AppSnackbar.error('Gagal membagikan struk: $e');
    }
  }
}
