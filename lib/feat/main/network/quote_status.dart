/// Quote status computation logic extracted for testability.
class QuoteStatusHelper {
  const QuoteStatusHelper._();

  static String effectiveClientStatus({
    required String jobStatus,
    required String quoteStatus,
  }) {
    return switch (jobStatus) {
      'completed' ||
      'contact_opened' ||
      'in_progress' ||
      'paid' ||
      'confirmed' ||
      'accepted' => jobStatus,
      _ => quoteStatus.isEmpty ? jobStatus : quoteStatus,
    };
  }

  static String clientLabel(String status, {required bool hasQuote}) {
    if (status == 'quoted') {
      return hasQuote ? '견적 받음' : '요청 보냄';
    }
    return switch (status) {
      'submitted' => '견적 받음',
      'accepted' ||
      'paid' ||
      'confirmed' ||
      'contact_opened' ||
      'in_progress' => '진행중',
      'completed' => '완료',
      'rejected' => '거절',
      'expired' => '만료',
      _ => '요청 보냄',
    };
  }

  static int quoteRank(String status) => switch (status) {
    'completed' => 50,
    'contact_opened' ||
    'in_progress' ||
    'paid' ||
    'confirmed' ||
    'accepted' => 40,
    'submitted' || 'quoted' => 30,
    'expired' || 'rejected' => 20,
    _ => 0,
  };

  /// A map request has no preferred operator and must remain open after every
  /// quote so other operators can continue to respond. Only a direct,
  /// one-operator request advances to `quoted` automatically.
  static bool shouldAdvanceJobAfterQuote(String? preferredOperatorId) =>
      preferredOperatorId != null && preferredOperatorId.trim().isNotEmpty;
}
