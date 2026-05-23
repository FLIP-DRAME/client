import 'package:flutter/material.dart';

import '../feat/main/model/drone_pilot_model.dart';

const List<String> defaultPortfolioImages = <String>[
  'https://images.unsplash.com/photo-1508614589041-895b88991e3e?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=85',
];

const List<DroneCategory> defaultDroneCategories = <DroneCategory>[
  DroneCategory(
    id: 'aerial',
    label: '항공촬영',
    description: '홍보 영상, 행사, 부동산 항공 컷',
    icon: Icons.camera_alt_rounded,
  ),
  DroneCategory(
    id: 'spray',
    label: '농약방제',
    description: '논밭 방제와 작업 기록',
    icon: Icons.grass_rounded,
  ),
  DroneCategory(
    id: 'estate',
    label: '부동산',
    description: '건물 외관과 입지 영상',
    icon: Icons.home_work_rounded,
  ),
  DroneCategory(
    id: 'mapping',
    label: '측량·매핑',
    description: '부지 측량과 정사영상',
    icon: Icons.map_rounded,
  ),
  DroneCategory(
    id: 'inspection',
    label: '시설점검',
    description: '태양광, 지붕, 교량 점검',
    icon: Icons.engineering_rounded,
  ),
  DroneCategory(
    id: 'event',
    label: '행사촬영',
    description: '축제, 스포츠, 이벤트 촬영',
    icon: Icons.celebration_rounded,
  ),
];

const List<String> defaultServiceAreas = <String>[
  '전체',
  '서울',
  '경기',
  '강원',
  '충청',
  '전라',
  '경상',
  '제주',
];

const Map<String, List<String>> defaultServiceDistricts =
    <String, List<String>>{
      '서울': <String>['강남', '관악', '회기', '마포', '성수', '잠실'],
      '경기': <String>['성남', '수원', '고양', '용인', '화성', '이천'],
      '강원': <String>['강릉', '춘천', '원주', '속초'],
      '충청': <String>['태안', '천안', '청주', '대전', '세종'],
      '전라': <String>['전주', '광주', '여수', '순천', '군산'],
      '경상': <String>['부산', '해운대', '대구', '울산', '포항'],
      '제주': <String>['애월', '제주시', '서귀포', '성산'],
    };

const Map<String, List<String>> defaultServiceNeighborhoods =
    <String, List<String>>{
      '강남': <String>['역삼동', '논현동', '삼성동', '청담동', '대치동'],
      '관악': <String>['봉천동', '신림동', '낙성대동', '대학동'],
      '회기': <String>['회기동', '휘경동', '이문동'],
      '마포': <String>['상암동', '합정동', '망원동', '공덕동'],
      '성수': <String>['성수동1가', '성수동2가', '뚝섬동'],
      '잠실': <String>['잠실동', '석촌동', '송파동'],
      '성남': <String>['분당동', '정자동', '판교동', '서현동'],
      '수원': <String>['영통동', '인계동', '광교동', '매탄동'],
      '고양': <String>['일산동', '마두동', '화정동'],
      '용인': <String>['기흥동', '수지동', '처인동'],
      '화성': <String>['동탄동', '향남읍', '봉담읍'],
      '이천': <String>['창전동', '증포동', '부발읍'],
    };
