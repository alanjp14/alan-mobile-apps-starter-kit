// AMDS v1.0 · Button. Built on Material buttons for correct focus / keyboard /
// hover / semantics, with an AMDS press-scale on top.
// See docs/component-library/design-specs.md A1 + api-reference.md §1.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

enum AmdsButtonVariant {
  primary,
  secondary,
  tertiary,
  tonal,
  destructive,
  destructiveText
}

enum AmdsButtonSize { sm, md, lg }

class AmdsButton extends StatefulWidget {
  const AmdsButton({
    required this.label,
    required this.onPressed,
    this.variant = AmdsButtonVariant.primary,
    this.size = AmdsButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AmdsButtonVariant variant;
  final AmdsButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;
  final String? semanticLabel;
  final bool autofocus;

  @override
  State<AmdsButton> createState() => _AmdsButtonState();
}

class _AmdsButtonState extends State<AmdsButton> {
  final WidgetStatesController _states = WidgetStatesController();
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(() {
      final p = _states.value.contains(WidgetState.pressed);
      if (p != _pressed) setState(() => _pressed = p);
    });
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  double get _minHeight => switch (widget.size) {
        AmdsButtonSize.sm => AmdsSize.buttonHeightSm,
        AmdsButtonSize.md => AmdsSize.buttonHeightMd,
        AmdsButtonSize.lg => AmdsSize.buttonHeightLg,
      };

  double get _iconSize => switch (widget.size) {
        AmdsButtonSize.sm => AmdsSize.iconXs,
        AmdsButtonSize.md => AmdsSize.iconSm,
        AmdsButtonSize.lg => AmdsSize.iconMd,
      };

  TextStyle get _textStyle => switch (widget.size) {
        AmdsButtonSize.sm => AmdsTextStyles.labelSmall,
        AmdsButtonSize.md => AmdsTextStyles.label,
        AmdsButtonSize.lg => AmdsTextStyles.titleMedium,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final enabled = widget.onPressed != null && !widget.loading;

    final ({Color bg, Color fg, Color? outline, bool tinted}) v =
        switch (widget.variant) {
      AmdsButtonVariant.primary => (
          bg: c.primary,
          fg: c.onPrimary,
          outline: null,
          tinted: false
        ),
      AmdsButtonVariant.secondary => (
          bg: Colors.transparent,
          fg: c.primary,
          outline: c.primary,
          tinted: false
        ),
      AmdsButtonVariant.tertiary => (
          bg: Colors.transparent,
          fg: c.primary,
          outline: null,
          tinted: false
        ),
      AmdsButtonVariant.tonal => (
          bg: c.primaryContainer,
          fg: c.onPrimaryContainer,
          outline: null,
          tinted: true
        ),
      AmdsButtonVariant.destructive => (
          bg: c.danger,
          fg: c.textOnColor,
          outline: null,
          tinted: false
        ),
      AmdsButtonVariant.destructiveText => (
          bg: Colors.transparent,
          fg: c.danger,
          outline: null,
          tinted: false
        ),
    };

    final overlay = v.fg.withValues(alpha: AmdsOpacity.pressed);
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(
          widget.fullWidth ? double.infinity : AmdsSize.touchTarget,
          _minHeight)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
            horizontal: widget.size == AmdsButtonSize.sm
                ? AmdsSpacing.sm
                : AmdsSpacing.md),
      ),
      shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AmdsRadius.brMd)),
      textStyle: WidgetStatePropertyAll(_textStyle),
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.disabled)) {
          return v.bg == Colors.transparent ? null : c.disabled;
        }
        return v.bg == Colors.transparent ? null : v.bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? v.fg.withValues(alpha: AmdsOpacity.disabled)
            : v.fg,
      ),
      overlayColor: WidgetStatePropertyAll(overlay),
      side: v.outline == null
          ? null
          : WidgetStateProperty.resolveWith(
              (s) => BorderSide(
                color:
                    s.contains(WidgetState.disabled) ? c.disabled : v.outline!,
                width: 1,
              ),
            ),
      elevation: widget.variant == AmdsButtonVariant.primary ||
              widget.variant == AmdsButtonVariant.destructive
          ? WidgetStateProperty.resolveWith<double>(
              (s) => s.contains(WidgetState.pressed) ? 0.0 : 1.0)
          : const WidgetStatePropertyAll<double>(0),
      shadowColor: const WidgetStatePropertyAll<Color>(Color(0xFF0F172A)),
    );

    final child = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: CircularProgressIndicator(strokeWidth: 2, color: v.fg))
        else if (widget.leadingIcon != null)
          Icon(widget.leadingIcon, size: _iconSize),
        if (widget.loading || widget.leadingIcon != null)
          const SizedBox(width: AmdsSpacing.xs),
        Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
        if (widget.trailingIcon != null && !widget.loading) ...[
          const SizedBox(width: AmdsSpacing.xs),
          Icon(widget.trailingIcon, size: _iconSize),
        ],
      ],
    );

    final onPressed = enabled ? widget.onPressed : null;
    final filled = v.bg != Colors.transparent;
    final button = filled
        ? FilledButton(
            onPressed: onPressed,
            statesController: _states,
            style: style,
            autofocus: widget.autofocus,
            child: child)
        : v.outline != null
            ? OutlinedButton(
                onPressed: onPressed,
                statesController: _states,
                style: style,
                autofocus: widget.autofocus,
                child: child)
            : TextButton(
                onPressed: onPressed,
                statesController: _states,
                style: style,
                autofocus: widget.autofocus,
                child: child);

    // The Material button already provides button role, focus, keyboard
    // activation, and its accessible name from the child Text. Only override the
    // name when a caller passes an explicit semanticLabel.
    Widget result = widget.semanticLabel == null
        ? button
        : Semantics(
            label: widget.semanticLabel,
            button: true,
            enabled: enabled,
            excludeSemantics: true,
            child: button);

    result = AnimatedScale(
      scale: (_pressed && !reduce) ? 0.96 : 1.0,
      duration: _pressed ? AmdsMotion.instant : AmdsMotion.fast,
      curve: _pressed ? AmdsMotion.standard : AmdsMotion.spring,
      child: result,
    );

    if (widget.fullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }
    return result;
  }
}
