import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase/supabase_providers.dart';
import 'feat/auth/viewmodel/auth_view_model.dart';
import 'feat/feed/network/feed_api.dart';
import 'feat/feed/viewmodel/feed_view_model.dart';
import 'feat/main/network/drone_pilot_api.dart';
import 'feat/main/viewmodel/main_view_model.dart';
import 'feat/quote/network/quote_api.dart';
import 'feat/quote/viewmodel/quote_view_model.dart';

final dronePilotApiProvider = Provider<DronePilotApi>((ref) {
  return SupabaseDronePilotApi(ref.watch(supabaseClientProvider));
});

final quoteApiProvider = Provider<QuoteApi>((ref) {
  return SupabaseQuoteApi(ref.watch(supabaseClientProvider));
});

final feedApiProvider = Provider<FeedApi>((ref) {
  return FeedApi(ref.watch(supabaseClientProvider));
});

final feedViewModelProvider = Provider<FeedViewModel>((ref) {
  return FeedViewModel(ref.watch(feedApiProvider));
});

final quoteViewModelProvider = Provider<QuoteViewModel>((ref) {
  return QuoteViewModel(ref.watch(quoteApiProvider));
});

final drameStoreProvider = ChangeNotifierProvider<DrameStore>((ref) {
  return DrameStore(
    api: ref.watch(dronePilotApiProvider),
    quoteApi: ref.watch(quoteApiProvider),
    feedApi: ref.watch(feedApiProvider),
  );
});

final authViewModelProvider = Provider<AuthViewModel>((ref) {
  return AuthViewModel(ref.watch(drameStoreProvider));
});
