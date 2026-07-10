import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/moderation_model.dart';

class ModerationApi {
  ModerationApi(this._client);

  final SupabaseClient _client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('로그인이 필요합니다.');
    return uid;
  }

  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String detail = '',
  }) async {
    await _client.from('content_reports').insert(<String, Object?>{
      'reporter_id': _uid,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'detail': detail.trim(),
    });
  }

  Future<void> blockUser(String userId) async {
    await _client.from('user_blocks').insert(<String, Object?>{
      'blocker_id': _uid,
      'blocked_id': userId,
    });
  }

  Future<void> unblockUser(String userId) async {
    await _client
        .from('user_blocks')
        .delete()
        .eq('blocker_id', _uid)
        .eq('blocked_id', userId);
  }

  Future<Set<String>> fetchBlockedUserIds() async {
    if (_client.auth.currentUser == null) return const <String>{};
    final rows = await _client
        .from('user_blocks')
        .select('blocked_id')
        .eq('blocker_id', _uid);
    return rows.map((row) => row['blocked_id'].toString()).toSet();
  }

  Future<List<BlockedUser>> fetchBlockedUsers() async {
    final ids = await fetchBlockedUserIds();
    if (ids.isEmpty) return const <BlockedUser>[];
    final rows = await _client
        .from('profiles')
        .select('id, nickname, name')
        .inFilter('id', ids.toList());
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final nickname = (map['nickname'] ?? '').toString().trim();
      final name = (map['name'] ?? '').toString().trim();
      return BlockedUser(
        userId: map['id'].toString(),
        displayName: nickname.isNotEmpty ? nickname : (name.isNotEmpty ? name : '알 수 없음'),
      );
    }).toList();
  }
}
