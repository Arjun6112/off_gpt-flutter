import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

class AppTitle extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;

  const AppTitle({
    super.key,
    this.fontSize = 14,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? AppColors.surface(isDark);

    return Row(
      children: [
        SizedBox(width: 10),
        Text(tr("l_offGPT"),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: effectiveTextColor,
            )),
      ],
    );
  }
}
