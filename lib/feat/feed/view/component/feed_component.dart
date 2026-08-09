part of '../pages/feed_page.dart';

class _FeedPageShell extends StatelessWidget {
  const _FeedPageShell({required this.child, this.top = 44, this.bottom = 44});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
          child: child,
        ),
      ),
    );
  }
}

class _FeedNetworkCover extends StatelessWidget {
  const _FeedNetworkCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFE4EAF2), Color(0xFFB8C7D8)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _FeedEmptyCover extends StatelessWidget {
  const _FeedEmptyCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFE4EAF2), Color(0xFFB8C7D8)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.flight_takeoff_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}

class _FeedPost {
  const _FeedPost({
    required this.id,
    required this.location,
    required this.category,
    required this.images,
    required this.authorName,
    required this.authorRole,
    required this.date,
    required this.likes,
    required this.caption,
    this.authorId = '',
    this.operatorId,
    this.authorAvatarUrl,
    this.likedByMe = false,
    this.latitude,
    this.longitude,
  });

  factory _FeedPost.fromApi(FeedPost post) => _FeedPost(
    id: post.id,
    location: post.location,
    category: post.category,
    images: post.images,
    authorName: post.authorName,
    authorRole: post.authorRole,
    date: post.date,
    likes: post.likes,
    caption: post.caption,
    authorId: post.authorId,
    operatorId: post.operatorId,
    authorAvatarUrl: post.authorAvatarUrl,
  );

  final String id;
  final String location;
  final String category;
  final List<String> images;
  final String authorName;
  final String authorRole;
  final String date;
  final int likes;
  final String caption;
  final String authorId;
  final String? operatorId;
  final String? authorAvatarUrl;
  final bool likedByMe;

  /// Shoot location picked by the operator at upload time. Null for posts
  /// that predate the map feature -- they show in the photo feed only.
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;
}

class _FeedMapPoint {
  const _FeedMapPoint({required this.post});

  final _FeedPost post;

  LatLng get position => LatLng(post.latitude!, post.longitude!);
}

const List<_FeedPost> _mockFeedPosts = <_FeedPost>[
  _FeedPost(
    id: 'mock-han-river-night',
    location: '서울 한강',
    category: '항공촬영',
    images: <String>[
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '스카이필름',
    authorRole: '드론 촬영팀',
    date: '방금 전',
    likes: 241,
    caption: '한강 야간 비행 동선을 따라 촬영한 도심 항공 컷입니다.',
    latitude: 37.5259,
    longitude: 126.9285,
  ),
  _FeedPost(
    id: 'mock-busan-coast',
    location: '부산 해운대',
    category: '항공촬영',
    images: <String>[
      'https://images.unsplash.com/photo-1599239660425-cbe6fa8b47c8?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '오션드론',
    authorRole: '해안 촬영',
    date: '오늘',
    likes: 198,
    caption: '해운대 해안선을 따라 저고도 패닝으로 담은 포트폴리오 샘플입니다.',
    latitude: 35.1587,
    longitude: 129.1604,
  ),
  _FeedPost(
    id: 'mock-jeju-seongsan',
    location: '제주 성산',
    category: '관광홍보',
    images: <String>[
      'https://images.unsplash.com/photo-1540202404-a2f29016b523?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '제주에어뷰',
    authorRole: '관광 콘텐츠',
    date: '어제',
    likes: 313,
    caption: '성산 일출봉 주변 풍광을 홍보 영상용 구도로 정리했습니다.',
    latitude: 33.4592,
    longitude: 126.9425,
  ),
  _FeedPost(
    id: 'mock-gangneung-surf',
    location: '강원 강릉',
    category: '항공촬영',
    images: <String>[
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '동해라인',
    authorRole: '해변 촬영',
    date: '2일 전',
    likes: 156,
    caption: '강릉 해변의 수평선과 파도 라인을 드론 탑뷰로 잡았습니다.',
    latitude: 37.7519,
    longitude: 128.8761,
  ),
  _FeedPost(
    id: 'mock-daejeon-inspection',
    location: '대전 유성',
    category: '시설점검',
    images: <String>[
      'https://images.unsplash.com/photo-1473773508845-188df298d2d1?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '테크스캔',
    authorRole: '산업 점검',
    date: '3일 전',
    likes: 87,
    caption: '시설 점검 요청 피드와 연결될 수 있도록 점검형 메타데이터로 구성했습니다.',
    latitude: 36.3504,
    longitude: 127.3845,
  ),
  _FeedPost(
    id: 'mock-jeonju-hanok',
    location: '전북 전주',
    category: '관광홍보',
    images: <String>[
      'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1200&q=80',
    ],
    authorName: '로컬뷰',
    authorRole: '지역 홍보',
    date: '5일 전',
    likes: 122,
    caption: '한옥마을 주변 동선과 랜드마크를 중심으로 배치한 mock 피드입니다.',
    latitude: 35.8242,
    longitude: 127.148,
  ),
];

class DroneFeedSection extends ConsumerStatefulWidget {
  const DroneFeedSection({
    super.key,
    this.region = '전체',
    this.category = '전체',
    this.sort = '인기순',
  });

  final String region;
  final String category;
  final String sort;

  @override
  ConsumerState<DroneFeedSection> createState() => _DroneFeedSectionState();
}

class _DroneFeedSectionState extends ConsumerState<DroneFeedSection> {
  int _visibleCount = 12;
  List<_FeedPost>? _remoteFeed;
  bool _showPhotoFeed = true;
  String? _selectedMapPostId;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final api = ref.read(feedApiProvider);
      List<FeedPost> posts = const <FeedPost>[];
      Set<String> likedIds = <String>{};
      Set<String> blockedIds = <String>{};
      try {
        posts = await ref.read(feedViewModelProvider).fetchPosts();
        likedIds = await api.fetchMyLikedPostIds();
        blockedIds =
            await ref.read(moderationApiProvider).fetchBlockedUserIds();
        if (blockedIds.isNotEmpty) {
          posts =
              posts
                  .where((post) => !blockedIds.contains(post.authorId))
                  .toList();
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _remoteFeed = const <_FeedPost>[]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('피드를 불러오지 못했습니다. 잠시 뒤 다시 시도해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _remoteFeed =
            posts
                .map(
                  (post) => _FeedPost(
                    id: post.id,
                    location: post.location,
                    category: post.category,
                    images: post.images,
                    authorName: post.authorName,
                    authorRole: post.authorRole,
                    date: post.date,
                    likes: post.likes,
                    caption: post.caption,
                    authorId: post.authorId,
                    operatorId: post.operatorId,
                    authorAvatarUrl: post.authorAvatarUrl,
                    likedByMe: likedIds.contains(post.id),
                    latitude: post.latitude,
                    longitude: post.longitude,
                  ),
                )
                .toList();
      });
    });
  }

  @override
  void didUpdateWidget(DroneFeedSection old) {
    super.didUpdateWidget(old);
    if (old.region != widget.region ||
        old.category != widget.category ||
        old.sort != widget.sort) {
      _visibleCount = 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_remoteFeed == null) {
      return const _FeedPageShell(
        child: Center(child: CircularProgressIndicator(color: _navy)),
      );
    }

    final remoteFeed = _remoteFeed!;
    final sourceFeed = remoteFeed.isNotEmpty ? remoteFeed : _mockFeedPosts;
    var filtered = sourceFeed;
    if (widget.region != '전체') {
      filtered =
          filtered.where((p) => p.location.contains(widget.region)).toList();
    }
    if (widget.category != '전체') {
      filtered = filtered.where((p) => p.category == widget.category).toList();
    }
    final actualFeed = List<_FeedPost>.from(filtered);
    if (widget.sort == '인기순') {
      actualFeed.sort((a, b) => b.likes.compareTo(a.likes));
    }

    if (actualFeed.isEmpty) {
      return const _FeedPageShell(
        child: ModeText(
          '아직 공개된 피드가 없습니다.',
          size: 14,
          color: _ink,
          height: 1.55,
        ),
      );
    }
    final mapPoints = _mapPointsFor(actualFeed);
    if (!_showPhotoFeed) {
      if (mapPoints.isEmpty) {
        return _FeedPageShell(
          top: 10,
          bottom: 46,
          child: _FeedMapEmptyState(
            onShowPhotos: () => setState(() => _showPhotoFeed = true),
          ),
        );
      }
      final selectedId =
          mapPoints.any((point) => point.post.id == _selectedMapPostId)
              ? _selectedMapPostId
              : mapPoints.first.post.id;
      return _FeedPageShell(
        top: 10,
        bottom: 46,
        child: _FeedMapView(
          points: mapPoints,
          selectedPostId: selectedId,
          onSelect:
              (point) => setState(() {
                _selectedMapPostId = point.post.id;
              }),
          onOpenPost: (post) => _openPostDialog(context, post),
          onShowPhotos: () => setState(() => _showPhotoFeed = true),
        ),
      );
    }

    final visibleItems = actualFeed.take(_visibleCount).toList();
    final hasMore = _visibleCount < actualFeed.length;

    return _FeedPageShell(
      top: 10,
      bottom: 46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showPhotoFeed = false),
              icon: const Icon(Icons.map_rounded),
              label: const Text('지도 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                side: const BorderSide(color: _line),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: FeedText.button,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              // 모바일: 1열, PC: 4열 (네이버 카페 갤러리 형식)
              final isMobile = constraints.maxWidth < 600;
              final crossAxisCount = isMobile ? 1 : 4;
              final childAspectRatio = isMobile ? 1.2 : 0.85;
              final spacing = isMobile ? 12.0 : 16.0;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: visibleItems.length,
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  return _FeedGalleryCard(
                    post: item,
                    onTap: () => _openPostDialog(context, item),
                  );
                },
              );
            },
          ),
          if (hasMore) ...<Widget>[
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    final nextCount = _visibleCount + 12;
                    _visibleCount =
                        nextCount > actualFeed.length
                            ? actualFeed.length
                            : nextCount;
                  });
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('사진 더 보기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _line),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  textStyle: FeedText.button,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openPostDialog(BuildContext context, _FeedPost post) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder:
          (_) => _FeedPostDialog(
            post: post,
            loadPilot:
                (id) => ref.read(dronePilotApiProvider).fetchPilotById(id),
          ),
    );
  }

  List<_FeedMapPoint> _mapPointsFor(List<_FeedPost> feed) {
    return <_FeedMapPoint>[
      for (final post in feed)
        if (post.hasLocation) _FeedMapPoint(post: post),
    ];
  }
}

class _FeedMapEmptyState extends StatelessWidget {
  const _FeedMapEmptyState({required this.onShowPhotos});

  final VoidCallback onShowPhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.map_outlined, color: _muted, size: 36),
          const SizedBox(height: 12),
          const ModeText('아직 위치가 등록된 촬영 게시물이 없습니다.', size: 14, color: _ink, height: 1.55),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onShowPhotos,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('사진으로 보기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _navy,
              side: const BorderSide(color: _line),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: FeedText.button,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMapView extends StatelessWidget {
  const _FeedMapView({
    required this.points,
    required this.selectedPostId,
    required this.onSelect,
    required this.onOpenPost,
    required this.onShowPhotos,
  });

  final List<_FeedMapPoint> points;
  final String? selectedPostId;
  final ValueChanged<_FeedMapPoint> onSelect;
  final ValueChanged<_FeedPost> onOpenPost;
  final VoidCallback onShowPhotos;

  @override
  Widget build(BuildContext context) {
    final selected = points.firstWhere(
      (point) => point.post.id == selectedPostId,
      orElse: () => points.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ModeText(
                    '드론 지도',
                    size: 26,
                    weight: FontWeight.w800,
                    color: _navy,
                    height: 1.25,
                    letterSpacing: -0.6,
                  ),
                  const SizedBox(height: 6),
                  ModeText(
                    '한국 지도에서 촬영 위치를 고르고 바로 사진을 확인하세요.',
                    size: 14,
                    color: _muted,
                    height: 1.55,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: onShowPhotos,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('사진으로 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                side: const BorderSide(color: _line),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: FeedText.button,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            return SizedBox(
              height: compact ? 580 : 640,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: <Widget>[
                    FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(36.35, 127.85),
                        initialZoom: 6.5,
                        minZoom: 5,
                        maxZoom: 17,
                      ),
                      children: <Widget>[
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.modu.drame',
                        ),
                        MarkerLayer(
                          markers:
                              points
                                  .map(
                                    (point) => Marker(
                                      point: point.position,
                                      width: 58,
                                      height: 58,
                                      child: _FeedMapMarker(
                                        selected:
                                            point.post.id == selected.post.id,
                                        onTap: () => onSelect(point),
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
                      child: _FeedMapLegend(count: points.length),
                    ),
                    Positioned(
                      left: compact ? 12 : null,
                      right: 12,
                      bottom: 12,
                      child: _FeedMapPreview(
                        point: selected,
                        compact: compact,
                        onOpen: () => onOpenPost(selected.post),
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
                            color: _muted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FeedMapMarker extends StatelessWidget {
  const _FeedMapMarker({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected ? 1.12 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? _navy : Colors.white,
            border: Border.all(color: _navy, width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x330A0B0D),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.flight_takeoff_rounded,
            color: selected ? Colors.white : _navy,
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _FeedMapLegend extends StatelessWidget {
  const _FeedMapLegend({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.radar_rounded, color: _navy, size: 18),
            const SizedBox(width: 8),
            ModeMediumText('$count개 촬영 지점', size: 13, color: _ink, height: 1.25),
          ],
        ),
      ),
    );
  }
}

class _FeedMapPreview extends StatelessWidget {
  const _FeedMapPreview({
    required this.point,
    required this.compact,
    required this.onOpen,
  });

  final _FeedMapPoint point;
  final bool compact;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final post = point.post;
    final image = post.images.isEmpty ? null : post.images.first;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? double.infinity : 390),
      child: Material(
        color: Colors.white,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: compact ? 104 : 128,
                    height: compact ? 88 : 104,
                    child:
                        image == null
                            ? const _FeedEmptyCover()
                            : _FeedNetworkCover(imageUrl: image),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ModeSemiBoldText(
                        post.location,
                        size: 14,
                        color: _ink,
                        height: 1.35,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      ModeMediumText(
                        post.category,
                        size: 13,
                        color: _muted,
                        height: 1.35,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      ModeText(
                        post.caption,
                        size: 13,
                        color: _ink,
                        height: 1.55,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.favorite_rounded,
                            color: _navy,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          ModeMediumText('${post.likes}', size: 13, color: _ink, height: 1.25),
                          const Spacer(),
                          const Icon(
                            Icons.open_in_full_rounded,
                            color: _muted,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedCard extends StatefulWidget {
  const _FeedCard({
    required this.image,
    required this.location,
    required this.category,
    required this.onTap,
  });

  final String? image;
  final String location;
  final String category;
  final VoidCallback onTap;

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (widget.image == null)
                const _FeedEmptyCover()
              else
                _FeedNetworkCover(imageUrl: widget.image!),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.transparent, Color(0xB3000000)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: ModeSemiBoldText(
                    widget.location,
                    size: 14,
                    color: Colors.white,
                    height: 1.35,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 네이버 카페 갤러리 스타일 카드
class _FeedGalleryCard extends StatefulWidget {
  const _FeedGalleryCard({required this.post, required this.onTap});

  final _FeedPost post;
  final VoidCallback onTap;

  @override
  State<_FeedGalleryCard> createState() => _FeedGalleryCardState();
}

class _FeedGalleryCardState extends State<_FeedGalleryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final coverImage = post.images.isNotEmpty ? post.images.first : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.06),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 이미지 영역 (상단)
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (coverImage != null)
                        _FeedNetworkCover(imageUrl: coverImage)
                      else
                        const _FeedEmptyCover(),
                      // 호버시 오버레이
                      AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: Icon(
                              Icons.open_in_full_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      // 이미지 개수 표시 (여러장인 경우)
                      if (post.images.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.photo_library_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 정보 영역 (하단)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 제목 (위치명)
                      Text(
                        post.location,
                        style: const TextStyle(
                          fontFamily: DT.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 작성자 + 지역
                      Row(
                        children: <Widget>[
                          // 작성자 아바타
                          if (post.authorAvatarUrl != null)
                            CircleAvatar(
                              radius: 10,
                              backgroundImage:
                                  NetworkImage(post.authorAvatarUrl!),
                            )
                          else
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: _navy,
                              child: Text(
                                post.authorName.isNotEmpty
                                    ? post.authorName[0]
                                    : '모',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontFamily: DT.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 카테고리 칩
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.category,
                              style: const TextStyle(
                                fontFamily: DT.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: DC.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 날짜 + 좋아요
                      Row(
                        children: <Widget>[
                          Text(
                            post.date,
                            style: const TextStyle(
                              fontFamily: DT.fontFamily,
                              fontSize: 12,
                              color: _muted,
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                          Icon(
                            post.likedByMe
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 14,
                            color:
                                post.likedByMe
                                    ? const Color(0xFFE54866)
                                    : _muted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${post.likes}',
                            style: const TextStyle(
                              fontFamily: DT.fontFamily,
                              fontSize: 12,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedTimelineCard extends StatelessWidget {
  const _FeedTimelineCard({required this.post, required this.onTap});

  final _FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial =
        post.authorName.trim().isEmpty ? '모' : post.authorName.characters.first;
    final avatarUrl = post.authorAvatarUrl;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: <Widget>[
                  ModeAvatar(
                    imageUrl: avatarUrl,
                    radius: 22,
                    fallbackText: initial,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ModeSemiBoldText(post.authorName, size: 14, color: _ink, height: 1.35),
                        const SizedBox(height: 2),
                        ModeMediumText(
                          '${post.location} · ${post.category}',
                          size: 13,
                          color: _muted,
                          height: 1.35,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _FeedCategoryChip(label: post.category),
                  ReportBlockMenuButton(
                    reportTargetType: ReportTargetType.feedPost,
                    reportTargetId: post.id,
                    targetUserId: post.authorId.isEmpty ? null : post.authorId,
                    targetUserName: post.authorName,
                    isOwnContent:
                        post.authorId.isNotEmpty &&
                        post.authorId ==
                            Supabase.instance.client.auth.currentUser?.id,
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1.38,
              child:
                  post.images.isEmpty
                      ? const _FeedEmptyCover()
                      : _FeedNetworkCover(imageUrl: post.images.first),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        post.likedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 25,
                        color: post.likedByMe ? const Color(0xFFE54866) : null,
                      ),
                      const SizedBox(width: 6),
                      ModeMediumText('${post.likes}', size: 13, color: _muted, height: 1.35),
                      const SizedBox(width: 14),
                      const Icon(Icons.chat_bubble_outline_rounded, size: 23),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: post.authorName,
                          style: FeedText.bodyStrong,
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text:
                              post.caption.isEmpty
                                  ? '${post.location}에서 진행한 ${post.category} 작업입니다.'
                                  : post.caption,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FeedText.body,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _line),
          ],
        ),
      ),
    );
  }
}

class _FeedCategoryChip extends StatelessWidget {
  const _FeedCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ModeChip(
      label: label,
      background: const Color(0xFFEAF2FF),
      foreground: DC.primary,
    );
  }
}

class _FeedPostDialog extends ConsumerStatefulWidget {
  const _FeedPostDialog({required this.post, required this.loadPilot});

  final _FeedPost post;
  final Future<DronePilot?> Function(String id) loadPilot;

  @override
  ConsumerState<_FeedPostDialog> createState() => _FeedPostDialogState();
}

class _FeedPostDialogState extends ConsumerState<_FeedPostDialog> {
  final TextEditingController _commentController = TextEditingController();
  final PageController _pageController = PageController();
  List<FeedComment> _comments = <FeedComment>[];
  bool _liked = false;
  int _likeCount = 0;
  int _imageIndex = 0;
  bool _loadingComments = true;
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ref.read(feedApiProvider);
      final liked = await api.hasLiked(widget.post.id);
      final comments = await api.fetchComments(widget.post.id);
      final likeCount = await api.fetchLikeCount(widget.post.id);
      if (!mounted) return;
      setState(() {
        _liked = liked;
        _comments = comments;
        _likeCount = likeCount;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 900;
    final compactImageHeight =
        (size.height * 0.34).clamp(180.0, 420.0).toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1180,
          maxHeight: size.height * 0.86,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            child:
                compact
                    ? Column(
                      children: <Widget>[
                        SizedBox(
                          height: compactImageHeight,
                          child: _imagePane(),
                        ),
                        Expanded(child: _metaPane()),
                      ],
                    )
                    : Row(
                      children: <Widget>[
                        Expanded(flex: 7, child: _imagePane()),
                        Expanded(flex: 4, child: _metaPane()),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _imagePane() {
    if (widget.post.images.isEmpty) {
      return const _FeedEmptyCover();
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        PageView.builder(
          controller: _pageController,
          itemCount: widget.post.images.length,
          onPageChanged: (index) {
            setState(() {
              _imageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return _FeedNetworkCover(imageUrl: widget.post.images[index]);
          },
        ),
        if (widget.post.images.length > 1) ...<Widget>[
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: _ImageNavButton(
              icon: Icons.chevron_left_rounded,
              onTap:
                  _imageIndex == 0 ? null : () => _jumpImage(_imageIndex - 1),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: _ImageNavButton(
              icon: Icons.chevron_right_rounded,
              onTap:
                  _imageIndex == widget.post.images.length - 1
                      ? null
                      : () => _jumpImage(_imageIndex + 1),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(widget.post.images.length, (
                index,
              ) {
                final selected = index == _imageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: selected ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: selected ? 0.95 : 0.55,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _metaPane() {
    final avatarUrl = widget.post.authorAvatarUrl;
    final initial =
        widget.post.authorName.isNotEmpty
            ? widget.post.authorName.substring(0, 1)
            : '모';

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: _navy,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child:
                    avatarUrl == null
                        ? ModeSemiBoldText(initial, size: 14, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ModeSemiBoldText(widget.post.authorName, size: 14, color: _ink, height: 1.35),
                    const SizedBox(height: 3),
                    ModeMediumText(widget.post.authorRole, size: 13, color: _muted, height: 1.35),
                  ],
                ),
              ),
              ReportBlockMenuButton(
                reportTargetType: ReportTargetType.feedPost,
                reportTargetId: widget.post.id,
                targetUserId:
                    widget.post.authorId.isEmpty ? null : widget.post.authorId,
                targetUserName: widget.post.authorName,
                isOwnContent:
                    widget.post.authorId.isNotEmpty &&
                    widget.post.authorId ==
                        Supabase.instance.client.auth.currentUser?.id,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _line),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        textStyle: FeedText.button,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          widget.post.operatorId == null
                              ? null
                              : () async {
                                final pilot = await widget.loadPilot(
                                  widget.post.operatorId!,
                                );
                                if (!mounted || pilot == null) return;
                                Navigator.of(context).pop();
                                _openPortfolio(context, pilot);
                              },
                      icon: const Icon(Icons.grid_view_rounded, size: 17),
                      label: const Text('포트폴리오 보러가기'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  _PostMetaPill(
                    icon: Icons.calendar_today_outlined,
                    text: widget.post.date,
                  ),
                  const SizedBox(width: 8),
                  _PostMetaPill(
                    icon: Icons.sell_outlined,
                    text: widget.post.category,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ModeMediumText(
                '${widget.post.location}에서 진행한 ${widget.post.category} 작업입니다.',
                size: 14,
                color: _ink,
                height: 1.55,
              ),
              const SizedBox(height: 20),
              const ModeSemiBoldText('댓글', size: 17, color: _ink, height: 1.35),
              const SizedBox(height: 12),
              if (_loadingComments)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (_comments.isEmpty)
                const ModeText('아직 댓글이 없습니다.', size: 14, color: _ink, height: 1.55)
              else
                ..._comments.map((c) => _CommentTile(comment: c)),
            ],
          ),
        ),
        const Divider(height: 1, color: _line),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  try {
                    final api = ref.read(feedApiProvider);
                    final nowLiked = await api.toggleLike(widget.post.id);
                    if (!mounted) return;
                    setState(() {
                      _liked = nowLiked;
                      _likeCount += nowLiked ? 1 : -1;
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('좋아요 오류: $e')));
                  }
                },
                icon: Icon(
                  _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _liked ? const Color(0xFFE54866) : _ink,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ModeMediumText('좋아요 $_likeCount개', size: 14, color: _ink, height: 1.35),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: FeedText.input,
                  decoration: const InputDecoration(
                    hintText: '댓글 달기...',
                    hintStyle: TextStyle(
                      fontFamily: DT.fontFamily,
                      color: _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              TextButton(
                onPressed: _submittingComment ? null : _submitComment,
                style: TextButton.styleFrom(
                  textStyle: FeedText.button,
                  foregroundColor: _navy,
                ),
                child:
                    _submittingComment
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('게시'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _jumpImage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _submittingComment) return;
    setState(() => _submittingComment = true);
    try {
      final api = ref.read(feedApiProvider);
      await api.addComment(widget.post.id, text);
      final updated = await api.fetchComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = updated;
        _commentController.clear();
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }
}

class _ImageNavButton extends StatelessWidget {
  const _ImageNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: onTap == null ? 0.35 : 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _ink),
        ),
      ),
    );
  }
}

class _PostMetaPill extends StatelessWidget {
  const _PostMetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ModeChip(label: text, icon: icon, background: _soft, foreground: _navy);
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final FeedComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CircleAvatar(
            radius: 16,
            backgroundColor: _soft,
            child: Icon(Icons.person_outline_rounded, size: 18, color: _muted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: _ink, height: 1.45),
                children: <TextSpan>[
                  TextSpan(
                    text: '${comment.authorName} ',
                    style: FeedText.commentUser,
                  ),
                  TextSpan(text: comment.content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
