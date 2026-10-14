import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ChoiceChip kategori untuk filter katalog.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label, required this.selected, required this.onSelected, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  /// Ikon Material berdasarkan nama ikon dari tabel kategori.
  static IconData iconFor(String? name) {
    switch (name) {
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'cast_for_education':
        return Icons.cast_for_education_rounded;
      case 'science':
        return Icons.science_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: icon == null ? null : Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primary),
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }
}
