// AMDS v1.0 · List Item / Row — the workhorse of list & settings screens.
// See docs/component-library/design-specs.md (Content › List Item).

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

/// A single row: optional leading widget, title (+ optional subtitle/overline),
/// optional trailing widget. Tappable rows get a press response and a button
/// role; provide [semanticLabel] when the visible text isn't self-describing.
class AmdsListItem extends StatelessWidget {
  const AmdsListItem({
    required this.title,
    this.overline,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool dense;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final vPad = dense ? AmdsSpacing.sm : AmdsSpacing.md;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overline != null)
          Text(
            overline!.toUpperCase(),
            style: AmdsTextStyles.overline.copyWith(color: c.textTertiary),
          ),
        Text(
          title,
          style: (dense ? context.text.bodyMedium : context.text.titleSmall)
              ?.copyWith(color: c.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AmdsTextStyles.bodySmall.copyWith(color: c.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    final Widget row = Container(
      constraints: const BoxConstraints(minHeight: AmdsSize.touchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: AmdsSpacing.md,
        vertical: vPad,
      ),
      color: selected ? c.primaryContainer.withValues(alpha: 0.5) : null,
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: c.onSurfaceVariant),
              child: leading!,
            ),
            const SizedBox(width: AmdsSpacing.md),
          ],
          Expanded(child: text),
          if (trailing != null) ...[
            const SizedBox(width: AmdsSpacing.sm),
            IconTheme.merge(
              data: IconThemeData(color: c.onSurfaceVariant),
              child: DefaultTextStyle.merge(
                style:
                    AmdsTextStyles.bodySmall.copyWith(color: c.textSecondary),
                child: trailing!,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null && onLongPress == null) return row;

    return AmdsPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 1,
      overlayColor: c.onSurface.withValues(alpha: AmdsOpacity.pressed),
      child: Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: row,
      ),
    );
  }
}

/// A hairline divider aligned to AMDS list metrics. [inset] indents past a
/// leading icon/avatar so it doesn't cut the whole row.
class AmdsDivider extends StatelessWidget {
  const AmdsDivider({this.inset = false, this.height = 1, super.key});

  final bool inset;
  final double height;

  @override
  Widget build(BuildContext context) => Divider(
        height: height,
        thickness: AmdsBorderWidth.hairline,
        color: context.amds.colors.divider,
        indent: inset ? AmdsSpacing.md + AmdsSize.iconLg + AmdsSpacing.md : 0,
      );
}

/// Wraps rows in a card with dividers between them — the standard grouped-list
/// look for settings and detail screens.
class AmdsListGroup extends StatelessWidget {
  const AmdsListGroup({
    required this.children,
    this.header,
    this.insetDividers = true,
    super.key,
  });

  final List<Widget> children;
  final String? header;
  final bool insetDividers;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AmdsSpacing.md, 0, AmdsSpacing.md, AmdsSpacing.xs),
            child: Text(
              header!.toUpperCase(),
              style: AmdsTextStyles.overline.copyWith(color: c.textTertiary),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: AmdsRadius.brLg,
            border: Border.all(color: c.border),
          ),
          child: ClipRRect(
            borderRadius: AmdsRadius.brLg,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) AmdsDivider(inset: insetDividers),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
