import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    required this.title,
    required this.leading,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final IconData leading;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading, color: AppColors.textColor, size: 32),
      title: Text(title, style: AppTextStyles.s16W400),
      onLongPress: onLongPress,
      onTap: onTap,
    );
  }
}
