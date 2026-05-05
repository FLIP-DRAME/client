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

void _openPortfolio(BuildContext context, DronePilot pilot) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PilotPortfolioPage(pilot: pilot)),
  );
}
