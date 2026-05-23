import 'package:flutter/material.dart';

class DronePilot {
  const DronePilot({
    required this.id,
    required this.name,
    required this.location,
    required this.categories,
    required this.availableAreas,
    required this.permittedAreas,
    required this.basePrice,
    required this.contact,
    required this.mapX,
    required this.mapY,
    required this.portfolioImages,
    required this.specialty,
    required this.intro,
    required this.description,
    required this.quoteOptions,
  });

  final String id;
  final String name;
  final String location;
  final List<String> categories;
  final List<String> availableAreas;
  final List<String> permittedAreas;
  final int basePrice;
  final String contact;
  final double mapX;
  final double mapY;
  final List<String> portfolioImages;
  final String specialty;
  final String intro;
  final String description;
  final List<String> quoteOptions;

  bool hasPermitFor(String area) => permittedAreas.contains(area);
  bool hasCategory(String category) =>
      category == '전체' || categories.contains(category);

  String get priceLabel => '${(basePrice / 10000).round()}만원부터';
}

class DroneCategory {
  const DroneCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
}
