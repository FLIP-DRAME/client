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
    this.operatorStatus = 'approved',
    this.avatarUrl,
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
  final String operatorStatus;
  final String? avatarUrl;

  bool hasPermitFor(String area) => permittedAreas.contains(area);
  bool hasCategory(String category) =>
      category == '전체' || categories.contains(category);

  String get priceLabel => '${(basePrice / 10000).round()}만원부터';
  bool get isApproved => operatorStatus == 'approved';
  bool get isPendingReview => operatorStatus == 'pending_review';
  String get displayLocation {
    final value = location.trim();
    if (!_isReadableArea(value)) {
      return '지역 협의';
    }
    return value;
  }

  String get primaryDisplayArea {
    for (final area in availableAreas) {
      final value = area.trim();
      if (_isReadableArea(value) && value != '전체') {
        return value;
      }
    }
    return displayLocation;
  }

  String get displaySpecialty {
    final cleaned = specialty.replaceAll('?', '').replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) {
      return categories.isNotEmpty ? categories.join(' · ') : '-';
    }
    return specialty;
  }

  bool _isReadableArea(String value) =>
      value.isNotEmpty && value != '??' && value != '?' && value != '-';
}

class OperatorReview {
  const OperatorReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;
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
