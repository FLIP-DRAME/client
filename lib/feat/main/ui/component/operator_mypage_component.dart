part of '../pages/main_page.dart';

class _OperatorProfileManagementPage extends StatelessWidget {
  const _OperatorProfileManagementPage({required this.store});

  final DrameStore store;

  @override
  Widget build(BuildContext context) {
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
            isPilotMode: true,
            onFindPilotTap: () => context.go('/'),
            onPortfolioTap: () => context.go('/'),
            onRequestsTap:
                () => _openPilotRequestReviewPage(
                  context,
                  initialRequest: mockPilotWorkRequests.first,
                ),
            onMyPageTap: () {},
          ),
        ),
        SliverToBoxAdapter(child: _OperatorMyPageBody(store: store)),
        const SliverToBoxAdapter(child: _FooterSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
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
                    // const _OperatorMyPageSideCard(),
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
                    // const SizedBox(
                    //   width: 330,
                    //   child: _OperatorMyPageSideCard(),
                    // ),
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
                        ],
                      ),
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
                            ],
                            onChanged:
                                (value) =>
                                    store.updatePilotInsurance(company: value),
                          ),
                          _InlineEditableText(
                            label: '보험 증권번호',
                            value: store.pilotOnboarding.insuranceNumber,
                            hint: 'DB-DRONE-240001',
                            onChanged:
                                (value) =>
                                    store.updatePilotInsurance(number: value),
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
                  ],
                );
              },
            ),
            _OperatorFeedSection(store: store),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => context.go('/'),
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  textStyle: AppText.button,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('저장하고 운용자 페이지로'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorMyPageProfile extends StatelessWidget {
  const _OperatorMyPageProfile({
    required this.name,
    required this.nickname,
    required this.store,
  });

  final String name;
  final String nickname;
  final DrameStore store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFFEAF0F7),
                  child: Text(
                    nickname.characters.first,
                    style: AppText.cardTitle.copyWith(color: _navy),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: AppText.cardTitle),
                  const SizedBox(height: 8),
                  Text(
                    '$nickname 운용자의 항공촬영·방제 서비스',
                    style: AppText.portfolioTitle.copyWith(
                      fontWeight: DrameTextStyles.medium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      Text('리뷰 평점 0', style: AppText.cardSubtitle),
                      Text('리뷰수 0', style: AppText.cardSubtitle),
                      Text(
                        '요청수 ${mockPilotWorkRequests.length}',
                        style: AppText.cardSubtitle,
                      ),
                      Text(
                        '내 활동 분석 >',
                        style: AppText.cardSubtitle.copyWith(color: _navy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: _myPageOutlineButtonStyle(),
                child: const Text('내 소개 편집'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final pilot =
                      store.selectedPilot ??
                      (store.pilots.isNotEmpty
                          ? store.pilots.first
                          : mockPilots.first);
                  context.push('/portfolio/${pilot.id}', extra: pilot);
                },
                style: _myPageOutlineButtonStyle(),
                child: const Text('미리보기'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OperatorMyPageSideCard extends StatelessWidget {
  const _OperatorMyPageSideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
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
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: _navy,
              textStyle: AppText.button,
              padding: EdgeInsets.zero,
            ),
            label: const Text('자세히 보기'),
            icon: const Icon(Icons.chevron_right_rounded),
            iconAlignment: IconAlignment.end,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
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
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _line),
            ),
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
                  label: '제조사',
                  value: drone.maker,
                  values: const <String>['DJI', 'Autel', 'Parrot', '기타'],
                  onChanged:
                      (value) => store.updatePilotDrone(index, maker: value),
                ),
                _InlineEditableText(
                  label: '모델명',
                  value: drone.model,
                  hint: 'Mavic 3 Pro',
                  onChanged:
                      (value) => store.updatePilotDrone(index, model: value),
                ),
                _InlineEditableText(
                  label: '신고번호',
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
                  child: Text('기체 카테고리', style: AppText.metricLabel),
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
                  child: Text('탑재 센서', style: AppText.metricLabel),
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
  });

  final String label;
  final String value;
  final String hint;
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
            child: TextFormField(
              key: ValueKey<String>('mypage-$label-$value'),
              initialValue: value,
              onChanged: onChanged,
              style: AppText.smallStrong.copyWith(color: _ink),
              decoration: _inlineInputDecoration(hint),
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
      borderSide: const BorderSide(color: _navy, width: 1.2),
    ),
  );
}

ButtonStyle _myPageOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: _ink,
    textStyle: AppText.button,
    padding: const EdgeInsets.symmetric(vertical: 15),
    side: const BorderSide(color: _line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}


class _OperatorFeedSection extends StatefulWidget {
  const _OperatorFeedSection({required this.store});

  final DrameStore store;

  @override
  State<_OperatorFeedSection> createState() => _OperatorFeedSectionState();
}

class _OperatorFeedSectionState extends State<_OperatorFeedSection> {
  final TextEditingController _captionController = TextEditingController();
  List<int>? _pendingImageBytes;
  String? _pendingImageName;
  bool _isExpanded = false; // 업로드 폼 펼침 여부

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

Future<void> _pickImage() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*';
  input.click();

  await input.onChange.first;

  final files = input.files;
  if (files == null || files.length == 0) return;

  final file = files.item(0)!;
  final reader = web.FileReader();

  // Completer로 로드 완료를 기다림
  final completer = Completer<Uint8List>();

  reader.addEventListener('loadend', (web.Event _) {
    final result = reader.result;
    if (result == null) {
      completer.completeError('파일 읽기 실패');
      return;
    }
    final bytes = Uint8List.view((result as JSArrayBuffer).toDart);
    completer.complete(bytes);
  }.toJS);

  reader.readAsArrayBuffer(file);

  final bytes = await completer.future;

  setState(() {
    _pendingImageBytes = bytes;
    _pendingImageName = file.name;
  });
}

  void _submit() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _pendingImageBytes == null) return;

    widget.store.addFeedPost(
      caption: caption,
      imageBytes: _pendingImageBytes,
    );

    // 초기화
    _captionController.clear();
    setState(() {
      _pendingImageBytes = null;
      _pendingImageName = null;
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            FilledButton.icon(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(_isExpanded ? Icons.close_rounded : Icons.add_rounded),
              label: Text(_isExpanded ? '닫기' : '새 게시물'),
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                textStyle: AppText.button,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── 업로드 폼 (펼쳐질 때만 표시) ──
        if (_isExpanded) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 이미지 첨부 영역
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            _pendingImageBytes != null
                                ? _navy
                                : const Color(0xFFCDD5E0),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child:
                        _pendingImageBytes != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                Uint8List.fromList(_pendingImageBytes!),
                                fit: BoxFit.cover,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 36,
                                  color: _muted,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '사진을 클릭해서 업로드',
                                  style: AppText.cardSubtitle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'JPG, PNG, WEBP 지원',
                                  style: AppText.metricLabel,
                                ),
                              ],
                            ),
                  ),
                ),
                if (_pendingImageName != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _mint,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _pendingImageName!,
                          style: AppText.metricLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => setState(() {
                              _pendingImageBytes = null;
                              _pendingImageName = null;
                            }),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // 캡션 입력
                TextFormField(
                  controller: _captionController,
                  maxLines: 3,
                  style: AppText.smallStrong.copyWith(color: _ink),
                  decoration: InputDecoration(
                    hintText: '작업 내용이나 소개글을 입력하세요...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
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
                      borderSide: const BorderSide(color: _navy, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 등록 버튼
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      textStyle: AppText.button,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('피드에 등록'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── 피드 그리드 ──
        if (widget.store.myFeedPosts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.photo_library_outlined,
                  size: 40,
                  color: _muted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text('아직 올린 피드가 없어요', style: AppText.cardSubtitle),
                const SizedBox(height: 4),
                Text(
                  '작업 사진을 올려 고객에게 어필해보세요!',
                  style: AppText.metricLabel,
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: widget.store.myFeedPosts.length,
                itemBuilder: (context, index) {
                  final post = widget.store.myFeedPosts[index];
                  return _FeedPostCard(
                    post: post,
                    onDelete: () => widget.store.deleteFeedPost(post.id),
                  );
                },
              );
            },
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
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line),
            image:
                post.imageBytes != null
                    ? DecorationImage(
                      image: MemoryImage(
                        Uint8List.fromList(post.imageBytes!),
                      ),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              post.imageBytes == null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        post.caption,
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
                            Colors.black.withValues(alpha: 0.55),
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

        // 삭제 버튼
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
