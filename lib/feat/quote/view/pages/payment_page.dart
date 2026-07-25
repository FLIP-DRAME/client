import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
import '../../model/quote_model.dart';
import '../component/quote_component.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({
    super.key,
    required this.estimate,
    required this.paymentInstruction,
  });

  final QuoteEstimate estimate;
  final PaymentInstruction paymentInstruction;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return QuoteScaffold(
      title: '계좌이체 결제',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const QuoteStepHeader(
              title: '안심계좌로 결제를 진행하세요',
              body: '입금 확인 후 운용자의 연락수단이 제공됩니다.',
            ),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QuoteInfoRow(
                    label: '입금 은행',
                    value: widget.paymentInstruction.bankName,
                  ),
                  QuoteInfoRow(
                    label: '예금주',
                    value: widget.paymentInstruction.accountHolder,
                  ),
                  QuoteInfoRow(
                    label: '계좌번호',
                    value: widget.paymentInstruction.accountNumber,
                  ),
                  QuoteInfoRow(
                    label: '입금 금액',
                    value: widget.paymentInstruction.amountLabel,
                  ),
                  QuoteInfoRow(
                    label: '입금자명',
                    value: widget.paymentInstruction.depositorName,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ModeCard(
                      variant: ModeCardVariant.softFilled,
                      padding: const EdgeInsets.all(16),
                      radius: 10,
                      child: const ModeText(
                        '입금 전 촬영 일정과 요청 범위를 다시 확인하세요. 결제 후에는 연락수단이 열리고 세부 일정 조율을 진행합니다.',
                        size: 14,
                        color: quoteMuted,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ModeButton(
                    label: '입금 확인 완료',
                    fullWidth: true,
                    loading: _submitting,
                    onPressed: () async {
                      setState(() => _submitting = true);
                      try {
                        final contact = await ref
                            .read(quoteViewModelProvider)
                            .createContactAccess(
                              widget.estimate.copyWith(
                                paymentId: widget
                                    .paymentInstruction.paymentId,
                              ),
                            );
                        if (!context.mounted) return;
                        context.push(
                          '/quote/contact',
                          extra: <String, Object?>{
                            'estimate': widget.estimate,
                            'contactAccess': contact,
                          },
                        );
                      } catch (_) {
                        if (mounted) {
                          setState(() => _submitting = false);
                        }
                      }
                    },
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
