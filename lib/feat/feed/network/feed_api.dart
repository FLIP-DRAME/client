import 'dart:typed_data';

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
    required this.createdAt,
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
  final DateTime createdAt;
  final int likes;
  final String caption;
  final String? operatorId;
  final String? authorAvatarUrl;
}

class FeedComment {
  const FeedComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String content;
  final DateTime createdAt;
}

class FeedApi {
  FeedApi(this._client);

  final SupabaseClient _client;

  Future<List<FeedPost>> fetchPosts({int limit = 30}) async {
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
          assets:feed_post_assets(url, sort_order)
        ''')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows
        .map<FeedPost>(
          (row) => _postFromRow(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<List<FeedPost>> fetchPostsByOperator(
    String operatorId, {
    int limit = 30,
  }) async {
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
          assets:feed_post_assets(url, sort_order)
        ''')
        .eq('operator_id', operatorId)
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(limit);

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
          assets:feed_post_assets(url, sort_order)
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return rows
        .map<FeedPost>(
          (row) => _postFromRow(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<FeedPost> createPost({
    required String caption,
    required String categoryLabel,
    required String locationLabel,
    List<int>? imageBytes,
    String? imageFileName,
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

    final categoryId =
        categoryLabel == '전체'
            ? await _primaryCategoryId(operatorId)
            : await _categoryIdByLabel(categoryLabel);
    final location =
        locationLabel == '전체'
            ? (operator?['location_label']?.toString().trim().isNotEmpty == true
                ? operator!['location_label'].toString()
                : '지역 미정')
            : locationLabel;
    final uploadedImage =
        imageBytes == null || imageBytes.isEmpty
            ? null
            : await _uploadFeedImage(userId, imageBytes, imageFileName);
    String? postId;
    try {
      final post =
          await _client
              .from('feed_posts')
              .insert(<String, Object?>{
                'author_id': userId,
                'operator_id': operatorId,
                'category_id': categoryId,
                'body': caption,
                'location_label': location,
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
                assets:feed_post_assets(url, sort_order)
              ''')
              .single();
      postId = post['id']?.toString();

      if (uploadedImage != null) {
        await _client.from('feed_post_assets').insert(<String, Object?>{
          'post_id': postId,
          'kind': 'image',
          'url': uploadedImage.url,
          'sort_order': 0,
        });
      }
    } catch (_) {
      if (uploadedImage != null) {
        await _tryRemoveUploadedFeedImage(uploadedImage.path);
      }
      rethrow;
    }
    if (postId == null) {
      throw StateError('피드 게시글을 생성하지 못했습니다.');
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
          assets:feed_post_assets(url, sort_order)
        ''')
        .eq('id', postId)
        .limit(1);
    return _postFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<void> deletePost(String id) async {
    final rows = await _client
        .from('feed_post_assets')
        .select('url')
        .eq('post_id', id);
    final paths =
        rows
            .map<String?>(
              (row) => _feedAssetPathFromUrl((row as Map)['url']?.toString()),
            )
            .whereType<String>()
            .toList();
    if (paths.isNotEmpty) {
      try {
        await _client.storage.from('feed-assets').remove(paths);
      } catch (_) {
        // Keep post deletion available even if asset cleanup fails.
      }
    }
    await _client.from('feed_posts').delete().eq('id', id);
  }

  Future<({String path, String url})> _uploadFeedImage(
    String userId,
    List<int> bytes,
    String? fileName,
  ) async {
    final type = _imageType(bytes, fileName);
    final path =
        '$userId/${DateTime.now().microsecondsSinceEpoch}.${type.extension}';
    await _client.storage
        .from('feed-assets')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: type.contentType),
        );
    return (
      path: path,
      url: _client.storage.from('feed-assets').getPublicUrl(path),
    );
  }

  Future<void> _tryRemoveUploadedFeedImage(String path) async {
    try {
      await _client.storage.from('feed-assets').remove(<String>[path]);
    } catch (_) {
      // Best-effort cleanup only. The original write error is what matters.
    }
  }

  ({String extension, String contentType}) _imageType(
    List<int> bytes,
    String? fileName,
  ) {
    final extension = _fileExtension(fileName);
    if (extension != null) {
      return (extension: extension, contentType: _contentType(extension));
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return (extension: 'webp', contentType: 'image/webp');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return (extension: 'png', contentType: 'image/png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return (extension: 'jpg', contentType: 'image/jpeg');
    }
    return (extension: 'jpg', contentType: 'image/jpeg');
  }

  String? _fileExtension(String? fileName) {
    final ext = fileName?.split('.').last.toLowerCase().trim();
    return switch (ext) {
      'jpg' || 'jpeg' => 'jpg',
      'png' => 'png',
      'webp' => 'webp',
      _ => null,
    };
  }

  String _contentType(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  String? _feedAssetPathFromUrl(String? url) {
    if (url == null || url.isEmpty || url.startsWith('data:')) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final index = uri.pathSegments.indexOf('feed-assets');
    if (index == -1 || index == uri.pathSegments.length - 1) return null;
    return uri.pathSegments.skip(index + 1).map(Uri.decodeComponent).join('/');
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

  Future<String?> _categoryIdByLabel(String label) async {
    final rows = await _client
        .from('service_categories')
        .select('id')
        .eq('label', label)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first['id']?.toString();
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
    final rawCreatedAt = map['created_at']?.toString() ?? '';
    final parsedCreatedAt =
        DateTime.tryParse(rawCreatedAt)?.toLocal() ?? DateTime.now();
    return FeedPost(
      id: map['id'].toString(),
      location: (map['location_label'] ?? '지역 미정').toString(),
      category: ((map['category'] as Map?)?['label'] ?? '드론 작업').toString(),
      images: images,
      authorName: (operator?['display_name'] ?? '모드 운용자').toString(),
      authorRole: (operator?['specialty'] ?? '드론 운용자').toString(),
      date: _dateOnly(map['created_at']),
      createdAt: parsedCreatedAt,
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

  Future<bool> hasLiked(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final rows = await _client
        .from('feed_likes')
        .select('post_id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .limit(1);
    return rows.isNotEmpty;
  }

  /// Returns true if now liked, false if unliked.
  Future<bool> toggleLike(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final already = await hasLiked(postId);
    if (already) {
      await _client
          .from('feed_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false;
    } else {
      await _client.from('feed_likes').insert(<String, Object?>{
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  Future<Set<String>> fetchMyLikedPostIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return <String>{};
    final rows = await _client
        .from('feed_likes')
        .select('post_id')
        .eq('user_id', userId);
    return rows.map<String>((r) => (r as Map)['post_id'].toString()).toSet();
  }

  Future<int> fetchLikeCount(String postId) async {
    final rows = await _client
        .from('feed_likes')
        .select('post_id')
        .eq('post_id', postId);
    return rows.length;
  }

  Future<List<FeedComment>> fetchComments(String postId) async {
    final rows = await _client
        .from('feed_comments')
        .select(
          'id, post_id, user_id, body, created_at, profiles(nickname, name)',
        )
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return rows.map<FeedComment>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final profile = map['profiles'] as Map?;
      final nickname = profile?['nickname']?.toString().trim() ?? '';
      final name = profile?['name']?.toString().trim() ?? '';
      final authorName =
          nickname.isNotEmpty ? nickname : (name.isNotEmpty ? name : '익명');
      return FeedComment(
        id: map['id'].toString(),
        postId: map['post_id'].toString(),
        userId: map['user_id'].toString(),
        authorName: authorName,
        content: (map['body'] ?? '').toString(),
        createdAt: DateTime.parse(map['created_at'].toString()).toLocal(),
      );
    }).toList();
  }

  Future<void> addComment(String postId, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('로그인이 필요합니다.');
    await _client.from('feed_comments').insert(<String, Object?>{
      'post_id': postId,
      'user_id': userId,
      'body': content.trim(),
    });
  }

  String _dateOnly(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';
    return '${parsed.year}.${parsed.month.toString().padLeft(2, '0')}.${parsed.day.toString().padLeft(2, '0')}';
  }
}
