import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_defaults.dart';
import '../model/main_models.dart';
import '../model/drone_pilot_model.dart';
import 'quote_status.dart';

abstract class DronePilotApi {
  Future<List<DronePilot>> fetchPilots({
    String? priorityArea,
    String? category,
  });
  Future<List<DroneCategory>> fetchCategories();
  Future<List<String>> fetchRegions();
  Future<DronePilot?> fetchPilotById(String id);
  Future<DronePilot?> fetchMyOperatorProfile();
  Future<({String name, String nickname})?> fetchMyAccountProfile();
  Future<List<PilotWorkRequestData>> fetchOperatorRequests();
  Future<List<UserQuoteSummary>> fetchMyQuotes();
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markOperatorRequestSeen(String requestId);
  Future<void> updateMyQuoteRequest({
    required String requestId,
    required String category,
    required String area,
    required String preferredDate,
    required String detail,
    required String budgetRange,
    required String contactWindow,
    int? proposedAmount,
    double? latitude,
    double? longitude,
  });
  Future<void> submitQuoteForRequest(
    PilotWorkRequest request,
    String message, {
    int? proposedPrice,
  });
  Future<void> submitOperatorRegistration(PilotRegistrationPayload payload);
  Future<String> uploadProfilePhoto(String userId, List<int> bytes, String ext);
  Future<String> uploadPortfolioImage(
    String userId,
    List<int> bytes,
    String fileName,
  );
  Future<String> uploadLicensePdf(String userId, List<int> bytes);
  Future<String> uploadBusinessPdf(String userId, List<int> bytes);
  Future<String> uploadInsurancePdf(String userId, List<int> bytes);
  Future<void> updateMyProfile({
    required String name,
    required String nickname,
  });
  Future<void> updateOperatorProfile({
    required String intro,
    required String description,
    required List<String> categoryLabels,
    required List<String> areaNames,
    required List<String> portfolioImageUrls,
  });
  Future<void> saveFcmToken(String token);
  Future<bool> isRequestUnlocked(String requestId);
  Future<void> unlockRequest(String requestId);
  Future<void> deleteMyAccount();
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
    required this.createdAt,
    this.myQuoteId,
    this.myQuoteMessage,
    this.myQuotePrice,
    this.latitude,
    this.longitude,
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
  final DateTime createdAt;
  final String? myQuoteId;
  final String? myQuoteMessage;
  final int? myQuotePrice;
  final double? latitude;
  final double? longitude;
}

class UserQuoteSummary {
  const UserQuoteSummary({
    required this.id,
    required this.pilotId,
    required this.pilotName,
    required this.category,
    required this.area,
    required this.date,
    required this.status,
    required this.price,
    required this.detail,
    required this.budgetRange,
    required this.contactWindow,
    required this.message,
    required this.createdAt,
    this.budgetMin,
    this.budgetMax,
    this.quoteId,
    this.proposedPriceInt,
  });

  final String id;
  final String pilotId;
  final String pilotName;
  final String category;
  final String area;
  final String date;
  final String status;
  final String price;
  final String detail;
  final String budgetRange;
  final String contactWindow;
  final String message;
  final DateTime createdAt;
  final int? budgetMin;
  final int? budgetMax;
  final String? quoteId;
  final int? proposedPriceInt;

  bool get isQuoteReceived => status == '견적 받음';
  bool get isInProgress => status == '진행중';
  bool get isCompleted => status == '완료';
  bool get isPending => status == '요청 보냄';

  String get budgetOption {
    final min = budgetMin;
    if (min == null) return '협의';
    if (min == 0) return '0~30만원';
    if (min == 300000) return '30~50만원';
    if (min == 500000) return '50~100만원';
    if (min >= 1000000) return '100만원 이상';
    return budgetRange;
  }
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
          status,
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
          avatar_url,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(body, portfolio_assets(url, sort_order))
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
              final parentRegion =
                  priorityArea != null && priorityArea.contains(' ')
                      ? priorityArea.split(' ').first
                      : null;
              final areaMatch =
                  priorityArea == null ||
                  priorityArea == '전체' ||
                  pilot.availableAreas.contains(priorityArea) ||
                  pilot.permittedAreas.contains(priorityArea) ||
                  (parentRegion != null &&
                      pilot.availableAreas.contains(parentRegion)) ||
                  (parentRegion != null &&
                      pilot.permittedAreas.contains(parentRegion));
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
          status,
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
          avatar_url,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(body, portfolio_assets(url, sort_order))
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
          status,
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
          avatar_url,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order),
          portfolio_items(body, portfolio_assets(url, sort_order))
        ''')
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    final row = Map<String, dynamic>.from(rows.first as Map);
    try {
      final account = await fetchMyAccountProfile();
      final currentDisplayName =
          account?.nickname.isNotEmpty == true
              ? account!.nickname
              : account?.name ?? '';
      if (currentDisplayName.isNotEmpty) {
        row['display_name'] = currentDisplayName;
      }
    } catch (_) {
      // The operator profile remains usable if the account row is unavailable.
    }
    return _pilotFromRow(row);
  }

  @override
  Future<({String name, String nickname})?> fetchMyAccountProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select('name, nickname')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return (
      name: (row['name'] ?? '').toString().trim(),
      nickname: (row['nickname'] ?? '').toString().trim(),
    );
  }

  @override
  Future<String> uploadProfilePhoto(
    String userId,
    List<int> bytes,
    String ext,
  ) async {
    final path = '$userId/profile.$ext';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
        );
    final url = _client.storage.from('avatars').getPublicUrl(path);
    await _client
        .from('operator_profiles')
        .update(<String, Object?>{'avatar_url': url})
        .eq('user_id', userId);
    return url;
  }

  @override
  Future<String> uploadPortfolioImage(
    String userId,
    List<int> bytes,
    String fileName,
  ) async {
    final ext = _fileExt(fileName, fallback: 'jpg');
    final path =
        '$userId/portfolio_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: _imageContentType(ext),
            upsert: true,
          ),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<void> updateMyProfile({
    required String name,
    required String nickname,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final cleanName = name.trim();
    final cleanNickname = nickname.trim();
    final nextMetadata = <String, Object?>{
      ...?user.userMetadata,
      'name': cleanName,
      'nickname': cleanNickname,
    };
    await _client.auth.updateUser(UserAttributes(data: nextMetadata));
    await _tryOptionalWrite(
      () => _client.from('profiles').upsert(<String, Object?>{
        'id': user.id,
        'email': user.email,
        'name': cleanName,
        'nickname': cleanNickname,
      }, onConflict: 'id'),
    );
    final displayName = cleanNickname.isNotEmpty ? cleanNickname : cleanName;
    if (displayName.isNotEmpty) {
      await _tryOptionalWrite(
        () => _client
            .from('operator_profiles')
            .update(<String, Object?>{'display_name': displayName})
            .eq('user_id', user.id),
      );
    }
  }

  @override
  Future<String> uploadLicensePdf(String userId, List<int> bytes) async {
    final path = '$userId/license_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return _client.storage.from('documents').getPublicUrl(path);
  }

  @override
  Future<String> uploadBusinessPdf(String userId, List<int> bytes) async {
    final path =
        '$userId/business_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return _client.storage.from('documents').getPublicUrl(path);
  }

  @override
  Future<String> uploadInsurancePdf(String userId, List<int> bytes) async {
    final path =
        '$userId/insurance_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return _client.storage.from('documents').getPublicUrl(path);
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
              'status': 'pending_review',
              'business_name': data.businessName,
              'business_number': data.businessNumber,
              'representative_name': data.representativeName,
              'display_name': displayName,
              'location_label':
                  data.areas.isEmpty ? null : data.areas.join(', '),
              'specialty':
                  serviceLabels.isEmpty ? null : serviceLabels.join(', '),
              'intro': '',
              'description': data.portfolioUrl,
              'phone': null,
              'email': payload.email,
              'license_file_url': data.licenseFileUrl,
              'business_file_url': data.businessFileUrl,
              'insurance_file_url': data.insuranceFileUrl,
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
          'drone_registration':
              data.insuranceDroneNumber.isEmpty
                  ? null
                  : data.insuranceDroneNumber,
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
    required List<String> categoryLabels,
    required List<String> areaNames,
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

    final specialtyLabel = categoryLabels.join(', ');
    final locationLabel = areaNames.join(', ');

    await _client
        .from('operator_profiles')
        .update(<String, Object?>{
          'intro': intro,
          'description': description,
          'specialty': specialtyLabel.isEmpty ? null : specialtyLabel,
          'location_label': locationLabel.isEmpty ? null : locationLabel,
        })
        .eq('user_id', userId);

    await _tryOptionalWrite(
      () => _syncCategoriesByLabels(operatorId, categoryLabels),
    );
    await _tryOptionalWrite(() => _syncAreasByNames(operatorId, areaNames));

    await _tryOptionalWrite(
      () => _client
          .from('portfolio_assets')
          .delete()
          .eq('operator_id', operatorId),
    );
    await _client
        .from('portfolio_items')
        .delete()
        .eq('operator_id', operatorId);

    for (var i = 0; i < portfolioImageUrls.length; i += 1) {
      final url = portfolioImageUrls[i];
      final trimmed = url.trim();
      if (trimmed.isEmpty) continue;
      final item =
          await _client
              .from('portfolio_items')
              .insert(<String, Object?>{
                'operator_id': operatorId,
                'title': '포트폴리오 이미지 ${i + 1}',
                'body': trimmed,
                'is_published': true,
              })
              .select('id')
              .single();
      if (_isHttpUrl(trimmed)) {
        await _tryOptionalWrite(
          () => _client.from('portfolio_assets').insert(<String, Object?>{
            'portfolio_item_id': item['id'],
            'operator_id': operatorId,
            'kind': 'image',
            'url': trimmed,
            'sort_order': i,
            'alt_text': '운용자 포트폴리오',
          }),
        );
      }
    }
  }

  Future<void> _syncCategoriesByLabels(
    String operatorId,
    List<String> labels,
  ) async {
    await _client
        .from('operator_categories')
        .delete()
        .eq('operator_id', operatorId);
    if (labels.isEmpty) return;
    final rows = await _client
        .from('service_categories')
        .select('id,label')
        .inFilter('label', labels);
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

  Future<void> _syncAreasByNames(String operatorId, List<String> names) async {
    await _client
        .from('operator_service_areas')
        .delete()
        .eq('operator_id', operatorId);
    if (names.isEmpty) return;
    final rows = await _client
        .from('regions')
        .select('id,name')
        .inFilter('name', names);
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

  @override
  Future<void> saveFcmToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('user_push_tokens').upsert(<String, Object?>{
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
    } on PostgrestException {
      return;
    }
  }

  @override
  Future<bool> isRequestUnlocked(String requestId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final rows = await _client
          .from('operator_request_unlocks')
          .select('job_request_id')
          .eq('operator_user_id', userId)
          .eq('job_request_id', requestId)
          .limit(1);
      return rows.isNotEmpty;
    } on PostgrestException {
      return false;
    }
  }

  @override
  Future<void> unlockRequest(String requestId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('operator_request_unlocks').upsert(<String, Object?>{
      'operator_user_id': userId,
      'job_request_id': requestId,
    }, onConflict: 'operator_user_id,job_request_id');
  }

  @override
  Future<void> deleteMyAccount() async {
    if (_client.auth.currentUser == null) throw Exception('로그인이 필요합니다.');

    // All data deletion + auth user removal is handled server-side (service role bypasses RLS)
    final token = _client.auth.currentSession?.accessToken ?? '';
    final res = await _client.functions.invoke(
      'delete-user',
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    // Always sign out regardless of result
    try {
      await _client.auth.signOut();
    } catch (_) {}

    final status = res.status;
    if (status != 200) {
      final body = res.data;
      final detail =
          body is Map
              ? (body['error'] ?? body.toString())
              : body?.toString() ?? '';
      throw Exception('계정 삭제 실패 ($status): $detail');
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

  String _fileExt(String fileName, {required String fallback}) {
    final index = fileName.lastIndexOf('.');
    if (index < 0 || index == fileName.length - 1) return fallback;
    final ext = fileName.substring(index + 1).toLowerCase();
    return ext.replaceAll(RegExp(r'[^a-z0-9]'), '').isEmpty
        ? fallback
        : ext.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _imageContentType(String ext) {
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      _ => 'image/jpeg',
    };
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
    availableAreas.addAll(_splitLabels(row['location_label']));

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
            final assetUrls = nested.whereType<Map>().map(
              (asset) => (asset['url'] ?? '').toString(),
            );
            final bodyUrl = (item['body'] ?? '').toString();
            final isHttp =
                bodyUrl.startsWith('http://') ||
                bodyUrl.startsWith('https://');
            return <String>[
              if (isHttp) bodyUrl,
              ...assetUrls,
            ];
          }),
        }.where((url) => url.isNotEmpty).toList();

    final categoryLabels =
        categories.isNotEmpty
            ? categories
            : specialtyCategories.isNotEmpty
            ? specialtyCategories
            : defaultDroneCategories.map((category) => category.label).toList();

    final avatarUrl = row['avatar_url']?.toString();
    return DronePilot(
      id: row['id'].toString(),
      name: (row['display_name'] ?? row['business_name'] ?? '운용자').toString(),
      location: _readableLabel(row['location_label'], '지역 협의'),
      categories: categoryLabels,
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
      quoteOptions: categoryLabels,
      operatorStatus: (row['status'] ?? 'approved').toString(),
      avatarUrl: (avatarUrl?.isEmpty ?? true) ? null : avatarUrl,
    );
  }

  Iterable<String> _splitLabels(Object? value) {
    return (value ?? '')
        .toString()
        .split(',')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty);
  }

  String _readableLabel(Object? value, String fallback) {
    final label = (value ?? '').toString().trim();
    if (label.isEmpty || label == '??' || label == '?' || label == '-') {
      return fallback;
    }
    return label;
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
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const <PilotWorkRequestData>[];
    final profile =
        await _client
            .from('operator_profiles')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();
    final operatorId = profile?['id']?.toString();
    if (operatorId == null) return const <PilotWorkRequestData>[];

    // No `.eq('preferred_operator_id', operatorId)` filter here: broadcast
    // (map-posted) requests have `preferred_operator_id: null` and are only
    // visible to this operator once they've submitted a quote, via a
    // separate RLS policy keyed off the `quotes` table — see
    // supabase_job_request_broadcast_response_migration.sql. RLS already
    // restricts the result set to (a) requests targeted at this operator and
    // (b) requests this operator has quoted, so no extra filter is needed.
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
          operator_viewed_at,
          created_at,
          latitude,
          longitude,
          service_categories(label),
          quotes(id, message, proposed_price, operator_id)
        ''')
        .neq('client_id', userId)
        .order('created_at', ascending: false);

    return rows.map<PilotWorkRequestData>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final quotes =
          (map['quotes'] as List? ?? const [])
              .whereType<Map>()
              .map((q) => Map<String, dynamic>.from(q))
              .toList();
      final myQuote =
          quotes
              .where((q) => q['operator_id']?.toString() == operatorId)
              .firstOrNull;
      return PilotWorkRequestData(
        id: map['id'].toString(),
        category:
            ((map['service_categories'] as Map?)?['label'] ?? '작업 요청')
                .toString(),
        status: _operatorRequestStatus(
          (map['status'] ?? '').toString(),
          map['operator_viewed_at'],
          hasMyQuote: myQuote != null,
        ),
        location: (map['location_label'] ?? '지역 미정').toString(),
        dateRange: _dateRange(
          map['preferred_start_at'],
          map['preferred_end_at'],
        ),
        budget: _budgetLabel(map['budget_min'], map['budget_max']),
        client: (map['client_display_name'] ?? '고객').toString(),
        summary: (map['detail'] ?? map['title'] ?? '').toString(),
        remaining: '확인 필요',
        createdAt:
            DateTime.tryParse((map['created_at'] ?? '').toString()) ??
            DateTime.now(),
        myQuoteId: myQuote?['id']?.toString(),
        myQuoteMessage: myQuote?['message']?.toString(),
        myQuotePrice: (myQuote?['proposed_price'] as num?)?.toInt(),
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> markOperatorRequestSeen(String requestId) async {
    await _client
        .from('job_requests')
        .update(<String, Object?>{
          'operator_viewed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('status', 'open');
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
          preferred_operator_id,
          location_label,
          preferred_start_at,
          created_at,
          detail,
          budget_min,
          budget_max,
          contact_window,
          service_categories(label),
          quotes(id, status, proposed_price, message, operator_profiles(display_name, business_name))
        ''')
        .eq('client_id', userId)
        .order('created_at', ascending: false);

    final operatorIds =
        rows
            .map<String>(
              (row) => ((row as Map)['preferred_operator_id'] ?? '').toString(),
            )
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();
    final requestedOperators = <String, Map<String, dynamic>>{};
    if (operatorIds.isNotEmpty) {
      final operatorRows = await _client
          .from('operator_profiles')
          .select('id, display_name, business_name')
          .inFilter('id', operatorIds);
      for (final row in operatorRows) {
        final map = Map<String, dynamic>.from(row as Map);
        requestedOperators[map['id'].toString()] = map;
      }
    }

    return rows.map<UserQuoteSummary>((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final quote = _preferredQuoteForClient(
        List<Object?>.from(map['quotes'] as List? ?? const []),
      );
      final operator = quote['operator_profiles'] as Map?;
      final pilotId = (map['preferred_operator_id'] ?? '').toString();
      final requestedOperator = requestedOperators[pilotId];
      final price = (quote['proposed_price'] as num?)?.toInt();
      final jobStatus = (map['status'] ?? '').toString();
      final quoteStatus = (quote['status'] ?? '').toString();
      final hasQuote = quote.isNotEmpty;
      final status = _effectiveClientQuoteStatus(
        jobStatus: jobStatus,
        quoteStatus: quoteStatus,
      );
      return UserQuoteSummary(
        id: (map['id'] ?? '').toString(),
        pilotId: pilotId,
        pilotName:
            (operator?['display_name'] ??
                    operator?['business_name'] ??
                    requestedOperator?['display_name'] ??
                    requestedOperator?['business_name'] ??
                    '운용자 견적 대기중')
                .toString(),
        category:
            ((map['service_categories'] as Map?)?['label'] ?? '작업 요청')
                .toString(),
        area: (map['location_label'] ?? '지역 미정').toString(),
        date: _dateOnly(map['preferred_start_at'] ?? map['created_at']),
        status: _quoteStatusLabel(status, hasQuote: hasQuote),
        price: price == null ? '-' : '${(price / 10000).round()}만원',
        detail: (map['detail'] ?? '').toString(),
        budgetRange: _budgetLabel(map['budget_min'], map['budget_max']),
        contactWindow: (map['contact_window'] ?? '').toString(),
        message: (quote['message'] ?? '').toString(),
        createdAt:
            DateTime.tryParse((map['created_at'] ?? '').toString()) ??
            DateTime.now(),
        budgetMin: (map['budget_min'] as num?)?.toInt(),
        budgetMax: (map['budget_max'] as num?)?.toInt(),
        quoteId: quote['id']?.toString(),
        proposedPriceInt: (quote['proposed_price'] as num?)?.toInt(),
      );
    }).toList();
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const <AppNotification>[];
    try {
      final rows = await _client
          .from('notifications')
          .select('id, title, body, kind, created_at, read_at')
          .eq('recipient_id', userId)
          .isFilter('read_at', null)
          .order('created_at', ascending: false)
          .limit(20);
      return rows.map<AppNotification>((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return AppNotification(
          id: map['id'].toString(),
          title: (map['title'] ?? '알림').toString(),
          body: (map['body'] ?? '').toString(),
          kind: (map['kind'] ?? 'general').toString(),
          createdAt:
              DateTime.tryParse((map['created_at'] ?? '').toString()) ??
              DateTime.now(),
        );
      }).toList();
    } on PostgrestException {
      return const <AppNotification>[];
    }
  }

  @override
  Future<void> updateMyQuoteRequest({
    required String requestId,
    required String category,
    required String area,
    required String preferredDate,
    required String detail,
    required String budgetRange,
    required String contactWindow,
    int? proposedAmount,
    double? latitude,
    double? longitude,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }
    final budget = _parseBudgetLabel(budgetRange);
    final parsedDate = _parsePreferredDate(preferredDate);
    final categoryRows = await _client
        .from('service_categories')
        .select('id')
        .eq('label', category)
        .limit(1);
    final categoryId =
        categoryRows.isEmpty ? null : categoryRows.first['id']?.toString();
    await _client
        .from('job_requests')
        .update(<String, Object?>{
          'status': 'open',
          'operator_viewed_at': null,
          if (categoryId != null) 'category_id': categoryId,
          'location_label': area,
          'detail': detail,
          'budget_min': budget.$1,
          'budget_max': proposedAmount ?? budget.$2,
          'contact_window': contactWindow,
          if (parsedDate != null)
            'preferred_start_at': parsedDate.toUtc().toIso8601String(),
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        })
        .eq('id', requestId)
        .eq('client_id', userId);
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

  @override
  Future<void> submitQuoteForRequest(
    PilotWorkRequest request,
    String message, {
    int? proposedPrice,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }
    final operator =
        await _client
            .from('operator_profiles')
            .select('id, display_name, business_name')
            .eq('user_id', userId)
            .maybeSingle();
    if (operator == null) {
      throw StateError('운용자 등록을 먼저 완료해 주세요.');
    }

    final operatorId = operator['id'].toString();
    final existing = await _client
        .from('quotes')
        .select('id')
        .eq('job_request_id', request.id)
        .eq('operator_id', operatorId)
        .limit(1);
    final payload = <String, Object?>{
      'job_request_id': request.id,
      'operator_id': operatorId,
      'status': 'submitted',
      'proposed_price':
          proposedPrice ?? _proposedPriceFromBudget(request.budget),
      'estimated_time_label': '일정 협의 후 진행',
      'message':
          message.trim().isEmpty
              ? '${operator['display_name'] ?? operator['business_name'] ?? '운용자'}가 요청 내용을 확인하고 견적을 보냈습니다.'
              : message.trim(),
    };

    if (existing.isEmpty) {
      await _client.from('quotes').insert(payload);
    } else {
      await _client
          .from('quotes')
          .update(payload)
          .eq('id', existing.first['id']);
    }
    await _client
        .from('job_requests')
        .update(<String, Object?>{'status': 'quoted'})
        .eq('id', request.id);
    await _tryOptionalWrite(() => _insertClientQuoteNotification(request.id));
  }

  Future<void> _insertClientQuoteNotification(String jobRequestId) async {
    final rows = await _client
        .from('job_requests')
        .select('client_id, title, location_label')
        .eq('id', jobRequestId)
        .limit(1);
    if (rows.isEmpty) return;
    final row = rows.first;
    await _client.from('notifications').insert(<String, Object?>{
      'recipient_id': row['client_id'],
      'kind': 'quote_received',
      'title': '견적을 받았습니다',
      'body': '${row['location_label'] ?? '요청'} 견적이 도착했습니다.',
      'source_table': 'quotes',
      'source_id': jobRequestId,
      'dedupe_key': 'job_request:$jobRequestId:client_quote_received',
    });
  }

  String _jobStatusLabel(String status) => switch (status) {
    'open' => '요청 도착',
    'quoted' => '견적 보냄',
    'accepted' || 'paid' || 'contact_opened' || 'in_progress' => '진행 중',
    'completed' => '완료',
    'cancelled' => '취소',
    _ => '요청 도착',
  };

  String _operatorRequestStatus(
    String status,
    Object? viewedAt, {
    bool hasMyQuote = false,
  }) {
    if (hasMyQuote) return '견적 보냄';
    if (status == 'open') {
      return viewedAt == null ? '신규' : '확인 중';
    }
    return _jobStatusLabel(status);
  }

  String _quoteStatusLabel(String status, {required bool hasQuote}) =>
      QuoteStatusHelper.clientLabel(status, hasQuote: hasQuote);

  Map<String, dynamic> _preferredQuoteForClient(List<Object?> quoteRows) {
    final quotes =
        quoteRows
            .whereType<Map>()
            .map((quote) => Map<String, dynamic>.from(quote))
            .toList();
    if (quotes.isEmpty) return const <String, Object?>{};
    quotes.sort((a, b) {
      final aRank = QuoteStatusHelper.quoteRank((a['status'] ?? '').toString());
      final bRank = QuoteStatusHelper.quoteRank((b['status'] ?? '').toString());
      return bRank.compareTo(aRank);
    });
    return quotes.first;
  }

  String _effectiveClientQuoteStatus({
    required String jobStatus,
    required String quoteStatus,
  }) => QuoteStatusHelper.effectiveClientStatus(
    jobStatus: jobStatus,
    quoteStatus: quoteStatus,
  );

  int _proposedPriceFromBudget(String budget) {
    final numbers =
        RegExp(r'\d+')
            .allMatches(budget)
            .map((match) => int.tryParse(match.group(0) ?? '') ?? 0)
            .where((value) => value > 0)
            .toList();
    if (numbers.isEmpty) return 300000;
    return numbers.last * 10000;
  }

  (int?, int?) _parseBudgetLabel(String label) {
    return switch (label) {
      '0~30만원' => (0, 300000),
      '~30만원' => (0, 300000),
      '30~50만원' => (300000, 500000),
      '50~100만원' => (500000, 1000000),
      '100만원 이상' => (1000000, null),
      '예산 협의' => (null, null),
      _ => (null, null),
    };
  }

  String _budgetLabel(Object? min, Object? max) {
    final minValue = (min as num?)?.toInt();
    final maxValue = (max as num?)?.toInt();
    if (minValue == null && maxValue == null) return '예산 협의';
    if (minValue == null) return '~${(maxValue! / 10000).round()}만원';
    if (maxValue == null) return '${(minValue / 10000).round()}만원 이상';
    if (minValue == 0 && maxValue == 300000) return '0~30만원';
    if (minValue == 0 && maxValue == 500000) return '0~50만원';
    if (minValue == 0) return '~${(maxValue / 10000).round()}만원';
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
