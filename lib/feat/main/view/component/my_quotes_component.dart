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
        final receivedQuotes =
            quotes.where((quote) => quote.isQuoteReceived).toList();
        final inProgressQuotes =
            quotes.where((quote) => quote.isInProgress).toList();

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
                  context.go('/operator');
                },
                onRequestsTap:
                    () => _openPilotRequestReviewPage(
                      context,
                      initialRequest: store.firstPilotWorkRequest,
                    ),
                notificationCount: store.notificationCount,
                onNotificationTap: () => _showNotifications(context, store),
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
                            else ...<Widget>[
                              _QuoteSection(
                                title: '견적 받음',
                                quotes: receivedQuotes,
                                compact: compact,
                                emptyText: '아직 받은 견적이 없습니다.',
                                onTap:
                                    (quote) =>
                                        _openQuoteFromList(context, quote),
                              ),
                              const SizedBox(height: 24),
                              _QuoteSection(
                                title: '진행중',
                                quotes: inProgressQuotes,
                                compact: compact,
                                emptyText: '진행중인 작업이 없습니다.',
                                onTap:
                                    (quote) =>
                                        _openQuoteFromList(context, quote),
                              ),
                            ],
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

  void _openQuoteFromList(BuildContext context, UserQuoteSummary quote) {
    if (quote.isQuoteReceived) {
      showDialog<void>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('견적 메시지'),
              content: Text(
                quote.message.isEmpty ? '운용자가 견적을 보냈습니다.' : quote.message,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('닫기'),
                ),
              ],
            ),
      );
      return;
    }
    if (quote.pilotId.isEmpty) return;
    context.go(
      '/quote/request/${quote.pilotId}/edit/${quote.id}',
      extra: quote,
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class MyQuoteDetailPage extends StatefulWidget {
  const MyQuoteDetailPage({
    super.key,
    required this.requestId,
    this.initialQuote,
  });

  final String requestId;
  final UserQuoteSummary? initialQuote;

  @override
  State<MyQuoteDetailPage> createState() => _MyQuoteDetailPageState();
}

class _MyQuoteDetailPageState extends State<MyQuoteDetailPage> {
  late final TextEditingController _areaController;
  late final TextEditingController _detailController;
  late final TextEditingController _budgetController;
  late final TextEditingController _contactController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final quote = widget.initialQuote;
    _areaController = TextEditingController(text: quote?.area ?? '');
    _detailController = TextEditingController(text: quote?.detail ?? '');
    _budgetController = TextEditingController(text: quote?.budgetRange ?? '');
    _contactController = TextEditingController(
      text: quote?.contactWindow ?? '',
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _detailController.dispose();
    _budgetController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        final quote =
            widget.initialQuote ?? _findQuote(store.myQuotes, widget.requestId);
        if (quote == null) {
          return Scaffold(
            backgroundColor: DC.canvas,
            body: Center(
              child: TextButton(
                onPressed: () => context.go('/my/quotes'),
                child: const Text('견적 목록으로 돌아가기'),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: DC.canvas,
          body: Column(
            children: <Widget>[
              DrameTopNavigation(
                isLoggedIn: true,
                isOperator: false,
                nickname:
                    store.accountNickname.isNotEmpty
                        ? store.accountNickname
                        : store.accountName,
                activePage: 'quotes',
                onLoginTap: () => context.go('/login'),
                onRegisterPilotTap: () => context.push('/pilot/register'),
                onLogoTap: () => context.go('/home'),
                onFindPilotTap: () => context.go('/home'),
                onFeedTap: () => context.go('/feed'),
                onPortfolioTap: () => context.go('/portfolio'),
                onMyQuotesTap: () => context.go('/my/quotes'),
                onSwitchToUser: () {
                  store.setPilotMode(false);
                  context.go('/home');
                },
                onSwitchToOperator: () {
                  store.setPilotMode(true);
                  context.go('/operator');
                },
                notificationCount: store.notificationCount,
                onNotificationTap: () => _showNotifications(context, store),
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
                            Text('견적 요청 수정', style: DT.titleLg),
                            const SizedBox(height: 8),
                            Text(
                              '${quote.pilotName}에게 보낸 요청 내용을 수정합니다.',
                              style: DT.bodyMd.copyWith(color: DC.body),
                            ),
                            const SizedBox(height: 28),
                            _QuoteEditField(
                              label: '지역',
                              controller: _areaController,
                            ),
                            const SizedBox(height: 14),
                            _QuoteEditField(
                              label: '상세 요청',
                              controller: _detailController,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 14),
                            _QuoteEditField(
                              label: '예산 범위',
                              controller: _budgetController,
                            ),
                            const SizedBox(height: 14),
                            _QuoteEditField(
                              label: '연락 가능 시간',
                              controller: _contactController,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: <Widget>[
                                OutlinedButton(
                                  onPressed: () => context.go('/my/quotes'),
                                  child: const Text('취소'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed:
                                      _saving
                                          ? null
                                          : () => _save(context, store, quote),
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 18,
                                  ),
                                  label: Text(_saving ? '저장 중' : '저장'),
                                ),
                              ],
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

  UserQuoteSummary? _findQuote(List<UserQuoteSummary> quotes, String id) {
    for (final quote in quotes) {
      if (quote.id == id) return quote;
    }
    return null;
  }

  Future<void> _save(
    BuildContext context,
    DrameStore store,
    UserQuoteSummary quote,
  ) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await store.updateMyQuoteRequest(
        requestId: quote.id,
        area: _areaController.text.trim(),
        preferredDate: quote.date,
        detail: _detailController.text.trim(),
        budgetRange: _budgetController.text.trim(),
        contactWindow: _contactController.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('견적 요청을 수정했습니다.')));
      context.go('/my/quotes');
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _QuoteEditField extends StatelessWidget {
  const _QuoteEditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection({
    required this.title,
    required this.quotes,
    required this.compact,
    required this.emptyText,
    required this.onTap,
  });

  final String title;
  final List<UserQuoteSummary> quotes;
  final bool compact;
  final String emptyText;
  final ValueChanged<UserQuoteSummary> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title, style: DT.titleSm),
            const SizedBox(width: 8),
            _StatusChip(label: '${quotes.length}', color: DC.primary),
          ],
        ),
        const SizedBox(height: 12),
        if (quotes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DC.rxLg),
              border: Border.all(color: DC.hairline),
            ),
            child: Text(emptyText, style: DT.bodyMd.copyWith(color: DC.muted)),
          )
        else
          ...quotes.map(
            (quote) => _QuoteCard(
              quote: quote,
              compact: compact,
              onTap: () => onTap(quote),
            ),
          ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.compact,
    required this.onTap,
  });
  final UserQuoteSummary quote;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(quote.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DC.rxLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DC.rxLg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
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
                          Expanded(
                            child: Text(quote.pilotName, style: DT.titleSm),
                          ),
                          _StatusChip(label: quote.status, color: statusColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${quote.category} · ${quote.area}',
                        style: DT.bodyMd.copyWith(color: DC.body),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quote.date,
                        style: DT.caption.copyWith(color: DC.muted),
                      ),
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
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == '견적 받음') return DC.primary;
    if (status == '진행중') return const Color(0xFF16A34A);
    if (status == '완료') return DC.muted;
    if (status == '요청 보냄') return const Color(0xFF64748B);
    switch (status) {
      case '견적 받음':
        return DC.primary;
      case '진행중':
        return const Color(0xFF16A34A);
      case '완료':
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
