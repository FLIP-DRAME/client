import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'drone_pilot_model.dart';
import 'mock_drone_pilot_api.dart';

abstract class DronePilotApi {
  Future<List<DronePilot>> fetchPilots({String? priorityArea, String? category});
  Future<List<DroneCategory>> fetchCategories();
  Future<List<String>> fetchRegions();
  Future<DronePilot?> fetchPilotById(String id);
  Future<void> submitOperatorRegistration(PilotRegistrationPayload payload);
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
          rating_avg,
          completed_jobs_count,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order)
        ''')
        .eq('status', 'approved')
        .order('rating_avg', ascending: false);

    final pilots = rows
        .map<DronePilot>((row) => _pilotFromRow(Map<String, dynamic>.from(row as Map)))
        .where((pilot) {
          final categoryMatch =
              category == null || category == '전체' || pilot.hasCategory(category);
          final areaMatch = priorityArea == null ||
              priorityArea == '전체' ||
              pilot.availableAreas.contains(priorityArea) ||
              pilot.permittedAreas.contains(priorityArea);
          return categoryMatch && areaMatch;
        })
        .toList();

    pilots.sort((a, b) {
      if (priorityArea != null && priorityArea != '전체') {
        final areaCompare =
            (a.hasPermitFor(priorityArea) ? 0 : 1).compareTo(b.hasPermitFor(priorityArea) ? 0 : 1);
        if (areaCompare != 0) return areaCompare;
      }
      return b.rating.compareTo(a.rating);
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
          rating_avg,
          completed_jobs_count,
          operator_categories(service_categories(slug,label)),
          operator_service_areas(permission_type, regions(name)),
          portfolio_assets(url, sort_order)
        ''')
        .eq('id', id)
        .limit(1);
    if (rows.isEmpty) return null;
    return _pilotFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  @override
  Future<void> submitOperatorRegistration(PilotRegistrationPayload payload) async {
    final data = payload.data;
    final displayName = payload.nickname.isNotEmpty ? payload.nickname : payload.name;
    final operator = await _client
        .from('operator_profiles')
        .upsert(
          <String, Object?>{
            'user_id': payload.userId,
            'status': 'pending_review',
            'business_name': data.businessName,
            'business_number': data.businessNumber,
            'representative_name': data.representativeName,
            'display_name': displayName,
            'location_label': data.areas.isEmpty ? null : data.areas.join(', '),
            'specialty': data.portfolioTypes.isEmpty ? null : data.portfolioTypes.join(', '),
            'intro': 'Drame 운용자 심사 대기 프로필입니다.',
            'description': data.portfolioUrl,
            'phone': null,
            'email': payload.email,
          },
          onConflict: 'user_id',
        )
        .select('id')
        .single();

    final operatorId = operator['id'].toString();
    if (data.licenseNumber.toString().isNotEmpty) {
      await _client.from('operator_licenses').insert(<String, Object?>{
        'operator_id': operatorId,
        'license_type': data.licenseType,
        'license_number': data.licenseNumber,
      });
    }
    if (data.insuranceNumber.toString().isNotEmpty) {
      await _client.from('operator_insurances').insert(<String, Object?>{
        'operator_id': operatorId,
        'company': data.insuranceCompany,
        'policy_number': data.insuranceNumber,
      });
    }
    for (final drone in data.drones) {
      if (drone.model.toString().trim().isEmpty) continue;
      await _client.from('operator_drones').insert(<String, Object?>{
        'operator_id': operatorId,
        'maker': drone.maker,
        'model': drone.model,
        'registration_number': drone.registrationNumber,
      });
    }
  }

  DronePilot _pilotFromRow(Map<String, dynamic> row) {
    final categoryRows = List<Object?>.from(row['operator_categories'] as List? ?? const []);
    final categories = categoryRows
        .map((item) => (item as Map)['service_categories'])
        .whereType<Map>()
        .map((item) => (item['label'] ?? '').toString())
        .where((label) => label.isNotEmpty)
        .toSet()
        .toList();

    final areaRows = List<Object?>.from(row['operator_service_areas'] as List? ?? const []);
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

    final assetRows = List<Object?>.from(row['portfolio_assets'] as List? ?? const []);
    final images = assetRows
        .whereType<Map>()
        .map((item) => (item['url'] ?? '').toString())
        .where((url) => url.isNotEmpty)
        .toList();

    return DronePilot(
      id: row['id'].toString(),
      name: (row['display_name'] ?? row['business_name'] ?? '운용자').toString(),
      location: (row['location_label'] ?? '지역 협의').toString(),
      categories: categories.isEmpty ? const <String>['항공촬영'] : categories,
      availableAreas: availableAreas.isEmpty ? const <String>['전체'] : availableAreas.toList(),
      permittedAreas: permittedAreas.toList(),
      basePrice: (row['base_price'] as num?)?.toInt() ?? 0,
      contact: (row['phone'] ?? '').toString(),
      rating: (row['rating_avg'] as num?)?.toDouble() ?? 0,
      completedJobs: (row['completed_jobs_count'] as num?)?.toInt() ?? 0,
      mapX: 0.5,
      mapY: 0.5,
      portfolioImages: images.isEmpty ? mockPilots.first.portfolioImages : images,
      specialty: (row['specialty'] ?? '').toString(),
      intro: (row['intro'] ?? '').toString(),
      description: (row['description'] ?? '').toString(),
      responseTime: (row['response_time_label'] ?? '문의 후 안내').toString(),
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
}
