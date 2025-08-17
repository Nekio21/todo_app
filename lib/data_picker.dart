import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'app_text_style.dart';
import 'app_theme.dart';

class DataPicker extends FormField<DateTime?>{

  DataPicker({super.key, super.validator, super.onSaved}) : super(builder: (field){
    return InkWell(
      onTap: () async{
          final picked = await pickDateTime(field.context);
          if (picked != null) {
            field.didChange(picked);
          }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.small,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: field.hasError ? AppTheme.error : AppTheme.onSurface,
          ),
          Text(
            field.value == null
                ? "set time*"
                : field.value.toString(),
            style: field.hasError ? AppTextStyle.captionBold.apply(color: AppTheme.error) : AppTextStyle.captionBold,
          ),
        ],
      ),
    );
  });


  static Future<DateTime?> pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 3650)),
    );

    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

}