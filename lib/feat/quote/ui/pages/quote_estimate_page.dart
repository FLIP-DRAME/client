import 'package:flutter/material.dart';

import '../../network/mock_quote_api.dart';
import '../../network/quote_model.dart';
import '../component/quote_component.dart';
import 'payment_page.dart';

class QuoteEstimatePage extends StatelessWidget {
  const QuoteEstimatePage({super.key, required this.estimate});

  final QuoteEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return QuoteScaffold(
      title: '견적 확인',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            QuoteStepHeader(title: '운용자의 견적이 도착했습니다', body: estimate.message),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    estimate.request.pilot.name,
                    style: QuoteText.sectionTitle,
                  ),
                  const SizedBox(height: 18),
                  QuoteInfoRow(
                    label: '작업 카테고리',
                    value: estimate.request.category,
                  ),
                  QuoteInfoRow(label: '촬영 지역', value: estimate.request.area),
                  QuoteInfoRow(
                    label: '희망 일정',
                    value: estimate.request.preferredDate,
                  ),
                  QuoteInfoRow(label: '제안가', value: estimate.priceLabel),
                  QuoteInfoRow(
                    label: '예상 작업 시간',
                    value: estimate.estimatedTime,
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('포함 항목'),
                  ...estimate.includedItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.check_rounded,
                            color: quoteNavy,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item, style: QuoteText.body)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final payment = MockQuoteApi().createPaymentInstruction(
                          estimate,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => PaymentPage(
                                  estimate: estimate,
                                  paymentInstruction: payment,
                                ),
                          ),
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
                      child: const Text('계좌이체 결제로 진행하기'),
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
