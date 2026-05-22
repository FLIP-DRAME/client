import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase/supabase_providers.dart';
import 'feat/feed/network/feed_api.dart';
import 'feat/main/network/drone_pilot_api.dart';
import 'feat/main/ui/pages/main_page.dart';
import 'feat/quote/network/quote_api.dart';

final dronePilotApiProvider = Provider<DronePilotApi>((ref) {
  return SupabaseDronePilotApi(ref.watch(supabaseClientProvider));
});

final quoteApiProvider = Provider<QuoteApi>((ref) {
  return SupabaseQuoteApi(ref.watch(supabaseClientProvider));
});

final feedApiProvider = Provider<FeedApi>((ref) {
  return FeedApi(ref.watch(supabaseClientProvider));
});

final drameStoreProvider = ChangeNotifierProvider<DrameStore>((ref) {
  return DrameStore(
    api: ref.watch(dronePilotApiProvider),
    quoteApi: ref.watch(quoteApiProvider),
  );
});
