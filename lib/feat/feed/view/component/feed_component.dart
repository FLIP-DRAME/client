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
  const _FeedSectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

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
    this.operatorId,
    this.authorAvatarUrl,
  });

  final String id;
  final String location;
  final String category;
  final List<String> images;
  final String authorName;
  final String authorRole;
  final String date;
  final int likes;
  final String caption;
  final String? operatorId;
  final String? authorAvatarUrl;
}

class DroneFeedSection extends ConsumerStatefulWidget {
  const DroneFeedSection({super.key});

  @override
  ConsumerState<DroneFeedSection> createState() => _DroneFeedSectionState();
}

class _DroneFeedSectionState extends ConsumerState<DroneFeedSection> {
  int _visibleCount = 9;
  List<_FeedPost>? _remoteFeed;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final posts = await ref.read(feedViewModelProvider).fetchPosts();
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
                    operatorId: post.operatorId,
                    authorAvatarUrl: post.authorAvatarUrl,
                  ),
                )
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_remoteFeed == null) {
      return const _FeedPageShell(
        child: Center(child: CircularProgressIndicator(color: _navy)),
      );
    }
    final actualFeed = _remoteFeed!;
    if (actualFeed.isEmpty) {
      return const _FeedPageShell(
        child: Text('아직 공개된 피드가 없습니다.', style: FeedText.body),
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children:
                    visibleItems
                        .map(
                          (item) => _FeedTimelineCard(
                            post: item,
                            onTap: () => _openPostDialog(context, item),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          if (hasMore) ...<Widget>[
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    final nextCount = _visibleCount + 9;
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
                  child: Text(
                    widget.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FeedText.feedLocation,
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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFF1F4F8),
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            initial,
                            style: FeedText.authorName.copyWith(color: _navy),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(post.authorName, style: FeedText.authorName),
                        const SizedBox(height: 2),
                        Text(
                          '${post.location} · ${post.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FeedText.authorRole,
                        ),
                      ],
                    ),
                  ),
                  _FeedCategoryChip(label: post.category),
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
                      const Icon(Icons.favorite_border_rounded, size: 25),
                      const SizedBox(width: 14),
                      const Icon(Icons.chat_bubble_outline_rounded, size: 23),
                      const Spacer(),
                      Text('${post.likes}명이 좋아함', style: FeedText.authorRole),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: FeedText.metaPill.copyWith(color: const Color(0xFF0052FF)),
      ),
    );
  }
}

class _FeedPostDialog extends StatefulWidget {
  const _FeedPostDialog({required this.post, required this.loadPilot});

  final _FeedPost post;
  final Future<DronePilot?> Function(String id) loadPilot;

  @override
  State<_FeedPostDialog> createState() => _FeedPostDialogState();
}

class _FeedPostDialogState extends State<_FeedPostDialog> {
  final TextEditingController _commentController = TextEditingController();
  final PageController _pageController = PageController();
  final List<String> _comments = <String>[];
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
    final likes = widget.post.likes + (_liked ? 1 : 0);
    final avatarUrl = widget.post.authorAvatarUrl;
    final initial = widget.post.authorName.isNotEmpty
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
                child: avatarUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontFamily: DrameTextStyles.fontFamily,
                          color: Colors.white,
                          fontSize: DrameTextStyles.bodySize,
                          fontWeight: DrameTextStyles.semiBold,
                        ),
                      )
                    : null,
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
              Text(
                '${widget.post.location}에서 진행한 ${widget.post.category} 작업입니다.',
                style: FeedText.bodyStrong,
              ),
              const SizedBox(height: 20),
              const Text('댓글', style: FeedText.dialogTitle),
              const SizedBox(height: 12),
              if (_comments.isEmpty)
                const Text('아직 댓글이 없습니다.', style: FeedText.body)
              else
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
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: FeedText.input,
                  decoration: const InputDecoration(
                    hintText: '댓글 달기...',
                    hintStyle: TextStyle(
                      fontFamily: DrameTextStyles.fontFamily,
                      color: _muted,
                      fontSize: DrameTextStyles.bodySize,
                      fontWeight: DrameTextStyles.regular,
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
        ],
      ),
    );
  }
}
