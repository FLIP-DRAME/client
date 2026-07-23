import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/login_prompt.dart';
import '../../../../common/mode/mode.dart';
import '../../../main/model/drone_pilot_model.dart';
import '../../../main/model/main_models.dart';
import '../../../feed/network/feed_api.dart';
import '../../../feed/view/pages/feed_page.dart';
import '../../../quote/model/quote_model.dart';

part '../component/portfolio_component.dart';

const _ink = Colors.black;
const _muted = Colors.black;
const _soft = Color(0xFFF7F8FA);
// Matches DC.mapHairline exactly; kept as a private alias (rather than
// deleted per the usual migration rule) because portfolio_component.dart —
// a `part of` this library that this migration pass doesn't touch —
// references `_line` directly.
const _line = DC.mapHairline;
const _primary = Color(0xFF0052FF);
const _mutedGray = Color(0xFF7C828A);
const _navy = Color(0xFF0A0B0D);
const _bgBeige = Color(0xFFF0F0EB);
const _mintGreen = Color(0xFF22C58B);

void _openQuoteRequest(BuildContext context, DronePilot pilot) {
  _showMobileQuoteSheet(context, pilot);
}

class PortfolioText {
  static const TextStyle profileName = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle profileMeta = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle profileDescription = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static const TextStyle quoteTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle quoteBody = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle button = TextStyle(
    fontFamily: DT.fontFamily,
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static const TextStyle quoteLabel = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle quoteValue = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle reviewName = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle reviewBody = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle rating = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );
}

class PilotPortfolioPage extends StatelessWidget {
  const PilotPortfolioPage({super.key, required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    if (compact) return _MobilePortfolioScaffold(pilot: pilot);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const ModeBoldText(
          '모두의 드론',
          size: 18,
          color: _ink,
          height: 1.2,
          letterSpacing: -0.2,
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _PageShell(
              top: 44,
              bottom: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _PortfolioMain(pilot: pilot)),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 300,
                    child: _QuoteCard(pilot: pilot),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
