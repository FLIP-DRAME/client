import '../network/feed_api.dart';

class FeedViewModel {
  const FeedViewModel(this._api);

  final FeedApi _api;

  Future<List<FeedPost>> fetchPosts() => _api.fetchPosts();
}
