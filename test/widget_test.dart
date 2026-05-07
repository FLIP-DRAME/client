import 'package:drane/feat/main/network/mock_drone_pilot_api.dart';
import 'package:drane/feat/main/ui/pages/main_page.dart';
import 'package:drane/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders service-style Drame home', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DrameStore(),
        child: const DrameApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('필요한 드론 작업,\n검증된 조종사와 빠르게 연결하세요'), findsOneWidget);
    expect(find.text('항공 촬영부터 방제, 점검, 측량까지 한번에'), findsOneWidget);
  });

  testWidgets('runs category to contact demo quote flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DrameStore(),
        child: const DrameApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -620));
    await tester.pumpAndSettle();

    expect(find.text('카테고리별 드론 서비스'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('category-aerial')));
    await tester.pumpAndSettle();

    expect(find.text('촬영 지역을 선택하세요'), findsOneWidget);
    final seoulChip = find.byKey(const ValueKey('area-서울'));
    await tester.ensureVisible(seoulChip);
    await tester.pumpAndSettle();
    await tester.tap(seoulChip);
    await tester.pumpAndSettle();

    expect(find.text('조건에 맞는 운용자'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pilot-pilot-001')));
    await tester.pumpAndSettle();

    expect(find.text('견적 요청하기'), findsOneWidget);
    await tester.tap(find.text('촬영 요청하기'));
    await tester.pumpAndSettle();

    expect(find.text('견적 작성'), findsOneWidget);
    await tester.tap(find.text('견적 요청하기'));
    await tester.pumpAndSettle();

    expect(find.text('운용자의 견적이 도착했습니다'), findsOneWidget);
    await tester.tap(find.text('계좌이체 결제로 진행하기'));
    await tester.pumpAndSettle();

    expect(find.text('안심계좌로 결제를 진행하세요'), findsOneWidget);
    await tester.tap(find.text('입금 확인 완료'));
    await tester.pumpAndSettle();

    expect(find.text('결제가 확인되었습니다'), findsOneWidget);
    expect(find.text('전화번호'), findsOneWidget);
  });

  test('prioritizes permitted pilots for selected area', () async {
    final pilots = await MockDronePilotApi().fetchPilots(priorityArea: '서울');

    expect(pilots.first.hasPermitFor('서울'), isTrue);
    expect(pilots.first.name, '이서연 운용자');
  });
}
