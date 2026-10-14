import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/produk_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/produk_image.dart';

class ProdukFormView extends GetView<ProdukController> {
  const ProdukFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final editing = controller.editing.value;
    final isEdit = editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Ubah Produk' : 'Tambah Produk')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Obx(() {
                final bytes = controller.pickedBytes.value;
                return Stack(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: controller.pickImage,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: bytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(bytes, fit: BoxFit.cover),
                              )
                            : (editing?.gambar != null
                                  ? ProdukImage(url: editing!.imageUrl, width: 150, height: 200, borderRadius: 16)
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
                                        SizedBox(height: 6),
                                        Text(
                                          'Pilih gambar\ndari galeri',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Pilih gambar',
                          onPressed: controller.pickImage,
                          icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    if (bytes != null)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Material(
                          color: AppColors.danger,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Batal pilih',
                            onPressed: controller.removePickedImage,
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('JPG/PNG/WEBP, maks 2 MB', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nama Produk',
              isRequired: true,
              controller: controller.namaC,
              hint: 'Contoh: Bank Soal UTBK 2027',
              validator: (v) => Validators.wajib(v, label: 'Nama produk'),
            ),
            const Text.rich(
              TextSpan(
                text: 'Kategori',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<int>(
                key: ValueKey('kategori-${controller.kategoriList.length}'),
                initialValue: controller.kategoriList.any((k) => k.id == controller.kategoriId.value)
                    ? controller.kategoriId.value
                    : null,
                isExpanded: true,
                hint: const Text('Pilih kategori'),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: [for (final k in controller.kategoriList) DropdownMenuItem(value: k.id, child: Text(k.nama))],
                onChanged: controller.onKategoriChanged,
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => CustomTextField(
                label: controller.labelPenulis,
                isRequired: true,
                controller: controller.penulisC,
                hint: controller.isKelasDipilih ? 'Nama pengajar' : 'Penulis buku / merek alat tulis',
                prefixIcon: controller.isKelasDipilih ? Icons.co_present_outlined : Icons.person_outline_rounded,
                validator: (v) => Validators.wajib(v, label: controller.labelPenulis),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Harga (Rp)',
                    isRequired: true,
                    controller: controller.hargaC,
                    hint: '75000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.harga,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => CustomTextField(
                      label: controller.labelStok,
                      isRequired: true,
                      controller: controller.stokC,
                      hint: '10',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => Validators.stok(v, label: controller.labelStok),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Dropdown(label: 'Jenjang', value: controller.jenjang, items: controller.jenjangList),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Dropdown(
                    label: 'Format Produk',
                    value: controller.formatProduk,
                    items: controller.formatList,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => CustomTextField(
                label: 'Detail Tambahan',
                controller: controller.detailC,
                hint: controller.isKelasDipilih ? 'Contoh: 8 pertemuan' : 'Contoh: 248 halaman / isi 12 pcs',
                prefixIcon: Icons.straighten_rounded,
              ),
            ),
            CustomTextField(
              label: 'Deskripsi',
              isRequired: true,
              controller: controller.deskripsiC,
              hint: 'Jelaskan isi buku, spesifikasi barang, atau materi kelas',
              maxLines: 4,
              validator: (v) => Validators.wajib(v, label: 'Deskripsi'),
            ),
            Obx(
              () => Card(
                child: SwitchListTile(
                  value: controller.isBestSeller.value,
                  onChanged: (v) => controller.isBestSeller.value = v,
                  title: const Text('Best Seller', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Tampilkan di bagian Best Seller beranda'),
                  secondary: const Icon(Icons.star_rounded, color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isSaving.value ? null : controller.save,
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(controller.isSaving.value ? 'Menyimpan...' : (isEdit ? 'Simpan Perubahan' : 'Simpan Produk')),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.items});

  final String label;
  final RxString value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        const SizedBox(height: 6),
        Obx(
          () => DropdownButtonFormField<String>(
            key: ValueKey('$label-${value.value}'),
            initialValue: value.value,
            isExpanded: true,
            items: [
              for (final i in items)
                DropdownMenuItem(
                  value: i,
                  child: Text(i, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) {
              if (v != null) value.value = v;
            },
          ),
        ),
      ],
    );
  }
}
