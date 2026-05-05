import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../network/drone_pilot_model.dart';
import '../network/mock_drone_pilot_api.dart';

const _navy = Color(0xFF1F3F68);
const _deepNavy = Color(0xFF0E315C);
const _ink = Color(0xFF15355F);
const _muted = Color(0xFF74839A);
const _soft = Color(0xFFF3F6FA);
const _line = Color(0xFFE6EBF2);
const _mint = Color(0xFF28C894);

class DrameStore extends ChangeNotifier {
  DrameStore({MockDronePilotApi? api}) : _api = api ?? MockDronePilotApi();

  final MockDronePilotApi _api;

  List<DronePilot> pilots = const <DronePilot>[];
  DronePilot? selectedPilot;
  String selectedArea = '전체';
  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    pilots = await _api.fetchPilots(priorityArea: selectedArea);
    selectedPilot = pilots.isEmpty ? null : pilots.first;
    isLoading = false;
    notifyListeners();
  }

  Future<void> selectArea(String area) async {
    selectedArea = area;
    await load();
  }

  void selectPilot(DronePilot pilot) {
    selectedPilot = pilot;
    notifyListeners();
  }
}

class DrameHomePage extends StatefulWidget {
  const DrameHomePage({super.key});

  @override
  State<DrameHomePage> createState() => _DrameHomePageState();
}

class _DrameHomePageState extends State<DrameHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrameStore>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (store.isLoading && store.pilots.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final pilot = store.selectedPilot ?? store.pilots.first;
            return CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(child: _TopNavigation()),
                SliverToBoxAdapter(child: _MapMatchSection(store: store)),
                SliverToBoxAdapter(child: _PortfolioSection(pilot: pilot)),
                SliverToBoxAdapter(child: _PopularPilotsSection(store: store)),
                const SliverToBoxAdapter(child: SizedBox(height: 52)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;

    return Container(
      height: compact ? 70 : 82,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: <Widget>[
          const _Logo(),
          const Spacer(),
          FilledButton(onPressed: () {}, child: Text(compact ? '로그인' : '로그인')),
        ],
      ),
    );
  }
}

class _MapMatchSection extends StatelessWidget {
  const _MapMatchSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Container(
      color: _navy,
      child: _SectionShell(
        title: 'Drame',
        subtitle: '드론 매칭 플랫폼',
        dark: true,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(radius: 5, backgroundColor: _mint),
                  SizedBox(width: 10),
                  Text(
                    '자격증·보험 검증 완료 운용자 매칭',
                    style: TextStyle(
                      color: Color(0xFFD6E0EC),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _AreaFilter(store: store, dark: true),
            const SizedBox(height: 18),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 7, child: _MapPanel(store: store)),
                  const SizedBox(width: 18),
                  Expanded(flex: 5, child: _PilotPanel(store: store)),
                ],
              )
            else
              Column(
                children: <Widget>[
                  _MapPanel(store: store),
                  const SizedBox(height: 18),
                  _PilotPanel(store: store),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PopularPilotsSection extends StatelessWidget {
  const _PopularPilotsSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _SectionShell(
        title: '인기 운용자',
        subtitle: '검증된 운용자의 포트폴리오를 확인하세요',
        action: '전체 보기',
        child: LayoutBuilder(
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
                mainAxisExtent: 468,
              ),
              itemBuilder: (context, index) {
                final pilot = store.pilots[index];
                return _PilotCard(
                  pilot: pilot,
                  featured: index == 0 || index == 3,
                  onTap: () => store.selectPilot(pilot),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PortfolioSection extends StatelessWidget {
  const _PortfolioSection({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    final jobs = <
      ({String tag, String title, String meta, String result, String image})
    >[
      (
        tag: '농약 방제',
        title: '경기도 이천 벼농사 방제',
        meta: '12ha',
        result: '작업 완료 2시간',
        image: pilot.portfolioImages[0],
      ),
      (
        tag: '부동산 영상',
        title: '강남 고급 아파트 촬영',
        meta: '4K 영상',
        result: '납품 당일',
        image: pilot.portfolioImages[1],
      ),
      (
        tag: '측량·매핑',
        title: '인천 물류센터 부지 측량',
        meta: '35,000㎡',
        result: 'DXF 파일 납품',
        image: pilot.portfolioImages[2],
      ),
      (
        tag: '시설 점검',
        title: '충남 태양광 패널 열화상 점검',
        meta: '500kW 규모',
        result: '보고서 즉시 발행',
        image: pilot.portfolioImages[3],
      ),
    ];

    return _SectionShell(
      title: '${pilot.name} 작업 포트폴리오',
      subtitle: '촬영자를 선택하면 이 영역이 해당 운용자의 작업 이미지로 바뀝니다.',
      action: '제안하기',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 2 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: wide ? 374 : 300,
            ),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _WorkTile(
                tag: job.tag,
                title: job.title,
                meta: job.meta,
                result: job.result,
                image: job.image,
                large: wide && (index == 2 || index == 3),
              );
            },
          );
        },
      ),
    );
  }
}

class _AreaFilter extends StatelessWidget {
  const _AreaFilter({required this.store, this.dark = false});

  final DrameStore store;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            mockServiceAreas.map((area) {
              final selected = store.selectedArea == area;
              return ChoiceChip(
                label: Text(area),
                selected: selected,
                onSelected: (_) => store.selectArea(area),
                selectedColor: dark ? Colors.white : _navy,
                backgroundColor:
                    dark ? Colors.white.withValues(alpha: 0.10) : Colors.white,
                side: BorderSide(
                  color: dark ? Colors.white.withValues(alpha: 0.22) : _line,
                ),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color:
                      selected
                          ? (dark ? _deepNavy : Colors.white)
                          : (dark ? Colors.white : _ink),
                  fontWeight: FontWeight.w800,
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
      height: 470,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              Positioned.fill(child: CustomPaint(painter: _KoreaMapPainter())),
              Positioned(
                left: 22,
                top: 22,
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
      height: 470,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
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
                      fontSize: 26,
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
            const SizedBox(height: 22),
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
              icon: Icons.verified_user_outlined,
              label: '허가 지역',
              value: pilot.permittedAreas.join(', '),
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
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                _Metric(label: '평점', value: pilot.rating.toStringAsFixed(1)),
                const SizedBox(width: 10),
                _Metric(label: '완료 촬영', value: '${pilot.completedJobs}건'),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('촬영 제안 보내기'),
            ),
            const SizedBox(height: 20),
            const Text(
              '마커를 클릭하면 이 박스에서 운용자 정보가 바로 바뀝니다.',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2937),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_outdoor_outlined,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Drame',
          style: TextStyle(
            color: _navy,
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 900 ? 0.0 : 20.0;
    final widthFactor = width >= 900 ? 0.75 : 1.0;

    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: dark ? 46 : 30,
          ),
          child: Column(
            crossAxisAlignment:
                dark ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          dark
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          textAlign: dark ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: dark ? Colors.white : _deepNavy,
                            fontSize: dark ? 56 : 24,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          SizedBox(height: dark ? 12 : 7),
                          Text(
                            subtitle!,
                            textAlign: dark ? TextAlign.center : TextAlign.left,
                            style: TextStyle(
                              color:
                                  dark
                                      ? const Color(0xFFC6D4E4)
                                      : const Color(0xFF5F7190),
                              fontSize: dark ? 20 : 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
              ),
              SizedBox(height: dark ? 28 : 22),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _PilotCard extends StatelessWidget {
  const _PilotCard({
    required this.pilot,
    required this.featured,
    required this.onTap,
  });

  final DronePilot pilot;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _NetworkCover(imageUrl: pilot.portfolioImages.first),
                  if (featured)
                    Positioned(
                      left: 14,
                      top: 14,
                      child: _DarkPill(
                        text: pilot.rating >= 5 ? 'Premium' : 'Pro',
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _LightPill(text: pilot.specialty.split(',').first),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: _deepNavy,
                        size: 19,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pilot.rating.toStringAsFixed(pilot.rating == 5 ? 0 : 1)} (${pilot.completedJobs})',
                        style: const TextStyle(
                          color: _deepNavy,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    pilot.name,
                    style: const TextStyle(
                      color: _deepNavy,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pilot.priceLabel,
                    style: const TextStyle(
                      color: Color(0xFF677996),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
              colors: <Color>[Color(0xFFCBD7E5), Color(0xFF173B66)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.flight_takeoff, color: Colors.white, size: 42),
          ),
        );
      },
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({
    required this.tag,
    required this.title,
    required this.meta,
    required this.result,
    required this.image,
    required this.large,
  });

  final String tag;
  final String title;
  final String meta;
  final String result;
  final String image;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _NetworkCover(imageUrl: image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Positioned(left: 18, top: 18, child: _GlassPill(text: tag)),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: large ? 23 : 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Icon(Icons.straighten, color: Colors.white, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      meta,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.check_rounded, color: _mint, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      result,
                      style: const TextStyle(
                        color: _mint,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
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
    final color = priority ? _mint : _deepNavy;

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

class _PilotListTile extends StatelessWidget {
  const _PilotListTile({
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
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: priority ? const Color(0xFFD9F7EA) : _soft,
        child: Icon(
          selected ? Icons.radio_button_checked : Icons.flight_takeoff,
          color: priority ? const Color(0xFF14986D) : _deepNavy,
          size: 18,
        ),
      ),
      title: Text(
        pilot.name,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${pilot.location} · ${pilot.priceLabel}'),
      trailing: priority ? const Icon(Icons.verified, color: _mint) : null,
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
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: _deepNavy),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
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
        padding: const EdgeInsets.all(16),
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
                color: _deepNavy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge();

  @override
  Widget build(BuildContext context) {
    return const _LightPill(text: '허가 우선');
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _deepNavy,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LightPill extends StatelessWidget {
  const _LightPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8A98AD),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KoreaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint =
        Paint()
          ..color = const Color(0xFFF5F8FC)
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
