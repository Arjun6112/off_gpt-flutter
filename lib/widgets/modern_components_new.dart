import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern Card Component
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.lg),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder(isDark),
          width: 1,
        ),
        boxShadow: boxShadow ?? AppShadows.small(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppBorderRadius.lg),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Button Styles Enum
enum ButtonStyle { primary, secondary, outline, ghost }

enum ButtonSize { small, medium, large }

/// Modern Button Component
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = ButtonStyle.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (style) {
      case ButtonStyle.primary:
        backgroundColor = AppColors.primary(isDark);
        foregroundColor = AppColors.textOnPrimary(isDark);
        break;
      case ButtonStyle.secondary:
        backgroundColor = AppColors.secondary(isDark);
        foregroundColor = AppColors.textOnPrimary(isDark);
        break;
      case ButtonStyle.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.textPrimary(isDark);
        borderSide = BorderSide(color: AppColors.border(isDark));
        break;
      case ButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.accent(isDark);
        break;
    }

    EdgeInsets padding;
    double fontSize;
    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm);
        fontSize = 12;
        break;
      case ButtonSize.medium:
        padding = const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md);
        fontSize = 14;
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.lg);
        fontSize = 16;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null)
          Icon(icon!, size: 16, color: foregroundColor),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: AppSpacing.sm),
        if (text.isNotEmpty)
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: foregroundColor,
              fontSize: fontSize,
            ),
          ),
      ],
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: padding,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Icon Button Styles
enum IconButtonStyle { normal, filled, outline }

/// Modern Icon Button Component
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final IconButtonStyle style;
  final double? size;
  final Color? color;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.style = IconButtonStyle.normal,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (style) {
      case IconButtonStyle.filled:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            iconSize: size ?? 24,
            color: color ?? AppColors.textSecondary(isDark),
          ),
        );
      case IconButtonStyle.outline:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(isDark)),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            iconSize: size ?? 24,
            color: color ?? AppColors.textSecondary(isDark),
          ),
        );
      case IconButtonStyle.normal:
        return IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          iconSize: size ?? 24,
          color: color ?? AppColors.textSecondary(isDark),
        );
    }
  }
}

/// Modern Text Field Component
class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool enabled;
  final String? helperText;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              widget.label!,
              style: AppTypography.labelMedium.copyWith(
                color: _isFocused
                    ? AppColors.accent(isDark)
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          validator: widget.validator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: _isFocused
                ? AppColors.surface(isDark)
                : AppColors.surfaceLight(isDark),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: AppColors.border(isDark)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: AppColors.border(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: AppColors.accent(isDark), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: _isFocused
                  ? AppColors.accent(isDark)
                  : AppColors.textSecondary(isDark),
            ),
            hintStyle: AppTypography.bodyMedium
                .copyWith(color: AppColors.textTertiary(isDark)),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon!,
                    color: AppColors.textSecondary(isDark))
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon!),
                    onPressed: widget.onSuffixIconPressed,
                    color: AppColors.textSecondary(isDark),
                  )
                : null,
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.helperText!,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary(isDark)),
            ),
          ),
      ],
    );
  }
}

/// Modern List Tile Component
class ModernListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;
  final bool showBorder;

  const ModernListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: AppColors.border(isDark)))
            : null,
      ),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
        iconColor: AppColors.textSecondary(isDark),
      ),
    );
  }
}

/// Modern App Bar Component
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? elevation;

  const ModernAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface(isDark),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.textSecondary(isDark)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Modern Badge Component
class ModernBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const ModernBadge({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceLight(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color ?? AppColors.textSecondary(isDark),
        ),
      ),
    );
  }
}

/// Modern Chip Component
class ModernChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? color;
  final bool selected;

  const ModernChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
    this.backgroundColor,
    this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onPressed != null ? (_) => onPressed!() : null,
      onDeleted: onDeleted,
      backgroundColor: backgroundColor ?? AppColors.surfaceLight(isDark),
      selectedColor: AppColors.accent(isDark).withValues(alpha: 0.2),
      checkmarkColor: AppColors.accent(isDark),
      deleteIconColor: AppColors.textSecondary(isDark),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: color ?? AppColors.textSecondary(isDark),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
    );
  }
}
