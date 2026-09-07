// AMDS v1.0 · Text Field + Password Field. See
// docs/component-library/design-specs.md B1/B2. The visual style comes from the
// themed InputDecorationTheme in amds_tokens; this adds the always-visible label,
// required marker, and helper/error handling.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmdsTextField extends StatelessWidget {
  const AmdsTextField({
    required this.label,
    this.controller,
    this.onChanged,
    this.helper,
    this.error,
    this.hint,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onFieldSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? helper;
  final String? error;
  final String? hint;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Returns an error string, or null when valid. Runs inside an enclosing
  /// [Form]. Compose with `Validators.all([...])` from `amds_core`.
  final String? Function(String value)? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: required ? '$label, required' : label,
          child: ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                text: label,
                style: AmdsTextStyles.label
                    .copyWith(color: hasError ? c.danger : c.textSecondary),
                children: required
                    ? [
                        TextSpan(
                            text: '  (required)',
                            style: AmdsTextStyles.labelSmall
                                .copyWith(color: c.textTertiary))
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: AmdsSpacing.xxs),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          validator: validator == null ? null : (v) => validator!(v ?? ''),
          style: AmdsTextStyles.bodyLarge.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: AmdsSize.iconSm)
                : null,
            suffixIcon: suffix,
            // an explicit `error` prop wins; otherwise the validator drives it
            errorText: hasError ? error : null,
            helperText: hasError ? null : helper,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// Text field with a show/hide toggle.
class AmdsPasswordField extends StatefulWidget {
  const AmdsPasswordField({
    required this.label,
    this.controller,
    this.onChanged,
    this.helper,
    this.error,
    this.required = false,
    this.autofillHint = AutofillHints.password,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? helper;
  final String? error;
  final bool required;
  final String autofillHint;
  final TextInputAction? textInputAction;
  final String? Function(String value)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AmdsPasswordField> createState() => _AmdsPasswordFieldState();
}

class _AmdsPasswordFieldState extends State<AmdsPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AmdsTextField(
      label: widget.label,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      helper: widget.helper,
      error: widget.error,
      required: widget.required,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [widget.autofillHint],
      validator: widget.validator,
      suffix: IconButton(
        icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: AmdsSize.iconSm),
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
