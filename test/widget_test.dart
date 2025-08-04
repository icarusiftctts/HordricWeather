// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('HordricWeather app loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app loads with HordricWeather title
    expect(find.text('HordricWeather'), findsOneWidget);
    expect(find.text('Découvrir la météo'), findsOneWidget);

    // Tap the discover button and trigger a frame.
    await tester.tap(find.text('Découvrir la météo'));
    await tester.pump();

    // Verify that we navigate to city selection
    expect(find.text('Choisir vos villes'), findsOneWidget);
  });
}
