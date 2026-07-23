part of '../pages/main_page.dart';

String _cleanArea(String area) {
  final v = area.trim();
  if (v.isEmpty || v == '??' || v == '?') return '';
  return ' · $v';
}

class MyQuotesPage extends StatefulWidget {
  const MyQuotesPage({super.key});

  @override
  State<MyQuotesPage> createState() => _MyQuotesPageState();
}

class _MyQuotesPageState extends State<MyQuotesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = context.read<DrameStore>();
      if (store.isLoggedIn) unawaited(store.load());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrameStore>(
      builder: (context, store, _) {
        if (store.isSessionRestoring) {
          return const Scaffold(backgroundColor: DC.canvas);
        }
        if (!store.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/login');
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
        final pendingQuotes = quotes.where((quote) => quote.isPending).toList();
        final completedQuotes =
            quotes.where((quote) => quote.isCompleted).toList();

        return Scaffold(
          backgroundColor: DC.canvas,
          appBar: compact
              ? AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  title: const Text('내 견적'),
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
                  isLoggedIn: true,
                  isOperator: store.isPilotMode,
                  nickname: nickname,
                  activePage: 'quotes',
                  onLoginTap: () => context.go('/login'),
                  onRegisterPilotTap: () => context.push('/pilot/register'),
                  onLogoTap: () {
                    store.setPilotMode(false);
                    context.go('/home');
                  },
                  onFindPilotTap: () => context.go('/home'),
                  onFeedTap: () => context.go('/feed'),
                  onPortfolioTap: () => context.go('/portfolio'),
                  onMyQuotesTap: () {},
                  onChatTap: () => context.go('/chats'),
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
                      child: _PageShell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: compact ? 16 : 40),
                            if (!compact)
                              const ModeSemiBoldText(
                                '내 견적',
                                size: 24,
                                height: 1.25,
                                letterSpacing: -0.4,
                              ),
                            if (!compact) const SizedBox(height: 8),
                            if (!compact)
                              const ModeText(
                                '요청한 견적의 진행 상황을 확인하세요.',
                                size: 16,
                                color: DC.body,
                                height: 1.5,
                              ),
                            if (!compact) const SizedBox(height: 32),
                            if (compact) const SizedBox(height: 8),
                            if (quotes.isEmpty)
                              ModeEmptyState(
                                icon: Icons.inbox_outlined,
                                title: '아직 보낸 견적이 없어요',
                                subtitle: '운용자를 찾아 견적을 요청해 보세요.',
                                actionLabel: '운용자 찾기',
                                onAction: () => context.go('/home'),
                              )
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
                                title: '견적 대기중',
                                quotes: pendingQuotes,
                                compact: compact,
                                emptyText: '대기중인 견적 요청이 없습니다.',
                                onTap:
                                    (quote) =>
                                        _openQuoteFromList(context, quote),
                              ),
                              if (completedQuotes.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 24),
                                _QuoteSection(
                                  title: '완료',
                                  quotes: completedQuotes,
                                  compact: compact,
                                  emptyText: '',
                                  onTap:
                                      (quote) =>
                                          _openQuoteFromList(context, quote),
                                ),
                              ],
                            ],
                            const SizedBox(height: 72),
                          ],
                        ),
                      ),
                    ),
                    if (!compact) const SliverToBoxAdapter(child: _FooterSection()),
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
                onLogoTap: () {
                  store.setPilotMode(false);
                  context.go('/home');
                },
                onFindPilotTap: () => context.go('/home'),
                onFeedTap: () => context.go('/feed'),
                onPortfolioTap: () => context.go('/portfolio'),
                onMyQuotesTap: () => context.go('/my/quotes'),
                onChatTap: () => context.go('/chats'),
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
                notificationCount: store.notificationCount,
                chatUnreadCount: store.chatUnreadCount,
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
                            const ModeSemiBoldText(
                              '견적 요청 수정',
                              size: 24,
                              height: 1.25,
                              letterSpacing: -0.4,
                            ),
                            const SizedBox(height: 8),
                            ModeText(
                              '${quote.pilotName}에게 보낸 요청 내용을 수정합니다.',
                              size: 16,
                              color: DC.body,
                              height: 1.5,
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
    final router = GoRouter.of(context);
    try {
      await store.updateMyQuoteRequest(
        requestId: quote.id,
        category: quote.category,
        area: _areaController.text.trim(),
        preferredDate: quote.date,
        detail: _detailController.text.trim(),
        budgetRange: _budgetController.text.trim(),
        contactWindow: _contactController.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('견적 요청을 수정했습니다.')));
      router.go('/my/quotes');
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
            ModeSemiBoldText(title, size: 16, height: 1.25),
            const SizedBox(width: 8),
            ModeChip(
              label: '${quotes.length}',
              background: DC.primary.withValues(alpha: 0.1),
              foreground: DC.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (quotes.isEmpty)
          SizedBox(
            width: double.infinity,
            child: ModeCard(
              variant: ModeCardVariant.flatBordered,
              padding: const EdgeInsets.all(18),
              child: ModeText(emptyText, size: 16, color: DC.muted, height: 1.5),
            ),
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

class _QuoteCard extends ConsumerWidget {
  const _QuoteCard({
    required this.quote,
    required this.compact,
    required this.onTap,
  });
  final UserQuoteSummary quote;
  final bool compact;
  final VoidCallback onTap;

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    if (quote.id.isEmpty) return;
    try {
      final roomId = await ref
          .read(chatViewModelProvider)
          .getOrCreateRoom(quote.id);
      if (context.mounted) {
        context.push(
          '/chat/$roomId',
          extra: <String, String>{
            'otherPartyName': quote.pilotName,
            'category': quote.category,
          },
        );
      }
    } catch (e, st) {
      debugPrint('[_QuoteCard] 채팅방 열기 실패: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방을 열 수 없습니다. 다시 시도해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayPrice =
        quote.price == '-' && quote.budgetOption.isNotEmpty
            ? quote.budgetOption
            : quote.price;
    final showChat = quote.isInProgress && quote.pilotId.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModeCard(
        variant: ModeCardVariant.flatBordered,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        onTap: onTap,
        child:
              compact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ModeSemiBoldText(
                              quote.pilotName,
                              size: 16,
                              height: 1.25,
                            ),
                          ),
                          ModeStatusBadge(status: quote.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ModeText(
                        '${quote.category}${_cleanArea(quote.area)}',
                        size: 16,
                        color: DC.body,
                        height: 1.5,
                      ),
                      const SizedBox(height: 4),
                      ModeText(
                        quote.date,
                        size: 13,
                        color: DC.muted,
                        height: 1.5,
                      ),
                      const SizedBox(height: 8),
                      ModeSemiBoldText(
                        displayPrice,
                        size: 16,
                        color: DC.primary,
                        height: 1.25,
                      ),
                      if (showChat) ...<Widget>[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openChat(context, ref),
                            icon: const Icon(Icons.chat_rounded, size: 16),
                            label: const Text('채팅하기'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DC.primary,
                              side: const BorderSide(color: DC.primary),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontFamily: DrameTextStyles.fontFamily,
                                fontSize: DrameTextStyles.labelSize,
                                fontWeight: DrameTextStyles.semiBold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                  : Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ModeSemiBoldText(
                                  quote.pilotName,
                                  size: 16,
                                  height: 1.25,
                                ),
                                const SizedBox(height: 4),
                                ModeText(
                                  '${quote.category}${_cleanArea(quote.area)} · ${quote.date}',
                                  size: 16,
                                  color: DC.body,
                                  height: 1.5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ModeSemiBoldText(
                            displayPrice,
                            size: 16,
                            color: DC.primary,
                            height: 1.25,
                          ),
                          const SizedBox(width: 20),
                          ModeStatusBadge(status: quote.status),
                          if (showChat) ...<Widget>[
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => _openChat(context, ref),
                              icon: const Icon(Icons.chat_rounded, size: 14),
                              label: const Text('채팅'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DC.primary,
                                side: const BorderSide(color: DC.primary),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: DrameTextStyles.fontFamily,
                                  fontSize: DrameTextStyles.labelSize,
                                  fontWeight: DrameTextStyles.semiBold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
        ),
      );
  }
}
