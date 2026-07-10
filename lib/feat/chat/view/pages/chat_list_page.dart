import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_text_styles.dart';
import '../../model/chat_model.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  List<ChatRoom> _rooms = <ChatRoom>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rooms = await ref.read(chatViewModelProvider).fetchRooms();
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final blockedIds =
          await ref.read(moderationApiProvider).fetchBlockedUserIds();
      final visibleRooms =
          blockedIds.isEmpty
              ? rooms
              : rooms.where((room) {
                final otherPartyUserId =
                    currentUserId == room.clientId
                        ? room.operatorId
                        : room.clientId;
                return !blockedIds.contains(otherPartyUserId);
              }).toList();
      if (mounted) setState(() => _rooms = visibleRooms);
      await ref.read(drameStoreProvider).refreshChatUnreadCount();
    } on AuthException {
      // 비로그인 상태에서는 채팅 목록을 불러올 수 없음
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DC.surfaceSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: DC.ink,
            size: 20,
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          '채팅',
          style: TextStyle(
            fontFamily: DrameTextStyles.fontFamily,
            fontSize: DrameTextStyles.itemTitleSize,
            fontWeight: DrameTextStyles.semiBold,
            color: DC.ink,
          ),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _rooms.isEmpty
              ? _EmptyState(onRefresh: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: DC.spXs),
                  itemCount: _rooms.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(height: 1, color: DC.hairlineSoft),
                  itemBuilder: (context, index) {
                    return _ChatRoomTile(
                      room: _rooms[index],
                      onTap: () async {
                        final room = _rooms[index];
                        final currentUserId =
                            Supabase.instance.client.auth.currentUser?.id;
                        final otherPartyUserId =
                            currentUserId == room.clientId
                                ? room.operatorId
                                : room.clientId;
                        await context.push(
                          '/chat/${room.id}',
                          extra: <String, String>{
                            'otherPartyName': room.otherPartyName,
                            'category': room.category,
                            'otherPartyUserId': otherPartyUserId,
                          },
                        );
                        if (mounted) _load();
                      },
                    );
                  },
                ),
              ),
    );
  }
}

// ─── Room Tile ───────────────────────────────────────────────────────────────

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: DC.spBase,
          vertical: DC.spSm,
        ),
        child: Row(
          children: <Widget>[
            _Avatar(
              name: room.otherPartyName,
              avatarUrl: room.otherPartyAvatarUrl,
            ),
            const SizedBox(width: DC.spSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          room.otherPartyName,
                          style: TextStyle(
                            fontFamily: DrameTextStyles.fontFamily,
                            fontSize: DrameTextStyles.bodySize,
                            fontWeight:
                                hasUnread
                                    ? DrameTextStyles.semiBold
                                    : DrameTextStyles.medium,
                            color: DC.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeLabel(room.lastMessageAt),
                        style: TextStyle(
                          fontFamily: DrameTextStyles.fontFamily,
                          fontSize: 11,
                          color: hasUnread ? DC.primary : DC.mutedSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '요청: ${room.category}',
                    style: const TextStyle(
                      fontFamily: DrameTextStyles.fontFamily,
                      fontSize: 11,
                      fontWeight: DrameTextStyles.medium,
                      color: DC.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          room.lastMessage ?? room.category,
                          style: TextStyle(
                            fontFamily: DrameTextStyles.fontFamily,
                            fontSize: DrameTextStyles.labelSize,
                            fontWeight:
                                hasUnread
                                    ? DrameTextStyles.medium
                                    : DrameTextStyles.regular,
                            color: hasUnread ? DC.body : DC.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: DC.primary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(DC.rxPill),
                            ),
                          ),
                          child: Text(
                            room.unreadCount > 99
                                ? '99+'
                                : room.unreadCount.toString(),
                            style: const TextStyle(
                              fontFamily: DrameTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: DrameTextStyles.semiBold,
                              color: Colors.white,
                            ),
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
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = h < 12 ? '오전' : '오후';
      final hour = h % 12 == 0 ? 12 : h % 12;
      return '$ampm $hour:$m';
    }
    return '${dt.month}/${dt.day}';
  }
}

// ─── Avatar ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: DC.surfaceStrong,
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: DC.surfaceStrong,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: DrameTextStyles.fontFamily,
          fontSize: DrameTextStyles.bodySize,
          fontWeight: DrameTextStyles.semiBold,
          color: DC.body,
        ),
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DC.spBase),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: DC.mutedSoft,
            ),
            const SizedBox(height: DC.spSm),
            Text(
              '채팅 목록을 불러오지 못했습니다',
              style: const TextStyle(
                fontFamily: DrameTextStyles.fontFamily,
                fontSize: DrameTextStyles.bodySize,
                color: DC.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DC.spXs),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: DC.mutedSoft,
          ),
          const SizedBox(height: DC.spSm),
          const Text(
            '아직 채팅이 없습니다',
            style: TextStyle(
              fontFamily: DrameTextStyles.fontFamily,
              fontSize: DrameTextStyles.bodySize,
              color: DC.muted,
            ),
          ),
          const SizedBox(height: DC.spXs),
          TextButton(onPressed: onRefresh, child: const Text('새로고침')),
        ],
      ),
    );
  }
}
