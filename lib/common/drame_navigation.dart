import 'package:flutter/material.dart';

import 'drame_text_styles.dart';

const _primary = Color(0xFF0052FF);
const _toggle = Color(0xFF293341);
const _ink = Color(0xFF111111);
const _muted = Color(0xFF667085);
const _soft = Color(0xFFF7F8FA);
const _line = Color(0xFFE5E7EB);

class DrameTopNavigation extends StatelessWidget {
  const DrameTopNavigation({
    super.key,
    required this.isPilotMode,
    required this.onModeChanged,
    required this.onLoginTap,
    required this.onRegisterTap,
    this.onLogoTap,
  });

  final bool isPilotMode;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;
  final VoidCallback? onLogoTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Container(
      height: compact ? 68 : 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: onLogoTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Drame',
                      style: TextStyle(
                        fontFamily: DrameTextStyles.fontFamily,
                        color: _ink,
                        fontSize: DrameTextStyles.logoSize,
                        fontWeight: DrameTextStyles.bold,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (!compact) ...<Widget>[
                  _DrameModeToggle(
                    isPilotMode: isPilotMode,
                    onChanged: onModeChanged,
                  ),
                  const SizedBox(width: 14),
                ],
                TextButton(
                  onPressed: onLoginTap,
                  style: TextButton.styleFrom(
                    textStyle: DrameTextStyles.label,
                    foregroundColor: _ink,
                  ),
                  child: const Text('로그인 / 회원가입'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onRegisterTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    textStyle: DrameTextStyles.labelStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                  ),
                  child: const Text('운용자 등록'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrameSecondaryNavigation extends StatelessWidget {
  const DrameSecondaryNavigation({
    super.key,
    required this.isPilotMode,
    required this.onFindPilotTap,
    required this.onPortfolioTap,
    this.onRequestsTap,
    this.onMyPageTap,
  });

  final bool isPilotMode;
  final VoidCallback onFindPilotTap;
  final VoidCallback onPortfolioTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onMyPageTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final tabs =
        isPilotMode
            ? <({IconData icon, String label, VoidCallback onTap})>[
              (
                icon: Icons.description_outlined,
                label: '요청 확인하기',
                onTap: onRequestsTap ?? () {},
              ),
              (
                icon: Icons.account_circle_outlined,
                label: '마이페이지',
                onTap: onMyPageTap ?? () {},
              ),
            ]
            : <({IconData icon, String label, VoidCallback onTap})>[
              (
                icon: Icons.person_search_rounded,
                label: '촬영자 찾기',
                onTap: onFindPilotTap,
              ),
              (
                icon: Icons.grid_view_rounded,
                label: '포트폴리오',
                onTap: onPortfolioTap,
              ),
            ];

    return Container(
      height: compact ? 58 : 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
              child: Row(
                children:
                    tabs
                        .map(
                          (tab) => Padding(
                            padding: const EdgeInsets.only(right: 34),
                            child: DrameSubNavTab(
                              icon: tab.icon,
                              label: tab.label,
                              onTap: tab.onTap,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrameSubNavTab extends StatelessWidget {
  const DrameSubNavTab({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _muted,
        textStyle: DrameTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _DrameModeToggle extends StatelessWidget {
  const _DrameModeToggle({required this.isPilotMode, required this.onChanged});

  final bool isPilotMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _DrameModeToggleItem(
            label: '이용자',
            selected: !isPilotMode,
            onTap: () => onChanged(false),
          ),
          _DrameModeToggleItem(
            label: '운용자',
            selected: isPilotMode,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _DrameModeToggleItem extends StatelessWidget {
  const _DrameModeToggleItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _toggle : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: DrameTextStyles.label.copyWith(
            color: selected ? Colors.white : _muted,
            fontWeight: DrameTextStyles.semiBold,
          ),
        ),
      ),
    );
  }
}
