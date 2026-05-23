import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../core/app_defaults.dart';
import '../../../main/model/drone_pilot_model.dart';
import '../../../main/network/drone_pilot_api.dart';
import '../../model/quote_model.dart';
import '../component/quote_component.dart';

class QuoteRequestPage extends ConsumerStatefulWidget {
  const QuoteRequestPage({super.key, required this.pilot, this.initialQuote});

  final DronePilot pilot;
  final UserQuoteSummary? initialQuote;

  @override
  ConsumerState<QuoteRequestPage> createState() => _QuoteRequestPageState();
}

class _QuoteRequestPageState extends ConsumerState<QuoteRequestPage> {
  final _dateController = TextEditingController();
  final _detailController = TextEditingController();
  final _contactController = TextEditingController();
  String? _category;
  String? _area;
  String _budget = '50만원 이하';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final quote = widget.initialQuote;
    _category = quote?.category ?? _categoryOptions.first;
    _area = quote?.area ?? _areaOptions.first;
    _budget = quote?.budgetRange ?? '50만원 이하';
    _dateController.text = quote?.date ?? '2026.05.20';
    _detailController.text =
        quote?.detail ?? '현장 분위기를 보여주는 항공 촬영과 기본 보정본이 필요합니다.';
    _contactController.text = quote?.contactWindow ?? '평일 오후 2시 이후';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _detailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _category;
    final area = _area;
    if (category == null || area == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('견적 요청에 필요한 카테고리와 지역을 선택해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final request = QuoteRequest(
      pilot: widget.pilot,
      category: category,
      area: area,
      preferredDate: _dateController.text,
      detail: _detailController.text,
      budgetRange: _budget,
      contactWindow: _contactController.text,
    );
    try {
      final store = ref.read(drameStoreProvider);
      if (_isEditing) {
        await store.updateMyQuoteRequest(
          requestId: widget.initialQuote!.id,
          area: area,
          preferredDate: _dateController.text,
          detail: _detailController.text,
          budgetRange: _budget,
          contactWindow: _contactController.text,
        );
      } else {
        await store.submitQuoteRequest(request);
      }
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? '견적 요청을 수정했습니다.'
                : '견적 요청을 보냈습니다. 운용자가 확인하면 내 견적에 표시됩니다.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/my/quotes');
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = _categoryOptions;
    final areaOptions = _areaOptions;
    final selectedCategory =
        categoryOptions.contains(_category)
            ? _category!
            : categoryOptions.first;
    final selectedArea =
        areaOptions.contains(_area) ? _area! : areaOptions.first;
    return QuoteScaffold(
      title: _isEditing ? '견적 요청 수정' : '견적 작성',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _isEditing
                  ? '${widget.pilot.name}에게 보낸 요청을 수정하세요'
                  : '${widget.pilot.name}에게 요청할 작업을 작성하세요',
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
                    values: categoryOptions,
                    selected: selectedCategory,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('지역'),
                  ChoiceWrap(
                    values: areaOptions,
                    selected: selectedArea,
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
                      child: Text(
                        _submitting
                            ? (_isEditing ? '수정 중' : '요청 보내는 중')
                            : (_isEditing ? '수정 완료' : '견적 요청하기'),
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

  List<String> get _categoryOptions {
    final values =
        widget.pilot.categories
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    if (values.isNotEmpty) return values;
    return defaultDroneCategories.map((category) => category.label).toList();
  }

  List<String> get _areaOptions {
    final values =
        widget.pilot.availableAreas
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    if (values.isNotEmpty) return values;
    return defaultServiceAreas.where((area) => area != '전체').toList();
  }

  bool get _isEditing => widget.initialQuote != null;
}
