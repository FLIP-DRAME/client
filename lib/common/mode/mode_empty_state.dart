import 'package:flutter/material.dart';

import '../d_tokens.dart';
import 'mode_button.dart';
import 'mode_text.dart';

/// Shared empty-state panel (icon + title + optional subtitle/CTA) —
/// replaces 6 near-identical hand-rolled `_Empty*` classes.
class ModeEmptyState extends StatelessWidget {
  const ModeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 48, color: DC.muted),
          const SizedBox(height: 16),
          ModeSemiBoldText(title, size: 16, color: DC.ink, textAlign: TextAlign.center),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 8),
            ModeText(
              subtitle!,
              size: 14,
              color: DC.body,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 20),
            ModeButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
