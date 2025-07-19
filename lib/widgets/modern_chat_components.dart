import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_theme.dart';

class ModernChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onRegenerate;

  const ModernChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.onCopy,
    this.onShare,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isDark),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: _buildMessageContainer(isDark),
          ),
          const SizedBox(width: AppSpacing.md),
          if (isUser) _buildAvatar(isDark),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.accent(isDark)
            : AppColors.secondaryLight(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: AppColors.surface(isDark),
      ),
    );
  }

  Widget _buildMessageContainer(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.chatUserBubble(isDark)
                : AppColors.chatAssistantBubble(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg).copyWith(
              topLeft: isUser
                  ? const Radius.circular(AppBorderRadius.lg)
                  : const Radius.circular(AppBorderRadius.xs),
              topRight: isUser
                  ? const Radius.circular(AppBorderRadius.xs)
                  : const Radius.circular(AppBorderRadius.lg),
            ),
            border: isUser ? null : Border.all(color: AppColors.border(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: isUser
                    ? Text(
                        message,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textOnPrimary(isDark),
                        ),
                      )
                    : MarkdownBody(
                        data: message,
                        styleSheet: MarkdownStyleSheet(
                          p: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary(isDark),
                          ),
                          code: AppTypography.bodyMedium.copyWith(
                            backgroundColor: AppColors.surfaceDark(isDark),
                            color: AppColors.textPrimary(isDark),
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: AppColors.surfaceDark(isDark),
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.sm),
                          ),
                        ),
                      ),
              ),
              if (!isUser) _buildActionButtons(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.copy,
            tooltip: 'Copy',
            onPressed: onCopy,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildActionButton(
            icon: Icons.share,
            tooltip: 'Share',
            onPressed: onShare,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildActionButton(
            icon: Icons.refresh,
            tooltip: 'Regenerate',
            onPressed: onRegenerate,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface(isDark),
          foregroundColor: AppColors.textSecondary(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class ModernChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final bool isLoading;
  final String? hint;

  const ModernChatInput({
    super.key,
    required this.controller,
    this.onSend,
    this.onAttach,
    this.isLoading = false,
    this.hint,
  });

  @override
  State<ModernChatInput> createState() => _ModernChatInputState();
}

class _ModernChatInputState extends State<ModernChatInput> {
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isEmpty = widget.controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        border: Border(top: BorderSide(color: AppColors.border(isDark))),
      ),
      child: Row(
        children: [
          if (widget.onAttach != null) ...[
            IconButton(
              onPressed: widget.onAttach,
              icon: const Icon(Icons.attach_file),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceLight(isDark),
                foregroundColor: AppColors.textSecondary(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.chatInputBackground(isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                minLines: 1,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Type a message...',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textTertiary(isDark),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onSubmitted: (_) => widget.onSend?.call(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isEmpty || widget.isLoading
                  ? AppColors.surfaceLight(isDark)
                  : AppColors.accent(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: IconButton(
              onPressed: (_isEmpty || widget.isLoading) ? null : widget.onSend,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textSecondary(isDark)),
                      ),
                    )
                  : const Icon(Icons.send),
              style: IconButton.styleFrom(
                foregroundColor: _isEmpty
                    ? AppColors.textTertiary(isDark)
                    : AppColors.surface(isDark),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
