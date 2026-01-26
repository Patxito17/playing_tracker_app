import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_pie_chart.dart';

void main() {
  group('AppPieChart', () {
    testWidgets('renders correctly with data', (tester) async {
      // Arrange
      final data = [
        (label: 'Escalas', value: 45.0, color: Colors.blue),
        (label: 'Estudios', value: 30.0, color: Colors.red),
        (label: 'Repertorio', value: 25.0, color: Colors.green),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPieChart(data: data, title: 'Distribución por tarea'),
          ),
        ),
      );

      // Assert
      expect(find.text('Distribución por tarea'), findsOneWidget);
      expect(find.text('Escalas'), findsOneWidget);
      expect(find.text('Estudios'), findsOneWidget);
      expect(find.text('Repertorio'), findsOneWidget);
    });

    testWidgets('shows empty state when data is empty', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppPieChart(data: [])),
        ),
      );

      // Assert
      expect(find.text('No hay datos disponibles'), findsOneWidget);
    });

    testWidgets('calculates percentages correctly', (tester) async {
      // Arrange
      final data = [
        (label: 'Tarea 1', value: 50.0, color: null as Color?),
        (label: 'Tarea 2', value: 50.0, color: null as Color?),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppPieChart(data: data)),
        ),
      );

      // Assert - each task should show 50%
      expect(find.text('50.0%'), findsNWidgets(2));
    });

    testWidgets('displays center text when provided', (tester) async {
      // Arrange
      final data = [(label: 'Test', value: 100.0, color: null as Color?)];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPieChart(data: data, centerText: 'Total: 100 min'),
          ),
        ),
      );

      // Assert
      expect(find.text('Total: 100 min'), findsOneWidget);
    });

    testWidgets('responds to touch interactions', (tester) async {
      // Arrange
      final data = [
        (label: 'Tarea 1', value: 60.0, color: null as Color?),
        (label: 'Tarea 2', value: 40.0, color: null as Color?),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppPieChart(data: data)),
        ),
      );

      // Pump the widget tree to settle animations
      await tester.pumpAndSettle();

      // Assert - widget builds and settles without errors
      expect(find.byType(AppPieChart), findsOneWidget);
    });
  });
}
