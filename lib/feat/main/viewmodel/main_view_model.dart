import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_defaults.dart';
import '../../feed/network/feed_api.dart';
import '../../quote/network/quote_api.dart';
import '../../quote/model/quote_model.dart';
import '../model/main_models.dart';
import '../network/drone_pilot_api.dart';
import '../model/drone_pilot_model.dart';

class DrameStore extends ChangeNotifier {
  DrameStore({
    required DronePilotApi api,
    required QuoteApi quoteApi,
    required FeedApi feedApi,
  }) : _api = api,
       _quoteApi = quoteApi,
       _feedApi = feedApi;

  final DronePilotApi _api;
  final QuoteApi _quoteApi;
  final FeedApi _feedApi;

  List<DronePilot> pilots = const <DronePilot>[];
  List<DronePilot> allPilots = const <DronePilot>[];
  List<DroneCategory> categories = defaultDroneCategories;
  List<String> serviceAreas = defaultServiceAreas;
  List<PilotWorkRequest> pilotWorkRequests = const <PilotWorkRequest>[];
  List<UserQuoteSummary> myQuotes = const <UserQuoteSummary>[];
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
      pilotWorkRequests =
          (await _api.fetchOperatorRequests())
              .map(_workRequestFromData)
              .toList();
      myQuotes = await _api.fetchMyQuotes();
      myFeedPosts =
          (await _feedApi.fetchMyPosts()).map(_operatorPostFromFeed).toList();
      final myOperator =
          isLoggedIn && accountRole == '운용자'
              ? await _api.fetchMyOperatorProfile()
              : null;
      operatorRegistrationCompleted = myOperator != null;
      pilots = nextPilots;
      if (initial) {
        allPilots = nextPilots;
      }
      selectedPilot = myOperator ?? (pilots.isEmpty ? null : pilots.first);
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
    if (selectedPortfolioCategory == category) return;
    selectedPortfolioCategory = category;
    notifyListeners();
  }

  void setPilotMode(bool value) {
    if (isPilotMode == value) return;
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
      isPilotOnboarding = false;
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
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
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
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: <String, Object?>{
          'role': role == '운용자' ? 'operator' : 'client',
          'name': name,
          'nickname': nickname,
        },
      );
    } on AuthException catch (error) {
      if (!_isEmailRateLimited(error)) {
        throw Exception(_authErrorMessage(error));
      }

      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException {
        throw Exception(
          'Supabase 메일 발송 제한에 걸렸습니다. 이미 만든 계정이면 로그인으로 진행하고, 새 계정은 Supabase 대시보드에서 Auth > Rate Limits 또는 Email Confirm 설정을 조정한 뒤 다시 시도해 주세요.',
        );
      }
    }
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

  bool _isEmailRateLimited(AuthException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == '429' ||
        message.contains('rate limit') ||
        message.contains('over email send rate limit') ||
        message.contains('email rate limit');
  }

  String _authErrorMessage(AuthException error) {
    if (_isEmailRateLimited(error)) {
      return 'Supabase 메일 발송 제한에 걸렸습니다. 잠시 뒤 다시 시도하거나, 개발 중이면 Supabase Auth 설정에서 이메일 확인을 끄거나 rate limit을 올려 주세요.';
    }
    if (error.message.toLowerCase().contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 맞지 않습니다.';
    }
    if (error.message.toLowerCase().contains('already registered')) {
      return '이미 가입된 이메일입니다. 로그인으로 진행해 주세요.';
    }
    return error.message;
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
    if (pilotOnboardingStep == 0) return;
    pilotOnboardingStep -= 1;
    notifyListeners();
  }

  Future<void> nextPilotOnboardingStep() async {
    if (pilotOnboardingStep >= 4) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          await _api.submitOperatorRegistration(
            PilotRegistrationPayload(
              userId: user.id,
              email:
                  accountEmail.isNotEmpty ? accountEmail : (user.email ?? ''),
              name: accountName,
              nickname: accountNickname,
              data: pilotOnboarding,
            ),
          );
        } on PostgrestException catch (error) {
          throw Exception(
            '운용자 등록 저장에 실패했습니다. Supabase SQL 패치와 RLS 정책을 적용한 뒤 다시 시도해 주세요. (${error.message})',
          );
        }
      }
      pilotOnboarding.submitted = true;
      operatorRegistrationCompleted = true;
      registrationJustCompleted = true;
      isPilotOnboarding = false;
      await load(initial: true);
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
    if (pilotOnboarding.drones.length == 1) return;
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
    if (estimate == null) return;
    paymentConfirmed = true;
    contactAccess = await _quoteApi.createContactAccess(estimate!);
    notifyListeners();
  }

  List<OperatorFeedPost> myFeedPosts = <OperatorFeedPost>[];

  Future<void> addFeedPost({
    required String caption,
    List<int>? imageBytes,
  }) async {
    final post = await _feedApi.createPost(
      caption: caption,
      imageBytes: imageBytes,
    );
    myFeedPosts = <OperatorFeedPost>[
      _operatorPostFromFeed(post),
      ...myFeedPosts,
    ];
    notifyListeners();
  }

  Future<void> deleteFeedPost(String id) async {
    await _feedApi.deletePost(id);
    myFeedPosts = myFeedPosts.where((p) => p.id != id).toList();
    notifyListeners();
  }

  PilotWorkRequest? get firstPilotWorkRequest =>
      pilotWorkRequests.isEmpty ? null : pilotWorkRequests.first;

  PilotWorkRequest _workRequestFromData(PilotWorkRequestData data) {
    return PilotWorkRequest(
      id: data.id,
      category: data.category,
      status: data.status,
      location: data.location,
      distance: '거리 확인 필요',
      dateRange: data.dateRange,
      budget: data.budget,
      client: data.client,
      summary: data.summary,
      progress: '견적 응답 대기',
      remaining: data.remaining,
      mapLabel: '${data.location} 지도',
    );
  }

  OperatorFeedPost _operatorPostFromFeed(FeedPost post) {
    return OperatorFeedPost(
      id: post.id,
      caption: post.caption,
      createdAt: DateTime.now(),
      imageUrl: post.images.isEmpty ? null : post.images.first,
    );
  }
}
