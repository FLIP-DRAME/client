import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'd_tokens.dart';

// ── DrameTopNavigation ────────────────────────────────────────────────────────
//
// 64 px top bar (Coinbase-style).
//   • Left   : 모드 wordmark (brand blue)
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
    this.isOperatorRegistered = true,
    this.nickname,
    this.activePage,
    required this.onLoginTap,
    required this.onRegisterPilotTap,
    required this.onLogoTap,
    required this.onFindPilotTap,
    this.onFeedTap,
    this.onPortfolioTap,
    this.onRequestsTap,
    this.onMyPageTap,
    this.onMyQuotesTap,
    this.onSwitchToUser,
    this.onSwitchToOperator,
  });

  final bool isLoggedIn;
  final bool isOperator;
  final bool isOperatorRegistered;
  final String? nickname;

  /// 'find' | 'feed' | 'portfolio' | 'quotes' — highlights active link in user nav
  final String? activePage;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterPilotTap;
  final VoidCallback onLogoTap;
  final VoidCallback onFindPilotTap;
  final VoidCallback? onFeedTap;
  final VoidCallback? onPortfolioTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onMyPageTap;
  final VoidCallback? onMyQuotesTap;
  final VoidCallback? onSwitchToUser;
  final VoidCallback? onSwitchToOperator;

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
                  if (isLoggedIn && !isOperator) ...<Widget>[
                    _NavLink(
                      label: '운용자 찾기',
                      onTap: onFindPilotTap,
                      active: activePage == 'find',
                    ),
                    const SizedBox(width: 24),
                    _NavLink(
                      label: '피드',
                      onTap: onFeedTap ?? () {},
                      active: activePage == 'feed',
                    ),
                    const SizedBox(width: 24),
                    _NavLink(
                      label: '포트폴리오',
                      onTap: onPortfolioTap ?? () {},
                      active: activePage == 'portfolio',
                    ),
                  ] else ...<Widget>[
                    _NavLink(label: '촬영자 찾기', onTap: onFindPilotTap),
                    const SizedBox(width: 24),
                    _NavLink(label: '서비스 소개', onTap: onFindPilotTap),
                    const SizedBox(width: 24),
                    _NavLink(label: '기사 등록', onTap: onRegisterPilotTap),
                  ],
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
                  if (!isOperatorRegistered) ...<Widget>[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onRegisterPilotTap,
                      icon: const Icon(Icons.verified_outlined, size: 16),
                      label: const Text('운용자 등록하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B2B),
                        foregroundColor: Colors.white,
                        textStyle: DT.navLink.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  _ModeToggle(
                    isOperator: true,
                    onUserTap: onSwitchToUser ?? () {},
                    onOperatorTap: onSwitchToOperator ?? () {},
                  ),
                ] else ...<Widget>[
                  if (!compact)
                    TextButton(
                      onPressed: onMyQuotesTap,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            activePage == 'quotes' ? DC.primary : DC.ink,
                        textStyle: DT.navLink,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('내 견적'),
                    ),
                  if (!compact) const SizedBox(width: 8),
                  _ModeToggle(
                    isOperator: false,
                    onUserTap: onSwitchToUser ?? () {},
                    onOperatorTap: onSwitchToOperator ?? () {},
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

/// Reusable wordmark. [size] sets icon height; text scales from it.
/// [onDark] flips colors for dark-background panels.
/// [showText] controls whether "모드" label is shown (default true).
class DrameLogo extends StatelessWidget {
  const DrameLogo({
    super.key,
    this.size = 28,
    this.onDark = false,
    this.showText = true,
  });

  final double size;
  final bool onDark;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          'assets/logo_not_text.svg',
          height: size,
          width: size * 1.45,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            onDark ? Colors.white : DC.primary,
            BlendMode.srcIn,
          ),
        ),
        if (showText) ...<Widget>[
          SizedBox(width: size * 0.25),
          Text(
            '모드',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: size * 0.65,
              fontWeight: FontWeight.w800,
              color: onDark ? Colors.white : DC.ink,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ],
      ],
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
      child: const DrameLogo(size: 40, showText: false),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.active ? DC.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 120),
            style: DT.titleSm.copyWith(
              color: active ? DC.ink : DC.body,
              fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isOperator,
    required this.onUserTap,
    required this.onOperatorTap,
  });

  final bool isOperator;
  final VoidCallback onUserTap;
  final VoidCallback onOperatorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DC.surfaceStrong,
        borderRadius: BorderRadius.circular(DC.rxPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ToggleTab(label: '이용자', active: !isOperator, onTap: onUserTap),
          _ToggleTab(label: '운용자', active: isOperator, onTap: onOperatorTap),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(DC.rxPill),
          boxShadow:
              active
                  ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: DT.navLink.copyWith(
            color: active ? DC.ink : DC.muted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
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
              style: DT.titleSm.copyWith(
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
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
