import 'package:drane/feat/main/network/mock_drone_pilot_api.dart';
import 'package:drane/feat/quote/network/mock_quote_api.dart';
import 'package:drane/feat/quote/network/quote_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prioritizes permitted pilots for selected area', () async {
    final pilots = await MockDronePilotApi().fetchPilots(priorityArea: '서울');

    expect(pilots.first.hasPermitFor('서울'), isTrue);
    expect(pilots.first.name, '이서연 운용자');
  });

  test('creates a complete local quote flow model', () async {
    final pilot = mockPilots.first;
    final request = QuoteRequest(
      pilot: pilot,
      category: pilot.categories.first,
      area: pilot.availableAreas.first,
      preferredDate: '2026.05.20',
      detail: '현장 분위기를 보여주는 항공 촬영과 기본 보정본이 필요합니다.',
      budgetRange: '50~100만원',
      contactWindow: '평일 오후 2시 이후',
    );

    final api = MockQuoteApi();
    final estimate = await api.createEstimate(request);
    final payment = api.createPaymentInstruction(estimate);
    final contact = api.createContactAccess(estimate);

    expect(estimate.proposedPrice, greaterThan(pilot.basePrice));
    expect(payment.amount, estimate.proposedPrice);
    expect(contact.phone, pilot.contact);
  });
}
