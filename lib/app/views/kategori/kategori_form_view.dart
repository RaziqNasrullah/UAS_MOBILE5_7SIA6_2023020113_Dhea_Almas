import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_text_field.dart';

class KategoriFormView extends GetView<KategoriController> {
  const KategoriFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.editing.value != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Ubah Kategori' : 'Tambah Kategori')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Nama Kategori',
              isRequired: true,
              controller: controller.namaC,
              hint: 'Contoh: Buku Pelajaran',
              prefixIcon: Icons.category_outlined,
              validator: controller.validateNama,
            ),
            CustomTextField(
              label: 'Deskripsi',
              controller: controller.deskripsiC,
              hint: 'Deskripsi singkat kategori (opsional)',
              maxLines: 3,
              maxLength: 255,
            ),
            const Text('Ikon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final name in KategoriController.ikonPilihan)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => controller.ikon.value = name,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: controller.ikon.value == name ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          CategoryChip.iconFor(name),
                          color: controller.ikon.value == name ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
              label: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Kategori'),
            ),
          ),
        ),
      ),
    );
  }
}
