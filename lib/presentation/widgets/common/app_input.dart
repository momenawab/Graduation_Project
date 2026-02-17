import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart' as styles;

/// Standard input field widget with label, error text, and validation support.
@immutable
class AppInput extends StatelessWidget {
  /// Input field label
  final String? label;

  /// Input field hint text
  final String? hintText;

  /// Current value of the input
  final String? value;

  /// Callback when value changes
  final ValueChanged<String>? onChanged;

  /// Callback when input is submitted
  final ValueChanged<String>? onSubmitted;

  /// Input field validator
  final FormFieldValidator<String>? validator;

  /// Whether input is enabled (defaults to true)
  final bool enabled;

  /// Whether input is required (shows asterisk on label)
  final bool isRequired;

  /// Maximum number of characters allowed
  final int? maxLength;

  /// Maximum number of lines (defaults to 1)
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Input field prefix widget
  final Widget? prefix;

  /// Input field suffix widget
  final Widget? suffix;

  /// Input field prefix icon
  final IconData? prefixIcon;

  /// Input field suffix icon
  final IconData? suffixIcon;

  /// Callback when suffix icon is tapped
  final VoidCallback? onSuffixIconTap;

  /// Keyboard type for the input
  final TextInputType? keyboardType;

  /// Text input action (e.g., done, next, search)
  final TextInputAction? textInputAction;

  /// Text capitalization mode
  final TextCapitalization textCapitalization;

  /// Error text to display
  final String? errorText;

  /// Helper text to display below input
  final String? helperText;

  /// Input field border radius (defaults to 8)
  final double borderRadius;

  /// Input field padding
  final EdgeInsetsGeometry? contentPadding;

  const AppInput({
    this.label,
    this.hintText,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.helperText,
    this.borderRadius = 8,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveContentPadding =
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: styles.AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          enabled: enabled,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: styles.AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            helperText: helperText,
            prefix: prefix,
            suffix: suffix,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon != null
                ? InkWell(
                    onTap: onSuffixIconTap,
                    child: Icon(suffixIcon, color: AppColors.textSecondary),
                  )
                : null,
            contentPadding: effectiveContentPadding,
            filled: true,
            fillColor: enabled
                ? AppColors.cardBackground
                : AppColors.cardBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
