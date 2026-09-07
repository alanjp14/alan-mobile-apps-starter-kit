// AMDS v1.0 · selection controls — Checkbox, Radio, Switch (+ their labelled
// "tile" forms) and Slider. All expose the right role/state to a11y and keep a
// ≥44dp target. See docs/component-library/design-specs.md (Inputs).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// Bare checkbox. Prefer [AmdsCheckboxTile] when there's a label.
class AmdsCheckbox extends StatelessWidget {
  const AmdsCheckbox({
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.semanticLabel,
    super.key,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Semantics(
      label: semanticLabel,
      child: Checkbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
        activeColor: c.primary,
        checkColor: c.onPrimary,
        side: BorderSide(color: c.borderStrong, width: AmdsBorderWidth.thin),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Checkbox + label in a tappable row (the whole row toggles).
class AmdsCheckboxTile extends StatelessWidget {
  const AmdsCheckboxTile({
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    this.tristate = false,
    super.key,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final String? description;
  final bool tristate;

  @override
  Widget build(BuildContext context) => _SelectionTile(
        leading: AmdsCheckbox(
          value: value,
          tristate: tristate,
          onChanged: onChanged,
        ),
        label: label,
        description: description,
        selected: value ?? false,
        onTap: onChanged == null
            ? null
            : () => onChanged!(tristate ? _cycle(value) : !(value ?? false)),
      );

  static bool? _cycle(bool? v) => switch (v) {
        false => true,
        true => null,
        null => false,
      };
}

/// A single-choice group. Wrap [AmdsRadioTile]s (or bare [Radio]s) in this and
/// it manages selection — no `groupValue` threading per option.
///
/// ```dart
/// AmdsRadioGroup<Plan>(
///   groupValue: plan,
///   onChanged: (v) => setState(() => plan = v!),
///   children: [
///     for (final p in Plan.values)
///       AmdsRadioTile(value: p, label: p.name),
///   ],
/// )
/// ```
class AmdsRadioGroup<T> extends StatelessWidget {
  const AmdsRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required this.children,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RadioGroup<T>(
        groupValue: groupValue,
        onChanged: onChanged ?? (_) {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}

/// One option inside an [AmdsRadioGroup].
class AmdsRadioTile<T> extends StatelessWidget {
  const AmdsRadioTile({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
    super.key,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final group = RadioGroup.maybeOf<T>(context);
    final selected = group?.groupValue == value;
    return _SelectionTile(
      leading: Radio<T>(
        value: value,
        enabled: enabled,
        activeColor: c.primary,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      label: label,
      description: description,
      selected: selected,
      onTap: !enabled || group == null ? null : () => group.onChanged(value),
    );
  }
}

/// Switch + label row. Use for "apply immediately" settings (not form fields).
class AmdsSwitchTile extends StatelessWidget {
  const AmdsSwitchTile({
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return _SelectionTile(
      label: label,
      description: description,
      selected: value,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: c.onPrimary,
        activeTrackColor: c.primary,
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.selected,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String label;
  final bool selected;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Semantics(
      container: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AmdsRadius.brMd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AmdsSize.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) leading!,
                if (leading != null) const SizedBox(width: AmdsSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: context.text.bodyLarge),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: AmdsTextStyles.bodySmall
                              .copyWith(color: c.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AmdsSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Labelled slider with an optional live value readout.
class AmdsSlider extends StatelessWidget {
  const AmdsSlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.valueLabel,
    super.key,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double)? valueLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Row(
            children: [
              Expanded(
                child: Text(label!, style: context.text.labelLarge),
              ),
              if (valueLabel != null)
                Text(
                  valueLabel!(value),
                  style:
                      AmdsTextStyles.bodySmall.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: c.primary,
          inactiveColor: c.surfaceVariant,
          label: valueLabel?.call(value),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
