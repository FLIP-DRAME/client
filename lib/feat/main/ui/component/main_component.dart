part of '../pages/main_page.dart';

class _PopularPortfolioSection extends StatelessWidget {
  const _PopularPortfolioSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      top: 12,
      bottom: 48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(eyebrow: '이용자들이 만족한', title: '인기 운용자들의 포트폴리오'),
          const SizedBox(height: 22),
          const _PortfolioCategoryChips(),
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
                itemCount: store.pilots.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 402,
                ),
                itemBuilder: (context, index) {
                  final pilot = store.pilots[index];
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
    );
  }
}

class _AreaFilter extends StatelessWidget {
  const _AreaFilter({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            mockServiceAreas.map((area) {
              // 1. 여기서 area와 selected를 정의해줘야 합니다.
              final selected = store.selectedArea == area;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => store.selectArea(area),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Color(0xFF1E3A5F) : Colors.white,
                      borderRadius: BorderRadius.circular(8), // 기존 디자인 유지
                      border: Border.all(color: selected ? _ink : _line),
                    ),
                    child: Text(
                      area,
                      style: TextStyle(
                        color: selected ? Colors.white : _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
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
            color: Colors.black.withValues(alpha: 0.04),
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
                Expanded(
                  child: Text(
                    pilot.name,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (hasPriority) const _PriorityBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pilot.specialty,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
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
            // _InfoRow(
            //   icon: Icons.verified_user_outlined,
            //   label: '허가 지역',
            //   value: pilot.permittedAreas.join(', '),
            // ),
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
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _openPortfolio(context, pilot),
              icon: const Icon(Icons.arrow_forward_rounded),
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
              Text(
                eyebrow,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
            style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  const _NavText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PortfolioCategoryChips extends StatelessWidget {
  const _PortfolioCategoryChips();

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
              final selected = category == '전체';
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _navy : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: selected ? _navy : _line),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: selected ? Colors.white : _ink,
                      fontWeight: FontWeight.w900,
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
                    style: const TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pilot.name,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${pilot.priceLabel}',
                        style: const TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.verified_outlined, color: _mint, size: 18),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
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
      color: _navy,
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
            const Divider(color: Color(0xFF86A0BE)),
            const SizedBox(height: 28),
            Row(
              children: <Widget>[
                const Expanded(child: _InsuranceNote()),
                const SizedBox(width: 18),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const <Widget>[
                      _InsuranceCard(
                        label: '법적 의무',
                        title: '드론 배상책임보험',
                        body: '제3자 신체·재산 피해 보상',
                      ),
                      _InsuranceCard(
                        label: '권장',
                        title: '드론 기체보험',
                        body: '기체 파손·분실·추락 보상',
                      ),
                      _InsuranceCard(
                        label: '선택',
                        title: '조종자 상해보험',
                        body: '조종자 본인 신체 상해 보상',
                      ),
                      _InsuranceCard(
                        label: '추천',
                        title: '드론 종합보험',
                        body: '배상책임 + 기체 + 상해 통합',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            const Divider(color: Color(0xFF86A0BE)),
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
                      color: Color(0xFF9AB0C8),
                      fontWeight: FontWeight.w700,
                      height: 1.7,
                    ),
                  ),
                ),
                Text(
                  '© 2026 Drame. All rights reserved.',
                  style: TextStyle(
                    color: Color(0xFF9AB0C8),
                    fontWeight: FontWeight.w700,
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
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 22),
        Text(
          '30분 안에,\n검증된 드론 운용자와 만나세요.',
          style: TextStyle(
            color: Color(0xFFB7C7D9),
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
          style: const TextStyle(
            color: Color(0xFFB7C7D9),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xFFB7C7D9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsuranceNote extends StatelessWidget {
  const _InsuranceNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '드론 보험\n드론 운용에 필요한 보험을 Drame에서 비교하고 가입하세요.',
      style: TextStyle(
        color: Color(0xFFB7C7D9),
        fontWeight: FontWeight.w800,
        height: 1.7,
      ),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  const _InsuranceCard({
    required this.label,
    required this.title,
    required this.body,
  });

  final String label;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB7C7D9)),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF58D09B),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFB7C7D9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
            ),
          ),
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
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
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
