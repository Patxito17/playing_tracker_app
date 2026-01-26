import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/statistics/domain/models/task_stats_model.dart';

void main() {
  group('TaskStatsModel', () {
    test(
      'debe serializar y deserializar correctamente con fromJson/toJson',
      () {
        // Arrange
        final lastSessionDate = DateTime(2026, 1, 25);
        final model = TaskStatsModel(
          taskId: 'task_123',
          taskTitle: 'Escalas mayores',
          totalDuration: 3600,
          totalSessions: 4,
          suggestedDuration: 1800,
          isCompleted: false,
          lastSessionDate: lastSessionDate,
        );

        // Act
        final json = model.toJson();
        final modelFromJson = TaskStatsModel.fromJson(json);

        // Assert
        expect(modelFromJson.taskId, model.taskId);
        expect(modelFromJson.taskTitle, model.taskTitle);
        expect(modelFromJson.totalDuration, model.totalDuration);
        expect(modelFromJson.suggestedDuration, model.suggestedDuration);
        expect(modelFromJson.isCompleted, model.isCompleted);
        expect(modelFromJson, model);
      },
    );

    test('debe calcular el porcentaje de progreso correctamente', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 1800, // 30 minutos
        totalSessions: 2,
        suggestedDuration: 3600, // 60 minutos sugeridos
        isCompleted: false,
      );

      // Act
      final progress = model.progressPercentage;

      // Assert
      expect(progress, 50.0);
    });

    test('debe retornar null para progreso cuando no hay tiempo sugerido', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 1800,
        totalSessions: 2,
        suggestedDuration: null,
        isCompleted: false,
      );

      // Act
      final progress = model.progressPercentage;

      // Assert
      expect(progress, isNull);
    });

    test('hasReachedGoal debe retornar true cuando se alcanza el objetivo', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 3600,
        totalSessions: 2,
        suggestedDuration: 3600,
        isCompleted: false,
      );

      // Assert
      expect(model.hasReachedGoal, isTrue);
    });

    test('remainingTime debe calcular el tiempo restante correctamente', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 1800, // 30 minutos
        totalSessions: 2,
        suggestedDuration: 3600, // 60 minutos sugeridos
        isCompleted: false,
      );

      // Act
      final remaining = model.remainingTime;

      // Assert
      expect(remaining, 1800); // 30 minutos restantes
    });

    test('remainingTime debe ser 0 cuando se alcanza el objetivo', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 3600,
        totalSessions: 2,
        suggestedDuration: 3600,
        isCompleted: false,
      );

      // Assert
      expect(model.remainingTime, 0);
    });

    test('debe formatear el tiempo restante correctamente', () {
      // Arrange
      final model = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea test',
        totalDuration: 1800,
        totalSessions: 2,
        suggestedDuration: 3600,
        isCompleted: false,
      );

      // Act
      final formatted = model.remainingTimeFormatted;

      // Assert
      expect(formatted, '30 min');
    });

    test('copyWith debe crear una nueva instancia con valores modificados', () {
      // Arrange
      final original = TaskStatsModel(
        taskId: 'task_123',
        taskTitle: 'Tarea original',
        totalDuration: 1800,
        totalSessions: 2,
        isCompleted: false,
      );

      // Act
      final modified = original.copyWith(
        taskTitle: 'Tarea modificada',
        isCompleted: true,
      );

      // Assert
      expect(modified.taskId, original.taskId);
      expect(modified.taskTitle, 'Tarea modificada');
      expect(modified.totalDuration, original.totalDuration);
      expect(modified.isCompleted, isTrue);
    });
  });
}
