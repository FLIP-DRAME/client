import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
import '../../model/quote_model.dart';
import '../component/quote_component.dart';

class ContactAccessPage extends ConsumerStatefulWidget {
  const ContactAccessPage({
    super.key,
    required this.estimate,
    required this.contactAccess,
  });

  final QuoteEstimate estimate;
  final ContactAccess contactAccess;

  @override
  ConsumerState<ContactAccessPage> createState() => _ContactAccessPageState();
}

class _ContactAccessPageState extends ConsumerState<ContactAccessPage> {
  bool _openingChat = false;

  Future<void> _startChat() async {
    final jobRequestId = widget.estimate.jobRequestId;
    if (jobRequestId == null) return;

    setState(() => _openingChat = true);
    try {
      final roomId =
          await ref.read(chatViewModelProvider).getOrCreateRoom(jobRequestId);
      if (!mounted) return;
      context.push(
        '/chat/$roomId',
        extra: <String, String>{
          'otherPartyName': widget.estimate.request.pilot.name,
          'category': widget.estimate.request.category,
        },
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

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
              body: '${widget.estimate.request.pilot.name}과 직접 일정을 조율할 수 있습니다.',
            ),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QuoteInfoRow(
                      label: '전화번호', value: widget.contactAccess.phone),
                  QuoteInfoRow(
                      label: '이메일', value: widget.contactAccess.email),
                  QuoteInfoRow(
                    label: '카카오 채널',
                    value: widget.contactAccess.kakaoChannel,
                  ),
                  const SizedBox(height: 14),
                  ModeText(
                    widget.contactAccess.note,
                    size: 14,
                    color: quoteMuted,
                    height: 1.55,
                  ),
                  const SizedBox(height: 24),
                  if (widget.estimate.jobRequestId != null)
                    ModeButton(
                      label: '채팅으로 작업 조율하기',
                      onPressed: _startChat,
                      icon: Icons.chat_rounded,
                      loading: _openingChat,
                      fullWidth: true,
                    ),
                  const SizedBox(height: 10),
                  ModeButton(
                    label: '메인으로 돌아가기',
                    onPressed: () => context.go('/home'),
                    icon: Icons.home_rounded,
                    variant: ModeButtonVariant.secondary,
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
