import '../../main/network/drone_pilot_model.dart';

class QuoteRequest {
  const QuoteRequest({
    required this.pilot,
    required this.category,
    required this.area,
    required this.preferredDate,
    required this.detail,
    required this.budgetRange,
    required this.contactWindow,
  });

  final DronePilot pilot;
  final String category;
  final String area;
  final String preferredDate;
  final String detail;
  final String budgetRange;
  final String contactWindow;
}

class QuoteEstimate {
  const QuoteEstimate({
    required this.request,
    required this.proposedPrice,
    required this.estimatedTime,
    required this.includedItems,
    required this.message,
  });

  final QuoteRequest request;
  final int proposedPrice;
  final String estimatedTime;
  final List<String> includedItems;
  final String message;

  String get priceLabel => '${(proposedPrice / 10000).round()}만원';
}

class PaymentInstruction {
  const PaymentInstruction({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.amount,
    required this.depositorName,
  });

  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final int amount;
  final String depositorName;

  String get amountLabel => '${(amount / 10000).round()}만원';
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
