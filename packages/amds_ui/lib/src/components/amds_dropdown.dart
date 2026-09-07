// AMDS v1.0 · Dropdown / Select — single choice from a list, field presentation.
// See docs/component-library/design-specs.md (Inputs › Dropdown).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class AmdsDropdown<T> extends StatelessWidget {
  const AmdsDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelOf,
    this.label,
    this.hint = 'Select',
    this.required = false,
    this.errorText,
    super.key,
  });

  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) labelOf;
  final String? label;
  final String hint;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: AmdsTextStyles.labelSmall.copyWith(color: c.textSecondary),
              children: required
                  ? [
                      TextSpan(
                        text: '  (required)',
                        style: AmdsTextStyles.labelSmall
                            .copyWith(color: c.textTertiary),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: AmdsSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: c.textTertiary)),
          icon: Icon(Icons.expand_more, color: c.onSurfaceVariant),
          borderRadius: AmdsRadius.brMd,
          style: context.text.bodyLarge?.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: c.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AmdsSpacing.md, vertical: AmdsSpacing.sm),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: AmdsRadius.brMd,
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AmdsRadius.brMd,
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AmdsRadius.brMd,
              borderSide: BorderSide(
                  color: c.borderFocus, width: AmdsBorderWidth.thick),
            ),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
