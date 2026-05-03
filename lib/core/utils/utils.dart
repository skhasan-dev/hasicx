import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors, DeleteDialog;

class AppUtils {
  static Future<void> showDeleteDialog(
    BuildContext context, {
    bool isSong = true,
    required VoidCallback onDelete,
  }) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.deepTabColor,
          child: DeleteDialog(onDelete: onDelete, isSong: isSong),
        );
      },
    );
  }
}
