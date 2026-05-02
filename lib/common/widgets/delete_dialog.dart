import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({required this.onDelete, this.isSong = true, super.key});

  final bool isSong;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete),
              Text('Delete', style: AppTextStyles.s16W600),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to delete this ${isSong ? 'song' : 'playlist'}?',
            style: AppTextStyles.s14W400,
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: context.pop,
                child: Text(
                  'No',
                  style: AppTextStyles.s14W600.copyWith(
                    color: AppColors.textColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  onDelete.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                ),
                child: Text(
                  'Yes',
                  style: AppTextStyles.s14W600.copyWith(
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
