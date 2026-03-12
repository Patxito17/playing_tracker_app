import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/home/presentation/widgets/home_class_card_compact.dart';
import 'package:playing_tracker/features/home/presentation/widgets/home_dashboard_header.dart';
import 'package:playing_tracker/features/home/presentation/widgets/home_stat_card.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('Home Widgets Tests', () {
    testWidgets('HomeDashboardHeader displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: HomeDashboardHeader(
            title: 'Test Title',
            subtitle: 'Test Subtitle',
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('HomeStatCard displays label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: HomeStatCard(
            label: 'Total Students',
            value: '42',
            icon: Icons.group,
          ),
        ),
      );

      expect(find.text('Total Students'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('HomeClassCardCompact displays class info and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        TestWrapper(
          child: HomeClassCardCompact(
            className: 'Piano Class',
            studentCount: 10,
            icon: Icons.piano,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Piano Class'), findsOneWidget);
      expect(find.text('10 alumnos'), findsOneWidget);
      expect(find.byIcon(Icons.piano), findsOneWidget);

      await tester.tap(find.byType(HomeClassCardCompact));
      expect(tapped, true);
    });
  });
}
