import 'package:flutter/material.dart';

import '../../../common/d_tokens.dart';

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
    'contact_opened' || 'in_progress' || 'paid' || 'confirmed' || 'accepted' =>
      40,
    'submitted' || 'quoted' => 30,
    'expired' || 'rejected' => 20,
    _ => 0,
  };

  /// Foreground/background color pair for a status label as returned by
  /// [clientLabel]. Single source of truth for status-chip coloring — used
  /// to replace three previously independent, drifted color mappings.
  static (Color foreground, Color background) statusColors(String label) {
    return switch (label) {
      '견적 받음' => (DC.primary, const Color(0xFFEEF4FF)),
      '진행중' => (DC.up, const Color(0xFFE8F9F1)),
      '완료' => (DC.muted, DC.surfaceStrong),
      '거절' => (DC.down, const Color(0xFFFDECEC)),
      '만료' => (DC.mutedSoft, DC.surfaceSoft),
      _ => (DC.body, DC.surfaceSoft), // '요청 보냄' and any unknown status
    };
  }
}
