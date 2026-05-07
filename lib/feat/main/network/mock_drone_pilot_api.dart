import 'drone_pilot_model.dart';

class MockDronePilotApi {
  Future<List<DronePilot>> fetchPilots({
    String? priorityArea,
    String? category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    final pilots =
        mockPilots.where((pilot) {
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
        }).toList();

    pilots.sort((a, b) {
      final aCategory = category != null && a.hasCategory(category) ? 0 : 1;
      final bCategory = category != null && b.hasCategory(category) ? 0 : 1;
      if (aCategory != bCategory) {
        return aCategory.compareTo(bCategory);
      }
      if (priorityArea != null && priorityArea != '전체') {
        final aPriority = a.hasPermitFor(priorityArea) ? 0 : 1;
        final bPriority = b.hasPermitFor(priorityArea) ? 0 : 1;
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
      }
      return b.rating.compareTo(a.rating);
    });
    return pilots;
  }
}

const List<DroneCategory> mockDroneCategories = <DroneCategory>[
  DroneCategory(
    id: 'aerial',
    label: '항공촬영',
    description: '홍보 영상, 행사, 부동산 항공 컷',
    iconCodePoint: 0xe412,
  ),
  DroneCategory(
    id: 'spray',
    label: '농약방제',
    description: '논밭 방제와 작업 기록',
    iconCodePoint: 0xf06c9,
  ),
  DroneCategory(
    id: 'estate',
    label: '부동산',
    description: '건물 외관과 입지 영상',
    iconCodePoint: 0xe0af,
  ),
  DroneCategory(
    id: 'mapping',
    label: '측량·매핑',
    description: '부지 측량과 정사영상',
    iconCodePoint: 0xe55b,
  ),
  DroneCategory(
    id: 'inspection',
    label: '시설점검',
    description: '태양광, 지붕, 교량 점검',
    iconCodePoint: 0xf02cc,
  ),
  DroneCategory(
    id: 'event',
    label: '행사촬영',
    description: '축제, 스포츠, 이벤트 촬영',
    iconCodePoint: 0xe87d,
  ),
];

const List<String> mockServiceAreas = <String>[
  '전체',
  '서울',
  '경기',
  '강원',
  '충청',
  '전라',
  '경상',
  '제주',
];

const List<DronePilot> mockPilots = <DronePilot>[
  DronePilot(
    id: 'pilot-001',
    name: '이서연 운용자',
    location: '서울 마포',
    categories: <String>['항공촬영', '농약방제'],
    availableAreas: <String>['서울', '경기'],
    permittedAreas: <String>['서울'],
    basePrice: 300000,
    contact: '010-2418-9031',
    rating: 5.0,
    completedJobs: 52,
    mapX: 0.46,
    mapY: 0.24,
    specialty: '농약 방제, 도심 홍보 영상',
    intro: '도심 홍보 영상과 농경지 방제를 함께 처리하는 서울권 운용자입니다.',
    description:
        '비행 허가 확인, 촬영 동선 설계, 원본 납품까지 한 번에 진행합니다. 도심 촬영 경험이 많아 안전거리와 민원 리스크를 사전에 체크합니다.',
    responseTime: '평균 20분 내',
    quoteOptions: <String>['도심 항공촬영', '농약 방제', '기본 편집본'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1508614589041-895b88991e3e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
  DronePilot(
    id: 'pilot-002',
    name: '김민준 운용자',
    location: '경기 성남',
    categories: <String>['항공촬영', '부동산'],
    availableAreas: <String>['서울', '경기'],
    permittedAreas: <String>['경기'],
    basePrice: 250000,
    contact: '010-5529-1844',
    rating: 4.9,
    completedJobs: 37,
    mapX: 0.42,
    mapY: 0.32,
    specialty: '부동산 영상, 항공 파노라마',
    intro: '아파트, 상가, 토지 홍보용 항공 영상을 빠르게 제작합니다.',
    description:
        '부동산 매물의 입지, 조망, 주변 인프라가 잘 보이도록 촬영합니다. 숏폼 홍보용 컷과 상세 매물 소개용 컷을 구분해 납품합니다.',
    responseTime: '평균 30분 내',
    quoteOptions: <String>['부동산 홍보 영상', '항공 파노라마', '짧은 편집본'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
  DronePilot(
    id: 'pilot-003',
    name: '박지훈 운용자',
    location: '강원 강릉',
    categories: <String>['측량·매핑', '시설점검'],
    availableAreas: <String>['강원', '경기'],
    permittedAreas: <String>['강원'],
    basePrice: 800000,
    contact: '010-7610-3382',
    rating: 4.8,
    completedJobs: 28,
    mapX: 0.68,
    mapY: 0.23,
    specialty: '측량·매핑, 대형 건설 현장',
    intro: '건설 부지와 대형 현장 매핑에 강한 강원권 운용자입니다.',
    description:
        '부지 현황 기록, 정사영상, 공정 비교용 항공 데이터를 제공합니다. 현장 관리자와 작업 범위를 먼저 정리한 뒤 안전 기준에 맞춰 비행합니다.',
    responseTime: '평균 35분 내',
    quoteOptions: <String>['정사영상', '건설 현장 기록', 'DXF 납품 상담'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
  DronePilot(
    id: 'pilot-004',
    name: '서해 드론웍스',
    location: '충남 태안',
    categories: <String>['시설점검', '해양·산림'],
    availableAreas: <String>['충청', '경기'],
    permittedAreas: <String>['충청'],
    basePrice: 320000,
    contact: '010-4830-6702',
    rating: 4.7,
    completedJobs: 61,
    mapX: 0.35,
    mapY: 0.45,
    specialty: '시설 점검, 태양광 패널 열화상',
    intro: '태양광 패널과 해안 시설 점검에 특화된 충청권 팀입니다.',
    description:
        '열화상 촬영과 육안 점검 컷을 함께 제공하고, 이상 지점을 리포트 형태로 정리합니다. 해안가와 산림 인접 시설 경험이 많습니다.',
    responseTime: '평균 40분 내',
    quoteOptions: <String>['태양광 점검', '시설 외관 점검', '리포트 납품'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
  DronePilot(
    id: 'pilot-005',
    name: '남해 시네마틱',
    location: '부산 해운대',
    categories: <String>['항공촬영', '행사촬영'],
    availableAreas: <String>['경상', '전라'],
    permittedAreas: <String>['경상'],
    basePrice: 500000,
    contact: '010-9064-1195',
    rating: 4.9,
    completedJobs: 142,
    mapX: 0.67,
    mapY: 0.68,
    specialty: '행사·이벤트 촬영, 드론 라이트쇼',
    intro: '행사 규모와 동선을 고려해 현장감 있는 항공 영상을 촬영합니다.',
    description:
        '축제, 공연, 야외 행사에서 관객 동선과 무대 구성을 살려 촬영합니다. 당일 하이라이트 컷과 추후 편집용 원본을 분리 납품합니다.',
    responseTime: '평균 25분 내',
    quoteOptions: <String>['행사 항공촬영', '드론 라이트쇼 상담', '하이라이트 컷'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
  DronePilot(
    id: 'pilot-006',
    name: '오름 드론웍스',
    location: '제주 애월',
    categories: <String>['항공촬영', '해양·산림'],
    availableAreas: <String>['제주'],
    permittedAreas: <String>['제주'],
    basePrice: 380000,
    contact: '010-3255-7810',
    rating: 4.8,
    completedJobs: 94,
    mapX: 0.28,
    mapY: 0.90,
    specialty: '관광지, 리조트, 해안선 촬영',
    intro: '제주 해안선과 리조트 홍보 영상에 특화된 운용자입니다.',
    description:
        '관광지와 숙박 공간의 분위기를 살리는 시네마틱 항공 컷을 제공합니다. 바람과 기상 변화가 큰 제주 환경을 고려해 대체 일정을 함께 제안합니다.',
    responseTime: '평균 30분 내',
    quoteOptions: <String>['리조트 항공촬영', '해안선 촬영', '관광 홍보 영상'],
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1483683804023-6ccdb62f86ef?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
];
