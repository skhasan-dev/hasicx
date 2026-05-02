import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors, AppTextStyles;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.tabColor,
      actions: [
        IconButton(
          onPressed: () {
            // if (player.isSearchEnabled.value) {
            //   player.isSearchEnabled.value = false;
            //   setState(() {
            //     searchQuery = '';
            //   });
            // } else {
            //   player.isSearchEnabled.value = true;
            // }
          },
          icon: Icon(Icons.search, color: AppColors.textColor),
        ),
      ],
      title: Text(
        "HasicX",
        style: AppTextStyles.s18W600.copyWith(letterSpacing: 2),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
