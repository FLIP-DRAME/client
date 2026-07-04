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
  });

  final String id;
  final String status;
  final String category;
  final String budgetLabel;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  static const _inProgressStatuses = <String>{
    'accepted',
    'paid',
    'contact_opened',
    'in_progress',
  };

  bool get isInProgress => _inProgressStatuses.contains(status);
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
