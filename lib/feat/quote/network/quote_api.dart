import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main/model/drone_pilot_model.dart';
import '../model/quote_model.dart';

abstract class QuoteApi {
  Future<QuoteEstimate> createEstimate(QuoteRequest request);
  Future<PaymentInstruction> createPaymentInstruction(QuoteEstimate estimate);
  Future<ContactAccess> createContactAccess(QuoteEstimate estimate);
}

class SupabaseQuoteApi implements QuoteApi {
  SupabaseQuoteApi(this._client);

  final SupabaseClient _client;

  @override
  Future<QuoteEstimate> createEstimate(QuoteRequest request) async {
    final userId = _client.auth.currentUser?.id;
    final categoryId = await _findCategoryId(request.category);
    final regionId = await _findRegionId(request.area);
    final budget = _parseBudget(request.budgetRange);

    final job =
        await _client
            .from('job_requests')
            .insert(<String, Object?>{
              'client_id': userId,
              'category_id': categoryId,
              'preferred_operator_id': request.pilot.id,
              'region_id': regionId,
              'status': 'open',
              'title': '${request.area} ${request.category} 요청',
              'detail': request.detail,
              'location_label': request.area,
              'budget_min': budget.$1,
              'budget_max': budget.$2,
              'contact_window': request.contactWindow,
              'client_display_name': _client.auth.currentUser?.email,
            })
            .select('id')
            .single();

    final proposedPrice = _proposedPrice(request.pilot, request.category);
    String? quoteId;
    try {
      final quote =
          await _client
              .from('quotes')
              .insert(<String, Object?>{
                'job_request_id': job['id'],
                'operator_id': request.pilot.id,
                'status': 'submitted',
                'proposed_price': proposedPrice,
                'estimated_time_label': _estimatedTime(request.category),
                'message': _message(request),
              })
              .select('id')
              .single();
      quoteId = quote['id'].toString();
      await _client
          .from('quote_included_items')
          .insert(
            _includedItems(request.category)
                .asMap()
                .entries
                .map(
                  (entry) => <String, Object?>{
                    'quote_id': quoteId,
                    'item_text': entry.value,
                    'sort_order': entry.key,
                  },
                )
                .toList(),
          );
    } on PostgrestException {
      // Operators normally create quotes. When RLS blocks this client-side
      // convenience quote, the job request is still saved and the estimate UI
      // can continue as a pending request.
    }

    return QuoteEstimate(
      request: request,
      proposedPrice: proposedPrice,
      estimatedTime: _estimatedTime(request.category),
      includedItems: _includedItems(request.category),
      message: _message(request),
      jobRequestId: job['id'].toString(),
      quoteId: quoteId,
    );
  }

  @override
  Future<PaymentInstruction> createPaymentInstruction(
    QuoteEstimate estimate,
  ) async {
    String? paymentId;
    if (estimate.quoteId != null) {
      final payment =
          await _client
              .from('payments')
              .insert(<String, Object?>{
                'quote_id': estimate.quoteId,
                'client_id': _client.auth.currentUser?.id,
                'status': 'pending',
                'method': 'bank_transfer',
                'amount': estimate.proposedPrice,
                'bank_name': 'DRAME 안심계좌',
                'account_holder': '주식회사 드라메',
                'account_number': '110-482-903184',
                'depositor_name': '의뢰자명 + ${estimate.request.pilot.name}',
              })
              .select('id')
              .single();
      paymentId = payment['id'].toString();
    }
    return PaymentInstruction(
      bankName: 'DRAME 안심계좌',
      accountHolder: '주식회사 드라메',
      accountNumber: '110-482-903184',
      amount: estimate.proposedPrice,
      depositorName: '의뢰자명 + ${estimate.request.pilot.name}',
      paymentId: paymentId,
    );
  }

  @override
  Future<ContactAccess> createContactAccess(QuoteEstimate estimate) async {
    final pilot = estimate.request.pilot;
    if (estimate.paymentId != null) {
      await _client
          .from('payments')
          .update(<String, Object?>{
            'status': 'confirmed',
            'paid_at': DateTime.now().toUtc().toIso8601String(),
            'confirmed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', estimate.paymentId!);
    }
    return ContactAccess(
      phone: pilot.contact.isEmpty ? '운용자 승인 후 공개' : pilot.contact,
      email: '${pilot.id}@drame.co.kr',
      kakaoChannel: '@drame-${pilot.id}',
      note: '입금 확인 후 24시간 동안 연락수단이 제공됩니다. 작업 조건은 채팅에서 최종 확정하세요.',
    );
  }

  Future<String?> _findCategoryId(String label) async {
    final rows = await _client
        .from('service_categories')
        .select('id')
        .eq('label', label)
        .limit(1);
    return rows.isEmpty ? null : rows.first['id'].toString();
  }

  Future<String?> _findRegionId(String name) async {
    final rows = await _client
        .from('regions')
        .select('id')
        .eq('name', name)
        .limit(1);
    return rows.isEmpty ? null : rows.first['id'].toString();
  }

  (int?, int?) _parseBudget(String label) {
    return switch (label) {
      '50만원 이하' => (0, 500000),
      '50~100만원' => (500000, 1000000),
      '100만원 이상' => (1000000, null),
      _ => (null, null),
    };
  }

  int _proposedPrice(DronePilot pilot, String category) {
    final premium = switch (category) {
      '측량·매핑' || '시설점검' => 180000,
      '농약방제' => 90000,
      _ => 120000,
    };
    return pilot.basePrice + premium;
  }

  String _estimatedTime(String category) =>
      category == '농약방제' ? '반나절 작업' : '촬영 2시간 + 편집 1일';

  List<String> _includedItems(String category) => <String>[
    '비행 가능 여부 사전 확인',
    '현장 촬영 및 기본 안전 동선 설계',
    '원본 파일 납품',
    if (category != '농약방제') '핵심 컷 보정본 10장',
  ];

  String _message(QuoteRequest request) {
    return '${request.pilot.name}이 ${request.area} ${request.category} 요청을 확인했습니다. '
        '날씨와 공역 조건만 맞으면 희망 일정에 맞춰 진행 가능합니다.';
  }
}
