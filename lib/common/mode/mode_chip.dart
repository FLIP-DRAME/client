import 'package:flutter/material.dart';

import '../../feat/main/network/quote_status.dart';
import '../d_tokens.dart';

enum ModeChipShape { pill, rounded }

/// Shared chip/pill/badge primitive — covers the ~15 bespoke chip classes
/// found across the view layer (status chips, filter chips, category tags).
class ModeChip extends StatelessWidget {
  const ModeChip({
    super.key,
    required this.label,
    this.icon,
    required this.background,
    required this.foreground,
    this.shape = ModeChipShape.pill,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final ModeChipShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          shape == ModeChipShape.pill ? DC.rxPill : DC.rxXs,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: DT.captionStrong.copyWith(
              color: foreground,
              letterSpacing: null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status pill resolving color from the single shared table in
/// [QuoteStatusHelper.statusColors] — replaces three previously independent
/// status-color mappings (`my_quotes_component.dart`,
/// `mobile_redesign_component.dart`, `job_request_map_component.dart`).
///
/// [status] is the already-localized label (e.g. from
/// [QuoteStatusHelper.clientLabel]), not the raw API status string.
class ModeStatusBadge extends StatelessWidget {
  const ModeStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = QuoteStatusHelper.statusColors(status);
    return ModeChip(label: status, background: bg, foreground: fg);
  }
}
