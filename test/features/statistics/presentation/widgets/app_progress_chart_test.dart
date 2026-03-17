import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/presentation/widgets/app_progress_chart.dart';

void main() {
  group('AppProgressChart', () {
    testWidgets('renders correctly with progress value', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppProgressChart(progress: 0.75)),
        ),
      );

      // Assert
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('shows 0% for zero progress', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppProgressChart(progress: 0.0)),
        ),
      );

      // Assert
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('shows 100% for full progress', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppProgressChart(progress: 1.0)),
        ),
      );

      // Assert
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('applies custom size', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppProgressChart(progress: 0.5, size: 200)),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(AppProgressChart),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, equals(200));
      expect(sizedBox.height, equals(200));
    });

    testWidgets('displays custom center widget when provided', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppProgressChart(
              progress: 0.8,
              centerWidget: Text('Custom Center'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Center'), findsOneWidget);
      expect(find.text('80%'), findsNothing);
    });

    testWidgets('throws assertion error for invalid progress values', (
      tester,
    ) async {
      // Assert - progress > 1.0
      expect(
        () => AppProgressChart(progress: 1.5),
        throwsA(isA<AssertionError>()),
      );

      // Assert - progress < 0.0
      expect(
        () => AppProgressChart(progress: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
