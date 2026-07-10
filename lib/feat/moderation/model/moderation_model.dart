/// What kind of thing a report is filed against.
///
/// Kept as plain strings on the wire (content_reports.target_type) rather
/// than a Postgres enum, so new target types don't need a migration.
class ReportTargetType {
  static const String feedPost = 'feed_post';
  static const String chatUser = 'chat_user';
  static const String userProfile = 'user';
}

const List<String> reportReasons = <String>[
  '스팸 또는 광고',
  '욕설/혐오 표현',
  '음란물',
  '사기 의심',
  '불법 촬영/항공안전 위반',
  '기타',
];

class BlockedUser {
  const BlockedUser({required this.userId, required this.displayName});

  final String userId;
  final String displayName;
}
