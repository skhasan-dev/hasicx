import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    this.icon,
    this.title,
    this.subtitle,
    this.actionText,
    this.onPressed,
    super.key,
  });

  final Widget? icon;
  final Widget? title;
  final Widget? subtitle;
  final String? actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      mainAxisSize: MainAxisSize.min,
      children: [
        ?icon,

        Column(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [?title, ?subtitle],
        ),

        const SizedBox(height: 0),

        if (actionText != null && onPressed != null)
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: AppColors.buttonColor,
            ),
            child: Text(
              actionText!,
              style: AppTextStyles.s16W600.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
