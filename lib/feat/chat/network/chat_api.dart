import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/chat_model.dart';

class ChatApi {
  ChatApi(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// Finds or creates the chat room for the given job_request.
  /// Fetches client_id and operator user_id from the job_request itself,
  /// so this works whether the caller is the client or the operator.
  Future<String> getOrCreateRoom(String jobRequestId) async {
    final existing = await _client
        .from('chat_rooms')
        .select('id')
        .eq('job_request_id', jobRequestId)
        .maybeSingle();

    if (existing != null) return existing['id'].toString();

    final jobRow = await _client
        .from('job_requests')
        .select('client_id, preferred_operator_id')
        .eq('id', jobRequestId)
        .single();

    final clientUserId = jobRow['client_id'].toString();
    final operatorProfileId = jobRow['preferred_operator_id'].toString();

    final opRow = await _client
        .from('operator_profiles')
        .select('user_id')
        .eq('id', operatorProfileId)
        .single();
    final operatorUserId = opRow['user_id'].toString();

    final row = await _client
        .from('chat_rooms')
        .insert(<String, Object?>{
          'job_request_id': jobRequestId,
          'client_id': clientUserId,
          'operator_id': operatorUserId,
        })
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
  }) async {
    await _client.from('chat_messages').insert(<String, Object?>{
      'room_id': roomId,
      'sender_id': _uid,
      'content': content.trim(),
    });
  }

  Stream<List<ChatMessage>> messageStream(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: <String>['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map((r) => ChatMessage.fromJson(Map<String, dynamic>.from(r)))
              .toList(),
        );
  }

  Future<List<ChatRoom>> fetchRooms() async {
    if (_client.auth.currentUser == null) return <ChatRoom>[];
    final userId = _uid;
    final rows = await _client
        .from('chat_rooms')
        .select('id, job_request_id, client_id, operator_id, last_message_at')
        .or('client_id.eq.$userId,operator_id.eq.$userId')
        .order('last_message_at', ascending: false);

    final List<ChatRoom> result = <ChatRoom>[];
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      final roomId = map['id'].toString();
      final clientId = map['client_id'].toString();
      final operatorId = map['operator_id'].toString();
      final isClient = userId == clientId;
      final otherPartyUserId = isClient ? operatorId : clientId;

      String otherPartyName = '';
      String? otherPartyAvatarUrl;
      try {
        final pRows = await _client
            .from('profiles')
            .select('nickname, name')
            .eq('id', otherPartyUserId)
            .limit(1);
        if (pRows.isNotEmpty) {
          final p = Map<String, dynamic>.from(pRows.first as Map);
          final n = p['nickname']?.toString().trim() ?? '';
          final nm = p['name']?.toString().trim() ?? '';
          otherPartyName = n.isNotEmpty ? n : nm;
        }
      } catch (_) {}

      if (otherPartyName.isEmpty) {
        try {
          final opRows = await _client
              .from('operator_profiles')
              .select('display_name, business_name, avatar_url')
              .eq('user_id', otherPartyUserId)
              .limit(1);
          if (opRows.isNotEmpty) {
            final op = Map<String, dynamic>.from(opRows.first as Map);
            final d = op['display_name']?.toString().trim() ?? '';
            final b = op['business_name']?.toString().trim() ?? '';
            otherPartyName = d.isNotEmpty ? d : b;
            final av = op['avatar_url']?.toString().trim() ?? '';
            if (av.isNotEmpty) otherPartyAvatarUrl = av;
          }
        } catch (_) {}
      }

      if (otherPartyName.isEmpty) otherPartyName = '상대방';

      String category = '작업';
      try {
        final jRows = await _client
            .from('job_requests')
            .select('title, service_categories(label)')
            .eq('id', map['job_request_id'].toString())
            .limit(1);
        if (jRows.isNotEmpty) {
          final j = Map<String, dynamic>.from(jRows.first as Map);
          category =
              ((j['service_categories'] as Map?)?['label'] ?? j['title'] ?? '작업')
                  .toString();
        }
      } catch (_) {}

      String? lastMsg;
      try {
        final mRows = await _client
            .from('chat_messages')
            .select('content')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .limit(1);
        if (mRows.isNotEmpty) {
          lastMsg = (mRows.first as Map)['content']?.toString();
        }
      } catch (_) {}

      int unread = 0;
      try {
        final uRows = await _client
            .from('chat_messages')
            .select('id')
            .eq('room_id', roomId)
            .eq('is_read', false)
            .neq('sender_id', userId);
        unread = uRows.length;
      } catch (_) {}

      result.add(ChatRoom(
        id: roomId,
        jobRequestId: map['job_request_id'].toString(),
        clientId: clientId,
        operatorId: operatorId,
        lastMessageAt:
            DateTime.parse(map['last_message_at'].toString()).toLocal(),
        lastMessage: lastMsg,
        unreadCount: unread,
        otherPartyName: otherPartyName,
        category: category,
        otherPartyAvatarUrl: otherPartyAvatarUrl,
      ));
    }
    return result;
  }

  Future<void> markRead(String roomId) async {
    try {
      await _client
          .from('chat_messages')
          .update(<String, Object?>{'is_read': true})
          .eq('room_id', roomId)
          .neq('sender_id', _uid)
          .eq('is_read', false);
    } on PostgrestException {
      return;
    }
  }
}
