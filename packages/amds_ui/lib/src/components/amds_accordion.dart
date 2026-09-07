// AMDS v1.0 · Accordion / Disclosure — a titled, expandable region.
// See docs/component-library/design-specs.md (Content › Accordion).

import 'package:amds_motion/amds_motion.dart';
import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

class AmdsAccordion extends StatefulWidget {
  const AmdsAccordion({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<AmdsAccordion> createState() => _AmdsAccordionState();
}

class _AmdsAccordionState extends State<AmdsAccordion>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final reduce = context.reduceMotion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          label: widget.title,
          child: InkWell(
            onTap: _toggle,
            borderRadius: AmdsRadius.brMd,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AmdsSize.touchTarget),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.sm),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: AmdsSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title, style: context.text.titleSmall),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(widget.subtitle!,
                                style: AmdsTextStyles.bodySmall
                                    .copyWith(color: c.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: reduce ? Duration.zero : AmdsMotion.fast,
                      curve: AmdsMotion.standard,
                      child: Icon(Icons.expand_more, color: c.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: AmdsSpacing.md),
            child: widget.child,
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: reduce ? Duration.zero : AmdsMotion.base,
          sizeCurve: AmdsMotion.standard,
          firstCurve: AmdsMotion.accelerate,
          secondCurve: AmdsMotion.decelerate,
        ),
      ],
    );
  }
}
