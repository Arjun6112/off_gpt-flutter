import 'package:flutter/material.dart';
import '../widgets/modern_components.dart';

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
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: ModernTextField(
        label: widget.label,
        hint: widget.hint,
        helperText: widget.helperText,
        controller: widget.controller,
        maxLines: widget.maxLines,
        keyboardType:
            widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text,
        onChanged: widget.onChanged,
      ),
    );
  }
}
