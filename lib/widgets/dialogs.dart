import 'package:flutter/material.dart';

class AskDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;

  const AskDialog({
    super.key,
    this.title = 'Confirm',
    this.message = 'Are you sure?',
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Confirm',
    String message = 'Are you sure?',
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AskDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF09090B) // Zinc-950
              : const Color(0xFFFFFFFF), // Pure white
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF27272A) // Zinc-800
                : const Color(0xFFE4E4E7), // Zinc-200
            width: 1,
          ),
          boxShadow: [
            // Modern shadow similar to chat UI
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF4F4F5) // Zinc-100
                    : const Color(0xFF18181B), // Zinc-900
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFA1A1AA) // Zinc-400
                    : const Color(0xFF71717A), // Zinc-500
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                      onCancel?.call();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF27272A) // Zinc-800
                              : const Color(0xFFE4E4E7), // Zinc-200
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFF4F4F5) // Zinc-100
                              : const Color(0xFF18181B), // Zinc-900
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFF4F4F5) // Zinc-100
                            : const Color(0xFF18181B), // Zinc-900
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF27272A) // Zinc-800
                              : const Color(0xFFE4E4E7), // Zinc-200
                          width: 1,
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF18181B) // Zinc-900
                              : const Color(0xFFF4F4F5), // Zinc-100
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
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
