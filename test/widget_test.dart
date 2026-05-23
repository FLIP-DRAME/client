import 'package:mode/core/app_defaults.dart';
import 'package:mode/feat/main/model/drone_pilot_model.dart';
import 'package:mode/feat/quote/model/quote_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default category data remains available before remote load', () {
    expect(defaultDroneCategories, isNotEmpty);
    expect(defaultDroneCategories.first.label, '항공촬영');
    expect(defaultServiceAreas.first, '전체');
  });

  test('quote estimate preserves Supabase identifiers through copyWith', () {
    final pilot = DronePilot(
      id: 'operator-id',
      name: '운용자',
      location: '서울',
      categories: const <String>['항공촬영'],
      availableAreas: const <String>['서울'],
      permittedAreas: const <String>['서울'],
      basePrice: 300000,
      contact: '010-0000-0000',
      mapX: 0.5,
      mapY: 0.5,
      portfolioImages: defaultPortfolioImages,
      specialty: '항공촬영',
      intro: '소개',
      description: '설명',
      quoteOptions: const <String>['항공촬영'],
    );
    final request = QuoteRequest(
      pilot: pilot,
      category: '항공촬영',
      area: '서울',
      preferredDate: '2026.05.20',
      detail: '요청',
      budgetRange: '50~100만원',
      contactWindow: '오후',
    );
    final estimate = QuoteEstimate(
      request: request,
      proposedPrice: 420000,
      estimatedTime: '촬영 2시간',
      includedItems: const <String>['촬영'],
      message: '견적',
    ).copyWith(
      jobRequestId: 'job-id',
      quoteId: 'quote-id',
      paymentId: 'payment-id',
    );

    expect(estimate.jobRequestId, 'job-id');
    expect(estimate.quoteId, 'quote-id');
    expect(estimate.paymentId, 'payment-id');
  });
}
