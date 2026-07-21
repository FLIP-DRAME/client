import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/chat_model.dart';

class ChatApi {
  ChatApi(this._client);

  final SupabaseClient _client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('로그인이 필요합니다.');
    return uid;
  }

  /// Finds or creates the chat room for the given job_request.
  /// Fetches client_id and operator user_id from the job_request itself,
  /// so this works whether the caller is the client or the operator.
  Future<String> getOrCreateRoom(String jobRequestId) async {
    final existing =
        await _client
            .from('chat_rooms')
            .select('id')
            .eq('job_request_id', jobRequestId)
            .maybeSingle();

    if (existing != null) return existing['id'].toString();

    final jobRow =
        await _client
            .from('job_requests')
            .select('client_id, preferred_operator_id')
            .eq('id', jobRequestId)
            .single();

    final clientUserId = jobRow['client_id'].toString();
    final preferredOperatorId = jobRow['preferred_operator_id']?.toString();

    String operatorUserId;
    if (preferredOperatorId != null && preferredOperatorId.isNotEmpty) {
      final opRow =
          await _client
              .from('operator_profiles')
              .select('user_id')
              .eq('id', preferredOperatorId)
              .single();
      operatorUserId = opRow['user_id'].toString();
    } else {
      // Broadcast (map-posted) job_requests never get preferred_operator_id
      // filled in, even once a quote is accepted, so it can't be used to
      // find the operator here. The client side only shows the chat button
      // once it has a resolved pilotId (see my_quotes_component.dart), so
      // whoever reaches this branch signed in as the operator themselves.
      final currentUserId = _uid;
      if (currentUserId == clientUserId) {
        throw StateError('상대 운용자를 확인할 수 없습니다.');
      }
      operatorUserId = currentUserId;
    }

    final row =
        await _client
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
          (rows) =>
              rows
                  .map(
                    (r) => ChatMessage.fromJson(Map<String, dynamic>.from(r)),
                  )
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

    Future<ChatRoom?> buildRoom(Map<dynamic, dynamic> row) async {
      final map = Map<String, dynamic>.from(row);
      final roomId = map['id'].toString();
      final clientId = map['client_id'].toString();
      final operatorId = map['operator_id'].toString();
      final isClient = userId == clientId;
      final otherPartyUserId = isClient ? operatorId : clientId;
      final jobRequestId = map['job_request_id'].toString();

      final results = await Future.wait(<Future<dynamic>>[
        _client
            .from('profiles')
            .select('nickname, name')
            .eq('id', otherPartyUserId)
            .limit(1)
            .catchError((Object e) => <dynamic>[]),
        _client
            .from('operator_profiles')
            .select('display_name, business_name, avatar_url')
            .eq('user_id', otherPartyUserId)
            .limit(1)
            .catchError((Object e) => <dynamic>[]),
        _client
            .from('job_requests')
            .select('title, service_categories(label)')
            .eq('id', jobRequestId)
            .limit(1)
            .catchError((Object e) => <dynamic>[]),
        _client
            .from('chat_messages')
            .select('content')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .limit(1)
            .catchError((Object e) => <dynamic>[]),
        _client
            .from('chat_messages')
            .select('id')
            .eq('room_id', roomId)
            .eq('is_read', false)
            .neq('sender_id', userId)
            .catchError((Object e) => <dynamic>[]),
      ]);

      final pRows = results[0] as List<dynamic>;
      final opRows = results[1] as List<dynamic>;
      final jRows = results[2] as List<dynamic>;
      final mRows = results[3] as List<dynamic>;
      final uRows = results[4] as List<dynamic>;

      String otherPartyName = '';
      String? otherPartyAvatarUrl;

      if (pRows.isNotEmpty) {
        final p = Map<String, dynamic>.from(pRows.first as Map);
        final n = p['nickname']?.toString().trim() ?? '';
        final nm = p['name']?.toString().trim() ?? '';
        otherPartyName = n.isNotEmpty ? n : nm;
      }

      if (otherPartyName.isEmpty && opRows.isNotEmpty) {
        final op = Map<String, dynamic>.from(opRows.first as Map);
        final d = op['display_name']?.toString().trim() ?? '';
        final b = op['business_name']?.toString().trim() ?? '';
        otherPartyName = d.isNotEmpty ? d : b;
        final av = op['avatar_url']?.toString().trim() ?? '';
        if (av.isNotEmpty) otherPartyAvatarUrl = av;
      }

      if (otherPartyName.isEmpty) otherPartyName = '상대방';

      String category = '작업';
      if (jRows.isNotEmpty) {
        final j = Map<String, dynamic>.from(jRows.first as Map);
        category =
            ((j['service_categories'] as Map?)?['label'] ??
                    j['title'] ??
                    '작업')
                .toString();
      }

      final lastMsg =
          mRows.isNotEmpty ? (mRows.first as Map)['content']?.toString() : null;
      final unread = uRows.length;

      return ChatRoom(
        id: roomId,
        jobRequestId: jobRequestId,
        clientId: clientId,
        operatorId: operatorId,
        lastMessageAt:
            map['last_message_at'] != null
                ? DateTime.parse(map['last_message_at'].toString()).toLocal()
                : DateTime.fromMillisecondsSinceEpoch(0),
        lastMessage: lastMsg,
        unreadCount: unread,
        otherPartyName: otherPartyName,
        category: category,
        otherPartyAvatarUrl: otherPartyAvatarUrl,
      );
    }

    final rooms = await Future.wait(
      rows.map((row) => buildRoom(row as Map<dynamic, dynamic>)),
    );
    return rooms.whereType<ChatRoom>().toList();
  }

  Future<int> fetchUnreadCount() async {
    if (_client.auth.currentUser == null) return 0;
    final userId = _uid;
    try {
      final roomRows = await _client
          .from('chat_rooms')
          .select('id')
          .or('client_id.eq.$userId,operator_id.eq.$userId');
      if (roomRows.isEmpty) return 0;
      final roomIds = roomRows.map((r) => r['id'].toString()).toList();
      final result = await _client
          .from('chat_messages')
          .select('id')
          .inFilter('room_id', roomIds)
          .eq('is_read', false)
          .neq('sender_id', userId);
      return result.length;
    } catch (e, st) {
      debugPrint('[ChatApi] fetchUnreadCount 실패: $e\n$st');
      return 0;
    }
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
