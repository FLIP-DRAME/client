part of '../pages/main_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Redesign – 모두의 드론 App Design v1 (2026-05-23)
// ─────────────────────────────────────────────────────────────────────────────

const _bgBeige = Color(0xFFF0F0EB);

// ─── Redesigned Mobile App Bar ────────────────────────────────────────────────

class _MobileNewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileNewAppBar({
    required this.store,
    required this.onLoginTap,
    required this.onModeChanged,
  });

  final DrameStore store;
  final VoidCallback onLoginTap;
  final ValueChanged<bool> onModeChanged;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          const DrameLogo(size: 26),
          const Spacer(),
          DrameModeSwitchButton(
            isOperator: store.isPilotMode,
            onUserTap: () => onModeChanged(false),
            onOperatorTap: () => onModeChanged(true),
          ),
          if (!store.isLoggedIn) ...<Widget>[
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: '로그인',
              child: InkWell(
                onTap: onLoginTap,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── User Home Tab (PDF p.2) ──────────────────────────────────────────────────

class _UserHomeTab extends StatefulWidget {
  const _UserHomeTab({required this.store});

  final DrameStore store;

  @override
  State<_UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<_UserHomeTab> {
  String _selectedCat = '전체';
  final PageController _pilotPageCtrl = PageController();
  int _pilotPage = 0;

  @override
  void dispose() {
    _pilotPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final allPilots = store.allPilots;
    final filtered =
        _selectedCat == '전체'
            ? allPilots
            : allPilots.where((p) => p.hasCategory(_selectedCat)).toList();

    return ColoredBox(
      color: _bgBeige,
      child: CustomScrollView(
        slivers: <Widget>[
          // ── Category chip row ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: <Widget>[
                    _HomeCatChip(
                      label: '전체',
                      selected: _selectedCat == '전체',
                      onTap: () => setState(() => _selectedCat = '전체'),
                    ),
                    ...store.categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _HomeCatChip(
                          label: cat.label,
                          selected: _selectedCat == cat.label,
                          onTap: () => setState(() => _selectedCat = cat.label),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── How it works ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '3단계로 끝나는 드론 서비스',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '어떻게\n작동하나요?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0B0D),
                      height: 1.25,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardW = (constraints.maxWidth - 20) / 2.3;
                      return SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            _HowItWorksStepCard(
                              step: '01',
                              title: '견적 요청',
                              body: '지도에서 위치 선택 또는 운용자에게 직접 요청',
                              width: cardW,
                            ),
                            const SizedBox(width: 10),
                            _HowItWorksStepCard(
                              step: '02',
                              title: '기사 매칭',
                              body: '요청부터 일정 조율까지 연결',
                              width: cardW,
                            ),
                            const SizedBox(width: 10),
                            _HowItWorksStepCard(
                              step: '03',
                              title: '견적 확정',
                              body: '자격증과 포트폴리오 보고 선택',
                              width: cardW,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Job request map ─────────────────────────────────────────────────
          SliverToBoxAdapter(child: _JobRequestMapSection(store: store)),

          // ── Operator 2-per-page horizontal pager ──────────────────────────
          SliverToBoxAdapter(
            child:
                filtered.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          '해당 카테고리의 운용자가 없습니다.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Color(0xFF7C828A),
                          ),
                        ),
                      ),
                    )
                    : _OperatorPager(
                      pilots: filtered,
                      pageCtrl: _pilotPageCtrl,
                      currentPage: _pilotPage,
                      onPageChanged: (p) => setState(() => _pilotPage = p),
                      onTap: (pilot) {
                        store.selectPilot(pilot);
                        _openPortfolio(context, pilot);
                      },
                    ),
          ),

          // ── Category browse section ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '카테고리/지역별 서비스',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0B0D),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '원하는 분야와 지역의 드론 서비스를 찾아보세요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: Color(0xFF7C828A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 80,
                        ),
                    itemBuilder: (context, index) {
                      final cat = store.categories[index];
                      return GestureDetector(
                        onTap: () {
                          store.selectCategory(cat);
                          setState(() => _selectedCat = cat.label);
                          _showCategoryAreaSheet(context, store, cat);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE4EAF2)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF4FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cat.icon,
                                  size: 18,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cat.label,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0A0B0D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCatChip extends StatelessWidget {
  const _HomeCatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A0B0D) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF0A0B0D) : const Color(0xFFDEE1E6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF5B616E),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksStepCard extends StatelessWidget {
  const _HowItWorksStepCard({
    required this.step,
    required this.title,
    required this.body,
    this.width = 180,
  });

  final String step;
  final String title;
  final String body;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            step,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0B0D),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7C828A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Operator 2-per-page Horizontal Pager ────────────────────────────────────

class _OperatorPager extends StatelessWidget {
  const _OperatorPager({
    required this.pilots,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
  });

  final List<DronePilot> pilots;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<DronePilot> onTap;

  @override
  Widget build(BuildContext context) {
    final pageCount = (pilots.length / 2).ceil();

    return Column(
      children: <Widget>[
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              final a = pageIndex * 2;
              final b = a + 1;
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _OperatorCardCompact(
                        pilot: pilots[a],
                        onTap: () => onTap(pilots[a]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (b < pilots.length)
                      Expanded(
                        child: _OperatorCardCompact(
                          pilot: pilots[b],
                          onTap: () => onTap(pilots[b]),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
          ),
        ),
        // Dot indicators
        if (pageCount > 1) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(pageCount, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? _primary : const Color(0xFFCDD7E8),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }
}

class _OperatorCardCompact extends StatelessWidget {
  const _OperatorCardCompact({required this.pilot, required this.onTap});

  final DronePilot pilot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = pilot.name.isNotEmpty ? pilot.name[0].toUpperCase() : '?';
    final area = pilot.primaryDisplayArea;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4EAF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF0F3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B616E),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _mint,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        pilot.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0B0D),
                          letterSpacing: -0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (area.isNotEmpty)
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.location_on_outlined,
                              size: 10,
                              color: Color(0xFF7C828A),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                area,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 11,
                                  color: Color(0xFF5B616E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  pilot.categories
                      .take(2)
                      .map(
                        (cat) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile Operator Card (PDF p.2 style) ─────────────────────────────────────

class _MobileOperatorCard extends StatelessWidget {
  const _MobileOperatorCard({required this.pilot, required this.onTap});

  final DronePilot pilot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = pilot.name.isNotEmpty ? pilot.name[0].toUpperCase() : '?';
    final area = pilot.primaryDisplayArea;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4EAF2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  width: 46,
                  height: 46,
                  child: ClipOval(
                    child:
                        pilot.avatarUrl?.trim().isNotEmpty == true
                            ? Image.network(
                              pilot.avatarUrl!,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _MobileAvatarFallback(
                                    initial: initial,
                                  ),
                            )
                            : _MobileAvatarFallback(initial: initial),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          pilot.name,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0B0D),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFA8ACB3),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      if (area.isNotEmpty) ...<Widget>[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF7C828A),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            area,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: Color(0xFF5B616E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        pilot.categories
                            .take(3)
                            .map((cat) => _CatBadge(label: cat))
                            .toList(),
                  ),
                  if (pilot.intro.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      pilot.intro,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: Color(0xFF7C828A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileAvatarFallback extends StatelessWidget {
  const _MobileAvatarFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEEF0F3),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5B616E),
          ),
        ),
      ),
    );
  }
}

class _CatBadge extends StatelessWidget {
  const _CatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
      ),
    );
  }
}

// ─── User My Page Tab (PDF p.9) ───────────────────────────────────────────────

class _UserMyPageTab extends StatelessWidget {
  const _UserMyPageTab({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final name =
        store.accountNickname.isNotEmpty
            ? store.accountNickname
            : store.accountName.isNotEmpty
            ? store.accountName
            : '이용자';
    final email = store.accountEmail;
    final received = store.myQuotes.where((q) => q.isQuoteReceived).length;
    final inProgress = store.myQuotes.where((q) => q.isInProgress).length;

    return ColoredBox(
      color: _bgBeige,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Top bar ───────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: const Text(
                '내 정보',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0B0D),
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // ── Profile card ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF0F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B616E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0B0D),
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: Color(0xFF7C828A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats row ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: <Widget>[
                  _UserStatBox(value: '$received', label: '견적 받음'),
                  const SizedBox(width: 8),
                  _UserStatBox(value: '$inProgress', label: '진행중'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Operator registration CTA ──────────────────────────────────
            if (!store.operatorRegistrationCompleted) ...<Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: GestureDetector(
                  onTap: () => context.push('/pilot/register'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flight,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '드론 운용자로 등록하기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _primary,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                '전문 기사로 활동하고 수익을 만들어요',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  color: Color(0xFF5B616E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // ── Service menu ───────────────────────────────────────────────
            _MobileMenuSection(
              title: '서비스',
              items: <_MobileMenuItem>[
                _MobileMenuItem(
                  label: '내 견적',
                  onTap: () => context.go('/my/quotes'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Account menu ───────────────────────────────────────────────
            _MobileMenuSection(
              title: '계정',
              items: <_MobileMenuItem>[
                _MobileMenuItem(
                  label: '개인정보처리방침',
                  onTap: () => context.push('/privacy'),
                ),
                _MobileMenuItem(
                  label: '차단 관리',
                  onTap: () => context.push('/blocked-users'),
                ),
                _MobileMenuItem(
                  label: '로그아웃',
                  isDestructive: true,
                  onTap: () async {
                    await store.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
                _MobileMenuItem(
                  label: '계정 삭제',
                  isDestructive: true,
                  onTap: () => _showAccountDeletionDialog(context, store),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _UserStatBox extends StatelessWidget {
  const _UserStatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEF0F3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0B0D),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Color(0xFF7C828A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileMenuSection extends StatelessWidget {
  const _MobileMenuSection({required this.title, required this.items});

  final String title;
  final List<_MobileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C828A),
                letterSpacing: 0.2,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          item.isDestructive
                              ? const Color(0xFFE53935)
                              : const Color(0xFF0A0B0D),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color:
                        item.isDestructive
                            ? const Color(0xFFE53935).withAlpha(120)
                            : const Color(0xFFA8ACB3),
                    size: 18,
                  ),
                  onTap: item.onTap,
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFEEF0F3),
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

void _showAccountDeletionDialog(BuildContext context, DrameStore store) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _AccountDeletionDialog(store: store),
  );
}

class _AccountDeletionDialog extends StatefulWidget {
  const _AccountDeletionDialog({required this.store});
  final DrameStore store;

  @override
  State<_AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<_AccountDeletionDialog> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        '계정 삭제',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A0B0D),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            '계정을 삭제하면 다음 데이터가 즉시 삭제됩니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: Color(0xFF4B5058),
              height: 1.5,
            ),
          ),
          SizedBox(height: 10),
          _DeletionBullet('프로필, 이미지, 포트폴리오'),
          _DeletionBullet('피드 게시글 및 댓글'),
          _DeletionBullet('푸시 알림 토큰'),
          SizedBox(height: 10),
          Text(
            '거래 및 견적 기록은 전자상거래법에 따라 최대 5년 보관 후 파기됩니다. 이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Color(0xFF7C828A),
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFF7C828A),
            ),
          ),
        ),
        FilledButton(
          onPressed:
              _deleting
                  ? null
                  : () async {
                    setState(() => _deleting = true);
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);
                    try {
                      await widget.store.deleteAccount();
                      if (mounted) {
                        nav.pop();
                        router.go('/');
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _deleting = false);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: const Color(0xFFE53935),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          child:
              _deleting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('계정 삭제'),
        ),
      ],
    );
  }
}

class _DeletionBullet extends StatelessWidget {
  const _DeletionBullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: <Widget>[
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFFE53935), fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF4B5058),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMenuItem {
  const _MobileMenuItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

// ─── Mobile My Quotes Tab (PDF p.4/5 – replaces 채팅) ─────────────────────────

class _MobileMyQuotesTab extends StatefulWidget {
  const _MobileMyQuotesTab({required this.store});

  final DrameStore store;

  @override
  State<_MobileMyQuotesTab> createState() => _MobileMyQuotesTabState();
}

class _MobileMyQuotesTabState extends State<_MobileMyQuotesTab> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    if (!store.isLoggedIn) {
      return ColoredBox(
        color: _bgBeige,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Color(0xFFA8ACB3),
              ),
              const SizedBox(height: 16),
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A0B0D),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('로그인'),
              ),
            ],
          ),
        ),
      );
    }

    final all = store.myQuotes;
    final received = all.where((q) => q.isQuoteReceived).toList();
    final pending = all.where((q) => q.isPending).toList();
    final completed = all.where((q) => q.isCompleted).toList();
    final filtered =
        _filter == 1
            ? received
            : _filter == 2
            ? pending
            : _filter == 3
            ? completed
            : all;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '내 견적',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0B0D),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _QuoteFilterTab(
                        label: '전체 ${all.length}',
                        selected: _filter == 0,
                        onTap: () => setState(() => _filter = 0),
                      ),
                      const SizedBox(width: 8),
                      _QuoteFilterTab(
                        label: '견적받음 ${received.length}',
                        selected: _filter == 1,
                        onTap: () => setState(() => _filter = 1),
                      ),
                      const SizedBox(width: 8),
                      _QuoteFilterTab(
                        label: '대기중 ${pending.length}',
                        selected: _filter == 2,
                        onTap: () => setState(() => _filter = 2),
                      ),
                      if (completed.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        _QuoteFilterTab(
                          label: '완료 ${completed.length}',
                          selected: _filter == 3,
                          onTap: () => setState(() => _filter = 3),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: Colors.white,
              child:
                  filtered.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: Color(0xFFA8ACB3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '견적 내역이 없습니다',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7C828A),
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final q = filtered[index];
                          return _MobileQuoteStatusCard(
                            quote: q,
                            onTap: () => _onQuoteTap(context, q),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQuoteTap(BuildContext context, UserQuoteSummary quote) {
    if (quote.isQuoteReceived) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _QuoteEstimateSheet(quote: quote),
      );
      return;
    }
    if (quote.pilotId.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MobileQuoteEditSheet(quote: quote),
    );
  }
}

class _QuoteFilterTab extends StatelessWidget {
  const _QuoteFilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A0B0D) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF0A0B0D) : const Color(0xFFE4EAF2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF5B616E),
          ),
        ),
      ),
    );
  }
}

class _MobileQuoteStatusCard extends StatelessWidget {
  const _MobileQuoteStatusCard({required this.quote, required this.onTap});

  final UserQuoteSummary quote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = quote.status;
    final statusStyle = _statusStyle(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4EAF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusStyle.$2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusStyle.$1,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  quote.date,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: Color(0xFFA8ACB3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              quote.category,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0B0D),
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Color(0xFF7C828A),
                ),
                const SizedBox(width: 2),
                Text(
                  _cleanArea(quote.area).replaceFirst(' · ', ''),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    color: Color(0xFF5B616E),
                  ),
                ),
                if (quote.price.isNotEmpty && quote.price != '0') ...<Widget>[
                  const Text(' · ', style: TextStyle(color: Color(0xFFA8ACB3))),
                  Text(
                    quote.price,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0B0D),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                if (quote.pilotName.isNotEmpty) ...<Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF0F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        quote.pilotName[0],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B616E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    quote.pilotName.isNotEmpty
                        ? quote.pilotName
                        : status == '요청 보냄'
                        ? '운용자 검토 중'
                        : '',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          status == '요청 보냄'
                              ? _primary
                              : const Color(0xFF0A0B0D),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA8ACB3),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _statusStyle(String status) {
    switch (status) {
      case '견적 받음':
        return (const Color(0xFF0052FF), const Color(0xFFEEF4FF));
      case '진행중':
        return (const Color(0xFF05B169), const Color(0xFFE8F9F1));
      default:
        return (const Color(0xFF7C828A), const Color(0xFFF7F8FA));
    }
  }
}

class _QuoteEstimateSheet extends StatelessWidget {
  const _QuoteEstimateSheet({required this.quote});

  final UserQuoteSummary quote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '견적서',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0B0D),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SheetInfoRow(label: '서비스', value: quote.category),
          _SheetInfoRow(label: '지역', value: quote.area),
          if (quote.pilotName.isNotEmpty)
            _SheetInfoRow(label: '운용자', value: quote.pilotName),
          if (quote.price.isNotEmpty && quote.price != '0')
            _SheetInfoRow(
              label: '견적 금액',
              value: quote.price,
              isHighlight: true,
            ),
          if (quote.message.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            const Text(
              '운용자 메모',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C828A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quote.message,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: Color(0xFF0A0B0D),
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInfoRow extends StatelessWidget {
  const _SheetInfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF7C828A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isHighlight ? 18 : 14,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: const Color(0xFF0A0B0D),
                letterSpacing: isHighlight ? -0.2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Operator Dashboard Tab (PDF p.10) ────────────────────────────────────────

class _OperatorDashboardTab extends StatelessWidget {
  const _OperatorDashboardTab({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final nickname =
        store.accountNickname.isNotEmpty
            ? store.accountNickname
            : store.accountName;
    final pilot = store.selectedPilot;
    final requests = store.pilotWorkRequests;
    final newCount = requests.where((r) => r.status == '신규').length;

    return ColoredBox(
      color: _bgBeige,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header + profile card ──────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: nickname,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A0B0D),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const TextSpan(
                          text: ' 운용자 페이지',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0B0D),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '프로필과 요청 현황을 한 곳에서 관리하세요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: Color(0xFF7C828A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE4EAF2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF0F3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      nickname.isNotEmpty
                                          ? nickname[0].toUpperCase()
                                          : 'O',
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF5B616E),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 1,
                                  right: 1,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _mint,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    nickname,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0A0B0D),
                                    ),
                                  ),
                                  if (store.operatorRegistrationCompleted &&
                                      pilot != null &&
                                      pilot.categories.isNotEmpty)
                                    Text(
                                      pilot.categories.take(3).join(' · '),
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        color: Color(0xFF7C828A),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  _MobileOperatorStatusChip(store: store),
                                ],
                              ),
                            ),
                            if (store.operatorRegistrationCompleted)
                              TextButton.icon(
                                onPressed: () => context.go('/operator/mypage'),
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: const Text('등록 정보'),
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  foregroundColor: const Color(0xFF5B616E),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child:
                              store.operatorRegistrationCompleted
                                  ? OutlinedButton(
                                    onPressed:
                                        () => context.go('/operator/mypage'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0A0B0D),
                                      side: const BorderSide(
                                        color: Color(0xFFE4EAF2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text('내 소개 편집'),
                                  )
                                  : FilledButton(
                                    onPressed:
                                        () => context.push('/pilot/register'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: const Text('운용자 등록하기'),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Stats row ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _OpStatCard(
                      label: '받은 요청',
                      value: '${requests.length}',
                      sub: newCount > 0 ? '신규 $newCount건' : null,
                      subColor: _primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OpStatCard(
                      label: '총 수락',
                      value:
                          '${requests.where((r) => r.status == '수락').length}',
                      sub: '누적 수락 건수',
                      subColor: const Color(0xFF7C828A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Received requests carousel ─────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          '받은 요청',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A0B0D),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (requests.isNotEmpty)
                        Semantics(
                          button: true,
                          label: '받은 요청 ${requests.length}건',
                          child: InkWell(
                            onTap: () => context.push('/operator/requests'),
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '${requests.length}건 대기 중',
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    color: Color(0xFF7C828A),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFA8ACB3),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (requests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4EAF2)),
                      ),
                      child: const Center(
                        child: Text(
                          '아직 받은 요청이 없습니다',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Color(0xFF7C828A),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 185,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final req = requests[i];
                          return _RequestTile(
                            request: req,
                            onTap:
                                () => context.push(
                                  '/operator/requests',
                                  extra: req,
                                ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _OpStatCard extends StatelessWidget {
  const _OpStatCard({
    required this.label,
    required this.value,
    this.sub,
    this.subColor,
  });

  final String label;
  final String value;
  final String? sub;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4EAF2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Color(0xFF7C828A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A0B0D),
              letterSpacing: -0.4,
            ),
          ),
          if (sub != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subColor ?? const Color(0xFF7C828A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request, required this.onTap});

  final PilotWorkRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isReviewing = request.status == '신규' || request.status == '확인 중';
    final isQuoteSent = request.status == '견적 보냄';
    final badgeColor =
        isReviewing
            ? const Color(0xFF05B169)
            : isQuoteSent
            ? _primary
            : const Color(0xFF7C828A);
    final badgeBg =
        isReviewing
            ? const Color(0xFFEBFAF3)
            : isQuoteSent
            ? const Color(0xFFEEF4FF)
            : const Color(0xFFF7F7F7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 162,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isReviewing ? _primary : const Color(0xFFE4EAF2),
            width: isReviewing ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.displayLocation,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5B616E),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.category,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0B0D),
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.budget,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Color(0xFF5B616E),
              ),
            ),
            Text(
              request.dateRange,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Color(0xFF5B616E),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('응답하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Operator My Page Mobile Tab ──────────────────────────────────────────────

class _OperatorMyPageMobileTab extends StatelessWidget {
  const _OperatorMyPageMobileTab({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final name = store.accountName.isEmpty ? '운용자' : store.accountName;
    final nickname =
        store.accountNickname.isEmpty ? name : store.accountNickname;
    final email = store.accountEmail;

    return ColoredBox(
      color: _bgBeige,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Top bar ───────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: const Text(
                '내 정보',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0B0D),
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // ── Profile header ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF0F3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            nickname.isNotEmpty
                                ? nickname[0].toUpperCase()
                                : 'O',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5B616E),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _mint,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0B0D),
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: Color(0xFF7C828A),
                            ),
                          ),
                        const SizedBox(height: 6),
                        _MobileOperatorStatusChip(store: store),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _MobileMenuSection(
              title: '운용자 관리',
              items: <_MobileMenuItem>[
                _MobileMenuItem(
                  label: '포트폴리오 편집',
                  onTap: () => _openOperatorPortfolio(context, store),
                ),
                _MobileMenuItem(
                  label: '피드 관리',
                  onTap: () => context.go('/operator/feed'),
                ),
                _MobileMenuItem(
                  label: '등록 정보 수정',
                  onTap: () => context.go('/operator/mypage'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _MobileMenuSection(
              title: '계정',
              items: <_MobileMenuItem>[
                _MobileMenuItem(
                  label: '차단 관리',
                  onTap: () => context.push('/blocked-users'),
                ),
                _MobileMenuItem(
                  label: '로그아웃',
                  onTap: () async {
                    await store.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
                _MobileMenuItem(
                  label: '계정 삭제',
                  onTap: () => context.go('/delete-account'),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile Quote Edit Sheet ───────────────────────────────────────────────────

class _MobileQuoteEditSheet extends ConsumerStatefulWidget {
  const _MobileQuoteEditSheet({required this.quote});

  final UserQuoteSummary quote;

  @override
  ConsumerState<_MobileQuoteEditSheet> createState() =>
      _MobileQuoteEditSheetState();
}

class _MobileQuoteEditSheetState extends ConsumerState<_MobileQuoteEditSheet> {
  late final TextEditingController _dateController;
  late final TextEditingController _detailController;
  late final TextEditingController _contactController;
  late final TextEditingController _amountController;
  late String _budget;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.quote;
    _dateController = TextEditingController(text: q.date);
    _detailController = TextEditingController(text: q.detail);
    _contactController = TextEditingController(text: q.contactWindow);
    _amountController = TextEditingController();
    _budget = q.budgetRange.isNotEmpty ? q.budgetRange : '0~30만원';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _detailController.dispose();
    _contactController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final effectiveBudget =
        _amountController.text.trim().isNotEmpty
            ? _amountController.text.trim()
            : _budget;
    try {
      final store = ref.read(drameStoreProvider);
      await store.updateMyQuoteRequest(
        requestId: widget.quote.id,
        category: widget.quote.category,
        area: widget.quote.area,
        preferredDate: _dateController.text.trim(),
        detail: _detailController.text.trim(),
        budgetRange: effectiveBudget,
        contactWindow: _contactController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('견적 요청을 수정했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${widget.quote.pilotName} 견적 수정',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0B0D),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.quote.category}${_cleanArea(widget.quote.area)}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF7C828A),
              ),
            ),
            const SizedBox(height: 20),
            _SheetEditField(label: '일정', controller: _dateController),
            const SizedBox(height: 12),
            _SheetEditField(
              label: '요청사항',
              controller: _detailController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SheetEditField(
              label: '견적 금액 (선택)',
              controller: _amountController,
              hint: _budget,
            ),
            const SizedBox(height: 12),
            const Text(
              '예산',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0B0D),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  <String>['0~30만원', '30~50만원', '50~100만원', '협의']
                      .map(
                        (v) => GestureDetector(
                          onTap: () => setState(() => _budget = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  v == _budget
                                      ? const Color(0xFF0A0B0D)
                                      : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    v == _budget
                                        ? const Color(0xFF0A0B0D)
                                        : const Color(0xFFE4EAF2),
                              ),
                            ),
                            child: Text(
                              v,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    v == _budget
                                        ? Colors.white
                                        : const Color(0xFF5B616E),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            _SheetEditField(label: '연락 가능 시간', controller: _contactController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(_saving ? '저장 중…' : '수정 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetEditField extends StatelessWidget {
  const _SheetEditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE4EAF2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE4EAF2)),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          color: Color(0xFF7C828A),
        ),
      ),
    );
  }
}

// ─── Category Area Bottom Sheet ───────────────────────────────────────────────

void _showCategoryAreaSheet(
  BuildContext context,
  DrameStore store,
  DroneCategory cat,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (_) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: _CategoryAreaSheet(category: cat, store: store),
        ),
  );
}

class _CategoryAreaSheet extends StatefulWidget {
  const _CategoryAreaSheet({required this.category, required this.store});

  final DroneCategory category;
  final DrameStore store;

  @override
  State<_CategoryAreaSheet> createState() => _CategoryAreaSheetState();
}

class _CategoryAreaSheetState extends State<_CategoryAreaSheet> {
  String? _selectedArea;

  List<DronePilot> get _filtered {
    var list =
        widget.store.allPilots
            .where((p) => p.hasCategory(widget.category.label))
            .toList();
    if (_selectedArea != null) {
      list =
          list.where((p) => p.availableAreas.contains(_selectedArea)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final areas = defaultServiceAreas.where((a) => a != '전체').toList();
    final districts =
        _selectedArea != null
            ? (defaultServiceDistricts[_selectedArea] ?? <String>[])
            : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDEE1E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF0A0B0D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.category.label} 서비스',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0B0D),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 시/도 chip row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              _AreaFilterChip(
                label: '전체',
                selected: _selectedArea == null,
                onTap: () => setState(() => _selectedArea = null),
              ),
              ...areas.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _AreaFilterChip(
                    label: a,
                    selected: _selectedArea == a,
                    onTap: () => setState(() => _selectedArea = a),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (districts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  districts
                      .map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDEE1E6),
                              ),
                            ),
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5B616E),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Divider(color: Color(0xFFE4EAF2), height: 1),
        ),
        Expanded(
          child:
              _filtered.isEmpty
                  ? const Center(
                    child: Text(
                      '해당 조건의 운용자가 없습니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Color(0xFF7C828A),
                      ),
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final pilot = _filtered[i];
                      return _MobileOperatorCard(
                        pilot: pilot,
                        onTap: () {
                          Navigator.pop(context);
                          widget.store.selectPilot(pilot);
                          _openPortfolio(context, pilot);
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _AreaFilterChip extends StatelessWidget {
  const _AreaFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFDEE1E6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF5B616E),
          ),
        ),
      ),
    );
  }
}

// ─── Operator Request Detail Sheet ────────────────────────────────────────────

Future<void> _showOperatorRequestSheet(
  BuildContext context,
  PilotWorkRequest request,
  DrameStore store,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (_) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.92,
          child: _OperatorRequestSheet(request: request, store: store),
        ),
  );
}

class _OperatorRequestSheet extends StatefulWidget {
  const _OperatorRequestSheet({required this.request, required this.store});

  final PilotWorkRequest request;
  final DrameStore store;

  @override
  State<_OperatorRequestSheet> createState() => _OperatorRequestSheetState();
}

class _OperatorRequestSheetState extends State<_OperatorRequestSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _memoController;
  bool _submitting = false;
  bool _submitted = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final req = widget.request;
    _amountController = TextEditingController(
      text: req.myQuotePrice != null ? req.myQuotePrice.toString() : '',
    );
    _memoController = TextEditingController(
      text:
          req.myQuoteMessage ??
          '안녕하세요. 요청 내용 기준으로 작업 가능합니다. 포함 범위, 가능 일정, 연락 가능한 전화번호나 카카오 채널을 함께 남깁니다.',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = _amountController.text.trim();
    final memo = _memoController.text.trim();
    final proposedPrice = int.tryParse(amount.replaceAll(',', ''));
    setState(() => _submitting = true);
    try {
      await widget.store.submitOperatorQuote(
        widget.request,
        memo,
        proposedPrice: proposedPrice,
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
        _editing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isReviewing = req.status == '신규' || req.status == '확인 중';
    final isQuoteSent = req.status == '견적 보냄';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDEE1E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF0A0B0D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '받은 요청 · ${widget.store.pilotWorkRequests.length}건',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0B0D),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Request info card ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isReviewing ? _primary : const Color(0xFFE4EAF2),
                      width: isReviewing ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              req.category,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isReviewing
                                      ? const Color(0xFFEBFAF3)
                                      : isQuoteSent
                                      ? const Color(0xFFEEF4FF)
                                      : const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              req.status,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isReviewing
                                        ? const Color(0xFF05B169)
                                        : isQuoteSent
                                        ? _primary
                                        : const Color(0xFF7C828A),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            req.remaining,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11,
                              color: Color(0xFF7C828A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: <Widget>[
                          _ReqMetaRow(
                            icon: Icons.place_outlined,
                            text: '${req.location} (${req.distance})',
                          ),
                          _ReqMetaRow(
                            icon: Icons.calendar_today_outlined,
                            text: req.dateRange,
                          ),
                          _ReqMetaRow(
                            icon: Icons.paid_outlined,
                            text: req.budget,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        req.summary,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: Color(0xFF3A3F47),
                          height: 1.5,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE4EAF2), height: 1),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                req.client.isNotEmpty
                                    ? req.client[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5B616E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              req.client,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0B0D),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '견적 응답 대기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7C828A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _RequestReviewMap(request: req),
                const SizedBox(height: 12),

                // ── Quote response section ─────────────────────────────────
                if ((_submitted || widget.request.myQuoteMessage != null) &&
                    !_editing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FFF2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF22C58B),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '견적을 보냈습니다.',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A0B0D),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _editing = true),
                              child: const Text(
                                '편집하기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3B7EF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.request.myQuotePrice != null ||
                            (widget.request.myQuoteMessage != null &&
                                widget
                                    .request
                                    .myQuoteMessage!
                                    .isNotEmpty)) ...<Widget>[
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFFB8F0D8), height: 1),
                          const SizedBox(height: 10),
                          if (widget.request.myQuotePrice != null)
                            _SentQuoteRow(
                              label: '견적 금액',
                              value:
                                  '${(widget.request.myQuotePrice! / 10000).round()}만원',
                            ),
                          if (widget.request.myQuoteMessage != null &&
                              widget
                                  .request
                                  .myQuoteMessage!
                                  .isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            _SentQuoteRow(
                              label: '메시지',
                              value: widget.request.myQuoteMessage!,
                              multiLine: true,
                            ),
                          ],
                        ],
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4EAF2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          '견적 응답',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0B0D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '견적 금액',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0B0D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0B0D),
                          ),
                          decoration: InputDecoration(
                            suffixText: '원',
                            suffixStyle: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              color: Color(0xFF7C828A),
                            ),
                            hintText: '예: 450000',
                            hintStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDEE1E6),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE4EAF2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE4EAF2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '메모',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0B0D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _memoController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Color(0xFF3A3F47),
                            height: 1.55,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                '예: 촬영 범위, 포함 산출물, 가능 일정, 연락 가능한 전화번호/카카오 채널을 적어주세요.',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE4EAF2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE4EAF2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(_submitting ? '전송 중…' : '견적 보내기'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReqMetaRow extends StatelessWidget {
  const _ReqMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: const Color(0xFF8BA0B8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            color: Color(0xFF5B616E),
          ),
        ),
      ],
    );
  }
}

class _SentQuoteRow extends StatelessWidget {
  const _SentQuoteRow({
    required this.label,
    required this.value,
    this.multiLine = false,
  });

  final String label;
  final String value;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A3F47),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Color(0xFF3A3F47),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Operator Status Chip ─────────────────────────────────────────────────────

class _MobileOperatorStatusChip extends StatelessWidget {
  const _MobileOperatorStatusChip({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, icon) = _chipStyle();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 11, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (String, Color, Color, IconData) _chipStyle() {
    if (!store.operatorRegistrationCompleted) {
      return (
        '미등록',
        const Color(0xFFF7F8FA),
        const Color(0xFF7C828A),
        Icons.person_outline_rounded,
      );
    }
    return switch (store.operatorReviewStatus) {
      'approved' => (
        '인증됨',
        const Color(0xFFE8F9F1),
        const Color(0xFF05B169),
        Icons.verified_rounded,
      ),
      'pending_review' => (
        '확인중',
        const Color(0xFFFFF7E6),
        const Color(0xFFD97706),
        Icons.schedule_rounded,
      ),
      'rejected' => (
        '인증안됨',
        const Color(0xFFFFF0F0),
        const Color(0xFFDC2626),
        Icons.cancel_outlined,
      ),
      _ => (
        '확인중',
        const Color(0xFFFFF7E6),
        const Color(0xFFD97706),
        Icons.schedule_rounded,
      ),
    };
  }
}

// ─── Operator Requests Tab ────────────────────────────────────────────────────

class _OperatorRequestsMobileTab extends StatelessWidget {
  const _OperatorRequestsMobileTab({required this.store});

  final DrameStore store;

  void _openSheet(BuildContext context, PilotWorkRequest request) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OperatorRequestSheet(store: store, request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = store.pilotWorkRequests;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '받은 요청 · ${requests.length}건',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0B0D),
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (requests.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  '받은 요청이 없습니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Color(0xFF8BA0B8),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _openSheet(context, req),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                req.status == '신규' || req.status == '확인 중'
                                    ? _primary
                                    : const Color(0xFFE4EAF2),
                            width:
                                req.status == '신규' || req.status == '확인 중'
                                    ? 1.5
                                    : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    req.category,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  req.status,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5B616E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              req.client,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0B0D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${req.location} · ${req.dateRange}',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: Color(0xFF7C828A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
