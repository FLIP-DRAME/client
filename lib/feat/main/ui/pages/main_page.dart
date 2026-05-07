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
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.4,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: 'Pretendard',
    color: Colors.white,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -1.0,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFFB9C7D8),
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.55,
    letterSpacing: -0.2,
  );

  static const TextStyle heroSearch = TextStyle(
    fontFamily: 'Pretendard',
    color: Color(0xFF8D9CB0),
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static const TextStyle topButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.1,
  );

  static const TextStyle primaryButton = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
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

class PilotDroneForm {
  PilotDroneForm({
    this.maker = 'DJI',
    this.model = '',
    Set<String>? categories,
    Set<String>? sensors,
    this.registrationNumber = '',
    this.photoUploaded = false,
  }) : categories = categories ?? <String>{},
       sensors = sensors ?? <String>{};

  String maker;
  String model;
  Set<String> categories;
  Set<String> sensors;
  String registrationNumber;
  bool photoUploaded;
}

class PilotOnboardingData {
  String licenseType = '초경량비행장치 조종자';
  String licenseNumber = '';
  bool licenseFrontUploaded = false;
  bool licenseBackUploaded = false;
  String businessName = '';
  String businessNumber = '';
  String representativeName = '';
  String insuranceCompany = 'DB손해보험';
  String insuranceNumber = '';
  bool insuranceUploaded = false;
  List<PilotDroneForm> drones = <PilotDroneForm>[PilotDroneForm()];
  Set<String> areas = <String>{};
  Set<String> portfolioTypes = <String>{};
  String portfolioUrl = '';
  bool sampleUploaded = false;
  bool submitted = false;
}

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
  String selectedPortfolioCategory = '전체';
  String selectedRegion = '전체';
  String selectedDistrict = '전체';
  String selectedArea = '전체';
  QuoteRequest? quoteRequest;
  QuoteEstimate? estimate;
  PaymentInstruction? paymentInstruction;
  ContactAccess? contactAccess;
  bool paymentConfirmed = false;
  bool isLoading = true;
  bool isRefreshing = false;
  bool isPilotMode = false;
  bool isPilotAuthOpen = false;
  bool isLoginMode = false;
  bool isLoggedIn = false;
  bool isPilotOnboarding = false;
  bool operatorRegistrationCompleted = false;
  bool operatorPortfolioCompleted = false;
  int pilotOnboardingStep = 0;
  String accountRole = '운용자';
  String accountEmail = '';
  String accountId = '';
  String accountPassword = '';
  String accountName = '';
  String accountNickname = '';
  final PilotOnboardingData pilotOnboarding = PilotOnboardingData();

  Future<void> load({bool initial = false}) async {
    if (initial) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    notifyListeners();

    final nextPilots = await _api.fetchPilots(
      priorityArea: selectedArea,
      category: selectedCategory?.label,
    );
    pilots = nextPilots;
    selectedPilot = pilots.isEmpty ? null : pilots.first;
    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> selectCategory(DroneCategory category) async {
    selectedCategory = category;
    selectedRegion = '전체';
    selectedDistrict = '전체';
    selectedArea = '전체';
    await load();
  }

  Future<void> selectRegion(String region) async {
    selectedRegion = region;
    selectedDistrict = '전체';
    selectedArea = region == '전체' ? '전체' : region;
    await load();
  }

  Future<void> selectArea(String area) async {
    selectedRegion = area;
    selectedDistrict = '전체';
    selectedArea = area;
    await load();
  }

  Future<void> selectDistrict(String district) async {
    selectedDistrict = district;
    selectedArea = district == '전체' ? selectedRegion : district;
    await load();
  }

  Future<void> selectNeighborhood(String neighborhood) async {
    selectedArea = neighborhood == '전체' ? selectedDistrict : neighborhood;
    await load();
  }

  void selectPilot(DronePilot pilot) {
    selectedPilot = pilot;
    notifyListeners();
  }

  void selectPortfolioCategory(String category) {
    if (selectedPortfolioCategory == category) {
      return;
    }
    selectedPortfolioCategory = category;
    notifyListeners();
  }

  void setPilotMode(bool value) {
    if (isPilotMode == value) {
      return;
    }
    isPilotMode = value;
    if (!value) {
      isPilotAuthOpen = false;
      isPilotOnboarding = false;
    }
    notifyListeners();
  }

  void openPilotOnboarding() {
    isPilotMode = true;
    if (!isLoggedIn || accountRole != '운용자') {
      isPilotAuthOpen = true;
      isPilotOnboarding = false;
      isLoginMode = false;
      accountRole = '운용자';
      notifyListeners();
      return;
    }
    isPilotAuthOpen = false;
    isPilotOnboarding = true;
    notifyListeners();
  }

  void closePilotOnboarding() {
    isPilotOnboarding = false;
    notifyListeners();
  }

  void openAuth({bool loginMode = false, String? role}) {
    isPilotAuthOpen = true;
    isPilotOnboarding = false;
    isLoginMode = loginMode;
    accountRole = role ?? accountRole;
    notifyListeners();
  }

  void updateAuth({
    bool? loginMode,
    String? role,
    String? email,
    String? accountId,
    String? password,
    String? name,
    String? nickname,
  }) {
    isLoginMode = loginMode ?? isLoginMode;
    accountRole = role ?? accountRole;
    accountEmail = email ?? accountEmail;
    this.accountId = accountId ?? this.accountId;
    accountPassword = password ?? accountPassword;
    accountName = name ?? accountName;
    accountNickname = nickname ?? accountNickname;
    notifyListeners();
  }

  void submitAuth() {
    isLoggedIn = true;
    isPilotAuthOpen = false;
    if (accountRole == '운용자') {
      isPilotMode = true;
      isPilotOnboarding = !operatorRegistrationCompleted;
    } else {
      isPilotMode = false;
      isPilotOnboarding = false;
    }
    notifyListeners();
  }

  void completeOperatorPortfolio() {
    operatorPortfolioCompleted = true;
    pilotOnboarding.sampleUploaded = true;
    notifyListeners();
  }

  void goToPilotOnboardingStep(int step) {
    pilotOnboardingStep = step.clamp(0, 5);
    notifyListeners();
  }

  void previousPilotOnboardingStep() {
    if (pilotOnboardingStep == 0) {
      return;
    }
    pilotOnboardingStep -= 1;
    notifyListeners();
  }

  void nextPilotOnboardingStep() {
    if (pilotOnboardingStep >= 5) {
      pilotOnboarding.submitted = true;
      operatorRegistrationCompleted = true;
      isPilotOnboarding = false;
      notifyListeners();
      return;
    }
    pilotOnboardingStep += 1;
    notifyListeners();
  }

  void updatePilotLicense({
    String? type,
    String? number,
    bool? frontUploaded,
    bool? backUploaded,
  }) {
    pilotOnboarding.licenseType = type ?? pilotOnboarding.licenseType;
    pilotOnboarding.licenseNumber = number ?? pilotOnboarding.licenseNumber;
    pilotOnboarding.licenseFrontUploaded =
        frontUploaded ?? pilotOnboarding.licenseFrontUploaded;
    pilotOnboarding.licenseBackUploaded =
        backUploaded ?? pilotOnboarding.licenseBackUploaded;
    notifyListeners();
  }

  void updatePilotBusiness({
    String? name,
    String? number,
    String? representative,
  }) {
    pilotOnboarding.businessName = name ?? pilotOnboarding.businessName;
    pilotOnboarding.businessNumber = number ?? pilotOnboarding.businessNumber;
    pilotOnboarding.representativeName =
        representative ?? pilotOnboarding.representativeName;
    notifyListeners();
  }

  void updatePilotInsurance({String? company, String? number, bool? uploaded}) {
    pilotOnboarding.insuranceCompany =
        company ?? pilotOnboarding.insuranceCompany;
    pilotOnboarding.insuranceNumber = number ?? pilotOnboarding.insuranceNumber;
    pilotOnboarding.insuranceUploaded =
        uploaded ?? pilotOnboarding.insuranceUploaded;
    notifyListeners();
  }

  void updatePilotDrone(
    int index, {
    String? maker,
    String? model,
    String? registrationNumber,
    bool? photoUploaded,
  }) {
    final drone = pilotOnboarding.drones[index];
    drone.maker = maker ?? drone.maker;
    drone.model = model ?? drone.model;
    drone.registrationNumber = registrationNumber ?? drone.registrationNumber;
    drone.photoUploaded = photoUploaded ?? drone.photoUploaded;
    notifyListeners();
  }

  void togglePilotDroneCategory(int index, String category) {
    final categories = pilotOnboarding.drones[index].categories;
    categories.contains(category)
        ? categories.remove(category)
        : categories.add(category);
    notifyListeners();
  }

  void togglePilotDroneSensor(int index, String sensor) {
    final sensors = pilotOnboarding.drones[index].sensors;
    sensors.contains(sensor) ? sensors.remove(sensor) : sensors.add(sensor);
    notifyListeners();
  }

  void addPilotDrone() {
    pilotOnboarding.drones.add(PilotDroneForm());
    notifyListeners();
  }

  void removePilotDrone(int index) {
    if (pilotOnboarding.drones.length == 1) {
      return;
    }
    pilotOnboarding.drones.removeAt(index);
    notifyListeners();
  }

  void togglePilotArea(String area) {
    pilotOnboarding.areas.contains(area)
        ? pilotOnboarding.areas.remove(area)
        : pilotOnboarding.areas.add(area);
    notifyListeners();
  }

  void togglePilotPortfolioType(String type) {
    pilotOnboarding.portfolioTypes.contains(type)
        ? pilotOnboarding.portfolioTypes.remove(type)
        : pilotOnboarding.portfolioTypes.add(type);
    notifyListeners();
  }

  void updatePilotPortfolio({String? url, bool? sampleUploaded}) {
    pilotOnboarding.portfolioUrl = url ?? pilotOnboarding.portfolioUrl;
    pilotOnboarding.sampleUploaded =
        sampleUploaded ?? pilotOnboarding.sampleUploaded;
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
  final GlobalKey _categorySectionKey = GlobalKey();
  final GlobalKey _portfolioSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrameStore>().load(initial: true);
    });
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
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
                SliverToBoxAdapter(child: _TopNavigation(store: store)),
                SliverToBoxAdapter(
                  child: _SecondaryNavigation(
                    onFindPilotTap: () => _scrollToSection(_categorySectionKey),
                    onPortfolioTap:
                        () => _scrollToSection(_portfolioSectionKey),
                  ),
                ),
                if (store.isPilotMode) ...<Widget>[
                  SliverToBoxAdapter(
                    child:
                        store.isPilotAuthOpen
                            ? _PilotAuthSection(store: store)
                            : store.isPilotOnboarding
                            ? _PilotOnboardingSection(store: store)
                            : store.operatorRegistrationCompleted
                            ? _PilotDashboardSection(store: store)
                            : _PilotLandingSection(store: store),
                  ),
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ] else ...<Widget>[
                  const SliverToBoxAdapter(child: _LandingHeroSection()),
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _categorySectionKey,
                      child: _CategorySelectionSection(store: store),
                    ),
                  ),
                  if (store.selectedCategory != null) ...<Widget>[
                    SliverToBoxAdapter(
                      child: _AreaSelectionSection(store: store),
                    ),
                    if (store.selectedArea != '전체')
                      SliverToBoxAdapter(
                        child: _OperatorListSection(store: store),
                      ),
                  ],
                  const SliverToBoxAdapter(
                    child: ColoredBox(
                      color: Colors.white,
                      child: DroneFeedSection(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _portfolioSectionKey,
                      child: _PopularPortfolioSection(store: store),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({required this.store});

  final DrameStore store;

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
                  // _TopSearch(),
                ],
                const Spacer(),
                const SizedBox(width: 22),
                if (!compact) ...<Widget>[
                  _ModeToggle(
                    isPilotMode: store.isPilotMode,
                    onChanged: store.setPilotMode,
                  ),
                  const SizedBox(width: 14),
                ],
                TextButton(
                  onPressed: () {
                    store.setPilotMode(true);
                    store.openAuth(loginMode: true, role: '운용자');
                  },
                  style: TextButton.styleFrom(
                    textStyle: HomeText.topButton,
                    foregroundColor: _ink,
                  ),
                  child: const Text('로그인 / 회원가입'),
                ),
                FilledButton(
                  onPressed: store.openPilotOnboarding,
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
                  child: const Text('운용자 등록'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isPilotMode, required this.onChanged});

  final bool isPilotMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ModeToggleItem(
            label: '이용자',
            selected: !isPilotMode,
            onTap: () => onChanged(false),
          ),
          _ModeToggleItem(
            label: '운용자',
            selected: isPilotMode,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleItem extends StatelessWidget {
  const _ModeToggleItem({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _navy : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: HomeText.topButton.copyWith(
            color: selected ? Colors.white : _muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SecondaryNavigation extends StatelessWidget {
  const _SecondaryNavigation({
    required this.onFindPilotTap,
    required this.onPortfolioTap,
  });

  final VoidCallback onFindPilotTap;
  final VoidCallback onPortfolioTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final tabs = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.person_search_rounded,
        label: '촬영자 찾기',
        onTap: onFindPilotTap,
      ),
      (icon: Icons.grid_view_rounded, label: '포트폴리오', onTap: onPortfolioTap),
      (icon: Icons.info_outline_rounded, label: 'Drame 소개', onTap: () {}),
      (icon: Icons.map_outlined, label: '비행공역 확인', onTap: () {}),
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
                        child: _SubNavTab(
                          icon: tab.icon,
                          label: tab.label,
                          onTap: tab.onTap,
                        ),
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
  const _SubNavTab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6E7F99),
        textStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
      height: 380,
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
            children: const <Widget>[
              _HeroStatusBadge(),
              SizedBox(height: 36),
              Text(
                '필요한 드론 작업,\n검증된 조종사와 빠르게 연결하세요',
                textAlign: TextAlign.center,
                style: HomeText.heroTitle,
              ),
              SizedBox(height: 22),
              Text(
                '항공 촬영부터 방제, 점검, 측량까지 한번에',
                textAlign: TextAlign.center,
                style: HomeText.heroSubtitle,
              ),
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
