import 'package:flutter/material.dart';

import '../d_tokens.dart';

/// Shared circular avatar — replaces ~28 raw
/// `Container(decoration: BoxDecoration(shape: BoxShape.circle, ...))`
/// call sites that reimplemented `CircleAvatar` by hand.
class ModeAvatar extends StatelessWidget {
  const ModeAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.fallbackIcon = Icons.person,
  });

  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: DC.surfaceStrong,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: DC.surfaceStrong,
        child: Text(
          fallbackText![0].toUpperCase(),
          style: TextStyle(
            fontFamily: DT.fontFamily,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: DC.body,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: DC.surfaceStrong,
      child: Icon(fallbackIcon, size: radius, color: DC.muted),
    );
  }
}
