// AMDS v1.0 · Chip — compact, interactive descriptors. Distinct from
// AmdsStatusChip (read-only status). See docs/component-library/design-specs.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// A selectable / removable chip. For a set, use [AmdsFilterChips] (multi) or
/// [AmdsChoiceChips] (single).
class AmdsChip extends StatelessWidget {
  const AmdsChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.leadingIcon,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final IconData? leadingIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final fg = !enabled
        ? c.textDisabled
        : selected
            ? c.onPrimaryContainer
            : c.textPrimary;
    final bg = selected ? c.primaryContainer : c.surface;

    return RawChip(
      label: Text(label),
      labelStyle: AmdsTextStyles.label.copyWith(color: fg),
      avatar: leadingIcon == null
          ? (selected ? Icon(Icons.check, size: 18, color: fg) : null)
          : Icon(leadingIcon, size: 18, color: fg),
      selected: selected,
      isEnabled: enabled,
      showCheckmark: false,
      onSelected: enabled ? onSelected : null,
      onDeleted: enabled ? onDeleted : null,
      deleteIcon: const Icon(Icons.close, size: 18),
      deleteIconColor: fg,
      backgroundColor: bg,
      selectedColor: c.primaryContainer,
      disabledColor: c.surfaceVariant,
      side: BorderSide(
        color: selected ? Colors.transparent : c.border,
        width: AmdsBorderWidth.hairline,
      ),
      shape: const StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      padding: const EdgeInsets.symmetric(
          horizontal: AmdsSpacing.xs, vertical: AmdsSpacing.xs),
    );
  }
}

/// Multi-select chip set. [selected] is the current set; [onChanged] gets the
/// next set.
class AmdsFilterChips<T> extends StatelessWidget {
  const AmdsFilterChips({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelOf,
    this.iconOf,
    super.key,
  });

  final List<T> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final String Function(T) labelOf;
  final IconData? Function(T)? iconOf;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AmdsSpacing.xs,
        runSpacing: AmdsSpacing.xs,
        children: [
          for (final o in options)
            AmdsChip(
              label: labelOf(o),
              leadingIcon: iconOf?.call(o),
              selected: selected.contains(o),
              onSelected: (on) {
                final next = {...selected};
                on ? next.add(o) : next.remove(o);
                onChanged(next);
              },
            ),
        ],
      );
}

/// Single-select chip set (radio semantics, chip presentation).
class AmdsChoiceChips<T> extends StatelessWidget {
  const AmdsChoiceChips({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.labelOf,
    super.key,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AmdsSpacing.xs,
        runSpacing: AmdsSpacing.xs,
        children: [
          for (final o in options)
            AmdsChip(
              label: labelOf(o),
              selected: o == value,
              onSelected: (on) => onChanged(on ? o : null),
            ),
        ],
      );
}
