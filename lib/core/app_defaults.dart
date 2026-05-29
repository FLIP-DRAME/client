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
      '인천': <String>[
        '중구', '동구', '미추홀구', '연수구', '남동구', '부평구', '계양구', '서구', '강화군', '옹진군',
      ],
      '서울': <String>[
        '강남', '강동', '강북', '강서', '관악', '광진', '구로', '금천',
        '노원', '도봉', '동대문', '동작', '마포', '서대문', '서초', '성동',
        '성북', '송파', '양천', '영등포', '용산', '은평', '종로', '중구', '중랑',
      ],
      '경기': <String>[
        '수원', '성남', '고양', '용인', '부천', '안산', '안양', '남양주',
        '화성', '평택', '의정부', '파주', '시흥', '광명', '김포', '광주',
        '군포', '하남', '오산', '이천', '구리', '안성', '의왕', '과천', '양주',
      ],
      '강원': <String>[
        '춘천', '원주', '강릉', '동해', '태백', '속초', '삼척',
        '홍천', '횡성', '영월', '평창', '정선', '철원', '화천',
        '양구', '인제', '고성', '양양',
      ],
      '충청': <String>[
        '대전', '세종', '청주', '천안', '공주', '보령', '아산', '서산',
        '논산', '계룡', '당진', '충주', '제천', '보은', '옥천', '영동',
        '진천', '괴산', '음성', '단양', '청양', '태안',
      ],
      '전라': <String>[
        '광주', '전주', '익산', '군산', '정읍', '남원', '김제',
        '목포', '여수', '순천', '나주', '광양', '담양', '곡성', '구례',
        '고흥', '보성', '화순', '장흥', '강진', '해남', '영암', '무안',
        '함평', '영광', '장성', '완도', '진도',
      ],
      '경상': <String>[
        '부산', '대구', '울산', '창원', '포항', '경주', '김천', '안동',
        '구미', '영주', '영천', '상주', '문경', '경산', '진주', '통영',
        '사천', '김해', '밀양', '거제', '양산', '거창', '합천',
      ],
      '제주': <String>[
        '제주시', '서귀포', '애월', '조천', '구좌', '한림', '대정', '안덕', '표선', '성산',
      ],
    };

const Map<String, List<String>> defaultServiceNeighborhoods =
    <String, List<String>>{};
