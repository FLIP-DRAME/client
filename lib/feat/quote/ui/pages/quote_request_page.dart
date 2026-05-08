import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../main/network/drone_pilot_model.dart';
import '../../network/mock_quote_api.dart';
import '../../network/quote_model.dart';
import '../component/quote_component.dart';

class QuoteRequestPage extends StatefulWidget {
  const QuoteRequestPage({super.key, required this.pilot});

  final DronePilot pilot;

  @override
  State<QuoteRequestPage> createState() => _QuoteRequestPageState();
}

class _QuoteRequestPageState extends State<QuoteRequestPage> {
  final _dateController = TextEditingController(text: '2026.05.20');
  final _detailController = TextEditingController(
    text: '현장 분위기를 보여주는 항공 촬영과 기본 보정본이 필요합니다.',
  );
  final _contactController = TextEditingController(text: '평일 오후 2시 이후');
  String? _category;
  String? _area;
  String _budget = '50만원 이하';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _category = widget.pilot.categories.first;
    _area = widget.pilot.availableAreas.first;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _detailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final request = QuoteRequest(
      pilot: widget.pilot,
      category: _category!,
      area: _area!,
      preferredDate: _dateController.text,
      detail: _detailController.text,
      budgetRange: _budget,
      contactWindow: _contactController.text,
    );
    final estimate = await MockQuoteApi().createEstimate(request);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    context.push('/quote/estimate', extra: estimate);
  }

  @override
  Widget build(BuildContext context) {
    return QuoteScaffold(
      title: '견적 작성',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${widget.pilot.name}에게 요청할 작업을 작성하세요',
              style: QuoteText.title,
            ),
            const SizedBox(height: 10),
            Text(widget.pilot.intro, style: QuoteText.body),
            const SizedBox(height: 28),
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const FieldLabel('카테고리'),
                  ChoiceWrap(
                    values: widget.pilot.categories,
                    selected: _category!,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('지역'),
                  ChoiceWrap(
                    values: widget.pilot.availableAreas,
                    selected: _area!,
                    onSelected: (value) => setState(() => _area = value),
                  ),
                  const SizedBox(height: 20),
                  QuoteTextField(label: '촬영 희망일', controller: _dateController),
                  const SizedBox(height: 16),
                  QuoteTextField(
                    label: '상세 요청',
                    controller: _detailController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('예산 범위'),
                  ChoiceWrap(
                    values: const <String>['50만원 이하', '50~100만원', '100만원 이상'],
                    selected: _budget,
                    onSelected: (value) => setState(() => _budget = value),
                  ),
                  const SizedBox(height: 20),
                  QuoteTextField(
                    label: '연락 가능 시간',
                    controller: _contactController,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: quoteNavy,
                        foregroundColor: Colors.white,
                        textStyle: QuoteText.button,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(_submitting ? '견적 생성 중' : '견적 요청하기'),
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
