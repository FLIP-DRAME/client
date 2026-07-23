import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app_providers.dart';
import '../../../../common/mode/mode.dart';
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
  final _detailController = TextEditingController();
  final _contactController = TextEditingController();
  final _amountController = TextEditingController();
  String? _category;
  String? _area;
  String? _district;
  String _budget = '50만원 이하';
  DateTime? _selectedDate;
  LatLng? _pickedLocation;
  String? _pickedLocationLabel;
  bool _submitting = false;

  String get _formattedDate {
    if (_selectedDate == null) return '';
    final y = _selectedDate!.year;
    final m = _selectedDate!.month.toString().padLeft(2, '0');
    final d = _selectedDate!.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parts = dateStr.split('.');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  @override
  void initState() {
    super.initState();
    final quote = widget.initialQuote;
    _category = quote?.category ?? _categoryOptions.first;
    final savedArea = quote?.area ?? _areaOptions.first;
    if (quote != null) {
      final parts = savedArea.split(' ');
      if (parts.length == 2 &&
          defaultServiceAreas.contains(parts[0]) &&
          (defaultServiceDistricts[parts[0]]?.contains(parts[1]) ?? false)) {
        _area = parts[0];
        _district = parts[1];
      }
    }
    _area ??= savedArea;
    _budget = _budgetOptionFromMin(quote?.budgetMin) ?? '50만원 이하';
    _selectedDate = _parseDateString(quote?.date);
    _detailController.text =
        quote?.detail ?? '현장 분위기를 보여주는 항공 촬영과 기본 보정본이 필요합니다.';
    _contactController.text = quote?.contactWindow ?? '평일 오후 2시 이후';
    _amountController.text = _customAmountFromQuote(quote);
  }

  String? _budgetOptionFromMin(int? budgetMin) {
    if (budgetMin == null) return '협의';
    if (budgetMin == 0) return '0~30만원';
    if (budgetMin == 300000) return '30~50만원';
    if (budgetMin == 500000) return '50~100만원';
    if (budgetMin >= 1000000) return '100만원 이상';
    return null;
  }

  String _customAmountFromQuote(UserQuoteSummary? quote) {
    if (quote == null) return '';
    final budgetMin = quote.budgetMin;
    final budgetMax = quote.budgetMax;
    if (budgetMin == null || budgetMax == null) return '';
    const standardMaxes = <int, int>{
      0: 300000,
      300000: 500000,
      500000: 1000000,
    };
    final standardMax = standardMaxes[budgetMin];
    if (standardMax == null || budgetMax == standardMax) return '';
    return '${(budgetMax / 10000).round()}만원';
  }

  @override
  void dispose() {
    _detailController.dispose();
    _contactController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _category;
    final area = _effectiveArea;
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
    final proposedAmount = _parseAmount(_amountController.text.trim());
    final request = QuoteRequest(
      pilot: widget.pilot,
      category: category,
      area: area,
      preferredDate: _formattedDate,
      detail: _detailController.text,
      budgetRange: _budget,
      contactWindow: _contactController.text,
      proposedAmount: proposedAmount,
      latitude: _pickedLocation?.latitude,
      longitude: _pickedLocation?.longitude,
    );
    try {
      final store = ref.read(drameStoreProvider);
      if (_isEditing) {
        await store.updateMyQuoteRequest(
          requestId: widget.initialQuote!.id,
          category: category,
          area: area,
          preferredDate: _formattedDate,
          detail: _detailController.text,
          budgetRange: _budget,
          contactWindow: _contactController.text,
          proposedAmount: proposedAmount,
          latitude: _pickedLocation?.latitude,
          longitude: _pickedLocation?.longitude,
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
    final districtOptions = _districtOptions;
    final selectedCategory =
        categoryOptions.contains(_category)
            ? _category!
            : categoryOptions.first;
    final selectedArea =
        areaOptions.contains(_area) ? _area! : areaOptions.first;
    final selectedDistrict =
        districtOptions.contains(_district) ? _district! : '전체';
    return QuoteScaffold(
      title: _isEditing ? '견적 요청 수정' : '견적 요청',
      child: QuoteShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            QuotePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const FieldLabel('서비스 종류'),
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
                    onSelected: (value) => setState(() {
                      _area = value;
                      _district = null;
                    }),
                  ),
                  if (districtOptions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    ChoiceWrap(
                      values: <String>['전체', ...districtOptions],
                      selected: selectedDistrict,
                      onSelected: (value) => setState(() => _district = value),
                    ),
                  ],
                  const SizedBox(height: 16),
                  QuoteLocationField(
                    location: _pickedLocation,
                    locationLabel: _pickedLocationLabel,
                    onLocationSelected: (result) => setState(() {
                      _pickedLocation = result.position;
                      _pickedLocationLabel = result.label;
                    }),
                  ),
                  const SizedBox(height: 20),
                  QuoteDateField(
                    selectedDate: _selectedDate,
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                  ),
                  const SizedBox(height: 16),
                  QuoteTextField(
                    label: '요청사항',
                    controller: _detailController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('예산'),
                  ChoiceWrap(
                    values: const <String>[
                      '0~30만원',
                      '30~50만원',
                      '50~100만원',
                      '협의',
                    ],
                    selected: _budget,
                    onSelected: (value) => setState(() => _budget = value),
                  ),
                  const SizedBox(height: 16),
                  QuoteTextField(
                    label: '견적 금액 (만원)',
                    controller: _amountController,
                  ),
                  const SizedBox(height: 16),
                  QuoteTextField(
                    label: '연락 가능 시간',
                    controller: _contactController,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _submitting
                                  ? null
                                  : () =>
                                      _isEditing
                                          ? context.go('/my/quotes')
                                          : context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5B616E),
                            side: const BorderSide(color: Color(0xFFE4EAF2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: QuoteText.button,
                          ),
                          child: const Text('이전'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ModeButton(
                          label:
                              _submitting
                                  ? (_isEditing ? '수정 중…' : '요청 중…')
                                  : (_isEditing ? '수정 완료' : '요청 보내기'),
                          onPressed: _submitting ? null : _submit,
                          fullWidth: true,
                        ),
                      ),
                    ],
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

  String? get _effectiveArea {
    if (_district != null && _district != '전체') return '$_area $_district';
    return _area;
  }

  List<String> get _districtOptions {
    final region = _area;
    if (region == null || region == '전체') return const <String>[];
    return defaultServiceDistricts[region] ?? const <String>[];
  }

  List<String> get _areaOptions {
    final values =
        widget.pilot.availableAreas
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    if (values.isEmpty || values.contains('전체')) return defaultServiceAreas;
    return <String>['전체', ...values];
  }

  int? _parseAmount(String text) {
    if (text.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(text);
    if (match == null) return null;
    final wan = int.tryParse(match.group(1) ?? '');
    if (wan == null || wan <= 0) return null;
    return wan * 10000;
  }

  bool get _isEditing => widget.initialQuote != null;
}
