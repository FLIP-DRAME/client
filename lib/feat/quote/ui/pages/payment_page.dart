import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../network/mock_quote_api.dart';
import '../../network/quote_model.dart';
import '../component/quote_component.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.estimate,
    required this.paymentInstruction,
  });

  final QuoteEstimate estimate;
  final PaymentInstruction paymentInstruction;

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
              body: '입금 확인 후 운용자의 연락수단이 제공됩니다. 실제 입금 검증은 mock 버튼으로 처리합니다.',
            ),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QuoteInfoRow(
                    label: '입금 은행',
                    value: paymentInstruction.bankName,
                  ),
                  QuoteInfoRow(
                    label: '예금주',
                    value: paymentInstruction.accountHolder,
                  ),
                  QuoteInfoRow(
                    label: '계좌번호',
                    value: paymentInstruction.accountNumber,
                  ),
                  QuoteInfoRow(
                    label: '입금 금액',
                    value: paymentInstruction.amountLabel,
                  ),
                  QuoteInfoRow(
                    label: '입금자명',
                    value: paymentInstruction.depositorName,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: quoteSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: quoteLine),
                    ),
                    child: const Text(
                      '입금 전 촬영 일정과 요청 범위를 다시 확인하세요. 결제 후에는 연락수단이 열리고 세부 일정 조율을 진행합니다.',
                      style: QuoteText.body,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final contact = MockQuoteApi().createContactAccess(
                          estimate,
                        );
                        context.push(
                          '/quote/contact',
                          extra: <String, Object?>{
                            'estimate': estimate,
                            'contactAccess': contact,
                          },
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: quoteNavy,
                        foregroundColor: Colors.white,
                        textStyle: QuoteText.button,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('입금 확인 완료'),
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
