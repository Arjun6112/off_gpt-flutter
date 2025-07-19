import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final effectiveTextColor = textColor ??
        (isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B));

    return Row(
      children: [
        const SizedBox(width: 12),
        Text(
          tr("l_offGPT"),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: effectiveTextColor,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}
