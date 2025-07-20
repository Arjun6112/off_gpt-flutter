import 'package:flutter/material.dart';

class QTextField extends StatefulWidget {
  final String label;
  final Function(String) onChanged;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;
  final String? helperText;

  const QTextField(
    this.label,
    this.controller,
    this.onChanged, {
    super.key,
    this.maxLines = 1,
    this.hint,
    this.helperText,
  });

  @override
  _QTextFieldState createState() => _QTextFieldState();
}

class _QTextFieldState extends State<QTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onChanged(widget.controller.text);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? (isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFD4D4D8))
                    : (isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE4E4E7)),
                width: 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              keyboardType: widget.maxLines > 1
                  ? TextInputType.multiline
                  : TextInputType.text,
              style: TextStyle(
                color:
                    isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF27272A) // Zinc-800
                        : const Color(0xFFF4F4F5), // Zinc-200
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF27272A) // Zinc-800
                        : const Color(0xFFF4F4F5), // Zinc-200
                    width: 1,
                  ),
                ),
                focusColor: isDark
                    ? const Color(0xFF18181B) // Zinc-900 (darker)
                    : const Color(0xFFE4E4E7), // Zinc-200
                filled: true,

                fillColor: isDark
                    ? const Color(0xFF18181B) // Zinc-900 (darker)
                    : const Color(0xFFE4E4E7), // Zinc-200
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF71717A),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              ),
              onChanged: (value) {
                setState(() {}); // Update focus state
              },
            ),
          ),
          if (widget.helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color:
                    isDark ? const Color(0xFF71717A) : const Color(0xFF71717A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
