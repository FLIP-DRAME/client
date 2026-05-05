class DronePilot {
  const DronePilot({
    required this.id,
    required this.name,
    required this.location,
    required this.availableAreas,
    required this.permittedAreas,
    required this.basePrice,
    required this.contact,
    required this.rating,
    required this.completedJobs,
    required this.mapX,
    required this.mapY,
    required this.portfolioImages,
    required this.specialty,
  });

  final String id;
  final String name;
  final String location;
  final List<String> availableAreas;
  final List<String> permittedAreas;
  final int basePrice;
  final String contact;
  final double rating;
  final int completedJobs;
  final double mapX;
  final double mapY;
  final List<String> portfolioImages;
  final String specialty;

  bool hasPermitFor(String area) => permittedAreas.contains(area);

  String get priceLabel => '${(basePrice / 10000).round()}만원부터';
}
