import 'package:flutter/material.dart';

import '../../../main/network/drone_pilot_model.dart';
import '../../../main/network/mock_drone_pilot_api.dart';
import '../../../portfolio/ui/pages/portfolio_page.dart';

part '../component/feed_component.dart';


const _navy = Color(0xFF1F3F68);
const _ink = Color(0xFF172338);
const _muted = Color(0xFF718096);
const _soft = Color(0xFFF3F6FA);
const _line = Color(0xFFE4EAF2);

class FeedText {
  static const TextStyle eyebrow = TextStyle(
    fontFamily: 'Pretendard',
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.6,
  );

  static const TextStyle feedLocation = TextStyle(
    fontFamily: 'Pretendard',
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const TextStyle authorName = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.15,
  );

  static const TextStyle authorRole = TextStyle(
    fontFamily: 'Pretendard',
    color: _muted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.55,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle metaPill = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.1,
  );

  static const TextStyle likeCount = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle comment = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
  );

  static const TextStyle commentUser = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle input = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: -0.1,
  );
}

void _openPortfolio(BuildContext context, DronePilot pilot) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PilotPortfolioPage(pilot: pilot)),
  );
}
