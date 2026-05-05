import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../feed/ui/pages/feed_page.dart';
import '../../../portfolio/ui/pages/portfolio_page.dart';
import '../../network/drone_pilot_model.dart';
import '../../network/mock_drone_pilot_api.dart';

part '../component/main_component.dart';

class HomeText {
  static const TextStyle logo = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFF1F3F68),
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.6,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: 'Pretendard',
    color: _ink,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.22,
    letterSpacing: -0.9,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: 'Pretendard',
    color: _muted,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.55,
    letterSpacing: -0.15,
  );

  static const TextStyle categoryLabel = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFF5F6B7B),
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle topButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const TextStyle primaryButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.1,
  );
}

const _navy = Colors.black;
// 0xFF1F3F68
const _ink = Color(0xFF172338);
const _muted = Color(0xFF718096);
const _soft = Color(0xFFF3F6FA);
const _line = Color(0xFFE4EAF2);
const _mint = Color(0xFF22C58B);

void _openPortfolio(BuildContext context, DronePilot pilot) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PilotPortfolioPage(pilot: pilot)),
  );
}

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

            return CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(child: _TopNavigation()),
                SliverToBoxAdapter(child: _HeroIntro(store: store)),
                SliverToBoxAdapter(child: _MapSection(store: store)),
                const SliverToBoxAdapter(child: DroneFeedSection()),
                SliverToBoxAdapter(
                  child: _PopularPortfolioSection(store: store),
                ),
                const SliverToBoxAdapter(child: _FooterSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
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
    final compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
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
                const Text('Drame', style: HomeText.logo),
                if (!compact) ...const <Widget>[
                  SizedBox(width: 36),
                  _NavText('촬영자 찾기'),
                  _NavText('포트폴리오'),
                  // _NavText('커뮤니티'),
                ],
                const Spacer(),
                // if (!compact) const _TopSearch(),
                const SizedBox(width: 22),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    textStyle: HomeText.topButton,
                    foregroundColor: _ink,
                  ),
                  child: const Text('로그인 / 회원가입'),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3F68),
                    foregroundColor: Colors.white,
                    textStyle: HomeText.primaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                  ),
                  child: const Text('촬영자 등록'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      top: 58,
      bottom: 34,
      child: Column(
        children: <Widget>[
          const Text(
            '필요한 드론 작업, 검증된 조종사와 빠르게 연결하세요',
            textAlign: TextAlign.center,
            style: HomeText.heroTitle,
          ),
          const SizedBox(height: 16),
          const Text(
            '항공 촬영부터 방제, 점검, 측량까지 한 번에',
            textAlign: TextAlign.center,
            style: HomeText.heroSubtitle,
          ),
          const SizedBox(height: 32),
          const _CategoryStrip(),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    const categories = <({IconData icon, String label, Color color})>[
      (icon: Icons.apps_rounded, label: '전체보기', color: Color(0xFF818796)),
      (icon: Icons.photo_camera_rounded, label: '촬영', color: _navy),
      (
        icon: Icons.energy_savings_leaf_rounded,
        label: '농약방제',
        color: Color(0xFF18B979),
      ),
      (icon: Icons.apartment_rounded, label: '부동산', color: Color(0xFF2E9BFF)),
      (
        icon: Icons.construction_rounded,
        label: '건설현장',
        color: Color(0xFFFFA726),
      ),
      (icon: Icons.map_rounded, label: '측량·매핑', color: Color(0xFF00A6A6)),
      (
        icon: Icons.manage_search_rounded,
        label: '시설점검',
        color: Color(0xFFFF5BB7),
      ),
      (
        icon: Icons.celebration_rounded,
        label: '행사촬영',
        color: Color(0xFF8D6BFF),
      ),
      // (icon: Icons.flash_on_rounded, label: '라이트쇼', color: Color(0xFF2D9CDB)),
      // (icon: Icons.waves_rounded, label: '해양·산림', color: Color(0xFF1F9D78)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 76,
                      child: Text(
                        category.label,
                        textAlign: TextAlign.center,
                        style: HomeText.categoryLabel,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return _PageShell(
      top: 34,
      bottom: 58,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            eyebrow: '지역 기반 실시간 매칭',
            title: '지도에서 바로 촬영자 선택',
            action: '공역 확인',
          ),
          const SizedBox(height: 22),
          _AreaFilter(store: store),
          const SizedBox(height: 22),

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
                const SizedBox(height: 16),
                _PilotPanel(store: store),
              ],
            ),
        ],
      ),
    );
  }
}
