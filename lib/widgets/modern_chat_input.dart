import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../theme/app_theme.dart';

class ModernChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final Function(types.PartialText) onSendPressed;
  final VoidCallback? onAttachmentPressed;
  final bool isProcessing;

  const ModernChatInputField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSendPressed,
    this.onAttachmentPressed,
    this.isProcessing = false,
  });

  @override
  State<ModernChatInputField> createState() => _ModernChatInputFieldState();
}

class _ModernChatInputFieldState extends State<ModernChatInputField> {
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _isEmpty = widget.controller.text.isEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isEmpty = widget.controller.text.isEmpty;
    if (_isEmpty != isEmpty) {
      setState(() {
        _isEmpty = isEmpty;
      });
    }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty && !widget.isProcessing) {
      final text = widget.controller.text.trim();
      widget.controller.clear();
      widget.onSendPressed(types.PartialText(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        color: AppColors.surface(isDark),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(isDark).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          if (widget.onAttachmentPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                onPressed: widget.onAttachmentPressed,
                icon: Icon(
                  Icons.attach_file_outlined,
                  color: AppColors.textSecondary(isDark),
                  size: 20,
                ),
                tooltip: 'Attach file',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),

          // Text input field
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: widget.onAttachmentPressed != null ? 4 : 16,
                right: 0,
                top: 8,
                bottom: 8,
              ),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isProcessing,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary(isDark),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),

          // Send button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _isEmpty || widget.isProcessing ? null : _handleSend,
                icon: widget.isProcessing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textSecondary(isDark)),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: 20,
                      ),
                style: IconButton.styleFrom(
                  foregroundColor: _isEmpty || widget.isProcessing
                      ? AppColors.textTertiary(isDark)
                      : AppColors.accent(isDark),
                  backgroundColor: _isEmpty || widget.isProcessing
                      ? Colors.transparent
                      : AppColors.accent(isDark).withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                tooltip: 'Send message',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
