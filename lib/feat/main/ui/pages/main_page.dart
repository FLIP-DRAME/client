import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../common/drame_navigation.dart';
import '../../../../common/drame_text_styles.dart';
import '../../../feed/ui/pages/feed_page.dart';
import '../../../quote/network/mock_quote_api.dart';
import '../../../quote/network/quote_model.dart';
import '../../network/drone_pilot_model.dart';
import '../../network/mock_drone_pilot_api.dart';
import 'package:web/web.dart' as web;
import 'dart:typed_data';         // Uint8List
import 'dart:js_interop';         // JSArrayBuffer, .toDart 사용에 필요
import 'dart:async';        // Completer


part '../component/main_component.dart';
part '../component/operator_mypage_component.dart';

class HomeText {
  static const TextStyle logo = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Color(0xFF111111),
    fontSize: DrameTextStyles.logoSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.15,
    letterSpacing: -0.2,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Color(0xFF111111),
    fontSize: DrameTextStyles.heroTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Color(0xFF4B5563),
    fontSize: 16,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle heroSearch = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Color(0xFF8D9CB0),
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.45,
  );

  static const TextStyle topButton = DrameTextStyles.label;

  static const TextStyle primaryButton = DrameTextStyles.labelStrong;
}

const _navy = Color(0xFF0052FF);
const _toggle = Color(0xFF293341);
const _ink = Color(0xFF111111);
const _muted = Color(0xFF718096);
const _soft = Color(0xFFF7F8FA);
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

class OperatorFeedPost {
  OperatorFeedPost({
    required this.id,
    required this.caption,
    required this.createdAt,
    this.imageBytes,
  });

  final String id;
  final String caption;
  final DateTime createdAt;
  final List<int>? imageBytes; // 웹: Uint8List, 실제 앱에선 File 경로로 교체 가능
}

class PilotWorkRequest {
  const PilotWorkRequest({
    required this.id,
    required this.category,
    required this.status,
    required this.location,
    required this.distance,
    required this.dateRange,
    required this.budget,
    required this.client,
    required this.summary,
    required this.progress,
    required this.remaining,
    required this.mapLabel,
  });

  final String id;
  final String category;
  final String status;
  final String location;
  final String distance;
  final String dateRange;
  final String budget;
  final String client;
  final String summary;
  final String progress;
  final String remaining;
  final String mapLabel;
}

const List<PilotWorkRequest> mockPilotWorkRequests = <PilotWorkRequest>[
  PilotWorkRequest(
    id: 'request-001',
    category: '농약 방제',
    status: '신규',
    location: '경기 화성시',
    distance: '8km',
    dateRange: '2026.04.20',
    budget: '30~100만원',
    client: 'K**',
    summary: '논 3,000평 농약 방제 작업 요청입니다. 비행 승인 대행 포함 희망. 작업 후 GPS 로그 제공 요청드립니다.',
    progress: '현재 2명이 견적 작성 중',
    remaining: '23시간 남음',
    mapLabel: '경기 화성시 지도',
  ),
  PilotWorkRequest(
    id: 'request-002',
    category: '부동산 영상',
    status: '신규',
    location: '서울 강남구',
    distance: '15km',
    dateRange: '2026.04.22',
    budget: '30~100만원',
    client: 'L**',
    summary: '신축 아파트 단지 항공 촬영 요청. 4K 영상 + 편집본 납품. 일몰 전후 골든아워 촬영 희망.',
    progress: '현재 1명이 견적 작성 중',
    remaining: '47시간 남음',
    mapLabel: '서울 강남구 지도',
  ),
  PilotWorkRequest(
    id: 'request-003',
    category: '시설 점검',
    status: '마감 임박',
    location: '인천 남동구',
    distance: '22km',
    dateRange: '2026.04.18 ~ 2026.04.19',
    budget: '100~500만원',
    client: 'P**',
    summary: '태양광 패널 열화상 점검. 약 500kW 규모. 열화상 카메라 탑재 드론 필수. 점검 보고서 포함.',
    progress: '현재 3명이 견적 작성 중',
    remaining: '5시간 남음',
    mapLabel: '인천 남동구 지도',
  ),
  PilotWorkRequest(
    id: 'request-004',
    category: '측량·매핑',
    status: '검토 중',
    location: '경기 용인시',
    distance: '31km',
    dateRange: '2026.04.25',
    budget: '100~500만원',
    client: 'J**',
    summary: '건설 현장 토공량 산출을 위한 3D 매핑. RTK GPS 탑재 드론 필수. DXF 파일 납품.',
    progress: '현재 1명이 견적 작성 중',
    remaining: '71시간 남음',
    mapLabel: '경기 용인시 지도',
  ),
  PilotWorkRequest(
    id: 'request-005',
    category: '행사촬영',
    status: '신규',
    location: '부산 해운대',
    distance: '42km',
    dateRange: '2026.04.27',
    budget: '50~150만원',
    client: 'M**',
    summary: '해변 행사 항공 촬영과 하이라이트 영상 제작 요청. 안전요원 동선과 관람객 밀집 구간 고려 필요.',
    progress: '현재 2명이 견적 작성 중',
    remaining: '96시간 남음',
    mapLabel: '부산 해운대 지도',
  ),
];

void _openPortfolio(BuildContext context, DronePilot pilot) {
  context.push('/portfolio/${pilot.id}', extra: pilot);
}

void _openPilotRequestReviewPage(
  BuildContext context, {
  required PilotWorkRequest initialRequest,
}) {
  context.push('/pilot/requests', extra: initialRequest);
}

class PilotRequestReviewPage extends StatelessWidget {
  const PilotRequestReviewPage({super.key, required this.initialRequest});

  final PilotWorkRequest initialRequest;

  @override
  Widget build(BuildContext context) {
    return _PilotRequestReviewPage(initialRequest: initialRequest);
  }
}

class PilotRegistrationPage extends StatefulWidget {
  const PilotRegistrationPage({super.key});

  @override
  State<PilotRegistrationPage> createState() => _PilotRegistrationPageState();
}

class _PilotRegistrationPageState extends State<PilotRegistrationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrameStore>().openPilotOnboarding();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (store.isPilotAuthOpen ||
                !store.isLoggedIn ||
                store.accountRole != '운용자') {
              return _PilotAuthSection(store: store);
            }
            if (store.operatorRegistrationCompleted &&
                !store.isPilotOnboarding) {
              return _PilotRegistrationDoneSection(store: store);
            }
            return _PilotOnboardingSection(store: store);
          },
        ),
      ),
    );
  }
}

class OperatorMyPage extends StatelessWidget {
  const OperatorMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder:
              (context, store, _) =>
                  _OperatorProfileManagementPage(store: store),
        ),
      ),
    );
  }
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

  void goToPilotOnboardingStep(int step) {
    pilotOnboardingStep = step.clamp(0, 4);
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
    if (pilotOnboardingStep >= 4) {
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

  List<OperatorFeedPost> myFeedPosts = <OperatorFeedPost>[];

  void addFeedPost({required String caption, List<int>? imageBytes}) {
    myFeedPosts = <OperatorFeedPost>[
      OperatorFeedPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caption: caption,
        createdAt: DateTime.now(),
        imageBytes: imageBytes,
      ),
      ...myFeedPosts,
    ];
    notifyListeners();
  }

  void deleteFeedPost(String id) {
    myFeedPosts = myFeedPosts.where((p) => p.id != id).toList();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (store.isLoading && store.pilots.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: DrameTopNavigation(
                    isPilotMode: store.isPilotMode,
                    onModeChanged: store.setPilotMode,
                    onLoginTap: () {
                      store.setPilotMode(true);
                      store.openAuth(loginMode: true, role: '운용자');
                    },
                    onRegisterTap: () => context.push('/pilot/register'),
                    onLogoTap: () => context.go('/'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: DrameSecondaryNavigation(
                    isPilotMode: store.isPilotMode,
                    onFindPilotTap: () => _scrollToSection(_categorySectionKey),
                    onPortfolioTap:
                        () => _scrollToSection(_portfolioSectionKey),
                    onRequestsTap:
                        () => _openPilotRequestReviewPage(
                          context,
                          initialRequest: mockPilotWorkRequests.first,
                        ),
                    onMyPageTap: () => context.push('/pilot/mypage'),
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

// ignore: unused_element
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
                  onPressed: () => context.push('/pilot/register'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
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

// ignore: unused_element
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

// ignore: unused_element
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
          color: selected ? _toggle : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: HomeText.topButton.copyWith(
            color: selected ? Colors.white : _muted,
            fontWeight: DrameTextStyles.semiBold,
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
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

// ignore: unused_element
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
        textStyle: DrameTextStyles.button,
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
    final compact = MediaQuery.sizeOf(context).width < 760;

    return SizedBox(
      height: compact ? 420 : 520,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFEAF7FF)),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _HeroWashBackground(),
            _PageShell(
              top: compact ? 54 : 86,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const _HeroStatusBadge(),
                  SizedBox(height: compact ? 28 : 38),
                  Text(
                    '필요한 드론 작업을 더 쉽고 빠르게,\n검증된 운용자와 더 넓은 현장으로.',
                    textAlign: TextAlign.center,
                    style: HomeText.heroTitle.copyWith(
                      fontSize: compact ? 30 : 46,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '항공 촬영부터 방제, 점검, 측량까지 Drame에서 한 번에 연결하세요.',
                    textAlign: TextAlign.center,
                    style: HomeText.heroSubtitle.copyWith(
                      fontSize: compact ? 15 : 17,
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

class _HeroWashBackground extends StatelessWidget {
  const _HeroWashBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFFEAFBFF),
            Color(0xFFEFF9FF),
            Color(0xFFDCEFFF),
          ],
        ),
      ),
      child: CustomPaint(painter: _HeroWashPainter()),
    );
  }
}

class _HeroWashPainter extends CustomPainter {
  const _HeroWashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue =
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              const Color(0xFF0052FF).withValues(alpha: 0.30),
              const Color(0xFF87C7FF).withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.72, size.height * 0.36),
              radius: size.width * 0.34,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.36),
      size.width * 0.34,
      blue,
    );

    final wave =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.58)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 56
          ..strokeCap = StrokeCap.round;
    final path =
        Path()
          ..moveTo(size.width * 0.50, size.height * 1.02)
          ..cubicTo(
            size.width * 0.62,
            size.height * 0.76,
            size.width * 0.80,
            size.height * 0.70,
            size.width * 0.97,
            size.height * 0.46,
          );
    canvas.drawPath(path, wave);

    final gloss =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;
    final glossPath =
        Path()
          ..moveTo(size.width * 0.62, size.height * 0.02)
          ..cubicTo(
            size.width * 0.72,
            size.height * 0.22,
            size.width * 0.88,
            size.height * 0.28,
            size.width,
            size.height * 0.58,
          );
    canvas.drawPath(glossPath, gloss);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.circle, color: _navy, size: 8),
          SizedBox(width: 8),
          Text(
            '자격증·보험 검증 완료 운용자 매칭',
            style: TextStyle(
              fontFamily: DrameTextStyles.fontFamily,
              color: _ink,
              fontSize: DrameTextStyles.labelSize,
              fontWeight: DrameTextStyles.semiBold,
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
