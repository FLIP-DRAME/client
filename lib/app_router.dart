import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mode/feat/main/network/drone_pilot_api.dart';

import 'app_providers.dart';
import 'feat/feed/network/feed_api.dart';
import 'feat/feed/view/pages/feed_page.dart';
import 'feat/auth/view/pages/login_page.dart';
import 'feat/auth/view/pages/signup_page.dart';
import 'feat/legal/view/pages/privacy_policy_page.dart';
import 'feat/legal/view/pages/account_deletion_page.dart';
import 'feat/legal/view/pages/terms_page.dart';
import 'feat/chat/view/pages/chat_list_page.dart';
import 'feat/chat/view/pages/chat_room_page.dart';
import 'feat/moderation/view/pages/blocked_users_page.dart';
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
      name: 'home',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DrameHomePage()),
    ),
    GoRoute(
      path: '/landing',
      name: 'landing',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LandingPage()),
    ),
    GoRoute(
      path: '/home',
      name: 'home-alias',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DrameHomePage()),
    ),
    GoRoute(
      path: '/operator',
      name: 'operator',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DrameHomePage(operatorMode: true)),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SignupPage()),
    ),
    GoRoute(
      path: '/signup/done',
      name: 'signup-done',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SignupWelcomePage()),
    ),
    GoRoute(
      path: '/feed',
      name: 'feed',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: FeedStandalonePage()),
    ),
    GoRoute(
      path: '/feed/:postId',
      name: 'feed-detail',
      pageBuilder: (context, state) {
        final postId = state.pathParameters['postId']!;
        final post = state.extra is FeedPost ? state.extra! as FeedPost : null;
        return NoTransitionPage(
          child: FeedDetailPage(postId: postId, post: post),
        );
      },
    ),
    GoRoute(
      path: '/portfolio',
      name: 'portfolio-home',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PortfolioStandalonePage()),
    ),
    GoRoute(
      path: '/portfolio/:pilotId',
      name: 'portfolio',
      pageBuilder: (context, state) => NoTransitionPage(
        child: _PilotResolverPage(
          pilotId: state.pathParameters['pilotId'],
          extra: state.extra,
          builder: (pilot) => PilotPortfolioPage(pilot: pilot),
        ),
      ),
    ),
    GoRoute(
      path: '/quote/request/:pilotId/edit/:requestId',
      name: 'quote-request-edit',
      pageBuilder: (context, state) {
        final initialQuote =
            state.extra is UserQuoteSummary
                ? state.extra! as UserQuoteSummary
                : null;
        return NoTransitionPage(
          child: _PilotResolverPage(
            pilotId: state.pathParameters['pilotId'],
            extra: null,
            builder:
                (pilot) =>
                    QuoteRequestPage(pilot: pilot, initialQuote: initialQuote),
          ),
        );
      },
    ),
    GoRoute(
      path: '/quote/request/:pilotId',
      name: 'quote-request',
      pageBuilder: (context, state) => NoTransitionPage(
        child: _PilotResolverPage(
          pilotId: state.pathParameters['pilotId'],
          extra: state.extra,
          builder: (pilot) => QuoteRequestPage(pilot: pilot),
        ),
      ),
    ),
    GoRoute(
      path: '/quote/estimate',
      name: 'quote-estimate',
      pageBuilder: (context, state) {
        final estimate =
            state.extra is QuoteEstimate ? state.extra! as QuoteEstimate : null;
        return NoTransitionPage(
          child: estimate == null
              ? const _MissingRouteDataPage(message: '견적 정보가 없습니다.')
              : QuoteEstimatePage(estimate: estimate),
        );
      },
    ),
    GoRoute(
      path: '/quote/payment',
      name: 'quote-payment',
      pageBuilder: (context, state) {
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
        return NoTransitionPage(
          child: estimate == null || paymentInstruction == null
              ? const _MissingRouteDataPage(message: '결제 정보가 없습니다.')
              : PaymentPage(
                estimate: estimate,
                paymentInstruction: paymentInstruction,
              ),
        );
      },
    ),
    GoRoute(
      path: '/quote/contact',
      name: 'quote-contact',
      pageBuilder: (context, state) {
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
        return NoTransitionPage(
          child: estimate == null || contactAccess == null
              ? const _MissingRouteDataPage(message: '견적 정보가 없습니다.')
              : ContactAccessPage(
                estimate: estimate,
                contactAccess: contactAccess,
              ),
        );
      },
    ),
    GoRoute(
      path: '/my/quotes',
      name: 'my-quotes',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MyQuotesPage()),
    ),
    GoRoute(
      path: '/my/quotes/:requestId',
      name: 'my-quote-detail',
      pageBuilder: (context, state) {
        final initialQuote =
            state.extra is UserQuoteSummary
                ? state.extra! as UserQuoteSummary
                : null;
        if (initialQuote == null || initialQuote.pilotId.isEmpty) {
          return const NoTransitionPage(child: MyQuotesPage());
        }
        return NoTransitionPage(
          child: _PilotResolverPage(
            pilotId: initialQuote.pilotId,
            extra: null,
            builder:
                (pilot) =>
                    QuoteRequestPage(pilot: pilot, initialQuote: initialQuote),
          ),
        );
      },
    ),
    GoRoute(
      path: '/pilot/register',
      name: 'pilot-register',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PilotRegistrationPage()),
    ),
    GoRoute(
      path: '/pilot/mypage',
      name: 'pilot-mypage',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OperatorMyPage()),
    ),
    GoRoute(
      path: '/operator/mypage',
      name: 'operator-mypage',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OperatorMyPage()),
    ),
    GoRoute(
      path: '/operator/feed',
      name: 'operator-feed',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OperatorFeedPage()),
    ),
    GoRoute(
      path: '/operator/portfolio',
      name: 'operator-portfolio',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OperatorPortfolioPage()),
    ),
    GoRoute(
      path: '/operator/requests',
      name: 'operator-requests',
      pageBuilder: (context, state) {
        final initialRequest =
            state.extra is PilotWorkRequest
                ? state.extra! as PilotWorkRequest
                : null;
        return NoTransitionPage(
          child: PilotRequestReviewPage(initialRequest: initialRequest),
        );
      },
    ),
    GoRoute(
      path: '/pilot/requests',
      name: 'pilot-requests',
      pageBuilder: (context, state) {
        final initialRequest =
            state.extra is PilotWorkRequest
                ? state.extra! as PilotWorkRequest
                : null;
        return NoTransitionPage(
          child: PilotRequestReviewPage(initialRequest: initialRequest),
        );
      },
    ),
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PrivacyPolicyPage()),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: TermsPage()),
    ),
    GoRoute(
      path: '/delete-account',
      name: 'delete-account',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AccountDeletionPage()),
    ),
    GoRoute(
      path: '/blocked-users',
      name: 'blocked-users',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: BlockedUsersPage()),
    ),
    GoRoute(
      path: '/chats',
      name: 'chats',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ChatListPage()),
    ),
    GoRoute(
      path: '/chat/:roomId',
      name: 'chat-room',
      pageBuilder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final extra = state.extra;
        final otherPartyName =
            extra is Map<String, String> ? extra['otherPartyName'] ?? '' : '';
        final category =
            extra is Map<String, String> ? extra['category'] ?? '' : '';
        final otherPartyUserId =
            extra is Map<String, String> ? extra['otherPartyUserId'] : null;
        return NoTransitionPage(
          child: ChatRoomPage(
            roomId: roomId,
            otherPartyName: otherPartyName,
            category: category,
            otherPartyUserId: otherPartyUserId,
          ),
        );
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kDebugMode && state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (kDebugMode && state.error != null) const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('메인으로 돌아가기'),
              ),
            ],
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
        if (snapshot.hasError) {
          return _MissingRouteDataPage(
            message: '운용자 정보를 불러오지 못했습니다: ${snapshot.error}',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
