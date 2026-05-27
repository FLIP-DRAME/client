import 'package:supabase_flutter/supabase_flutter.dart';

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

    String clientDisplayName = _client.auth.currentUser?.email ?? '고객';
    if (userId != null) {
      final profile = await _client
          .from('profiles')
          .select('nickname, name')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        final nickname = profile['nickname']?.toString().trim() ?? '';
        final name = profile['name']?.toString().trim() ?? '';
        if (nickname.isNotEmpty) {
          clientDisplayName = nickname;
        } else if (name.isNotEmpty) {
          clientDisplayName = name;
        }
      }
    }

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
              'client_display_name': clientDisplayName,
            })
            .select('id')
            .single();
    await _tryInsertOperatorNotification(
      jobRequestId: job['id'].toString(),
      operatorId: request.pilot.id,
      area: request.area,
      category: request.category,
    );

    return QuoteEstimate(
      request: request,
      proposedPrice: 0,
      estimatedTime: '운용자 검토 대기',
      includedItems: const <String>[],
      message:
          '${request.pilot.name}에게 견적 요청을 보냈습니다. 운용자가 확인 후 견적을 보내면 내 견적에서 확인할 수 있습니다.',
      jobRequestId: job['id'].toString(),
    );
  }

  Future<void> _tryInsertOperatorNotification({
    required String jobRequestId,
    required String operatorId,
    required String area,
    required String category,
  }) async {
    try {
      final operatorRows = await _client
          .from('operator_profiles')
          .select('user_id')
          .eq('id', operatorId)
          .limit(1);
      if (operatorRows.isEmpty) return;
      await _client.from('notifications').insert(<String, Object?>{
        'recipient_id': operatorRows.first['user_id'],
        'kind': 'quote_request',
        'title': '새 견적 요청이 도착했습니다',
        'body': '$area $category 요청을 확인해 주세요.',
        'source_table': 'job_requests',
        'source_id': jobRequestId,
        'dedupe_key': 'job_request:$jobRequestId:operator_request',
      });
    } on PostgrestException {
      return;
    }
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
                'bank_name': '모드 안심계좌',
                'account_holder': '주식회사 드라메',
                'account_number': '110-482-903184',
                'depositor_name': '의뢰자명 + ${estimate.request.pilot.name}',
              })
              .select('id')
              .single();
      paymentId = payment['id'].toString();
    }
    return PaymentInstruction(
      bankName: '모드 안심계좌',
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
    if (estimate.jobRequestId != null) {
      await _client
          .from('job_requests')
          .update(<String, Object?>{'status': 'contact_opened'})
          .eq('id', estimate.jobRequestId!);
    }
    if (estimate.quoteId != null) {
      await _tryUpdateQuoteStatus(estimate.quoteId!, 'accepted');
    }
    return ContactAccess(
      phone: pilot.contact.isEmpty ? '운용자 승인 후 공개' : pilot.contact,
      email: '${pilot.id}@mode.co.kr',
      kakaoChannel: '@mode-${pilot.id}',
      note: '입금 확인 후 24시간 동안 연락수단이 제공됩니다. 작업 조건은 채팅에서 최종 확정하세요.',
    );
  }

  Future<void> _tryUpdateQuoteStatus(String quoteId, String status) async {
    try {
      await _client
          .from('quotes')
          .update(<String, Object?>{'status': status})
          .eq('id', quoteId);
    } on PostgrestException {
      return;
    }
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
}
