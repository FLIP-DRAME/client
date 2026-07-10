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

    // profiles RLS only exposes a user's own row (same reason chat_api.dart
    // falls back to a placeholder name for the other party) -- looking up
    // someone else's nickname/name here will silently come back empty, not
    // as an error. Every blocked id still gets an entry so a resolved-name
    // failure never hides a real block from the management screen.
    final names = <String, String>{};
    try {
      final rows = await _client
          .from('profiles')
          .select('id, nickname, name')
          .inFilter('id', ids.toList());
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        final nickname = (map['nickname'] ?? '').toString().trim();
        final name = (map['name'] ?? '').toString().trim();
        final resolved = nickname.isNotEmpty ? nickname : name;
        if (resolved.isNotEmpty) names[map['id'].toString()] = resolved;
      }
    } catch (_) {
      // Fall through to id-only display below.
    }

    return ids
        .map(
          (id) => BlockedUser(
            userId: id,
            displayName: names[id] ?? '사용자 ${id.substring(0, 8)}',
          ),
        )
        .toList();
  }
}
