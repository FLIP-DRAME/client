import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_navigation.dart';
import '../../../../common/drame_text_styles.dart';
import '../../../../common/login_prompt.dart';
import '../../../../core/platform/platform_file_picker.dart';
import '../../../../core/app_defaults.dart';
import '../../../chat/view/pages/chat_list_page.dart';
import '../../../feed/view/pages/feed_page.dart';
import '../../model/main_models.dart';
import '../../network/drone_pilot_api.dart';
import '../../model/drone_pilot_model.dart';
import '../../viewmodel/main_view_model.dart';
import 'dart:async';
import 'dart:ui';

part '../component/main_component.dart';
part '../component/operator_mypage_component.dart';
part '../component/feed_standalone_component.dart';
part '../component/portfolio_standalone_component.dart';
part '../component/my_quotes_component.dart';
part '../component/mobile_redesign_component.dart';

class HomeText {
  static const TextStyle logo = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.logoSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.15,
    letterSpacing: -0.2,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.heroTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: 16,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle heroSearch = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: Colors.black,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.medium,
    height: 1.45,
  );

  static const TextStyle topButton = DrameTextStyles.label;

  static const TextStyle primaryButton = DrameTextStyles.labelStrong;
}

const _primary = Color(0xFF0052FF);
const _navy = Color(0xFF0A0B0D);
const _focus = Color(0xFFE5E7EB);
const _ink = Color(0xFF0A0B0D);
const _muted = Color(0xFF7C828A);
const _soft = Color(0xFFF7F8FA);
const _line = Color(0xFFE4EAF2);
const _mint = Color(0xFF22C58B);

typedef StoreBuilder =
    Widget Function(BuildContext context, DrameStore store, Widget? child);

class Consumer<T> extends ConsumerWidget {
  const Consumer({super.key, required this.builder});

  final StoreBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref.watch(drameStoreProvider), null);
  }
}

extension DrameStoreContext on BuildContext {
  T read<T>() {
    if (T == DrameStore) {
      return ProviderScope.containerOf(
            this,
            listen: false,
          ).read(drameStoreProvider)
          as T;
    }
    throw UnsupportedError('No Riverpod bridge registered for $T.');
  }
}

class BusinessNumberInputFormatter extends TextInputFormatter {
  const BusinessNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < limited.length; i += 1) {
      if (i == 3 || i == 5) {
        buffer.write('-');
      }
      buffer.write(limited[i]);
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

void _openPortfolio(BuildContext context, DronePilot pilot) {
  context.push('/portfolio/${pilot.id}', extra: pilot);
}

void _openPilotRequestReviewPage(
  BuildContext context, {
  PilotWorkRequest? initialRequest,
}) {
  context.push('/operator/requests', extra: initialRequest);
}

void _showNotifications(BuildContext context, DrameStore store) {
  showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('알림'),
          content: SizedBox(
            width: 360,
            child:
                store.notifications.isEmpty
                    ? const Text('새 알림이 없습니다.')
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          store.notifications
                              .take(6)
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: _primary,
                                  ),
                                  title: Text(item.title),
                                  subtitle: Text(item.body),
                                ),
                              )
                              .toList(),
                    ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기'),
            ),
          ],
        ),
  );
}

class PilotRequestReviewPage extends StatelessWidget {
  const PilotRequestReviewPage({super.key, this.initialRequest});

  final PilotWorkRequest? initialRequest;

  @override
  Widget build(BuildContext context) {
    return _PilotRequestReviewPage(initialRequest: initialRequest);
  }
}

class PilotRegistrationPage extends StatefulWidget {
  const PilotRegistrationPage({super.key});

  @override
  State<PilotRegistrationPage> createState() => _PilotRegistrationPageState();
}

class _PilotRegistrationPageState extends State<PilotRegistrationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<DrameStore>();
      unawaited(store.restoreSession().then((_) {
        if (!mounted) return;
        if (!store.isLoggedIn) {
          context.go('/login');
          return;
        }
        if (!store.operatorRegistrationCompleted &&
            !store.registrationJustCompleted) {
          store.openPilotOnboarding();
        }
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DrameStore>(
          builder: (context, store, _) {
            if (!store.isLoggedIn) {
              return const SizedBox.shrink();
            }
            if (store.registrationJustCompleted ||
                (store.operatorRegistrationCompleted &&
                    !store.isPilotOnboarding)) {
              return _PilotRegistrationDoneSection(store: store);
            }
            return SingleChildScrollView(
              child: _PilotOnboardingSection(store: store),
            );
          },
        ),
      ),
    );
  }
}

class OperatorMyPage extends StatelessWidget {
  const OperatorMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder:
          (context, store, _) => _OperatorProfileManagementPage(store: store),
    );
  }
}

class OperatorFeedPage extends StatelessWidget {
  const OperatorFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder:
          (context, store, _) => _OperatorStandaloneShell(
            store: store,
            activeTab: 'feed',
            child: _OperatorFeedTabPage(store: store),
          ),
    );
  }
}

class OperatorPortfolioPage extends StatelessWidget {
  const OperatorPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder:
          (context, store, _) => _OperatorStandaloneShell(
            store: store,
            activeTab: 'portfolio',
            child: _OperatorPortfolioBuilderSection(store: store),
          ),
    );
  }
}

class _OperatorStandaloneShell extends StatelessWidget {
  const _OperatorStandaloneShell({
    required this.store,
    required this.activeTab,
    required this.child,
  });

  final DrameStore store;
  final String activeTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final nickname =
        store.accountNickname.isNotEmpty
            ? store.accountNickname
            : store.accountName;
    return Scaffold(
      backgroundColor: DC.canvas,
      body: Column(
        children: <Widget>[
          DrameTopNavigation(
            isLoggedIn: store.isLoggedIn,
            isOperator: true,
            isOperatorRegistered: store.operatorRegistrationCompleted,
            nickname: nickname,
            onLoginTap: () => context.go('/login'),
            onRegisterPilotTap: () => context.push('/pilot/register'),
            onLogoTap: () {
              store.setPilotMode(false);
              context.go('/home');
            },
            onFindPilotTap: () => context.go('/home'),
            onFeedTap: () => context.go('/feed'),
            onPortfolioTap: () => context.go('/portfolio'),
            onRequestsTap: () => context.go('/operator/requests'),
            onMyPageTap: () => context.go('/operator/mypage'),
            onMyQuotesTap: () => context.go('/my/quotes'),
            onChatTap: () => context.go('/chats'),
            notificationCount: store.notificationCount,
            chatUnreadCount: store.chatUnreadCount,
            onNotificationTap: () => _showNotifications(context, store),
            onLogoutTap: () async {
              await store.signOut();
              if (context.mounted) context.go('/login');
            },
            onSwitchToUser: () {
              store.setPilotMode(false);
              context.go('/home');
            },
            onSwitchToOperator: () {
              store.setPilotMode(true);
              context.go('/operator');
            },
            onAboutServiceTap: () => context.go('/landing'),
            operatorActiveTab: activeTab,
            onOperatorTabTap: (id) {
              switch (id) {
                case 'requests':
                  context.go('/operator/requests');
                case 'feed':
                  context.go('/operator/feed');
                case 'portfolio':
                  context.go('/operator/portfolio');
                case 'profile':
                  context.go('/operator/mypage');
                default:
                  context.go('/operator');
              }
            },
          ),
          Expanded(
            child: ColoredBox(
              color: DC.canvas,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class DrameHomePage extends StatefulWidget {
  const DrameHomePage({super.key, this.operatorMode = false});

  final bool operatorMode;

  @override
  State<DrameHomePage> createState() => _DrameHomePageState();
}

class _DrameHomePageState extends State<DrameHomePage> {
  final GlobalKey _categorySectionKey = GlobalKey();
  final GlobalKey _areaSectionKey = GlobalKey();
  final GlobalKey _operatorSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // Tab state: 'all' | category id (user), or 'dashboard'|'requests'|'feed'|'profile' (operator)
  String _selectedTabId = 'all';
  // Mobile tab index
  int _tabIndex = 0;
  // Tracks which tabs have been visited so they are built lazily on first visit.
  final Set<int> _visitedMobileTabs = <int>{0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<DrameStore>();
      unawaited(store.restoreSession().then((_) {
        if (!mounted) return;
        // /operator 진입은 로그인 + 운용자만 가능.
        if (widget.operatorMode && !store.isLoggedIn) {
          context.go('/home');
          return;
        }
        store.setPilotMode(widget.operatorMode);
        unawaited(store.load(initial: true));
      }));
    });
  }

  @override
  void didUpdateWidget(covariant DrameHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operatorMode == widget.operatorMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DrameStore>().setPilotMode(widget.operatorMode);
      setState(() {
        _selectedTabId = widget.operatorMode ? 'dashboard' : 'all';
        _tabIndex = 0;
        _visitedMobileTabs
          ..clear()
          ..add(0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleUserTabChanged(String id, DrameStore store) {
    setState(() => _selectedTabId = id);
    if (id == 'all') {
      store.clearCategory();
      _scrollToTop();
    } else {
      if (store.categories.isEmpty) {
        return;
      }
      final cat = store.categories.firstWhere(
        (c) => c.id == id,
        orElse: () => store.categories.first,
      );
      store.selectCategory(cat);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(_areaSectionKey);
      });
    }
  }

  void _handleOperatorTabChanged(
    String id,
    BuildContext ctx,
    DrameStore store,
  ) {
    if (id == 'requests') {
      ctx.go('/operator/requests');
    } else if (id == 'feed') {
      ctx.go('/operator/feed');
    } else if (id == 'portfolio') {
      ctx.go('/operator/portfolio');
    } else if (id == 'profile') {
      ctx.go('/operator/mypage');
    } else {
      setState(() => _selectedTabId = id);
    }
  }

  PreferredSizeWidget _buildMobileAppBar(
    BuildContext context,
    DrameStore store,
  ) {
    return _MobileNewAppBar(
      store: store,
      onLoginTap: () => context.go('/login'),
      onModeChanged: (isOperator) {
        if (isOperator) {
          if (!store.isLoggedIn) {
            showLoginRequiredDialog(context);
            return;
          }
          store.setPilotMode(true);
        } else {
          store.setPilotMode(false);
        }
        setState(() => _tabIndex = 0);
        context.go(isOperator ? '/operator' : '/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (store.isLoading && store.pilots.isEmpty) {
          return const Scaffold(
            backgroundColor: DC.canvas,
            body: Center(child: CircularProgressIndicator(color: DC.primary)),
          );
        }
        if (!store.isLoading && store.lastError != null && store.pilots.isEmpty) {
          return Scaffold(
            backgroundColor: DC.canvas,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFB0BEC5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '데이터를 불러오지 못했습니다',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.lastError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Color(0xFF6E7F99),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => unawaited(store.load(initial: true)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DC.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return compact
            ? _buildMobileLayout(context, store)
            : _buildWebLayout(context, store);
      },
    );
  }

  Widget _buildWebLayout(BuildContext context, DrameStore store) {
    // Operator mode: logged in as operator
    final isOperatorDashboard = store.isLoggedIn && store.isPilotMode;

    // Sync selected tab with store category when user navigates
    final tabId =
        store.selectedCategory != null
            ? store.selectedCategory!.id
            : (_selectedTabId == 'all' ? 'all' : _selectedTabId);

    return Scaffold(
      backgroundColor: DC.canvas,
      body: Column(
        children: <Widget>[
          // ── Sticky top nav ──────────────────────────────────────────────────
          DrameTopNavigation(
            isLoggedIn: store.isLoggedIn,
            isOperator: isOperatorDashboard,
            isOperatorRegistered: store.operatorRegistrationCompleted,
            nickname:
                store.isLoggedIn
                    ? (store.accountNickname.isNotEmpty
                        ? store.accountNickname
                        : store.accountName)
                    : null,
            activePage: 'find',
            onLoginTap: () => context.go('/login'),
            onRegisterPilotTap: () => context.push('/pilot/register'),
            onLogoTap: () {
              store.clearCategory();
              store.setPilotMode(false);
              setState(() => _selectedTabId = 'all');
              context.go('/home');
              _scrollToTop();
            },
            onFindPilotTap: () {
              store.setPilotMode(false);
              setState(() => _selectedTabId = 'all');
              _scrollToSection(_categorySectionKey);
            },
            onFeedTap: () {
              if (!store.isLoggedIn) {
                showLoginRequiredDialog(context);
                return;
              }
              context.go('/feed');
            },
            onPortfolioTap: () => context.go('/portfolio'),
            onMyQuotesTap: () {
              if (!store.isLoggedIn) {
                showLoginRequiredDialog(context);
                return;
              }
              context.go('/my/quotes');
            },
            onChatTap: () {
              if (!store.isLoggedIn) {
                showLoginRequiredDialog(context);
                return;
              }
              context.go('/chats');
            },
            onLogoutTap:
                store.isLoggedIn
                    ? () async {
                      await store.signOut();
                      if (context.mounted) context.go('/login');
                    }
                    : null,
            onSwitchToUser: () {
              store.setPilotMode(false);
              setState(() => _selectedTabId = 'all');
              context.go('/home');
            },
            onSwitchToOperator: () {
              if (!store.isLoggedIn) {
                showLoginRequiredDialog(context);
                return;
              }
              store.setPilotMode(true);
              setState(() => _selectedTabId = 'dashboard');
              context.go('/operator');
            },
            onRequestsTap:
                () => _openPilotRequestReviewPage(
                  context,
                  initialRequest: store.firstPilotWorkRequest,
                ),
            onMyPageTap: () => context.go('/operator/mypage'),
            onAboutServiceTap: () => context.go('/landing'),
            notificationCount: store.notificationCount,
            chatUnreadCount: store.chatUnreadCount,
            onNotificationTap: () => _showNotifications(context, store),
            operatorActiveTab: isOperatorDashboard ? _selectedTabId : null,
            onOperatorTabTap:
                isOperatorDashboard
                    ? (id) => _handleOperatorTabChanged(id, context, store)
                    : null,
          ),

          // ── Sticky secondary tab bar (user only) ────────────────────────────
          if (!isOperatorDashboard)
            DrameTabNav(
              isOperator: false,
              selectedId: tabId,
              onTabChanged: (id) => _handleUserTabChanged(id, store),
            ),

          // ── Scrollable content ──────────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                if (isOperatorDashboard) ...<Widget>[
                  SliverToBoxAdapter(
                    child:
                        store.isPilotOnboarding
                            ? _PilotOnboardingSection(store: store)
                            : store.registrationJustCompleted
                            ? _PilotRegistrationDoneSection(store: store)
                            : _selectedTabId == 'feed'
                            ? _OperatorFeedTabPage(store: store)
                            : _selectedTabId == 'portfolio'
                            ? _OperatorPortfolioBuilderSection(store: store)
                            : _PilotDashboardSection(store: store),
                  ),
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ] else ...<Widget>[
                  // ── How it works ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _RevealOnScroll(
                      scrollController: _scrollController,
                      child: const _HowItWorksSection(),
                    ),
                  ),

                  // ── Live operators banner ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: _RevealOnScroll(
                      scrollController: _scrollController,
                      child: _LiveOperatorsBannerSection(store: store),
                    ),
                  ),

                  // ── Category cards ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _categorySectionKey,
                      child: _RevealOnScroll(
                        scrollController: _scrollController,
                        child: _CategorySelectionSection(
                          store: store,
                          onCategorySelected:
                              () =>
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _scrollToSection(_areaSectionKey),
                                  ),
                        ),
                      ),
                    ),
                  ),

                  // ── Area selection (only when category selected) ────────────
                  if (store.selectedCategory != null)
                    SliverToBoxAdapter(
                      child: KeyedSubtree(
                        key: _areaSectionKey,
                        child: _AreaSelectionSection(
                          store: store,
                          onAreaSelected:
                              () =>
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) =>
                                        _scrollToSection(_operatorSectionKey),
                                  ),
                        ),
                      ),
                    ),

                  // ── Operator list (always visible) ─────────────────────────
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _operatorSectionKey,
                      child: _OperatorListSection(store: store),
                    ),
                  ),

                  // ── Operator CTA band ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _OperatorCtaBand(
                      onTap: () => context.push('/pilot/register'),
                    ),
                  ),

                  // ── Footer ─────────────────────────────────────────────────
                  const SliverToBoxAdapter(child: _FooterSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DrameStore store) {
    final userNav = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: '홈',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.description_outlined),
        activeIcon: Icon(Icons.description_rounded),
        label: '내견적',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.photo_library_outlined),
        activeIcon: Icon(Icons.photo_library_rounded),
        label: '피드',
      ),
      BottomNavigationBarItem(
        icon: _BottomBadgeIcon(
          icon: Icons.chat_bubble_outline_rounded,
          count: store.chatUnreadCount,
        ),
        activeIcon: _BottomBadgeIcon(
          icon: Icons.chat_bubble_rounded,
          count: store.chatUnreadCount,
        ),
        label: '채팅',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: '내정보',
      ),
    ];

    final operatorNav = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: '대시보드',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inbox_outlined),
        activeIcon: Icon(Icons.inbox_rounded),
        label: '요청확인',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.photo_library_outlined),
        activeIcon: Icon(Icons.photo_library_rounded),
        label: '피드',
      ),
      BottomNavigationBarItem(
        icon: _BottomBadgeIcon(
          icon: Icons.chat_bubble_outline_rounded,
          count: store.chatUnreadCount,
        ),
        activeIcon: _BottomBadgeIcon(
          icon: Icons.chat_bubble_rounded,
          count: store.chatUnreadCount,
        ),
        label: '채팅',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: '내정보',
      ),
    ];

    final navItems = store.isPilotMode ? operatorNav : userNav;
    final safeIndex = _tabIndex.clamp(0, navItems.length - 1);
    final operatorHomeTab =
        store.isPilotOnboarding
            ? SingleChildScrollView(
              child: _PilotOnboardingSection(store: store),
            )
            : store.registrationJustCompleted
            ? SingleChildScrollView(
              child: _PilotRegistrationDoneSection(store: store),
            )
            : _OperatorDashboardTab(store: store);

    final tabChildren =
        store.isPilotMode
            ? <Widget>[
              operatorHomeTab,
              _OperatorRequestsMobileTab(store: store),
              ColoredBox(
                color: DC.canvas,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: _OperatorFeedSection(store: store),
                      ),
                      const SizedBox(height: 8),
                      const ColoredBox(
                        color: DC.canvas,
                        child: DroneFeedSection(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              ChatListPage(onBack: () => setState(() => _tabIndex = 0)),
              _OperatorMyPageMobileTab(store: store),
            ]
            : <Widget>[
              _UserHomeTab(store: store),
              _MobileMyQuotesTab(store: store),
              const SingleChildScrollView(
                child: ColoredBox(color: DC.canvas, child: DroneFeedSection()),
              ),
              ChatListPage(onBack: () => setState(() => _tabIndex = 0)),
              _UserMyPageTab(store: store),
            ];

    return PopScope(
      canPop: _tabIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tabIndex = 0);
      },
      child: Scaffold(
      backgroundColor: DC.canvas,
      appBar: _buildMobileAppBar(context, store),
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            for (int i = 0; i < tabChildren.length; i++)
              if (_visitedMobileTabs.contains(i))
                Offstage(
                  offstage: safeIndex != i,
                  child: TickerMode(
                    enabled: safeIndex == i,
                    child: tabChildren[i],
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) {
          if (!store.isLoggedIn && index != 0 && !store.isPilotMode) {
            showLoginRequiredDialog(context);
            return;
          }
          setState(() {
            _tabIndex = index;
            _visitedMobileTabs.add(index);
          });
        },
        selectedItemColor: _primary,
        unselectedItemColor: const Color(0xFF8BA0B8),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: navItems,
      ),
    ),
    );
  }
}

class _BottomBadgeIcon extends StatelessWidget {
  const _BottomBadgeIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -10,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: const BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
