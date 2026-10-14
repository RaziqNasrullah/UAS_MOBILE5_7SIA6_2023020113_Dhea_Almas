import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Gambar produk dari server dengan placeholder & fallback jika gagal dimuat.
class ProdukImage extends StatelessWidget {
  const ProdukImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: AppColors.sky.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 36),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, _) => Container(
                width: width,
                height: height,
                color: AppColors.sky.withValues(alpha: 0.3),
                alignment: Alignment.center,
                child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
