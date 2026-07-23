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

  static const List<String> _sorts = <String>['인기순', '최신순'];

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (store.isSessionRestoring) {
          return const Scaffold(backgroundColor: DC.canvas);
        }
        final compact = MediaQuery.sizeOf(context).width < 760;
        final nickname =
            store.accountNickname.isNotEmpty
                ? store.accountNickname
                : store.accountName;
        final regions = store.serviceAreas;
        final categories = <String>[
          '전체',
          ...store.categories.map((category) => category.label),
        ];

        return Scaffold(
          backgroundColor: DC.canvas,
          appBar:
              compact
                  ? AppBar(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    centerTitle: false,
                    title: const Text('피드'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/home'),
                    ),
                  )
                  : null,
          body: Column(
            children: <Widget>[
              if (!compact)
                DrameTopNavigation(
                  isLoggedIn: store.isLoggedIn,
                  isOperator: store.isPilotMode,
                  nickname: nickname,
                  activePage: 'feed',
                  onLoginTap: () => context.go('/login'),
                  onRegisterPilotTap: () => context.push('/pilot/register'),
                  onLogoTap: () {
                    store.setPilotMode(false);
                    context.go('/home');
                  },
                  onFindPilotTap: () => context.go('/home'),
                  onFeedTap: () => context.go('/feed'),
                  onPortfolioTap: () => context.go('/portfolio'),
                  onMyQuotesTap: () => context.go('/my/quotes'),
                  onChatTap: () => context.go('/chats'),
                  onLogoutTap: () async {
                    await store.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  onSwitchToUser: () {
                    store.setPilotMode(false);
                    context.go('/home');
                  },
                  onSwitchToOperator: () {
                    store.setPilotMode(true);
                    context.go('/operator');
                  },
                  onRequestsTap:
                      () => _openPilotRequestReviewPage(
                        context,
                        initialRequest: store.firstPilotWorkRequest,
                      ),
                  notificationCount: store.notificationCount,
                  chatUnreadCount: store.chatUnreadCount,
                  onNotificationTap: () => _showNotifications(context, store),
                ),

              // ── Filter Bar ─────────────────────────────────────────────────
              _FeedFilterBar(
                compact: compact,
                selectedRegion: _selectedRegion,
                selectedCategory: _selectedCategory,
                selectedSort: _selectedSort,
                regions: regions,
                categories: categories,
                sorts: _sorts,
                onRegionChanged: (v) => setState(() => _selectedRegion = v),
                onCategoryChanged: (v) => setState(() => _selectedCategory = v),
                onSortChanged: (v) => setState(() => _selectedSort = v),
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: DC.canvas,
                        child: DroneFeedSection(
                          region: _selectedRegion,
                          category: _selectedCategory,
                          sort: _selectedSort,
                        ),
                      ),
                    ),
                    if (!compact)
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
    this.centered = false,
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
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      children: <Widget>[
        _FilterDropdown(
          icon: Icons.place_outlined,
          label: '지역',
          selected: selectedRegion,
          options: regions,
          onChanged: onRegionChanged,
        ),
        const SizedBox(width: 8),
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
        ...sorts.map(
          (sort) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SortChip(
              label: sort,
              selected: selectedSort == sort,
              onTap: () => onSortChanged(sort),
            ),
          ),
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDEE1E6))),
      ),
      child:
          centered
              ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 16 : 24,
                      vertical: 12,
                    ),
                    child: row,
                  ),
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 16 : 24,
                  vertical: 12,
                ),
                child: row,
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
      itemBuilder:
          (_) =>
              options
                  .map(
                    (opt) => PopupMenuItem<String>(
                      value: opt,
                      child: Row(
                        children: <Widget>[
                          if (selected == opt) ...<Widget>[
                            const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Color(0xFF0052FF),
                            ),
                            const SizedBox(width: 8),
                          ] else
                            const SizedBox(width: 24),
                          ModeText(
                            opt,
                            size: 14,
                            weight:
                                selected == opt
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                            color:
                                selected == opt
                                    ? const Color(0xFF0052FF)
                                    : const Color(0xFF0A0B0D),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color:
                isFiltered ? const Color(0xFF0052FF) : const Color(0xFFDEE1E6),
            width: isFiltered ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color:
                  isFiltered
                      ? const Color(0xFF0052FF)
                      : const Color(0xFF7C828A),
            ),
            const SizedBox(width: 5),
            ModeMediumText(
              isFiltered ? selected : label,
              size: 14,
              color:
                  isFiltered
                      ? const Color(0xFF0052FF)
                      : const Color(0xFF0A0B0D),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color:
                  isFiltered
                      ? const Color(0xFF0052FF)
                      : const Color(0xFF7C828A),
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
      child: ModeChip(
        label: label,
        background: selected ? const Color(0xFF0A0B0D) : Colors.white,
        foreground: selected ? Colors.white : const Color(0xFF5B616E),
      ),
    );
  }
}
