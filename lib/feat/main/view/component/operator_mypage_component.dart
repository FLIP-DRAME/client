part of '../pages/main_page.dart';

void _showOperatorAccountDeletionDialog(
  BuildContext context,
  DrameStore store,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _AccountDeletionDialog(store: store),
  );
}

Future<void> _uploadMyPageFile({
  required BuildContext context,
  required Future<void> Function() upload,
  required String successMessage,
}) async {
  try {
    await upload();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    }
  }
}

class _OperatorProfileManagementPage extends StatelessWidget {
  const _OperatorProfileManagementPage({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DC.canvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            DrameTopNavigation(
              isLoggedIn: store.isLoggedIn,
              isOperator: store.isPilotMode && store.isLoggedIn,
              nickname:
                  store.accountNickname.isNotEmpty
                      ? store.accountNickname
                      : store.accountName,
              onLoginTap: () => context.go('/login'),
              onRegisterPilotTap: () => context.push('/pilot/register'),
              onLogoTap: () => context.go('/operator'),
              onFindPilotTap: () => context.go('/home'),
              onRequestsTap:
                  () => _openPilotRequestReviewPage(
                    context,
                    initialRequest: store.firstPilotWorkRequest,
                  ),
              onMyPageTap: () {},
              onChatTap: () => context.push('/chats'),
              onLogoutTap: () async {
                await store.signOut();
                if (context.mounted) context.go('/login');
              },
              onSwitchToUser: () {
                store.setPilotMode(false);
                context.go('/home');
              },
              onSwitchToOperator: () {
                store.setPilotMode(true);
                context.go('/operator');
              },
              notificationCount: store.notificationCount,
              onNotificationTap: () => _showNotifications(context, store),
              operatorActiveTab: 'profile',
              onOperatorTabTap: (id) {
                if (id == 'dashboard') {
                  context.go('/operator');
                } else if (id == 'feed') {
                  context.go('/operator/feed');
                } else if (id == 'portfolio') {
                  context.go('/operator/portfolio');
                } else if (id == 'requests') {
                  context.go('/operator/requests');
                } else if (id == 'profile') {
                  context.go('/operator/mypage');
                }
              },
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _OperatorMyPageBody(store: store)),
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorMyPageBody extends StatelessWidget {
  const _OperatorMyPageBody({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 980;
    final name = store.accountName.isEmpty ? '운용자' : store.accountName;
    final nickname =
        store.accountNickname.isEmpty ? name : store.accountNickname;

    return ColoredBox(
      color: Colors.white,
      child: _PageShell(
        top: 44,
        bottom: 86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            compact
                ? Column(
                  children: <Widget>[
                    _OperatorMyPageProfile(
                      name: name,
                      nickname: nickname,
                      store: store,
                    ),
                    const SizedBox(height: 18),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: _OperatorMyPageProfile(
                        name: name,
                        nickname: nickname,
                        store: store,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
            const SizedBox(height: 48),
            const Text('내 등록 정보', style: AppText.cardTitle),
            const SizedBox(height: 8),
            const Text(
              '운용자 등록 때 입력한 정보를 바로 수정할 수 있습니다.',
              style: AppText.cardSubtitle,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 980;
                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: <Widget>[
                    SizedBox(
                      width:
                          twoColumns
                              ? (constraints.maxWidth - 18) / 2
                              : constraints.maxWidth,
                      child: _OperatorInfoCard(
                        title: '기본 정보',
                        children: <Widget>[
                          _InlineEditableText(
                            label: '이름',
                            value: store.accountName,
                            hint: '운용자',
                            onChanged: (value) => store.updateAuth(name: value),
                          ),
                          _InlineEditableText(
                            label: '닉네임',
                            value: store.accountNickname,
                            hint: '드라메 파일럿',
                            onChanged:
                                (value) => store.updateAuth(nickname: value),
                          ),
                          const SizedBox(height: 8),
                          const Text('활동 지역', style: AppText.smallStrong),
                          const SizedBox(height: 10),
                          _PilotChipGroup(
                            values: const <String>[
                              '서울',
                              '경기',
                              '인천',
                              '강원',
                              '충청',
                              '전라',
                              '경상',
                              '제주',
                            ],
                            selected: store.pilotOnboarding.areas,
                            onTap: store.togglePilotArea,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width:
                          twoColumns
                              ? (constraints.maxWidth - 18) / 2
                              : constraints.maxWidth,
                      child: _OperatorInfoCard(
                        title: '자격 및 사업자',
                        children: <Widget>[
                          _InlineEditableSelect(
                            label: '자격증 종류',
                            value: store.pilotOnboarding.licenseType,
                            values: const <String>[
                              '초경량비행장치 조종자',
                              '무인멀티콥터 지도조종자',
                              '무인헬리콥터 조종자',
                            ],
                            onChanged:
                                (value) =>
                                    store.updatePilotLicense(type: value),
                          ),
                          _InlineEditableText(
                            label: '자격증 번호',
                            value: store.pilotOnboarding.licenseNumber,
                            hint: 'UAV-2026-0001',
                            onChanged:
                                (value) =>
                                    store.updatePilotLicense(number: value),
                          ),
                          _InlineEditableText(
                            label: '상호명',
                            value: store.pilotOnboarding.businessName,
                            hint: '드라메 항공촬영',
                            onChanged:
                                (value) =>
                                    store.updatePilotBusiness(name: value),
                          ),
                          _InlineEditableText(
                            label: '사업자등록번호',
                            value: store.pilotOnboarding.businessNumber,
                            hint: '000-00-00000',
                            keyboardType: TextInputType.number,
                            inputFormatters: const <TextInputFormatter>[
                              BusinessNumberInputFormatter(),
                            ],
                            onChanged:
                                (value) =>
                                    store.updatePilotBusiness(number: value),
                          ),
                          _InlineEditableText(
                            label: '대표자명',
                            value: store.pilotOnboarding.representativeName,
                            hint: '홍길동',
                            onChanged:
                                (value) => store.updatePilotBusiness(
                                  representative: value,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _PdfUploadField(
                            label: '자격증 파일 (PDF) *',
                            fileName: store.pilotOnboarding.licenseFileName,
                            onPick:
                                (bytes, name) =>
                                    _uploadMyPageFile(
                                      context: context,
                                      upload: () => store.uploadLicensePdf(
                                        bytes,
                                        name,
                                      ),
                                      successMessage: '자격증 파일이 업로드되었습니다.',
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _PdfUploadField(
                            label: '사업자등록증 파일 (PDF) *',
                            fileName: store.pilotOnboarding.businessFileName,
                            onPick:
                                (bytes, name) =>
                                    _uploadMyPageFile(
                                      context: context,
                                      upload: () => store.uploadBusinessPdf(
                                        bytes,
                                        name,
                                      ),
                                      successMessage: '사업자등록증 파일이 업로드되었습니다.',
                                    ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width:
                          twoColumns
                              ? (constraints.maxWidth - 18) / 2
                              : constraints.maxWidth,
                      child: _OperatorDroneListCard(store: store),
                    ),
                    SizedBox(
                      width:
                          twoColumns
                              ? (constraints.maxWidth - 18) / 2
                              : constraints.maxWidth,
                      child: _OperatorInfoCard(
                        title: '보험 정보',
                        children: <Widget>[
                          _InlineEditableSelect(
                            label: '보험사',
                            value: store.pilotOnboarding.insuranceCompany,
                            values: const <String>[
                              'DB손해보험',
                              '삼성화재',
                              '현대해상',
                              'KB손해보험',
                              '한화손해보험',
                              '메리츠화재',
                              '롯데손해보험',
                              'MG손해보험',
                              '흥국화재',
                              'NH농협손해보험',
                              '기타',
                            ],
                            onChanged:
                                (value) =>
                                    store.updatePilotInsurance(company: value),
                          ),
                          const SizedBox(height: 8),
                          _PdfUploadField(
                            label: '보험 증권 파일 (PDF) *',
                            fileName: store.pilotOnboarding.insuranceFileName,
                            onPick:
                                (bytes, name) =>
                                    _uploadMyPageFile(
                                      context: context,
                                      upload: () => store.uploadInsurancePdf(
                                        bytes,
                                        name,
                                      ),
                                      successMessage: '보험 증권 파일이 업로드되었습니다.',
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    await store.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    textStyle: AppText.button,
                  ),
                  child: const Text('로그아웃'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.push('/blocked-users'),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    textStyle: AppText.button,
                  ),
                  child: const Text('차단 관리'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      () => _showOperatorAccountDeletionDialog(context, store),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    textStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: const Text('계정 삭제'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ModeButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    store.validateOperatorOnboardingDetails();
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          e
                              .toString()
                              .replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                    return;
                  }
                  try {
                    // 자격증/사업자/보험/기체 정보를 먼저 저장한다: 이 저장이
                    // 실패하면(예: 아직 운용자 등록 전) 아래 saveMyProfile/
                    // updateOperatorProfile이 트리거하는 load()로 인해 화면에
                    // 입력해 둔 값이 리로드되어 사라지는 것을 방지한다.
                    await store.saveOperatorOnboardingDetails();
                    await store.saveMyProfile(
                      name: store.accountName,
                      nickname: store.accountNickname,
                    );
                    await store.updateOperatorProfile(
                      intro:
                          store.selectedPilot?.intro ??
                          '${store.accountNickname.isNotEmpty ? store.accountNickname : store.accountName} 운용자입니다.',
                      description:
                          store.selectedPilot?.description ??
                          store.pilotOnboarding.portfolioUrl,
                      categoryLabels:
                          store.selectedPilot?.categories ?? const <String>[],
                      areaNames: store.pilotOnboarding.areas.toList(),
                      portfolioImageUrls:
                          store.selectedPilot?.portfolioImages ??
                          const <String>[],
                    );
                  } catch (e) {
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e
                                .toString()
                                .replaceFirst('Exception: ', ''),
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (context.mounted) context.go('/operator');
                },
                variant: ModeButtonVariant.primary,
                label: '저장하고 운용자 페이지로',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorMyPageProfile extends StatefulWidget {
  const _OperatorMyPageProfile({
    required this.name,
    required this.nickname,
    required this.store,
  });

  final String name;
  final String nickname;
  final DrameStore store;

  @override
  State<_OperatorMyPageProfile> createState() => _OperatorMyPageProfileState();
}

class _OperatorMyPageProfileState extends State<_OperatorMyPageProfile> {
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final nickname = widget.nickname;
    final avatarUrl = store.selectedPilot?.avatarUrl;
    final serviceText =
        store.selectedPilot?.categories.isNotEmpty == true
            ? store.selectedPilot!.categories.join(' · ')
            : '운용자 등록을 완료하면 제공 서비스가 표시됩니다.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            ModeAvatar(imageUrl: avatarUrl, radius: 44, fallbackText: nickname),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(nickname, style: AppText.cardTitle),
                  const SizedBox(height: 8),
                  ModeMediumText(
                    serviceText,
                    size: 18,
                    color: _ink,
                    height: 1.3,
                    letterSpacing: -0.25,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      _OperatorReviewBadge(store: store),
                      Text(
                        '요청수 ${store.pilotWorkRequests.length}',
                        style: AppText.cardSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!store.operatorRegistrationCompleted) ...<Widget>[
          const SizedBox(height: 26),
          Row(
            children: <Widget>[
              Expanded(
                child: ModeButton(
                  onPressed: () => context.push('/pilot/register'),
                  variant: ModeButtonVariant.primary,
                  fullWidth: true,
                  label: '운용자 등록',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ignore: unused_element
class _OperatorMyPageSideCard extends StatelessWidget {
  const _OperatorMyPageSideCard();

  @override
  Widget build(BuildContext context) {
    return ModeCard(
      variant: ModeCardVariant.flatBordered,
      radius: 12,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: _muted),
          ),
          const SizedBox(height: 20),
          const Text('아직 리뷰가 하나도 없다면?', style: AppText.portfolioTitle),
          const SizedBox(height: 10),
          const Text(
            '서비스를 제공 받은 고객에게 간편하게 리뷰를 요청해 보세요.',
            style: AppText.cardSubtitle,
          ),
        ],
      ),
    );
  }
}

class _OperatorInfoCard extends StatelessWidget {
  const _OperatorInfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ModeCard(
      variant: ModeCardVariant.flatBordered,
      radius: 12,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppText.portfolioTitle),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _OperatorDroneListCard extends StatelessWidget {
  const _OperatorDroneListCard({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return _OperatorInfoCard(
      title: '보유 기체',
      children: <Widget>[
        ...store.pilotOnboarding.drones.asMap().entries.map((entry) {
          final index = entry.key;
          final drone = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: ModeCard(
              variant: ModeCardVariant.softFilled,
              radius: 10,
              padding: const EdgeInsets.all(16),
              child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('기체 ${index + 1}', style: AppText.smallStrong),
                    const Spacer(),
                    if (store.pilotOnboarding.drones.length > 1)
                      IconButton(
                        onPressed: () => store.removePilotDrone(index),
                        icon: const Icon(Icons.close_rounded),
                        color: _muted,
                        tooltip: '기체 삭제',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _InlineEditableSelect(
                  label: '제조사 (선택)',
                  value: drone.maker,
                  values: const <String>[
                    'DJI',
                    'Autel',
                    'Parrot',
                    '유콘시스템',
                    '니어스랩',
                    'XAG',
                    '기타',
                  ],
                  onChanged:
                      (value) => store.updatePilotDrone(index, maker: value),
                ),
                _InlineEditableText(
                  label: '모델명 *',
                  value: drone.model,
                  hint: 'Mavic 3 Pro',
                  onChanged:
                      (value) => store.updatePilotDrone(index, model: value),
                ),
                _InlineEditableText(
                  label: '신고번호 *',
                  value: drone.registrationNumber,
                  hint: 'S1234567',
                  onChanged:
                      (value) => store.updatePilotDrone(
                        index,
                        registrationNumber: value,
                      ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('기체 카테고리 *', style: AppText.metricLabel),
                ),
                const SizedBox(height: 8),
                _PilotChipGroup(
                  values: const <String>['촬영용', '방제용', '측량용', '점검용', '다목적'],
                  selected: drone.categories,
                  onTap:
                      (value) => store.togglePilotDroneCategory(index, value),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('탑재 센서 (선택)', style: AppText.metricLabel),
                ),
                const SizedBox(height: 8),
                _PilotChipGroup(
                  values: const <String>[
                    '4K 카메라',
                    '열화상',
                    '다중분광',
                    'RTK GPS',
                    '약제 탱크',
                  ],
                  selected: drone.sensors,
                  onTap: (value) => store.togglePilotDroneSensor(index, value),
                ),
              ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: store.addPilotDrone,
          icon: const Icon(Icons.add_rounded),
          label: const Text('기체 추가'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            textStyle: AppText.button,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineEditableText extends StatelessWidget {
  const _InlineEditableText({
    required this.label,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Text('$label:', style: AppText.cardSubtitle),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey<String>('mypage-$label'),
              initialValue: value,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              style: AppText.smallStrong.copyWith(color: _ink),
              decoration: _inlineInputDecoration(hint),
              cursorColor: _navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineEditableSelect extends StatelessWidget {
  const _InlineEditableSelect({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Text('$label:', style: AppText.cardSubtitle),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: values.contains(value) ? value : values.first,
              items:
                  values
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              onChanged: (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
              style: AppText.smallStrong.copyWith(color: _ink),
              decoration: _inlineInputDecoration('선택'),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inlineInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8FAFD),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _focus, width: 1.2),
    ),
  );
}

class _OperatorFeedSection extends StatefulWidget {
  const _OperatorFeedSection({required this.store});

  final DrameStore store;

  @override
  State<_OperatorFeedSection> createState() => _OperatorFeedSectionState();
}

class _OperatorFeedSectionState extends State<_OperatorFeedSection> {
  static const int _maxImageCount = 10;
  static const List<String> _categoryOptions = <String>[
    '항공촬영',
    '농약방제',
    '부동산',
    '측량·매핑',
    '시설점검',
    '행사촬영',
  ];

  final TextEditingController _titleController = TextEditingController();
  bool _isExpanded = false;
  bool _isSubmitting = false;
  LatLng? _pickedLocation;
  String? _pickedLocationLabel;
  String _selectedCategory = '항공촬영';

  // Flutter Quill 리치 텍스트 에디터 컨트롤러
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await showFeedLocationPicker(
      context,
      initial: _pickedLocation,
    );
    if (result == null || !mounted) return;
    setState(() {
      _pickedLocation = result.position;
      _pickedLocationLabel = result.label;
    });
  }

  // 현재 삽입된 이미지들을 추적
  final List<PickedFile> _embeddedImages = <PickedFile>[];

  Future<void> _pickImages() async {
    if (_isSubmitting) return;
    final files = await pickPlatformFiles(
      accept: 'image/*',
      allowMultiple: true,
    );
    if (files.isEmpty) return;
    if (!mounted) return;

    final remaining = _maxImageCount - _embeddedImages.length;
    if (files.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사진은 한 게시물에 최대 10장까지 올릴 수 있습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 현재 커서 위치에 이미지 삽입
    for (final file in files.take(remaining)) {
      _embeddedImages.add(file);
      // 이미지를 base64로 변환하여 Quill 에디터에 삽입
      final base64Image = 'data:image/${file.name.split('.').last};base64,${base64Encode(file.bytes)}';
      final index = _quillController.selection.baseOffset;
      _quillController.document.insert(index, quill.BlockEmbed.image(base64Image));
      _quillController.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        quill.ChangeSource.local,
      );
      // 이미지 뒤에 새 줄 추가
      _quillController.document.insert(index + 1, '\n');
      _quillController.updateSelection(
        TextSelection.collapsed(offset: index + 2),
        quill.ChangeSource.local,
      );
    }
    setState(() {});
  }

  /// 커스텀 색상 선택기 표시
  void _showColorPicker({required bool isBackground}) {
    Color currentColor = Colors.black;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isBackground ? '배경색 선택' : '텍스트 색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                currentColor = color;
              },
              enableAlpha: false,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 선택한 색상을 Quill 에디터에 적용
                final r = currentColor.r.toInt();
                final g = currentColor.g.toInt();
                final b = currentColor.b.toInt();
                final hexColor = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
                if (isBackground) {
                  _quillController.formatSelection(quill.BackgroundAttribute(hexColor));
                } else {
                  _quillController.formatSelection(quill.ColorAttribute(hexColor));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
              ),
              child: const Text('적용', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// 텍스트 색상 적용
  void _applyTextColor(Color color) {
    final r = color.r.toInt();
    final g = color.g.toInt();
    final b = color.b.toInt();
    final hexColor = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    _quillController.formatSelection(quill.ColorAttribute(hexColor));
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    // Quill 에디터에서 플레인 텍스트 추출
    final caption = _quillController.document.toPlainText().trim();

    final messenger = ScaffoldMessenger.of(context);
    if (_embeddedImages.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('사진을 최소 1장 이상 올려주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    if (_pickedLocation == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('지도에서 촬영 위치를 선택해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _isSubmitting = true);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('피드 등록 대기중입니다. 잠시만 기다려 주세요.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 30),
        ),
      );

    try {
      await widget.store.addFeedPost(
        caption: caption,
        images:
            _embeddedImages
                .map(
                  (image) => FeedImageUpload(
                    bytes: image.bytes,
                    fileName: image.name,
                  ),
                )
                .toList(),
        categoryLabel: _selectedCategory,
        locationLabel: _pickedLocationLabel ?? '',
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error
                  .toString()
                  .replaceFirst('Bad state: ', '')
                  .replaceFirst('Exception: ', ''),
            ),
            backgroundColor: _ink,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    if (!mounted) return;
    _titleController.clear();
    // Quill 에디터 초기화
    _quillController = quill.QuillController.basic();
    setState(() {
      _isSubmitting = false;
      _isExpanded = false;
      _embeddedImages.clear();
      _pickedLocation = null;
      _pickedLocationLabel = null;
      _selectedCategory = '항공촬영';
    });
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('피드 등록이 완료되었습니다.'),
          backgroundColor: Color(0xFF0A7F5A),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DC.canvas,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('내 피드', style: AppText.cardTitle),
                    SizedBox(height: 6),
                    Text(
                      '작업 사진과 소개글을 피드에 올려 고객에게 보여주세요.',
                      style: AppText.cardSubtitle,
                    ),
                  ],
                ),
              ),
              _isExpanded
                  ? OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() => _isExpanded = false),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('닫기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF222222),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF222222)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => setState(() => _isExpanded = true),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('새 게시물'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF222222),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isExpanded) ...<Widget>[
            // ═══════════════════════════════════════════════════════════════
            // SmartEditor 스타일 피드 작성 폼
            // ═══════════════════════════════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ─────────────────────────────────────────────────────────
                  // 카테고리 행
                  // ─────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          '카테고리',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFDDDDDD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                isDense: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Color(0xFF666666),
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF333333),
                                ),
                                items:
                                    _categoryOptions.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                onChanged:
                                    _isSubmitting
                                        ? null
                                        : (value) {
                                          if (value != null) {
                                            setState(
                                              () => _selectedCategory = value,
                                            );
                                          }
                                        },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─────────────────────────────────────────────────────────
                  // 제목 행
                  // ─────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          '제목',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                            ),
                            decoration: const InputDecoration(
                              hintText: '제목을 입력하세요',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF999999),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─────────────────────────────────────────────────────────
                  // 파일첨부 툴바
                  // ─────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          '파일첨부',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SmartEditorToolButton(
                          icon: Icons.photo_camera_rounded,
                          label: '사진',
                          color: const Color(0xFFFF6B35),
                          onTap: _isSubmitting ? null : _pickImages,
                          badge:
                              _embeddedImages.isNotEmpty
                                  ? '${_embeddedImages.length}'
                                  : null,
                        ),
                        const SizedBox(width: 4),
                        _SmartEditorToolButton(
                          icon: Icons.map_rounded,
                          label: '지도',
                          color: const Color(0xFF4CAF50),
                          onTap: _isSubmitting ? null : _pickLocation,
                          badge: _pickedLocation != null ? '✓' : null,
                        ),
                      ],
                    ),
                  ),
                  // ─────────────────────────────────────────────────────────
                  // 텍스트 서식 툴바 (Custom Toolbar - Quill actions)
                  // ─────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          // 폰트 크기 드롭다운
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFDDDDDD)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: 14,
                                isDense: true,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                                items: const [
                                  DropdownMenuItem(value: 12, child: Text('12pt')),
                                  DropdownMenuItem(value: 14, child: Text('14pt')),
                                  DropdownMenuItem(value: 16, child: Text('16pt')),
                                  DropdownMenuItem(value: 18, child: Text('18pt')),
                                  DropdownMenuItem(value: 20, child: Text('20pt')),
                                  DropdownMenuItem(value: 24, child: Text('24pt')),
                                ],
                                onChanged: _isSubmitting ? null : (size) {
                                  if (size != null) {
                                    _quillController.formatSelection(quill.Attribute.fromKeyValue('size', '${size}px'));
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // B (Bold) 버튼
                          _FormatButton(
                            label: 'B',
                            fontWeight: FontWeight.bold,
                            onTap: _isSubmitting ? null : () {
                              _quillController.formatSelection(quill.Attribute.bold);
                            },
                          ),
                          const SizedBox(width: 4),
                          // I (Italic) 버튼
                          _FormatButton(
                            label: 'I',
                            fontStyle: FontStyle.italic,
                            onTap: _isSubmitting ? null : () {
                              _quillController.formatSelection(quill.Attribute.italic);
                            },
                          ),
                          const SizedBox(width: 4),
                          // U (Underline) 버튼
                          _FormatButton(
                            label: 'U',
                            textDecoration: TextDecoration.underline,
                            onTap: _isSubmitting ? null : () {
                              _quillController.formatSelection(quill.Attribute.underline);
                            },
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: const Color(0xFFDDDDDD),
                          ),
                          const SizedBox(width: 8),
                          // 텍스트 색상 버튼 - 프리셋 색상
                          _TextColorButton(
                            color: const Color(0xFF333333),
                            onTap: _isSubmitting ? null : () => _applyTextColor(const Color(0xFF333333)),
                          ),
                          const SizedBox(width: 4),
                          _TextColorButton(
                            color: const Color(0xFFE53935),
                            onTap: _isSubmitting ? null : () => _applyTextColor(const Color(0xFFE53935)),
                          ),
                          const SizedBox(width: 4),
                          _TextColorButton(
                            color: const Color(0xFF1E88E5),
                            onTap: _isSubmitting ? null : () => _applyTextColor(const Color(0xFF1E88E5)),
                          ),
                          const SizedBox(width: 4),
                          _TextColorButton(
                            color: const Color(0xFF43A047),
                            onTap: _isSubmitting ? null : () => _applyTextColor(const Color(0xFF43A047)),
                          ),
                          const SizedBox(width: 4),
                          // 커스텀 색상 버튼
                          GestureDetector(
                            onTap: _isSubmitting ? null : () => _showColorPicker(isBackground: false),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                                ),
                                border: Border.all(color: const Color(0xFFDDDDDD)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  '...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ─────────────────────────────────────────────────────────
                  // 첨부된 사진 미리보기 (이미지가 에디터에 삽입된 경우 표시)
                  // ─────────────────────────────────────────────────────────
                  if (_embeddedImages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _embeddedImages.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return _SmartEditorImagePreview(
                                  image: _embeddedImages[index],
                                  onRemove:
                                      _isSubmitting
                                          ? null
                                          : () => setState(
                                            () => _embeddedImages.removeAt(
                                              index,
                                            ),
                                          ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_embeddedImages.length}장 첨부됨 · 첫 번째 사진이 대표 이미지로 표시됩니다.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ─────────────────────────────────────────────────────────
                  // 선택된 위치 표시
                  // ─────────────────────────────────────────────────────────
                  if (_pickedLocation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _pickedLocationLabel ?? '위치 선택됨',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _pickedLocation = null;
                              _pickedLocationLabel = null;
                            }),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ─────────────────────────────────────────────────────────
                  // 본문 에디터 영역 (Quill Rich Text Editor)
                  // ─────────────────────────────────────────────────────────
                  Container(
                    constraints: const BoxConstraints(minHeight: 200),
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: quill.QuillEditor(
                      controller: _quillController,
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      config: quill.QuillEditorConfig(
                        placeholder: '내용을 입력하세요.\n\n촬영 장소, 작업 내용, 사용 장비 등을 자유롭게 작성해주세요.\n\n텍스트를 선택한 후 위 툴바에서 서식을 적용할 수 있습니다.',
                        padding: EdgeInsets.zero,
                        autoFocus: false,
                        expands: false,
                      ),
                    ),
                  ),
                  // ─────────────────────────────────────────────────────────
                  // 태그달기 행
                  // ─────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          '태그달기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFCCCCCC)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const TextField(
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF333333),
                              ),
                              decoration: InputDecoration(
                                hintText: '태그를 쉼표로 구분하여 입력하세요',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─────────────────────────────────────────────────────────────
            // 등록 버튼
            // ─────────────────────────────────────────────────────────────
            if (_isSubmitting)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCFE0FF)),
                ),
                child: const Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '피드 등록 대기중',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '등록',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (widget.store.myFeedPosts.isEmpty)
            SizedBox(
              width: double.infinity,
              child: ModeCard(
                variant: ModeCardVariant.softFilled,
                radius: 12,
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: const ModeEmptyState(
                  icon: Icons.photo_library_outlined,
                  title: '아직 올린 피드가 없어요',
                  subtitle: '작업 사진을 올려 고객에게 어필해보세요!',
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.store.myFeedPosts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final post = widget.store.myFeedPosts[index];
                    return _FeedPostCard(
                      post: post,
                      onDelete:
                          () async => widget.store.deleteFeedPost(post.id),
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

/// SmartEditor 스타일 툴 버튼
class _SmartEditorToolButton extends StatelessWidget {
  const _SmartEditorToolButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
              ),
            ),
            if (badge != null) ...<Widget>[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 서식 버튼 (B, I, U)
class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.label,
    this.fontWeight,
    this.fontStyle,
    this.textDecoration,
    this.onTap,
  });

  final String label;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextDecoration? textDecoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: fontWeight ?? FontWeight.normal,
              fontStyle: fontStyle ?? FontStyle.normal,
              decoration: textDecoration,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

/// 텍스트 색상 버튼
class _TextColorButton extends StatelessWidget {
  const _TextColorButton({
    required this.color,
    this.onTap,
  });

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

/// SmartEditor 스타일 이미지 프리뷰
class _SmartEditorImagePreview extends StatelessWidget {
  const _SmartEditorImagePreview({
    required this.image,
    this.onRemove,
  });

  final PickedFile image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.memory(
              Uint8List.fromList(image.bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({required this.post, required this.onDelete});

  final OperatorFeedPost post;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider =
        post.imageBytes != null
            ? MemoryImage(Uint8List.fromList(post.imageBytes!))
            : post.imageUrl != null
            ? NetworkImage(post.imageUrl!)
            : null;
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line),
            image:
                imageProvider == null
                    ? null
                    : DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child:
              imageProvider == null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        post.caption.isEmpty ? '이미지 없음' : post.caption,
                        style: AppText.cardSubtitle,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : post.caption.isNotEmpty
                  ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            Colors.black.withValues(alpha: 0.58),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        post.caption,
                        style: AppText.metricLabel.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  : null,
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
