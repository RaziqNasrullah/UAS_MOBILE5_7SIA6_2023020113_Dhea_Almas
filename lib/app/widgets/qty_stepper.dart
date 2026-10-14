import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tombol -/+ jumlah dengan batas minimal & maksimal (stok/kuota).
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    required this.max,
    this.onMaxReached,
    this.enabled = true,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback? onMaxReached;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canMinus = enabled && value > min;
    final canPlus = enabled && value < max;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, canMinus ? () => onChanged(value - 1) : null, 'Kurangi'),
          SizedBox(
            width: 34,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          _btn(
            Icons.add_rounded,
            !enabled ? null : (canPlus ? () => onChanged(value + 1) : onMaxReached),
            'Tambah',
            dimmed: !canPlus,
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, String tooltip, {bool dimmed = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 18, color: onTap == null || dimmed ? AppColors.border : AppColors.primary),
        ),
      ),
    );
  }
}
