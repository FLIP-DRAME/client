import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  List<AppNotification> notifications = const <AppNotification>[];
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
  bool isLoggedIn = false;
  bool isPilotOnboarding = false;
  bool isSessionRestoring = true;
  bool operatorRegistrationCompleted = false;
  String operatorReviewStatus = 'none';
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
          isLoggedIn ? await _api.fetchMyOperatorProfile() : null;
      if (myOperator != null) {
        accountRole = '운용자';
        operatorRegistrationCompleted = true;
        operatorReviewStatus = myOperator.operatorStatus;
      } else {
        // 운용자 등록 정보가 없으면 미등록 상태로 리셋
        operatorRegistrationCompleted = false;
        operatorReviewStatus = 'none';
      }
      notifications = _mergeNotifications(
        await _api.fetchNotifications(),
        pilotWorkRequests: pilotWorkRequests,
        quotes: myQuotes,
      );
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
    selectedArea =
        district == '전체' ? selectedRegion : '$selectedRegion $district';
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
      isPilotOnboarding = false;
    }
    notifyListeners();
  }

  void openPilotOnboarding() {
    isPilotMode = true;
    isPilotOnboarding = true;
    notifyListeners();
  }

  void closePilotOnboarding() {
    isPilotOnboarding = false;
    notifyListeners();
  }

  void updateAuth({
    String? role,
    String? email,
    String? password,
    String? name,
    String? nickname,
  }) {
    accountRole = role ?? accountRole;
    accountEmail = email ?? accountEmail;
    accountPassword = password ?? accountPassword;
    accountName = name ?? accountName;
    accountNickname = nickname ?? accountNickname;
    notifyListeners();
  }

  void submitAuth() {
    isLoggedIn = true;
    if (accountRole == '운용자') {
      isPilotMode = true;
      isPilotOnboarding = false;
    } else {
      isPilotMode = false;
      isPilotOnboarding = false;
    }
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? const <String, dynamic>{};
    final role = meta['role'] == 'operator' ? '운용자' : '이용자';
    updateAuth(role: role, email: email, password: password);
    submitAuth();
    unawaited(_saveFcmToken());
  }

  Future<void> deleteAccount() async {
    await _api.deleteMyAccount();
    isLoggedIn = false;
    isPilotMode = false;
    isPilotOnboarding = false;
    accountEmail = '';
    accountPassword = '';
    accountName = '';
    accountNickname = '';
    myQuotes = <UserQuoteSummary>[];
    allPilots = <DronePilot>[];
    notifyListeners();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    isLoggedIn = false;
    isPilotMode = false;
    isPilotOnboarding = false;
    accountEmail = '';
    accountPassword = '';
    accountName = '';
    accountNickname = '';
    myQuotes = <UserQuoteSummary>[];
    allPilots = <DronePilot>[];
    operatorRegistrationCompleted = false;
    operatorReviewStatus = 'none';
    notifyListeners();
  }

  Future<void> _saveFcmToken() async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _api.saveFcmToken(token);
        FirebaseMessaging.instance.onTokenRefresh.listen(_api.saveFcmToken);
      }
    } catch (_) {}
  }

  Future<void> signUp({
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
          'role': 'client',
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
      role: '이용자',
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
    if (user == null) {
      isSessionRestoring = false;
      notifyListeners();
      return;
    }
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final role = metadata['role'] == 'operator' ? '운용자' : '이용자';
    final myOperator = await _api.fetchMyOperatorProfile();
    updateAuth(
      role: myOperator == null ? role : '운용자',
      email: user.email ?? '',
      name: (metadata['name'] ?? '').toString(),
      nickname: (metadata['nickname'] ?? '').toString(),
    );
    if (myOperator != null) {
      operatorRegistrationCompleted = true;
      operatorReviewStatus = myOperator.operatorStatus;
    } else {
      operatorRegistrationCompleted = false;
      operatorReviewStatus = 'none';
    }
    submitAuth();
    isSessionRestoring = false;
    notifyListeners();
  }

  void goToPilotOnboardingStep(int step) {
    // 이미 완료한 단계(현재 단계 이하)로만 이동 가능
    if (step > pilotOnboardingStep) return;
    pilotOnboardingStep = step.clamp(0, 4);
    notifyListeners();
  }

  void previousPilotOnboardingStep() {
    if (pilotOnboardingStep == 0) return;
    pilotOnboardingStep -= 1;
    notifyListeners();
  }

  Future<void> nextPilotOnboardingStep() async {
    _validatePilotOnboardingStep(pilotOnboardingStep);
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
        } catch (error) {
          throw Exception('운용자 등록 중 오류가 발생했습니다. 잠시 뒤 다시 시도해 주세요.');
        }
      }
      pilotOnboarding.submitted = true;
      accountRole = '운용자';
      operatorRegistrationCompleted = true;
      operatorReviewStatus = 'pending_review';
      registrationJustCompleted = true;
      isPilotOnboarding = false;
      notifyListeners();
      return;
    }
    pilotOnboardingStep += 1;
    notifyListeners();
  }

  void _validatePilotOnboardingStep(int step) {
    final data = pilotOnboarding;
    String? message;
    if (step == 0) {
      if (data.licenseNumber.trim().isEmpty) {
        message = '자격증 번호를 입력해 주세요.';
      } else if (!RegExp(r'^\d{2}-\d{6}$').hasMatch(data.licenseNumber.trim())) {
        message = '자격증 번호를 00-000000 형식으로 입력해 주세요.';
      }
    } else if (step == 1) {
      if (data.businessName.trim().isEmpty) {
        message = '상호명을 입력해 주세요.';
      } else if (!RegExp(
        r'^\d{3}-\d{2}-\d{5}$',
      ).hasMatch(data.businessNumber.trim())) {
        message = '사업자등록번호는 000-00-00000 형식으로 입력해 주세요.';
      } else if (data.representativeName.trim().isEmpty) {
        message = '대표자명을 입력해 주세요.';
      }
    } else if (step == 2) {
      if (data.insuranceNumber.trim().isEmpty) {
        message = '보험 증권번호를 입력해 주세요.';
      }
    } else if (step == 3) {
      final hasDrone = data.drones.any(
        (drone) => drone.model.trim().isNotEmpty,
      );
      final hasCategory = data.drones.any(
        (drone) => drone.categories.isNotEmpty,
      );
      if (!hasDrone) {
        message = '보유 기체의 모델명을 하나 이상 입력해 주세요.';
      } else if (!hasCategory) {
        message = '기체 작업 분야를 하나 이상 선택해 주세요.';
      }
    } else if (step == 4 && data.areas.isEmpty) {
      message = '주요 활동 지역을 하나 이상 선택해 주세요.';
    }
    if (message != null) {
      throw Exception(message);
    }
  }

  void acknowledgeRegistrationDone() {
    registrationJustCompleted = false;
    notifyListeners();
  }

  bool get operatorVerified => operatorReviewStatus == 'approved';
  bool get operatorReviewPending => operatorReviewStatus == 'pending_review';
  String get operatorReviewLabel {
    return switch (operatorReviewStatus) {
      'approved' => '검증 완료',
      'pending_review' => '확인중',
      'rejected' => '반려됨',
      'suspended' => '중지됨',
      _ => operatorRegistrationCompleted ? '확인중' : '미등록',
    };
  }

  int get notificationCount => notifications.length;

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

  void updatePilotInsurance({
    String? company,
    String? number,
    String? droneNumber,
    bool? uploaded,
  }) {
    pilotOnboarding.insuranceCompany =
        company ?? pilotOnboarding.insuranceCompany;
    pilotOnboarding.insuranceNumber = number ?? pilotOnboarding.insuranceNumber;
    pilotOnboarding.insuranceDroneNumber =
        droneNumber ?? pilotOnboarding.insuranceDroneNumber;
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

  void togglePilotRegion(String region) {
    final areas = pilotOnboarding.areas;
    final active =
        areas.contains(region) || areas.any((a) => a.startsWith('$region '));
    if (active) {
      areas.remove(region);
      areas.removeWhere((a) => a.startsWith('$region '));
    } else {
      areas.add(region);
    }
    notifyListeners();
  }

  void togglePilotDistrict(String region, String district) {
    final areas = pilotOnboarding.areas;
    if (district == '전체') {
      areas.removeWhere((a) => a.startsWith('$region '));
      areas.add(region);
    } else {
      final key = '$region $district';
      areas.remove(region);
      if (areas.contains(key)) {
        areas.remove(key);
        if (!areas.any((a) => a.startsWith('$region '))) {
          areas.add(region);
        }
      } else {
        areas.add(key);
      }
    }
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
    try {
      quoteRequest = request;
      estimate = await _quoteApi.createEstimate(request);
      myQuotes = await _api.fetchMyQuotes();
      paymentInstruction = null;
      contactAccess = null;
      paymentConfirmed = false;
      notifyListeners();
      return estimate!;
    } on PostgrestException catch (error) {
      throw Exception('견적 요청 저장에 실패했습니다. (${error.message})');
    }
  }

  Future<void> submitOperatorQuote(
    PilotWorkRequest request,
    String message, {
    int? proposedPrice,
  }) async {
    await _api.submitQuoteForRequest(
      request,
      message,
      proposedPrice: proposedPrice,
    );
    await load();
  }

  Future<void> markOperatorRequestSeen(PilotWorkRequest request) async {
    if (request.status != '신규') return;
    await _api.markOperatorRequestSeen(request.id);
    pilotWorkRequests =
        pilotWorkRequests
            .map(
              (item) =>
                  item.id == request.id
                      ? PilotWorkRequest(
                        id: item.id,
                        category: item.category,
                        status: '확인 중',
                        location: item.location,
                        distance: item.distance,
                        dateRange: item.dateRange,
                        budget: item.budget,
                        client: item.client,
                        summary: item.summary,
                        progress: item.progress,
                        remaining: item.remaining,
                        mapLabel: item.mapLabel,
                      )
                      : item,
            )
            .toList();
    notifyListeners();
  }

  Future<void> updateMyQuoteRequest({
    required String requestId,
    required String category,
    required String area,
    required String preferredDate,
    required String detail,
    required String budgetRange,
    required String contactWindow,
    int? proposedAmount,
  }) async {
    await _api.updateMyQuoteRequest(
      requestId: requestId,
      category: category,
      area: area,
      preferredDate: preferredDate,
      detail: detail,
      budgetRange: budgetRange,
      contactWindow: contactWindow,
      proposedAmount: proposedAmount,
    );
    myQuotes = await _api.fetchMyQuotes();
    notifyListeners();
  }

  Future<void> confirmPayment() async {
    if (estimate == null) return;
    paymentConfirmed = true;
    contactAccess = await _quoteApi.createContactAccess(estimate!);
    notifyListeners();
  }

  List<OperatorFeedPost> myFeedPosts = <OperatorFeedPost>[];

  Future<void> uploadLicensePdf(List<int> bytes, String fileName) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');
    final url = await _api.uploadLicensePdf(userId, bytes);
    pilotOnboarding.licenseFileUrl = url;
    pilotOnboarding.licenseFileName = fileName;
    notifyListeners();
  }

  Future<void> uploadBusinessPdf(List<int> bytes, String fileName) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');
    final url = await _api.uploadBusinessPdf(userId, bytes);
    pilotOnboarding.businessFileUrl = url;
    pilotOnboarding.businessFileName = fileName;
    notifyListeners();
  }

  Future<void> uploadInsurancePdf(List<int> bytes, String fileName) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');
    final url = await _api.uploadInsurancePdf(userId, bytes);
    pilotOnboarding.insuranceFileUrl = url;
    pilotOnboarding.insuranceFileName = fileName;
    notifyListeners();
  }

  Future<String> uploadProfilePhoto(List<int> bytes, String ext) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');
    final url = await _api.uploadProfilePhoto(userId, bytes, ext);
    if (selectedPilot != null) {
      selectedPilot = DronePilot(
        id: selectedPilot!.id,
        name: selectedPilot!.name,
        location: selectedPilot!.location,
        categories: selectedPilot!.categories,
        availableAreas: selectedPilot!.availableAreas,
        permittedAreas: selectedPilot!.permittedAreas,
        basePrice: selectedPilot!.basePrice,
        contact: selectedPilot!.contact,
        mapX: selectedPilot!.mapX,
        mapY: selectedPilot!.mapY,
        portfolioImages: selectedPilot!.portfolioImages,
        specialty: selectedPilot!.specialty,
        intro: selectedPilot!.intro,
        description: selectedPilot!.description,
        quoteOptions: selectedPilot!.quoteOptions,
        operatorStatus: selectedPilot!.operatorStatus,
        avatarUrl: url,
      );
      notifyListeners();
    }
    return url;
  }

  Future<void> addFeedPost({
    required String caption,
    List<int>? imageBytes,
  }) async {
    try {
      final post = await _feedApi.createPost(
        caption: caption,
        imageBytes: imageBytes,
      );
      myFeedPosts = <OperatorFeedPost>[
        _operatorPostFromFeed(post),
        ...myFeedPosts,
      ];
      notifyListeners();
    } on StateError {
      rethrow;
    } on PostgrestException catch (error) {
      throw Exception('피드 등록에 실패했습니다. (${error.message})');
    } catch (_) {
      throw Exception('피드 등록 중 오류가 발생했습니다. 잠시 뒤 다시 시도해 주세요.');
    }
  }

  Future<void> updateOperatorProfile({
    required String intro,
    required String description,
    required List<String> categoryLabels,
    required List<String> areaNames,
    required List<String> portfolioImageUrls,
  }) async {
    await _api.updateOperatorProfile(
      intro: intro,
      description: description,
      categoryLabels: categoryLabels,
      areaNames: areaNames,
      portfolioImageUrls: portfolioImageUrls,
    );
    await load();
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
      myQuoteId: data.myQuoteId,
      myQuoteMessage: data.myQuoteMessage,
      myQuotePrice: data.myQuotePrice,
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

  List<AppNotification> _mergeNotifications(
    List<AppNotification> remote, {
    required List<PilotWorkRequest> pilotWorkRequests,
    required List<UserQuoteSummary> quotes,
  }) {
    final derived = <AppNotification>[
      if (accountRole == '운용자' || isPilotMode)
        ...pilotWorkRequests
            .where((request) => request.status == '신규')
            .map(
              (request) => AppNotification(
                id: 'request-${request.id}',
                title: '새 견적 요청',
                body: '${request.location} ${request.category} 요청이 도착했습니다.',
                createdAt: DateTime.now(),
                kind: 'quote_request',
              ),
            ),
      if (accountRole != '운용자' || !isPilotMode)
        ...quotes
            .where((quote) => quote.isQuoteReceived || quote.isInProgress)
            .map(
              (quote) => AppNotification(
                id: 'quote-${quote.id}-${quote.status}',
                title: quote.isQuoteReceived ? '견적을 받았습니다' : '작업이 진행중입니다',
                body: '${quote.pilotName} · ${quote.category} · ${quote.area}',
                createdAt: DateTime.now(),
                kind:
                    quote.isQuoteReceived
                        ? 'quote_received'
                        : 'quote_confirmed',
              ),
            ),
    ];
    final seen = <String>{};
    return <AppNotification>[
      ...remote,
      ...derived,
    ].where((item) => seen.add(item.id)).toList();
  }
}
