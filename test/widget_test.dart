// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/main.dart';

void main() {
  testWidgets('Playing Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlayingTrackerApp());

    // Verify that the app title is displayed
    expect(find.text('Playing Tracker - Tema M3'), findsOneWidget);

    // Verify that theme toggle button is present
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
