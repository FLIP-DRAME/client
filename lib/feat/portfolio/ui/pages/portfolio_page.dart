import 'package:flutter/material.dart';

import '../../../main/network/drone_pilot_model.dart';

part '../component/portfolio_component.dart';

const _navy = Color(0xFF1F3F68);
const _ink = Color(0xFF172338);
const _muted = Color(0xFF718096);
const _soft = Color(0xFFF3F6FA);
const _line = Color(0xFFE4EAF2);

class PilotPortfolioPage extends StatelessWidget {
  const PilotPortfolioPage({super.key, required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DRAME',
          style: TextStyle(color: _navy, fontWeight: FontWeight.w900),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, 0),
              child: _PageShell(
                top: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 980;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 7,
                                child: _PortfolioMain(pilot: pilot),
                              ),
                              const SizedBox(width: 32),
                              SizedBox(
                                width: 330,
                                child: _QuoteCard(pilot: pilot),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: <Widget>[
                              _PortfolioMain(pilot: pilot),
                              const SizedBox(height: 24),
                              _QuoteCard(pilot: pilot),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }
}
