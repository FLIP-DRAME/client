import 'drone_pilot_model.dart';

class MockDronePilotApi {
  Future<List<DronePilot>> fetchPilots({String? priorityArea}) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    final pilots = List<DronePilot>.from(mockPilots);
    if (priorityArea == null || priorityArea == '전체') {
      return pilots;
    }

    pilots.sort((a, b) {
      final aPriority = a.hasPermitFor(priorityArea) ? 0 : 1;
      final bPriority = b.hasPermitFor(priorityArea) ? 0 : 1;
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return b.rating.compareTo(a.rating);
    });
    return pilots;
  }
}

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
    availableAreas: <String>['서울', '경기'],
    permittedAreas: <String>['서울'],
    basePrice: 300000,
    contact: '010-2418-9031',
    rating: 5.0,
    completedJobs: 52,
    mapX: 0.46,
    mapY: 0.24,
    specialty: '농약 방제, 도심 홍보 영상',
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
    availableAreas: <String>['서울', '경기'],
    permittedAreas: <String>['경기'],
    basePrice: 250000,
    contact: '010-5529-1844',
    rating: 4.9,
    completedJobs: 37,
    mapX: 0.42,
    mapY: 0.32,
    specialty: '부동산 영상, 항공 파노라마',
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
    availableAreas: <String>['강원', '경기'],
    permittedAreas: <String>['강원'],
    basePrice: 800000,
    contact: '010-7610-3382',
    rating: 4.8,
    completedJobs: 28,
    mapX: 0.68,
    mapY: 0.23,
    specialty: '측량·매핑, 대형 건설 현장',
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
    availableAreas: <String>['충청', '경기'],
    permittedAreas: <String>['충청'],
    basePrice: 320000,
    contact: '010-4830-6702',
    rating: 4.7,
    completedJobs: 61,
    mapX: 0.35,
    mapY: 0.45,
    specialty: '시설 점검, 태양광 패널 열화상',
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
    availableAreas: <String>['경상', '전라'],
    permittedAreas: <String>['경상'],
    basePrice: 500000,
    contact: '010-9064-1195',
    rating: 4.9,
    completedJobs: 142,
    mapX: 0.67,
    mapY: 0.68,
    specialty: '행사·이벤트 촬영, 드론 라이트쇼',
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
    availableAreas: <String>['제주'],
    permittedAreas: <String>['제주'],
    basePrice: 380000,
    contact: '010-3255-7810',
    rating: 4.8,
    completedJobs: 94,
    mapX: 0.28,
    mapY: 0.90,
    specialty: '관광지, 리조트, 해안선 촬영',
    portfolioImages: <String>[
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1483683804023-6ccdb62f86ef?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=85',
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=85',
    ],
  ),
];
