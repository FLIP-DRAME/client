import 'package:flutter/material.dart';

import 'd_tokens.dart';

// ── DrameTopNavigation ────────────────────────────────────────────────────────
//
// 64 px top bar (Coinbase-style).
//   • Left   : DRANE wordmark (brand blue)
//   • Center : nav links — only on desktop
//   • Right  : context CTAs
//               - guest  : [로그인] [시작하기 →]
//               - user   : [내 견적 (N)] [닉네임 ▼]
//               - operator: [요청 관리] [닉네임 ▼]
//
class DrameTopNavigation extends StatelessWidget {
  const DrameTopNavigation({
    super.key,
    required this.isLoggedIn,
    required this.isOperator,
    this.nickname,
    this.quoteCount = 0,
    required this.onLoginTap,
    required this.onRegisterPilotTap,
    required this.onLogoTap,
    required this.onFindPilotTap,
    this.onQuoteTap,
    this.onRequestsTap,
    this.onMyPageTap,
  });

  final bool isLoggedIn;
  final bool isOperator;
  final String? nickname;
  final int quoteCount;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterPilotTap;
  final VoidCallback onLogoTap;
  final VoidCallback onFindPilotTap;
  final VoidCallback? onQuoteTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onMyPageTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 768;

    return Container(
      height: DC.navHeight,
      decoration: const BoxDecoration(
        color: DC.canvas,
        border: Border(bottom: BorderSide(color: DC.hairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth + 48),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
            child: Row(
              children: <Widget>[
                // ── Logo ────────────────────────────────────────────────────
                _Logo(onTap: onLogoTap),

                // ── Center nav links (desktop only) ─────────────────────────
                if (!compact) ...<Widget>[
                  const SizedBox(width: 40),
                  _NavLink(label: '촬영자 찾기', onTap: onFindPilotTap),
                  const SizedBox(width: 24),
                  _NavLink(label: '서비스 소개', onTap: onFindPilotTap),
                  const SizedBox(width: 24),
                  _NavLink(label: '기사 등록', onTap: onRegisterPilotTap),
                ],

                const Spacer(),

                // ── Right CTAs ───────────────────────────────────────────────
                if (!isLoggedIn) ...<Widget>[
                  TextButton(
                    onPressed: onLoginTap,
                    style: TextButton.styleFrom(
                      foregroundColor: DC.ink,
                      textStyle: DT.navLink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('로그인'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onRegisterPilotTap,
                    style: dPrimaryButtonStyle(),
                    child: const Text('시작하기'),
                  ),
                ] else if (isOperator) ...<Widget>[
                  if (!compact)
                    TextButton(
                      onPressed: onRequestsTap,
                      style: TextButton.styleFrom(
                        foregroundColor: DC.ink,
                        textStyle: DT.navLink,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('요청 관리'),
                    ),
                  const SizedBox(width: 8),
                  _AccountChip(
                    nickname: nickname ?? '기사님',
                    onTap: onMyPageTap ?? () {},
                  ),
                ] else ...<Widget>[
                  if (!compact && quoteCount > 0)
                    _QuoteBadgeButton(
                      count: quoteCount,
                      onTap: onQuoteTap ?? () {},
                    ),
                  if (!compact && quoteCount > 0) const SizedBox(width: 8),
                  _AccountChip(
                    nickname: nickname ?? '이용자',
                    onTap: onMyPageTap ?? () {},
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Text(
        'Mode Drone',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: DC.primary,
          letterSpacing: -0.4,
          height: 1,
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: DT.navLink.copyWith(color: _hovered ? DC.ink : DC.body),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.nickname, required this.onTap});

  final String nickname;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: DC.surfaceStrong,
          borderRadius: BorderRadius.circular(DC.rxPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(nickname, style: DT.navLink.copyWith(color: DC.ink)),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: DC.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteBadgeButton extends StatelessWidget {
  const _QuoteBadgeButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: DC.hairline),
          borderRadius: BorderRadius.circular(DC.rxPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('내 견적', style: DT.navLink.copyWith(color: DC.ink)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: DC.primary,
                borderRadius: BorderRadius.circular(DC.rxPill),
              ),
              child: Text(
                '$count',
                style: DT.captionStrong.copyWith(color: DC.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DrameTabNav ──────────────────────────────────────────────────────────────
//
// Context-aware secondary tab bar (48 px).
//   • Guest / user browsing : category filter tabs
//   • Operator (logged in)  : 대시보드 | 요청 관리 | 피드 | 내 프로필
//
class DrameTabNav extends StatelessWidget {
  const DrameTabNav({
    super.key,
    required this.isOperator,
    required this.selectedId,
    required this.onTabChanged,
    this.tabs,
  });

  final bool isOperator;
  final String selectedId;
  final ValueChanged<String> onTabChanged;

  // Custom tab list; falls back to defaults when null.
  final List<DrameTab>? tabs;

  static const List<DrameTab> _userTabs = <DrameTab>[
    DrameTab(id: 'all', label: '전체'),
    DrameTab(id: 'aerial', label: '항공촬영'),
    DrameTab(id: 'spray', label: '농약방제'),
    DrameTab(id: 'estate', label: '부동산'),
    DrameTab(id: 'mapping', label: '측량·매핑'),
    DrameTab(id: 'inspection', label: '시설점검'),
    DrameTab(id: 'event', label: '행사촬영'),
  ];

  static const List<DrameTab> _operatorTabs = <DrameTab>[
    DrameTab(id: 'dashboard', label: '대시보드'),
    DrameTab(id: 'requests', label: '요청 관리'),
    DrameTab(id: 'feed', label: '피드'),
    DrameTab(id: 'profile', label: '내 프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 768;
    final effectiveTabs = tabs ?? (isOperator ? _operatorTabs : _userTabs);

    return Container(
      height: DC.tabHeight,
      decoration: const BoxDecoration(
        color: DC.canvas,
        border: Border(bottom: BorderSide(color: DC.hairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth + 48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
            child: Row(
              children:
                  effectiveTabs
                      .map(
                        (t) => _TabItem(
                          tab: t,
                          selected: selectedId == t.id,
                          onTap: () => onTabChanged(t.id),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class DrameTab {
  const DrameTab({required this.id, required this.label});

  final String id;
  final String label;
}

class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final DrameTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: DC.tabHeight,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          margin: const EdgeInsets.only(right: 28),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selected ? DC.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              style: DT.navLink.copyWith(
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                color: widget.selected ? DC.ink : (_hovered ? DC.ink : DC.body),
              ),
              child: Text(widget.tab.label),
            ),
          ),
        ),
      ),
    );
  }
}
