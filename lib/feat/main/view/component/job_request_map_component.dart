part of '../pages/main_page.dart';

class _JobRequestMapSection extends ConsumerStatefulWidget {
  const _JobRequestMapSection({required this.store});

  final DrameStore store;

  @override
  ConsumerState<_JobRequestMapSection> createState() =>
      _JobRequestMapSectionState();
}

class _JobRequestMapSectionState extends ConsumerState<_JobRequestMapSection> {
  static const Color _navy = Color(0xFF16305E);

  List<MapJobRequest>? _requests;
  String? _selectedId;
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

  Future<void> _load() async {
    try {
      final api = ref.read(quoteApiProvider);
      final open = await api.fetchOpenMapRequests();
      final mine =
          widget.store.isLoggedIn
              ? await api.fetchMyMapRequests()
              : const <MapJobRequest>[];
      if (!mounted) return;
      // Own requests win on id collisions -- they carry the true status
      // (e.g. closed/expired) even after the public feed has dropped them.
      final merged = <String, MapJobRequest>{
        for (final request in open) request.id: request,
      };
      for (final request in mine) {
        merged[request.id] = request;
      }
      final combined =
          merged.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _requests = combined);
    } catch (_) {
      if (!mounted) return;
      setState(() => _requests = const <MapJobRequest>[]);
    }
  }

  Future<void> _closeRequest(MapJobRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
        _requests =
            _requests
                ?.map(
                  (r) => r.id == request.id
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
                          isOwn: r.isOwn,
                        )
                      : r,
                )
                .toList();
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
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
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
      showLoginRequiredDialog(
        context,
        message: '촬영 요청을 등록하려면 로그인이 필요합니다.',
      );
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
            error.toString().replaceFirst('Bad state: ', '').replaceFirst(
              'Exception: ',
              '',
            ),
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
        message: '요청 상세 확인과 견적 응답은 로그인 후 이용할 수 있습니다.',
      );
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
      summary: '',
      progress: '',
      remaining: '확인 필요',
      mapLabel: '${request.locationLabel} 지도',
      createdAt: request.createdAt,
      latitude: request.latitude,
      longitude: request.longitude,
    );
    _openPilotRequestReviewPage(context, initialRequest: stub);
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
                      const Text('촬영 요청 지도', style: AppText.cardTitle),
                      const SizedBox(height: 6),
                      Text(
                        '지도에서 위치를 찍어 촬영 요청을 올리고, 다른 요청도 둘러보세요.',
                        style: AppText.cardSubtitle,
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
                onDateChanged:
                    (value) => setState(() => _composerDate = value),
                onSubmit: _submitComposer,
              ),
              const SizedBox(height: 20),
            ],
            if (requests == null)
              const SizedBox(
                height: 420,
                child: Center(child: CircularProgressIndicator(color: _navy)),
              )
            else if (requests.isEmpty)
              _JobRequestMapEmptyState(onNewRequest: () {
                if (!_showComposer) setState(() => _showComposer = true);
              })
            else
              _JobRequestMap(
                requests: requests,
                selectedId: _selectedId,
                onSelect: (request) => setState(() => _selectedId = request.id),
                onDismiss: () => setState(() => _selectedId = null),
                onRespond: _handleRespond,
                onClose: _closeRequest,
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

  static const Color _navy = Color(0xFF16305E);
  static const Color _line = Color(0xFFE4EAF2);
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
    final categoryOptions =
        defaultDroneCategories.map((c) => c.label).toList();
    final selectedCategory =
        categoryOptions.contains(category) ? category! : categoryOptions.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: locationLabel == null ? _line : _mint,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.map_rounded,
                    size: 18,
                    color: locationLabel == null ? const Color(0xFF9CA3AF) : _mint,
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
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
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
                  '등록한 요청은 7일이 지나면 지도에서 자동으로 마감(삭제)돼요. 그 전에 직접 마감할 수도 있어요.',
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
                backgroundColor: _navy,
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
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.map_outlined, color: Color(0xFF9CA3AF), size: 36),
          const SizedBox(height: 12),
          const Text('아직 등록된 촬영 요청이 없습니다.', style: AppText.cardSubtitle),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onNewRequest,
            icon: const Icon(Icons.add_rounded),
            label: const Text('새 요청 등록'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF16305E),
              side: const BorderSide(color: Color(0xFFE4EAF2)),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
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
    required this.onSelect,
    required this.onDismiss,
    required this.onRespond,
    required this.onClose,
  });

  final List<MapJobRequest> requests;
  final String? selectedId;
  final ValueChanged<MapJobRequest> onSelect;
  final VoidCallback onDismiss;
  final ValueChanged<MapJobRequest> onRespond;
  final ValueChanged<MapJobRequest> onClose;

  @override
  State<_JobRequestMap> createState() => _JobRequestMapState();
}

class _JobRequestMapState extends State<_JobRequestMap> {
  static const Color _navy = Color(0xFF16305E);
  static const double _minZoom = 6;
  static const double _maxZoom = 17;

  final MapController _mapController = MapController();
  bool _compactShowList = false;

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(camera.center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.requests;
    final selectedId = widget.selectedId;
    final onSelect = widget.onSelect;
    final onDismiss = widget.onDismiss;
    final onRespond = widget.onRespond;
    final onClose = widget.onClose;
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

        final mapStack = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: <Widget>[
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(36.35, 127.85),
                  initialZoom: 6.5,
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
                        requests
                            .map(
                              (request) => Marker(
                                point: LatLng(
                                  request.latitude,
                                  request.longitude,
                                ),
                                width: 54,
                                height: 54,
                                child: _JobRequestMarker(
                                  inProgress: request.isInProgress,
                                  closed: request.isClosedOrExpired,
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
                    border: Border.all(color: const Color(0xFFE4EAF2)),
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
                          color: _navy,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${requests.length}개 요청 · 진행중 초록 테두리',
                          style: AppText.metricLabel,
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
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: AppText.metricLabel.copyWith(fontSize: 11),
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
                    compact: true,
                    onRespond: () => onRespond(selected!),
                    onClose: () => onClose(selected!),
                    onDismiss: onDismiss,
                  ),
                ),
            ],
          ),
        );

        final cardList = ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            return GestureDetector(
              onTap: () => onSelect(request),
              child: _JobRequestPreview(
                request: request,
                compact: true,
                highlighted: request.id == selectedId,
                onRespond: () => onRespond(request),
                onClose: () => onClose(request),
              ),
            );
          },
        );

        if (compact) {
          return Column(
            children: <Widget>[
              _CompactViewToggle(
                showList: _compactShowList,
                onChanged: (showList) =>
                    setState(() => _compactShowList = showList),
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

  static const Color _line = Color(0xFFE4EAF2);

  final bool showList;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
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

  static const Color _navy = Color(0xFF16305E);

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _navy : Colors.transparent,
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
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MapZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),
          const Divider(height: 1, color: Color(0xFFE4EAF2)),
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
        child: Icon(icon, size: 20, color: const Color(0xFF16305E)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected ? 1.12 : 1,
        child: Opacity(
          opacity: closed ? 0.6 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? color : Colors.white,
              border: Border.all(color: color, width: inProgress ? 3 : 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x330A0B0D),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              closed
                  ? Icons.lock_clock_rounded
                  : Icons.request_quote_rounded,
              color: selected ? Colors.white : color,
              size: 23,
            ),
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
    this.highlighted = false,
    this.onDismiss,
  });

  static const Color _navy = Color(0xFF16305E);
  static const Color _inProgress = Color(0xFF05B169);
  static const Color _closed = Color(0xFF9CA3AF);

  final MapJobRequest request;
  final bool compact;
  final VoidCallback onRespond;
  final VoidCallback onClose;
  final bool highlighted;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final closed = request.isClosedOrExpired;
    final statusColor =
        closed ? _closed : (request.isInProgress ? _inProgress : _navy);
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
                  color: highlighted ? _navy : Colors.transparent,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              statusLabel,
                              style: AppText.metricLabel.copyWith(
                                color: statusColor,
                              ),
                            ),
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
                  else if (!request.isOwn && !closed)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onRespond,
                        style: FilledButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          textStyle: AppText.button,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('견적 응답하기'),
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
