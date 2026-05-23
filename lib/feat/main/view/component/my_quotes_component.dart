part of '../pages/main_page.dart';

class MyQuotesPage extends StatelessWidget {
  const MyQuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (!store.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(backgroundColor: DC.canvas);
        }

        final compact = MediaQuery.sizeOf(context).width < 760;
        final nickname =
            store.accountNickname.isNotEmpty
                ? store.accountNickname
                : store.accountName;

        final quotes = store.myQuotes;

        return Scaffold(
          backgroundColor: DC.canvas,
          body: Column(
            children: <Widget>[
              DrameTopNavigation(
                isLoggedIn: true,
                isOperator: store.isPilotMode,
                nickname: nickname,
                activePage: 'quotes',
                onLoginTap: () => context.go('/login'),
                onRegisterPilotTap: () => context.push('/pilot/register'),
                onLogoTap: () => context.go('/home'),
                onFindPilotTap: () => context.go('/home'),
                onFeedTap: () => context.go('/feed'),
                onPortfolioTap: () => context.go('/portfolio'),
                onMyQuotesTap: () {},
                onSwitchToUser: () {
                  store.setPilotMode(false);
                  context.go('/home');
                },
                onSwitchToOperator: () {
                  store.setPilotMode(true);
                  context.go('/home');
                },
                onRequestsTap:
                    () => _openPilotRequestReviewPage(
                      context,
                      initialRequest: store.firstPilotWorkRequest,
                    ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _PageShell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 40),
                            Text('내 견적', style: DT.titleLg),
                            const SizedBox(height: 8),
                            Text(
                              '요청한 견적의 진행 상황을 확인하세요.',
                              style: DT.bodyMd.copyWith(color: DC.body),
                            ),
                            const SizedBox(height: 32),
                            if (quotes.isEmpty)
                              _EmptyQuotes(onFind: () => context.go('/home'))
                            else
                              ...quotes.map(
                                (q) => _QuoteCard(quote: q, compact: compact),
                              ),
                            const SizedBox(height: 72),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: _FooterSection()),
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

// ── Widgets ──────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.compact});
  final UserQuoteSummary quote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(quote.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DC.rxLg),
        border: Border.all(color: DC.hairline),
      ),
      child:
          compact
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(quote.pilotName, style: DT.titleSm)),
                      _StatusChip(label: quote.status, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${quote.category} · ${quote.area}',
                    style: DT.bodyMd.copyWith(color: DC.body),
                  ),
                  const SizedBox(height: 4),
                  Text(quote.date, style: DT.caption.copyWith(color: DC.muted)),
                  const SizedBox(height: 8),
                  Text(
                    quote.price,
                    style: DT.titleSm.copyWith(color: DC.primary),
                  ),
                ],
              )
              : Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(quote.pilotName, style: DT.titleSm),
                        const SizedBox(height: 4),
                        Text(
                          '${quote.category} · ${quote.area} · ${quote.date}',
                          style: DT.bodyMd.copyWith(color: DC.body),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    quote.price,
                    style: DT.titleSm.copyWith(color: DC.primary),
                  ),
                  const SizedBox(width: 20),
                  _StatusChip(label: quote.status, color: statusColor),
                ],
              ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case '견적 도착':
        return DC.primary;
      case '결제 완료':
        return const Color(0xFF16A34A);
      case '작업 완료':
        return DC.muted;
      default:
        return DC.body;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DC.rxPill),
      ),
      child: Text(
        label,
        style: DT.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyQuotes extends StatelessWidget {
  const _EmptyQuotes({required this.onFind});
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 48),
          Icon(Icons.inbox_outlined, size: 48, color: DC.muted),
          const SizedBox(height: 16),
          Text('아직 보낸 견적이 없어요', style: DT.titleSm.copyWith(color: DC.body)),
          const SizedBox(height: 8),
          Text(
            '운용자를 찾아 견적을 요청해 보세요.',
            style: DT.bodyMd.copyWith(color: DC.muted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onFind,
            style: dPrimaryButtonStyle(),
            child: const Text('운용자 찾기'),
          ),
        ],
      ),
    );
  }
}
