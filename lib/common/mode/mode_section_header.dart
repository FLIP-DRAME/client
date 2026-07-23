import 'package:flutter/material.dart';

import '../d_tokens.dart';
import 'mode_text.dart';

/// Shared section header (optional eyebrow + title + optional trailing
/// action) — replaces `_SectionHeader` and its ad hoc re-implementations.
class ModeSectionHeader extends StatelessWidget {
  const ModeSectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String? eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null) ...<Widget>[
                ModeSemiBoldText(eyebrow!, size: 13, color: DC.primary),
                const SizedBox(height: 4),
              ],
              ModeBoldText(title, size: 24, color: DC.ink),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
