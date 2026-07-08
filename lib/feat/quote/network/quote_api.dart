import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/quote_model.dart';

abstract class QuoteApi {
  Future<QuoteEstimate> createEstimate(QuoteRequest request);
  Future<PaymentInstruction> createPaymentInstruction(QuoteEstimate estimate);
  Future<ContactAccess> createContactAccess(QuoteEstimate estimate);

  /// Open, geotagged broadcast requests for the job-request map.
  Future<List<MapJobRequest>> fetchOpenMapRequests({int limit = 100});

  /// The current user's own map-posted broadcast requests, regardless of
  /// status -- used so an owner can see/close their own pin even after it
  /// has closed or auto-expired and dropped off the public map.
  Future<List<MapJobRequest>> fetchMyMapRequests();

  /// Posts a new broadcast request (no preferred operator) pinned at the
  /// given map location.
  Future<MapJobRequest> createMapJobRequest({
    required String categoryLabel,
    required String budgetRange,
    required double latitude,
    required double longitude,
    required String locationLabel,
    String detail = '',
    int? proposedAmount,
    DateTime? preferredDate,
  });

  /// Closes a map-posted request early (stop receiving further quotes).
  /// Only the owner (client_id) may do this -- enforced by RLS.
  Future<void> closeMapJobRequest(String requestId);
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

    final preferredDate = _parsePreferredDate(request.preferredDate);
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
              'budget_max': request.proposedAmount ?? budget.$2,
              'contact_window': request.contactWindow,
              'client_display_name': clientDisplayName,
              if (preferredDate != null)
                'preferred_start_at': preferredDate.toUtc().toIso8601String(),
              if (request.latitude != null) 'latitude': request.latitude,
              if (request.longitude != null) 'longitude': request.longitude,
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

  DateTime? _parsePreferredDate(String dateStr) {
    final parts = dateStr.split('.');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  (int?, int?) _parseBudget(String label) {
    return switch (label) {
      '0~30만원' => (0, 300000),
      '~30만원' => (0, 300000),
      '30~50만원' => (300000, 500000),
      '50~100만원' => (500000, 1000000),
      '100만원 이상' => (1000000, null),
      '협의' => (null, null),
      // 구버전 레이블 호환
      '50만원 이하' => (0, 500000),
      _ => (null, null),
    };
  }

  String _budgetLabelFromRange(Object? min, Object? max) {
    final minValue = (min as num?)?.toInt();
    final maxValue = (max as num?)?.toInt();
    if (minValue == null && maxValue == null) return '예산 협의';
    if (maxValue == null) return '${((minValue ?? 0) / 10000).round()}만원 이상';
    if (minValue == null || minValue == 0) {
      return '${(maxValue / 10000).round()}만원 이하';
    }
    return '${(minValue / 10000).round()}~${(maxValue / 10000).round()}만원';
  }

  @override
  Future<List<MapJobRequest>> fetchOpenMapRequests({int limit = 100}) async {
    final rows = await _client
        .from('job_requests_map_public')
        .select('''
          id,
          status,
          budget_min,
          budget_max,
          latitude,
          longitude,
          location_label,
          created_at,
          category_label,
          preferred_start_at
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    final requests = rows.map<MapJobRequest>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return MapJobRequest(
        id: map['id'].toString(),
        status: (map['status'] ?? 'open').toString(),
        category: (map['category_label'] ?? '드론 작업').toString(),
        budgetLabel: _budgetLabelFromRange(
          map['budget_min'],
          map['budget_max'],
        ),
        locationLabel: (map['location_label'] ?? '지역 미정').toString(),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        createdAt:
            DateTime.tryParse((map['created_at'] ?? '').toString()) ??
            DateTime.now(),
        preferredDate: DateTime.tryParse(
          (map['preferred_start_at'] ?? '').toString(),
        ),
      );
    }).toList();

    // Defensive client-side filter: the DB view is expected to already drop
    // closed/expired rows (see supabase_job_request_expiry_migration.sql),
    // but this keeps the public feed correct even before that migration is
    // applied, or if it's ever missed on a fresh Supabase project.
    return requests.where((r) => !r.isClosedOrExpired).toList();
  }

  @override
  Future<List<MapJobRequest>> fetchMyMapRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const <MapJobRequest>[];

    final rows = await _client
        .from('job_requests')
        .select('''
          id,
          status,
          budget_min,
          budget_max,
          latitude,
          longitude,
          location_label,
          created_at,
          preferred_start_at,
          service_categories(label)
        ''')
        .eq('client_id', userId)
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .order('created_at', ascending: false);

    return rows.map<MapJobRequest>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final categoryRow = map['service_categories'] as Map?;
      return MapJobRequest(
        id: map['id'].toString(),
        status: (map['status'] ?? 'open').toString(),
        category: (categoryRow?['label'] ?? '드론 작업').toString(),
        budgetLabel: _budgetLabelFromRange(
          map['budget_min'],
          map['budget_max'],
        ),
        locationLabel: (map['location_label'] ?? '지역 미정').toString(),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        createdAt:
            DateTime.tryParse((map['created_at'] ?? '').toString()) ??
            DateTime.now(),
        preferredDate: DateTime.tryParse(
          (map['preferred_start_at'] ?? '').toString(),
        ),
        isOwn: true,
      );
    }).toList();
  }

  @override
  Future<void> closeMapJobRequest(String requestId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }
    await _client
        .from('job_requests')
        .update(<String, Object?>{'status': 'cancelled'})
        .eq('id', requestId)
        .eq('client_id', userId);
  }

  @override
  Future<MapJobRequest> createMapJobRequest({
    required String categoryLabel,
    required String budgetRange,
    required double latitude,
    required double longitude,
    required String locationLabel,
    String detail = '',
    int? proposedAmount,
    DateTime? preferredDate,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }
    final categoryId = await _findCategoryId(categoryLabel);
    final budget = _parseBudget(budgetRange);

    String clientDisplayName = _client.auth.currentUser?.email ?? '고객';
    final profile =
        await _client
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

    final row =
        await _client
            .from('job_requests')
            .insert(<String, Object?>{
              'client_id': userId,
              'category_id': categoryId,
              'preferred_operator_id': null,
              'status': 'open',
              'title': '$locationLabel $categoryLabel 요청',
              'detail': detail,
              'location_label': locationLabel,
              'latitude': latitude,
              'longitude': longitude,
              'budget_min': budget.$1,
              'budget_max': proposedAmount ?? budget.$2,
              'contact_window': '앱 내 채팅 우선',
              'client_display_name': clientDisplayName,
              if (preferredDate != null)
                'preferred_start_at': preferredDate.toUtc().toIso8601String(),
            })
            .select('id, status, budget_min, budget_max, created_at')
            .single();

    return MapJobRequest(
      id: row['id'].toString(),
      status: (row['status'] ?? 'open').toString(),
      category: categoryLabel,
      budgetLabel: _budgetLabelFromRange(
        row['budget_min'],
        row['budget_max'],
      ),
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      preferredDate: preferredDate,
      isOwn: true,
    );
  }
}
