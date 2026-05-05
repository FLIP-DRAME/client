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

class _FeedSectionHeader extends StatelessWidget {
  const _FeedSectionHeader({
    required this.eyebrow,
    required this.title,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(eyebrow, style: FeedText.eyebrow),
              const SizedBox(height: 7),
              Text(title, style: FeedText.sectionTitle),
            ],
          ),
        ),
        if (action != null)
          TextButton.icon(
            onPressed: () {},
            label: Text(action!),
            icon: const Icon(Icons.chevron_right_rounded),
            iconAlignment: IconAlignment.end,
          ),
      ],
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

class _FeedPost {
  const _FeedPost({
    required this.location,
    required this.category,
    required this.images,
    required this.authorName,
    required this.authorRole,
    required this.date,
    required this.likes,
  });

  final String location;
  final String category;
  final List<String> images;
  final String authorName;
  final String authorRole;
  final String date;
  final int likes;
}

class DroneFeedSection extends StatefulWidget {
  const DroneFeedSection({super.key});

  @override
  State<DroneFeedSection> createState() => _DroneFeedSectionState();
}

class _DroneFeedSectionState extends State<DroneFeedSection> {
  int _visibleCount = 9;

  @override
  Widget build(BuildContext context) {
    final feed = <_FeedPost>[
      _FeedPost(
        location: '서울 강남구',
        category: '항공촬영',
        images: mockPilots[0].portfolioImages,
        authorName: '이서연 운용자',
        authorRole: '도심 홍보 영상 전문가',
        date: '2026.05.02',
        likes: 634,
      ),
      _FeedPost(
        location: '경기 이천',
        category: '농약방제',
        images: <String>[
          mockPilots[0].portfolioImages[1],
          mockPilots[0].portfolioImages[1],
        ],
        authorName: '김하늘 운용자',
        authorRole: '정밀 방제 운용자',
        date: '2026.04.30',
        likes: 412,
      ),
      _FeedPost(
        location: '인천 서구',
        category: '측량·매핑',
        images: <String>[
          mockPilots[2].portfolioImages[0],
          mockPilots[2].portfolioImages[0],
        ],
        authorName: '박지훈 운용자',
        authorRole: 'RTK 측량 전문가',
        date: '2026.04.27',
        likes: 295,
      ),
      _FeedPost(
        location: '충남 태안',
        category: '시설점검',
        images: <String>[
          mockPilots[3].portfolioImages[0],
          mockPilots[3].portfolioImages[0],
        ],
        authorName: '서해 드론웍스',
        authorRole: '태양광 패널 점검',
        date: '2026.04.25',
        likes: 188,
      ),
      _FeedPost(
        location: '부산 해운대',
        category: '행사촬영',
        images: mockPilots[4].portfolioImages,
        authorName: '남해 시네마틱',
        authorRole: '이벤트 항공 촬영',
        date: '2026.04.21',
        likes: 712,
      ),
      _FeedPost(
        location: '제주 애월',
        category: '항공촬영',
        images: mockPilots[5].portfolioImages,
        authorName: '오름 드론웍스',
        authorRole: '관광지 콘텐츠 촬영',
        date: '2026.04.19',
        likes: 538,
      ),
      _FeedPost(
        location: '강원 강릉',
        category: '항공촬영',
        images: <String>[
          mockPilots[2].portfolioImages[1],
          mockPilots[2].portfolioImages[3],
        ],
        authorName: '백두대간 픽처스',
        authorRole: '산악 지형 촬영',
        date: '2026.04.16',
        likes: 221,
      ),
      _FeedPost(
        location: '전남 여수',
        category: '해양·산림',
        images: <String>[
          mockPilots[5].portfolioImages[2],
          mockPilots[5].portfolioImages[3],
        ],
        authorName: '호남 에어샷',
        authorRole: '해양 관광 콘텐츠',
        date: '2026.04.12',
        likes: 176,
      ),
      _FeedPost(
        location: '서울 마포',
        category: '부동산',
        images: mockPilots[1].portfolioImages,
        authorName: '김민준 운용자',
        authorRole: '부동산 영상 전문가',
        date: '2026.04.10',
        likes: 329,
      ),
      _FeedPost(
        location: '경기 성남',
        category: '부동산',
        images: <String>[
          mockPilots[1].portfolioImages[1],
          mockPilots[1].portfolioImages[2],
        ],
        authorName: '김민준 운용자',
        authorRole: '항공 파노라마 촬영',
        date: '2026.04.08',
        likes: 204,
      ),
      _FeedPost(
        location: '충북 청주',
        category: '농약방제',
        images: <String>[
          mockPilots[0].portfolioImages[1],
          mockPilots[0].portfolioImages[0],
        ],
        authorName: '한강 에어필름',
        authorRole: '농경지 방제',
        date: '2026.04.06',
        likes: 151,
      ),
      _FeedPost(
        location: '경북 포항',
        category: '시설점검',
        images: mockPilots[3].portfolioImages,
        authorName: '서해 드론웍스',
        authorRole: '시설 안전 점검',
        date: '2026.04.03',
        likes: 267,
      ),
      _FeedPost(
        location: '인천 송도',
        category: '건설현장',
        images: <String>[
          mockPilots[2].portfolioImages[2],
          mockPilots[2].portfolioImages[0],
        ],
        authorName: '박지훈 운용자',
        authorRole: '건설 현장 기록',
        date: '2026.03.31',
        likes: 318,
      ),
      _FeedPost(
        location: '대전 유성',
        category: '측량·매핑',
        images: <String>[
          mockPilots[2].portfolioImages[0],
          mockPilots[1].portfolioImages[1],
        ],
        authorName: '백두대간 픽처스',
        authorRole: '정사영상 제작',
        date: '2026.03.29',
        likes: 143,
      ),
      _FeedPost(
        location: '제주 서귀포',
        category: '항공촬영',
        images: <String>[
          mockPilots[5].portfolioImages[1],
          mockPilots[5].portfolioImages[0],
        ],
        authorName: '오름 드론웍스',
        authorRole: '리조트 홍보 촬영',
        date: '2026.03.25',
        likes: 482,
      ),
    ];
    final visibleItems = feed.take(_visibleCount).toList();
    final hasMore = _visibleCount < feed.length;

    return _FeedPageShell(
      top: 22,
      bottom: 46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _FeedSectionHeader(eyebrow: '실제 작업 리뷰', title: '드론으로 찍은 사진 피드'),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final count =
                  constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 760
                      ? 2
                      : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  mainAxisExtent: constraints.maxWidth >= 900 ? 392 : 300,
                ),
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  return _FeedCard(
                    image: item.images.first,
                    location: item.location,
                    category: item.category,
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
                    final nextCount = _visibleCount + 9;
                    _visibleCount =
                        nextCount > feed.length ? feed.length : nextCount;
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
      builder: (_) => _FeedPostDialog(post: post),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.image,
    required this.location,
    required this.category,
    required this.onTap,
  });

  final String image;
  final String location;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _FeedNetworkCover(imageUrl: image),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FeedText.feedLocation,
                  ),
                  const SizedBox(height: 5),
                  // Text(
                  //   category,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedPostDialog extends StatefulWidget {
  const _FeedPostDialog({required this.post});

  final _FeedPost post;

  @override
  State<_FeedPostDialog> createState() => _FeedPostDialogState();
}

class _FeedPostDialogState extends State<_FeedPostDialog> {
  final TextEditingController _commentController = TextEditingController();
  final PageController _pageController = PageController();
  final List<String> _comments = <String>[
    '촬영 구도가 정말 깔끔하네요.',
    '이 지역 허가까지 포함된 작업인가요?',
    '비슷한 촬영 견적도 받아보고 싶어요.',
  ];
  bool _liked = false;
  int _imageIndex = 0;

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
                        SizedBox(height: 420, child: _imagePane()),
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
    final likes = widget.post.likes + (_liked ? 1 : 0);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: _navy,
                child: Text(
                  widget.post.authorName.substring(0, 1),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.post.authorName, style: FeedText.authorName),
                    const SizedBox(height: 3),
                    Text(widget.post.authorRole, style: FeedText.authorRole),
                  ],
                ),
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
                      onPressed: () {
                        final pilot = mockPilots.firstWhere(
                          (candidate) => widget.post.authorName.startsWith(
                            candidate.name.split(' ').first,
                          ),
                          orElse: () => mockPilots.first,
                        );
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
              Text(
                '${widget.post.location}에서 진행한 ${widget.post.category} 작업입니다.',
                style: FeedText.bodyStrong,
              ),
              const SizedBox(height: 20),
              const Text('댓글', style: FeedText.dialogTitle),
              const SizedBox(height: 12),
              ..._comments.map((comment) => _CommentTile(comment: comment)),
            ],
          ),
        ),
        const Divider(height: 1, color: _line),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _liked = !_liked;
                  });
                },
                icon: Icon(
                  _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _liked ? const Color(0xFFE54866) : _ink,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mode_comment_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send_outlined),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border_rounded),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('좋아요 $likes개', style: FeedText.likeCount),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied_alt_rounded, color: _muted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: FeedText.input,
                  decoration: const InputDecoration(
                    hintText: '댓글 달기...',
                    hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
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
                onPressed: _submitComment,
                style: TextButton.styleFrom(
                  textStyle: FeedText.button,
                  foregroundColor: _navy,
                ),
                child: const Text('게시'),
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

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _comments.add(text);
      _commentController.clear();
    });
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: _navy, size: 16),
          const SizedBox(width: 6),
          Text(text, style: FeedText.metaPill),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final String comment;

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
                  const TextSpan(
                    text: 'drame_user ',
                    style: FeedText.commentUser,
                  ),
                  TextSpan(text: comment),
                ],
              ),
            ),
          ),
          const Icon(Icons.favorite_border_rounded, size: 18, color: _muted),
        ],
      ),
    );
  }
}
