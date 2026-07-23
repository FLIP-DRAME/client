import '../../main/model/drone_pilot_model.dart';

class QuoteRequest {
  const QuoteRequest({
    required this.pilot,
    required this.category,
    required this.area,
    required this.preferredDate,
    required this.detail,
    required this.budgetRange,
    required this.contactWindow,
    this.proposedAmount,
    this.latitude,
    this.longitude,
  });

  final DronePilot pilot;
  final String category;
  final String area;
  final String preferredDate;
  final String detail;
  final String budgetRange;
  final String contactWindow;
  final int? proposedAmount;
  final double? latitude;
  final double? longitude;
}

class QuoteEstimate {
  const QuoteEstimate({
    required this.request,
    required this.proposedPrice,
    required this.estimatedTime,
    required this.includedItems,
    required this.message,
    this.jobRequestId,
    this.quoteId,
    this.paymentId,
  });

  final QuoteRequest request;
  final int proposedPrice;
  final String estimatedTime;
  final List<String> includedItems;
  final String message;
  final String? jobRequestId;
  final String? quoteId;
  final String? paymentId;

  String get priceLabel => '${(proposedPrice / 10000).round()}만원';

  QuoteEstimate copyWith({
    String? jobRequestId,
    String? quoteId,
    String? paymentId,
  }) {
    return QuoteEstimate(
      request: request,
      proposedPrice: proposedPrice,
      estimatedTime: estimatedTime,
      includedItems: includedItems,
      message: message,
      jobRequestId: jobRequestId ?? this.jobRequestId,
      quoteId: quoteId ?? this.quoteId,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}

class PaymentInstruction {
  const PaymentInstruction({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.amount,
    required this.depositorName,
    this.paymentId,
  });

  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final int amount;
  final String depositorName;
  final String? paymentId;

  String get amountLabel => '${(amount / 10000).round()}만원';
}

/// A broadcast job request pinned on the map (no preferred operator) --
/// only carries the safe, public subset of a job_requests row.
class MapJobRequest {
  const MapJobRequest({
    required this.id,
    required this.status,
    required this.category,
    required this.budgetLabel,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.preferredDate,
    this.detail = '',
    this.isOwn = false,
    this.hasMyQuote = false,
  });

  final String id;
  final String status;
  final String category;
  final String budgetLabel;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? preferredDate;
  final String detail;

  /// True when the current logged-in user is the one who posted this
  /// request. Only set for rows fetched via `fetchMyMapRequests` -- the
  /// public map feed never carries ownership info.
  final bool isOwn;

  /// True when the current logged-in operator has already submitted a quote
  /// for this request. Not part of the server payload -- stamped on client
  /// side after cross-referencing the operator's own quotes.
  final bool hasMyQuote;

  MapJobRequest copyWith({bool? hasMyQuote}) {
    return MapJobRequest(
      id: id,
      status: status,
      category: category,
      budgetLabel: budgetLabel,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      preferredDate: preferredDate,
      detail: detail,
      isOwn: isOwn,
      hasMyQuote: hasMyQuote ?? this.hasMyQuote,
    );
  }

  String get dateLabel {
    final date = preferredDate;
    if (date == null) return '일정 협의';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  static const _inProgressStatuses = <String>{
    'accepted',
    'paid',
    'contact_opened',
    'in_progress',
  };

  bool get isInProgress => _inProgressStatuses.contains(status);

  /// Manually closed by the requester (stopped accepting quotes). Reuses
  /// the existing 'cancelled' job_status enum value -- job_status is a
  /// Postgres enum with a fixed set of members, and 'cancelled' already
  /// means exactly this and is already excluded from the public map view.
  bool get isClosed => status == 'cancelled';

  /// Relative time since this request was posted, e.g. "3시간 전", "2일 전".
  String get elapsedLabel {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}주 전';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}개월 전';
    return '${diff.inDays ~/ 365}년 전';
  }
}

/// Full detail of a map-pinned job request, fetched on demand when a pin is
/// selected. Kept separate from [MapJobRequest] so the map load stays light.
class MapJobRequestDetail {
  const MapJobRequestDetail({required this.id, this.detail = ''});

  final String id;
  final String detail;

  bool get hasDetail => detail.trim().isNotEmpty;
}

class ContactAccess {
  const ContactAccess({
    required this.phone,
    required this.email,
    required this.kakaoChannel,
    required this.note,
  });

  final String phone;
  final String email;
  final String kakaoChannel;
  final String note;
}
