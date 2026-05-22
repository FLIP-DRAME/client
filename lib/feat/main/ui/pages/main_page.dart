import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_navigation.dart';
import '../../../../common/drame_text_styles.dart';
import '../../../feed/ui/pages/feed_page.dart';
import '../../../quote/network/quote_api.dart';
import '../../../quote/network/quote_model.dart';
import '../../network/drone_pilot_api.dart';
import '../../network/drone_pilot_model.dart';
import '../../network/mock_drone_pilot_api.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop'; // JSArrayBuffer, .toDart 사용에 필요
import 'dart:async'; // Completer

part '../component/main_component.dart';
part '../component/operator_mypage_component.dart';
part '../component/feed_standalone_component.dart';
part '../component/portfolio_standalone_component.dart';
part '../component/my_quotes_component.dart';

class HomeText {
  static const TextStyle logo = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.logoSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.15,
    letterSpacing: -0.2,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.heroTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: 16,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle heroSearch = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.45,
  );

  static const TextStyle topButton = DrameTextStyles.label;

  static const TextStyle primaryButton = DrameTextStyles.labelStrong;
}

const _primary = Color(0xFF0052FF);
const _navy = Colors.black;
const _toggle = Color(0xFFE5E7EB);
const _focus = Color(0xFFE5E7EB);
const _ink = Colors.black;
const _muted = Colors.black;
const _soft = Color(0xFFF7F8FA);
const _line = Color(0xFFE4EAF2);
const _mint = Color(0xFF22C58B);

typedef StoreBuilder = Widget Function(
  BuildContext context,
  DrameStore store,
  Widget? child,
);

class Consumer<T> extends ConsumerWidget {
  const Consumer({super.key, required this.builder});

  final StoreBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref.watch(drameStoreProvider), null);
  }
}

extension DrameStoreContext on BuildContext {
  T read<T>() {
    if (T == DrameStore) {
      return ProviderScope.containerOf(this, listen: false)
          .read(drameStoreProvider) as T;
    }
    throw UnsupportedError('No Riverpod bridge registered for $T.');
  }
}

class BusinessNumberInputFormatter extends TextInputFormatter {
  const BusinessNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < limited.length; i += 1) {
      if (i == 3 || i == 5) {
        buffer.write('-');
      }
      buffer.write(limited[i]);
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

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
      final store = context.read<DrameStore>();
      store.restoreSession().then((_) {
        if (!mounted) return;
        if (!store.isLoggedIn) {
          context.go('/login');
          return;
        }
        store.openPilotOnboarding();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (!store.isLoggedIn) {
              return const SizedBox.shrink();
            }
            if (store.operatorRegistrationCompleted &&
                !store.isPilotOnboarding) {
              return _PilotRegistrationDoneSection(store: store);
            }
            return SingleChildScrollView(
              child: _PilotOnboardingSection(store: store),
            );
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
    return Consumer<DrameStore>(
      builder: (context, store, _) =>
          _OperatorProfileManagementPage(store: store),
    );
  }
}

class DrameStore extends ChangeNotifier {
  DrameStore({required DronePilotApi api, required QuoteApi quoteApi})
    : _api = api,
      _quoteApi = quoteApi;

  final DronePilotApi _api;
  final QuoteApi _quoteApi;

  List<DronePilot> pilots = const <DronePilot>[];
  List<DronePilot> allPilots = const <DronePilot>[];
  List<DroneCategory> categories = mockDroneCategories;
  List<String> serviceAreas = mockServiceAreas;
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
  String? lastError;
  bool isPilotMode = false;
  bool isPilotAuthOpen = false;
  bool isLoginMode = false;
  bool isLoggedIn = false;
  bool isPilotOnboarding = false;
  bool operatorRegistrationCompleted = false;
  bool registrationJustCompleted = false;
  int pilotOnboardingStep = 0;
  String accountRole = '운용자';
  String accountEmail = '';
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

    try {
      categories = await _api.fetchCategories();
      serviceAreas = await _api.fetchRegions();
      final nextPilots = await _api.fetchPilots(
        priorityArea: selectedArea,
        category: selectedCategory?.label,
      );
      pilots = nextPilots;
      if (initial) {
        allPilots = nextPilots;
      }
      selectedPilot = pilots.isEmpty ? null : pilots.first;
      lastError = null;
    } catch (error) {
      lastError = error.toString();
      pilots = const <DronePilot>[];
      if (initial) {
        allPilots = const <DronePilot>[];
      }
      selectedPilot = null;
    }
    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  void clearCategory() {
    selectedCategory = null;
    selectedRegion = '전체';
    selectedDistrict = '전체';
    selectedArea = '전체';
    pilots = allPilots;
    selectedPilot = pilots.isEmpty ? null : pilots.first;
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
    String? password,
    String? name,
    String? nickname,
  }) {
    isLoginMode = loginMode ?? isLoginMode;
    accountRole = role ?? accountRole;
    accountEmail = email ?? accountEmail;
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

  Future<void> signIn({
    required String role,
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    updateAuth(loginMode: true, role: role, email: email, password: password);
    submitAuth();
  }

  Future<void> signUp({
    required String role,
    required String email,
    required String password,
    required String name,
    required String nickname,
  }) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: <String, Object?>{
        'role': role == '운용자' ? 'operator' : 'client',
        'name': name,
        'nickname': nickname,
      },
    );
    updateAuth(
      loginMode: false,
      role: role,
      email: email,
      password: password,
      name: name,
      nickname: nickname,
    );
    submitAuth();
  }

  Future<void> restoreSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final role = metadata['role'] == 'operator' ? '운용자' : '이용자';
    updateAuth(
      loginMode: true,
      role: role,
      email: user.email ?? '',
      name: (metadata['name'] ?? '').toString(),
      nickname: (metadata['nickname'] ?? '').toString(),
    );
    submitAuth();
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

  Future<void> nextPilotOnboardingStep() async {
    if (pilotOnboardingStep >= 4) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _api.submitOperatorRegistration(
          PilotRegistrationPayload(
            userId: user.id,
            email: accountEmail.isNotEmpty ? accountEmail : (user.email ?? ''),
            name: accountName,
            nickname: accountNickname,
            data: pilotOnboarding,
          ),
        );
      }
      pilotOnboarding.submitted = true;
      operatorRegistrationCompleted = true;
      registrationJustCompleted = true;
      isPilotOnboarding = false;
      notifyListeners();
      return;
    }
    pilotOnboardingStep += 1;
    notifyListeners();
  }

  void acknowledgeRegistrationDone() {
    registrationJustCompleted = false;
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
    paymentInstruction = await _quoteApi.createPaymentInstruction(estimate!);
    estimate = estimate!.copyWith(paymentId: paymentInstruction?.paymentId);
    contactAccess = null;
    paymentConfirmed = false;
    notifyListeners();
    return estimate!;
  }

  Future<void> confirmPayment() async {
    if (estimate == null) {
      return;
    }
    paymentConfirmed = true;
    contactAccess = await _quoteApi.createContactAccess(estimate!);
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
  final GlobalKey _areaSectionKey = GlobalKey();
  final GlobalKey _operatorSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // Tab state: 'all' | category id (user), or 'dashboard'|'requests'|'feed'|'profile' (operator)
  String _selectedTabId = 'all';
  // Mobile tab index
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<DrameStore>();
      store.restoreSession().then((_) {
        if (!mounted) return;
        if (!store.isLoggedIn) {
          context.go('/login');
          return;
        }
        store.load(initial: true);
      });
      if (!store.isLoggedIn && Supabase.instance.client.auth.currentUser == null) {
        context.go('/login');
        return;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleUserTabChanged(String id, DrameStore store) {
    setState(() => _selectedTabId = id);
    if (id == 'all') {
      store.clearCategory();
      _scrollToTop();
    } else {
      if (store.categories.isEmpty) {
        return;
      }
      final cat = store.categories.firstWhere(
        (c) => c.id == id,
        orElse: () => store.categories.first,
      );
      store.selectCategory(cat);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(_areaSectionKey);
      });
    }
  }

  void _handleOperatorTabChanged(String id, BuildContext ctx, DrameStore store) {
    setState(() => _selectedTabId = id);
    switch (id) {
      case 'requests':
        _openPilotRequestReviewPage(ctx, initialRequest: mockPilotWorkRequests.first);
      case 'profile':
        ctx.push('/pilot/mypage');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (store.isLoading && store.pilots.isEmpty) {
          return const Scaffold(
            backgroundColor: DC.canvas,
            body: Center(
              child: CircularProgressIndicator(color: DC.primary),
            ),
          );
        }
        return compact
            ? _buildMobileLayout(context, store)
            : _buildWebLayout(context, store);
      },
    );
  }

  Widget _buildWebLayout(BuildContext context, DrameStore store) {
    // Operator mode: logged in as operator
    final isOperatorDashboard =
        store.isLoggedIn && store.isPilotMode;

    // Sync selected tab with store category when user navigates
    final tabId = store.selectedCategory != null
        ? store.selectedCategory!.id
        : (_selectedTabId == 'all' ? 'all' : _selectedTabId);

    return Scaffold(
      backgroundColor: DC.canvas,
      body: Column(
        children: <Widget>[
          // ── Sticky top nav ──────────────────────────────────────────────────
          DrameTopNavigation(
            isLoggedIn: store.isLoggedIn,
            isOperator: isOperatorDashboard,
            isOperatorRegistered: store.operatorRegistrationCompleted,
            nickname: store.isLoggedIn
                ? (store.accountNickname.isNotEmpty
                    ? store.accountNickname
                    : store.accountName)
                : null,
            activePage: 'find',
            onLoginTap: () => context.go('/login'),
            onRegisterPilotTap: () => context.push('/pilot/register'),
            onLogoTap: () {
              store.clearCategory();
              store.setPilotMode(false);
              setState(() => _selectedTabId = 'all');
              _scrollToTop();
            },
            onFindPilotTap: () {
              store.setPilotMode(false);
              setState(() => _selectedTabId = 'all');
              _scrollToSection(_categorySectionKey);
            },
            onFeedTap: () => context.go('/feed'),
            onPortfolioTap: () => context.go('/portfolio'),
            onMyQuotesTap: () => context.go('/my/quotes'),
            onSwitchToUser: () { store.setPilotMode(false); context.go('/home'); },
            onSwitchToOperator: () { store.setPilotMode(true); context.go('/home'); },
            onRequestsTap: () => _openPilotRequestReviewPage(
              context,
              initialRequest: mockPilotWorkRequests.first,
            ),
            onMyPageTap: () => context.push('/pilot/mypage'),
          ),

          // ── Sticky secondary tab bar ────────────────────────────────────────
          DrameTabNav(
            isOperator: isOperatorDashboard && store.operatorRegistrationCompleted,
            selectedId: isOperatorDashboard ? _selectedTabId : tabId,
            onTabChanged: (id) {
              if (isOperatorDashboard) {
                _handleOperatorTabChanged(id, context, store);
              } else {
                _handleUserTabChanged(id, store);
              }
            },
          ),

          // ── Scrollable content ──────────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                if (isOperatorDashboard) ...<Widget>[
                  SliverToBoxAdapter(
                    child: store.isPilotAuthOpen
                        ? _PilotAuthSection(store: store)
                        : store.isPilotOnboarding
                            ? _PilotOnboardingSection(store: store)
                            : store.registrationJustCompleted
                                ? _PilotRegistrationDoneSection(store: store)
                                : store.operatorRegistrationCompleted
                                    ? (_selectedTabId == 'feed'
                                        ? _OperatorFeedTabPage(store: store)
                                        : _PilotDashboardSection(store: store))
                                    : _PilotLandingSection(store: store),
                  ),
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ] else ...<Widget>[
                  // ── How it works ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _RevealOnScroll(
                      scrollController: _scrollController,
                      child: const _HowItWorksSection(),
                    ),
                  ),

                  // ── Live operators banner ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: _RevealOnScroll(
                      scrollController: _scrollController,
                      child: _LiveOperatorsBannerSection(store: store),
                    ),
                  ),

                  // ── Category cards ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _categorySectionKey,
                      child: _RevealOnScroll(
                        scrollController: _scrollController,
                        child: _CategorySelectionSection(
                          store: store,
                          onCategorySelected: () =>
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToSection(_areaSectionKey),
                              ),
                        ),
                      ),
                    ),
                  ),

                  // ── Area + operator list (after category selected) ──────────
                  if (store.selectedCategory != null) ...<Widget>[
                    SliverToBoxAdapter(
                      child: KeyedSubtree(
                        key: _areaSectionKey,
                        child: _AreaSelectionSection(
                          store: store,
                          onAreaSelected: () =>
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToSection(_operatorSectionKey),
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: KeyedSubtree(
                        key: _operatorSectionKey,
                        child: _OperatorListSection(store: store),
                      ),
                    ),
                  ],

                  // ── Operator CTA band ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _OperatorCtaBand(
                      onTap: () => context.push('/pilot/register'),
                    ),
                  ),

                  // ── Footer ─────────────────────────────────────────────────
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DrameStore store) {
    // 운용자 모드이고 아직 등록 미완료 또는 방금 완료 → 전체화면, 네비게이션 없음
    if (store.isPilotMode &&
        (!store.operatorRegistrationCompleted ||
            store.registrationJustCompleted)) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: store.isPilotAuthOpen
                ? _PilotAuthSection(store: store)
                : store.isPilotOnboarding
                    ? _PilotOnboardingSection(store: store)
                    : store.registrationJustCompleted
                        ? _PilotRegistrationDoneSection(store: store)
                        : _PilotLandingSection(store: store),
          ),
        ),
      );
    }

    final navItems = store.isPilotMode
        ? const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_outlined),
              activeIcon: Icon(Icons.dynamic_feed_rounded),
              label: '피드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description_rounded),
              label: '요청 확인',
            ),
          ]
        : const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: '촬영자 찾기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_outlined),
              activeIcon: Icon(Icons.dynamic_feed_rounded),
              label: '피드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: '포트폴리오',
            ),
          ];

    final safeIndex = _tabIndex.clamp(0, navItems.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _MobileAppBar(
          store: store,
          onLoginTap: () => context.go('/login'),
          onLogoTap: () {
            store.setPilotMode(false);
            setState(() => _tabIndex = 0);
          },
          onModeChanged: (value) {
            store.setPilotMode(value);
            setState(() => _tabIndex = 0);
          },
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: safeIndex,
          children: store.isPilotMode
              ? <Widget>[
                  SingleChildScrollView(
                    child: store.isPilotOnboarding
                        ? _PilotOnboardingSection(store: store)
                        : _PilotDashboardSection(store: store),
                  ),
                  SingleChildScrollView(
                    child: _OperatorFeedSection(store: store),
                  ),
                  _MobilePilotRequestsPage(store: store),
                ]
              : <Widget>[
                  _MobileSearchFlow(store: store),
                  const SingleChildScrollView(
                    child: ColoredBox(
                      color: Colors.white,
                      child: DroneFeedSection(),
                    ),
                  ),
                  SingleChildScrollView(
                    child: _PopularPortfolioSection(store: store),
                  ),
                ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        selectedItemColor: _primary,
        unselectedItemColor: const Color(0xFF8BA0B8),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: navItems,
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
                    backgroundColor: _primary,
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
            color: selected ? _ink : _muted,
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
