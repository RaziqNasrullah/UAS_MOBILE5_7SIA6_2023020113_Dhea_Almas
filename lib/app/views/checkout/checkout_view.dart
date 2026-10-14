import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/checkout_controller.dart';
import '../../data/services/api_config.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/rincian_biaya_card.dart';
import '../../widgets/state_views.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = controller.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang kosong',
            message: 'Tambahkan produk sebelum checkout.',
            actionLabel: 'Kembali',
            onAction: Get.back,
          );
        }
        final r = controller.rincian;
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _Section(
                title: 'Ringkasan Pesanan',
                icon: Icons.shopping_bag_outlined,
                child: Column(
                  children: [
                    for (final it in cart.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${it.nama} x${it.jumlah}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (it.catatanItem != null)
                                    Text(
                                      'Catatan: ${it.catatanItem}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(Formatter.rupiah(it.subtotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Data Pemesan',
                icon: Icons.person_outline_rounded,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Nama Pemesan',
                      isRequired: true,
                      controller: controller.namaC,
                      hint: 'Nama lengkap',
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) => Validators.wajib(v, label: 'Nama pemesan'),
                    ),
                    CustomTextField(
                      label: 'Nomor HP',
                      isRequired: true,
                      controller: controller.hpC,
                      hint: '08xxxxxxxxxx',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_rounded,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
                        LengthLimitingTextInputFormatter(16),
                      ],
                      helperText: 'Angka 10-13 digit, diawali 08',
                      validator: Validators.noHp,
                    ),
                    if (controller.emailWajib)
                      CustomTextField(
                        label: 'Email (untuk info & akses kelas)',
                        isRequired: true,
                        controller: controller.emailC,
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => Validators.email(v, wajibDiisi: true),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Tipe Pesanan',
                icon: Icons.local_shipping_outlined,
                child: RadioGroup<String>(
                  groupValue: controller.tipePesanan.value,
                  onChanged: controller.setTipe,
                  child: Column(
                    children: [
                      const _TipeTile(
                        value: ApiConfig.tipeAmbil,
                        icon: Icons.storefront_rounded,
                        subtitle: 'Ambil langsung di toko NeoLearn. Ongkir gratis.',
                      ),
                      _TipeTile(
                        value: ApiConfig.tipeDiantar,
                        icon: Icons.delivery_dining_rounded,
                        subtitle: 'Diantar ke alamatmu. Ongkir ${Formatter.rupiah(ApiConfig.ongkirDiantar)}.',
                      ),
                      _TipeTile(
                        value: ApiConfig.tipeDigital,
                        icon: Icons.cloud_download_outlined,
                        enabled: controller.bolehDigital,
                        subtitle: controller.bolehDigital
                            ? 'E-book & link kelas dikirim secara digital.'
                            : 'Hanya jika semua item berformat E-Book atau Kelas Online.',
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isDiantar) ...[
                const SizedBox(height: 14),
                _Section(
                  title: 'Alamat Pengiriman',
                  icon: Icons.location_on_outlined,
                  child: CustomTextField(
                    label: 'Alamat lengkap',
                    isRequired: true,
                    controller: controller.alamatC,
                    hint: 'Jalan, nomor rumah, RT/RW, kelurahan, kota',
                    maxLines: 3,
                    validator: (v) => Validators.alamat(v, wajibDiisi: true),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _Section(
                title: 'Catatan Pesanan',
                icon: Icons.notes_rounded,
                child: CustomTextField(
                  label: 'Catatan (opsional)',
                  controller: controller.catatanC,
                  hint: 'Contoh: tolong dibungkus rapi',
                  maxLines: 2,
                  maxLength: 255,
                ),
              ),
              const SizedBox(height: 14),
              RincianBiayaCard(
                subtotal: r.subtotal,
                biayaLayanan: r.biayaLayanan,
                ongkir: r.ongkir,
                diskon: r.diskon,
                total: r.total,
                totalQty: cart.totalQty,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (cart.items.isEmpty) return const SizedBox.shrink();
        final busy = controller.isSubmitting.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ElevatedButton.icon(
              onPressed: busy ? null : controller.submit,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                busy ? 'Memproses pesanan...' : 'Buat Pesanan - ${Formatter.rupiah(controller.rincian.total)}',
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TipeTile extends StatelessWidget {
  const _TipeTile({required this.value, required this.icon, required this.subtitle, this.enabled = true});

  final String value;
  final IconData icon;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: enabled ? AppColors.primary : AppColors.border),
      title: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.w600, color: enabled ? null : AppColors.textSecondary),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }
}
