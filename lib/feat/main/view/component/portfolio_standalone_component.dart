part of '../pages/main_page.dart';

class PortfolioStandalonePage extends StatefulWidget {
  const PortfolioStandalonePage({super.key});

  @override
  State<PortfolioStandalonePage> createState() =>
      _PortfolioStandalonePageState();
}

class _PortfolioStandalonePageState extends State<PortfolioStandalonePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = context.read<DrameStore>();
      if (store.isSessionRestoring) return;
      unawaited(store.load(initial: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (store.isSessionRestoring) {
          return const Scaffold(backgroundColor: DC.canvas);
        }
        final nickname =
            store.accountNickname.isNotEmpty
                ? store.accountNickname
                : store.accountName;

        if (store.isLoading && store.allPilots.isEmpty) {
          return const Scaffold(
            backgroundColor: DC.canvas,
            body: Center(child: CircularProgressIndicator(color: DC.primary)),
          );
        }

        final compact = MediaQuery.sizeOf(context).width < 760;
        return Scaffold(
          backgroundColor: DC.canvas,
          appBar: compact
              ? AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  title: const Text('포트폴리오'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                )
              : null,
          body: Column(
            children: <Widget>[
              if (!compact)
                DrameTopNavigation(
                  isLoggedIn: store.isLoggedIn,
                  isOperator: store.isPilotMode,
                  nickname: nickname,
                  activePage: 'portfolio',
                  onLoginTap: () => context.go('/login'),
                  onRegisterPilotTap: () => context.push('/pilot/register'),
                  onLogoTap: () {
                    store.setPilotMode(false);
                    context.go('/home');
                  },
                  onFindPilotTap: () => context.go('/home'),
                  onFeedTap: () => context.go('/feed'),
                  onPortfolioTap: () => context.go('/portfolio'),
                  onMyQuotesTap: () => context.go('/my/quotes'),
                  onChatTap: () => context.push('/chats'),
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
                  onRequestsTap:
                      () => _openPilotRequestReviewPage(
                        context,
                        initialRequest: store.firstPilotWorkRequest,
                      ),
                  notificationCount: store.notificationCount,
                  chatUnreadCount: store.chatUnreadCount,
                  onNotificationTap: () => _showNotifications(context, store),
                ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _PopularPortfolioSection(store: store),
                    ),
                    if (!compact)
                      SliverToBoxAdapter(
                        child: _OperatorCtaBand(
                          onTap: () => context.push('/pilot/register'),
                        ),
                      ),
                    if (!compact) const SliverToBoxAdapter(child: _FooterSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 72)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
