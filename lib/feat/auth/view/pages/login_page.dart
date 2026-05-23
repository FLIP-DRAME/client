import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_navigation.dart';
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
            '로그인에 실패했습니다: $error',
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final store = ref.watch(drameStoreProvider);
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
    return _buildFormPanel(context, store, isDesktop: false);
  }

  // ── Form Panel (shared) ─────────────────────────────────────────────────────
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
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DC.hairline),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Top bar
                      _buildTopBar(context, isDesktop: isDesktop),
                      const SizedBox(height: 36),

                      // Title
                      const Text(
                        '로그인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: DC.ink,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Drame에 오신 것을 환영합니다',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: DC.body,
                          height: 1.5,
                        ),
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
                          suffix: GestureDetector(
                            onTap:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                            child: Icon(
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
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              _isLoading ? null : () => _handleLogin(store),
                          style: FilledButton.styleFrom(
                            backgroundColor: DC.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: DC.primary.withValues(
                              alpha: 0.55,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('로그인'),
                        ),
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
                            child: Text(
                              '또는',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: DC.muted.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: DC.hairline, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Signup link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              '계정이 없으신가요?',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: DC.body,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: const Text(
                                '회원가입하기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: DC.primary,
                                ),
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
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: DC.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DC.hairline),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: DC.ink,
              size: 18,
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
          const Text(
            '드론 전문가와\n고객을 연결합니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.35,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '항공 촬영, 방제, 측량, 시설 점검까지\n전문 드론 운용자와 바로 연결하세요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.65,
            ),
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
                  Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
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
                Text(
                  '처음 방문이신가요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onSignupTap,
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DC.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: DC.primary,
                    ),
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

