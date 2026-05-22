part of '../pages/main_page.dart';

class FeedStandalonePage extends StatefulWidget {
  const FeedStandalonePage({super.key});

  @override
  State<FeedStandalonePage> createState() => _FeedStandalonePageState();
}

class _FeedStandalonePageState extends State<FeedStandalonePage> {
  String _selectedRegion = '전체';
  String _selectedSort = '인기순';
  String _selectedCategory = '전체';

  static const List<String> _regions = <String>[
    '전체', '서울', '경기', '인천', '부산', '대구', '광주', '대전',
  ];

  static const List<String> _categories = <String>[
    '전체', '항공촬영', '농약방제', '측량·매핑', '시설점검', '부동산', '행사촬영',
  ];

  static const List<String> _sorts = <String>['인기순', '최신순'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<DrameStore>().isLoggedIn) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (!store.isLoggedIn) return const Scaffold(backgroundColor: DC.canvas);
        final compact = MediaQuery.sizeOf(context).width < 760;
        final nickname = store.accountNickname.isNotEmpty
            ? store.accountNickname
            : store.accountName;

        return Scaffold(
          backgroundColor: DC.canvas,
          body: Column(
            children: <Widget>[
              DrameTopNavigation(
                isLoggedIn: true,
                isOperator: store.isPilotMode,
                nickname: nickname,
                activePage: 'feed',
                onLoginTap: () => context.go('/login'),
                onRegisterPilotTap: () => context.push('/pilot/register'),
                onLogoTap: () => context.go('/home'),
                onFindPilotTap: () => context.go('/home'),
                onFeedTap: () => context.go('/feed'),
                onPortfolioTap: () => context.go('/portfolio'),
                onMyQuotesTap: () => context.go('/my/quotes'),
                onSwitchToUser: () { store.setPilotMode(false); context.go('/home'); },
                onSwitchToOperator: () { store.setPilotMode(true); context.go('/home'); },
                onRequestsTap: () => _openPilotRequestReviewPage(
                  context,
                  initialRequest: mockPilotWorkRequests.first,
                ),
              ),

              // ── Filter Bar ─────────────────────────────────────────────────
              _FeedFilterBar(
                compact: compact,
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

              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    const SliverToBoxAdapter(
                      child: ColoredBox(
                        color: Colors.white,
                        child: DroneFeedSection(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: _FooterSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 72)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Feed Filter Bar ───────────────────────────────────────────────────────────

class _FeedFilterBar extends StatelessWidget {
  const _FeedFilterBar({
    required this.compact,
    required this.selectedRegion,
    required this.selectedCategory,
    required this.selectedSort,
    required this.regions,
    required this.categories,
    required this.sorts,
    required this.onRegionChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  final bool compact;
  final String selectedRegion;
  final String selectedCategory;
  final String selectedSort;
  final List<String> regions;
  final List<String> categories;
  final List<String> sorts;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFDEE1E6)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            // 지역 dropdown-style pill
            _FilterDropdown(
              icon: Icons.place_outlined,
              label: '지역',
              selected: selectedRegion,
              options: regions,
              onChanged: onRegionChanged,
            ),
            const SizedBox(width: 8),

            // 카테고리 dropdown-style pill
            _FilterDropdown(
              icon: Icons.category_outlined,
              label: '카테고리',
              selected: selectedCategory,
              options: categories,
              onChanged: onCategoryChanged,
            ),

            const SizedBox(width: 16),
            Container(width: 1, height: 20, color: DC.primary),
            const SizedBox(width: 16),

            // 정렬 toggle pills
            ...sorts.map((sort) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _SortChip(
                label: sort,
                selected: selectedSort == sort,
                onTap: () => onSortChanged(sort),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.icon,
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isFiltered = selected != '전체';
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      itemBuilder: (_) => options
          .map((opt) => PopupMenuItem<String>(
                value: opt,
                child: Row(
                  children: <Widget>[
                    if (selected == opt) ...<Widget>[
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFF0052FF)),
                      const SizedBox(width: 8),
                    ] else
                      const SizedBox(width: 24),
                    Text(
                      opt,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: selected == opt ? FontWeight.w600 : FontWeight.w400,
                        color: selected == opt
                            ? const Color(0xFF0052FF)
                            : const Color(0xFF0A0B0D),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isFiltered ? const Color(0xFF0052FF) : const Color(0xFFDEE1E6),
            width: isFiltered ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: isFiltered ? const Color(0xFF0052FF) : const Color(0xFF7C828A),
            ),
            const SizedBox(width: 5),
            Text(
              isFiltered ? selected : label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isFiltered ? const Color(0xFF0052FF) : const Color(0xFF0A0B0D),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: isFiltered ? const Color(0xFF0052FF) : const Color(0xFF7C828A),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A0B0D) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? const Color(0xFF0A0B0D) : const Color(0xFFDEE1E6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF5B616E),
          ),
        ),
      ),
    );
  }
}
