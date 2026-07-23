import 'package:flutter/material.dart';

import '../d_tokens.dart';

enum ModeButtonVariant { primary, secondary, outlineOnDark, ghost }

enum ModeButtonSize { md, lg }

/// Shared button primitive wrapping the button-style factories already
/// defined in `d_tokens.dart` (`dPrimaryButtonStyle`, `dSecondaryButtonStyle`,
/// `dOutlineOnDarkButtonStyle`, `dGhostButtonStyle`) — those were written but
/// had zero call sites before this component existed.
class ModeButton extends StatelessWidget {
  const ModeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ModeButtonVariant.primary,
    this.size = ModeButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ModeButtonVariant variant;
  final ModeButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  ButtonStyle _style() {
    final bool lg = size == ModeButtonSize.lg;
    return switch (variant) {
      ModeButtonVariant.primary =>
        lg ? dPrimaryButtonStyleLg() : dPrimaryButtonStyle(),
      ModeButtonVariant.secondary => dSecondaryButtonStyle(
        height: lg ? 56 : 44,
      ),
      ModeButtonVariant.outlineOnDark =>
        lg ? dOutlineOnDarkButtonStyleLg() : dOutlineOnDarkButtonStyle(),
      ModeButtonVariant.ghost => dGhostButtonStyle(),
    };
  }

  Color _spinnerColor() => switch (variant) {
    ModeButtonVariant.primary => DC.onPrimary,
    ModeButtonVariant.secondary => DC.ink,
    ModeButtonVariant.outlineOnDark => DC.onDark,
    ModeButtonVariant.ghost => DC.primary,
  };

  @override
  Widget build(BuildContext context) {
    final Widget child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _spinnerColor(),
            ),
          )
        : icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      ModeButtonVariant.outlineOnDark => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: _style(),
        child: child,
      ),
      ModeButtonVariant.ghost => TextButton(
        onPressed: loading ? null : onPressed,
        style: _style(),
        child: child,
      ),
      ModeButtonVariant.primary || ModeButtonVariant.secondary => ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: _style(),
        child: child,
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
