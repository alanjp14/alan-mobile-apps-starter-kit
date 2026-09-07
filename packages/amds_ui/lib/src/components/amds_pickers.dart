// AMDS v1.0 · Date & Time fields — a read-only field that opens the platform
// picker (Material on Android, adaptive on iOS) and shows the formatted value.
// See docs/component-library/design-specs.md (Inputs › Date/Time Picker).

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.valueText,
    required this.icon,
    required this.onTap,
    required this.hint,
    this.required = false,
    this.errorText,
    this.onClear,
  });

  final String label;
  final String? valueText;
  final IconData icon;
  final VoidCallback onTap;
  final String hint;
  final bool required;
  final String? errorText;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final hasValue = valueText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        InkWell(
          onTap: onTap,
          borderRadius: AmdsRadius.brMd,
          child: InputDecorator(
            isEmpty: !hasValue,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              filled: true,
              fillColor: c.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AmdsSpacing.md, vertical: AmdsSpacing.sm + 2),
              prefixIcon: Icon(icon, color: c.onSurfaceVariant),
              suffixIcon: hasValue && onClear != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: AmdsSize.iconSm,
                      tooltip: 'Clear',
                      onPressed: onClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AmdsRadius.brMd,
                borderSide: BorderSide(color: c.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AmdsRadius.brMd,
                borderSide: BorderSide(color: c.border),
              ),
            ),
            child: hasValue
                ? Text(valueText!, style: context.text.bodyLarge)
                : null,
          ),
        ),
      ],
    );
  }
}

class AmdsDateField extends StatelessWidget {
  const AmdsDateField({
    required this.value,
    required this.onChanged,
    this.label = 'Date',
    this.firstDate,
    this.lastDate,
    this.format,
    this.required = false,
    this.errorText,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime)? format;
  final bool required;
  final String? errorText;

  String _fmt(DateTime d) =>
      format?.call(d) ?? '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}';
  static String _pad2(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final v = value;
    return _PickerField(
      label: label,
      hint: 'Select date',
      required: required,
      errorText: errorText,
      icon: Icons.calendar_today_outlined,
      valueText: v == null ? null : _fmt(v),
      onClear: () => onChanged(null),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(now.year - 5),
          lastDate: lastDate ?? DateTime(now.year + 5),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

class AmdsTimeField extends StatelessWidget {
  const AmdsTimeField({
    required this.value,
    required this.onChanged,
    this.label = 'Time',
    this.required = false,
    this.errorText,
    super.key,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  final String label;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      label: label,
      hint: 'Select time',
      required: required,
      errorText: errorText,
      icon: Icons.schedule,
      valueText: value?.format(context),
      onClear: () => onChanged(null),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
