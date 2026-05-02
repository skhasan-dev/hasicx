import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';

class AddPlaylistDialog extends StatelessWidget {
  AddPlaylistDialog({required this.onCreate, super.key});

  final TextEditingController playlistController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueChanged<String> onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Enter Playlist Name", style: AppTextStyles.s16W600),
            const SizedBox(height: 16),
            TextFormField(
              controller: playlistController,
              style: AppTextStyles.s14W400,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is Required';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: "Playlist Name",
                hintStyle: AppTextStyles.s14W400,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.buttonColor),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: context.pop,
                  child: Text(
                    "Cancel",
                    style: AppTextStyles.s14W600.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      onCreate.call(playlistController.text.trim());
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                  ),
                  child: Text(
                    "Create",
                    style: AppTextStyles.s14W600.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
