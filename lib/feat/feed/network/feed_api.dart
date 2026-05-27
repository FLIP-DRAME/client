import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPost {
  const FeedPost({
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

class FeedApi {
  FeedApi(this._client);

  final SupabaseClient _client;

  Future<List<FeedPost>> fetchPosts() async {
    final rows = await _client
        .from('feed_posts')
        .select('''
          id,
          title,
          body,
          location_label,
          created_at,
          category:service_categories(label),
          operator:operator_profiles(id, display_name, specialty, avatar_url),
          assets:feed_post_assets(url, sort_order),
          likes:feed_likes(count)
        ''')
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return rows
        .map<FeedPost>(
          (row) => _postFromRow(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<List<FeedPost>> fetchMyPosts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const <FeedPost>[];

    final rows = await _client
        .from('feed_posts')
        .select('''
          id,
          title,
          body,
          location_label,
          created_at,
          category:service_categories(label),
          operator:operator_profiles(id, display_name, specialty, avatar_url),
          assets:feed_post_assets(url, sort_order),
          likes:feed_likes(count)
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return rows
        .map<FeedPost>(
          (row) => _postFromRow(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<FeedPost> createPost({
    required String caption,
    List<int>? imageBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final operator =
        await _client
            .from('operator_profiles')
            .select('id, location_label, specialty')
            .eq('user_id', userId)
            .maybeSingle();
    final operatorId = operator?['id']?.toString();
    if (operatorId == null || operatorId.isEmpty) {
      throw StateError('운용자 등록을 먼저 완료한 뒤 피드를 등록해 주세요.');
    }

    final categoryId = await _primaryCategoryId(operatorId);
    final post =
        await _client
            .from('feed_posts')
            .insert(<String, Object?>{
              'author_id': userId,
              'operator_id': operatorId,
              'category_id': categoryId,
              'body': caption,
              'location_label': operator?['location_label'],
              'is_published': true,
            })
            .select('''
              id,
              title,
              body,
              location_label,
              created_at,
              category:service_categories(label),
              operator:operator_profiles(id, display_name, specialty, avatar_url),
              assets:feed_post_assets(url, sort_order),
              likes:feed_likes(count)
            ''')
            .single();

    if (imageBytes != null && imageBytes.isNotEmpty) {
      await _client.from('feed_post_assets').insert(<String, Object?>{
        'post_id': post['id'],
        'kind': 'image',
        'url': 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
      });
    }

    final rows = await _client
        .from('feed_posts')
        .select('''
          id,
          title,
          body,
          location_label,
          created_at,
          category:service_categories(label),
          operator:operator_profiles(id, display_name, specialty, avatar_url),
          assets:feed_post_assets(url, sort_order),
          likes:feed_likes(count)
        ''')
        .eq('id', post['id'])
        .limit(1);
    return _postFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<void> deletePost(String id) async {
    await _client.from('feed_posts').delete().eq('id', id);
  }

  Future<String?> _primaryCategoryId(String operatorId) async {
    final rows = await _client
        .from('operator_categories')
        .select('category_id')
        .eq('operator_id', operatorId)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first['category_id']?.toString();
  }

  FeedPost _postFromRow(Map<String, dynamic> map) {
    final assets = List<Object?>.from(map['assets'] as List? ?? const []);
    final images =
        assets
            .whereType<Map>()
            .map((asset) => (asset['url'] ?? '').toString())
            .where((url) => url.isNotEmpty)
            .toList();
    final operator = map['operator'] as Map?;
    final likes = List<Object?>.from(map['likes'] as List? ?? const []);
    return FeedPost(
      id: map['id'].toString(),
      location: (map['location_label'] ?? '지역 미정').toString(),
      category: ((map['category'] as Map?)?['label'] ?? '드론 작업').toString(),
      images: images,
      authorName: (operator?['display_name'] ?? '모드 운용자').toString(),
      authorRole: (operator?['specialty'] ?? '드론 운용자').toString(),
      date: _dateOnly(map['created_at']),
      likes:
          likes.isEmpty
              ? 0
              : ((likes.first as Map?)?['count'] as num?)?.toInt() ?? 0,
      caption: (map['body'] ?? map['title'] ?? '').toString(),
      operatorId: operator?['id']?.toString(),
      authorAvatarUrl:
          (operator?['avatar_url']?.toString().trim().isEmpty ?? true)
              ? null
              : operator?['avatar_url']?.toString(),
    );
  }

  String _dateOnly(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';
    return '${parsed.year}.${parsed.month.toString().padLeft(2, '0')}.${parsed.day.toString().padLeft(2, '0')}';
  }
}
