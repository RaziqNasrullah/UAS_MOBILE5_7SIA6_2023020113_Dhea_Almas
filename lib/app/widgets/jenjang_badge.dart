import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Badge jenjang pendidikan dengan warna berbeda per jenjang.
class JenjangBadge extends StatelessWidget {
  const JenjangBadge({super.key, required this.jenjang, this.compact = false});

  final String jenjang;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.jenjang(jenjang);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        jenjang,
        style: TextStyle(color: color, fontSize: compact ? 10 : 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
