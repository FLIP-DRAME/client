import 'quote_model.dart';

class MockQuoteApi {
  Future<QuoteEstimate> createEstimate(QuoteRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final categoryPremium =
        request.category == '측량·매핑' || request.category == '시설점검'
            ? 180000
            : request.category == '농약방제'
            ? 90000
            : 120000;
    final proposedPrice = request.pilot.basePrice + categoryPremium;

    return QuoteEstimate(
      request: request,
      proposedPrice: proposedPrice,
      estimatedTime: request.category == '농약방제' ? '반나절 작업' : '촬영 2시간 + 편집 1일',
      includedItems: <String>[
        '비행 가능 여부 사전 확인',
        '현장 촬영 및 기본 안전 동선 설계',
        '원본 파일 납품',
        if (request.category != '농약방제') '핵심 컷 보정본 10장',
      ],
      message:
          '${request.pilot.name}이 ${request.area} ${request.category} 요청을 확인했습니다. '
          '날씨와 공역 조건만 맞으면 희망 일정에 맞춰 진행 가능합니다.',
    );
  }

  PaymentInstruction createPaymentInstruction(QuoteEstimate estimate) {
    return PaymentInstruction(
      bankName: 'DRAME 안심계좌',
      accountHolder: '주식회사 드라메',
      accountNumber: '110-482-903184',
      amount: estimate.proposedPrice,
      depositorName: '의뢰자명 + ${estimate.request.pilot.name}',
    );
  }

  ContactAccess createContactAccess(QuoteEstimate estimate) {
    final pilot = estimate.request.pilot;
    return ContactAccess(
      phone: pilot.contact,
      email: '${pilot.id}@drame.co.kr',
      kakaoChannel: '@drame-${pilot.id}',
      note: '입금 확인 후 24시간 동안 연락수단이 제공됩니다. 작업 조건은 채팅에서 최종 확정하세요.',
    );
  }
}
