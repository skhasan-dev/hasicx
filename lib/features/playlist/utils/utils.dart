import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/features/playlist/index.dart';
import 'package:hasicx/features/playlist/presentation/widgets/set_count.dart';

class PlaylistUtils {
  static Future<void> showAddPlaylistDialog(
    BuildContext context, {
    required ValueChanged<String> onCreate,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Removes rounded corners
          ),
          backgroundColor: AppColors.deepTabColor,
          child: AddPlaylistDialog(onCreate: onCreate),
        );
      },
    );
  }

  static Future<void> showCountDialog(
    BuildContext context, {
    required ValueChanged<int> onCountSet,
  }) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Removes rounded corners
          ),
          backgroundColor: AppColors.deepTabColor,
          child: SetCount(onCountSet: onCountSet),
        );
      },
    );
  }
}
