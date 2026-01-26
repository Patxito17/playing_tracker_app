import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/domain/models/daily_stats_model.dart';

void main() {
  group('DailyStatsModel', () {
    final testTimestamp = Timestamp.fromDate(DateTime(2026, 1, 26));

    test(
      'debe serializar y deserializar correctamente con fromJson/toJson',
      () {
        // Arrange
        final model = DailyStatsModel(
          date: testTimestamp,
          totalDuration: 3600, // 1 hora
          totalSessions: 5,
          uniqueTasks: 3,
        );

        // Act
        final json = model.toJson();
        final modelFromJson = DailyStatsModel.fromJson(json);

        // Assert
        expect(modelFromJson.date, model.date);
        expect(modelFromJson.totalDuration, model.totalDuration);
        expect(modelFromJson.totalSessions, model.totalSessions);
        expect(modelFromJson.uniqueTasks, model.uniqueTasks);
        expect(modelFromJson, model);
      },
    );

    test('debe formatear la duración correctamente', () {
      // Arrange
      final model = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 7265, // 2h 1min 5s
        totalSessions: 3,
        uniqueTasks: 2,
      );

      // Act
      final formatted = model.durationFormatted;

      // Assert
      expect(formatted, '2 h 1 min');
    });

    test('debe calcular el promedio por sesión correctamente', () {
      // Arrange
      final model = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 3600, // 1 hora
        totalSessions: 4,
        uniqueTasks: 2,
      );

      // Act
      final average = model.averageDurationPerSession;

      // Assert
      expect(average, 900); // 900 segundos = 15 minutos
    });

    test('debe retornar 0 para promedio cuando no hay sesiones', () {
      // Arrange
      final model = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 0,
        totalSessions: 0,
        uniqueTasks: 0,
      );

      // Act
      final average = model.averageDurationPerSession;

      // Assert
      expect(average, 0);
    });

    test('copyWith debe crear una nueva instancia con valores modificados', () {
      // Arrange
      final original = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 1800,
        totalSessions: 2,
        uniqueTasks: 1,
      );

      // Act
      final modified = original.copyWith(totalDuration: 3600, totalSessions: 4);

      // Assert
      expect(modified.date, original.date);
      expect(modified.totalDuration, 3600);
      expect(modified.totalSessions, 4);
      expect(modified.uniqueTasks, original.uniqueTasks);
    });

    test('debe comparar correctamente con ==', () {
      // Arrange
      final model1 = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 1800,
        totalSessions: 2,
        uniqueTasks: 1,
      );

      final model2 = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 1800,
        totalSessions: 2,
        uniqueTasks: 1,
      );

      final model3 = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 3600, // diferente
        totalSessions: 2,
        uniqueTasks: 1,
      );

      // Assert
      expect(model1, model2);
      expect(model1, isNot(model3));
    });

    test('toString debe retornar representación legible', () {
      // Arrange
      final model = DailyStatsModel(
        date: testTimestamp,
        totalDuration: 3600,
        totalSessions: 3,
        uniqueTasks: 2,
      );

      // Act
      final stringRep = model.toString();

      // Assert
      expect(stringRep, contains('DailyStatsModel'));
      expect(stringRep, contains('sessions: 3'));
    });
  });
}
