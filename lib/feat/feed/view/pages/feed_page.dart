import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
import '../../../main/model/drone_pilot_model.dart';
import '../../../moderation/model/moderation_model.dart';
import '../../../moderation/view/component/report_block_menu.dart';
import '../../network/feed_api.dart';

part '../component/feed_component.dart';

const _navy = Color(0xFF0A0B0D);
const _ink = Color(0xFF0A0B0D);
const _muted = Color(0xFF7C828A);
const _soft = Color(0xFFF7F8FA);
// Matches DC.mapHairline exactly; kept as a private alias (rather than
// deleted per the usual migration rule) because feed_component.dart — a
// `part of` this library that this migration pass doesn't touch — references
// `_line` directly.
const _line = DC.mapHairline;

class FeedText {
  static const TextStyle eyebrow = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _navy,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.6,
  );

  static const TextStyle feedLocation = TextStyle(
    fontFamily: DT.fontFamily,
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle button = TextStyle(
    fontFamily: DT.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle authorName = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle authorRole = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.55,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle metaPill = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle likeCount = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle comment = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle commentUser = TextStyle(
    fontFamily: DT.fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle input = TextStyle(
    fontFamily: DT.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
}

void _openPortfolio(BuildContext context, DronePilot pilot) {
  context.push('/portfolio/${pilot.id}', extra: pilot);
}

Future<void> showFeedPostDialog(
  BuildContext context,
  FeedPost post, {
  required Future<DronePilot?> Function(String id) loadPilot,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (_) => _FeedPostDialog(
      post: _FeedPost.fromApi(post),
      loadPilot: loadPilot,
    ),
  );
}
