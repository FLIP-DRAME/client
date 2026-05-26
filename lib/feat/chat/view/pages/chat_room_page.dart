import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_text_styles.dart';
import '../../model/chat_model.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.otherPartyName,
    this.category = '',
  });

  final String roomId;
  final String otherPartyName;
  final String category;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final TextEditingController _inputController = TextEditingController();
  StreamSubscription<List<ChatMessage>>? _sub;
  List<ChatMessage> _messages = <ChatMessage>[];
  bool _sending = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    final vm = ref.read(chatViewModelProvider);
    vm.markRead(widget.roomId);
    _sub = vm.messageStream(widget.roomId).listen((msgs) {
      if (!mounted) return;
      // 확정된 메시지와 내용+발신자가 같은 temp 제거 (중복 방지)
      // 스트림은 내림차순(최신→오래된)이므로 temp도 앞에 추가
      final confirmedKeys =
          msgs.map((m) => '${m.senderId}_${m.content}').toSet();
      final pendingTemps = _messages
          .where((m) =>
              m.id.startsWith('temp_') &&
              !confirmedKeys.contains('${m.senderId}_${m.content}'))
          .toList();
      setState(() => _messages = [...pendingTemps, ...msgs]);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _inputController.clear();

    // 낙관적 업데이트 — 내림차순 리스트이므로 맨 앞에 추가
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      roomId: widget.roomId,
      senderId: _currentUserId,
      content: text,
      isRead: false,
      createdAt: DateTime.now(),
    );
    setState(() => _messages = [tempMsg, ..._messages]);

    try {
      await ref.read(chatViewModelProvider).sendMessage(
            roomId: widget.roomId,
            content: text,
          );
    } catch (e) {
      // 전송 실패 시 낙관적 메시지 제거 후 입력 복원
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != tempId).toList();
          _inputController.text = text;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전송 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.otherPartyName,
              style: const TextStyle(
                fontFamily: DrameTextStyles.fontFamily,
                fontSize: DrameTextStyles.itemTitleSize,
                fontWeight: DrameTextStyles.semiBold,
                color: DC.ink,
              ),
            ),
            if (widget.category.isNotEmpty)
              Text(
                widget.category,
                style: const TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: DrameTextStyles.labelSize,
                  fontWeight: DrameTextStyles.regular,
                  color: DC.muted,
                ),
              ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      '첫 메시지를 보내보세요',
                      style: TextStyle(
                        fontFamily: DrameTextStyles.fontFamily,
                        fontSize: DrameTextStyles.bodySize,
                        color: DC.muted,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DC.spBase,
                      vertical: DC.spBase,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = msg.senderId == _currentUserId;
                      final isLastOfDay = index == _messages.length - 1 ||
                          !_isSameDay(
                            msg.createdAt,
                            _messages[index + 1].createdAt,
                          );
                      final isFirstFromSender = index == _messages.length - 1 ||
                          _messages[index + 1].senderId != msg.senderId;
                      // 내가 보낸 메시지 중 가장 최근에 읽힌 것에만 '읽음' 표시
                      final readReceiptIndex = _messages.indexWhere(
                        (m) =>
                            m.senderId == _currentUserId &&
                            m.isRead &&
                            !m.id.startsWith('temp_'),
                      );
                      final showRead =
                          isMine && readReceiptIndex == index;
                      return Column(
                        children: <Widget>[
                          if (isLastOfDay) _DateDivider(date: msg.createdAt),
                          _MessageBubble(
                            message: msg,
                            isMine: isMine,
                            showRead: showRead,
                            senderName: (!isMine && isFirstFromSender)
                                ? widget.otherPartyName
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _InputBar(
            controller: _inputController,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showRead = false,
    this.senderName,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showRead;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isMine) const SizedBox(width: DC.spXxs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (senderName != null) ...<Widget>[
                  Text(
                    senderName!,
                    style: const TextStyle(
                      fontFamily: DrameTextStyles.fontFamily,
                      fontSize: 11,
                      fontWeight: DrameTextStyles.semiBold,
                      color: DC.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DC.spSm,
                    vertical: DC.spXs,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? DC.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(DC.rxMd),
                      topRight: const Radius.circular(DC.rxMd),
                      bottomLeft: Radius.circular(isMine ? DC.rxMd : DC.rxXs),
                      bottomRight: Radius.circular(isMine ? DC.rxXs : DC.rxMd),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: DrameTextStyles.fontFamily,
                      fontSize: DrameTextStyles.bodySize,
                      fontWeight: DrameTextStyles.regular,
                      color: isMine ? Colors.white : DC.ink,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DC.spXxs),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (showRead)
                const Text(
                  '읽음',
                  style: TextStyle(
                    fontFamily: DrameTextStyles.fontFamily,
                    fontSize: 10,
                    color: DC.primary,
                  ),
                ),
              Text(
                _timeLabel(message.createdAt),
                style: const TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: 11,
                  color: DC.mutedSoft,
                ),
              ),
            ],
          ),
          if (isMine) const SizedBox(width: DC.spXxs),
        ],
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h < 12 ? '오전' : '오후';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$ampm $hour:$m';
  }
}

// ─── Date Divider ────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DC.spSm),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider(color: DC.hairline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DC.spXs),
            child: Text(
              '${date.year}년 ${date.month}월 ${date.day}일',
              style: const TextStyle(
                fontFamily: DrameTextStyles.fontFamily,
                fontSize: 11,
                color: DC.muted,
              ),
            ),
          ),
          const Expanded(child: Divider(color: DC.hairline)),
        ],
      ),
    );
  }
}

// ─── Input Bar ───────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DC.hairline)),
      ),
      padding: EdgeInsets.only(
        left: DC.spBase,
        right: DC.spXs,
        top: DC.spXs,
        bottom: DC.spXs + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontFamily: DrameTextStyles.fontFamily,
                  fontSize: DrameTextStyles.bodySize,
                  color: DC.ink,
                ),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: const TextStyle(
                    fontFamily: DrameTextStyles.fontFamily,
                    fontSize: DrameTextStyles.bodySize,
                    color: DC.mutedSoft,
                  ),
                  filled: true,
                  fillColor: DC.surfaceSoft,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DC.spSm,
                    vertical: DC.spXs,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DC.rxPill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: DC.spXs),
            _SendButton(sending: sending, onTap: onSend),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.sending, required this.onTap});

  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sending ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: sending ? DC.primaryDisabled : DC.primary,
          shape: BoxShape.circle,
        ),
        child: sending
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 20),
      ),
    );
  }
}
