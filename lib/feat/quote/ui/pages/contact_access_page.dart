import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../network/quote_model.dart';
import '../component/quote_component.dart';

class ContactAccessPage extends StatelessWidget {
  const ContactAccessPage({
    super.key,
    required this.estimate,
    required this.contactAccess,
  });

  final QuoteEstimate estimate;
  final ContactAccess contactAccess;

  @override
  Widget build(BuildContext context) {
    return QuoteScaffold(
      title: '연락수단 제공',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            QuoteStepHeader(
              title: '결제가 확인되었습니다',
              body: '${estimate.request.pilot.name}과 직접 일정을 조율할 수 있습니다.',
            ),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QuoteInfoRow(label: '전화번호', value: contactAccess.phone),
                  QuoteInfoRow(label: '이메일', value: contactAccess.email),
                  QuoteInfoRow(
                    label: '카카오 채널',
                    value: contactAccess.kakaoChannel,
                  ),
                  const SizedBox(height: 14),
                  Text(contactAccess.note, style: QuoteText.body),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('메인으로 돌아가기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: quoteNavy,
                      textStyle: QuoteText.button,
                      side: const BorderSide(color: quoteLine),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
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
