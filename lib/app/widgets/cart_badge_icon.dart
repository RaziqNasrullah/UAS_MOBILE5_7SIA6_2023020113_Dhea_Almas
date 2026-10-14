import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../theme/app_colors.dart';

/// Ikon keranjang dengan badge jumlah item (reaktif via Obx).
class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key, this.onPressed, this.color = Colors.white, this.icon = Icons.shopping_cart_outlined});

  final VoidCallback? onPressed;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final badge = Obx(() {
      final n = cart.totalQty;
      return Badge(
        isLabelVisible: n > 0,
        backgroundColor: AppColors.accent,
        textColor: Colors.white,
        label: Text(n > 99 ? '99+' : '$n'),
        child: Icon(icon, color: color),
      );
    });
    if (onPressed == null) return badge;
    return IconButton(tooltip: 'Keranjang', onPressed: onPressed, icon: badge);
  }
}
