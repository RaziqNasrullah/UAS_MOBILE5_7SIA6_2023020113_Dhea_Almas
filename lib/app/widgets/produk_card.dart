import 'package:flutter/material.dart';

import '../models/produk.dart';
import '../theme/app_colors.dart';
import '../utils/formatter.dart';
import 'jenjang_badge.dart';
import 'produk_image.dart';

/// Kartu produk untuk grid katalog & daftar horizontal di beranda.
class ProdukCard extends StatelessWidget {
  const ProdukCard({super.key, required this.produk, required this.onTap, this.width});

  final Produk produk;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 3.2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProdukImage(url: produk.imageUrl, borderRadius: 0),
                    if (produk.isBestSeller)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: _Tag(label: 'Best Seller', color: AppColors.accent, icon: Icons.star_rounded),
                      ),
                    if (produk.isHabis)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: _Tag(label: produk.labelHabis, color: AppColors.danger),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        produk.penulisMerek,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              Formatter.rupiah(produk.harga),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          JenjangBadge(
                            jenjang: produk.jenjang == 'Perguruan Tinggi' ? 'PT' : produk.jenjang,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: Colors.white), const SizedBox(width: 3)],
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
