import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/drame_navigation.dart';
import '../../../../common/mode/mode.dart';
import '../../../../feat/main/viewmodel/main_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(
    String label, {
    IconData? prefixIcon,
    Widget? suffix,
  }) => InputDecoration(
    labelText: label,
    prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: DC.muted, size: 20) : null,
    suffix: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DC.hairline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DC.hairline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DC.primary, width: 1.5),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: const TextStyle(
      fontFamily: 'Pretendard',
      color: DC.muted,
      fontSize: 14,
    ),
  );

  Future<void> _handleLogin(DrameStore store) async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '이메일과 비밀번호를 입력해 주세요.',
            style: TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: DC.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await store.signIn(email: email, password: password);
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.replace(store.isPilotMode ? '/operator' : '/home');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '로그인에 실패했습니다: ${error.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: DC.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin(DrameStore store) async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await store.signInWithGoogle();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google 로그인에 실패했습니다: ${error.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: DC.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _redirectCachedLogin(DrameStore store) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !store.isLoggedIn) return;
      context.replace(store.isPilotMode ? '/operator' : '/home');
    });
  }

  Widget _buildSessionRestoreScaffold() {
    return const Scaffold(
      backgroundColor: Color(0xFFE5E7EB),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(color: DC.primary, strokeWidth: 2.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final store = ref.watch(drameStoreProvider);
        if (store.isSessionRestoring) {
          return _buildSessionRestoreScaffold();
        }
        if (store.isLoggedIn) {
          _redirectCachedLogin(store);
          return _buildSessionRestoreScaffold();
        }

        final width = MediaQuery.sizeOf(context).width;
        final isDesktop = width >= 768;

        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          body:
              isDesktop
                  ? _buildDesktopLayout(context, store)
                  : _buildMobileLayout(context, store),
        );
      },
    );
  }

  // ── Desktop Layout ──────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, DrameStore store) {
    return Row(
      children: <Widget>[
        // Left panel — 40%
        Flexible(
          flex: 40,
          child: _LeftPanel(onSignupTap: () => context.go('/signup')),
        ),
        // Right panel — 60%
        Flexible(
          flex: 60,
          child: _buildFormPanel(context, store, isDesktop: true),
        ),
      ],
    );
  }

  // ── Mobile Layout ───────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, DrameStore store) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              const DrameLogo(size: 44, showText: false),
              const SizedBox(height: 24),
              const ModeText(
                '모두의 드론',
                size: 26,
                weight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
                height: 1.11,
              ),
              const SizedBox(height: 12),
              const ModeText(
                '드론 서비스를 가장 쉽게, 가장 안전하게',
                textAlign: TextAlign.center,
                size: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              const Spacer(),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: DC.ink,
                ),
                decoration: _mobileInputDec('이메일', hint: 'name@email.com'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: DC.ink,
                ),
                decoration: _mobileInputDec(
                  '비밀번호',
                  suffix: IconButton(
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: DC.muted,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ModeButton(
                label: '이메일로 로그인',
                onPressed:
                    (_isLoading || _isGoogleLoading)
                        ? null
                        : () => _handleLogin(store),
                loading: _isLoading,
                size: ModeButtonSize.lg,
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              _buildGoogleButton(store, height: 54, borderRadius: 16),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const ModeText(
                    '처음이신가요?',
                    size: 14,
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                  ModeButton(
                    label: '회원가입',
                    onPressed: () => context.go('/signup'),
                    variant: ModeButtonVariant.ghost,
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA3AFBF),
                    height: 1.5,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: '로그인 시 '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Semantics(
                        label: '이용약관',
                        link: true,
                        button: true,
                        child: InkWell(
                          onTap: () => context.push('/terms'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: ModeText(
                              '이용약관',
                              size: 12,
                              color: Color(0xFFA3AFBF),
                              height: 1.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '과 '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Semantics(
                        label: '개인정보처리방침',
                        link: true,
                        button: true,
                        child: InkWell(
                          onTap: () => context.push('/privacy'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: ModeText(
                              '개인정보처리방침',
                              size: 12,
                              color: Color(0xFFA3AFBF),
                              height: 1.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '에 동의하게 됩니다.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _mobileInputDec(
    String label, {
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DC.primary, width: 1.6),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ── Form Panel (shared) ─────────────────────────────────────────────────────
  Widget _buildGoogleButton(
    DrameStore store, {
    required double height,
    required double borderRadius,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton.icon(
        onPressed:
            (_isLoading || _isGoogleLoading)
                ? null
                : () => _handleGoogleLogin(store),
        icon:
            _isGoogleLoading
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: DC.ink,
                    strokeWidth: 2,
                  ),
                )
                : const ModeText(
                  'G',
                  size: 18,
                  weight: FontWeight.w800,
                  color: Color(0xFF4285F4),
                ),
        label: const Text('Google로 계속하기'),
        style: OutlinedButton.styleFrom(
          foregroundColor: DC.ink,
          disabledForegroundColor: DC.muted,
          side: const BorderSide(color: DC.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel(
    BuildContext context,
    DrameStore store, {
    required bool isDesktop,
  }) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: 40,
                ),
                child: ModeCard(
                  variant: ModeCardVariant.elevated,
                  radius: 16,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Top bar
                      _buildTopBar(context, isDesktop: isDesktop),
                      const SizedBox(height: 36),

                      // Title
                      const ModeBoldText(
                        '로그인',
                        size: 28,
                        color: DC.ink,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      const SizedBox(height: 6),
                      const ModeText(
                        '모드에 오신 것을 환영합니다',
                        size: 14,
                        color: DC.body,
                        height: 1.5,
                      ),
                      const SizedBox(height: 28),

                      // Email field
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: DC.ink,
                        ),
                        decoration: _inputDec(
                          '이메일',
                          prefixIcon: Icons.email_outlined,
                        ).copyWith(hintText: 'name@email.com'),
                      ),
                      const SizedBox(height: 14),

                      // Password field
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: DC.ink,
                        ),
                        decoration: _inputDec(
                          '비밀번호',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: DC.muted,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      ModeButton(
                        label: '로그인',
                        onPressed:
                            (_isLoading || _isGoogleLoading)
                                ? null
                                : () => _handleLogin(store),
                        loading: _isLoading,
                        size: ModeButtonSize.lg,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Divider(color: DC.hairline, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ModeText(
                              '또는',
                              size: 13,
                              color: DC.muted.withValues(alpha: 0.8),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: DC.hairline, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildGoogleButton(store, height: 52, borderRadius: 12),
                      const SizedBox(height: 24),

                      // Signup link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const ModeText(
                              '계정이 없으신가요?',
                              size: 14,
                              color: DC.body,
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => context.go('/signup'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const ModeSemiBoldText(
                                '회원가입하기',
                                size: 14,
                                color: DC.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool isDesktop}) {
    return Row(
      children: <Widget>[
        // Back arrow
        ModeCard(
          variant: ModeCardVariant.softFilled,
          radius: 10,
          padding: EdgeInsets.zero,
          onTap: () => context.go('/'),
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: Icon(Icons.arrow_back_rounded, color: DC.ink, size: 18),
            ),
          ),
        ),
        if (!isDesktop) ...<Widget>[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.go('/'),
            child: const DrameLogo(size: 26),
          ),
        ],
      ],
    );
  }
}

// ── Left Panel Widget ────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.onSignupTap});

  final VoidCallback onSignupTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: const Color(0xFF374151),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Logo
          GestureDetector(
            onTap: () => context.go('/'),
            child: const DrameLogo(size: 28, onDark: true),
          ),

          const SizedBox(height: 56),

          // Tagline
          const ModeBoldText(
            '드론 전문가와\n고객을 연결합니다',
            size: 32,
            color: Colors.white,
            height: 1.35,
            letterSpacing: -0.8,
          ),
          const SizedBox(height: 12),
          ModeText(
            '항공 촬영, 방제, 측량, 시설 점검까지\n전문 드론 운용자와 바로 연결하세요.',
            size: 14,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.65,
          ),

          const SizedBox(height: 40),

          // Feature list
          ...<String>['검증된 드론 운용자', '빠른 견적 비교 시스템', '작업별 배상책임 보험 보장'].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: DC.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: DC.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ModeText(
                    item,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom signup link
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ModeText(
                  '처음 방문이신가요?',
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onSignupTap,
                  child: const ModeSemiBoldText(
                    '회원가입',
                    size: 14,
                    color: DC.primary,
                    decoration: TextDecoration.underline,
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
