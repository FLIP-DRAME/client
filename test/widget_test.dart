import 'package:drane/feat/network/mock_drone_pilot_api.dart';
import 'package:drane/feat/ui/drame_home_page.dart';
import 'package:drane/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders navy map hero as the first home content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DrameStore(),
        child: const DrameApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Drame'), findsWidgets);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('드론 매칭 플랫폼'), findsOneWidget);
    expect(find.text('촬영 제안 보내기'), findsOneWidget);
    expect(find.text('지도 촬영자 목록'), findsNothing);
  });

  test('prioritizes permitted pilots for selected area', () async {
    final pilots = await MockDronePilotApi().fetchPilots(priorityArea: '서울');

    expect(pilots.first.hasPermitFor('서울'), isTrue);
    expect(pilots.first.name, '이서연 운용자');
  });
}
