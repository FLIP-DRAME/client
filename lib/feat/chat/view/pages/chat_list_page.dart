import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
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
        title: const ModeSemiBoldText('채팅', size: 17, color: DC.ink),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ModeEmptyState(
                icon: Icons.error_outline_rounded,
                title: '채팅 목록을 불러오지 못했습니다',
                actionLabel: '다시 시도',
                onAction: _load,
              )
              : _rooms.isEmpty
              ? ModeEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: '아직 채팅이 없습니다',
                actionLabel: '새로고침',
                onAction: _load,
              )
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
            ModeAvatar(
              imageUrl: room.otherPartyAvatarUrl,
              radius: 24,
              fallbackText: room.otherPartyName,
            ),
            const SizedBox(width: DC.spSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ModeText(
                          room.otherPartyName,
                          size: 14,
                          weight:
                              hasUnread ? FontWeight.w600 : FontWeight.w500,
                          color: DC.ink,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ModeText(
                        _timeLabel(room.lastMessageAt),
                        size: 11,
                        color: hasUnread ? DC.primary : DC.mutedSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ModeMediumText(
                    '요청: ${room.category}',
                    size: 11,
                    color: DC.primary,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ModeText(
                          room.lastMessage ?? room.category,
                          size: 13,
                          weight:
                              hasUnread ? FontWeight.w500 : FontWeight.w400,
                          color: hasUnread ? DC.body : DC.muted,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        ModeChip(
                          label:
                              room.unreadCount > 99
                                  ? '99+'
                                  : room.unreadCount.toString(),
                          background: DC.primary,
                          foreground: Colors.white,
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

