import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'app_text_style.dart';

class ActionButton extends StatelessWidget{
  final String text;
  final Function? function;

  const ActionButton(this.text, {this.function, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        function?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.medium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(text, style: AppTextStyle.bodyLarge),
    );
  }
}