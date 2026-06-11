import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../model/quote_model.dart';
import '../component/quote_component.dart';

class QuoteEstimatePage extends ConsumerStatefulWidget {
  const QuoteEstimatePage({super.key, required this.estimate});

  final QuoteEstimate estimate;

  @override
  ConsumerState<QuoteEstimatePage> createState() => _QuoteEstimatePageState();
}

class _QuoteEstimatePageState extends ConsumerState<QuoteEstimatePage> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return QuoteScaffold(
      title: '견적 확인',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            QuoteStepHeader(
              title: '운용자의 견적이 도착했습니다',
              body: widget.estimate.message,
            ),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.estimate.request.pilot.name,
                    style: QuoteText.sectionTitle,
                  ),
                  const SizedBox(height: 18),
                  QuoteInfoRow(
                    label: '작업 카테고리',
                    value: widget.estimate.request.category,
                  ),
                  QuoteInfoRow(
                    label: '촬영 지역',
                    value: widget.estimate.request.area,
                  ),
                  QuoteInfoRow(
                    label: '희망 일정',
                    value: widget.estimate.request.preferredDate,
                  ),
                  QuoteInfoRow(
                    label: '견적 금액',
                    value: widget.estimate.priceLabel,
                  ),
                  QuoteInfoRow(
                    label: '예상 작업 시간',
                    value: widget.estimate.estimatedTime,
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('포함 항목'),
                  ...widget.estimate.includedItems.map(
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
                      onPressed: _submitting
                          ? null
                          : () async {
                              setState(() => _submitting = true);
                              try {
                                final payment = await ref
                                    .read(quoteViewModelProvider)
                                    .createPaymentInstruction(widget.estimate);
                                if (!context.mounted) return;
                                context.push(
                                  '/quote/payment',
                                  extra: <String, Object?>{
                                    'estimate': widget.estimate.copyWith(
                                      paymentId: payment.paymentId,
                                    ),
                                    'paymentInstruction': payment,
                                  },
                                );
                              } catch (_) {
                                if (mounted) {
                                  setState(() => _submitting = false);
                                }
                              }
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
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('계좌이체 결제로 진행하기'),
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
