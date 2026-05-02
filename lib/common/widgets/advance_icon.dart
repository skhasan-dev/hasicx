import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors;

class AdvanceIcon extends StatelessWidget {
  const AdvanceIcon({
    required this.icon,
    this.onTap,
    this.size = 24,
    this.color,
    super.key,
  });
  final IconData? icon;
  final double size;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: size, color: color ?? AppColors.textColor),
    );
  }
}
