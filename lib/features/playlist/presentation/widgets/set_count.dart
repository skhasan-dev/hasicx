import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';

class SetCount extends StatelessWidget {
  SetCount({required this.onCountSet, super.key});

  final ValueChanged<int> onCountSet;

  final TextEditingController countController = TextEditingController(
    text: SharedPrefs.getRecentCount().toString(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Set Count", style: AppTextStyles.s16W600),
            const SizedBox(height: 20),

            TextFormField(
              controller: countController,
              style: AppTextStyles.s28W600,
              textAlign: TextAlign.center,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Count is Required';
                }

                int? number = int.tryParse(value);

                switch (number) {
                  case null:
                    return 'Invalid number';
                  case <= 0:
                    return 'Count should be greater than 0';
                }

                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(),
            ),

            const SizedBox(height: 20),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      countController.text = SharedPrefs.getRecentCount()
                          .toString();
                    },
                    child: Text(
                      "Reset",
                      style: AppTextStyles.s14W600.copyWith(
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        onCountSet.call(
                          int.tryParse(countController.text.trim()) ?? 0,
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    child: Text(
                      "Set",
                      style: AppTextStyles.s14W600.copyWith(
                        color: AppColors.textColor,
                      ),
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
