import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('capture mode and white mark can be configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Animated white mark'), findsOneWidget);

    final switchFinder = find.byKey(const Key('white-mark-switch'));
    expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
    await tester.tap(switchFinder);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
  });
}
