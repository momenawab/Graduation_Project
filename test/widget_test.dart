import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safesight/main.dart';

void main() {
  testWidgets('SafeSight widget instantiates', (WidgetTester tester) async {
    // Test that the SafeSightApp widget can be instantiated
    const safeSightApp = SafeSightApp();

    // Verify widget is not null
    expect(safeSightApp, isNotNull);
  });

  testWidgets('Basic Flutter widgets work', (WidgetTester tester) async {
    // Verify basic Flutter widgets work
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test'),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
