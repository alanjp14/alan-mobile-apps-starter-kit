// AMDS v1.0 · small components — Icon Button, Chip, Badge, Avatar, Section Header,
// Banner. See docs/component-library/design-specs.md.

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/material.dart';

enum AmdsStatusTone { neutral, success, warning, danger, info }

extension AmdsStatusToneX on AmdsStatusTone {
  ({Color fg, Color bg}) resolve(AmdsColors c) => switch (this) {
        AmdsStatusTone.neutral => (fg: c.textSecondary, bg: c.surfaceVariant),
        AmdsStatusTone.success => (fg: c.onSuccessContainer, bg: c.successContainer),
        AmdsStatusTone.warning => (fg: c.onWarningContainer, bg: c.warningContainer),
        AmdsStatusTone.danger => (fg: c.onDangerContainer, bg: c.dangerContainer),
        AmdsStatusTone.info => (fg: c.onInfoContainer, bg: c.infoContainer),
      };

  IconData get icon => switch (this) {
        AmdsStatusTone.neutral => Icons.info_outline,
        AmdsStatusTone.success => Icons.check_circle_outline,
        AmdsStatusTone.warning => Icons.warning_amber_rounded,
        AmdsStatusTone.danger => Icons.error_outline,
        AmdsStatusTone.info => Icons.info_outline,
      };
}

class AmdsIconButton extends StatelessWidget {
  const AmdsIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tone,
    this.size = AmdsSize.iconMd,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    return IconButton(
      icon: Icon(icon, size: size),
      color: tone ?? c.onSurfaceVariant,
      tooltip: semanticLabel,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: AmdsSize.touchTarget, minHeight: AmdsSize.touchTarget),
      style: IconButton.styleFrom(
        highlightColor: c.onSurface.withValues(alpha: AmdsOpacity.pressed),
      ),
    );
  }
}

/// A status chip — text is the source of truth, colour is secondary.
class AmdsStatusChip extends StatelessWidget {
  const AmdsStatusChip(this.label, {this.tone = AmdsStatusTone.neutral, this.showIcon = true, super.key});

  final String label;
  final AmdsStatusTone tone;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final c = tone.resolve(context.amds.colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AmdsSpacing.xs, vertical: 3),
      decoration: BoxDecoration(color: c.bg, borderRadius: AmdsRadius.brFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[Icon(tone.icon, size: 14, color: c.fg), const SizedBox(width: 4)],
          Text(label, style: AmdsTextStyles.labelSmall.copyWith(color: c.fg)),
        ],
      ),
    );
  }
}

/// Count / dot badge wrapping a host widget.
class AmdsBadge extends StatelessWidget {
  const AmdsBadge({required this.child, this.count, this.showDot = false, this.tone = AmdsStatusTone.danger, super.key});

  final Widget child;
  final int? count;
  final bool showDot;
  final AmdsStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;
    final t = tone.resolve(c);
    final label = count == null ? null : (count! > 99 ? '99+' : '$count');
    if (label == null && !showDot) return child;
    return Badge(
      backgroundColor: tone == AmdsStatusTone.danger ? c.danger : t.fg,
      label: label == null ? null : Text(label, style: AmdsTextStyles.labelSmall.copyWith(color: c.textOnColor)),
      smallSize: 8,
      child: child,
    );
  }
}

class AmdsAvatar extends StatelessWidget {
  const AmdsAvatar({required this.name, this.imageUrl, this.size = AmdsSize.avatarMd, this.onTap, super.key});

  final String name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Color _bgFor(BuildContext context) {
    // deterministic tint from the name — always dark enough for white text
    const tints = [Color(0xFF15803D), Color(0xFF0369A1), Color(0xFF475569), Color(0xFFB45309), Color(0xFFB91C1C)];
    return tints[name.hashCode.abs() % tints.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(context))
            : _fallback(context),
      ),
    );
    final wrapped = onTap == null
        ? avatar
        : GestureDetector(onTap: onTap, child: Semantics(button: true, label: 'Change photo', child: avatar));
    return Semantics(label: name, image: true, child: wrapped);
  }

  Widget _fallback(BuildContext context) => ColoredBox(
        color: _bgFor(context),
        child: Center(
          child: Text(
            _initials,
            style: AmdsTextStyles.titleMedium.copyWith(color: Colors.white, fontSize: size * 0.36),
          ),
        ),
      );
}

class AmdsSectionHeader extends StatelessWidget {
  const AmdsSectionHeader(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AmdsSpacing.sm, top: AmdsSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(label.toUpperCase(), style: AmdsTextStyles.overline.copyWith(color: context.amds.colors.textSecondary)),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Screen-level inline alert. See design-specs.md D6.
class AmdsBanner extends StatelessWidget {
  const AmdsBanner({
    required this.message,
    this.tone = AmdsStatusTone.info,
    this.action,
    this.onActionPressed,
    this.onDismiss,
    super.key,
  });

  final String message;
  final AmdsStatusTone tone;
  final String? action;
  final VoidCallback? onActionPressed;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = tone.resolve(context.amds.colors);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AmdsSpacing.md, vertical: AmdsSpacing.sm),
        decoration: BoxDecoration(color: c.bg, borderRadius: AmdsRadius.brMd),
        child: Row(
          children: [
            Icon(tone.icon, size: AmdsSize.iconSm, color: c.fg),
            const SizedBox(width: AmdsSpacing.sm),
            Expanded(child: Text(message, style: AmdsTextStyles.bodyMedium.copyWith(color: c.fg))),
            if (action != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(action!, style: AmdsTextStyles.label.copyWith(color: c.fg)),
              ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, size: AmdsSize.iconSm, color: c.fg),
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
