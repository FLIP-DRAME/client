import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../../../common/drame_navigation.dart';
import '../../../../feat/main/viewmodel/main_view_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(
    String label, {
    IconData? prefixIcon,
    Widget? suffix,
    String? hint,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
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
    hintStyle: const TextStyle(
      fontFamily: 'Pretendard',
      color: DC.mutedSoft,
      fontSize: 14,
    ),
  );

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Pretendard'),
        ),
        backgroundColor: DC.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleSignup(DrameStore store) async {
    final name = _nameCtrl.text.trim();
    final nickname = _nicknameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _showSnack('모든 항목을 입력해 주세요.');
      return;
    }

    if (password != confirm) {
      _showSnack('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (!_agreedToTerms) {
      _showSnack('이용약관에 동의해 주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await store.signUp(
        email: email,
        password: password,
        name: name,
        nickname: nickname,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.replace('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('회원가입에 실패했습니다: $error');
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
        Flexible(
          flex: 40,
          child: _SignupLeftPanel(onLoginTap: () => context.go('/login')),
        ),
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

  // ── Form Panel ──────────────────────────────────────────────────────────────
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
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        '회원가입',
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
                        'Drame 계정을 만들어 드론 서비스를 시작하세요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: DC.body,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Name field
                      TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: DC.ink,
                        ),
                        decoration: _inputDec(
                          '이름',
                          prefixIcon: Icons.person_rounded,
                          hint: '실명을 입력해 주세요',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nickname field
                      TextField(
                        controller: _nicknameCtrl,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: DC.ink,
                        ),
                        decoration: _inputDec(
                          '닉네임',
                          prefixIcon: Icons.person_outline_rounded,
                          hint: '서비스에서 사용할 이름',
                        ),
                      ),
                      const SizedBox(height: 12),

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
                          hint: 'name@email.com',
                        ),
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 12),

                      // Confirm password field
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: DC.ink,
                        ),
                        decoration: _inputDec(
                          '비밀번호 확인',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffix: GestureDetector(
                            onTap:
                                () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                            child: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: DC.muted,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Terms checkbox
                      _buildTermsRow(),
                      const SizedBox(height: 22),

                      // Signup button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              _isLoading ? null : () => _handleSignup(store),
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
                                  : const Text('회원가입'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              '이미 회원이신가요?',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: DC.body,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                '로그인',
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

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms ? DC.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreedToTerms ? DC.primary : DC.hairline,
                width: 1.5,
              ),
            ),
            child:
                _agreedToTerms
                    ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                    : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: DC.body,
                  height: 1.55,
                ),
                children: <InlineSpan>[
                  TextSpan(text: '서비스 '),
                  TextSpan(
                    text: '이용약관',
                    style: TextStyle(
                      color: DC.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' 및 '),
                  TextSpan(
                    text: '개인정보처리방침',
                    style: TextStyle(
                      color: DC.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: '에 동의합니다'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Signup Left Panel ────────────────────────────────────────────────────────

class _SignupLeftPanel extends StatelessWidget {
  const _SignupLeftPanel({required this.onLoginTap});

  final VoidCallback onLoginTap;

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
            'Drame 운용자가 되어\n더 많은 고객을 만나세요',
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
            '검증된 전문가로 등록하고\n전국 드론 작업 요청을 받아보세요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.65,
            ),
          ),

          const SizedBox(height: 40),

          // Feature list
          ...<_FeatureItem>[
            const _FeatureItem(
              icon: Icons.person_add_alt_1_rounded,
              text: '무료로 프로필 등록',
              detail: '별도 비용 없이 바로 시작하세요',
            ),
            const _FeatureItem(
              icon: Icons.notifications_active_outlined,
              text: '전국 실시간 작업 요청 수신',
              detail: '내 지역 요청을 가장 먼저 받아보세요',
            ),
            const _FeatureItem(
              icon: Icons.account_balance_wallet_outlined,
              text: '안전한 정산 시스템',
              detail: '작업 완료 후 안전하게 수수료 정산',
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DC.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, color: DC.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.text,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.detail,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.45),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Login link
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
                  '이미 회원이신가요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onLoginTap,
                  child: const Text(
                    '로그인',
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

// ── Feature Item Data ────────────────────────────────────────────────────────

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final String text;
  final String detail;
}

