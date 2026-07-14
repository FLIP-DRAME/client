part of '../pages/portfolio_page.dart';

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

class _PortfolioMain extends StatelessWidget {
  const _PortfolioMain({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: () {
                  final imageUrl =
                      pilot.avatarUrl ??
                      (pilot.portfolioImages.isNotEmpty
                          ? pilot.portfolioImages.first
                          : null);
                  return imageUrl != null
                      ? _NetworkCover(imageUrl: imageUrl)
                      : const _EmptyPortfolioImage();
                }(),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(pilot.name, style: PortfolioText.profileName),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: <Widget>[
                        _ProfileMeta(
                          icon: Icons.place_outlined,
                          text: pilot.displayLocation,
                        ),
                        _ProfileMeta(
                          icon: Icons.sell_outlined,
                          text: pilot.displaySpecialty,
                        ),
                        _ProfileMeta(
                          icon: Icons.map_outlined,
                          text: () {
                            final v = pilot.availableAreas
                                .where(
                                  (a) =>
                                      a.trim().isNotEmpty &&
                                      a != '??' &&
                                      a != '?',
                                )
                                .join(', ');
                            return v.isEmpty ? '지역 협의' : v;
                          }(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(pilot.intro, style: PortfolioText.profileDescription),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Divider(color: _line),
        const SizedBox(height: 34),
        const _SectionTitle('서비스 상세설명'),
        const SizedBox(height: 14),
        Text(pilot.description, style: PortfolioText.body),
        const SizedBox(height: 40),
        if (pilot.portfolioImages.isNotEmpty) ...<Widget>[
          const _SectionTitle('사진 포트폴리오'),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pilot.portfolioImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              mainAxisExtent: 220,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _NetworkCover(imageUrl: pilot.portfolioImages[index]),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
        _OperatorFeedGridSection(operatorId: pilot.id),
        const SizedBox(height: 40),
        const Divider(color: _line),
        const SizedBox(height: 34),
        _ReviewSection(operatorId: pilot.id),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _navy.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('견적 요청하기', style: PortfolioText.quoteTitle),
          const SizedBox(height: 14),
          Text(
            '${pilot.name}에게 원하는 드론 서비스의 견적을 받아보세요.',
            style: PortfolioText.quoteBody,
          ),
          const SizedBox(height: 22),
          _QuotePriceRow(
            label: '가능 지역',
            value: () {
              final v = pilot.availableAreas
                  .where((a) => a.trim().isNotEmpty && a != '??' && a != '?')
                  .join(', ');
              return v.isEmpty ? '지역 협의' : v;
            }(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _openQuoteRequest(context, pilot),
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                textStyle: PortfolioText.button,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('견적 요청하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMeta extends StatelessWidget {
  const _ProfileMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: _muted, size: 20),
        const SizedBox(width: 6),
        Text(text, style: PortfolioText.profileMeta),
      ],
    );
  }
}

class _EmptyPortfolioImage extends StatelessWidget {
  const _EmptyPortfolioImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _soft,
      child: const Center(
        child: Icon(Icons.flight_takeoff_rounded, color: _muted, size: 34),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: PortfolioText.sectionTitle);
  }
}

class _QuotePriceRow extends StatelessWidget {
  const _QuotePriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: PortfolioText.quoteLabel),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: PortfolioText.quoteValue,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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

// ── Mobile portfolio redesign ─────────────────────────────────────────────────

class _MobilePortfolioScaffold extends StatelessWidget {
  const _MobilePortfolioScaffold({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: AppBar(
        backgroundColor: _bgBeige,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          '운용자 프로필',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _MobileProfileCard(pilot: pilot),
            if (pilot.portfolioImages.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _MobilePortfolioSection(
                images: pilot.portfolioImages,
                pilot: pilot,
              ),
            ],
            const SizedBox(height: 16),
            _OperatorFeedGridSection(operatorId: pilot.id, contained: true),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _ReviewSection(operatorId: pilot.id),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MobilePortfolioBottomBar(pilot: pilot),
    );
  }
}

class _MobileProfileCard extends StatelessWidget {
  const _MobileProfileCard({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    final initial = pilot.name.isNotEmpty ? pilot.name[0] : '?';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ClipOval(
                      child:
                          pilot.avatarUrl?.trim().isNotEmpty == true
                              ? Image.network(
                                pilot.avatarUrl!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _MobilePilotAvatarFallback(
                                      initial: initial,
                                    ),
                              )
                              : _MobilePilotAvatarFallback(initial: initial),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _mintGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const _CertBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pilot.displayLocation,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _mutedGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          const _MobileSectionLabel('전문 분야'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                pilot.categories
                    .where((c) => c.trim().isNotEmpty)
                    .map((c) => _SpecChip(label: c))
                    .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          const _MobileSectionLabel('소개'),
          const SizedBox(height: 8),
          Text(
            pilot.intro.isNotEmpty ? pilot.intro : pilot.description,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3A3F47),
              height: 1.65,
            ),
          ),
          if (pilot.intro.isNotEmpty &&
              pilot.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              pilot.description,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF3A3F47),
                height: 1.65,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final validAreas =
                  pilot.availableAreas
                      .where(
                        (a) => a.trim().isNotEmpty && a != '??' && a != '?',
                      )
                      .toList();
              if (validAreas.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _MobileSectionLabel('서비스 가능 지역'),
                    SizedBox(height: 8),
                    Text(
                      '지역 협의',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Color(0xFF7C828A),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MobileSectionLabel('서비스 가능 지역'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        validAreas.map((a) => _AreaChip(label: a)).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MobilePortfolioSection extends StatelessWidget {
  const _MobilePortfolioSection({required this.images, required this.pilot});

  final List<String> images;
  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              '포트폴리오 ${images.length}개',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: _NetworkCover(imageUrl: images[index]),
              );
            },
          ),
          if (pilot.description.isNotEmpty) ...<Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Divider(color: _line, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '서비스 상세설명',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pilot.description,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: Color(0xFF3A3F47),
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Pilot feed posts ─────────────────────────────────────────────
          Consumer(
            builder: (context, ref, _) {
              final store = ref.watch(drameStoreProvider);
              final posts =
                  store.selectedPilot?.id == '__portfolio_feed_disabled__'
                      ? store.myFeedPosts
                      : <OperatorFeedPost>[];
              if (posts.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Divider(color: _line, height: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      '내 피드',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth >= 720 ? 3 : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 260,
                              ),
                          itemBuilder:
                              (context, index) =>
                                  _FeedPostCard(post: posts[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MobilePortfolioBottomBar extends StatelessWidget {
  const _MobilePortfolioBottomBar({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _showMobileQuoteSheet(context, pilot),
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('견적 요청하기'),
        ),
      ),
    );
  }
}

class _MobilePilotAvatarFallback extends StatelessWidget {
  const _MobilePilotAvatarFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8EEFF),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  const _CertBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified_rounded, size: 12, color: _primary),
          SizedBox(width: 3),
          Text(
            '인증',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3A3F47),
        ),
      ),
    );
  }
}

class _MobileSectionLabel extends StatelessWidget {
  const _MobileSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        letterSpacing: -0.1,
      ),
    );
  }
}

// ── Feed post card ─────────────────────────────────────────────────────────────

class _OperatorFeedGridSection extends ConsumerStatefulWidget {
  const _OperatorFeedGridSection({
    required this.operatorId,
    this.contained = false,
  });

  final String operatorId;
  final bool contained;

  @override
  ConsumerState<_OperatorFeedGridSection> createState() =>
      _OperatorFeedGridSectionState();
}

class _OperatorFeedGridSectionState
    extends ConsumerState<_OperatorFeedGridSection> {
  static const int _collapsedCount = 9;

  late Future<List<FeedPost>> _future;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _future = _loadPosts();
  }

  @override
  void didUpdateWidget(covariant _OperatorFeedGridSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operatorId != widget.operatorId) {
      _expanded = false;
      _future = _loadPosts();
    }
  }

  Future<List<FeedPost>> _loadPosts() {
    return ref
        .read(feedApiProvider)
        .fetchPostsByOperator(widget.operatorId, limit: 30);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedPost>>(
      future: _future,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const <FeedPost>[];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildFrame(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || posts.isEmpty) {
          return const SizedBox.shrink();
        }

        final visiblePosts =
            _expanded ? posts : posts.take(_collapsedCount).toList();
        final canExpand = posts.length > _collapsedCount;

        return _buildFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const _SectionTitle('운용자 피드'),
                  const SizedBox(width: 8),
                  Text(
                    '${posts.length}',
                    style: const TextStyle(
                      fontFamily: DrameTextStyles.fontFamily,
                      fontSize: 14,
                      color: _mutedGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = widget.contained ? 8.0 : 12.0;
                  final cellWidth = (constraints.maxWidth - spacing * 2) / 3;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visiblePosts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      mainAxisExtent: cellWidth + 96,
                    ),
                    itemBuilder: (context, index) {
                      final post = visiblePosts[index];
                      return _FeedPostCard(
                        post: OperatorFeedPost(
                          id: post.id,
                          caption: post.caption,
                          createdAt: post.createdAt,
                          imageUrl: post.images.isEmpty ? null : post.images.first,
                        ),
                        onTap: () => showFeedPostDialog(
                          context,
                          post,
                          loadPilot: (id) => ref
                              .read(dronePilotApiProvider)
                              .fetchPilotById(id),
                        ),
                      );
                    },
                  );
                },
              ),
              if (canExpand && !_expanded) ...<Widget>[
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _expanded = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      textStyle: const TextStyle(
                        fontFamily: DrameTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: Text('더보기 ${posts.length - _collapsedCount}개'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrame({required Widget child}) {
    if (!widget.contained) return child;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({required this.post, this.onTap});

  final OperatorFeedPost post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: const Color(0xFFEEF0F3),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF8BA0B8),
                            size: 32,
                          ),
                        ),
                      ),
                ),
              ),
            )
          else if (post.imageBytes != null && post.imageBytes!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.memory(
                  Uint8List.fromList(post.imageBytes!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if ((post.imageUrl != null && post.imageUrl!.isNotEmpty) ||
              (post.imageBytes != null && post.imageBytes!.isNotEmpty))
            const SizedBox(height: 10),
          if (post.caption.isNotEmpty)
            Text(
              post.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF3A3F47),
                height: 1.55,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            post.createdAt.toString().substring(0, 10),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              color: _mutedGray,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Review section ─────────────────────────────────────────────────────────────

class _ReviewSection extends StatefulWidget {
  const _ReviewSection({required this.operatorId});

  final String operatorId;

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  bool _loading = true;
  List<OperatorReview> _reviews = <OperatorReview>[];
  bool _canLeaveReview = false;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    // Check quote eligibility independently so a missing reviews table
    // does not block the "리뷰 남기기" button from appearing.
    bool canLeaveReview = false;
    if (userId != null) {
      try {
        final quoteRows = await client
            .from('job_requests')
            .select('id')
            .eq('client_id', userId)
            .eq('preferred_operator_id', widget.operatorId)
            .limit(1);
        canLeaveReview = (quoteRows as List).isNotEmpty;
      } catch (_) {}
    }

    List<OperatorReview> reviews = <OperatorReview>[];
    bool hasReviewed = false;
    try {
      final rows = await client
          .from('operator_reviews')
          .select('id, reviewer_id, reviewer_name, rating, comment, created_at')
          .eq('operator_id', widget.operatorId)
          .order('created_at', ascending: false)
          .limit(20);

      reviews =
          rows.map<OperatorReview>((row) {
            final map = Map<String, dynamic>.from(row as Map);
            return OperatorReview(
              id: map['id'].toString(),
              reviewerId: (map['reviewer_id'] ?? '').toString(),
              reviewerName: (map['reviewer_name'] ?? '익명').toString(),
              rating: (map['rating'] as num?)?.toInt() ?? 5,
              comment: (map['comment'] ?? '').toString(),
              createdAt:
                  DateTime.tryParse((map['created_at'] ?? '').toString()) ??
                  DateTime.now(),
            );
          }).toList();

      if (userId != null) {
        hasReviewed = reviews.any((r) => r.reviewerId == userId);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _reviews = reviews;
        _canLeaveReview = canLeaveReview;
        _hasReviewed = hasReviewed;
        _loading = false;
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<int>(0, (sum, r) => sum + r.rating) / _reviews.length;
  }

  Future<void> _onLeaveReview() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _LeaveReviewDialog(operatorId: widget.operatorId),
    );
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const _SectionTitle('리뷰'),
            if (_reviews.isNotEmpty) ...<Widget>[
              const SizedBox(width: 10),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFBBC05),
                size: 18,
              ),
              const SizedBox(width: 3),
              Text(
                _averageRating.toStringAsFixed(1),
                style: PortfolioText.rating,
              ),
              const SizedBox(width: 4),
              Text(
                '(${_reviews.length})',
                style: const TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: 14,
                  color: _mutedGray,
                ),
              ),
            ],
            const Spacer(),
            if (_loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_canLeaveReview && !_hasReviewed)
              OutlinedButton(
                onPressed: _onLeaveReview,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  textStyle: const TextStyle(
                    fontFamily: DrameTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('리뷰 남기기'),
              )
            else if (_canLeaveReview && _hasReviewed)
              const Text(
                '리뷰 작성 완료',
                style: TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: 13,
                  color: _mutedGray,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_reviews.isEmpty && !_loading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '아직 리뷰가 없습니다',
                style: TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: 14,
                  color: _mutedGray,
                ),
              ),
            ),
          )
        else
          ..._reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(review: review),
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final OperatorReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: PortfolioText.reviewName,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFBBC05),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(review.comment, style: PortfolioText.reviewBody),
          ],
          const SizedBox(height: 8),
          Text(
            '${review.createdAt.year}.${review.createdAt.month.toString().padLeft(2, '0')}.${review.createdAt.day.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontFamily: DrameTextStyles.fontFamily,
              fontSize: 12,
              color: _mutedGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveReviewDialog extends StatefulWidget {
  const _LeaveReviewDialog({required this.operatorId});

  final String operatorId;

  @override
  State<_LeaveReviewDialog> createState() => _LeaveReviewDialogState();
}

class _LeaveReviewDialogState extends State<_LeaveReviewDialog> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw StateError('로그인이 필요합니다.');

      String reviewerName = '익명';
      final profile =
          await client
              .from('profiles')
              .select('nickname, name')
              .eq('id', userId)
              .maybeSingle();
      if (profile != null) {
        final nickname = (profile['nickname'] ?? '').toString().trim();
        final name = (profile['name'] ?? '').toString().trim();
        if (nickname.isNotEmpty) {
          reviewerName = nickname;
        } else if (name.isNotEmpty) {
          reviewerName = name;
        }
      }

      await client.from('operator_reviews').upsert(<String, Object?>{
        'operator_id': widget.operatorId,
        'reviewer_id': userId,
        'reviewer_name': reviewerName,
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
      }, onConflict: 'operator_id,reviewer_id');

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        '리뷰 남기기',
        style: TextStyle(
          fontFamily: DrameTextStyles.fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '별점',
              style: TextStyle(
                fontFamily: DrameTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFBBC05),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '운용자에 대한 리뷰를 작성해주세요.',
                filled: true,
                fillColor: _soft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primary, width: 1.4),
                ),
                hintStyle: const TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: 14,
                  color: _mutedGray,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
          child: Text(_submitting ? '제출 중…' : '리뷰 제출'),
        ),
      ],
    );
  }
}

void _showMobileQuoteSheet(BuildContext context, DronePilot pilot) {
  if (Supabase.instance.client.auth.currentUser == null) {
    showLoginRequiredDialog(context, message: '견적 요청은 로그인 후 이용할 수 있습니다.');
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MobileQuoteSheet(pilot: pilot),
  );
}

// ── Mobile quote request bottom sheet ─────────────────────────────────────────

class _MobileQuoteSheet extends ConsumerStatefulWidget {
  const _MobileQuoteSheet({required this.pilot});

  final DronePilot pilot;

  @override
  ConsumerState<_MobileQuoteSheet> createState() => _MobileQuoteSheetState();
}

class _MobileQuoteSheetState extends ConsumerState<_MobileQuoteSheet> {
  late String? _category;
  late String? _area;
  String _budget = '0~30만원';
  bool _submitting = false;

  final _dateController = TextEditingController();
  final _detailController = TextEditingController();
  final _contactController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cats =
        widget.pilot.categories.where((c) => c.trim().isNotEmpty).toList();
    _category = cats.isNotEmpty ? cats.first : null;
    final areas =
        widget.pilot.availableAreas
            .where((a) => a.trim().isNotEmpty && a != '??' && a != '?')
            .toList();
    _area = areas.isNotEmpty ? areas.first : null;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _detailController.dispose();
    _contactController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  List<String> get _cats =>
      widget.pilot.categories.where((c) => c.trim().isNotEmpty).toList();
  List<String> get _areas =>
      widget.pilot.availableAreas
          .where((a) => a.trim().isNotEmpty && a != '??' && a != '?')
          .toList();

  Future<void> _submit() async {
    if (_category == null) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final store = ref.read(drameStoreProvider);
      await store.submitQuoteRequest(
        QuoteRequest(
          pilot: widget.pilot,
          category: _category!,
          area: _area ?? '지역 협의',
          preferredDate: _dateController.text,
          detail: _detailController.text,
          budgetRange:
              _amountController.text.isNotEmpty
                  ? _amountController.text
                  : _budget,
          contactWindow: _contactController.text,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('견적 요청을 보냈습니다. 운용자가 확인하면 내 견적에 표시됩니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
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
    final cats = _cats;
    final areas = _areas;
    final selCat =
        cats.contains(_category)
            ? _category!
            : (cats.isNotEmpty ? cats.first : '');
    final selArea =
        areas.contains(_area) ? _area! : (areas.isNotEmpty ? areas.first : '');

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
                    '${widget.pilot.name}에게 견적 요청',
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
            const SizedBox(height: 20),
            if (cats.isNotEmpty) ...<Widget>[
              const _SheetLabel('서비스 종류'),
              const SizedBox(height: 8),
              _SheetChipWrap(
                values: cats,
                selected: selCat,
                onSelected: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 16),
            ],
            if (areas.isNotEmpty) ...<Widget>[
              const _SheetLabel('지역'),
              const SizedBox(height: 8),
              _SheetChipWrap(
                values: areas,
                selected: selArea,
                onSelected: (v) => setState(() => _area = v),
              ),
              const SizedBox(height: 16),
            ],
            _SheetTextField(label: '희망 일정', controller: _dateController),
            const SizedBox(height: 12),
            _SheetTextField(
              label: '요청사항',
              controller: _detailController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SheetTextField(
              label: '견적 금액 (선택)',
              controller: _amountController,
              hint: '예: 50만원',
            ),
            const SizedBox(height: 12),
            const _SheetLabel('예산'),
            const SizedBox(height: 8),
            _SheetChipWrap(
              values: const <String>['0~30만원', '30~50만원', '50~100만원', '협의'],
              selected: _budget,
              onSelected: (v) => setState(() => _budget = v),
            ),
            const SizedBox(height: 12),
            _SheetTextField(label: '연락 가능 시간', controller: _contactController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
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
                child: Text(_submitting ? '요청 중…' : '견적 요청 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0B0D),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
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
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _line),
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

class _SheetChipWrap extends StatelessWidget {
  const _SheetChipWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          values
              .map(
                (v) => GestureDetector(
                  onTap: () => onSelected(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          v == selected
                              ? const Color(0xFF0A0B0D)
                              : const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            v == selected
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
                            v == selected
                                ? Colors.white
                                : const Color(0xFF5B616E),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
