import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_clone/main.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();                                      // Wait for FutureBuilder

    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}