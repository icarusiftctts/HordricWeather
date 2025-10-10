import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hordricweather/main.dart';

void main() {
  testWidgets('HordricWeather app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for animations
    await tester.pumpAndSettle();
  });

  test('App initialization test', () {
    // Simple test to verify the app can be instantiated
    const app = MyApp();
    expect(app, isNotNull);
  });
}
