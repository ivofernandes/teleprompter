import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('picture overlay opens as a separate customizable feature', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Picture with custom overlay'), findsOneWidget);
    await tester.tap(find.byKey(const Key('picture-overlay-navigation')));
    await tester.pumpAndSettle();

    expect(find.text('Customize picture overlay'), findsOneWidget);
    expect(find.text('Behind the scenes'), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
    expect(find.byKey(const Key('open-overlay-camera')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('overlay-headline-field')),
      'Launch day',
    );
    await tester.pump();
    expect(find.text('Launch day'), findsNWidgets(2));
  });
}
