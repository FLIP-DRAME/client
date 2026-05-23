import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mode/feat/main/network/drone_pilot_api.dart';

import 'app_providers.dart';
import 'feat/auth/view/pages/login_page.dart';
import 'feat/auth/view/pages/signup_page.dart';
import 'feat/landing/view/pages/landing_page.dart';
import 'feat/main/model/main_models.dart';
import 'feat/main/model/drone_pilot_model.dart';
import 'feat/main/view/pages/main_page.dart';
import 'feat/portfolio/view/pages/portfolio_page.dart';
import 'feat/quote/model/quote_model.dart';
import 'feat/quote/view/pages/contact_access_page.dart';
import 'feat/quote/view/pages/payment_page.dart';
import 'feat/quote/view/pages/quote_estimate_page.dart';
import 'feat/quote/view/pages/quote_request_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const DrameHomePage(),
    ),
    GoRoute(
      path: '/operator',
      name: 'operator',
      builder: (context, state) => const DrameHomePage(operatorMode: true),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/feed',
      name: 'feed',
      builder: (context, state) => const FeedStandalonePage(),
    ),
    GoRoute(
      path: '/portfolio',
      name: 'portfolio-home',
      builder: (context, state) => const PortfolioStandalonePage(),
    ),
    GoRoute(
      path: '/portfolio/:pilotId',
      name: 'portfolio',
      builder: (context, state) {
        return _PilotResolverPage(
          pilotId: state.pathParameters['pilotId'],
          extra: state.extra,
          builder: (pilot) => PilotPortfolioPage(pilot: pilot),
        );
      },
    ),
    GoRoute(
      path: '/quote/request/:pilotId/edit/:requestId',
      name: 'quote-request-edit',
      builder: (context, state) {
        final initialQuote =
            state.extra is UserQuoteSummary
                ? state.extra! as UserQuoteSummary
                : null;
        return _PilotResolverPage(
          pilotId: state.pathParameters['pilotId'],
          extra: null,
          builder:
              (pilot) =>
                  QuoteRequestPage(pilot: pilot, initialQuote: initialQuote),
        );
      },
    ),
    GoRoute(
      path: '/quote/request/:pilotId',
      name: 'quote-request',
      builder: (context, state) {
        return _PilotResolverPage(
          pilotId: state.pathParameters['pilotId'],
          extra: state.extra,
          builder: (pilot) => QuoteRequestPage(pilot: pilot),
        );
      },
    ),
    GoRoute(
      path: '/quote/estimate',
      name: 'quote-estimate',
      builder: (context, state) {
        final estimate =
            state.extra is QuoteEstimate ? state.extra! as QuoteEstimate : null;
        return estimate == null
            ? const _MissingRouteDataPage(message: '견적 정보가 없습니다.')
            : QuoteEstimatePage(estimate: estimate);
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
                : null;
        final paymentInstruction =
            extra is Map<String, Object?> &&
                    extra['paymentInstruction'] is PaymentInstruction
                ? extra['paymentInstruction']! as PaymentInstruction
                : null;
        return estimate == null || paymentInstruction == null
            ? const _MissingRouteDataPage(message: '결제 정보가 없습니다.')
            : PaymentPage(
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
                : null;
        final contactAccess =
            extra is Map<String, Object?> &&
                    extra['contactAccess'] is ContactAccess
                ? extra['contactAccess']! as ContactAccess
                : null;
        return estimate == null || contactAccess == null
            ? const _MissingRouteDataPage(message: '연락처 정보가 없습니다.')
            : ContactAccessPage(
              estimate: estimate,
              contactAccess: contactAccess,
            );
      },
    ),
    GoRoute(
      path: '/my/quotes',
      name: 'my-quotes',
      builder: (context, state) => const MyQuotesPage(),
    ),
    GoRoute(
      path: '/my/quotes/:requestId',
      name: 'my-quote-detail',
      builder: (context, state) {
        final initialQuote =
            state.extra is UserQuoteSummary
                ? state.extra! as UserQuoteSummary
                : null;
        if (initialQuote == null || initialQuote.pilotId.isEmpty) {
          return const MyQuotesPage();
        }
        return _PilotResolverPage(
          pilotId: initialQuote.pilotId,
          extra: null,
          builder:
              (pilot) =>
                  QuoteRequestPage(pilot: pilot, initialQuote: initialQuote),
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
      path: '/operator/mypage',
      name: 'operator-mypage',
      builder: (context, state) => const OperatorMyPage(),
    ),
    GoRoute(
      path: '/operator/feed',
      name: 'operator-feed',
      builder: (context, state) => const OperatorFeedPage(),
    ),
    GoRoute(
      path: '/operator/portfolio',
      name: 'operator-portfolio',
      builder: (context, state) => const OperatorPortfolioPage(),
    ),
    GoRoute(
      path: '/operator/requests',
      name: 'operator-requests',
      builder: (context, state) {
        final initialRequest =
            state.extra is PilotWorkRequest
                ? state.extra! as PilotWorkRequest
                : null;
        return PilotRequestReviewPage(initialRequest: initialRequest);
      },
    ),
    GoRoute(
      path: '/pilot/requests',
      name: 'pilot-requests',
      builder: (context, state) {
        final initialRequest =
            state.extra is PilotWorkRequest
                ? state.extra! as PilotWorkRequest
                : null;
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

class _PilotResolverPage extends ConsumerWidget {
  const _PilotResolverPage({
    required this.pilotId,
    required this.extra,
    required this.builder,
  });

  final String? pilotId;
  final Object? extra;
  final Widget Function(DronePilot pilot) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (extra is DronePilot) {
      return builder(extra! as DronePilot);
    }
    if (pilotId == null) {
      return const _MissingRouteDataPage(message: '운용자 정보가 없습니다.');
    }
    return FutureBuilder<DronePilot?>(
      future: ref.read(dronePilotApiProvider).fetchPilotById(pilotId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final pilot = snapshot.data;
        if (pilot == null) {
          return const _MissingRouteDataPage(message: '운용자를 찾을 수 없습니다.');
        }
        return builder(pilot);
      },
    );
  }
}

class _MissingRouteDataPage extends StatelessWidget {
  const _MissingRouteDataPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/home'),
          child: Text(message),
        ),
      ),
    );
  }
}
