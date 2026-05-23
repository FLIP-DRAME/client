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
                child:
                    pilot.portfolioImages.isEmpty
                        ? const _EmptyPortfolioImage()
                        : _NetworkCover(imageUrl: pilot.portfolioImages.first),
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
                          text: pilot.location,
                        ),
                        _ProfileMeta(
                          icon: Icons.sell_outlined,
                          text: pilot.specialty,
                        ),
                        _ProfileMeta(
                          icon: Icons.map_outlined,
                          text: pilot.availableAreas.join(', '),
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
        const _SectionTitle('촬영자 정보'),
        const SizedBox(height: 16),
        _InfoBlock(
          rows: <({IconData icon, String text})>[
            (
              icon: Icons.verified_user_outlined,
              text: '허가 지역: ${pilot.permittedAreas.join(', ')}',
            ),
            (icon: Icons.call_outlined, text: '연락처: ${pilot.contact}'),
            (
              icon: Icons.payments_outlined,
              text: '기본 제안가: ${pilot.priceLabel}',
            ),
          ],
        ),
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
            '${pilot.name}에게 원하는 촬영 서비스의 견적을 받아보세요.',
            style: PortfolioText.quoteBody,
          ),
          const SizedBox(height: 22),
          _QuotePriceRow(label: '촬영가 제안가', value: pilot.priceLabel),
          _QuotePriceRow(
            label: '가능 지역',
            value: pilot.availableAreas.join(', '),
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
              child: const Text('촬영 요청하기'),
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.rows});

  final List<({IconData icon, String text})> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Icon(row.icon, color: _navy, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(row.text, style: PortfolioText.infoText),
                  ),
                ],
              ),
            );
          }).toList(),
    );
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
        children: <Widget>[
          Text(label, style: PortfolioText.quoteLabel),
          const Spacer(),
          Text(value, style: PortfolioText.quoteValue),
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
          onPressed: () => context.pop(),
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              size: 22,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.ios_share_outlined,
              size: 22,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
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
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EEFF),
                      shape: BoxShape.circle,
                    ),
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
                      pilot.location,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _mutedGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '보통 1시간 이내 응답',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: _mutedGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const <Widget>[
              Expanded(child: _PilotStatBox(label: '완료 작업', value: '24건')),
              SizedBox(width: 8),
              Expanded(child: _PilotStatBox(label: '응답률', value: '98%')),
              SizedBox(width: 8),
              Expanded(child: _PilotStatBox(label: '활동 기간', value: '2년')),
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
          const _MobileSectionLabel('서비스 가능 지역'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                pilot.availableAreas
                    .where((a) => a.trim().isNotEmpty)
                    .map((a) => _AreaChip(label: a))
                    .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Text(
                '기본 제안가',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _mutedGray,
                ),
              ),
              const Spacer(),
              Text(
                pilot.priceLabel,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
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
                  store.selectedPilot?.id == pilot.id
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

class _PilotStatBox extends StatelessWidget {
  const _PilotStatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              color: _mutedGray,
            ),
          ),
        ],
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

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({required this.post});

  final OperatorFeedPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 180,
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
            )
          else if (post.imageBytes != null && post.imageBytes!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                Uint8List.fromList(post.imageBytes!),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          if ((post.imageUrl != null && post.imageUrl!.isNotEmpty) ||
              (post.imageBytes != null && post.imageBytes!.isNotEmpty))
            const SizedBox(height: 10),
          if (post.caption.isNotEmpty)
            Text(
              post.caption,
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
    );
  }
}

void _showMobileQuoteSheet(BuildContext context, DronePilot pilot) {
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
  String _budget = '~30만원';
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
        widget.pilot.availableAreas.where((a) => a.trim().isNotEmpty).toList();
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
      widget.pilot.availableAreas.where((a) => a.trim().isNotEmpty).toList();

  Future<void> _submit() async {
    if (_category == null || _area == null) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final store = ref.read(drameStoreProvider);
      await store.submitQuoteRequest(
        QuoteRequest(
          pilot: widget.pilot,
          category: _category!,
          area: _area!,
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
              label: '제안 금액 (선택)',
              controller: _amountController,
              hint: '예: 50만원',
            ),
            const SizedBox(height: 12),
            const _SheetLabel('예산'),
            const SizedBox(height: 8),
            _SheetChipWrap(
              values: const <String>['~30만원', '30~50만원', '50~100만원', '협의'],
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
