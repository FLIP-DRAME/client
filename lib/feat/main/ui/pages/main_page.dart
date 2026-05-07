import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../feed/ui/pages/feed_page.dart';
import '../../../portfolio/ui/pages/portfolio_page.dart';
import '../../../quote/network/mock_quote_api.dart';
import '../../../quote/network/quote_model.dart';
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
    color: Colors.white,
    fontSize: 58,
    fontWeight: FontWeight.w900,
    height: 1.12,
    letterSpacing: -1.4,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFFB9C7D8),
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.25,
  );

  static const TextStyle heroSearch = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFF8D9CB0),
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const TextStyle topButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const TextStyle primaryButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.1,
  );
}

const _navy = Color(0xFF1F3A5F);
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
  DrameStore({MockDronePilotApi? api, MockQuoteApi? quoteApi})
    : _api = api ?? MockDronePilotApi(),
      _quoteApi = quoteApi ?? MockQuoteApi();

  final MockDronePilotApi _api;
  final MockQuoteApi _quoteApi;

  List<DronePilot> pilots = const <DronePilot>[];
  DroneCategory? selectedCategory;
  DronePilot? selectedPilot;
  String selectedArea = '전체';
  QuoteRequest? quoteRequest;
  QuoteEstimate? estimate;
  PaymentInstruction? paymentInstruction;
  ContactAccess? contactAccess;
  bool paymentConfirmed = false;
  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    pilots = await _api.fetchPilots(
      priorityArea: selectedArea,
      category: selectedCategory?.label,
    );
    selectedPilot = pilots.isEmpty ? null : pilots.first;
    isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(DroneCategory category) async {
    selectedCategory = category;
    selectedArea = '전체';
    await load();
  }

  Future<void> selectArea(String area) async {
    selectedArea = area;
    await load();
  }

  void selectPilot(DronePilot pilot) {
    selectedPilot = pilot;
    notifyListeners();
  }

  Future<QuoteEstimate> submitQuoteRequest(QuoteRequest request) async {
    quoteRequest = request;
    estimate = await _quoteApi.createEstimate(request);
    paymentInstruction = _quoteApi.createPaymentInstruction(estimate!);
    contactAccess = null;
    paymentConfirmed = false;
    notifyListeners();
    return estimate!;
  }

  void confirmPayment() {
    if (estimate == null) {
      return;
    }
    paymentConfirmed = true;
    contactAccess = _quoteApi.createContactAccess(estimate!);
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
      backgroundColor: const Color(0xFFF1F5FA),
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (store.isLoading && store.pilots.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(child: _TopNavigation()),
                const SliverToBoxAdapter(child: _SecondaryNavigation()),
                const SliverToBoxAdapter(child: _LandingHeroSection()),
                SliverToBoxAdapter(
                  child: _CategorySelectionSection(store: store),
                ),
                if (store.selectedCategory != null)
                  SliverToBoxAdapter(
                    child: _AreaSelectionSection(store: store),
                  ),
                if (store.selectedCategory != null &&
                    store.selectedArea != '전체')
                  SliverToBoxAdapter(child: _OperatorListSection(store: store)),
                const SliverToBoxAdapter(
                  child: ColoredBox(
                    color: Colors.white,
                    child: DroneFeedSection(),
                  ),
                ),
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
                  SizedBox(width: 54),
                  _TopSearch(),
                ],
                const Spacer(),
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

class _SecondaryNavigation extends StatelessWidget {
  const _SecondaryNavigation();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    const tabs = <({IconData icon, String label})>[
      (icon: Icons.person_search_rounded, label: '촬영자 찾기'),
      (icon: Icons.grid_view_rounded, label: '포트폴리오'),
      (icon: Icons.info_outline_rounded, label: 'Drame 소개'),
      (icon: Icons.map_outlined, label: '비행공역 확인'),
    ];

    return Container(
      height: compact ? 58 : 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    tabs.map((tab) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 34),
                        child: _SubNavTab(icon: tab.icon, label: tab.label),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubNavTab extends StatelessWidget {
  const _SubNavTab({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6E7F99),
        textStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _LandingHeroSection extends StatelessWidget {
  const _LandingHeroSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _navy,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x331F3F68),
              blurRadius: 32,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: _PageShell(
          top: 36,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const _HeroStatusBadge(),
              const SizedBox(height: 36),
              const Text(
                '필요한 드론 작업,\n검증된 조종사와 빠르게 연결하세요',
                textAlign: TextAlign.center,
                style: HomeText.heroTitle,
              ),
              const SizedBox(height: 22),
              const Text(
                '항공 촬영부터 방제, 점검, 측량까지 한번에',
                textAlign: TextAlign.center,
                style: HomeText.heroSubtitle,
              ),
              const SizedBox(height: 66),
              const _HeroSearchBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.circle, color: _mint, size: 8),
          SizedBox(width: 8),
          Text(
            '자격증·보험 검증 완료 운용자 매칭',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFFD5E4F3),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSearchBar extends StatelessWidget {
  const _HeroSearchBar();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Container(
        height: 86,
        padding: const EdgeInsets.only(left: 28, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF96A5B8),
              size: 26,
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Text('어떤 드론 작업이 필요하세요?', style: HomeText.heroSearch),
            ),
            const Text(
              '가입 없이 30초 만에',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFC6D1DE),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _navy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _MapSection extends StatelessWidget {
  const _MapSection({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Container(
      width: double.infinity,
      color: const Color(0xFFEAF1F8),
      child: _PageShell(
        top: 56,
        bottom: 66,
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
      ),
    );
  }
}
