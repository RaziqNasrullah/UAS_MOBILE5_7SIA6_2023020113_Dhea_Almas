import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../widgets/cart_badge_icon.dart';
import '../admin/admin_view.dart';
import '../cart/cart_view.dart';
import '../home/home_view.dart';
import '../katalog/katalog_view.dart';
import '../pesanan/pesanan_view.dart';

/// Kerangka utama dengan bottom navigation (badge keranjang memakai Obx).
class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [HomeView(), KatalogView(), CartView(), PesananView(), AdminView()];
    return Obx(
      () => PopScope(
        canPop: controller.currentIndex.value == MainController.tabBeranda,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.changeTab(MainController.tabBeranda);
        },
        child: Scaffold(
          body: IndexedStack(index: controller.currentIndex.value, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Katalog',
              ),
              NavigationDestination(
                icon: CartBadgeIcon(color: Color(0xFF5E6E7C)),
                selectedIcon: CartBadgeIcon(color: Color(0xFF1B5E6E), icon: Icons.shopping_cart_rounded),
                label: 'Keranjang',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Toko',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
