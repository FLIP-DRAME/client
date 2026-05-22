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
  });

  final String id;
  final String location;
  final String category;
  final List<String> images;
  final String authorName;
  final String authorRole;
  final String date;
  final int likes;
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
          operator:operator_profiles(display_name, specialty),
          assets:feed_post_assets(url, sort_order),
          likes:feed_likes(count)
        ''')
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return rows
        .map<FeedPost>((row) {
          final map = Map<String, dynamic>.from(row as Map);
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
            category:
                ((map['category'] as Map?)?['label'] ?? '드론 작업').toString(),
            images: images,
            authorName: (operator?['display_name'] ?? 'Drame 운용자').toString(),
            authorRole: (operator?['specialty'] ?? '드론 운용자').toString(),
            date: _dateOnly(map['created_at']),
            likes:
                likes.isEmpty
                    ? 0
                    : ((likes.first as Map?)?['count'] as num?)?.toInt() ?? 0,
          );
        })
        .where((post) => post.images.isNotEmpty)
        .toList();
  }

  String _dateOnly(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';
    return '${parsed.year}.${parsed.month.toString().padLeft(2, '0')}.${parsed.day.toString().padLeft(2, '0')}';
  }
}
