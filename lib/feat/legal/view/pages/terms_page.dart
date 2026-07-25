import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/mode/mode.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const ModeBoldText('이용약관', size: 17),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(),
                  SizedBox(height: 24),
                  _Section(
                    title: '1. 목적',
                    body:
                        '본 약관은 모두의 드론 Mode가 제공하는 드론 작업 견적·매칭 서비스의 이용 조건, 절차, 권리와 의무를 정하는 것을 목적으로 합니다.',
                  ),
                  _Section(
                    title: '2. 서비스 내용',
                    body:
                        '회사는 드론 작업을 의뢰하려는 이용자와 드론 운용자를 연결하고, 견적 요청, 포트폴리오 확인, 채팅, 작업 요청 관리 등 서비스 이용에 필요한 기능을 제공합니다.',
                  ),
                  _Section(
                    title: '3. 회원 계정',
                    body:
                        '이용자는 정확한 정보를 제공해야 하며, 계정 정보와 비밀번호를 안전하게 관리할 책임이 있습니다. 타인의 정보를 무단으로 사용하거나 허위 정보를 등록해서는 안 됩니다.',
                  ),
                  _Section(
                    title: '4. 운용자 등록',
                    body:
                        '운용자로 활동하려는 회원은 사업자 정보, 활동 지역, 보유 장비, 포트폴리오 등 필요한 정보를 등록할 수 있습니다. 회사는 서비스 품질과 안전한 거래를 위해 등록 정보를 확인하거나 노출 상태를 제한할 수 있습니다.',
                  ),
                  _Section(
                    title: '5. 견적 및 거래',
                    body:
                        '회사는 이용자와 운용자 간 견적 요청과 상담을 지원하는 플랫폼을 제공합니다. 실제 작업 조건, 일정, 비용, 결과물, 책임 범위는 당사자 간 협의 내용에 따릅니다.',
                  ),
                  _Section(
                    title: '6. 금지 행위',
                    body:
                        '이용자는 불법 촬영, 항공 안전 관련 법령 위반, 허위 정보 등록, 타인 권리 침해, 서비스 운영 방해, 부정 이용 행위를 해서는 안 됩니다.',
                  ),
                  _Section(
                    title: '7. 신고 및 제재',
                    body:
                        '이용자는 채팅 메시지, 피드 게시글, 다른 이용자를 신고할 수 있으며, 원치 않는 이용자를 차단할 수 있습니다. '
                        '회사는 신고된 콘텐츠와 계정을 검토하여 콘텐츠 삭제(숨김), 게시 제한, 계정 이용 정지 등의 조치를 취할 수 있습니다.',
                  ),
                  _Section(
                    title: '8. 개인정보',
                    body:
                        '회사는 개인정보처리방침에 따라 개인정보를 수집, 이용, 보관, 파기합니다. 개인정보처리방침은 서비스 화면 또는 별도 URL을 통해 확인할 수 있습니다.',
                  ),
                  _Section(
                    title: '9. 계정 삭제',
                    body:
                        '이용자는 앱 내 계정 삭제 기능 또는 계정 삭제 안내 페이지를 통해 계정 및 관련 데이터 삭제를 요청할 수 있습니다. 법령상 보관이 필요한 정보는 정해진 기간 동안 보관 후 파기됩니다.',
                  ),
                  _Section(
                    title: '10. 약관 변경',
                    body:
                        '회사는 법령 또는 서비스 변경에 따라 약관을 개정할 수 있으며, 중요한 변경 사항은 앱 화면 또는 이메일 등으로 안내합니다.',
                  ),
                  _Section(
                    title: '11. 문의',
                    body:
                        '서비스 이용 및 약관 관련 문의는 drame020101@modeofficial.net 또는 privacy@modeofficial.net으로 연락해 주세요.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ModeText(
          '모두의 드론 Mode 이용약관',
          size: 26,
          weight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
        SizedBox(height: 8),
        ModeText(
          '시행일: 2026년 6월 7일',
          size: 14,
          color: Color(0xFF6B7280),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ModeBoldText(title, size: 17, color: const Color(0xFF111827)),
          const SizedBox(height: 8),
          ModeText(
            body,
            size: 14,
            height: 1.7,
            color: const Color(0xFF374151),
          ),
        ],
      ),
    );
  }
}
