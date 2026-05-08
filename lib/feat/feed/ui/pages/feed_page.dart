import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/drame_text_styles.dart';
import '../../../main/network/drone_pilot_model.dart';
import '../../../main/network/mock_drone_pilot_api.dart';

part '../component/feed_component.dart';

const _navy = Color(0xFF1F3F68);
const _ink = Color(0xFF172338);
const _muted = Color(0xFF718096);
const _soft = Color(0xFFF3F6FA);
const _line = Color(0xFFE4EAF2);

class FeedText {
  static const TextStyle eyebrow = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.labelSize,
    fontWeight: DrameTextStyles.semiBold,
    height: 1.35,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _navy,
    fontSize: DrameTextStyles.sectionTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.28,
    letterSpacing: -0.2,
  );

  static const TextStyle feedLocation = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.white,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.semiBold,
    height: 1.35,
  );

  static const TextStyle button = DrameTextStyles.button;

  static const TextStyle authorName = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.semiBold,
    height: 1.35,
  );

  static const TextStyle authorRole = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.labelSize,
    fontWeight: DrameTextStyles.medium,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.55,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.itemTitleSize,
    fontWeight: DrameTextStyles.semiBold,
    height: 1.35,
  );

  static const TextStyle metaPill = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.labelSize,
    fontWeight: DrameTextStyles.medium,
    height: 1.25,
  );

  static const TextStyle likeCount = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.35,
  );

  static const TextStyle comment = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.45,
  );

  static const TextStyle commentUser = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    fontWeight: DrameTextStyles.semiBold,
  );

  static const TextStyle input = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.3,
  );
}

void _openPortfolio(BuildContext context, DronePilot pilot) {
  context.push('/portfolio/${pilot.id}', extra: pilot);
}
