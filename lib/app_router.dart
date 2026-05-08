import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'feat/main/network/drone_pilot_model.dart';
import 'feat/main/network/mock_drone_pilot_api.dart';
import 'feat/main/ui/pages/main_page.dart';
import 'feat/portfolio/ui/pages/portfolio_page.dart';
import 'feat/quote/network/mock_quote_api.dart';
import 'feat/quote/network/quote_model.dart';
import 'feat/quote/ui/pages/contact_access_page.dart';
import 'feat/quote/ui/pages/payment_page.dart';
import 'feat/quote/ui/pages/quote_estimate_page.dart';
import 'feat/quote/ui/pages/quote_request_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const DrameHomePage(),
    ),
    GoRoute(
      path: '/portfolio/:pilotId',
      name: 'portfolio',
      builder: (context, state) {
        final pilot = _resolvePilot(state);
        return PilotPortfolioPage(pilot: pilot);
      },
    ),
    GoRoute(
      path: '/quote/request/:pilotId',
      name: 'quote-request',
      builder: (context, state) {
        final pilot = _resolvePilot(state);
        return QuoteRequestPage(pilot: pilot);
      },
    ),
    GoRoute(
      path: '/quote/estimate',
      name: 'quote-estimate',
      builder: (context, state) {
        final estimate =
            state.extra is QuoteEstimate
                ? state.extra! as QuoteEstimate
                : _fallbackEstimate();
        return QuoteEstimatePage(estimate: estimate);
      },
    ),
    GoRoute(
      path: '/quote/payment',
      name: 'quote-payment',
      builder: (context, state) {
        final extra = state.extra;
        final estimate =
            extra is Map<String, Object?> && extra['estimate'] is QuoteEstimate
                ? extra['estimate']! as QuoteEstimate
                : _fallbackEstimate();
        final paymentInstruction =
            extra is Map<String, Object?> &&
                    extra['paymentInstruction'] is PaymentInstruction
                ? extra['paymentInstruction']! as PaymentInstruction
                : MockQuoteApi().createPaymentInstruction(estimate);
        return PaymentPage(
          estimate: estimate,
          paymentInstruction: paymentInstruction,
        );
      },
    ),
    GoRoute(
      path: '/quote/contact',
      name: 'quote-contact',
      builder: (context, state) {
        final extra = state.extra;
        final estimate =
            extra is Map<String, Object?> && extra['estimate'] is QuoteEstimate
                ? extra['estimate']! as QuoteEstimate
                : _fallbackEstimate();
        final contactAccess =
            extra is Map<String, Object?> &&
                    extra['contactAccess'] is ContactAccess
                ? extra['contactAccess']! as ContactAccess
                : MockQuoteApi().createContactAccess(estimate);
        return ContactAccessPage(
          estimate: estimate,
          contactAccess: contactAccess,
        );
      },
    ),
    GoRoute(
      path: '/pilot/register',
      name: 'pilot-register',
      builder: (context, state) => const PilotRegistrationPage(),
    ),
    GoRoute(
      path: '/pilot/mypage',
      name: 'pilot-mypage',
      builder: (context, state) => const OperatorMyPage(),
    ),
    GoRoute(
      path: '/pilot/requests',
      name: 'pilot-requests',
      builder: (context, state) {
        final initialRequest =
            state.extra is PilotWorkRequest
                ? state.extra! as PilotWorkRequest
                : mockPilotWorkRequests.first;
        return PilotRequestReviewPage(initialRequest: initialRequest);
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/'),
            child: const Text('메인으로 돌아가기'),
          ),
        ),
      ),
);

DronePilot _resolvePilot(GoRouterState state) {
  if (state.extra is DronePilot) {
    return state.extra! as DronePilot;
  }
  final pilotId = state.pathParameters['pilotId'];
  return mockPilots.firstWhere(
    (pilot) => pilot.id == pilotId,
    orElse: () => mockPilots.first,
  );
}

QuoteEstimate _fallbackEstimate() {
  final pilot = mockPilots.first;
  final request = QuoteRequest(
    pilot: pilot,
    category: pilot.categories.first,
    area: pilot.availableAreas.first,
    preferredDate: '2026.05.20',
    detail: pilot.intro,
    budgetRange: '50~100만원',
    contactWindow: '평일 오후',
  );
  return QuoteEstimate(
    request: request,
    proposedPrice: pilot.basePrice + 120000,
    estimatedTime: '촬영 2시간 + 편집 1일',
    includedItems: const <String>['비행 가능 여부 확인', '현장 촬영', '원본 파일 납품'],
    message: '${pilot.name}의 기본 견적입니다.',
  );
}
