part of '../pages/main_page.dart';

class _JobRequestMapSection extends ConsumerStatefulWidget {
  const _JobRequestMapSection({required this.store});

  final DrameStore store;

  @override
  ConsumerState<_JobRequestMapSection> createState() =>
      _JobRequestMapSectionState();
}

class _JobRequestMapSectionState extends ConsumerState<_JobRequestMapSection> {
  List<MapJobRequest>? _requests;
  Map<String, String> _myQuotedClientNames = const <String, String>{};
  String? _selectedId;
  MapJobRequestDetail? _selectedDetail;
  String? _detailLoadingId;
  bool _showComposer = false;

  String? _composerCategory;
  String _composerBudget = '협의';
  LatLng? _composerLocation;
  String? _composerLocationLabel;
  DateTime? _composerDate;
  final TextEditingController _composerDetailController =
      TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _composerDetailController.dispose();
    super.dispose();
  }

  /// Manually closed requests sink to the bottom; otherwise newest first.
  List<MapJobRequest> _sortRequests(List<MapJobRequest> requests) {
    return requests..sort((a, b) {
      final closedCompare = (a.isClosed ? 1 : 0).compareTo(b.isClosed ? 1 : 0);
      if (closedCompare != 0) return closedCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> _load() async {
    try {
      final api = ref.read(quoteApiProvider);
      final open = await api.fetchOpenMapRequests();
      final mine =
          widget.store.isLoggedIn
              ? await api.fetchMyMapRequests()
              : const <MapJobRequest>[];
      // Requests this operator has already sent a quote for -- used to swap
      // "견적 보내기" for "채팅하기" on those cards instead of letting them
      // respond again.
      final myQuotedClientNames = <String, String>{
        if (widget.store.operatorRegistrationCompleted)
          for (final r in (await ref
                  .read(dronePilotApiProvider)
                  .fetchOperatorRequests())
              .where((r) => r.myQuoteId != null))
            r.id: r.client,
      };
      if (!mounted) return;
      // Own requests win on id collisions -- they carry the true status
      // (e.g. manually closed) even after the public feed has dropped them.
      final merged = <String, MapJobRequest>{
        for (final request in open) request.id: request,
      };
      for (final request in mine) {
        merged[request.id] = request;
      }
      final combined = _sortRequests(
        merged.values
            .map(
              (request) =>
                  myQuotedClientNames.containsKey(request.id)
                      ? request.copyWith(hasMyQuote: true)
                      : request,
            )
            .toList(),
      );
      setState(() {
        _requests = combined;
        _myQuotedClientNames = myQuotedClientNames;
      });
      if (combined.isNotEmpty) {
        unawaited(_fetchDetail(combined.first.id));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _requests = const <MapJobRequest>[]);
    }
  }

  Future<void> _fetchDetail(String requestId) async {
    if (_detailLoadingId == requestId) return;
    _detailLoadingId = requestId;
    setState(() => _selectedDetail = null);
    try {
      final detail = await ref
          .read(quoteApiProvider)
          .fetchMapJobRequestDetail(requestId);
      if (!mounted ||
          _selectedId != requestId && requestId != _requests?.firstOrNull?.id) {
        return;
      }
      setState(() => _selectedDetail = detail);
    } catch (_) {
      // degrade gracefully -- preview card still shows without detail
    } finally {
      _detailLoadingId = null;
    }
  }

  Future<void> _closeRequest(MapJobRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('요청을 마감할까요?'),
            content: const Text('마감하면 지도에서 사라지고 더 이상 견적을 받을 수 없습니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('마감하기'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(quoteApiProvider).closeMapJobRequest(request.id);
      if (!mounted) return;
      setState(() {
        final updated =
            _requests
                ?.map(
                  (r) =>
                      r.id == request.id
                          ? MapJobRequest(
                            id: r.id,
                            status: 'cancelled',
                            category: r.category,
                            budgetLabel: r.budgetLabel,
                            locationLabel: r.locationLabel,
                            latitude: r.latitude,
                            longitude: r.longitude,
                            createdAt: r.createdAt,
                            preferredDate: r.preferredDate,
                            detail: r.detail,
                            isOwn: r.isOwn,
                          )
                          : r,
                )
                .toList();
        _requests = updated == null ? null : _sortRequests(updated);
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('요청을 마감했습니다. 더 이상 견적을 받지 않습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickComposerLocation() async {
    final result = await showFeedLocationPicker(
      context,
      initial: _composerLocation,
    );
    if (result == null || !mounted) return;
    setState(() {
      _composerLocation = result.position;
      _composerLocationLabel = result.label;
    });
  }

  Future<void> _submitComposer() async {
    if (_submitting) return;
    if (!widget.store.isLoggedIn) {
      showLoginRequiredDialog(context, message: '촬영 요청을 등록하려면 로그인이 필요합니다.');
      return;
    }
    final category = _composerCategory ?? defaultDroneCategories.first.label;
    final location = _composerLocation;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지도에서 촬영 위치를 선택해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final created = await ref
          .read(quoteApiProvider)
          .createMapJobRequest(
            categoryLabel: category,
            budgetRange: _composerBudget,
            latitude: location.latitude,
            longitude: location.longitude,
            locationLabel: _composerLocationLabel ?? '지도에서 선택한 위치',
            detail: _composerDetailController.text.trim(),
            preferredDate: _composerDate,
          );
      if (!mounted) return;
      setState(() {
        _requests = <MapJobRequest>[created, ...?_requests];
        _selectedId = created.id;
        _showComposer = false;
        _submitting = false;
        _composerCategory = null;
        _composerBudget = '협의';
        _composerLocation = null;
        _composerLocationLabel = null;
        _composerDate = null;
        _composerDetailController.clear();
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('촬영 요청을 지도에 등록했습니다.'),
          backgroundColor: Color(0xFF0A7F5A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst('Bad state: ', '')
                .replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRespond(MapJobRequest request) {
    if (!widget.store.isLoggedIn) {
      showLoginRequiredDialog(
        context,
        message: '드론 조종사이신가요? 여기서 일감을 받아보세요.',
      );
      return;
    }
    if (!widget.store.operatorRegistrationCompleted) {
      unawaited(showOperatorRegistrationPromptDialog(context));
      return;
    }
    final stub = PilotWorkRequest(
      id: request.id,
      category: request.category,
      status: request.isInProgress ? '진행 중' : '신규',
      location: request.locationLabel,
      distance: '',
      dateRange: request.dateLabel,
      budget: request.budgetLabel,
      client: '고객',
      summary: request.detail,
      progress: '',
      remaining: '확인 필요',
      mapLabel: '${request.locationLabel} 지도',
      createdAt: request.createdAt,
      latitude: request.latitude,
      longitude: request.longitude,
    );
    _openPilotRequestReviewPage(context, initialRequest: stub);
  }

  Future<void> _handleChat(MapJobRequest request) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final roomId = await ref
          .read(chatViewModelProvider)
          .getOrCreateRoom(request.id);
      if (mounted) {
        context.push(
          '/chat/$roomId',
          extra: <String, String>{
            'otherPartyName': _myQuotedClientNames[request.id] ?? '고객',
            'category': request.category,
          },
        );
      }
    } catch (e, st) {
      debugPrint('[_JobRequestMapSection] 채팅방 열기 실패: $e\n$st');
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('채팅방을 열 수 없습니다. 다시 시도해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = _requests;
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F8FA),
      child: _PageShell(
        top: 48,
        bottom: 52,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ModeText(
                        '촬영 요청 지도',
                        size: 22,
                        weight: FontWeight.w800,
                        color: DC.ink,
                        height: 1.25,
                        letterSpacing: -0.45,
                      ),
                      const SizedBox(height: 6),
                      const ModeMediumText(
                        '지도에서 위치를 찍어 촬영 요청을 올리고, 다른 요청도 둘러보세요.',
                        size: 14,
                        color: DC.muted,
                        height: 1.45,
                        letterSpacing: -0.1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed:
                      () => setState(() => _showComposer = !_showComposer),
                  icon: Icon(
                    _showComposer ? Icons.close_rounded : Icons.add_rounded,
                  ),
                  label: Text(_showComposer ? '닫기' : '새 요청 등록'),
                  style: FilledButton.styleFrom(
                    backgroundColor: DC.navy,
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
            if (_showComposer) ...<Widget>[
              _JobRequestComposer(
                category: _composerCategory,
                budget: _composerBudget,
                locationLabel: _composerLocationLabel,
                date: _composerDate,
                detailController: _composerDetailController,
                submitting: _submitting,
                onCategoryChanged:
                    (value) => setState(() => _composerCategory = value),
                onBudgetChanged:
                    (value) => setState(() => _composerBudget = value),
                onPickLocation: _pickComposerLocation,
                onDateChanged: (value) => setState(() => _composerDate = value),
                onSubmit: _submitComposer,
              ),
              const SizedBox(height: 20),
            ],
            if (requests == null)
              const SizedBox(
                height: 420,
                child: Center(
                  child: CircularProgressIndicator(color: DC.navy),
                ),
              )
            else if (requests.isEmpty)
              _JobRequestMapEmptyState(
                onNewRequest: () {
                  if (!_showComposer) setState(() => _showComposer = true);
                },
              )
            else
              _JobRequestMap(
                requests: requests,
                selectedId: _selectedId,
                selectedDetail: _selectedDetail,
                onSelect: (request) {
                  setState(() => _selectedId = request.id);
                  unawaited(_fetchDetail(request.id));
                },
                onDismiss: () => setState(() => _selectedId = null),
                onRespond: _handleRespond,
                onClose: _closeRequest,
                onChat: _handleChat,
              ),
          ],
        ),
      ),
    );
  }
}

class _JobRequestComposer extends StatelessWidget {
  const _JobRequestComposer({
    required this.category,
    required this.budget,
    required this.locationLabel,
    required this.date,
    required this.detailController,
    required this.submitting,
    required this.onCategoryChanged,
    required this.onBudgetChanged,
    required this.onPickLocation,
    required this.onDateChanged,
    required this.onSubmit,
  });

  static const Color _mint = Color(0xFF22C58B);

  final String? category;
  final String budget;
  final String? locationLabel;
  final DateTime? date;
  final TextEditingController detailController;
  final bool submitting;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onBudgetChanged;
  final VoidCallback onPickLocation;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final categoryOptions = defaultDroneCategories.map((c) => c.label).toList();
    final selectedCategory =
        categoryOptions.contains(category) ? category! : categoryOptions.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DC.mapHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FieldLabel('촬영 종류'),
          ChoiceWrap(
            values: categoryOptions,
            selected: selectedCategory,
            onSelected: onCategoryChanged,
          ),
          const SizedBox(height: 18),
          const FieldLabel('예산'),
          ChoiceWrap(
            values: const <String>['0~30만원', '30~50만원', '50~100만원', '협의'],
            selected: budget,
            onSelected: onBudgetChanged,
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPickLocation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: locationLabel == null ? DC.mapHairline : _mint,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.map_rounded,
                    size: 18,
                    color:
                        locationLabel == null ? const Color(0xFF9CA3AF) : _mint,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      locationLabel ?? '촬영 위치를 지도에서 선택 (필수)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.smallStrong.copyWith(
                        color:
                            locationLabel == null
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF0A0B0D),
                      ),
                    ),
                  ),
                  Text(
                    locationLabel == null ? '선택하기' : '변경',
                    style: AppText.metricLabel.copyWith(color: _mint),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          QuoteDateField(selectedDate: date, onDateSelected: onDateChanged),
          const SizedBox(height: 14),
          TextField(
            controller: detailController,
            maxLines: 3,
            style: AppText.smallStrong.copyWith(color: const Color(0xFF0A0B0D)),
            decoration: InputDecoration(
              hintText: '요청 내용 (선택) - 촬영 목적, 원하는 구도 등을 적어주세요.',
              filled: true,
              fillColor: const Color(0xFFF8FAFD),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DC.mapHairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DC.mapHairline),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(0xFF7C828A),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '등록한 요청은 직접 마감하기 전까지 다른 운용자들이 계속 견적을 보낼 수 있어요.',
                  style: AppText.metricLabel.copyWith(
                    color: const Color(0xFF7C828A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: DC.navy,
                foregroundColor: Colors.white,
                textStyle: AppText.button,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(submitting ? '등록 중...' : '요청 등록'),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobRequestMapEmptyState extends StatelessWidget {
  const _JobRequestMapEmptyState({required this.onNewRequest});

  final VoidCallback onNewRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DC.mapHairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.map_outlined, color: Color(0xFF9CA3AF), size: 36),
          const SizedBox(height: 12),
          const ModeMediumText(
            '아직 등록된 촬영 요청이 없습니다.',
            size: 14,
            color: DC.muted,
            height: 1.45,
            letterSpacing: -0.1,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onNewRequest,
            icon: const Icon(Icons.add_rounded),
            label: const Text('새 요청 등록'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DC.navy,
              side: const BorderSide(color: DC.mapHairline),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: AppText.button,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobRequestMap extends StatefulWidget {
  const _JobRequestMap({
    required this.requests,
    required this.selectedId,
    required this.selectedDetail,
    required this.onSelect,
    required this.onDismiss,
    required this.onRespond,
    required this.onClose,
    required this.onChat,
  });

  final List<MapJobRequest> requests;
  final String? selectedId;
  final MapJobRequestDetail? selectedDetail;
  final ValueChanged<MapJobRequest> onSelect;
  final VoidCallback onDismiss;
  final ValueChanged<MapJobRequest> onRespond;
  final ValueChanged<MapJobRequest> onClose;
  final ValueChanged<MapJobRequest> onChat;

  @override
  State<_JobRequestMap> createState() => _JobRequestMapState();
}

class _JobRequestMapState extends State<_JobRequestMap> {
  // CameraConstraint.contain requires the WHOLE viewport to stay inside
  // bounds -- if minZoom is too low, the viewport at that zoom is wider
  // than Korea and contain rejects every camera update (zoom appears
  // frozen). 8 is the lowest zoom where a full-width desktop map card
  // still fits inside the bounds below.
  static const double _minZoom = 8;
  static const double _maxZoom = 17;

  final MapController _mapController = MapController();
  final ScrollController _cardScrollController = ScrollController();
  final Map<String, GlobalKey> _cardKeys = <String, GlobalKey>{};
  bool _compactShowList = false;

  @override
  void dispose() {
    _mapController.dispose();
    _cardScrollController.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(camera.center, zoom);
  }

  @override
  void didUpdateWidget(_JobRequestMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != null &&
        widget.selectedId != oldWidget.selectedId) {
      _scrollSelectedIntoView(widget.selectedId!);
    }
  }

  void _scrollSelectedIntoView(String requestId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_cardScrollController.hasClients) return;
      final renderObject =
          _cardKeys[requestId]?.currentContext?.findRenderObject();
      if (renderObject == null) return;
      // Use the card list's own ScrollPosition directly (not the static
      // Scrollable.ensureVisible helper) -- that helper walks up through
      // every enclosing Scrollable, which also scrolled the outer page.
      _cardScrollController.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.requests;
    final selectedId = widget.selectedId;
    final selectedDetail = widget.selectedDetail;
    final onSelect = widget.onSelect;
    final onDismiss = widget.onDismiss;
    final onRespond = widget.onRespond;
    final onClose = widget.onClose;
    final onChat = widget.onChat;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final mapHeight = compact ? 420.0 : 560.0;

        MapJobRequest? selected;
        for (final request in requests) {
          if (request.id == selectedId) {
            selected = request;
            break;
          }
        }

        final mapStack = Listener(
          onPointerSignal: (_) {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(36.1, 127.85),
                    initialZoom: 8.3,
                    minZoom: _minZoom,
                    maxZoom: _maxZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(32.9, 124.4),
                        const LatLng(38.9, 131.95),
                      ),
                    ),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.modu.drame',
                    ),
                    MarkerLayer(
                      markers:
                          // Closed markers are drawn first (i.e.
                          // underneath) so active requests stay on top when
                          // pins overlap.
                          <MapJobRequest>[
                                ...requests.where((r) => r.isClosed),
                                ...requests.where((r) => !r.isClosed),
                              ]
                              .map(
                                (request) => Marker(
                                  point: LatLng(
                                    request.latitude,
                                    request.longitude,
                                  ),
                                  width: request.isClosed ? 27 : 54,
                                  height: request.isClosed ? 27 : 54,
                                  child: _JobRequestMarker(
                                    inProgress: request.isInProgress,
                                    closed: request.isClosed,
                                    selected: request.id == selectedId,
                                    onTap: () => onSelect(request),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: DC.mapHairline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.radar_rounded,
                            color: DC.navy,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          ModeMediumText(
                            '${requests.length}개 요청 · 진행중 초록 테두리',
                            size: 13,
                            color: DC.muted,
                            height: 1.35,
                            letterSpacing: -0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: ModeMediumText(
                        '© OpenStreetMap contributors',
                        size: 11,
                        color: DC.muted,
                        height: 1.35,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _MapZoomControls(
                    onZoomIn: () => _zoomBy(1),
                    onZoomOut: () => _zoomBy(-1),
                  ),
                ),
                if (compact && selected != null)
                  Positioned(
                    left: 12,
                    right: 60,
                    bottom: 12,
                    child: _JobRequestPreview(
                      request: selected,
                      detail: selectedDetail,
                      compact: true,
                      onRespond: () => onRespond(selected!),
                      onClose: () => onClose(selected!),
                      onChat: () => onChat(selected!),
                      onDismiss: onDismiss,
                    ),
                  ),
              ],
            ),
          ),
        );

        final cardList = ListView.separated(
          controller: _cardScrollController,
          // ListView only builds items near the current viewport -- a
          // marker tap for a request whose card is further down the list
          // has no RenderObject yet, so _scrollSelectedIntoView silently
          // finds nothing to scroll to. A large cacheExtent keeps every
          // card built regardless of scroll position (this list is at
          // most a few dozen items, so the cost is negligible).
          cacheExtent: 5000,
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            return GestureDetector(
              key: _cardKeys.putIfAbsent(request.id, () => GlobalKey()),
              onTap: () => onSelect(request),
              child: _JobRequestPreview(
                request: request,
                detail: request.id == selectedId ? selectedDetail : null,
                compact: true,
                highlighted: request.id == selectedId,
                onRespond: () => onRespond(request),
                onClose: () => onClose(request),
                onChat: () => onChat(request),
              ),
            );
          },
        );

        if (compact) {
          return Column(
            children: <Widget>[
              _CompactViewToggle(
                showList: _compactShowList,
                onChanged:
                    (showList) => setState(() => _compactShowList = showList),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: mapHeight,
                child: _compactShowList ? cardList : mapStack,
              ),
            ],
          );
        }

        return SizedBox(
          height: mapHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 3, child: mapStack),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: cardList),
            ],
          ),
        );
      },
    );
  }
}

class _CompactViewToggle extends StatelessWidget {
  const _CompactViewToggle({required this.showList, required this.onChanged});

  final bool showList;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DC.mapHairline),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _CompactViewToggleButton(
              label: '지도',
              icon: Icons.map_rounded,
              selected: !showList,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _CompactViewToggleButton(
              label: '견적 목록',
              icon: Icons.request_quote_rounded,
              selected: showList,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactViewToggleButton extends StatelessWidget {
  const _CompactViewToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DC.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : const Color(0xFF7C828A),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppText.metricLabel.copyWith(
                  color: selected ? Colors.white : const Color(0xFF7C828A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapZoomControls extends StatelessWidget {
  const _MapZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DC.mapHairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MapZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),
          const Divider(height: 1, color: DC.mapHairline),
          _MapZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 20, color: DC.navy),
      ),
    );
  }
}

class _JobRequestMarker extends StatelessWidget {
  const _JobRequestMarker({
    required this.inProgress,
    required this.closed,
    required this.selected,
    required this.onTap,
  });

  final bool inProgress;
  final bool closed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        closed
            ? const Color(0xFF9CA3AF)
            : inProgress
            ? const Color(0xFF05B169)
            : const Color(0xFF16305E);
    // Closed markers get a fully opaque black border; the fill/icon still
    // dim via alpha so the border isn't washed out along with them.
    final borderColor = closed ? Colors.black : color;
    final fillColor = selected ? color : Colors.white;
    final iconColor = selected ? Colors.white : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected ? 1.12 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: closed ? fillColor.withValues(alpha: 0.6) : fillColor,
            border: Border.all(color: borderColor, width: inProgress ? 3 : 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x330A0B0D),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            closed ? Icons.lock_clock_rounded : Icons.request_quote_rounded,
            color: closed ? iconColor.withValues(alpha: 0.6) : iconColor,
            size: closed ? 11.5 : 23,
          ),
        ),
      ),
    );
  }
}

class _JobRequestPreview extends StatelessWidget {
  const _JobRequestPreview({
    required this.request,
    required this.compact,
    required this.onRespond,
    required this.onClose,
    required this.onChat,
    this.highlighted = false,
    this.onDismiss,
    this.detail,
  });

  static const Color _inProgress = Color(0xFF05B169);
  static const Color _closed = Color(0xFF9CA3AF);

  final MapJobRequest request;
  final MapJobRequestDetail? detail;
  final bool compact;
  final VoidCallback onRespond;
  final VoidCallback onClose;
  final VoidCallback onChat;
  final bool highlighted;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final closed = request.isClosed;
    final statusColor =
        closed ? _closed : (request.isInProgress ? _inProgress : DC.navy);
    final statusLabel =
        closed ? '요청마감' : (request.isInProgress ? '진행중' : '요청 대기중');
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? double.infinity : 360),
      child: Material(
        color: Colors.white,
        elevation: highlighted ? 16 : 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: highlighted ? DC.navy : Colors.transparent,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: onDismiss != null ? 18 : 0,
                          ),
                          child: Text(
                            request.category,
                            style: AppText.smallStrong.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            request.elapsedLabel,
                            style: AppText.metricLabel.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ModeChip(
                            label: statusLabel,
                            background: statusColor.withValues(alpha: 0.1),
                            foreground: statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${request.locationLabel} · ${request.budgetLabel} · ${request.dateLabel}',
                    style: AppText.cardSubtitle,
                  ),
                  if (detail != null && detail!.hasDetail) ...<Widget>[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        detail!.detail,
                        style: AppText.cardSubtitle,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (request.isOwn && !closed)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onClose,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB3261E),
                          side: const BorderSide(color: Color(0xFFE4B7B3)),
                          textStyle: AppText.button,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('요청 마감하기'),
                      ),
                    )
                  else if (!request.isOwn && !closed && request.hasMyQuote)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onChat,
                        icon: const Icon(Icons.chat_rounded, size: 16),
                        label: const Text('채팅하기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DC.navy,
                          side: const BorderSide(color: DC.navy),
                          textStyle: AppText.button,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else if (!request.isOwn && !closed)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onRespond,
                        style: FilledButton.styleFrom(
                          backgroundColor: DC.navy,
                          foregroundColor: Colors.white,
                          textStyle: AppText.button,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('견적 보내기'),
                      ),
                    )
                  else if (closed)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _closed,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          disabledForegroundColor: _closed,
                          textStyle: AppText.button,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('마감된 요청입니다'),
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              Positioned(
                top: -2,
                right: -2,
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(100),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
