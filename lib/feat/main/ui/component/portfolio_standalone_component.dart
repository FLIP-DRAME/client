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
      final store = context.read<DrameStore>();
      if (!store.isLoggedIn) {
        context.go('/login');
        return;
      }
      store.load(initial: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (!store.isLoggedIn) return const Scaffold(backgroundColor: DC.canvas);
        final nickname = store.accountNickname.isNotEmpty
            ? store.accountNickname
            : store.accountName;

        if (store.isLoading && store.allPilots.isEmpty) {
          return const Scaffold(
            backgroundColor: DC.canvas,
            body: Center(child: CircularProgressIndicator(color: DC.primary)),
          );
        }

        return Scaffold(
          backgroundColor: DC.canvas,
          body: Column(
            children: <Widget>[
              DrameTopNavigation(
                isLoggedIn: true,
                isOperator: store.isPilotMode,
                nickname: nickname,
                activePage: 'portfolio',
                onLoginTap: () => context.go('/login'),
                onRegisterPilotTap: () => context.push('/pilot/register'),
                onLogoTap: () => context.go('/home'),
                onFindPilotTap: () => context.go('/home'),
                onFeedTap: () => context.go('/feed'),
                onPortfolioTap: () => context.go('/portfolio'),
                onMyQuotesTap: () => context.go('/my/quotes'),
                onSwitchToUser: () { store.setPilotMode(false); context.go('/home'); },
                onSwitchToOperator: () { store.setPilotMode(true); context.go('/home'); },
                onRequestsTap: () => _openPilotRequestReviewPage(
                  context,
                  initialRequest: mockPilotWorkRequests.first,
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _PopularPortfolioSection(store: store),
                    ),
                    SliverToBoxAdapter(
                      child: _OperatorCtaBand(
                        onTap: () => context.push('/pilot/register'),
                      ),
                    ),
                    const SliverToBoxAdapter(child: _FooterSection()),
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
