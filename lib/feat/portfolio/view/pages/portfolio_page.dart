import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/drame_text_styles.dart';
import '../../../../common/login_prompt.dart';
import '../../../main/model/drone_pilot_model.dart';
import '../../../main/model/main_models.dart';
import '../../../quote/model/quote_model.dart';

part '../component/portfolio_component.dart';

const _ink = Colors.black;
const _muted = Colors.black;
const _soft = Color(0xFFF7F8FA);
const _line = Color(0xFFE4EAF2);
const _primary = Color(0xFF0052FF);
const _mutedGray = Color(0xFF7C828A);
const _navy = Color(0xFF0A0B0D);
const _bgBeige = Color(0xFFF0F0EB);
const _mintGreen = Color(0xFF22C58B);

void _openQuoteRequest(BuildContext context, DronePilot pilot) {
  _showMobileQuoteSheet(context, pilot);
}

class PortfolioText {
  static const TextStyle logo = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: 18,
    fontWeight: DrameTextStyles.bold,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static const TextStyle profileName = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.pageTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle profileMeta = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.35,
  );

  static const TextStyle profileDescription = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.cardTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.65,
  );

  static const TextStyle quoteTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.cardTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle quoteBody = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle button = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.white,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.bold,
    letterSpacing: -0.1,
  );

  static const TextStyle quoteLabel = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: 12,
    fontWeight: DrameTextStyles.regular,
    height: 1.4,
  );

  static const TextStyle quoteValue = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.4,
  );

  static const TextStyle reviewName = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.bold,
    height: 1.3,
  );

  static const TextStyle reviewBody = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _muted,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle rating = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: _ink,
    fontSize: 28,
    fontWeight: DrameTextStyles.bold,
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
        title: const Text('모두의 드론', style: PortfolioText.logo),
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
