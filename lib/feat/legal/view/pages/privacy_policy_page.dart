import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/d_tokens.dart';
import '../../../../core/platform/platform_url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded, color: DC.ink),
        ),
        title: const Text(
          '개인정보처리방침',
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
          vertical: 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: const _PrivacyContent(),
          ),
        ),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Header('모드 개인정보처리방침', subtitle: '시행일: 2026년 6월 7일'),
        SizedBox(height: 20),
        _Body(
          '모드(이하 "회사" 또는 "모드")는 「개인정보 보호법」 등 관련 법령을 준수하며, 이용자의 개인정보를 보호하기 위해 최선을 다하고 있습니다. 본 방침은 회사가 제공하는 드론 전문가 매칭 서비스(이하 "서비스")와 관련하여 개인정보를 어떻게 수집·이용·제공·보관하는지 안내합니다.',
        ),
        SizedBox(height: 32),

        _SectionTitle('1. 수집하는 개인정보 항목'),
        SizedBox(height: 10),
        _SubTitle('회원가입 및 계정 이용'),
        _BulletList(<String>[
          '필수 항목: 이름, 닉네임, 이메일 주소, 비밀번호',
          '서비스 이용 기록: 서비스 이용 일시, 접속 기록, 계정 상태, 알림 수신 및 읽음 여부',
          '푸시 알림 정보: Firebase Cloud Messaging(FCM) 토큰',
        ]),
        SizedBox(height: 8),
        _SubTitle('견적 요청 및 매칭 이용'),
        _BulletList(<String>[
          '작업 카테고리, 작업 지역, 희망 일정, 예산, 작업 요청 내용, 연락 가능 시간',
          '견적 금액, 견적 메시지, 견적 상태, 결제 상태 및 입금 확인 정보',
          '매칭 이후 이용자와 운용자 간 채팅 메시지 및 읽음 여부',
        ]),
        SizedBox(height: 8),
        _SubTitle('운용자 등록 및 프로필 운영'),
        _BulletList(<String>[
          '사업자명, 사업자등록번호, 대표자명, 운용자 표시명, 이메일',
          '자격증 종류·번호·파일, 보험사·보험증권번호, 드론 제조사·모델·신고번호',
          '활동 가능 지역, 작업 분야, 소개 문구, 포트폴리오 URL 및 이미지, 프로필 사진',
        ]),
        SizedBox(height: 8),
        _SubTitle('피드 및 커뮤니티 이용'),
        _BulletList(<String>[
          '피드 게시글, 이미지, 댓글, 좋아요 기록',
          '게시글 작성자 표시명, 프로필 이미지, 작성 일시',
        ]),
        SizedBox(height: 8),
        _SubTitle('자동 수집 항목'),
        _BulletList(<String>[
          '기기 정보: 기기 모델, 운영체제 버전, 앱 버전',
          '위치 정보: 사용자가 직접 입력하거나 선택한 작업 지역 정보 (GPS 자동 수집 없음)',
        ]),
        SizedBox(height: 32),

        _SectionTitle('2. 개인정보 수집·이용 목적'),
        SizedBox(height: 10),
        _BulletList(<String>[
          '회원 가입, 로그인, 본인 확인 및 서비스 이용 계약 이행',
          '드론 작업 견적 요청, 견적 응답, 운용자 매칭 및 작업 진행 관리',
          '운용자 등록 심사, 프로필·포트폴리오 공개 및 운영',
          '채팅, 피드, 댓글, 좋아요 등 서비스 내 커뮤니케이션 기능 제공',
          '푸시 알림, 서비스 안내 및 고객 문의 대응',
          '결제 상태 확인, 분쟁 대응, 부정 이용 방지 및 보안 강화',
          '서비스 품질 향상을 위한 이용 현황 분석',
        ]),
        SizedBox(height: 32),

        _SectionTitle('3. 개인정보 보관 기간'),
        SizedBox(height: 10),
        _Body(
          '회사는 개인정보의 수집·이용 목적이 달성되거나 이용자가 삭제를 요청하면 지체 없이 파기하는 것을 원칙으로 합니다. 다만 관계 법령 또는 분쟁 대응, 부정 이용 방지 등 정당한 보관 사유가 있는 경우 아래 기간 동안 보관 후 파기합니다.',
        ),
        SizedBox(height: 8),
        _BulletList(<String>[
          '계정 정보, 프로필, 포트폴리오, 피드 게시글, 채팅 메시지: 계정 삭제 요청 시 즉시 파기',
          '전자상거래 등에서의 소비자 보호에 관한 법률: 계약·청약철회 기록 5년, 대금결제·재화 등의 공급 기록 5년, 소비자 불만·분쟁처리 기록 3년',
          '통신비밀보호법: 서비스 이용 접속 로그 3개월',
          '부정 이용 방지 및 분쟁 대응을 위한 내부 정책: 필요한 범위에서 최대 30일',
        ]),
        SizedBox(height: 32),

        _SectionTitle('4. 개인정보 제3자 제공'),
        SizedBox(height: 10),
        _Body(
          '회사는 이용자의 개인정보를 원칙적으로 제3자에게 제공하지 않습니다. 다만 아래의 경우에는 필요한 범위에서 개인정보를 제공할 수 있습니다.',
        ),
        SizedBox(height: 8),
        _BulletList(<String>[
          '이용자가 사전에 동의한 경우',
          '법령에 근거가 있거나 수사 기관 등 권한 있는 기관의 적법한 요청이 있는 경우',
          '견적 요청, 매칭, 채팅 또는 작업 진행을 위해 이용자와 운용자 사이에 표시명, 작업 요청 내용, 작업 지역, 연락 가능 시간 등 필요한 최소 정보를 공유하는 경우',
        ]),
        SizedBox(height: 32),

        _SectionTitle('5. 개인정보 처리 위탁'),
        SizedBox(height: 10),
        _Body('회사는 원활한 서비스 제공을 위해 아래와 같이 개인정보 처리를 위탁하고 있습니다.'),
        SizedBox(height: 8),
        _BulletList(<String>[
          'Supabase (미국): 회원 인증, 데이터베이스 저장·관리, 파일 저장 — 계정 정보, 견적 요청, 운용자 등록 정보, 채팅·피드·알림 데이터, 업로드 파일',
          'Firebase Cloud Messaging, Google LLC (미국): 앱 푸시 알림 발송 — FCM 토큰, 알림 제목 및 내용',
        ]),
        SizedBox(height: 32),

        _SectionTitle('6. 개인정보의 국외 이전'),
        SizedBox(height: 10),
        _Body('회사는 서비스 운영을 위해 아래와 같이 개인정보를 국외로 이전합니다.'),
        SizedBox(height: 8),
        _BulletList(<String>[
          '이전받는 자: Supabase, Inc. (미국) | 이전 항목: 계정 정보, 서비스 이용 데이터 전반 | 이전 목적: 데이터베이스·인증·파일 저장 | 보유 기간: 서비스 계약 기간',
          '이전받는 자: Google LLC (미국, Firebase) | 이전 항목: FCM 토큰, 알림 내용 | 이전 목적: 푸시 알림 발송 | 보유 기간: 서비스 계약 기간',
        ]),
        SizedBox(height: 8),
        _Body('각 수탁사는 업계 표준 보안 조치(TLS 암호화, 접근 제어 등)를 적용하고 있습니다. 이에 동의하지 않으실 경우 서비스 이용이 제한될 수 있습니다.'),
        SizedBox(height: 32),

        _SectionTitle('7. 이용자의 권리 및 행사 방법'),
        SizedBox(height: 10),
        _Body('이용자는 언제든지 다음의 개인정보 관련 권리를 행사할 수 있습니다.'),
        SizedBox(height: 8),
        _BulletList(<String>[
          '개인정보 열람 요청',
          '개인정보 정정·삭제 요청',
          '개인정보 처리 정지 요청',
          '개인정보 처리에 대한 동의 철회',
          '계정 및 관련 데이터 삭제 요청',
        ]),
        SizedBox(height: 8),
        _Body('권리 행사는 앱 내 마이페이지 또는 아래 개인정보 보호 담당 이메일(privacy@modeofficial.net)로 요청하실 수 있으며, 회사는 영업일 기준 7일 이내 조치합니다.'),
        SizedBox(height: 20),
        _AccountDeletionCard(),
        SizedBox(height: 32),

        _SectionTitle('8. 개인정보 보호 조치'),
        SizedBox(height: 10),
        _BulletList(<String>[
          '비밀번호는 인증 서비스의 보안 정책에 따라 암호화되어 저장되며 회사 직원도 복호화할 수 없음',
          '개인정보는 HTTPS(TLS) 암호화 통신으로 전송',
          '불필요한 개인정보 최소 수집 원칙 적용',
          '개인정보 접근 권한을 서비스 운영에 필요한 담당자로 제한',
          'Supabase Row Level Security 등 접근 제어 정책 적용',
        ]),
        SizedBox(height: 32),

        _SectionTitle('9. 쿠키, 광고 및 분석 도구'),
        SizedBox(height: 10),
        _Body(
          '본 앱은 현재 제3자 광고 SDK 및 Google Analytics를 사용하지 않습니다. 향후 광고 또는 분석 도구를 도입하여 개인정보 처리 방식이 변경되는 경우 본 방침을 개정하고 사전에 안내합니다.',
        ),
        SizedBox(height: 32),

        _SectionTitle('10. 아동 개인정보 보호'),
        SizedBox(height: 10),
        _Body(
          '본 서비스는 만 14세 미만 아동을 대상으로 하지 않습니다. 14세 미만 아동의 계정 생성을 허용하지 않으며, 해당 사실이 확인될 경우 지체 없이 계정과 관련 정보를 삭제합니다.',
        ),
        SizedBox(height: 32),

        _SectionTitle('11. 개인정보 보호책임자 및 문의'),
        SizedBox(height: 10),
        _Body('개인정보 처리에 관한 문의, 불만 처리, 피해 구제 등은 아래 이메일로 문의해 주세요.'),
        SizedBox(height: 8),
        _BulletList(<String>[
          '앱 이름: 모두의 드론 모드',
          '개발자: modeOfficial',
          '일반 문의 이메일: drame020101@modeofficial.net',
          '개인정보·계정 삭제 전용 이메일: privacy@modeofficial.net',
          '웹사이트: https://modeofficial.net',
        ]),
        SizedBox(height: 8),
        _Body(
          '개인정보 침해에 대한 신고나 상담은 개인정보보호위원회(privacy.go.kr) 또는 한국인터넷진흥원 개인정보침해신고센터(privacy.kisa.or.kr, 국번없이 118)에 문의하실 수 있습니다.',
        ),
        SizedBox(height: 32),

        _SectionTitle('12. 개인정보처리방침 변경'),
        SizedBox(height: 10),
        _Body(
          '본 개인정보처리방침은 법령 변경 또는 서비스 변경에 따라 수정될 수 있습니다. 변경 시 앱 화면 또는 이메일 등을 통해 사전 고지합니다.',
        ),
        SizedBox(height: 12),
        _Body('공고일: 2026년 6월 7일  |  시행일: 2026년 6월 7일'),
        SizedBox(height: 48),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text, {this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: DC.ink,
            height: 1.25,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: DC.muted,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: DC.ink,
        height: 1.4,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: DC.ink,
        height: 1.5,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DC.body,
        height: 1.65,
      ),
    );
  }
}

class _AccountDeletionCard extends StatelessWidget {
  const _AccountDeletionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF0052FF)),
              SizedBox(width: 8),
              Text(
                '계정 및 데이터 삭제 요청 방법',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0052FF),
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _StepRow(number: '1', text: '앱 내 마이페이지 하단 계정 섹션에서 "계정 삭제"를 선택하세요.'),
          const _StepRow(number: '2', text: '"이메일로 삭제 요청" 버튼을 눌러 발송해 주세요.'),
          const _StepRow(number: '3', text: '회사는 영업일 기준 7일 이내 삭제를 처리하고 결과를 안내합니다.'),
          const SizedBox(height: 16),
          const Text(
            '삭제되는 데이터',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: DC.ink),
          ),
          const SizedBox(height: 6),
          const _SmallBullet('계정 정보 (이름, 닉네임, 이메일, 비밀번호) — 즉시 삭제'),
          const _SmallBullet('프로필 사진, 포트폴리오 이미지 및 파일 — 즉시 삭제'),
          const _SmallBullet('피드 게시글, 이미지, 댓글 — 즉시 삭제'),
          const _SmallBullet('FCM 토큰(푸시 알림 정보) — 즉시 삭제'),
          const SizedBox(height: 12),
          const Text(
            '법령에 따라 보관되는 데이터',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: DC.ink),
          ),
          const SizedBox(height: 6),
          const _SmallBullet('견적 요청 및 거래 기록 — 전자상거래법에 따라 최대 5년 보관'),
          const _SmallBullet('소비자 불만·분쟁 처리 기록 — 소비자보호법에 따라 3년 보관'),
          const _SmallBullet('서비스 접속 로그 — 통신비밀보호법에 따라 3개월 보관'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                unawaited(openPlatformUrl(
                  'mailto:privacy@modeofficial.net'
                  '?subject=%EA%B3%84%EC%A0%95%20%EC%82%AD%EC%A0%9C%20%EC%9A%94%EC%B2%AD'
                  '&body=%EC%95%B1%20%EC%9D%B4%EB%A6%84%3A%20%EB%AA%A8%EB%91%90%EC%9D%98%20%EB%93%9C%EB%A1%A0%20%EB%AA%A8%EB%93%9C%0A%EA%B3%84%EC%A0%95%20%EC%82%AD%EC%A0%9C%EB%A5%BC%20%EC%9A%94%EC%B2%AD%ED%95%A9%EB%8B%88%EB%8B%A4.',
                ));
              },
              icon: const Icon(Icons.mail_outline_rounded, size: 16),
              label: const Text('이메일로 계정 삭제 요청하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0052FF),
                side: const BorderSide(color: Color(0xFF0052FF)),
                textStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '계정 삭제 요청 이메일: privacy@modeofficial.net',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: DC.muted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _AccountDeletionWebLink(),
        ],
      ),
    );
  }
}

class _AccountDeletionWebLink extends StatelessWidget {
  const _AccountDeletionWebLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/delete-account'),
      child: const Text(
        '계정 삭제 전용 페이지 열기 (로그인 없이 접근 가능) →',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          color: Color(0xFF0052FF),
          decoration: TextDecoration.underline,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

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
            width: 20,
            height: 20,
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
                fontSize: 11,
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

class _SmallBullet extends StatelessWidget {
  const _SmallBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 6),
            child: SizedBox(
              width: 4,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: DC.muted, shape: BoxShape.circle),
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

class _BulletList extends StatelessWidget {
  const _BulletList(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: SizedBox(
                          width: 14,
                          child: Text(
                            '·',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              color: DC.muted,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: DC.body,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
