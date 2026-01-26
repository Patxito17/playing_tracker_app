import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_bar_chart.dart';

void main() {
  group('AppBarChart', () {
    testWidgets('renders correctly with data', (tester) async {
      // Arrange
      final data = [
        (label: 'Lun', value: 30.0),
        (label: 'Mar', value: 45.0),
        (label: 'Mié', value: 60.0),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBarChart(data: data, title: 'Tiempo de estudio'),
          ),
        ),
      );

      // Assert
      expect(find.text('Tiempo de estudio'), findsOneWidget);
      expect(find.text('Lun'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('Mié'), findsOneWidget);
    });

    testWidgets('shows empty state when data is empty', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBarChart(data: [])),
        ),
      );

      // Assert
      expect(find.text('No hay datos disponibles'), findsOneWidget);
    });

    testWidgets('applies custom bar color', (tester) async {
      // Arrange
      final data = [(label: 'Test', value: 50.0)];
      const customColor = Colors.red;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBarChart(data: data, barColor: customColor),
          ),
        ),
      );

      // Assert - widget builds without errors
      expect(find.byType(AppBarChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      // Arrange
      final data = [(label: 'Test', value: 50.0)];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppBarChart(data: data, height: 300)),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(AppBarChart),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, equals(300));
    });
  });
}
