import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/d_tokens.dart';
import '../../../../common/drame_navigation.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 768;

    if (compact) {
      return const _MobileAppEntryFlow();
    }

    return Scaffold(
      backgroundColor: DC.canvas,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _HeroSection(
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _ServicesSection(
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _ClientFlowSection(
                    step: 1,
                    icon: Icons.category_outlined,
                    title: '카테고리 선택',
                    description:
                        '항공촬영, 농약방제, 측량·매핑, 시설점검 등\n8가지 드론 서비스 분야 중 필요한 작업을 선택하세요.',
                    highlight: '8가지 서비스 분야 · 전국 운용자 즉시 연결',
                    visual: const _CategoryGridVisual(),
                    background: const Color(0xFFF7F8FA),
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _ClientFlowSection(
                    step: 2,
                    icon: Icons.request_quote_outlined,
                    title: '견적 요청',
                    description:
                        '작업 지역, 일정, 예산을 입력하면\n복수의 운용자에게 자동으로 요청이 전달됩니다.',
                    highlight: '작업 조건 입력 · 복수 견적 비교',
                    visual: const _QuoteRequestVisual(),
                    background: DC.canvas,
                    compact: compact,
                    scrollController: _scrollController,
                    reversed: true,
                  ),
                  _ClientFlowSection(
                    step: 3,
                    icon: Icons.verified_outlined,
                    title: '운용자 확정',
                    description: '도착한 견적을 비교하고 가장 적합한\n검증된 운용자를 선택하세요.',
                    highlight: '자격증·포트폴리오 확인 · 작업 완료 후 리뷰',
                    visual: const _OperatorCompareVisual(),
                    background: const Color(0xFFF0F5FF),
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _WhyDrameSection(
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _OperatorCtaBand(
                    compact: compact,
                    scrollController: _scrollController,
                  ),
                  _Footer(compact: compact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────────────────────

class _MobileAppEntryFlow extends StatefulWidget {
  const _MobileAppEntryFlow();

  @override
  State<_MobileAppEntryFlow> createState() => _MobileAppEntryFlowState();
}

class _MobileAppEntryFlowState extends State<_MobileAppEntryFlow> {
  final PageController _pageController = PageController();
  bool _showSplash = true;
  int _page = 0;

  static const List<_OnboardingItem> _items = <_OnboardingItem>[
    _OnboardingItem(
      step: '01 · MATCHING',
      asset: 'assets/onboarding/onboarding_matching.png',
      title: '전문 드론 기사를\n2분 만에 매칭',
      body: '항공촬영부터 측량까지, 카테고리 선택 한 번이면 인증된 운용자가 견적을 보내드려요.',
    ),
    _OnboardingItem(
      step: '02 · MATCH FLOW',
      asset: 'assets/onboarding/onboarding_safe_pay.png',
      title: '요청부터 일정 조율까지\n한 흐름으로 매칭',
      body: '필요한 작업을 올리면 조건에 맞는 운용자와 연결되고, 견적 확인 후 바로 일정과 범위를 조율할 수 있어요.',
    ),
    _OnboardingItem(
      step: '03 · VERIFIED',
      asset: 'assets/onboarding/onboarding_verified.png',
      title: '자격증과 포트폴리오를 보고\n검증된 운용자 선택',
      body: '운용자 자격 정보, 작업 포트폴리오, 리뷰를 확인하고 내 작업에 맞는 전문가를 선택하세요.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      child:
          _showSplash
              ? const _MobileSplashScreen()
              : Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text(
                            '건너뛰기',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged:
                              (value) => setState(() => _page = value),
                          itemBuilder:
                              (context, index) =>
                                  _MobileOnboardingPage(item: _items[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                        child: Column(
                          children: <Widget>[
                            _MobilePageDots(index: _page, count: _items.length),
                            const SizedBox(height: 24),
                            Row(
                              children: <Widget>[
                                if (_page > 0) ...<Widget>[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _previous,
                                      style: _entryOutlineButtonStyle(),
                                      child: const Text('이전'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  flex: _page > 0 ? 2 : 1,
                                  child: FilledButton(
                                    onPressed:
                                        _page == _items.length - 1
                                            ? () => context.go('/home')
                                            : _next,
                                    style: _entryFilledButtonStyle(),
                                    child: Text(
                                      _page == _items.length - 1
                                          ? '시작하기'
                                          : '다음',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MobileSplashScreen extends StatelessWidget {
  const _MobileSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DC.primary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: DrameLogo(size: 48, showText: false),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '모두의 드론',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '전문 드론 기사 매칭 플랫폼',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 46,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'v 1.0.0',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileOnboardingPage extends StatelessWidget {
  const _MobileOnboardingPage({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FC),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE5EAF2)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(item.asset, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            item.step,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: DC.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.22,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.body,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilePageDots extends StatelessWidget {
  const _MobilePageDots({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (dot) {
        final selected = dot == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? DC.primary : const Color(0xFFD4DEE9),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.step,
    required this.asset,
    required this.title,
    required this.body,
  });

  final String step;
  final String asset;
  final String title;
  final String body;
}

ButtonStyle _entryFilledButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: DC.primary,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

ButtonStyle _entryOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF0F172A),
    textStyle: const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
    padding: const EdgeInsets.symmetric(vertical: 20),
    side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.compact, required this.scrollController});
  final bool compact;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: double.infinity,
      height: screenH,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.white,
              Colors.white,
              Color(0xFFF8FBFF),
              Color(0xFFEAF4FF),
              Color(0xFFDCEBFF),
            ],
            stops: <double>[0.0, 0.55, 0.74, 0.9, 1.0],
          ),
        ),
        child: Column(
          children: <Widget>[
            // ── Top nav ───────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: DC.hairline)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 20 : 48,
                vertical: 14,
              ),
              child: Row(
                children: <Widget>[
                  const DrameLogo(size: 28, showText: true),
                  if (!compact) ...<Widget>[
                    const SizedBox(width: 40),
                    ..._buildNavLinks(context),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('둘러보기'),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('로그인'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/signup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DC.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('시작하기'),
                  ),
                ],
              ),
            ),

            // ── Hero body fills remaining viewport height ──────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 96),
                child:
                    compact
                        ? _buildCompactHero(context)
                        : _buildDesktopHero(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavLinks(BuildContext context) {
    const links = <String>['서비스', '운용자 찾기', '피드', '고객지원'];
    return links
        .map(
          (label) => TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(label),
          ),
        )
        .toList();
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // ── Left: text content ─────────────────────────────────────────
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Headline with blue accent
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.12,
                      letterSpacing: -2,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '필요한 드론 작업,\n'),
                      TextSpan(
                        text: '2분 만에 매칭.',
                        style: TextStyle(color: DC.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Subtitle
                const Text(
                  '항공 촬영, 방제, 점검, 측량까지 — 자격증과 보험까지\n검증된 드론 가사와 안전 고객로 바로 연결됩니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.62,
                  ),
                ),
                const SizedBox(height: 38),
                // CTA buttons
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DC.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 17,
                        ),
                        minimumSize: const Size(0, 58),
                        elevation: 0,
                      ),
                      child: const Text('파일럿 찾기'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/pilot/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DC.ink,
                        textStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 17,
                        ),
                        minimumSize: const Size(0, 58),
                        elevation: 0,
                      ),
                      child: const Text('운용자로 등록'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 36),
        // ── Right: app mockup ──────────────────────────────────────────
        const Expanded(flex: 10, child: _AppMockupVisual()),
      ],
    );
  }

  Widget _buildCompactHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.18,
              letterSpacing: -1.5,
            ),
            children: <TextSpan>[
              TextSpan(text: '필요한 드론 작업,\n'),
              TextSpan(text: '2분 만에 매칭.', style: TextStyle(color: DC.primary)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '항공 촬영, 방제, 점검, 측량까지\n검증된 운용자와 바로 연결됩니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DC.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                elevation: 0,
              ),
              child: const Text('파일럿 찾기'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/pilot/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: DC.ink,
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                elevation: 0,
              ),
              child: const Text('운용자로 등록'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── App Mockup Visual ──────────────────────────────────────────────────────────

class _AppMockupVisual extends StatelessWidget {
  const _AppMockupVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: h * 0.29,
              left: w * 0.17,
              right: w * 0.28,
              child: const _DashedLink(width: 190),
            ),
            Positioned(
              top: h * 0.49,
              left: w * 0.18,
              right: w * 0.18,
              child: const _DashedLink(width: 230),
            ),
            Positioned(
              top: h * 0.13,
              right: 0,
              width: w.clamp(360.0, 430.0),
              child: const _OperatorPreviewCard(),
            ),
            Positioned(
              top: h * 0.43,
              left: 0,
              width: w.clamp(280.0, 340.0),
              child: const _RequestPreviewCard(),
            ),
            Positioned(top: h * 0.63, right: 48, child: const _MatchedChip()),
          ],
        );
      },
    );
  }
}

class _OperatorPreviewCard extends StatelessWidget {
  const _OperatorPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EEF8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    't',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5C93E8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '운용자',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFF19C37D),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '★ 4.9 · 인증 · 항공촬영 전문',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FFF5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF8FE8BE)),
                ),
                child: const Text(
                  '인증',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF08A561),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List<Widget>.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 98,
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        const Color(0xFFEAF4FF),
                        Color.lerp(
                          const Color(0xFFD7E9FF),
                          const Color(0xFFC8DDF8),
                          index / 2,
                        )!,
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(
                child: Center(
                  child: Text(
                    '2분 전',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B8794),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: DC.primary,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    '견적 확인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestPreviewCard extends StatelessWidget {
  const _RequestPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEF8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.11),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: DC.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '서울 마포',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '항공촬영',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '견적 준비 · 6월 5일',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _InfoPill(label: '4K'),
              const SizedBox(width: 6),
              _InfoPill(label: '반일 촬영'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

class _MatchedChip extends StatelessWidget {
  const _MatchedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
      decoration: BoxDecoration(
        color: DC.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: DC.primary.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text(
            '매칭 완료 — 2분 만에',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLink extends StatelessWidget {
  const _DashedLink({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(width, 1), painter: _DashedLinePainter());
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = DC.primary.withValues(alpha: 0.28)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 7, 0), paint);
      x += 14;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Services ──────────────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.compact,
    required this.scrollController,
  });
  final bool compact;
  final ScrollController scrollController;

  static const List<(IconData, String, String)> _services =
      <(IconData, String, String)>[
        (Icons.photo_camera_outlined, '항공촬영', '영화·광고·행사 항공 촬영'),
        (Icons.grass_outlined, '농약방제', '정밀 농약 살포·방제'),
        (Icons.home_work_outlined, '부동산 촬영', '단지·빌딩 입체 영상'),
        (Icons.map_outlined, '측량·매핑', '3D 지형·토공량 분석'),
        (Icons.domain_outlined, '시설점검', '태양광·철탑·교량 정밀 점검'),
        (Icons.celebration_outlined, '행사촬영', '공연·스포츠·이벤트 상공 촬영'),
        (Icons.water_outlined, '수중탐사', '수면·해안·댐 드론 촬영'),
        (Icons.local_fire_department_outlined, '재난대응', '화재·재해 현장 모니터링'),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DC.canvas,
      padding: EdgeInsets.only(top: DC.spSection, bottom: DC.spSection),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? DC.spLg : DC.spXxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: DC.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _RevealOnScroll(
                      scrollController: scrollController,
                      child: const Text(
                        'SERVICES',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: DC.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: DC.spBase),
                    _RevealOnScroll(
                      scrollController: scrollController,
                      delay: const Duration(milliseconds: 80),
                      child: const Text(
                        '모든 드론 작업을 한 곳에서',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: DC.ink,
                          letterSpacing: -1,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DC.spXxl),
          // ── Auto-scrolling ticker ──────────────────────────────────────
          _RevealOnScroll(
            scrollController: scrollController,
            delay: const Duration(milliseconds: 160),
            child: _ServiceTicker(services: _services),
          ),
        ],
      ),
    );
  }
}

// Continuously auto-scrolls service cards horizontally
class _ServiceTicker extends StatefulWidget {
  const _ServiceTicker({required this.services});
  final List<(IconData, String, String)> services;

  @override
  State<_ServiceTicker> createState() => _ServiceTickerState();
}

class _ServiceTickerState extends State<_ServiceTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _sc = ScrollController();
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(_onFrame)
          ..repeat();
  }

  void _onFrame() {
    if (!_sc.hasClients) return;
    final position = _sc.position;
    if (!position.hasContentDimensions) return;
    final max = position.maxScrollExtent;
    if (max > 0 && position.pixels >= max - 500) {
      _sc.jumpTo(0);
      return;
    }
    _sc.jumpTo(position.pixels + 0.4);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardW = 220.0;
    const gap = 16.0;
    return SizedBox(
      height: 148,
      child: ListView.builder(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: widget.services.length * 120,
        itemBuilder: (_, i) {
          final s = widget.services[i % widget.services.length];
          return Container(
            width: cardW,
            margin: const EdgeInsets.only(right: gap),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DC.rxLg),
              border: Border.all(color: DC.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DC.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DC.rxMd),
                  ),
                  child: Icon(s.$1, color: DC.primary, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  s.$2,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DC.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.$3,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: DC.body,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── How It Works ──────────────────────────────────────────────────────────────

// ── Client Flow Sections ──────────────────────────────────────────────────────

class _ClientFlowSection extends StatelessWidget {
  const _ClientFlowSection({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.highlight,
    required this.visual,
    required this.background,
    required this.compact,
    required this.scrollController,
    this.reversed = false,
  });

  final int step;
  final IconData icon;
  final String title;
  final String description;
  final String highlight;
  final Widget visual;
  final Color background;
  final bool compact;
  final ScrollController scrollController;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final contentCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FlowStepBadge(step: step, icon: icon),
        const SizedBox(height: 28),
        _FlowStepContent(
          title: title,
          description: description,
          highlight: highlight,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.symmetric(
        vertical: compact ? 60 : 96,
        horizontal: compact ? DC.spLg : DC.spXxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth),
          child: _RevealOnScroll(
            scrollController: scrollController,
            child:
                compact
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        contentCol,
                        const SizedBox(height: 40),
                        visual,
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          reversed
                              ? <Widget>[
                                Expanded(child: visual),
                                const SizedBox(width: 80),
                                Expanded(child: contentCol),
                              ]
                              : <Widget>[
                                Expanded(child: contentCol),
                                const SizedBox(width: 80),
                                Expanded(child: visual),
                              ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _FlowStepBadge extends StatelessWidget {
  const _FlowStepBadge({required this.step, required this.icon});
  final int step;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: DC.primary,
            borderRadius: BorderRadius.circular(DC.rxXl),
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 8),
        Text(
          '0$step',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DC.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _FlowStepContent extends StatelessWidget {
  const _FlowStepContent({
    required this.title,
    required this.description,
    required this.highlight,
  });
  final String title;
  final String description;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: DC.ink,
            letterSpacing: -1,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: DC.body,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: DC.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(DC.rxPill),
          ),
          child: Text(
            highlight,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DC.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step Visual Widgets ───────────────────────────────────────────────────────

class _CategoryGridVisual extends StatelessWidget {
  const _CategoryGridVisual();

  static final List<Widget> _chips =
      _ServicesSection._services
          .map((s) => _CategoryChip(icon: s.$1, label: s.$2))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 10, children: _chips);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DC.rxLg),
        border: Border.all(color: DC.hairline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: DC.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DC.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteRequestVisual extends StatelessWidget {
  const _QuoteRequestVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DC.rxXl),
        border: Border.all(color: DC.hairline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: DC.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '견적 요청서',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DC.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _PreviewField(label: '작업 유형', value: '항공촬영'),
          const SizedBox(height: 12),
          const _PreviewField(label: '작업 지역', value: '서울 강남구'),
          const SizedBox(height: 12),
          const _PreviewField(label: '작업 일정', value: '2026년 6월 15일'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: DC.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(DC.rxMd),
            ),
            child: Row(
              children: const <Widget>[
                Icon(Icons.notifications_outlined, color: DC.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  '견적 3건이 도착했습니다',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DC.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewField extends StatelessWidget {
  const _PreviewField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DC.muted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(DC.rxMd),
            border: Border.all(color: DC.hairline),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DC.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _OperatorCompareVisual extends StatelessWidget {
  const _OperatorCompareVisual();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        _OperatorCard(
          name: '김민준',
          specialty: '항공촬영 · 측량',
          price: '35만원~',
          highlighted: true,
        ),
        SizedBox(height: 10),
        _OperatorCard(
          name: '이서연',
          specialty: '농약방제 · 시설점검',
          price: '28만원~',
          highlighted: false,
        ),
        SizedBox(height: 10),
        _OperatorCard(
          name: '박지훈',
          specialty: '측량·매핑 · 재난대응',
          price: '42만원~',
          highlighted: false,
        ),
      ],
    );
  }
}

class _OperatorCard extends StatelessWidget {
  const _OperatorCard({
    required this.name,
    required this.specialty,
    required this.price,
    required this.highlighted,
  });
  final String name;
  final String specialty;
  final String price;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DC.rxLg),
        border: Border.all(
          color: highlighted ? DC.primary : DC.hairline,
          width: highlighted ? 2 : 1,
        ),
        boxShadow:
            highlighted
                ? <BoxShadow>[
                  BoxShadow(
                    color: DC.primary.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DC.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(DC.rxMd),
            ),
            child: const Icon(
              Icons.person_outline,
              color: DC.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DC.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF16A34A).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '인증',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: DC.body,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DC.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Why Drame ─────────────────────────────────────────────────────────────────

class _WhyDrameSection extends StatelessWidget {
  const _WhyDrameSection({
    required this.compact,
    required this.scrollController,
  });
  final bool compact;
  final ScrollController scrollController;

  static const _features = [
    (Icons.verified_outlined, '검증된 전문가', '자격증·포트폴리오·실적을 확인한 전문 운용자를 비교하세요'),
    (
      Icons.receipt_long_outlined,
      '투명한 견적 비교',
      '복수의 운용자에게 견적을 받아 최적의 조건을 선택하세요',
    ),
    (
      Icons.photo_library_outlined,
      '포트폴리오 확인',
      '실제 작업 사진과 소개를 보고 내 작업에 맞는 운용자를 고르세요',
    ),
    (Icons.timeline_outlined, '실시간 진행 추적', '요청부터 작업 완료까지 전 과정을 투명하게 확인하세요'),
  ];

  @override
  Widget build(BuildContext context) {
    final crossCount = compact ? 1 : 2;

    return Container(
      color: DC.canvas,
      padding: EdgeInsets.symmetric(
        vertical: DC.spSection,
        horizontal: compact ? DC.spLg : DC.spXxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RevealOnScroll(
                scrollController: scrollController,
                child: const Text(
                  '왜 모드인가요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: DC.ink,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: DC.spXxl),
              _RevealOnScroll(
                scrollController: scrollController,
                delay: const Duration(milliseconds: 120),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: DC.spBase,
                    mainAxisSpacing: DC.spBase,
                    childAspectRatio: compact ? 3.5 : 2.8,
                  ),
                  itemCount: _features.length,
                  itemBuilder: (context, i) {
                    final f = _features[i];
                    return _FeatureCard(
                      icon: f.$1,
                      title: f.$2,
                      description: f.$3,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DC.spLg),
      decoration: BoxDecoration(
        border: Border.all(color: DC.hairline),
        borderRadius: BorderRadius.circular(DC.rxLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: DC.primary, size: 36),
          const SizedBox(width: DC.spBase),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DC.ink,
                  ),
                ),
                const SizedBox(height: DC.spXxs),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: DC.body,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operator CTA Band ─────────────────────────────────────────────────────────

class _OperatorCtaBand extends StatelessWidget {
  const _OperatorCtaBand({
    required this.compact,
    required this.scrollController,
  });
  final bool compact;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DC.surfaceDark,
      padding: EdgeInsets.symmetric(
        vertical: DC.spSection,
        horizontal: compact ? DC.spLg : DC.spXxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth),
          child: _RevealOnScroll(
            scrollController: scrollController,
            child:
                compact
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CtaContent(),
                        const SizedBox(height: DC.spXl),
                        _CtaButton(),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _CtaContent()),
                        const SizedBox(width: DC.spXxl),
                        _CtaButton(),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _CtaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '운용자 모집',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: DC.primary,
          ),
        ),
        const SizedBox(height: DC.spBase),
        const Text(
          '드론 전문가라면\n모드에서 수익을 늘려보세요',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/pilot/register'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: DC.ink,
        textStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        minimumSize: const Size(0, 58),
        elevation: 0,
      ),
      child: const Text('운용자 등록하기 →'),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1117),
      padding: EdgeInsets.symmetric(
        vertical: DC.spXxl,
        horizontal: compact ? DC.spLg : DC.spXxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DC.maxWidth),
          child: Column(
            children: [
              Container(
                height: 1,
                color: const Color(0xFF1E2128),
                margin: const EdgeInsets.only(bottom: DC.spXxl),
              ),
              compact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterBrand(),
                      const SizedBox(height: DC.spXl),
                      _FooterLinks(
                        title: '서비스',
                        links: const ['운용자 등록', '촬영자 찾기', '사용 안내'],
                      ),
                      const SizedBox(height: DC.spLg),
                      _FooterLinks(
                        title: '회사',
                        links: const ['회사소개', '공지사항', '이용약관', '개인정보처리방침'],
                      ),
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _FooterBrand()),
                      const SizedBox(width: DC.spXxl),
                      Expanded(
                        child: _FooterLinks(
                          title: '서비스',
                          links: const ['운용자 등록', '촬영자 찾기', '사용 안내'],
                        ),
                      ),
                      const SizedBox(width: DC.spXxl),
                      Expanded(
                        child: _FooterLinks(
                          title: '회사',
                          links: const ['회사소개', '공지사항', '이용약관', '개인정보처리방침'],
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DrameLogo(size: 22, onDark: true),
        const SizedBox(height: DC.spXs),
        const Text(
          '모두의 드론 — 드론 매칭 플랫폼',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: DC.spBase),
        const Text(
          '© 2026 Mode Drone. All rights reserved.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.title, required this.links});
  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: DC.spBase),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: DC.spSm),
            child: Text(
              link,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reveal on Scroll ──────────────────────────────────────────────────────────

class _RevealOnScroll extends StatefulWidget {
  const _RevealOnScroll({
    required this.child,
    required this.scrollController,
    this.delay = Duration.zero,
  });
  final Widget child;
  final ScrollController scrollController;
  final Duration delay;

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
      widget.scrollController.addListener(_checkVisibility);
    });
  }

  void _checkVisibility() {
    if (_triggered) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final viewport = MediaQuery.sizeOf(ctx);
    final position = box.localToGlobal(Offset.zero);
    final isVisible = position.dy < viewport.height * 1.05;
    if (isVisible) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
