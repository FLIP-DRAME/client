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

// ── Scroll Reveal ─────────────────────────────────────────────────────────────

class _RevealOnScroll extends StatefulWidget {
  const _RevealOnScroll({
    required this.child,
    required this.scrollController,
    this.delay = 0,
  });

  final Widget child;
  final ScrollController scrollController;
  final int delay;

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    widget.scrollController.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_checkVisibility);
    _ctrl.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final topY = box.localToGlobal(Offset.zero).dy;
    final viewH = MediaQuery.of(context).size.height;
    if (topY < viewH * 0.92) {
      _triggered = true;
      widget.scrollController.removeListener(_checkVisibility);
      if (widget.delay > 0) {
        Future.delayed(Duration(milliseconds: widget.delay), () {
          if (mounted) _ctrl.forward();
        });
      } else {
        _ctrl.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: KeyedSubtree(key: _key, child: widget.child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CategorySelectionSection extends StatelessWidget {
  const _CategorySelectionSection({
    required this.store,
    this.onCategorySelected,
  });

  final DrameStore store;
  final VoidCallback? onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
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
            const _SectionHeader(
              eyebrow: '6가지 전문 드론 서비스',
              title: '어떤 서비스가 필요하신가요?',
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 1040 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: store.categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: compact ? 116 : 164,
                  ),
                  itemBuilder: (context, index) {
                    final category = store.categories[index];
                    return _ServiceCategoryCard(
                      key: ValueKey('category-${category.id}'),
                      category: category,
                      selected: store.selectedCategory?.id == category.id,
                      onTap: () {
                        store.selectCategory(category);
                        onCategorySelected?.call();
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

class _AreaSelectionSection extends StatelessWidget {
  const _AreaSelectionSection({required this.store, this.onAreaSelected});

  final DrameStore store;
  final VoidCallback? onAreaSelected;

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
            _AreaFilter(store: store, onAreaSelected: onAreaSelected),
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
                      constraints.maxWidth >= 1040 ? 3 : 2;
                  // 모바일 2열에서는 카드 높이를 줄임 (이미지+텍스트 최적화)
                  final cardHeight =
                      columns == 2 && constraints.maxWidth < 760 ? 320 : 430;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.pilots.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: cardHeight.toDouble(),
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

class _ServiceCategoryCard extends StatefulWidget {
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
  State<_ServiceCategoryCard> createState() => _ServiceCategoryCardState();
}

class _ServiceCategoryCardState extends State<_ServiceCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final active = widget.selected || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                widget.selected
                    ? const Color(0xFFEEF0F3)
                    : _hovered
                    ? const Color(0xFFF7F7F7)
                    : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  widget.selected
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFDEE1E6),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow:
                active && !widget.selected
                    ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child:
              compact
                  ? Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              widget.selected
                                  ? const Color(0xFFDEE1E6)
                                  : const Color(0xFFEEF0F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.category.icon,
                          color: const Color(0xFF0A0B0D),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.category.label,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0B0D),
                                height: 1.3,
                              ),
                            ),
                            Text(
                              widget.category.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF7C828A),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              widget.selected
                                  ? const Color(0xFFDEE1E6)
                                  : const Color(0xFFEEF0F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.category.icon,
                          color: const Color(0xFF0A0B0D),
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.category.label,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A0B0D),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7C828A),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
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
    final compact = MediaQuery.sizeOf(context).width < 760;
    final imgH = compact ? 120.0 : 190.0;
    final pad = compact ? 12.0 : 18.0;

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
              height: imgH,
              width: double.infinity,
              child:
                  pilot.portfolioImages.isNotEmpty
                      ? _NetworkCover(imageUrl: pilot.portfolioImages.first)
                      : pilot.avatarUrl != null
                      ? _NetworkCover(imageUrl: pilot.avatarUrl!)
                      : const _EmptyOperatorCover(),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (priority) ...<Widget>[
                    const _PriorityBadge(),
                    SizedBox(height: compact ? 8 : 14),
                  ],
                  Text(
                    pilot.name,
                    style:
                        compact
                            ? AppText.smallStrong.copyWith(fontSize: 14)
                            : AppText.portfolioTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 4 : 7),
                  Text(
                    pilot.intro,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardSubtitle,
                  ),
                  SizedBox(height: compact ? 8 : 14),
                  Wrap(
                    spacing: compact ? 4 : 7,
                    runSpacing: compact ? 4 : 7,
                    children:
                        pilot.categories
                            .take(compact ? 2 : pilot.categories.length)
                            .map((c) => _MiniChip(label: c))
                            .toList(),
                  ),
                  SizedBox(height: compact ? 10 : 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          pilot.priceLabel,
                          style: AppText.smallStrong,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _navy,
                        size: 18,
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

// ── Operator Feed Tab Page ────────────────────────────────────────────────────

class _OperatorFeedTabPage extends StatefulWidget {
  const _OperatorFeedTabPage({required this.store});
  final DrameStore store;

  @override
  State<_OperatorFeedTabPage> createState() => _OperatorFeedTabPageState();
}

class _OperatorFeedTabPageState extends State<_OperatorFeedTabPage> {
  String _selectedRegion = '전체';
  String _selectedCategory = '전체';
  String _selectedSort = '인기순';

  static const List<String> _regions = <String>[
    '전체',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
    '대전',
  ];

  static const List<String> _categories = <String>[
    '전체',
    '항공촬영',
    '농약방제',
    '측량·매핑',
    '시설점검',
    '부동산',
    '행사촬영',
  ];

  static const List<String> _sorts = <String>['인기순', '최신순'];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Container(
      width: double.infinity,
      color: DC.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PageShell(
            top: 40,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _OperatorFeedSection(store: widget.store),
                const SizedBox(height: 42),
                const Text('전체피드', style: AppText.cardTitle),
              ],
            ),
          ),
          _FeedFilterBar(
            compact: compact,
            centered: true,
            selectedRegion: _selectedRegion,
            selectedCategory: _selectedCategory,
            selectedSort: _selectedSort,
            regions: _regions,
            categories: _categories,
            sorts: _sorts,
            onRegionChanged: (v) => setState(() => _selectedRegion = v),
            onCategoryChanged: (v) => setState(() => _selectedCategory = v),
            onSortChanged: (v) => setState(() => _selectedSort = v),
          ),
          _PageShell(
            top: 14,
            bottom: 80,
            child: DroneFeedSection(
              region: _selectedRegion,
              category: _selectedCategory,
              sort: _selectedSort,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operator Portfolio Builder Section ───────────────────────────────────────

class _OperatorPortfolioBuilderSection extends StatefulWidget {
  const _OperatorPortfolioBuilderSection({required this.store});
  final DrameStore store;

  @override
  State<_OperatorPortfolioBuilderSection> createState() =>
      _OperatorPortfolioBuilderSectionState();
}

class _OperatorPortfolioBuilderSectionState
    extends State<_OperatorPortfolioBuilderSection> {
  bool _editing = false;
  bool _saving = false;
  int _previewTab = 0;

  late TextEditingController _introCtrl;
  late TextEditingController _descCtrl;
  late List<TextEditingController> _imageUrlCtrls;
  late Set<String> _selectedCategories;
  late Set<String> _selectedAreas;

  @override
  void initState() {
    super.initState();
    _resetFromPilot(widget.store.selectedPilot);
  }

  void _resetFromPilot(DronePilot? p) {
    _introCtrl = TextEditingController(text: p?.intro ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageUrlCtrls =
        (p?.portfolioImages.isNotEmpty == true)
            ? p!.portfolioImages
                .map((u) => TextEditingController(text: u))
                .toList()
            : <TextEditingController>[TextEditingController()];
    _selectedCategories = Set<String>.from(p?.categories ?? <String>[]);
    _selectedAreas = Set<String>.from(p?.availableAreas ?? <String>[]);
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _imageUrlCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.store.updateOperatorProfile(
        intro: _introCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryLabels: _selectedCategories.toList(),
        areaNames: _selectedAreas.toList(),
        portfolioImageUrls: _imageUrlCtrls.map((c) => c.text.trim()).toList(),
      );
      if (mounted) setState(() => _editing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: _navy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancelEdit() {
    final p = widget.store.selectedPilot;
    _introCtrl.text = p?.intro ?? '';
    _descCtrl.text = p?.description ?? '';
    for (final c in _imageUrlCtrls) {
      c.dispose();
    }
    _imageUrlCtrls =
        (p?.portfolioImages.isNotEmpty == true)
            ? p!.portfolioImages
                .map((u) => TextEditingController(text: u))
                .toList()
            : <TextEditingController>[TextEditingController()];
    _selectedCategories = Set<String>.from(p?.categories ?? <String>[]);
    _selectedAreas = Set<String>.from(p?.availableAreas ?? <String>[]);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: _PageShell(
        top: compact ? 8 : 48,
        bottom: compact ? 24 : 80,
        child: _editing ? _buildEditView() : _buildPreviewView(),
      ),
    );
  }

  Widget _buildPreviewView() {
    final pilot = widget.store.selectedPilot;
    final compact = MediaQuery.sizeOf(context).width < 760;

    if (!compact) {
      // ── Web layout ──────────────────────────────────────────────────────
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('포트폴리오 미리보기', style: AppText.cardTitle),
                    SizedBox(height: 6),
                    Text(
                      '고객에게 보여지는 내 프로필 페이지입니다.',
                      style: AppText.cardSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('편집하기'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  textStyle: AppText.button,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: _line),
          const SizedBox(height: 32),
          if (pilot == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Text('프로필 정보를 불러오는 중입니다.', style: AppText.cardSubtitle),
              ),
            )
          else ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _soft,
                    shape: BoxShape.circle,
                    border: Border.all(color: _line),
                  ),
                  child: () {
                      final imageUrl = pilot.avatarUrl ?? (pilot.portfolioImages.isNotEmpty ? pilot.portfolioImages.first : null);
                      return imageUrl != null
                          ? ClipOval(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: _muted,
                                    size: 32,
                                  ),
                            ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.flight_takeoff_rounded,
                              color: _muted,
                              size: 32,
                            ),
                          );
                    }(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(pilot.name, style: AppText.cardTitle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: <Widget>[
                          _PortfolioMeta(
                            icon: Icons.place_outlined,
                            text: pilot.location,
                          ),
                          _PortfolioMeta(
                            icon: Icons.sell_outlined,
                            text: pilot.specialty,
                          ),
                          _PortfolioMeta(
                            icon: Icons.map_outlined,
                            text: pilot.availableAreas.join(', '),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(pilot.intro, style: AppText.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: _line),
            const SizedBox(height: 28),
            const Text('서비스 상세설명', style: AppText.smallStrong),
            const SizedBox(height: 12),
            Text(
              pilot.description.isEmpty ? '(설명 없음)' : pilot.description,
              style: AppText.cardSubtitle,
            ),
            if (pilot.portfolioImages.isNotEmpty) ...<Widget>[
              const SizedBox(height: 36),
              const Text('사진 포트폴리오', style: AppText.smallStrong),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pilot.portfolioImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 200,
                ),
                itemBuilder:
                    (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pilot.portfolioImages[index],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: _soft,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: _muted,
                                ),
                              ),
                            ),
                      ),
                    ),
              ),
            ],
          ],
        ],
      );
    }

    // ── Mobile compact layout ────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('포트폴리오 미리보기', style: AppText.cardTitle),
                  SizedBox(height: 2),
                  Text(
                    '고객에게 보이는 내 프로필 페이지',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: Color(0xFF7C828A),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('편집'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (pilot == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('프로필 정보를 불러오는 중입니다.', style: AppText.metricLabel),
            ),
          )
        else ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: _line),
                ),
                child: () {
                    final imageUrl = pilot.avatarUrl ?? (pilot.portfolioImages.isNotEmpty ? pilot.portfolioImages.first : null);
                    return imageUrl != null
                        ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: Color(0xFF7C828A),
                                  size: 20,
                                ),
                          ),
                        )
                        : const Center(
                          child: Icon(
                            Icons.flight_takeoff_rounded,
                            color: Color(0xFF7C828A),
                            size: 20,
                          ),
                        );
                  }(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pilot.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0B0D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: Color(0xFF7C828A),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${pilot.location}  ·  ${pilot.specialty}',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: Color(0xFF7C828A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (pilot.intro.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        pilot.intro,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: Color(0xFF7C828A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                GestureDetector(
                  onTap: () => setState(() => _previewTab = i),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 8, right: i < 2 ? 20 : 0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              _previewTab == i ? _primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      const <String>['포트폴리오', '리뷰', '정보'][i],
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            _previewTab == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color:
                            _previewTab == i
                                ? _primary
                                : const Color(0xFF7C828A),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 12),
          if (_previewTab == 0) ..._buildMobilePortfolioTab(pilot),
          if (_previewTab == 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('아직 리뷰가 없습니다', style: AppText.metricLabel),
              ),
            ),
          if (_previewTab == 2) _buildMobileInfoTab(pilot),
        ],
      ],
    );
  }

  List<Widget> _buildMobilePortfolioTab(DronePilot pilot) {
    final images = pilot.portfolioImages;
    final feedPosts = widget.store.myFeedPosts;
    return <Widget>[
      if (images.isNotEmpty)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder:
              (context, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: _soft,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: _muted,
                          size: 20,
                        ),
                      ),
                    ),
              ),
        )
      else
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('사진 포트폴리오가 없습니다', style: AppText.metricLabel),
          ),
        ),
      const SizedBox(height: 20),
      const Text('서비스 상세설명', style: AppText.smallStrong),
      const SizedBox(height: 8),
      Text(
        pilot.description.isEmpty ? '(설명 없음)' : pilot.description,
        style: AppText.cardSubtitle,
      ),
      if (feedPosts.isNotEmpty) ...<Widget>[
        const SizedBox(height: 20),
        const Text('내 피드', style: AppText.smallStrong),
        const SizedBox(height: 12),
        ...feedPosts.map((post) => _PreviewFeedTile(post: post)),
      ],
    ];
  }

  Widget _buildMobileInfoTab(DronePilot pilot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PortfolioMeta(icon: Icons.place_outlined, text: pilot.location),
        const SizedBox(height: 8),
        _PortfolioMeta(icon: Icons.sell_outlined, text: pilot.specialty),
        const SizedBox(height: 8),
        _PortfolioMeta(
          icon: Icons.map_outlined,
          text: pilot.availableAreas.join(', '),
        ),
      ],
    );
  }

  Widget _buildEditView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('포트폴리오 편집', style: AppText.cardTitle),
                  SizedBox(height: 6),
                  Text(
                    '변경 후 저장하면 고객 페이지에 바로 반영됩니다.',
                    style: AppText.cardSubtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _saving ? null : _cancelEdit,
              style: TextButton.styleFrom(foregroundColor: _muted),
              child: const Text('취소'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                textStyle: AppText.button,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _saving
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('저장하기'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(color: _line),
        const SizedBox(height: 28),
        _EditField(
          label: '한줄 소개',
          hint: '예: 전국 드론 촬영 전문 운용자입니다.',
          controller: _introCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _EditField(
          label: '서비스 상세설명',
          hint: '제공하는 서비스, 장비, 경력 등을 자세히 작성해주세요.',
          controller: _descCtrl,
          maxLines: 6,
        ),
        const SizedBox(height: 28),
        const Text('포트폴리오 이미지 URL', style: AppText.smallStrong),
        const SizedBox(height: 6),
        const Text('이미지 주소(URL)를 한 줄씩 입력하세요.', style: AppText.cardSubtitle),
        const SizedBox(height: 14),
        ..._imageUrlCtrls.asMap().entries.map((entry) {
          final i = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: 'https://example.com/image.jpg',
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
                if (_imageUrlCtrls.length > 1) ...<Widget>[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ctrl.dispose();
                      setState(() => _imageUrlCtrls.removeAt(i));
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: _muted,
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () {
            setState(() => _imageUrlCtrls.add(TextEditingController()));
          },
          icon: const Icon(Icons.add),
          label: const Text('URL 추가'),
          style: TextButton.styleFrom(foregroundColor: _navy),
        ),
      ],
    );
  }
}

class _PreviewFeedTile extends StatelessWidget {
  const _PreviewFeedTile({required this.post});

  final OperatorFeedPost post;

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        post.imageBytes != null
            ? MemoryImage(Uint8List.fromList(post.imageBytes!)) as ImageProvider
            : post.imageUrl != null
            ? NetworkImage(post.imageUrl!) as ImageProvider
            : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (imageProvider != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (post.caption.isNotEmpty)
                  Text(post.caption, style: AppText.cardSubtitle),
                const SizedBox(height: 4),
                Text(
                  '${post.createdAt.year}.${post.createdAt.month.toString().padLeft(2, '0')}.${post.createdAt.day.toString().padLeft(2, '0')}',
                  style: AppText.metricLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioMeta extends StatelessWidget {
  const _PortfolioMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: _muted, size: 16),
        const SizedBox(width: 4),
        Text(text, style: AppText.cardSubtitle),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppText.smallStrong),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}

// ── Pilot Dashboard Section ───────────────────────────────────────────────────

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
            _IncomingRequestsPanel(store: store),
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
    final serviceText =
        store.selectedPilot?.categories.isNotEmpty == true
            ? store.selectedPilot!.categories.join(' · ')
            : '운용자 등록을 완료하면 제공 서비스가 표시됩니다.';
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
                backgroundImage: store.selectedPilot?.avatarUrl != null
                    ? NetworkImage(store.selectedPilot!.avatarUrl!)
                    : null,
                child: store.selectedPilot?.avatarUrl == null
                    ? Text(
                        nickname.characters.first,
                        style: AppText.cardTitle,
                      )
                    : null,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: AppText.portfolioTitle),
                    const SizedBox(height: 6),
                    Text(serviceText, style: AppText.cardSubtitle),
                  ],
                ),
              ),
              if (store.operatorRegistrationCompleted)
                TextButton.icon(
                  onPressed: () => context.go('/operator/mypage'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('등록 정보 수정'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5B616E),
                    textStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(children: <Widget>[_OperatorReviewBadge(store: store)]),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/operator/portfolio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    textStyle: AppText.button,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('포트폴리오 편집하기'),
                ),
              ),
              if (!store.operatorRegistrationCompleted) ...<Widget>[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/pilot/register'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      textStyle: AppText.button,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('운용자 등록'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OperatorReviewBadge extends StatelessWidget {
  const _OperatorReviewBadge({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final verified = store.operatorVerified;
    final pending = store.operatorReviewPending;
    final color =
        verified
            ? const Color(0xFF059669)
            : pending
            ? _primary
            : const Color(0xFFD97706);
    final background =
        verified
            ? const Color(0xFFE8F9F1)
            : pending
            ? const Color(0xFFEEF4FF)
            : const Color(0xFFFEF3C7);
    final icon =
        verified
            ? Icons.verified_rounded
            : pending
            ? Icons.hourglass_top_rounded
            : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            store.operatorReviewLabel,
            style: AppText.chip.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
  const _IncomingRequestsPanel({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final allRequests = store.pilotWorkRequests;
    final previewRequests = allRequests.take(3).toList();
    if (previewRequests.isEmpty) {
      return const _EmptyRequestPanel();
    }
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
                '${allRequests.length}건 대기 중',
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

class _EmptyRequestPanel extends StatelessWidget {
  const _EmptyRequestPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: const Text('아직 받은 요청이 없습니다.', style: AppText.cardSubtitle),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({required this.request});

  final PilotWorkRequest request;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _hovered = false;

  bool get _isNew => widget.request.status == '신규';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap:
            () => _openPilotRequestReviewPage(
              context,
              initialRequest: widget.request,
            ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(22),
          // hover: lift up by offsetting via transform + shadow
          transform:
              _hovered
                  ? (Matrix4.identity()..translate(0.0, -4.0))
                  : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // 신규: 초록 테두리, 마감임박: 빨간, 그 외: 기본
            border: Border.all(
              color:
                  _isNew
                      ? const Color(0xFF05B169)
                      : widget.request.status == '마감 임박'
                      ? const Color(0xFFCF202F)
                      : _hovered
                      ? const Color(0xFF0052FF)
                      : _line,
              width: _isNew || widget.request.status == '마감 임박' ? 1.5 : 1,
            ),
            boxShadow:
                _hovered
                    ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _MiniChip(label: widget.request.location),
                  const Spacer(),
                  // 신규 상태는 색 테두리만; 텍스트 배지로 상태 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isNew
                              ? const Color(0xFFEBFAF3)
                              : widget.request.status == '마감 임박'
                              ? const Color(0xFFFFF1F0)
                              : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.request.status,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            _isNew
                                ? const Color(0xFF05B169)
                                : widget.request.status == '마감 임박'
                                ? const Color(0xFFCF202F)
                                : const Color(0xFF7C828A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.request.category,
                style: AppText.smallStrong.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.request.budget} · ${widget.request.dateRange}',
                style: AppText.cardSubtitle,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      () => _openPilotRequestReviewPage(
                        context,
                        initialRequest: widget.request,
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
      ),
    );
  }
}

class _PilotRequestReviewPage extends StatefulWidget {
  const _PilotRequestReviewPage({this.initialRequest});

  final PilotWorkRequest? initialRequest;

  @override
  State<_PilotRequestReviewPage> createState() =>
      _PilotRequestReviewPageState();
}

class _PilotRequestReviewPageState extends State<_PilotRequestReviewPage> {
  PilotWorkRequest? selectedRequest;
  final Set<String> _completedRequestIds = {};
  String? _expandedRequestId; // compact 아코디언 전용

  @override
  void initState() {
    super.initState();
    selectedRequest = widget.initialRequest;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 980;
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        final requests = store.pilotWorkRequests;
        selectedRequest ??= requests.isEmpty ? null : requests.first;
        final current = selectedRequest;
        final currentCompleted =
            current != null &&
            (_completedRequestIds.contains(current.id) ||
                current.status == '견적 보냄');
        if (current == null) {
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
                                            : context.go('/home'),
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: _navy,
                                tooltip: '뒤로가기',
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => context.go('/home'),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('모두의 드론', style: HomeText.logo),
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
                    child: Center(
                      child: Text(
                        '받은 견적 요청이 없습니다.',
                        style: AppText.portfolioTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (current.status == '신규') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              unawaited(store.markOperatorRequestSeen(current));
            }
          });
        }
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
                                          : context.go('/home'),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: _navy,
                              tooltip: '뒤로가기',
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => context.go('/home'),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('모두의 드론', style: HomeText.logo),
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
                                    requests: requests,
                                    selected: current,
                                    expandedId: _expandedRequestId,
                                    onSelected: (request) {
                                      setState(() {
                                        if (_expandedRequestId == request.id) {
                                          // 같은 카드 탭 → 닫기
                                          _expandedRequestId = null;
                                        } else {
                                          // 다른 카드 탭 → 열기
                                          _expandedRequestId = request.id;
                                          selectedRequest = request;
                                          unawaited(
                                            store.markOperatorRequestSeen(
                                              request,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    inlineDetailBuilder: (request) {
                                      final isCompleted =
                                          _completedRequestIds.contains(
                                            request.id,
                                          ) ||
                                          request.status == '견적 보냄';
                                      return _RequestReviewDetail(
                                        request: request,
                                        isCompleted: isCompleted,
                                        onComplete: (
                                          message,
                                          proposedPrice,
                                        ) async {
                                          await store.submitOperatorQuote(
                                            request,
                                            message,
                                            proposedPrice: proposedPrice,
                                          );
                                          if (!mounted) return;
                                          setState(
                                            () => _completedRequestIds.add(
                                              request.id,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                            : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _RequestReviewList(
                                      requests: requests,
                                      selected: current,
                                      onSelected: (request) {
                                        setState(
                                          () => selectedRequest = request,
                                        );
                                        unawaited(
                                          store.markOperatorRequestSeen(
                                            request,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _RequestReviewDetail(
                                      request: current,
                                      isCompleted: currentCompleted,
                                      onComplete: (
                                        message,
                                        proposedPrice,
                                      ) async {
                                        await store.submitOperatorQuote(
                                          current,
                                          message,
                                          proposedPrice: proposedPrice,
                                        );
                                        if (!mounted) return;
                                        setState(
                                          () => _completedRequestIds.add(
                                            current.id,
                                          ),
                                        );
                                      },
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
      },
    );
  }
}

class _RequestReviewList extends StatefulWidget {
  const _RequestReviewList({
    required this.requests,
    required this.selected,
    required this.onSelected,
    this.inlineDetailBuilder,
    this.expandedId,
  });

  final List<PilotWorkRequest> requests;
  final PilotWorkRequest selected;
  final ValueChanged<PilotWorkRequest> onSelected;
  final Widget Function(PilotWorkRequest)? inlineDetailBuilder;
  /// compact 아코디언용: null이면 인라인 detail 비활성화
  final String? expandedId;

  @override
  State<_RequestReviewList> createState() => _RequestReviewListState();
}

class _RequestReviewListState extends State<_RequestReviewList> {
  // 0=전체, 1=견적받음, 2=견적보냄
  int _filter = 0;

  List<PilotWorkRequest> get _filtered {
    return switch (_filter) {
      1 =>
        widget.requests
            .where((r) => r.status == '신규' || r.status == '확인 중')
            .toList(),
      2 => widget.requests.where((r) => r.status == '견적 보냄').toList(),
      _ => widget.requests,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final received =
        widget.requests
            .where((r) => r.status == '신규' || r.status == '확인 중')
            .length;
    final sent = widget.requests.where((r) => r.status == '견적 보냄').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('견적 요청 ${widget.requests.length}건', style: AppText.portfolioTitle),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              _RequestTabChip(
                label: '전체 ${widget.requests.length}',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0),
              ),
              const SizedBox(width: 8),
              _RequestTabChip(
                label: '견적받음 $received',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1),
              ),
              const SizedBox(width: 8),
              _RequestTabChip(
                label: '견적보냄 $sent',
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('해당 항목이 없습니다.', style: AppText.cardSubtitle),
            ),
          )
        else
          ...filtered.map((request) {
            final isSelected = widget.selected.id == request.id;
            // expandedId가 제공된 경우에만 사용 (null이면 아무 카드도 열리지 않음)
            final isExpanded = widget.expandedId == request.id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequestReviewCard(
                    request: request,
                    selected: isSelected,
                    onTap: () => widget.onSelected(request),
                  ),
                ),
                if (isExpanded && widget.inlineDetailBuilder != null) ...<Widget>[
                  widget.inlineDetailBuilder!(request),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }),
      ],
    );
  }
}

class _RequestTabChip extends StatelessWidget {
  const _RequestTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? _navy : const Color(0xFF7C828A);
    final bg = selected ? const Color(0xFFF2F3F5) : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? fg : const Color(0xFFDEE1E6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _RequestReviewCard extends StatefulWidget {
  const _RequestReviewCard({
    required this.request,
    required this.selected,
    required this.onTap,
  });

  final PilotWorkRequest request;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_RequestReviewCard> createState() => _RequestReviewCardState();
}

class _RequestReviewCardState extends State<_RequestReviewCard> {
  bool _hovered = false;

  bool get _isReviewing =>
      widget.request.status == '신규' || widget.request.status == '확인 중';
  bool get _isQuoteSent => widget.request.status == '견적 보냄';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            // selected → 회색 배경 (토글처럼), hover → 약한 회색
            color:
                widget.selected
                    ? const Color(0xFFF2F3F5)
                    : _hovered
                    ? const Color(0xFFF8F9FA)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.selected
                      ? const Color(0xFF0052FF)
                      : _hovered
                      ? const Color(0xFFB0B8C8)
                      : _line,
              width: widget.selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _MiniChip(label: widget.request.category),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isReviewing
                              ? const Color(0xFFEBFAF3)
                              : _isQuoteSent
                              ? const Color(0xFFEEF4FF)
                              : widget.request.status == '마감 임박'
                              ? const Color(0xFFFFF1F0)
                              : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.request.status,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            _isReviewing
                                ? const Color(0xFF05B169)
                                : _isQuoteSent
                                ? _navy
                                : widget.request.status == '마감 임박'
                                ? const Color(0xFFCF202F)
                                : const Color(0xFF7C828A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: <Widget>[
                  _RequestMeta(
                    icon: Icons.place_outlined,
                    text:
                        '${widget.request.location} (${widget.request.distance})',
                  ),
                  _RequestMeta(
                    icon: Icons.calendar_today_outlined,
                    text: widget.request.dateRange,
                  ),
                  _RequestMeta(
                    icon: Icons.paid_outlined,
                    text: widget.request.budget,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(widget.request.summary, style: AppText.cardSubtitle),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.request.progress,
                      style: AppText.metricLabel,
                    ),
                  ),
                  Text(
                    widget.request.remaining,
                    style: AppText.smallStrong.copyWith(color: _navy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestReviewDetail extends ConsumerWidget {
  const _RequestReviewDetail({
    required this.request,
    required this.isCompleted,
    required this.onComplete,
  });

  final PilotWorkRequest request;
  final bool isCompleted;
  final Future<void> Function(String message, int? proposedPrice) onComplete;

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    try {
      final roomId =
          await ref.read(chatViewModelProvider).getOrCreateRoom(request.id);
      if (context.mounted) {
        context.push(
          '/chat/$roomId',
          extra: <String, String>{
            'otherPartyName': request.client,
            'category': request.category,
          },
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (isCompleted) ...<Widget>[
            const SizedBox(height: 18),
            const Divider(color: _line),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openChat(context, ref),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('의뢰자와 채팅하기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0052FF),
                  side: const BorderSide(color: Color(0xFF0052FF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontFamily: DrameTextStyles.fontFamily,
                    fontSize: DrameTextStyles.labelSize,
                    fontWeight: DrameTextStyles.semiBold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(color: _line),
          const SizedBox(height: 18),
          _QuoteSubmitPaywall(
            key: ValueKey(request.id),
            requestId: request.id,
            isCompleted: isCompleted,
            onComplete: onComplete,
            initialMessage: request.myQuoteMessage,
            initialPrice: request.myQuotePrice,
          ),
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

class _QuoteSentRow extends StatelessWidget {
  const _QuoteSentRow({
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
        SizedBox(width: 64, child: Text(label, style: AppText.metricLabel)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppText.cardSubtitle)),
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
    final verified = store.operatorVerified;
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
                    child: Icon(
                      verified
                          ? Icons.verified_user_outlined
                          : Icons.hourglass_top_rounded,
                      color: verified ? _mint : _primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    verified ? '운용자 검증이 완료되었습니다' : '운용자 인증 확인중입니다',
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    verified
                        ? '이제 받은 요청을 확인하고 등록 정보를 마이페이지에서 수정할 수 있습니다.'
                        : '제출한 인증 정보는 운영팀 확인 후 검증 완료로 전환됩니다.',
                    textAlign: TextAlign.center,
                    style: AppText.cardSubtitle,
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            store.acknowledgeRegistrationDone();
                            context.push('/operator/mypage');
                          },
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
                          onPressed: () {
                            store.acknowledgeRegistrationDone();
                            context.replace('/operator');
                          },
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
              onPressed: () => context.go('/home'),
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
                      onPressed: () => context.go('/home'),
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
              onPressed: () {
                store.closePilotOnboarding();
                context.go('/operator');
              },
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
            final locked = entry.key > store.pilotOnboardingStep;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: locked
                    ? null
                    : () => store.goToPilotOnboardingStep(entry.key),
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
                        child: completed
                            ? const Icon(
                                Icons.check_rounded,
                                color: _ink,
                                size: 17,
                              )
                            : locked
                                ? const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFFC5CDD8),
                                    size: 14,
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
                            color: locked
                                ? const Color(0xFFC5CDD8)
                                : active
                                    ? _ink
                                    : const Color(0xFFA3B0C2),
                          ),
                        ),
                      ),
                      if (locked)
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFFC5CDD8),
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
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await store.nextPilotOnboardingStep();
                    } catch (error) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            error.toString().replaceFirst('Exception: ', ''),
                          ),
                          backgroundColor: _ink,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
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

class _LicenseNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = limited.length <= 2
        ? limited
        : '${limited.substring(0, 2)}-${limited.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
          hint: '예: 24-000123',
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            _LicenseNumberFormatter(),
          ],
          onChanged: (value) => store.updatePilotLicense(number: value),
        ),
        const SizedBox(height: 18),
        _PdfUploadField(
          label: '자격증 파일 (PDF)',
          fileName: data.licenseFileName,
          onPick: (bytes, name) async {
            try {
              await store.uploadLicensePdf(bytes, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('자격증 파일이 업로드되었습니다.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('업로드 실패: $e')),
                );
              }
            }
          },
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
        const SizedBox(height: 18),
        _PdfUploadField(
          label: '사업자등록증 파일 (PDF)',
          fileName: data.businessFileName,
          onPick: (bytes, name) async {
            try {
              await store.uploadBusinessPdf(bytes, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('사업자등록증 파일이 업로드되었습니다.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('업로드 실패: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _PdfUploadField extends StatefulWidget {
  const _PdfUploadField({
    required this.label,
    required this.fileName,
    required this.onPick,
  });

  final String label;
  final String? fileName;
  final Future<void> Function(List<int> bytes, String fileName) onPick;

  @override
  State<_PdfUploadField> createState() => _PdfUploadFieldState();
}

class _PdfUploadFieldState extends State<_PdfUploadField> {
  bool _uploading = false;

  Future<void> _pickFile() async {
    final input =
        web.HTMLInputElement()
          ..type = 'file'
          ..accept = 'application/pdf';
    input.click();
    await Future.any(<Future<void>>[
      input.onChange.first.then((_) {}),
      Future<void>.delayed(const Duration(minutes: 2)),
    ]);
    final file = input.files?.item(0);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final reader = web.FileReader();
      final completer = Completer<Uint8List>();
      reader.addEventListener(
        'load',
        (web.Event e) {
          final result = reader.result;
          if (result == null) {
            completer.completeError('파일을 읽을 수 없습니다.');
            return;
          }
          completer.complete(
            Uint8List.view((result as JSArrayBuffer).toDart),
          );
        }.toJS,
      );
      reader.addEventListener(
        'error',
        ((web.Event e) => completer.completeError('파일 읽기 오류')).toJS,
      );
      reader.readAsArrayBuffer(file);
      final bytes = await completer.future;
      if (!mounted) return;
      await widget.onPick(bytes.toList(), file.name);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null && widget.fileName!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: AppText.cardSubtitle),
        const SizedBox(height: 8),
        InkWell(
          onTap: _uploading ? null : _pickFile,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  hasFile
                      ? Icons.picture_as_pdf_rounded
                      : Icons.upload_file_rounded,
                  size: 20,
                  color: hasFile ? const Color(0xFFDC2626) : _navy,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _uploading
                        ? '업로드 중…'
                        : (hasFile ? widget.fileName! : 'PDF 파일을 선택하세요'),
                    style: AppText.cardSubtitle.copyWith(
                      color: hasFile ? _navy : const Color(0xFF7C828A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasFile && !_uploading)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
              ],
            ),
          ),
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
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
            LengthLimitingTextInputFormatter(40),
          ],
          onChanged: (value) => store.updatePilotInsurance(number: value),
        ),
        const SizedBox(height: 18),
        _PilotTextField(
          label: '가입된 기체 번호',
          initialValue: data.insuranceDroneNumber,
          hint: '예: D-2024-001',
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(60),
          ],
          onChanged:
              (value) => store.updatePilotInsurance(droneNumber: value),
        ),
        const SizedBox(height: 18),
        _PdfUploadField(
          label: '보험 증권 파일 (PDF)',
          fileName: data.insuranceFileName,
          onPick: (bytes, name) async {
            try {
              await store.uploadInsurancePdf(bytes, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('보험 증권 파일이 업로드되었습니다.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('업로드 실패: $e')),
                );
              }
            }
          },
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
                const SizedBox(height: 12),
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
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  onChanged:
                      (value) => store.updatePilotDrone(
                        index,
                        registrationNumber: value,
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

  static const List<String> _regions = <String>[
    '서울', '경기', '인천', '강원', '충청', '전라', '경상', '제주',
  ];

  Set<String> _activeRegions(Set<String> areas) => _regions.where((r) {
    return areas.contains(r) || areas.any((a) => a.startsWith('$r '));
  }).toSet();

  Set<String> _activeDistricts(String region, Set<String> areas) {
    final result = <String>{};
    if (areas.contains(region)) result.add('전체');
    for (final d in defaultServiceDistricts[region] ?? <String>[]) {
      if (areas.contains('$region $d')) result.add(d);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final areas = store.pilotOnboarding.areas;
    final activeRegions = _activeRegions(areas);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('주요 활동 지역', style: AppText.smallStrong),
        const SizedBox(height: 10),
        _PilotChipGroup(
          values: _regions,
          selected: activeRegions,
          onTap: store.togglePilotRegion,
        ),
        for (final region in _regions.where(activeRegions.contains)) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            '$region 세부 지역',
            style: AppText.smallStrong,
          ),
          const SizedBox(height: 8),
          _PilotChipGroup(
            values: <String>[
              '전체',
              ...defaultServiceDistricts[region] ?? <String>[],
            ],
            selected: _activeDistricts(region, areas),
            onTap: (d) => store.togglePilotDistrict(region, d),
          ),
        ],
        const SizedBox(height: 18),
        const _PilotNotice('복수 지역을 선택할 수 있습니다. 선택 지역은 운용자 매칭 노출에 사용됩니다.'),
      ],
    );
  }
}

class _PilotTextField extends StatefulWidget {
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
  State<_PilotTextField> createState() => _PilotTextFieldState();
}

class _PilotTextFieldState extends State<_PilotTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _ctrl,
    keyboardType: widget.keyboardType,
    inputFormatters: widget.inputFormatters,
    onChanged: widget.onChanged,
    decoration: _pilotInputDecoration(label: widget.label, hint: widget.hint),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),
              selected: active,
              onSelected: (_) => onTap(value),
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFEEF0F3);
                }
                return Colors.white;
              }),
              showCheckmark: false,
              side: BorderSide(
                color: active ? const Color(0xFF9CA3AF) : _line,
                width: 1.4,
              ),
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
            ? store.allPilots
            : store.allPilots
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

class _AreaFilter extends StatefulWidget {
  const _AreaFilter({required this.store, this.onAreaSelected});

  final DrameStore store;
  final VoidCallback? onAreaSelected;

  @override
  State<_AreaFilter> createState() => _AreaFilterState();
}

class _AreaFilterState extends State<_AreaFilter> {
  final GlobalKey _districtRowKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final districts =
        store.selectedRegion == '전체'
            ? const <String>[]
            : defaultServiceDistricts[store.selectedRegion] ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AreaChipWrap(
          children:
              store.serviceAreas.map((area) {
                return _AreaChip(
                  key: ValueKey('area-$area'),
                  label: area,
                  selected: store.selectedRegion == area,
                  onTap: () {
                    store.selectRegion(area);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_districtRowKey.currentContext != null) {
                        _scrollTo(_districtRowKey);
                      } else {
                        widget.onAreaSelected?.call();
                      }
                    });
                  },
                );
              }).toList(),
        ),
        if (districts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _districtRowKey,
            child: Text(
              '${store.selectedRegion} 시·구 선택',
              style: AppText.smallStrong.copyWith(color: _navy),
            ),
          ),
          const SizedBox(height: 10),
          _AreaChipWrap(
            children: <Widget>[
              _AreaChip(
                key: const ValueKey('district-전체'),
                label: '전체',
                selected: store.selectedDistrict == '전체',
                onTap: () {
                  store.selectDistrict('전체');
                  widget.onAreaSelected?.call();
                },
                compact: true,
              ),
              ...districts.map((district) {
                return _AreaChip(
                  key: ValueKey('district-$district'),
                  label: district,
                  selected: store.selectedDistrict == district,
                  onTap: () {
                    store.selectDistrict(district);
                    widget.onAreaSelected?.call();
                  },
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
            _InfoRow(
              icon: Icons.category_outlined,
              label: '서비스',
              value: pilot.categories.join(', '),
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
    final compact = MediaQuery.sizeOf(context).width < 760;
    if (compact) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
        child: child,
      );
    }
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
              child: _PortfolioPreviewGrid(
                images: pilot.portfolioImages.isNotEmpty
                    ? pilot.portfolioImages
                    : pilot.avatarUrl != null
                    ? <String>[pilot.avatarUrl!]
                    : const <String>[],
              ),
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
                  Text(pilot.priceLabel, style: AppText.smallStrong),
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
    if (previewImages.isEmpty) {
      return const _EmptyOperatorCover();
    }

    if (previewImages.length == 1) {
      return _NetworkCover(imageUrl: previewImages.first);
    }

    return Row(
      children: <Widget>[
        Expanded(flex: 2, child: _NetworkCover(imageUrl: previewImages.first)),
        const SizedBox(width: 3),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _NetworkCover(imageUrl: previewImages[1]),
              ),
              if (previewImages.length > 2) ...<Widget>[
                const SizedBox(height: 3),
                Expanded(
                  child: _NetworkCover(imageUrl: previewImages[2]),
                ),
              ],
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

class _MobileAppBar extends StatelessWidget {
  const _MobileAppBar({
    required this.store,
    required this.onLoginTap,
    required this.onLogoTap,
    required this.onModeChanged,
  });

  final DrameStore store;
  final VoidCallback onLoginTap;
  final VoidCallback onLogoTap;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: onLogoTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('모드', style: HomeText.logo),
            ),
          ),
          const Spacer(),
          Container(
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _MobileToggleItem(
                  label: '이용자',
                  selected: !store.isPilotMode,
                  onTap: () => onModeChanged(false),
                ),
                _MobileToggleItem(
                  label: '운용자',
                  selected: store.isPilotMode,
                  onTap: () => onModeChanged(true),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onLoginTap,
            style: TextButton.styleFrom(
              textStyle: AppText.button,
              foregroundColor: _ink,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}

class _MobileToggleItem extends StatelessWidget {
  const _MobileToggleItem({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow:
              selected
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
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: _ink,
          ),
        ),
      ),
    );
  }
}

class _MobileUserHomePage extends StatelessWidget {
  const _MobileUserHomePage({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _CategorySelectionSection(store: store, onCategorySelected: () {}),
    );
  }
}

class _MobileSearchFlow extends StatelessWidget {
  const _MobileSearchFlow({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final hasCategory = store.selectedCategory != null;
    return hasCategory
        ? _SearchResultsPage(store: store)
        : _SearchCategoryPage(store: store);
  }
}

class _SearchCategoryPage extends StatelessWidget {
  const _SearchCategoryPage({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _PageShell(
        top: 28,
        bottom: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionHeader(
              eyebrow: '먼저 필요한 작업을 선택하세요',
              title: '카테고리별 드론 서비스',
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: store.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 148,
              ),
              itemBuilder: (context, index) {
                final category = store.categories[index];
                return _ServiceCategoryCard(
                  key: ValueKey('category-${category.id}'),
                  category: category,
                  selected: store.selectedCategory?.id == category.id,
                  onTap: () => store.selectCategory(category),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsPage extends StatelessWidget {
  const _SearchResultsPage({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: store.clearCategory,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _navy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  store.selectedCategory!.label,
                  style: AppText.smallStrong.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _line),
          _AreaSelectionSection(store: store),
          _OperatorListSection(store: store),
        ],
      ),
    );
  }
}

class _MobilePilotRequestsPage extends StatefulWidget {
  const _MobilePilotRequestsPage({required this.store});

  final DrameStore store;

  @override
  State<_MobilePilotRequestsPage> createState() =>
      _MobilePilotRequestsPageState();
}

class _MobilePilotRequestsPageState extends State<_MobilePilotRequestsPage> {
  String? _selectedId;
  int _filter = 0;

  List<PilotWorkRequest> _filtered(List<PilotWorkRequest> requests) {
    return switch (_filter) {
      1 =>
        requests.where((r) => r.status == '신규' || r.status == '확인 중').toList(),
      2 => requests.where((r) => r.status == '견적 보냄').toList(),
      _ => requests,
    };
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.store.pilotWorkRequests;
    final filtered = _filtered(requests);
    final received =
        requests.where((r) => r.status == '신규' || r.status == '확인 중').length;
    final sent = requests.where((r) => r.status == '견적 보냄').length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('받은 요청 · ${requests.length}건', style: AppText.portfolioTitle),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _RequestTabChip(
                  label: '전체 ${requests.length}',
                  selected: _filter == 0,
                  onTap: () => setState(() => _filter = 0),
                ),
                const SizedBox(width: 8),
                _RequestTabChip(
                  label: '견적받음 $received',
                  selected: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                const SizedBox(width: 8),
                _RequestTabChip(
                  label: '견적보냄 $sent',
                  selected: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
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
            ...filtered.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestReviewCard(
                  request: request,
                  selected: _selectedId == request.id,
                  onTap: () {
                    setState(() => _selectedId = request.id);
                    _showOperatorRequestSheet(
                      context,
                      request,
                      widget.store,
                    ).then((_) {
                      if (mounted) setState(() => _selectedId = null);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW COINBASE-STYLE SECTIONS
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBandDark extends StatefulWidget {
  const _HeroBandDark({
    required this.onGetQuoteTap,
    required this.onRegisterPilotTap,
  });

  final VoidCallback onGetQuoteTap;
  final VoidCallback onRegisterPilotTap;

  @override
  State<_HeroBandDark> createState() => _HeroBandDarkState();
}

class _HeroBandDarkState extends State<_HeroBandDark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _headFade;
  late final Animation<Offset> _headSlide;
  late final Animation<double> _subFade;
  late final Animation<Offset> _subSlide;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    );

    Animation<double> fade(double s, double e) => CurvedAnimation(
      parent: _ctrl,
      curve: Interval(s, e, curve: Curves.easeOut),
    );
    Animation<Offset> slide(double s, double e) =>
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(s, e, curve: Curves.easeOut),
          ),
        );

    _headFade = fade(0.00, 0.40);
    _headSlide = slide(0.00, 0.40);
    _subFade = fade(0.22, 0.60);
    _subSlide = slide(0.22, 0.60);
    _ctaFade = fade(0.45, 0.90);
    _ctaSlide = slide(0.45, 0.90);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final headSize = compact ? 36.0 : 56.0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFD6EEFF), Colors.white],
          stops: <double>[0.0, 1.0],
        ),
      ),
      child: _PageShell(
        top: compact ? 72 : 112,
        bottom: compact ? 80 : 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeTransition(
              opacity: _headFade,
              child: SlideTransition(
                position: _headSlide,
                child: Text(
                  '모든 드론 서비스를\n하나의 플랫폼에서',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: headSize,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: compact ? -0.8 : -1.5,
                    color: const Color(0xFF0A0B0D),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeTransition(
              opacity: _subFade,
              child: SlideTransition(
                position: _subSlide,
                child: const Text(
                  '  항공촬영부터 농업방제까지, 빠르게 견적을 받아보세요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: Color(0xFF5B616E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _ctaFade,
              child: SlideTransition(
                position: _ctaSlide,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: widget.onGetQuoteTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052FF),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        minimumSize: const Size(180, 60),
                        elevation: 0,
                      ),
                      child: const Text('지금 견적받기 →'),
                    ),
                    OutlinedButton(
                      onPressed: widget.onRegisterPilotTap,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A0B0D),
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: const StadiumBorder(),
                        side: const BorderSide(
                          color: Color(0xFFDEE1E6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        minimumSize: const Size(160, 60),
                      ),
                      child: const Text('기사 등록하기'),
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

// ── How It Works ──────────────────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;

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
            const _SectionHeader(
              eyebrow: '3단계로 끝나는 드론 서비스',
              title: '어떻게 작동하나요?',
            ),
            const SizedBox(height: 28),
            if (compact)
              Column(
                children: const <Widget>[
                  _HowItWorksStep(
                    number: '01',
                    title: '서비스 선택',
                    description: '항공촬영, 방제, 측량 등 필요한 드론 서비스를 카테고리에서 선택하세요.',
                  ),
                  SizedBox(height: 24),
                  _HowItWorksStep(
                    number: '02',
                    title: '기사 매칭',
                    description: '요청부터 일정 조율까지 한 흐름으로 맞는 운용자와 연결됩니다.',
                  ),
                  SizedBox(height: 24),
                  _HowItWorksStep(
                    number: '03',
                    title: '견적 확정',
                    description: '자격증과 포트폴리오를 보고 검증된 운용자를 선택해 작업을 진행하세요.',
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Expanded(
                    child: _HowItWorksStep(
                      number: '01',
                      title: '서비스 선택',
                      description: '항공촬영, 방제, 측량 등 필요한 드론 서비스를 카테고리에서 선택하세요.',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _HowItWorksStep(
                      number: '02',
                      title: '기사 매칭',
                      description: '요청부터 일정 조율까지 한 흐름으로 맞는 운용자와 연결됩니다.',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _HowItWorksStep(
                      number: '03',
                      title: '견적 확정',
                      description: '자격증과 포트폴리오를 보고 검증된 운용자를 선택해 작업을 진행하세요.',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDEE1E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0052FF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A0B0D),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF5B616E),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operator CTA Band ─────────────────────────────────────────────────────────

class _OperatorCtaBand extends StatelessWidget {
  const _OperatorCtaBand({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0B0D),
      child: _PageShell(
        top: 80,
        bottom: 80,
        child:
            compact
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '드론 기사이신가요?',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '모드에 등록하고 매달 검증된 프로젝트를 받아보세요.\n자격 확인부터 결제까지 플랫폼이 모두 처리합니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA8ACB3),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052FF),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        minimumSize: const Size(0, 52),
                        elevation: 0,
                      ),
                      child: const Text('등록하고 수입 올리기 →'),
                    ),
                  ],
                )
                : Row(
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '드론 기사이신가요?',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 44,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -1.2,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '모드에 등록하고 매달 검증된 프로젝트를 받아보세요.\n자격 확인부터 결제까지 플랫폼이 모두 처리합니다.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFA8ACB3),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052FF),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            minimumSize: const Size(0, 56),
                            elevation: 0,
                          ),
                          child: const Text('등록하고 수입 올리기 →'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      color: const Color(0xFF0F1117),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? DC.spLg : DC.spXxl,
              vertical: DC.spXxl,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: 1,
                  color: const Color(0xFF1E2128),
                  margin: const EdgeInsets.only(bottom: DC.spXxl),
                ),
                compact
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        _FooterBrand(),
                        SizedBox(height: DC.spXl),
                        _FooterLinks(
                          title: '서비스',
                          links: <String>['운용자 등록', '촬영자 찾기', '사용 안내'],
                        ),
                        SizedBox(height: DC.spLg),
                        _FooterLinks(
                          title: '회사',
                          links: <String>['회사소개', '공지사항', '이용약관', '개인정보처리방침'],
                        ),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Expanded(flex: 2, child: _FooterBrand()),
                        SizedBox(width: DC.spXxl),
                        Expanded(
                          child: _FooterLinks(
                            title: '서비스',
                            links: <String>['운용자 등록', '촬영자 찾기', '사용 안내'],
                          ),
                        ),
                        SizedBox(width: DC.spXxl),
                        Expanded(
                          child: _FooterLinks(
                            title: '회사',
                            links: <String>['회사소개', '공지사항', '이용약관', '개인정보처리방침'],
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
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
        DrameLogo(size: 22, onDark: true),
        SizedBox(height: DC.spXs),
        Text(
          '모두의 드론 — 드론 매칭 플랫폼',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: DC.spBase),
        Text(
          '© 2026 Mode Drone. All rights reserved.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.title, required this.links});

  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: DC.spSm),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: DC.spXs),
            child: Text(
              link,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
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

class _EmptyOperatorCover extends StatelessWidget {
  const _EmptyOperatorCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _soft,
      child: const Center(
        child: Icon(Icons.flight_takeoff_rounded, color: _muted, size: 40),
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

// ─── Quote Submit Paywall ────────────────────────────────────────────────────

class _QuoteSubmitPaywall extends ConsumerStatefulWidget {
  const _QuoteSubmitPaywall({
    super.key,
    required this.requestId,
    required this.isCompleted,
    required this.onComplete,
    this.initialMessage,
    this.initialPrice,
  });

  final String requestId;
  final bool isCompleted;
  final Future<void> Function(String message, int? proposedPrice) onComplete;
  final String? initialMessage;
  final int? initialPrice;

  @override
  ConsumerState<_QuoteSubmitPaywall> createState() =>
      _QuoteSubmitPaywallState();
}

class _QuoteSubmitPaywallState extends ConsumerState<_QuoteSubmitPaywall> {
  bool _unlocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkUnlocked();
  }

  Future<void> _checkUnlocked() async {
    final api = ref.read(dronePilotApiProvider);
    final unlocked = await api.isRequestUnlocked(widget.requestId);
    if (mounted) setState(() { _unlocked = unlocked; _loading = false; });
  }

  Future<void> _onPayTap() async {
    final api = ref.read(dronePilotApiProvider);
    await api.unlockRequest(widget.requestId);
    if (mounted) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    final section = _QuoteSubmitSection(
      isCompleted: widget.isCompleted,
      onComplete: widget.onComplete,
      initialMessage: widget.initialMessage,
      initialPrice: widget.initialPrice,
    );

    if (widget.isCompleted || _unlocked) return section;

    if (_loading) {
      return Stack(
        children: <Widget>[
          section,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        section,
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: InkWell(
              onTap: _onPayTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                      const Text(
                      '사전등록 혜택 수수료 무료!',
                      style: TextStyle(
                        color: Color(0xFF191919),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: DrameTextStyles.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Quote Submit Section ────────────────────────────────────────────────────

class _QuoteSubmitSection extends StatefulWidget {
  const _QuoteSubmitSection({
    required this.isCompleted,
    required this.onComplete,
    this.initialMessage,
    this.initialPrice,
  });

  final bool isCompleted;
  final Future<void> Function(String message, int? proposedPrice) onComplete;
  final String? initialMessage;
  final int? initialPrice;

  @override
  State<_QuoteSubmitSection> createState() => _QuoteSubmitSectionState();
}

class _QuoteSubmitSectionState extends State<_QuoteSubmitSection> {
  bool _submitting = false;
  bool _editing = false;
  late final TextEditingController _priceController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.initialPrice != null ? widget.initialPrice.toString() : '',
    );
    _messageController = TextEditingController(
      text:
          widget.initialMessage ??
          '안녕하세요. 요청 내용 기준으로 작업 가능합니다. 포함 범위, 가능 일정, 연락 가능한 전화번호나 카카오 채널을 함께 남깁니다.',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted && !_editing) {
      final priceText =
          widget.initialPrice != null
              ? '${(widget.initialPrice! / 10000).round()}만원'
              : null;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.check_circle_outline, color: _mint, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('견적을 보냈습니다.', style: AppText.smallStrong),
                ),
                TextButton(
                  onPressed: () => setState(() => _editing = true),
                  child: const Text('편집하기'),
                ),
              ],
            ),
            if (priceText != null || widget.initialMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(color: _line),
              const SizedBox(height: 10),
              if (priceText != null)
                _QuoteSentRow(label: '제안가격', value: priceText),
              if (widget.initialMessage != null &&
                  widget.initialMessage!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                _QuoteSentRow(
                  label: '메시지',
                  value: widget.initialMessage!,
                  multiLine: true,
                ),
              ],
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('견적 보내기', style: AppText.portfolioTitle),
        const SizedBox(height: 6),
        const Text('요청 내용을 확인한 뒤 이용자에게 견적을 보냅니다.', style: AppText.cardSubtitle),
        const SizedBox(height: 20),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: '제안가격',
            hintText: '예: 450000',
            suffixText: '원',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _focus, width: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _messageController,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: '견적 확정 메시지',
            hintText: '예: 촬영 범위, 포함 산출물, 가능 일정, 연락 가능한 전화번호/카카오 채널을 적어주세요.',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _focus, width: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: _line),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                _submitting
                    ? null
                    : () async {
                      final message = _messageController.text.trim();
                      final proposedPrice = int.tryParse(
                        _priceController.text.trim().replaceAll(',', ''),
                      );
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (dialogContext) => AlertDialog(
                              title: const Text('견적을 확정할까요?'),
                              content: Text(
                                message.isEmpty
                                    ? '제안가격 입력값 또는 요청 예산 기준으로 견적을 보냅니다.'
                                    : '아래 메시지로 견적을 보내겠습니까?\n\n$message',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(dialogContext, false),
                                  child: const Text('취소'),
                                ),
                                FilledButton(
                                  onPressed:
                                      () => Navigator.pop(dialogContext, true),
                                  child: const Text('보내기'),
                                ),
                              ],
                            ),
                      );
                      if (confirmed != true) return;
                      setState(() => _submitting = true);
                      try {
                        await widget.onComplete(message, proposedPrice);
                        if (mounted) setState(() => _editing = false);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('견적 전송 실패: $error')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
            icon: const Icon(Icons.send_outlined, size: 18),
            label: Text(_submitting ? '전송 중' : '견적 보내기'),
            style: FilledButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: _line,
              textStyle: AppText.button,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KakaoPaySection extends StatelessWidget {
  const _KakaoPaySection({required this.isCompleted, required this.onComplete});

  final bool isCompleted;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
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
            onPressed: onComplete,
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

// ── Live Operators Banner ─────────────────────────────────────────────────────

class _LiveOperatorsBannerSection extends StatelessWidget {
  const _LiveOperatorsBannerSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final pilots = store.allPilots.isNotEmpty ? store.allPilots : store.pilots;
    final count = pilots.length;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F8FA),
      child: _PageShell(
        top: 48,
        bottom: 52,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Headline row ───────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // live dot
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF05B169),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      const TextSpan(text: '지금 '),
                      TextSpan(
                        text: '$count명',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0B0D),
                        ),
                      ),
                      const TextSpan(text: '의 검증된 운용자가 내 요청을 기다리고 있습니다.'),
                    ],
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: compact ? 17 : 20,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5B616E),
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const Spacer(),
                if (!compact)
                  const Text(
                    '등록된 운용자 데이터를 실시간으로 반영합니다',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Horizontal pilot cards ─────────────────────────────────────
            SizedBox(
              height: 128,
              child:
                  pilots.isNotEmpty
                      ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pilots.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final pilot = pilots[index];
                          return _LiveOperatorCard(
                            pilot: pilot,
                            onTap: () {
                              store.selectPilot(pilot);
                              _openPortfolio(context, pilot);
                            },
                          );
                        },
                      )
                      : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, __) => const _LiveOperatorSkeleton(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveOperatorCard extends StatefulWidget {
  const _LiveOperatorCard({required this.pilot, required this.onTap});

  final DronePilot pilot;
  final VoidCallback onTap;

  @override
  State<_LiveOperatorCard> createState() => _LiveOperatorCardState();
}

class _LiveOperatorCardState extends State<_LiveOperatorCard> {
  bool _hovered = false;

  DronePilot get pilot => widget.pilot;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 190,
          height: 128,
          transform:
              _hovered
                  ? (Matrix4.identity()..translate(0.0, -3.0))
                  : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF9FAFB) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  _hovered ? const Color(0xFF0052FF) : const Color(0xFFDEE1E6),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow:
                _hovered
                    ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEEF0F3),
                    backgroundImage: pilot.avatarUrl != null
                        ? NetworkImage(pilot.avatarUrl!)
                        : null,
                    child: pilot.avatarUrl == null
                        ? Text(
                            pilot.name.characters.first,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0B0D),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          pilot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0B0D),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB020),
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              pilot.location,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                color: Color(0xFF7C828A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF05B169),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    pilot.categories
                        .take(2)
                        .map(
                          (cat) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFE4EAF2),
                              ),
                            ),
                            child: Text(
                              cat,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5B616E),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const Spacer(),
              Text(
                pilot.categories.join(' · '),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveOperatorSkeleton extends StatelessWidget {
  const _LiveOperatorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
    );
  }
}
