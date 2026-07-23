import 'package:flutter/material.dart';

import '../d_tokens.dart';

enum ModeCardVariant {
  /// White surface + hairline border + soft colored shadow. Used for
  /// portfolio/quote panels.
  elevated,

  /// White/surface + hairline border, no shadow. Used for list-row cards.
  flatBordered,

  /// Soft-filled background + hairline border, no shadow. Used for
  /// empty-state panels.
  softFilled,

  /// Same as [flatBordered] but animates and highlights when [selected].
  /// Used for selectable category tiles.
  selectable,
}

/// Shared card/panel primitive covering the four recurring `Container`-based
/// "card" shapes found across the view layer.
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.child,
    this.variant = ModeCardVariant.flatBordered,
    this.padding,
    this.radius,
    this.onTap,
    this.selected = false,
  });

  final Widget child;
  final ModeCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final VoidCallback? onTap;
  final bool selected;

  BoxDecoration _decoration() {
    final double r = radius ?? (variant == ModeCardVariant.elevated ? 14 : DC.rxLg);
    switch (variant) {
      case ModeCardVariant.elevated:
        return BoxDecoration(
          color: DC.canvas,
          borderRadius: BorderRadius.circular(r),
          border: Border.all(color: DC.hairline),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: DC.navy.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        );
      case ModeCardVariant.softFilled:
        return BoxDecoration(
          color: DC.surfaceSoft,
          borderRadius: BorderRadius.circular(r),
          border: Border.all(color: DC.hairline),
        );
      case ModeCardVariant.selectable:
        return BoxDecoration(
          color: selected ? DC.surfaceStrong : DC.canvas,
          borderRadius: BorderRadius.circular(r),
          border: Border.all(
            color: selected ? DC.primary : DC.hairline,
            width: selected ? 1.5 : 1,
          ),
        );
      case ModeCardVariant.flatBordered:
        return BoxDecoration(
          color: DC.canvas,
          borderRadius: BorderRadius.circular(r),
          border: Border.all(color: DC.hairline),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double r = radius ?? (variant == ModeCardVariant.elevated ? 14 : DC.rxLg);
    final Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: _decoration(),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: content,
      ),
    );
  }
}
