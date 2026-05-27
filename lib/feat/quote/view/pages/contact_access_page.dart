import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
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
                  Text(widget.contactAccess.note, style: QuoteText.body),
                  const SizedBox(height: 24),
                  if (widget.estimate.jobRequestId != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _openingChat ? null : _startChat,
                        icon: _openingChat
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.chat_rounded, size: 18),
                        label: const Text('채팅으로 작업 조율하기'),
                      ),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
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
