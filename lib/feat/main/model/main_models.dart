class PilotDroneForm {
  PilotDroneForm({
    this.maker = 'DJI',
    this.model = '',
    Set<String>? categories,
    Set<String>? sensors,
    this.registrationNumber = '',
    this.photoUploaded = false,
  }) : categories = categories ?? <String>{},
       sensors = sensors ?? <String>{};

  String maker;
  String model;
  Set<String> categories;
  Set<String> sensors;
  String registrationNumber;
  bool photoUploaded;
}

class PilotOnboardingData {
  String licenseType = '초경량비행장치 조종자';
  String licenseNumber = '';
  bool licenseFrontUploaded = false;
  bool licenseBackUploaded = false;
  String? licenseFileUrl;
  String? licenseFileName;
  String businessName = '';
  String businessNumber = '';
  String representativeName = '';
  String? businessFileUrl;
  String? businessFileName;
  String insuranceCompany = 'DB손해보험';
  String insuranceNumber = '';
  bool insuranceUploaded = false;
  List<PilotDroneForm> drones = <PilotDroneForm>[PilotDroneForm()];
  Set<String> areas = <String>{};
  Set<String> portfolioTypes = <String>{};
  String portfolioUrl = '';
  bool sampleUploaded = false;
  bool submitted = false;
}

class OperatorFeedPost {
  OperatorFeedPost({
    required this.id,
    required this.caption,
    required this.createdAt,
    this.imageBytes,
    this.imageUrl,
  });

  final String id;
  final String caption;
  final DateTime createdAt;
  final List<int>? imageBytes;
  final String? imageUrl;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.kind,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String kind;
}

class PilotWorkRequest {
  const PilotWorkRequest({
    required this.id,
    required this.category,
    required this.status,
    required this.location,
    required this.distance,
    required this.dateRange,
    required this.budget,
    required this.client,
    required this.summary,
    required this.progress,
    required this.remaining,
    required this.mapLabel,
    this.myQuoteId,
    this.myQuoteMessage,
    this.myQuotePrice,
  });

  final String id;
  final String category;
  final String status;
  final String location;
  final String distance;
  final String dateRange;
  final String budget;
  final String client;
  final String summary;
  final String progress;
  final String remaining;
  final String mapLabel;
  final String? myQuoteId;
  final String? myQuoteMessage;
  final int? myQuotePrice;
}
