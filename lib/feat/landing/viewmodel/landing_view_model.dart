import '../model/landing_models.dart';

class LandingViewModel {
  const LandingViewModel();

  List<LandingServiceItem> get services => const <LandingServiceItem>[
    LandingServiceItem(title: '항공촬영', description: '홍보 영상과 현장 기록'),
    LandingServiceItem(title: '농약방제', description: '농경지 방제 작업'),
    LandingServiceItem(title: '시설점검', description: '지붕, 태양광, 교량 점검'),
  ];
}
