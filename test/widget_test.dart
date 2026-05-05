import 'package:drane/feat/main/network/mock_drone_pilot_api.dart';
import 'package:drane/feat/main/ui/pages/main_page.dart';
import 'package:drane/main.dart';
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

    expect(find.text('DRAME: 드론 매칭 플랫폼'), findsOneWidget);
    expect(find.text('촬영'), findsWidgets);
    expect(find.text('농약방제'), findsWidgets);
    expect(find.text('지도에서 바로 촬영자 선택'), findsOneWidget);
  });

  test('prioritizes permitted pilots for selected area', () async {
    final pilots = await MockDronePilotApi().fetchPilots(priorityArea: '서울');

    expect(pilots.first.hasPermitFor('서울'), isTrue);
    expect(pilots.first.name, '이서연 운용자');
  });
}
