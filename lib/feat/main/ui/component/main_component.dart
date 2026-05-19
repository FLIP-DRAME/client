part of '../pages/main_page.dart';

class AppText {
  static const TextStyle eyebrow = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: _muted,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.6,
    color: _ink,
  );

  static const TextStyle nav = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
    color: _ink,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.45,
    color: _ink,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: -0.1,
    color: _muted,
  );

  static const TextStyle infoLabel = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.1,
    color: _muted,
  );

  static const TextStyle infoValue = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: _ink,
  );

  static const TextStyle metricLabel = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.1,
    color: _muted,
  );

  static const TextStyle metricValue = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 21,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.4,
    color: _ink,
  );

  static const TextStyle portfolioTitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
    color: _ink,
  );

  static const TextStyle smallStrong = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
    color: _ink,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.15,
  );
}

class _CategorySelectionSection extends StatelessWidget {
  const _CategorySelectionSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _PageShell(
        top: 52,
        bottom: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionHeader(
              eyebrow: '먼저 필요한 작업을 선택하세요',
              title: '카테고리별 드론 서비스',
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 1040
                        ? 6
                        : constraints.maxWidth >= 760
                        ? 3
                        : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockDroneCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 132,
                  ),
                  itemBuilder: (context, index) {
                    final category = mockDroneCategories[index];
                    return _ServiceCategoryCard(
                      key: ValueKey('category-${category.id}'),
                      category: category,
                      selected: store.selectedCategory?.id == category.id,
                      onTap: () => store.selectCategory(category),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaSelectionSection extends StatelessWidget {
  const _AreaSelectionSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 42,
        bottom: 42,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionHeader(
              eyebrow: '${store.selectedCategory!.label} 운용자 매칭',
              title: '촬영 지역을 선택하세요',
            ),
            const SizedBox(height: 20),
            _AreaFilter(store: store),
          ],
        ),
      ),
    );
  }
}

class _OperatorListSection extends StatelessWidget {
  const _OperatorListSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 52,
        bottom: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionHeader(
              eyebrow: '${store.selectedArea} 허가 운용자 우선 표시',
              title: '조건에 맞는 운용자',
              action: '${store.pilots.length}명',
            ),
            const SizedBox(height: 24),
            if (store.pilots.isEmpty)
              const _EmptyOperatorState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >= 1040
                          ? 3
                          : constraints.maxWidth >= 720
                          ? 2
                          : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.pilots.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      mainAxisExtent: 430,
                    ),
                    itemBuilder: (context, index) {
                      final pilot = store.pilots[index];
                      return _OperatorMatchCard(
                        key: ValueKey('pilot-${pilot.id}'),
                        pilot: pilot,
                        priority: pilot.hasPermitFor(store.selectedArea),
                        onTap: () {
                          store.selectPilot(pilot);
                          _openPortfolio(context, pilot);
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCategoryCard extends StatelessWidget {
  const _ServiceCategoryCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final DroneCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _focus : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _focus : _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? _focus : _line),
              ),
              child: Icon(category.icon, color: _navy, size: 22),
            ),
            const Spacer(),
            Text(
              category.label,
              style: AppText.smallStrong.copyWith(
                color: _ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.cardSubtitle.copyWith(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorMatchCard extends StatelessWidget {
  const _OperatorMatchCard({
    super.key,
    required this.pilot,
    required this.priority,
    required this.onTap,
  });

  final DronePilot pilot;
  final bool priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: priority ? _mint : _line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _navy.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 190,
              width: double.infinity,
              child: _NetworkCover(imageUrl: pilot.portfolioImages.first),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (priority) const _PriorityBadge(),
                      if (priority) const SizedBox(width: 8),
                      Text(pilot.responseTime, style: AppText.cardSubtitle),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB020),
                        size: 19,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        pilot.rating.toStringAsFixed(1),
                        style: AppText.smallStrong,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(pilot.name, style: AppText.portfolioTitle),
                  const SizedBox(height: 7),
                  Text(
                    pilot.intro,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children:
                        pilot.categories.map((category) {
                          return _MiniChip(label: category);
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Text(pilot.priceLabel, style: AppText.smallStrong),
                      const Spacer(),
                      Text(
                        '포트폴리오 보기',
                        style: AppText.smallStrong.copyWith(color: _navy),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _navy,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.metricLabel.copyWith(
          color: _navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyOperatorState extends StatelessWidget {
  const _EmptyOperatorState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: const Text(
        '선택한 조건에 맞는 운용자가 아직 없습니다. 다른 지역을 선택해보세요.',
        style: AppText.cardSubtitle,
      ),
    );
  }
}

class _PilotLandingSection extends StatelessWidget {
  const _PilotLandingSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: compact ? 500 : 560,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(
                  'https://images.unsplash.com/photo-1508614589041-895b88991e3e?auto=format&fit=crop&w=1800&q=85',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: _navy,
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                ),
                Container(color: Colors.black.withValues(alpha: 0.48)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          '드론 비즈니스의 시작\nDrame과 함께',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: FilledButton.icon(
                            onPressed: store.openPilotOnboarding,
                            icon: const Icon(Icons.verified_user_outlined),
                            label: const Text('운용자 등록하기'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.42),
                                width: 1.2,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 68,
                                vertical: 24,
                              ),
                              textStyle: AppText.button,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _PageShell(
            top: 56,
            bottom: 70,
            child:
                compact
                    ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Drame 운용자가 된다는 건\n검증된 요청을 꾸준히 만난다는 것',
                          style: AppText.sectionTitle,
                        ),
                        SizedBox(height: 24),
                        _PilotLandingMetric(label: '등록 운용자', value: '1,400+'),
                        SizedBox(height: 12),
                        _PilotLandingMetric(label: '월 작업 요청', value: '9,600+'),
                        SizedBox(height: 12),
                        _PilotLandingMetric(label: '평균 응답 시간', value: '30분 내'),
                      ],
                    )
                    : const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Drame 운용자가 된다는 건\n검증된 요청을 꾸준히 만난다는 것',
                            style: AppText.sectionTitle,
                          ),
                        ),
                        SizedBox(width: 28),
                        _PilotLandingMetric(label: '등록 운용자', value: '1,400+'),
                        SizedBox(width: 14),
                        _PilotLandingMetric(label: '월 작업 요청', value: '9,600+'),
                        SizedBox(width: 14),
                        _PilotLandingMetric(label: '평균 응답 시간', value: '30분 내'),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class _PilotLandingMetric extends StatelessWidget {
  const _PilotLandingMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: AppText.cardSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(value, style: AppText.metricValue, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PilotAuthSection extends StatelessWidget {
  const _PilotAuthSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 840;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 46,
        bottom: 88,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Container(
              padding: EdgeInsets.all(compact ? 22 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.07),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () => store.setPilotMode(false),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('메인으로'),
                    style: TextButton.styleFrom(
                      foregroundColor: _navy,
                      textStyle: AppText.button,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    store.isLoginMode ? '로그인' : '회원가입',
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '운용자 등록 전 계정 유형과 기본 정보를 먼저 확인합니다.',
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _soft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _AuthModeTab(
                          label: '로그인',
                          selected: store.isLoginMode,
                          onTap: () => store.updateAuth(loginMode: true),
                        ),
                        _AuthModeTab(
                          label: '회원가입',
                          selected: !store.isLoginMode,
                          onTap: () => store.updateAuth(loginMode: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text('계정 유형', style: AppText.smallStrong),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _AuthRoleChip(
                        label: '이용자',
                        selected: store.accountRole == '이용자',
                        onTap: () => store.updateAuth(role: '이용자'),
                      ),
                      _AuthRoleChip(
                        label: '운용자',
                        selected: store.accountRole == '운용자',
                        onTap: () => store.updateAuth(role: '운용자'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 720;
                      final fields = <Widget>[
                        _AuthEmailField(
                          value: store.accountEmail,
                          onChanged: (value) => store.updateAuth(email: value),
                        ),
                        _AuthPasswordField(
                          value: store.accountPassword,
                          onChanged:
                              (value) => store.updateAuth(password: value),
                        ),
                        if (!store.isLoginMode)
                          _AuthField(
                            label: '이름',
                            value: store.accountName,
                            onChanged: (value) => store.updateAuth(name: value),
                          ),
                        if (!store.isLoginMode)
                          _AuthField(
                            label: '닉네임',
                            value: store.accountNickname,
                            onChanged:
                                (value) => store.updateAuth(nickname: value),
                          ),
                      ];

                      if (!twoColumns) {
                        return Column(
                          children:
                              fields
                                  .map(
                                    (field) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: field,
                                    ),
                                  )
                                  .toList(),
                        );
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            fields
                                .map(
                                  (field) => SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: field,
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!store.isLoginMode) {
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                '회원가입이 완료 되었습니다!',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    store.updateAuth(loginMode: true);
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _navy,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          store.submitAuth();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 19),
                        textStyle: AppText.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        store.accountRole == '운용자'
                            ? store.isLoginMode
                                ? '로그인하고 운용자 등록 계속하기'
                                : '가입하고 운용자 등록 시작하기'
                            : store.isLoginMode
                            ? '로그인하기'
                            : '이용자 계정 만들기',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthModeTab extends StatelessWidget {
  const _AuthModeTab({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _toggle : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppText.smallStrong.copyWith(color: selected ? _ink : _muted),
        ),
      ),
    );
  }
}

class _AuthRoleChip extends StatelessWidget {
  const _AuthRoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: _focus,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? _navy : _line,
        width: selected ? 1.8 : 1,
      ),
      labelStyle: AppText.chip.copyWith(color: _ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}

class _AuthEmailField extends StatelessWidget {
  const _AuthEmailField({required this.value, required this.onChanged});

  static const _domains = <String>[
    'gmail.com',
    'naver.com',
    'kakao.com',
    'daum.net',
    'hanmail.net',
  ];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final atIndex = value.indexOf('@');
    final localPart = atIndex < 0 ? value : value.substring(0, atIndex);
    final domain = atIndex < 0 ? _domains.first : value.substring(atIndex + 1);
    final selectedDomain = _domains.contains(domain) ? domain : _domains.first;

    void updateEmail({String? local, String? nextDomain}) {
      onChanged('${local ?? localPart}@${nextDomain ?? selectedDomain}');
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            key: const ValueKey<String>('auth-email-local'),
            initialValue: localPart,
            keyboardType: TextInputType.emailAddress,
            onChanged: (next) => updateEmail(local: next),
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'example',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _focus, width: 1.4),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('@', style: AppText.smallStrong),
        ),
        SizedBox(
          width: 172,
          child: DropdownButtonFormField<String>(
            initialValue: selectedDomain,
            items:
                _domains
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
            onChanged: (next) {
              if (next != null) {
                updateEmail(nextDomain: next);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _focus, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _focus, width: 1.4),
        ),
      ),
    );
  }
}

class _AuthPasswordField extends StatefulWidget {
  const _AuthPasswordField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<_AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.value,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: '비밀번호',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          tooltip: _obscureText ? '비밀번호 보기' : '비밀번호 숨기기',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _focus, width: 1.4),
        ),
      ),
    );
  }
}

class _PilotDashboardSection extends StatelessWidget {
  const _PilotDashboardSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 940;
    final displayName = store.accountName.isEmpty ? '운용자' : store.accountName;
    final nickname =
        store.accountNickname.isEmpty ? displayName : store.accountNickname;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 52,
        bottom: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('$nickname 운용자 페이지', style: AppText.cardTitle),
                      const SizedBox(height: 8),
                      const Text(
                        '프로필과 요청 현황을 한 곳에서 관리하세요.',
                        style: AppText.cardSubtitle,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/pilot/mypage'),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('등록 정보 수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    textStyle: AppText.button,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            compact
                ? Column(
                  children: <Widget>[
                    _OperatorProfileCard(
                      name: displayName,
                      nickname: nickname,
                      store: store,
                    ),
                    const SizedBox(height: 18),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: _OperatorProfileCard(
                        name: displayName,
                        nickname: nickname,
                        store: store,
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
            const SizedBox(height: 32),
            const _IncomingRequestsPanel(),
          ],
        ),
      ),
    );
  }
}

class _OperatorProfileCard extends StatelessWidget {
  const _OperatorProfileCard({
    required this.name,
    required this.nickname,
    required this.store,
  });

  final String name;
  final String nickname;
  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                child: Text(
                  nickname.characters.first,
                  style: AppText.cardTitle,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: AppText.portfolioTitle),
                    const SizedBox(height: 6),
                    Text(
                      '$nickname 운용자의 항공촬영·방제 서비스',
                      style: AppText.cardSubtitle,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const <Widget>[
                        _MiniChip(label: '리뷰 0'),
                        _MiniChip(label: '응답 30분 내'),
                        _MiniChip(label: '인증 완료'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/pilot/mypage'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    textStyle: AppText.button,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('내 소개 편집'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    textStyle: AppText.button,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('미리보기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _OperatorSideCard extends StatelessWidget {
  const _OperatorSideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.mark_chat_unread_outlined, color: _navy, size: 34),
          const SizedBox(height: 18),
          const Text('새 요청을 확인하세요', style: AppText.portfolioTitle),
          const SizedBox(height: 10),
          const Text(
            '고객이 남긴 견적 요청에 빠르게 응답하면 매칭 확률이 올라갑니다.',
            style: AppText.cardSubtitle,
          ),
        ],
      ),
    );
  }
}

class _IncomingRequestsPanel extends StatelessWidget {
  const _IncomingRequestsPanel();

  @override
  Widget build(BuildContext context) {
    final previewRequests = mockPilotWorkRequests.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Text('받은 요청', style: AppText.portfolioTitle)),
            TextButton.icon(
              onPressed:
                  () => _openPilotRequestReviewPage(
                    context,
                    initialRequest: previewRequests.first,
                  ),
              icon: Text(
                '${previewRequests.length}건 대기 중',
                style: AppText.cardSubtitle.copyWith(color: _navy),
              ),
              label: const Icon(Icons.chevron_right_rounded, size: 18),
              style: TextButton.styleFrom(
                foregroundColor: _navy,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 960 ? 3 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 2.2 : 1.34,
              children:
                  previewRequests
                      .map((request) => _RequestCard(request: request))
                      .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final PilotWorkRequest request;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => _openPilotRequestReviewPage(context, initialRequest: request),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _MiniChip(label: request.location),
                const Spacer(),
                const Icon(Icons.circle, color: _mint, size: 10),
                const SizedBox(width: 5),
                Text(
                  request.status,
                  style: AppText.metricLabel.copyWith(color: _navy),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              request.category,
              style: AppText.smallStrong.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${request.budget} · ${request.dateRange}',
              style: AppText.cardSubtitle,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    () => _openPilotRequestReviewPage(
                      context,
                      initialRequest: request,
                    ),
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  textStyle: AppText.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _PilotRequestReviewPage extends StatefulWidget {
  const _PilotRequestReviewPage({required this.initialRequest});

  final PilotWorkRequest initialRequest;

  @override
  State<_PilotRequestReviewPage> createState() =>
      _PilotRequestReviewPageState();
}

class _PilotRequestReviewPageState extends State<_PilotRequestReviewPage> {
  late PilotWorkRequest selectedRequest = widget.initialRequest;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 980;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 76,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: _line)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed:
                              () =>
                                  context.canPop()
                                      ? context.pop()
                                      : context.go('/'),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: _navy,
                          tooltip: '뒤로가기',
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => context.go('/'),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Drame', style: HomeText.logo),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Container(width: 1, height: 22, color: _line),
                        const SizedBox(width: 18),
                        const Text('받은 요청', style: AppText.cardTitle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _PageShell(
                top: 30,
                bottom: 54,
                child:
                    compact
                        ? SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _RequestReviewList(
                                selected: selectedRequest,
                                onSelected:
                                    (request) => setState(
                                      () => selectedRequest = request,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              _RequestReviewDetail(request: selectedRequest),
                            ],
                          ),
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: _RequestReviewList(
                                  selected: selectedRequest,
                                  onSelected:
                                      (request) => setState(
                                        () => selectedRequest = request,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _RequestReviewDetail(
                                  request: selectedRequest,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestReviewList extends StatelessWidget {
  const _RequestReviewList({required this.selected, required this.onSelected});

  final PilotWorkRequest selected;
  final ValueChanged<PilotWorkRequest> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '견적 요청 ${mockPilotWorkRequests.length}건',
              style: AppText.portfolioTitle,
            ),
            const Spacer(),
            _RequestFilterButton(label: '최신순'),
          ],
        ),
        const SizedBox(height: 16),
        ...mockPilotWorkRequests.map(
          (request) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RequestReviewCard(
              request: request,
              selected: selected.id == request.id,
              onTap: () => onSelected(request),
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestFilterButton extends StatelessWidget {
  const _RequestFilterButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: AppText.metricLabel.copyWith(color: _navy)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _navy),
        ],
      ),
    );
  }
}

class _RequestReviewCard extends StatelessWidget {
  const _RequestReviewCard({
    required this.request,
    required this.selected,
    required this.onTap,
  });

  final PilotWorkRequest request;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _focus : _line, width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _MiniChip(label: request.category),
                const SizedBox(width: 8),
                _MiniChip(label: request.status),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: <Widget>[
                _RequestMeta(
                  icon: Icons.place_outlined,
                  text: '${request.location} (${request.distance})',
                ),
                _RequestMeta(
                  icon: Icons.calendar_today_outlined,
                  text: request.dateRange,
                ),
                _RequestMeta(icon: Icons.paid_outlined, text: request.budget),
              ],
            ),
            const SizedBox(height: 13),
            Text(request.summary, style: AppText.cardSubtitle),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(request.progress, style: AppText.metricLabel),
                ),
                Text(
                  request.remaining,
                  style: AppText.smallStrong.copyWith(color: _navy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestReviewDetail extends StatelessWidget {
  const _RequestReviewDetail({required this.request});

  final PilotWorkRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MiniChip(label: request.category),
                const SizedBox(height: 14),
                _RequestMeta(
                  icon: Icons.place_outlined,
                  text: '${request.location} (${request.distance})',
                ),
                const SizedBox(height: 8),
                _RequestMeta(
                  icon: Icons.calendar_today_outlined,
                  text: request.dateRange,
                ),
                const SizedBox(height: 8),
                _RequestMeta(icon: Icons.paid_outlined, text: request.budget),
                const SizedBox(height: 8),
                _RequestMeta(
                  icon: Icons.person_outline_rounded,
                  text: '의뢰자: ${request.client}',
                ),
                const SizedBox(height: 14),
                Text(request.summary, style: AppText.cardSubtitle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.map_outlined, color: Color(0xFF8BA0B8)),
                const SizedBox(height: 8),
                Text(request.mapLabel, style: AppText.metricLabel),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: _line),
          const SizedBox(height: 18),
          const _KakaoPaySection(),
        ],
      ),
    );
  }
}

class _RequestMeta extends StatelessWidget {
  const _RequestMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: const Color(0xFF8BA0B8)),
        const SizedBox(width: 5),
        Text(text, style: AppText.cardSubtitle),
      ],
    );
  }
}

class _QuoteField extends StatelessWidget {
  const _QuoteField({
    required this.label,
    required this.hint,
    this.suffix,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final String? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: maxLines == 1 ? hint : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: maxLines == 1 ? null : hint,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _focus, width: 1.2),
        ),
      ),
    );
  }
}

class _PilotRegistrationDoneSection extends StatelessWidget {
  const _PilotRegistrationDoneSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 80,
        bottom: 96,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F8F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: _mint,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('운용자 등록이 완료되었습니다', style: AppText.cardTitle),
                  const SizedBox(height: 10),
                  const Text(
                    '이제 받은 요청을 확인하고 등록 정보를 마이페이지에서 수정할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/pilot/mypage'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navy,
                            textStyle: AppText.button,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('등록 정보 수정'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.go('/'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            textStyle: AppText.button,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('운용자 페이지로'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _OperatorMyPageSection extends StatelessWidget {
  const _OperatorMyPageSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final data = store.pilotOnboarding;
    final drone = data.drones.first;
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 36,
        bottom: 86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('운용자 페이지'),
              style: TextButton.styleFrom(
                foregroundColor: _navy,
                textStyle: AppText.button,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('마이페이지', style: AppText.cardTitle),
                  const SizedBox(height: 8),
                  const Text(
                    '운용자 등록 때 입력한 정보를 수정할 수 있습니다.',
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 26),
                  _MyPageGroup(
                    title: '계정 정보',
                    children: <Widget>[
                      _PilotTextField(
                        label: '이름',
                        initialValue: store.accountName,
                        hint: '홍길동',
                        onChanged: (value) => store.updateAuth(name: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '닉네임',
                        initialValue: store.accountNickname,
                        hint: '드라메 파일럿',
                        onChanged: (value) => store.updateAuth(nickname: value),
                      ),
                    ],
                  ),
                  _MyPageGroup(
                    title: '자격 및 사업자',
                    children: <Widget>[
                      _PilotSelectField(
                        label: '자격증 종류',
                        value: data.licenseType,
                        values: const <String>[
                          '초경량비행장치 조종자',
                          '무인멀티콥터 지도조종자',
                          '무인헬리콥터 조종자',
                        ],
                        onChanged:
                            (value) => store.updatePilotLicense(type: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '자격증 번호',
                        initialValue: data.licenseNumber,
                        hint: 'UAV-2026-0001',
                        onChanged:
                            (value) => store.updatePilotLicense(number: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '상호명',
                        initialValue: data.businessName,
                        hint: '드라메 항공촬영',
                        onChanged:
                            (value) => store.updatePilotBusiness(name: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '사업자등록번호',
                        initialValue: data.businessNumber,
                        hint: '000-00-00000',
                        keyboardType: TextInputType.number,
                        inputFormatters: const <TextInputFormatter>[
                          BusinessNumberInputFormatter(),
                        ],
                        onChanged:
                            (value) => store.updatePilotBusiness(number: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '대표자명',
                        initialValue: data.representativeName,
                        hint: '홍길동',
                        onChanged:
                            (value) => store.updatePilotBusiness(
                              representative: value,
                            ),
                      ),
                    ],
                  ),
                  _MyPageGroup(
                    title: '보험 및 기체',
                    children: <Widget>[
                      _PilotSelectField(
                        label: '보험사',
                        value: data.insuranceCompany,
                        values: const <String>[
                          'DB손해보험',
                          '삼성화재',
                          '현대해상',
                          'KB손해보험',
                        ],
                        onChanged:
                            (value) =>
                                store.updatePilotInsurance(company: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '보험 증권번호',
                        initialValue: data.insuranceNumber,
                        hint: 'DB-DRONE-240001',
                        onChanged:
                            (value) =>
                                store.updatePilotInsurance(number: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotSelectField(
                        label: '기체 제조사',
                        value: drone.maker,
                        values: const <String>['DJI', 'Autel', 'Parrot', '기타'],
                        onChanged:
                            (value) => store.updatePilotDrone(0, maker: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '기체 모델명',
                        initialValue: drone.model,
                        hint: 'Mavic 3 Pro',
                        onChanged:
                            (value) => store.updatePilotDrone(0, model: value),
                      ),
                      const SizedBox(height: 16),
                      _PilotTextField(
                        label: '기체 신고번호',
                        initialValue: drone.registrationNumber,
                        hint: 'S1234567',
                        onChanged:
                            (value) => store.updatePilotDrone(
                              0,
                              registrationNumber: value,
                            ),
                      ),
                    ],
                  ),
                  _MyPageGroup(
                    title: '활동 지역',
                    children: <Widget>[
                      _PilotChipGroup(
                        values: const <String>[
                          '서울',
                          '경기',
                          '인천',
                          '강원',
                          '충청',
                          '전라',
                          '경상',
                          '제주',
                        ],
                        selected: data.areas,
                        onTap: store.togglePilotArea,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        textStyle: AppText.button,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('저장하고 돌아가기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPageGroup extends StatelessWidget {
  const _MyPageGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppText.portfolioTitle),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PilotOnboardingSection extends StatelessWidget {
  const _PilotOnboardingSection({required this.store});

  final DrameStore store;

  static const _steps = <String>[
    '자격증 등록',
    '사업자 정보',
    '보험 등록',
    '보유 기체',
    '활동 지역·일정',
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 940;
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: 40,
        bottom: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextButton.icon(
              onPressed: store.closePilotOnboarding,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('운용자 메인으로'),
              style: TextButton.styleFrom(
                foregroundColor: _navy,
                textStyle: AppText.button,
              ),
            ),
            const SizedBox(height: 30),
            if (compact)
              Column(
                children: <Widget>[
                  _PilotStepCard(store: store, steps: _steps),
                  const SizedBox(height: 18),
                  _PilotFormCard(store: store, steps: _steps),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 280,
                    child: _PilotStepCard(store: store, steps: _steps),
                  ),
                  const SizedBox(width: 28),
                  Expanded(child: _PilotFormCard(store: store, steps: _steps)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PilotStepCard extends StatelessWidget {
  const _PilotStepCard({required this.store, required this.steps});

  final DrameStore store;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final done =
        store.pilotOnboarding.submitted
            ? steps.length
            : store.pilotOnboardingStep;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('운용자 인증', style: AppText.portfolioTitle),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final active = entry.key == store.pilotOnboardingStep;
            final completed = entry.key < done;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => store.goToPilotOnboardingStep(entry.key),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: active ? _focus : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            active ? _focus : const Color(0xFFF1F3F5),
                        child:
                            completed
                                ? const Icon(
                                  Icons.check_rounded,
                                  color: _ink,
                                  size: 17,
                                )
                                : Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: active ? Colors.white : _muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppText.smallStrong.copyWith(
                            color: active ? _ink : const Color(0xFFA3B0C2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Divider(color: _line),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text('진행률', style: AppText.metricLabel),
              const Spacer(),
              Text('$done/6 완료', style: AppText.metricLabel),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (done / steps.length).clamp(0.08, 1),
              minHeight: 7,
              backgroundColor: const Color(0xFFE8EEF5),
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _PilotFormCard extends StatelessWidget {
  const _PilotFormCard({required this.store, required this.steps});

  final DrameStore store;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final step = store.pilotOnboardingStep;
    final bodies = <Widget>[
      _LicenseStep(store: store),
      _BusinessStep(store: store),
      _InsuranceStep(store: store),
      _DroneStep(store: store),
      _AreaStep(store: store),
    ];
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Step ${step + 1} / ${steps.length}',
            style: AppText.cardSubtitle,
          ),
          const SizedBox(height: 6),
          Text(steps[step], style: AppText.cardTitle),
          const SizedBox(height: 24),
          if (store.pilotOnboarding.submitted) ...<Widget>[
            const _PilotNotice('인증 요청이 접수되었습니다. 입력 정보는 계속 수정할 수 있습니다.'),
            const SizedBox(height: 18),
          ],
          bodies[step],
          const SizedBox(height: 28),
          const Divider(color: _line),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              OutlinedButton(
                onPressed:
                    step == 0
                        ? store.closePilotOnboarding
                        : store.previousPilotOnboardingStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 20,
                  ),
                  textStyle: AppText.button,
                ),
                child: Text(step == 0 ? '나가기' : '이전'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: store.nextPilotOnboardingStep,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 21),
                    textStyle: AppText.button,
                  ),
                  child: Text(step == steps.length - 1 ? '인증 제출' : '다음'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LicenseStep extends StatelessWidget {
  const _LicenseStep({required this.store});
  final DrameStore store;
  @override
  Widget build(BuildContext context) {
    final data = store.pilotOnboarding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PilotSelectField(
          label: '자격증 종류 *',
          value: data.licenseType,
          values: const <String>['초경량비행장치 조종자', '무인멀티콥터 지도조종자', '드론 실기평가 조종자'],
          onChanged: (value) => store.updatePilotLicense(type: value),
        ),
        const SizedBox(height: 18),
        _PilotTextField(
          label: '자격증 번호 *',
          initialValue: data.licenseNumber,
          hint: '예: 2024-0001234',
          onChanged: (value) => store.updatePilotLicense(number: value),
        ),
        const SizedBox(height: 18),
        _PilotUploadBox(
          title: '자격증 앞면 업로드',
          uploaded: data.licenseFrontUploaded,
          onTap:
              () => store.updatePilotLicense(
                frontUploaded: !data.licenseFrontUploaded,
              ),
        ),
        const SizedBox(height: 12),
        _PilotUploadBox(
          title: '자격증 뒷면 업로드',
          uploaded: data.licenseBackUploaded,
          onTap:
              () => store.updatePilotLicense(
                backUploaded: !data.licenseBackUploaded,
              ),
        ),
      ],
    );
  }
}

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({required this.store});
  final DrameStore store;
  @override
  Widget build(BuildContext context) {
    final data = store.pilotOnboarding;
    return Column(
      children: <Widget>[
        _PilotTextField(
          label: '상호명 *',
          initialValue: data.businessName,
          hint: '드라메 항공촬영',
          onChanged: (value) => store.updatePilotBusiness(name: value),
        ),
        const SizedBox(height: 18),
        _PilotTextField(
          label: '사업자등록번호 *',
          initialValue: data.businessNumber,
          hint: '000-00-00000',
          keyboardType: TextInputType.number,
          inputFormatters: const <TextInputFormatter>[
            BusinessNumberInputFormatter(),
          ],
          onChanged: (value) => store.updatePilotBusiness(number: value),
        ),
        const SizedBox(height: 18),
        _PilotTextField(
          label: '대표자명 *',
          initialValue: data.representativeName,
          hint: '홍길동',
          onChanged:
              (value) => store.updatePilotBusiness(representative: value),
        ),
      ],
    );
  }
}

class _InsuranceStep extends StatelessWidget {
  const _InsuranceStep({required this.store});
  final DrameStore store;
  @override
  Widget build(BuildContext context) {
    final data = store.pilotOnboarding;
    return Column(
      children: <Widget>[
        _PilotSelectField(
          label: '보험사 *',
          value: data.insuranceCompany,
          values: const <String>['DB손해보험', '삼성화재', '현대해상', 'KB손해보험'],
          onChanged: (value) => store.updatePilotInsurance(company: value),
        ),
        const SizedBox(height: 18),
        _PilotTextField(
          label: '보험 증권번호 *',
          initialValue: data.insuranceNumber,
          hint: 'DB-DRONE-240001',
          onChanged: (value) => store.updatePilotInsurance(number: value),
        ),
        const SizedBox(height: 18),
        _PilotUploadBox(
          title: '보험 증권 업로드',
          uploaded: data.insuranceUploaded,
          onTap:
              () =>
                  store.updatePilotInsurance(uploaded: !data.insuranceUploaded),
        ),
      ],
    );
  }
}

class _DroneStep extends StatelessWidget {
  const _DroneStep({required this.store});
  final DrameStore store;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...store.pilotOnboarding.drones.asMap().entries.map((entry) {
          final index = entry.key;
          final drone = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('기체 ${index + 1}', style: AppText.smallStrong),
                    const Spacer(),
                    if (store.pilotOnboarding.drones.length > 1)
                      IconButton(
                        onPressed: () => store.removePilotDrone(index),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                _PilotSelectField(
                  label: '제조사',
                  value: drone.maker,
                  values: const <String>['DJI', 'Autel', 'Parrot', '기타'],
                  onChanged:
                      (value) => store.updatePilotDrone(index, maker: value),
                ),
                const SizedBox(height: 18),
                _PilotTextField(
                  label: '모델명',
                  initialValue: drone.model,
                  hint: 'Mavic 3 Pro',
                  onChanged:
                      (value) => store.updatePilotDrone(index, model: value),
                ),
                const SizedBox(height: 18),
                _PilotChipGroup(
                  values: const <String>['촬영용', '방제용', '측량용', '점검용', '다목적'],
                  selected: drone.categories,
                  onTap:
                      (value) => store.togglePilotDroneCategory(index, value),
                ),
                const SizedBox(height: 14),
                _PilotChipGroup(
                  values: const <String>[
                    '4K 카메라',
                    '열화상',
                    '다중분광',
                    'RTK GPS',
                    '약제 탱크',
                  ],
                  selected: drone.sensors,
                  onTap: (value) => store.togglePilotDroneSensor(index, value),
                ),
                const SizedBox(height: 18),
                _PilotTextField(
                  label: '기체 신고번호',
                  initialValue: drone.registrationNumber,
                  hint: 'S1234567',
                  onChanged:
                      (value) => store.updatePilotDrone(
                        index,
                        registrationNumber: value,
                      ),
                ),
                const SizedBox(height: 18),
                _PilotUploadBox(
                  title: '기체 사진 업로드',
                  uploaded: drone.photoUploaded,
                  onTap:
                      () => store.updatePilotDrone(
                        index,
                        photoUploaded: !drone.photoUploaded,
                      ),
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: store.addPilotDrone,
          icon: const Icon(Icons.add_rounded),
          label: const Text('기체 추가'),
        ),
      ],
    );
  }
}

class _AreaStep extends StatelessWidget {
  const _AreaStep({required this.store});
  final DrameStore store;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('주요 활동 지역', style: AppText.smallStrong),
        const SizedBox(height: 10),
        _PilotChipGroup(
          values: const <String>[
            '서울',
            '경기',
            '인천',
            '강원',
            '충청',
            '전라',
            '경상',
            '제주',
          ],
          selected: store.pilotOnboarding.areas,
          onTap: store.togglePilotArea,
        ),
        const SizedBox(height: 18),
        const _PilotNotice('복수 지역을 선택할 수 있습니다. 선택 지역은 운용자 매칭 노출에 사용됩니다.'),
      ],
    );
  }
}

class _PilotTextField extends StatelessWidget {
  const _PilotTextField({
    required this.label,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });
  final String label;
  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: ValueKey<String>('$label-$initialValue'),
    initialValue: initialValue,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    decoration: _pilotInputDecoration(label: label, hint: hint),
  );
}

class _PilotSelectField extends StatelessWidget {
  const _PilotSelectField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          values
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      decoration: _pilotInputDecoration(label: label),
    );
  }
}

class _PilotUploadBox extends StatelessWidget {
  const _PilotUploadBox({
    required this.title,
    required this.uploaded,
    required this.onTap,
  });
  final String title;
  final bool uploaded;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 128,
        width: double.infinity,
        decoration: BoxDecoration(
          color: uploaded ? const Color(0xFFE9F8F2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: uploaded ? _mint : const Color(0xFFBFD0E4),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_outlined,
              color: uploaded ? _mint : const Color(0xFF8BA0B8),
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(title, style: AppText.smallStrong.copyWith(color: _navy)),
            const SizedBox(height: 4),
            Text(
              uploaded ? '첨부 완료' : 'JPG, PNG, PDF 지원',
              style: AppText.metricLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _PilotChipGroup extends StatelessWidget {
  const _PilotChipGroup({
    required this.values,
    required this.selected,
    required this.onTap,
  });
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          values.map((value) {
            final active = selected.contains(value);
            return FilterChip(
              label: Text(
                value,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? _navy : _ink,
                ),
              ),
              selected: active,
              onSelected: (_) => onTap(value),
              selectedColor: _focus,
              showCheckmark: false,
              side: BorderSide(color: active ? _navy : _line, width: 1.4),
            );
          }).toList(),
    );
  }
}

class _PilotNotice extends StatelessWidget {
  const _PilotNotice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: AppText.cardSubtitle),
    );
  }
}

InputDecoration _pilotInputDecoration({required String label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _focus, width: 1.4),
    ),
  );
}

class _PopularPortfolioSection extends StatelessWidget {
  const _PopularPortfolioSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final portfolioPilots =
        store.selectedPortfolioCategory == '전체'
            ? store.pilots
            : store.pilots
                .where(
                  (pilot) => pilot.hasCategory(store.selectedPortfolioCategory),
                )
                .toList();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: _PageShell(
        top: 58,
        bottom: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionHeader(eyebrow: '이용자들이 만족한', title: '인기 운용자들의 포트폴리오'),
            const SizedBox(height: 22),
            _PortfolioCategoryChips(store: store),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 980
                        ? 3
                        : constraints.maxWidth >= 680
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: portfolioPilots.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 402,
                  ),
                  itemBuilder: (context, index) {
                    final pilot = portfolioPilots[index];
                    return _PilotPortfolioCard(
                      pilot: pilot,
                      onTap: () {
                        store.selectPilot(pilot);
                        _openPortfolio(context, pilot);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaFilter extends StatelessWidget {
  const _AreaFilter({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final districts =
        store.selectedRegion == '전체'
            ? const <String>[]
            : mockServiceDistricts[store.selectedRegion] ?? const <String>[];
    final neighborhoods =
        store.selectedDistrict == '전체'
            ? const <String>[]
            : mockServiceNeighborhoods[store.selectedDistrict] ??
                const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AreaChipWrap(
          children:
              mockServiceAreas.map((area) {
                return _AreaChip(
                  key: ValueKey('area-$area'),
                  label: area,
                  selected: store.selectedRegion == area,
                  onTap: () => store.selectRegion(area),
                );
              }).toList(),
        ),
        if (districts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            '${store.selectedRegion} 시·구 선택',
            style: AppText.smallStrong.copyWith(color: _navy),
          ),
          const SizedBox(height: 10),
          _AreaChipWrap(
            children: <Widget>[
              _AreaChip(
                key: const ValueKey('district-전체'),
                label: '전체',
                selected: store.selectedDistrict == '전체',
                onTap: () => store.selectDistrict('전체'),
                compact: true,
              ),
              ...districts.map((district) {
                return _AreaChip(
                  key: ValueKey('district-$district'),
                  label: district,
                  selected: store.selectedDistrict == district,
                  onTap: () => store.selectDistrict(district),
                  compact: true,
                );
              }),
            ],
          ),
        ],
        if (neighborhoods.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            '${store.selectedDistrict} 동 선택',
            style: AppText.smallStrong.copyWith(color: _navy),
          ),
          const SizedBox(height: 10),
          _AreaChipWrap(
            children: <Widget>[
              _AreaChip(
                key: const ValueKey('neighborhood-전체'),
                label: '전체',
                selected: store.selectedArea == store.selectedDistrict,
                onTap: () => store.selectNeighborhood('전체'),
                compact: true,
              ),
              ...neighborhoods.map((neighborhood) {
                return _AreaChip(
                  key: ValueKey('neighborhood-$neighborhood'),
                  label: neighborhood,
                  selected: store.selectedArea == neighborhood,
                  onTap: () => store.selectNeighborhood(neighborhood),
                  compact: true,
                );
              }),
            ],
          ),
        ],
      ],
    );
  }
}

class _AreaChipWrap extends StatelessWidget {
  const _AreaChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 10, children: children);
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: selected ? _focus : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _focus : _line),
        ),
        child: Text(
          label,
          style: AppText.chip.copyWith(
            color: _ink,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: compact ? 14 : 15,
          ),
        ),
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 456,
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              Positioned.fill(child: CustomPaint(painter: _KoreaMapPainter())),
              Positioned(
                left: 20,
                top: 20,
                child: _PermitPill(area: store.selectedArea),
              ),
              ...store.pilots.map((pilot) {
                final selected = store.selectedPilot?.id == pilot.id;
                final priority =
                    store.selectedArea != '전체' &&
                    pilot.hasPermitFor(store.selectedArea);

                return Positioned(
                  left: constraints.maxWidth * pilot.mapX - 20,
                  top: constraints.maxHeight * pilot.mapY - 20,
                  child: _PilotMarker(
                    pilot: pilot,
                    selected: selected,
                    priority: priority,
                    onTap: () => store.selectPilot(pilot),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PilotPanel extends StatelessWidget {
  const _PilotPanel({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final pilot = store.selectedPilot ?? store.pilots.first;
    final hasPriority =
        store.selectedArea != '전체' && pilot.hasPermitFor(store.selectedArea);

    return Container(
      width: double.infinity,
      height: 456,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _navy.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(pilot.name, style: AppText.cardTitle)),
                if (hasPriority) const _PriorityBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(pilot.specialty, style: AppText.cardSubtitle),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.place_outlined,
              label: '활동 위치',
              value: pilot.location,
            ),
            _InfoRow(
              icon: Icons.map_outlined,
              label: '촬영 가능 위치',
              value: pilot.availableAreas.join(', '),
            ),
            _InfoRow(
              icon: Icons.call_outlined,
              label: '연락처',
              value: pilot.contact,
            ),
            _InfoRow(
              icon: Icons.payments_outlined,
              label: '제안가격',
              value: pilot.priceLabel,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _Metric(label: '평점', value: pilot.rating.toStringAsFixed(1)),
                const SizedBox(width: 10),
                _Metric(label: '완료 촬영', value: '${pilot.completedJobs}건'),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                textStyle: AppText.button,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _openPortfolio(context, pilot),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('촬영 제안 보내기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.child, this.top = 44, this.bottom = 44});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(eyebrow, style: AppText.eyebrow),
              const SizedBox(height: 7),
              Text(title, style: AppText.sectionTitle),
            ],
          ),
        ),
        if (action != null)
          TextButton.icon(
            onPressed: () {},
            label: Text(action!),
            icon: const Icon(Icons.chevron_right_rounded),
            iconAlignment: IconAlignment.end,
          ),
      ],
    );
  }
}

// ignore: unused_element
class _TopSearch extends StatelessWidget {
  const _TopSearch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.search_rounded, color: Color(0xFF9AA8BA), size: 21),
          SizedBox(width: 10),
          Text(
            '어떤 서비스가 필요하세요?',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioCategoryChips extends StatelessWidget {
  const _PortfolioCategoryChips({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    const categories = <String>[
      '전체',
      '항공촬영',
      '농약방제',
      '부동산',
      '시설점검',
      '측량·매핑',
      '행사촬영',
      '해양·산림',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              final selected = category == store.selectedPortfolioCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => store.selectPortfolioCategory(category),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _focus : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: selected ? _focus : _line),
                    ),
                    child: Text(
                      category,
                      style: AppText.chip.copyWith(
                        color: _ink,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _PilotPortfolioCard extends StatelessWidget {
  const _PilotPortfolioCard({required this.pilot, required this.onTap});

  final DronePilot pilot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _PortfolioPreviewGrid(images: pilot.portfolioImages),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pilot.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 8),
                  Text(pilot.name, style: AppText.portfolioTitle),
                  const SizedBox(height: 9),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB020),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pilot.rating.toStringAsFixed(1)} (${pilot.completedJobs})',
                        style: AppText.smallStrong,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${pilot.priceLabel}',
                        style: AppText.cardSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioPreviewGrid extends StatelessWidget {
  const _PortfolioPreviewGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final previewImages = images.take(3).toList();

    return Row(
      children: <Widget>[
        Expanded(flex: 2, child: _NetworkCover(imageUrl: previewImages.first)),
        const SizedBox(width: 3),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _NetworkCover(
                  imageUrl:
                      previewImages.length > 1
                          ? previewImages[1]
                          : previewImages.first,
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: _NetworkCover(
                  imageUrl:
                      previewImages.length > 2
                          ? previewImages[2]
                          : previewImages.first,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkCover extends StatelessWidget {
  const _NetworkCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFE4EAF2), Color(0xFFB8C7D8)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _PermitPill extends StatelessWidget {
  const _PermitPill({required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    final message =
        area == '전체' ? '지역 선택 시 허가 운용자 우선 표시' : '$area 허가 운용자 우선 표시 중';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.verified_outlined, color: _mint, size: 17),
          const SizedBox(width: 7),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.25,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      color: Colors.white,
      child: _PageShell(
        top: 58,
        bottom: 54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (compact)
              const Wrap(
                spacing: 28,
                runSpacing: 28,
                children: <Widget>[
                  SizedBox(width: 240, child: _FooterBrand()),
                  SizedBox(
                    width: 180,
                    child: _FooterColumn(
                      title: '서비스',
                      items: <String>[
                        '카테고리',
                        '작동 원리',
                        'Drame vs 기존',
                        '의뢰자 요금',
                        '비행공역 확인',
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: _FooterColumn(
                      title: '운용자',
                      items: <String>['운용자 등록', '운용자 가이드', '구독 관리', '일감 피드'],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: _FooterColumn(
                      title: '정책',
                      items: <String>['이용약관', '개인정보처리방침', '환불 정책', '청소년 보호'],
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: _FooterColumn(
                      title: '고객센터',
                      items: <String>[
                        '카카오 채널',
                        'hello@drame.co.kr',
                        '평일 09:00 - 18:00',
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Expanded(flex: 2, child: _FooterBrand()),
                  Expanded(
                    child: _FooterColumn(
                      title: '서비스',
                      items: <String>[
                        '카테고리',
                        '작동 원리',
                        'Drame vs 기존',
                        '의뢰자 요금',
                        '비행공역 확인',
                      ],
                    ),
                  ),
                  Expanded(
                    child: _FooterColumn(
                      title: '운용자',
                      items: <String>['운용자 등록', '운용자 가이드', '구독 관리', '일감 피드'],
                    ),
                  ),
                  Expanded(
                    child: _FooterColumn(
                      title: '정책',
                      items: <String>['이용약관', '개인정보처리방침', '환불 정책', '청소년 보호'],
                    ),
                  ),
                  Expanded(
                    child: _FooterColumn(
                      title: '고객센터',
                      items: <String>[
                        '카카오 채널',
                        'hello@drame.co.kr',
                        '평일 09:00 - 18:00',
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 42),
            const Divider(color: _line),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const <Widget>[
                Expanded(
                  child: Text(
                    '상호: 주식회사 드라메  |  대표자: 김드론  |  사업자등록번호: 123-45-67890\n'
                    '통신판매신고번호: 제2026-서울강남-0001호  |  개인정보 보호책임자: 이보호\n'
                    '주소: 서울특별시 강남구 테헤란로 123, 드라메빌딩 5층',
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                      height: 1.7,
                    ),
                  ),
                ),
                Text(
                  '© 2026 Drame. All rights reserved.',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '•  Drame',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 22),
        Text(
          '30분 안에,\n검증된 드론 운용자와 만나세요.',
          style: TextStyle(
            color: _muted,
            fontWeight: FontWeight.w800,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              item,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PilotMarker extends StatelessWidget {
  const _PilotMarker({
    required this.pilot,
    required this.selected,
    required this.priority,
    required this.onTap,
  });

  final DronePilot pilot;
  final bool selected;
  final bool priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = priority ? _mint : _navy;

    return Tooltip(
      message: '${pilot.name} · ${pilot.priceLabel}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 56 : 44,
          height: selected ? 56 : 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: selected ? 5 : 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.videocam_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: _navy),
          const SizedBox(width: 10),
          SizedBox(width: 100, child: Text(label, style: AppText.infoLabel)),
          Expanded(child: Text(value, style: AppText.infoValue)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _soft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: AppText.metricLabel),
            const SizedBox(height: 5),
            Text(value, style: AppText.metricValue),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FBF4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        '허가 우선',
        style: TextStyle(color: Color(0xFF128765), fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _KoreaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = const Color(0xFFD2DCE8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path =
        Path()
          ..moveTo(size.width * 0.58, size.height * 0.08)
          ..cubicTo(
            size.width * 0.72,
            size.height * 0.14,
            size.width * 0.74,
            size.height * 0.26,
            size.width * 0.66,
            size.height * 0.36,
          )
          ..cubicTo(
            size.width * 0.77,
            size.height * 0.47,
            size.width * 0.69,
            size.height * 0.62,
            size.width * 0.60,
            size.height * 0.72,
          )
          ..cubicTo(
            size.width * 0.51,
            size.height * 0.83,
            size.width * 0.38,
            size.height * 0.73,
            size.width * 0.36,
            size.height * 0.60,
          )
          ..cubicTo(
            size.width * 0.24,
            size.height * 0.51,
            size.width * 0.31,
            size.height * 0.39,
            size.width * 0.39,
            size.height * 0.31,
          )
          ..cubicTo(
            size.width * 0.35,
            size.height * 0.20,
            size.width * 0.45,
            size.height * 0.11,
            size.width * 0.58,
            size.height * 0.08,
          )
          ..close();

    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, borderPaint);

    final jejuRect = Rect.fromCenter(
      center: Offset(size.width * 0.30, size.height * 0.90),
      width: size.width * 0.18,
      height: size.height * 0.055,
    );
    canvas.drawOval(jejuRect, landPaint);
    canvas.drawOval(jejuRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KakaoPaySection extends StatefulWidget {
  const _KakaoPaySection();

  @override
  State<_KakaoPaySection> createState() => _KakaoPaySectionState();
}

class _KakaoPaySectionState extends State<_KakaoPaySection> {
  bool _paymentDone = false;

  @override
  Widget build(BuildContext context) {
    if (_paymentDone) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: const Row(
          children: <Widget>[
            Icon(Icons.phone_outlined, color: _navy, size: 20),
            SizedBox(width: 10),
            Text('이용자 연락처: 010-1234-5678', style: AppText.smallStrong),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('카카오페이로 결제하기', style: AppText.portfolioTitle),
        const SizedBox(height: 6),
        const Text('QR코드를 카카오페이 앱으로 스캔하세요', style: AppText.cardSubtitle),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE500),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.qr_code_rounded, color: Color(0xFF3A1D1D), size: 20),
              SizedBox(width: 8),
              Text(
                'KakaoPay',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A1D1D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: CustomPaint(painter: _QrCodePainter()),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('QR코드 유효시간: 10분', style: AppText.metricLabel)),
        const SizedBox(height: 20),
        const Divider(color: _line),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _paymentDone = true),
            style: FilledButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: _line,
              textStyle: AppText.button,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('완료'),
          ),
        ),
      ],
    );
  }
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF222222);
    final w = size.width;
    final h = size.height;

    void block(double x, double y, double s) {
      canvas.drawRect(Rect.fromLTWH(x * w, y * h, s * w, s * h), p);
    }

    block(0, 0, 0.30);
    canvas.drawRect(
      Rect.fromLTWH(0.04 * w, 0.04 * h, 0.22 * w, 0.22 * h),
      Paint()..color = Colors.white,
    );
    block(0.08, 0.08, 0.14);
    block(0.70, 0, 0.30);
    canvas.drawRect(
      Rect.fromLTWH(0.74 * w, 0.04 * h, 0.22 * w, 0.22 * h),
      Paint()..color = Colors.white,
    );
    block(0.78, 0.08, 0.14);
    block(0, 0.70, 0.30);
    canvas.drawRect(
      Rect.fromLTWH(0.04 * w, 0.74 * h, 0.22 * w, 0.22 * h),
      Paint()..color = Colors.white,
    );
    block(0.08, 0.78, 0.14);
    final dots = <List<double>>[
      [0.40, 0.04],
      [0.50, 0.04],
      [0.60, 0.04],
      [0.40, 0.12],
      [0.60, 0.12],
      [0.40, 0.20],
      [0.50, 0.20],
      [0.04, 0.40],
      [0.12, 0.40],
      [0.20, 0.40],
      [0.40, 0.40],
      [0.50, 0.40],
      [0.60, 0.40],
      [0.70, 0.40],
      [0.80, 0.40],
      [0.90, 0.40],
      [0.04, 0.50],
      [0.20, 0.50],
      [0.50, 0.50],
      [0.70, 0.50],
      [0.90, 0.50],
      [0.04, 0.60],
      [0.12, 0.60],
      [0.40, 0.60],
      [0.60, 0.60],
      [0.80, 0.60],
      [0.40, 0.70],
      [0.60, 0.70],
      [0.80, 0.70],
      [0.90, 0.70],
      [0.40, 0.80],
      [0.50, 0.80],
      [0.70, 0.80],
      [0.40, 0.90],
      [0.60, 0.90],
      [0.80, 0.90],
      [0.90, 0.90],
    ];

    for (final dot in dots) {
      block(dot[0], dot[1], 0.08);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
