import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_defaults.dart';
import '../model/drone_pilot_model.dart';

abstract class DronePilotApi {
  Future<List<DronePilot>> fetchPilots({
    String? priorityArea,
    String? category,
  });
  Future<List<DroneCategory>> fetchCategories();
  Future<List<String>> fetchRegions();
  Future<DronePilot?> fetchPilotById(String id);
  Future<DronePilot?> fetchMyOperatorProfile();
  Future<List<PilotWorkRequestData>> fetchOperatorRequests();
  Future<List<UserQuoteSummary>> fetchMyQuotes();
  Future<void> submitOperatorRegistration(PilotRegistrationPayload payload);
  Future<void> updateOperatorProfile({
    required String intro,
    required String description,
    required String specialty,
    required List<String> portfolioImageUrls,
  });
}

class PilotWorkRequestData {
  const PilotWorkRequestData({
    required this.id,
    required this.category,
    required this.status,
    required this.location,
    required this.dateRange,
    required this.budget,
    required this.client,
    required this.summary,
    required this.remaining,
  });

  final String id;
  final String category;
  final String status;
  final String location;
  final String dateRange;
  final String budget;
  final String client;
  final String summary;
  final String remaining;
}

class UserQuoteSummary {
  const UserQuoteSummary({
    required this.pilotName,
    required this.category,
    required this.area,
    required this.date,
    required this.status,
    required this.price,
  });

  final String pilotName;
  final String category;
  final String area;
  final String date;
  final String status;
  final String price;
}

class PilotRegistrationPayload {
  const PilotRegistrationPayload({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    required this.data,
  });

  final String userId;
  final String email;
  final String name;
  final String nickname;
  final dynamic data;
}

class SupabaseDronePilotApi implements DronePilotApi {
  SupabaseDronePilotApi(this._client);

  final SupabaseClient _client;

  @override
  Future<List<DroneCategory>> fetchCategories() async {
    final rows = await _client
        .from('service_categories')
        .select('id, slug, label, description, icon_name')
        .eq('is_active', true)
        .order('sort_order');
    return rows.map<DroneCategory>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return DroneCategory(
        id: (map['slug'] ?? map['id']).toString(),
        label: (map['label'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        icon: _iconForName((map['icon_name'] ?? '').toString()),
      );
    }).toList();
  }

  @override
  Future<List<String>> fetchRegions() async {
    final rows = await _client
        .from('regions')
        .select('name')
        .eq('level', 1)
        .order('sort_order');
    return <String>['전체', ...rows.map<String>((row) => row['name'].toString())];
  }

  @override
  Future<List<DronePilot>> fetchPilots({
    String? priorityArea,
    String? category,
  }) async {
    final rows = await _client
        .from('operator_profiles')
        .select('''
          id,
          display_name,
          business_name,
          location_label,
          specialty,
          intro,
          description,
          base_price,
          response_time_label,
          phone,
          email,
          kakao_channel,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(portfolio_assets(url, sort_order))
        ''')
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    final pilots =
        rows
            .map<DronePilot>(
              (row) => _pilotFromRow(Map<String, dynamic>.from(row as Map)),
            )
            .where((pilot) {
              final categoryMatch =
                  category == null ||
                  category == '전체' ||
                  pilot.hasCategory(category);
              final areaMatch =
                  priorityArea == null ||
                  priorityArea == '전체' ||
                  pilot.availableAreas.contains(priorityArea) ||
                  pilot.permittedAreas.contains(priorityArea);
              return categoryMatch && areaMatch;
            })
            .toList();

    pilots.sort((a, b) {
      if (priorityArea != null && priorityArea != '전체') {
        final areaCompare = (a.hasPermitFor(priorityArea) ? 0 : 1).compareTo(
          b.hasPermitFor(priorityArea) ? 0 : 1,
        );
        if (areaCompare != 0) return areaCompare;
      }
      return a.name.compareTo(b.name);
    });
    return pilots;
  }

  @override
  Future<DronePilot?> fetchPilotById(String id) async {
    final rows = await _client
        .from('operator_profiles')
        .select('''
          id,
          display_name,
          business_name,
          location_label,
          specialty,
          intro,
          description,
          base_price,
          response_time_label,
          phone,
          email,
          kakao_channel,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(portfolio_assets(url, sort_order))
        ''')
        .eq('id', id)
        .limit(1);
    if (rows.isEmpty) return null;
    return _pilotFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  @override
  Future<DronePilot?> fetchMyOperatorProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final rows = await _client
        .from('operator_profiles')
        .select('''
          id,
          display_name,
          business_name,
          location_label,
          specialty,
          intro,
          description,
          base_price,
          response_time_label,
          phone,
          email,
          kakao_channel,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(portfolio_assets(url, sort_order))
        ''')
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return _pilotFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  @override
  Future<void> submitOperatorRegistration(
    PilotRegistrationPayload payload,
  ) async {
    final data = payload.data;
    final displayName =
        payload.nickname.isNotEmpty ? payload.nickname : payload.name;
    final serviceLabels = _serviceLabelsForRegistration(data);
    await _ensureProfile(payload);
    final operator =
        await _client
            .from('operator_profiles')
            .upsert(<String, Object?>{
              'user_id': payload.userId,
              'status': 'approved',
              'business_name': data.businessName,
              'business_number': data.businessNumber,
              'representative_name': data.representativeName,
              'display_name': displayName,
              'location_label':
                  data.areas.isEmpty ? null : data.areas.join(', '),
              'specialty':
                  serviceLabels.isEmpty ? null : serviceLabels.join(', '),
              'intro': 'Drame 등록 운용자입니다.',
              'description': data.portfolioUrl,
              'phone': null,
              'email': payload.email,
            }, onConflict: 'user_id')
            .select('id')
            .single();

    final operatorId = operator['id'].toString();
    await _tryOptionalWrite(() => _syncOperatorCategories(operatorId, data));
    await _tryOptionalWrite(() => _syncOperatorAreas(operatorId, data));
    await _tryOptionalWrite(() => _syncOperatorPortfolio(operatorId, data));
    if (data.licenseNumber.toString().isNotEmpty) {
      await _tryOptionalWrite(
        () => _client.from('operator_licenses').insert(<String, Object?>{
          'operator_id': operatorId,
          'license_type': data.licenseType,
          'license_number': data.licenseNumber,
        }),
      );
    }
    if (data.insuranceNumber.toString().isNotEmpty) {
      await _tryOptionalWrite(
        () => _client.from('operator_insurances').insert(<String, Object?>{
          'operator_id': operatorId,
          'company': data.insuranceCompany,
          'policy_number': data.insuranceNumber,
        }),
      );
    }
    for (final drone in data.drones) {
      if (drone.model.toString().trim().isEmpty) continue;
      await _tryOptionalWrite(
        () => _client.from('operator_drones').insert(<String, Object?>{
          'operator_id': operatorId,
          'maker': drone.maker,
          'model': drone.model,
          'registration_number': drone.registrationNumber,
        }),
      );
    }
  }

  @override
  Future<void> updateOperatorProfile({
    required String intro,
    required String description,
    required String specialty,
    required List<String> portfolioImageUrls,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final existing =
        await _client
            .from('operator_profiles')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();
    if (existing == null) return;
    final operatorId = existing['id'].toString();

    await _client.from('operator_profiles').update(<String, Object?>{
      'intro': intro,
      'description': description,
      'specialty': specialty.isEmpty ? null : specialty,
    }).eq('user_id', userId);

    await _client
        .from('portfolio_items')
        .delete()
        .eq('operator_id', operatorId);

    for (final url in portfolioImageUrls) {
      final trimmed = url.trim();
      if (trimmed.isEmpty) continue;
      await _tryOptionalWrite(
        () => _client.from('portfolio_items').insert(<String, Object?>{
          'operator_id': operatorId,
          'body': trimmed,
        }),
      );
      if (_isHttpUrl(trimmed)) {
        await _tryOptionalWrite(
          () =>
              _client
                  .from('portfolio_assets')
                  .upsert(
                    <String, Object?>{
                      'operator_id': operatorId,
                      'url': trimmed,
                      'sort_order': portfolioImageUrls.indexOf(url),
                    },
                    onConflict: 'url',
                  ),
        );
      }
    }
  }

  Future<void> _ensureProfile(PilotRegistrationPayload payload) async {
    try {
      await _client.from('profiles').upsert(<String, Object?>{
        'id': payload.userId,
        'role': payload.data == null ? 'client' : 'operator',
        'email': payload.email,
        'name': payload.name,
        'nickname': payload.nickname,
      }, onConflict: 'id');
    } on PostgrestException {
      // The auth trigger normally creates this row. If direct profile upsert is
      // blocked by project RLS, the operator upsert below will surface the real
      // FK/RLS error instead of hiding it here.
    }
  }

  Future<void> _tryOptionalWrite(Future<Object?> Function() write) async {
    try {
      await write();
    } on PostgrestException {
      return;
    }
  }

  Future<void> _syncOperatorCategories(String operatorId, dynamic data) async {
    final labels = _serviceLabelsForRegistration(data);
    if (labels.isEmpty) return;
    final rows = await _client
        .from('service_categories')
        .select('id,label')
        .inFilter('label', labels.toList());
    await _client
        .from('operator_categories')
        .delete()
        .eq('operator_id', operatorId);
    if (rows.isEmpty) return;
    await _client
        .from('operator_categories')
        .insert(
          rows
              .map<Map<String, Object?>>(
                (row) => <String, Object?>{
                  'operator_id': operatorId,
                  'category_id': row['id'],
                },
              )
              .toList(),
        );
  }

  Future<void> _syncOperatorAreas(String operatorId, dynamic data) async {
    final labels = Set<String>.from(data.areas as Set);
    if (labels.isEmpty) {
      labels.add('서울');
    }
    final rows = await _client
        .from('regions')
        .select('id,name')
        .inFilter('name', labels.toList());
    await _client
        .from('operator_service_areas')
        .delete()
        .eq('operator_id', operatorId);
    if (rows.isEmpty) return;
    await _client
        .from('operator_service_areas')
        .insert(
          rows
              .map<Map<String, Object?>>(
                (row) => <String, Object?>{
                  'operator_id': operatorId,
                  'region_id': row['id'],
                  'permission_type': 'available',
                },
              )
              .toList(),
        );
  }

  Future<void> _syncOperatorPortfolio(String operatorId, dynamic data) async {
    final portfolioUrl = data.portfolioUrl.toString().trim();
    if (portfolioUrl.isEmpty) return;

    final existingItems = await _client
        .from('portfolio_items')
        .select('id')
        .eq('operator_id', operatorId)
        .eq('title', '등록 포트폴리오')
        .limit(1);
    final item =
        existingItems.isEmpty
            ? await _client
                .from('portfolio_items')
                .insert(<String, Object?>{
                  'operator_id': operatorId,
                  'title': '등록 포트폴리오',
                  'body': portfolioUrl,
                  'is_published': true,
                })
                .select('id')
                .single()
            : await _client
                .from('portfolio_items')
                .update(<String, Object?>{
                  'body': portfolioUrl,
                  'is_published': true,
                })
                .eq('id', existingItems.first['id'])
                .select('id')
                .single();

    if (!_isHttpUrl(portfolioUrl)) return;

    await _client
        .from('portfolio_assets')
        .delete()
        .eq('operator_id', operatorId)
        .eq('url', portfolioUrl);
    await _client.from('portfolio_assets').insert(<String, Object?>{
      'portfolio_item_id': item['id'],
      'operator_id': operatorId,
      'kind': 'image',
      'url': portfolioUrl,
      'alt_text': '운용자 포트폴리오',
    });
  }

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Set<String> _serviceLabelsForDroneCategories(Set<String> categories) {
    final labels = <String>{};
    if (categories.contains('촬영용') || categories.contains('다목적')) {
      labels.addAll(<String>['항공촬영', '부동산', '행사촬영']);
    }
    if (categories.contains('방제용')) labels.add('농약방제');
    if (categories.contains('측량용')) labels.add('측량·매핑');
    if (categories.contains('점검용')) labels.add('시설점검');
    return labels;
  }

  Set<String> _serviceLabelsForRegistration(dynamic data) {
    return <String>{
      for (final drone in data.drones)
        ..._serviceLabelsForDroneCategories(
          Set<String>.from(drone.categories as Set),
        ),
      ...Set<String>.from(data.portfolioTypes as Set).where(
        (label) =>
            defaultDroneCategories.any((category) => category.label == label),
      ),
    };
  }

  DronePilot _pilotFromRow(Map<String, dynamic> row) {
    final categoryRows = List<Object?>.from(
      row['operator_categories'] as List? ?? const [],
    );
    final categories =
        categoryRows
            .map((item) => (item as Map)['service_categories'])
            .whereType<Map>()
            .map((item) => (item['label'] ?? '').toString())
            .where((label) => label.isNotEmpty)
            .toSet()
            .toList();
    final specialtyCategories =
        (row['specialty'] ?? '')
            .toString()
            .split(RegExp(r'[,·]'))
            .map((label) => label.trim())
            .where(
              (label) => defaultDroneCategories.any(
                (category) => category.label == label,
              ),
            )
            .toSet()
            .toList();

    final areaRows = List<Object?>.from(
      row['operator_service_areas'] as List? ?? const [],
    );
    final availableAreas = <String>{};
    final permittedAreas = <String>{};
    for (final item in areaRows.whereType<Map>()) {
      final name = ((item['regions'] as Map?)?['name'] ?? '').toString();
      if (name.isEmpty) continue;
      availableAreas.add(name);
      if (item['permission_type'] == 'permitted') {
        permittedAreas.add(name);
      }
    }

    final assetRows = List<Object?>.from(
      row['portfolio_assets'] as List? ?? const [],
    );
    final itemRows = List<Object?>.from(
      row['portfolio_items'] as List? ?? const [],
    );
    final images =
        <String>{
          ...assetRows.whereType<Map>().map(
            (item) => (item['url'] ?? '').toString(),
          ),
          ...itemRows.whereType<Map>().expand<String>((item) {
            final nested = List<Object?>.from(
              item['portfolio_assets'] as List? ?? const [],
            );
            return nested.whereType<Map>().map(
              (asset) => (asset['url'] ?? '').toString(),
            );
          }),
        }.where((url) => url.isNotEmpty).toList();

    return DronePilot(
      id: row['id'].toString(),
      name: (row['display_name'] ?? row['business_name'] ?? '운용자').toString(),
      location: (row['location_label'] ?? '지역 협의').toString(),
      categories: categories.isEmpty ? specialtyCategories : categories,
      availableAreas:
          availableAreas.isEmpty
              ? const <String>['전체']
              : availableAreas.toList(),
      permittedAreas: permittedAreas.toList(),
      basePrice: (row['base_price'] as num?)?.toInt() ?? 0,
      contact: (row['phone'] ?? '').toString(),
      mapX: 0.5,
      mapY: 0.5,
      portfolioImages: images,
      specialty: (row['specialty'] ?? '').toString(),
      intro: (row['intro'] ?? '').toString(),
      description: (row['description'] ?? '').toString(),
      quoteOptions: categories.isEmpty ? const <String>['상담 견적'] : categories,
    );
  }

  IconData _iconForName(String iconName) {
    return switch (iconName) {
      'grass_rounded' => Icons.grass_rounded,
      'home_work_rounded' => Icons.home_work_rounded,
      'map_rounded' => Icons.map_rounded,
      'engineering_rounded' => Icons.engineering_rounded,
      'celebration_rounded' => Icons.celebration_rounded,
      _ => Icons.camera_alt_rounded,
    };
  }

  @override
  Future<List<PilotWorkRequestData>> fetchOperatorRequests() async {
    final rows = await _client
        .from('job_requests')
        .select('''
          id,
          status,
          title,
          detail,
          location_label,
          preferred_start_at,
          preferred_end_at,
          budget_min,
          budget_max,
          contact_window,
          client_display_name,
          created_at,
          service_categories(label)
        ''')
        .order('created_at', ascending: false);

    return rows.map<PilotWorkRequestData>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return PilotWorkRequestData(
        id: map['id'].toString(),
        category:
            ((map['service_categories'] as Map?)?['label'] ?? '작업 요청')
                .toString(),
        status: _jobStatusLabel((map['status'] ?? '').toString()),
        location: (map['location_label'] ?? '지역 미정').toString(),
        dateRange: _dateRange(
          map['preferred_start_at'],
          map['preferred_end_at'],
        ),
        budget: _budgetLabel(map['budget_min'], map['budget_max']),
        client: (map['client_display_name'] ?? '고객').toString(),
        summary: (map['detail'] ?? map['title'] ?? '').toString(),
        remaining: '확인 필요',
      );
    }).toList();
  }

  @override
  Future<List<UserQuoteSummary>> fetchMyQuotes() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const <UserQuoteSummary>[];

    final rows = await _client
        .from('job_requests')
        .select('''
          id,
          status,
          location_label,
          preferred_start_at,
          created_at,
          service_categories(label),
          quotes(status, proposed_price, operator_profiles(display_name, business_name))
        ''')
        .eq('client_id', userId)
        .order('created_at', ascending: false);

    return rows.map<UserQuoteSummary>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final quoteRows = List<Object?>.from(map['quotes'] as List? ?? const []);
      final quote =
          quoteRows.whereType<Map>().isEmpty
              ? const <String, Object?>{}
              : Map<String, dynamic>.from(quoteRows.whereType<Map>().first);
      final operator = quote['operator_profiles'] as Map?;
      final price = (quote['proposed_price'] as num?)?.toInt();
      return UserQuoteSummary(
        pilotName:
            (operator?['display_name'] ??
                    operator?['business_name'] ??
                    '견적 대기중')
                .toString(),
        category:
            ((map['service_categories'] as Map?)?['label'] ?? '작업 요청')
                .toString(),
        area: (map['location_label'] ?? '지역 미정').toString(),
        date: _dateOnly(map['preferred_start_at'] ?? map['created_at']),
        status: _quoteStatusLabel(
          (quote['status'] ?? map['status'] ?? '').toString(),
        ),
        price: price == null ? '-' : '${(price / 10000).round()}만원',
      );
    }).toList();
  }

  String _jobStatusLabel(String status) => switch (status) {
    'open' => '신규',
    'quoted' => '견적 도착',
    'accepted' || 'paid' || 'contact_opened' || 'in_progress' => '진행 중',
    'completed' => '완료',
    'cancelled' => '취소',
    _ => '신규',
  };

  String _quoteStatusLabel(String status) => switch (status) {
    'submitted' => '견적 도착',
    'accepted' => '수락 완료',
    'rejected' => '거절',
    'expired' => '만료',
    'paid' || 'confirmed' => '결제 완료',
    'completed' => '작업 완료',
    _ => '견적 검토중',
  };

  String _budgetLabel(Object? min, Object? max) {
    final minValue = (min as num?)?.toInt();
    final maxValue = (max as num?)?.toInt();
    if (minValue == null && maxValue == null) return '예산 협의';
    if (minValue == null) return '${(maxValue! / 10000).round()}만원 이하';
    if (maxValue == null) return '${(minValue / 10000).round()}만원 이상';
    return '${(minValue / 10000).round()}~${(maxValue / 10000).round()}만원';
  }

  String _dateRange(Object? start, Object? end) {
    final startLabel = _dateOnly(start);
    final endLabel = _dateOnly(end);
    if (startLabel == '-') return '일정 협의';
    if (endLabel == '-' || endLabel == startLabel) return startLabel;
    return '$startLabel ~ $endLabel';
  }

  String _dateOnly(Object? value) {
    if (value == null) return '-';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}.$month.$day';
  }
}
