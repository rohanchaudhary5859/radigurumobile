import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final String? prefixText;
  final String? suffixText;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final Color? fillColor;
  final bool filled;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final bool isDense;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool expands;
  final bool showCursor;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enableInteractiveSelection;
  final TextDirection? textDirection;
  final String obscuringCharacter;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? Function(String?)? onSaved;

  const TextInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.prefixIconData,
    this.suffixIcon,
    this.suffixIconData,
    this.prefixText,
    this.suffixText,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = false,
    this.errorText,
    this.helperText,
    this.counterText,
    this.isDense = true,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.expands = false,
    this.showCursor = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection = true,
    this.textDirection,
    this.obscuringCharacter = '•',
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      ),
    );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      autovalidateMode: autovalidateMode,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled ? null : theme.disabledColor,
      ),
      cursorColor: theme.primaryColor,
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(2),
      cursorHeight: 20,
      expands: expands,
      showCursor: showCursor,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      enableInteractiveSelection: enableInteractiveSelection,
      textDirection: textDirection,
      obscuringCharacter: obscuringCharacter,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      scrollController: scrollController,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon ?? (prefixIconData != null ? Icon(prefixIconData) : null),
        suffixIcon: suffixIcon ?? (suffixIconData != null ? Icon(suffixIconData) : null),
        prefixText: prefixText,
        suffixText: suffixText,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border ?? defaultBorder,
        enabledBorder: enabledBorder ?? defaultBorder,
        focusedBorder: focusedBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2,
              ),
            ),
        errorBorder: errorBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
        focusedErrorBorder: focusedErrorBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
        fillColor: fillColor ?? (isDark ? Colors.grey[900] : Colors.grey[50]),
        filled: filled || isDark,
        errorText: errorText,
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
        helperText: helperText,
        helperStyle: theme.textTheme.bodySmall,
        counterText: counterText,
        isDense: isDense,
        errorMaxLines: 2,
        helperMaxLines: 2,
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
