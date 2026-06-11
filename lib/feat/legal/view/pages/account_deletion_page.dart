import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/d_tokens.dart';
import '../../../../core/platform/platform_url_launcher.dart';

class AccountDeletionPage extends StatelessWidget {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 768;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded, color: DC.ink),
        ),
        title: const Text(
          '계정 및 데이터 삭제',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DC.ink,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: DC.hairline),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 40,
          vertical: 32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 앱 + 개발자 정보
                const Text(
                  '모두의 드론 모드',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: DC.ink,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '개발자: modeOfficial',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    color: DC.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // 안내
                const Text(
                  '계정 및 데이터 삭제 요청',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: DC.ink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '본 페이지는 모두의 드론 모드 앱 계정 및 관련 데이터의 삭제를 요청할 수 있는 페이지입니다. 앱에 로그인된 상태라면 앱 내 마이페이지 > 계정 > 계정 삭제 메뉴를 이용하시면 즉시 삭제됩니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: DC.body,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 28),

                // 인앱 삭제 안내 박스
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    border: Border.all(color: const Color(0xFFCDD7FF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        children: <Widget>[
                          Icon(Icons.phone_iphone_rounded, size: 16, color: Color(0xFF0052FF)),
                          SizedBox(width: 6),
                          Text(
                            '앱 내 즉시 삭제 방법',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Step('1', '앱에 로그인 후 하단 탭에서 마이페이지를 선택하세요.'),
                      _Step('2', '아래로 스크롤하여 "계정" 섹션의 "계정 삭제"를 탭하세요.'),
                      _Step('3', '삭제 안내를 확인하고 "계정 삭제" 버튼을 누르면 즉시 삭제됩니다.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 이메일 요청 박스
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        children: <Widget>[
                          Icon(Icons.mail_outline_rounded, size: 16, color: Color(0xFFE53935)),
                          SizedBox(width: 6),
                          Text(
                            '이메일로 삭제 요청',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '앱에 접근할 수 없는 경우, 아래 이메일로 계정 삭제를 요청할 수 있습니다. 요청 후 영업일 기준 7일 이내에 처리됩니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: DC.body,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '이메일에 다음 내용을 포함해 주세요: 가입 이메일 주소, 삭제 요청 사유(선택)',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: DC.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            unawaited(openPlatformUrl(
                              'mailto:privacy@modeofficial.net'
                              '?subject=%EA%B3%84%EC%A0%95%20%EC%82%AD%EC%A0%9C%20%EC%9A%94%EC%B2%AD'
                              '&body=%EA%B0%80%EC%9E%85%20%EC%9D%B4%EB%A9%94%EC%9D%BC%3A%20%0A%EC%82%AD%EC%A0%9C%20%EC%9A%94%EC%B2%AD%20%EC%82%AC%EC%9C%A0(%EC%84%A0%ED%83%9D)%3A%20',
                            ));
                          },
                          icon: const Icon(Icons.mail_outline_rounded, size: 16),
                          label: const Text('privacy@modeofficial.net 으로 요청'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            side: const BorderSide(color: Color(0xFFE53935)),
                            textStyle: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 삭제 범위
                const Text(
                  '삭제되는 데이터',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DC.ink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                _DataRow('즉시 삭제', '계정 정보, 프로필, 이미지, 포트폴리오, 피드 게시글, 댓글, 푸시 알림 토큰'),
                _DataRow('최대 5년 보관 후 파기', '거래 기록, 견적 요청·응답 (전자상거래법)'),
                _DataRow('3년 보관 후 파기', '소비자 불만·분쟁 처리 기록 (소비자보호법)'),
                _DataRow('3개월 보관 후 파기', '서비스 접속 로그 (통신비밀보호법)'),
                const SizedBox(height: 28),

                // 개인정보처리방침 링크
                GestureDetector(
                  onTap: () => context.push('/privacy'),
                  child: const Text(
                    '전체 개인정보처리방침 보기 →',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: Color(0xFF0052FF),
                      decoration: TextDecoration.underline,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text);
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0052FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: DC.body,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DC.ink,
                height: 1.55,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: DC.body,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
