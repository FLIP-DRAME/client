import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
import '../../../main/model/drone_pilot_model.dart';
import '../../../moderation/model/moderation_model.dart';
import '../../../moderation/view/component/report_block_menu.dart';
import '../../network/feed_api.dart';

part '../component/feed_component.dart';

const _navy = Color(0xFF0A0B0D);
const _ink = Color(0xFF0A0B0D);
const _muted = Color(0xFF7C828A);
const _soft = Color(0xFFF7F8FA);
// Matches DC.mapHairline exactly; kept as a private alias (rather than
// deleted per the usual migration rule) because feed_component.dart — a
// `part of` this library that this migration pass doesn't touch — references
// `_line` directly.
const _line = DC.mapHairline;

class FeedText {
  static const TextStyle eyebrow = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _navy,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.6,
  );

  static const TextStyle feedLocation = TextStyle(
    fontFamily: DT.fontFamily,
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle button = TextStyle(
    fontFamily: DT.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle authorName = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle authorRole = TextStyle(
    fontFamily: DT.fontFamily,
    color: _muted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.55,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle metaPill = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle likeCount = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle comment = TextStyle(
    fontFamily: DT.fontFamily,
    color: _ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle commentUser = TextStyle(
    fontFamily: DT.fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle input = TextStyle(
    fontFamily: DT.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
}

void _openPortfolio(BuildContext context, DronePilot pilot) {
  context.push('/portfolio/${pilot.id}', extra: pilot);
}

Future<void> showFeedPostDialog(
  BuildContext context,
  FeedPost post, {
  required Future<DronePilot?> Function(String id) loadPilot,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (_) => _FeedPostDialog(
      post: _FeedPost.fromApi(post),
      loadPilot: loadPilot,
    ),
  );
}

/// 피드 상세 페이지 (URL로 직접 접근 가능: /feed/:id)
class FeedDetailPage extends ConsumerStatefulWidget {
  const FeedDetailPage({super.key, required this.postId, this.post});

  final String postId;
  final FeedPost? post;

  @override
  ConsumerState<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends ConsumerState<FeedDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final PageController _pageController = PageController();
  FeedPost? _post;
  List<FeedComment> _comments = <FeedComment>[];
  bool _liked = false;
  int _likeCount = 0;
  int _imageIndex = 0;
  bool _loading = true;
  bool _loadingComments = true;
  bool _submittingComment = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_post != null) {
      _likeCount = _post!.likes;
      _loading = false;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ref.read(feedApiProvider);
      if (_post == null) {
        final post = await api.fetchPostById(widget.postId);
        if (post == null) {
          if (!mounted) return;
          setState(() {
            _error = '게시글을 찾을 수 없습니다.';
            _loading = false;
          });
          return;
        }
        if (!mounted) return;
        setState(() {
          _post = post;
          _likeCount = post.likes;
          _loading = false;
        });
      }
      final liked = await api.hasLiked(widget.postId);
      final comments = await api.fetchComments(widget.postId);
      final likeCount = await api.fetchLikeCount(widget.postId);
      if (!mounted) return;
      setState(() {
        _liked = liked;
        _comments = comments;
        _likeCount = likeCount;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '게시글을 불러오지 못했습니다.';
        _loading = false;
      });
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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _navy)),
      );
    }
    if (_error != null || _post == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_error ?? '게시글을 찾을 수 없습니다.'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/feed'),
                child: const Text('피드로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final post = _post!;
    final avatarUrl = post.authorAvatarUrl;
    final initial =
        post.authorName.isNotEmpty ? post.authorName.substring(0, 1) : '모';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Text(
          '게시글',
          style: TextStyle(
            fontFamily: DT.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          const Divider(height: 1, color: _line),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 제목 영역
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          post.caption.isNotEmpty
                              ? post.caption
                              : '${post.location} ${post.category}',
                          style: const TextStyle(
                            fontFamily: DT.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                      // 작성자 정보 + 날짜
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: _navy,
                              backgroundImage:
                                  avatarUrl != null
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              child:
                                  avatarUrl == null
                                      ? Text(
                                        initial,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                      fontFamily: DT.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${post.date} · ${post.location}',
                                    style: const TextStyle(
                                      fontFamily: DT.fontFamily,
                                      fontSize: 13,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 카테고리 칩
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                post.category,
                                style: const TextStyle(
                                  fontFamily: DT.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DC.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            ReportBlockMenuButton(
                              reportTargetType: ReportTargetType.feedPost,
                              reportTargetId: post.id,
                              targetUserId:
                                  post.authorId.isEmpty ? null : post.authorId,
                              targetUserName: post.authorName,
                              isOwnContent:
                                  post.authorId.isNotEmpty &&
                                  post.authorId ==
                                      Supabase.instance.client.auth.currentUser?.id,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: _line),
                      // 본문 내용
                      if (post.caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Text(
                            post.caption,
                            style: const TextStyle(
                              fontFamily: DT.fontFamily,
                              fontSize: 15,
                              color: _ink,
                              height: 1.7,
                            ),
                          ),
                        ),
                      // 이미지 갤러리
                      if (post.images.isNotEmpty) ...<Widget>[
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              PageView.builder(
                                controller: _pageController,
                                itemCount: post.images.length,
                                onPageChanged: (index) {
                                  setState(() => _imageIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    post.images[index],
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const _FeedEmptyCover(),
                                  );
                                },
                              ),
                              // 네비게이션 버튼
                              if (post.images.length > 1) ...<Widget>[
                                Positioned(
                                  left: 12,
                                  top: 0,
                                  bottom: 0,
                                  child: _ImageNavButton(
                                    icon: Icons.chevron_left_rounded,
                                    onTap:
                                        _imageIndex == 0
                                            ? null
                                            : () => _jumpImage(_imageIndex - 1),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 0,
                                  bottom: 0,
                                  child: _ImageNavButton(
                                    icon: Icons.chevron_right_rounded,
                                    onTap:
                                        _imageIndex == post.images.length - 1
                                            ? null
                                            : () => _jumpImage(_imageIndex + 1),
                                  ),
                                ),
                                // 인디케이터
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_imageIndex + 1} / ${post.images.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 썸네일 (3장 이상일 때)
                        if (post.images.length > 2)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: post.images.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final selected = index == _imageIndex;
                                  return GestureDetector(
                                    onTap: () => _jumpImage(index),
                                    child: Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color:
                                              selected
                                                  ? DC.primary
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          post.images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                      // 포트폴리오 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                post.operatorId == null
                                    ? null
                                    : () async {
                                      final pilot = await ref
                                          .read(dronePilotApiProvider)
                                          .fetchPilotById(post.operatorId!);
                                      if (!mounted || pilot == null) return;
                                      _openPortfolio(context, pilot);
                                    },
                            icon: const Icon(Icons.grid_view_rounded, size: 18),
                            label: const Text('운용자 포트폴리오 보기'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _navy,
                              side: const BorderSide(color: _line),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                fontFamily: DT.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: _line),
                      // 좋아요 + 댓글 수
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final api = ref.read(feedApiProvider);
                                  final nowLiked = await api.toggleLike(post.id);
                                  if (!mounted) return;
                                  setState(() {
                                    _liked = nowLiked;
                                    _likeCount += nowLiked ? 1 : -1;
                                  });
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('좋아요 오류: $e')),
                                  );
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    _liked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color:
                                        _liked
                                            ? const Color(0xFFE54866)
                                            : _muted,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '좋아요 $_likeCount',
                                    style: TextStyle(
                                      fontFamily: DT.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          _liked
                                              ? const Color(0xFFE54866)
                                              : _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: _muted,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '댓글 ${_comments.length}',
                                  style: const TextStyle(
                                    fontFamily: DT.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: _line),
                      // 댓글 섹션
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: <Widget>[
                            const Text(
                              '댓글',
                              style: TextStyle(
                                fontFamily: DT.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_comments.length}',
                              style: const TextStyle(
                                fontFamily: DT.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: DC.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loadingComments)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _soft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                '첫 번째 댓글을 남겨보세요!',
                                style: TextStyle(
                                  fontFamily: DT.fontFamily,
                                  fontSize: 14,
                                  color: _muted,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            children:
                                _comments
                                    .map((c) => _CommentTile(comment: c))
                                    .toList(),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 댓글 입력
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: _soft,
              border: Border(top: BorderSide(color: _line)),
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _line),
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(
                              fontFamily: DT.fontFamily,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: '댓글을 입력하세요...',
                              hintStyle: TextStyle(
                                fontFamily: DT.fontFamily,
                                color: _muted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 38,
                        child: FilledButton(
                          onPressed: _submittingComment ? null : _submitComment,
                          style: FilledButton.styleFrom(
                            backgroundColor: _navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child:
                              _submittingComment
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    '등록',
                                    style: TextStyle(
                                      fontFamily: DT.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      await api.addComment(widget.postId, text);
      final updated = await api.fetchComments(widget.postId);
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
