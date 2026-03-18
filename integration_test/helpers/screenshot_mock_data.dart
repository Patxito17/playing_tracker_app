import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';
import 'package:playing_tracker/features/classes/domain/models/class_model.dart';
import 'package:playing_tracker/features/sessions/domain/models/session_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/student_progress_model.dart';
import 'package:playing_tracker/features/statistics/domain/models/weekly_stats_model.dart';
import 'package:playing_tracker/features/tasks/domain/enums/task_status.dart';
import 'package:playing_tracker/features/tasks/domain/models/assignment_model.dart';
import 'package:playing_tracker/features/tasks/domain/models/task_model.dart';

/// Datos mock realistas para capturas de pantalla de la App Store / Play Store.
///
/// Todos los datos son estáticos y no dependen de Firebase en tiempo de ejecución.
/// Las fechas fijas (2026-03-10) garantizan reproducibilidad en los screenshots.
class ScreenshotMockData {
  ScreenshotMockData._();

  // ---------------------------------------------------------------------------
  // IDs constantes
  // ---------------------------------------------------------------------------

  static const String _studentId = 'student-screenshot-001';
  static const String _teacherId = 'teacher-screenshot-001';
  static const String _classId1 = 'class-screenshot-001';
  static const String _classId2 = 'class-screenshot-002';
  static const String _taskId1 = 'task-screenshot-001';
  static const String _taskId2 = 'task-screenshot-002';
  static const String _taskId3 = 'task-screenshot-003';

  // ---------------------------------------------------------------------------
  // Timestamps fijos (2026-03-10 como fecha de referencia)
  // ---------------------------------------------------------------------------

  static final Timestamp _refDate =
      Timestamp.fromDate(DateTime(2026, 3, 10, 12, 0));
  static final Timestamp _refDateMinus1 =
      Timestamp.fromDate(DateTime(2026, 3, 9, 11, 0));
  static final Timestamp _refDateMinus2 =
      Timestamp.fromDate(DateTime(2026, 3, 8, 10, 30));
  static final Timestamp _refDateMinus3 =
      Timestamp.fromDate(DateTime(2026, 3, 7, 9, 0));
  static final Timestamp _refDateMinus4 =
      Timestamp.fromDate(DateTime(2026, 3, 6, 18, 0));
  static final Timestamp _weekStart =
      Timestamp.fromDate(DateTime(2026, 3, 9)); // lunes
  static final Timestamp _weekEnd =
      Timestamp.fromDate(DateTime(2026, 3, 15)); // domingo
  static final Timestamp _createdAt =
      Timestamp.fromDate(DateTime(2026, 1, 15));

  // ---------------------------------------------------------------------------
  // Alumna (Ana García)
  // ---------------------------------------------------------------------------

  static StudentModel get student => StudentModel(
        id: _studentId,
        firstName: 'Ana',
        lastName: 'García',
        email: 'ana.garcia@example.com',
        createdAt: _createdAt,
        updatedAt: _refDate,
        isActive: true,
        totalSessionsCount: 12,
        totalDurationLogged: 7200, // 2 horas en segundos
        lastSessionDate: _refDate,
      );

  // ---------------------------------------------------------------------------
  // Docente (Carlos Mendoza)
  // ---------------------------------------------------------------------------

  static TeacherModel get teacher => TeacherModel(
        id: _teacherId,
        firstName: 'Carlos',
        lastName: 'Mendoza',
        email: 'carlos.mendoza@example.com',
        createdAt: _createdAt,
        updatedAt: _refDate,
        isActive: true,
      );

  // ---------------------------------------------------------------------------
  // Clases (para la vista del docente)
  // ---------------------------------------------------------------------------

  static ClassModel get classPianoIntermedio => ClassModel(
        id: _classId1,
        name: 'Piano Nivel Intermedio',
        description: 'Repertorio clásico y técnica de escalas',
        ownerTeacherId: _teacherId,
        accessCode: 'PIA234',
        createdAt: _createdAt,
        updatedAt: _refDate,
      );

  static ClassModel get classGuitarraIniciacion => ClassModel(
        id: _classId2,
        name: 'Guitarra Iniciación',
        description: 'Acordes básicos y lectura de cifrado',
        ownerTeacherId: _teacherId,
        accessCode: 'GIT567',
        createdAt: _createdAt,
        updatedAt: _refDate,
      );

  /// Lista de clases del docente (2 clases con grupos distintos).
  static List<ClassModel> get teacherClasses => [
        classPianoIntermedio,
        classGuitarraIniciacion,
      ];

  // ---------------------------------------------------------------------------
  // Tareas maestras
  // ---------------------------------------------------------------------------

  static TaskModel get taskEscalaDo => TaskModel(
        id: _taskId1,
        title: 'Escala de Do Mayor',
        description:
            'Practicar la escala en dos octavas, ascendente y descendente, '
            'a 60 BPM con metrónomo.',
        createdBy: _teacherId,
        durationSuggested: 1800, // 30 min
        createdAt: _createdAt,
        updatedAt: _refDate,
        dueDate: Timestamp.fromDate(DateTime(2026, 3, 20)),
      );

  static TaskModel get taskEstudio1 => TaskModel(
        id: _taskId2,
        title: 'Estudio nº 1 de Czerny',
        description:
            'Trabajo de independencia de dedos. '
            'Manos por separado primero, luego juntas.',
        createdBy: _teacherId,
        durationSuggested: 2700, // 45 min
        createdAt: _createdAt,
        updatedAt: _refDate,
      );

  static TaskModel get taskSonataMenor => TaskModel(
        id: _taskId3,
        title: 'Sonata en La menor',
        description:
            'Primer movimiento. Énfasis en el fraseo del tema principal.',
        createdBy: _teacherId,
        durationSuggested: 3600, // 60 min
        createdAt: _createdAt,
        updatedAt: _refDate,
        dueDate: Timestamp.fromDate(DateTime(2026, 3, 31)),
      );

  // ---------------------------------------------------------------------------
  // Asignaciones de la alumna
  // ---------------------------------------------------------------------------

  static AssignmentModel get assignmentEscalaDo => AssignmentModel(
        id: AssignmentModel.generateId(_taskId1, _studentId),
        taskId: _taskId1,
        studentId: _studentId,
        classId: _classId1,
        className: 'Piano Nivel Intermedio',
        teacherId: _teacherId,
        taskTitle: 'Escala de Do Mayor',
        taskDescription:
            'Practicar la escala en dos octavas, ascendente y descendente.',
        durationSuggested: 1800,
        status: TaskStatus.completed,
        assignedAt: _createdAt,
        completedAt: _refDateMinus1,
        sessionsCount: 5,
        totalDurationLogged: 2700,
        lastSessionDate: _refDateMinus1,
        dueDate: Timestamp.fromDate(DateTime(2026, 3, 20)),
      );

  static AssignmentModel get assignmentEstudio1 => AssignmentModel(
        id: AssignmentModel.generateId(_taskId2, _studentId),
        taskId: _taskId2,
        studentId: _studentId,
        classId: _classId1,
        className: 'Piano Nivel Intermedio',
        teacherId: _teacherId,
        taskTitle: 'Estudio nº 1 de Czerny',
        taskDescription: 'Trabajo de independencia de dedos.',
        durationSuggested: 2700,
        status: TaskStatus.inProgress,
        assignedAt: _createdAt,
        sessionsCount: 4,
        totalDurationLogged: 3000,
        lastSessionDate: _refDate,
      );

  static AssignmentModel get assignmentSonataMenor => AssignmentModel(
        id: AssignmentModel.generateId(_taskId3, _studentId),
        taskId: _taskId3,
        studentId: _studentId,
        classId: _classId1,
        className: 'Piano Nivel Intermedio',
        teacherId: _teacherId,
        taskTitle: 'Sonata en La menor',
        taskDescription:
            'Primer movimiento. Énfasis en el fraseo del tema principal.',
        durationSuggested: 3600,
        status: TaskStatus.pending,
        assignedAt: _refDateMinus2,
        sessionsCount: 0,
        totalDurationLogged: 0,
        dueDate: Timestamp.fromDate(DateTime(2026, 3, 31)),
      );

  /// Lista de asignaciones activas de la alumna (8 tareas, 6 completadas en
  /// el resumen de progreso; aquí se muestran las 3 más representativas).
  static List<AssignmentModel> get studentAssignments => [
        assignmentEstudio1,
        assignmentEscalaDo,
        assignmentSonataMenor,
      ];

  // ---------------------------------------------------------------------------
  // Sesiones recientes
  // ---------------------------------------------------------------------------

  static SessionModel _makeSession({
    required String id,
    required String taskId,
    required String taskTitle,
    required Timestamp start,
    required int durationSeconds,
    String? notes,
  }) {
    final end = Timestamp.fromMillisecondsSinceEpoch(
      start.millisecondsSinceEpoch + (durationSeconds * 1000),
    );
    final date = start.toDate();
    final monthBucket =
        '${date.year}-${date.month.toString().padLeft(2, '0')}';

    return SessionModel(
      id: id,
      studentId: _studentId,
      taskId: taskId,
      teacherId: _teacherId,
      classId: _classId1,
      startTime: start,
      endTime: end,
      totalDuration: durationSeconds,
      pausedDuration: 0,
      dateLogged: start,
      monthBucket: monthBucket,
      taskTitle: taskTitle,
      className: 'Piano Nivel Intermedio',
      notes: notes,
      status: SessionStatus.completed,
      createdAt: start,
    );
  }

  static List<SessionModel> get recentSessions => [
        _makeSession(
          id: 'session-ss-001',
          taskId: _taskId2,
          taskTitle: 'Estudio nº 1 de Czerny',
          start: _refDate,
          durationSeconds: 2100, // 35 min
          notes: 'Buena sesión, mejoré la mano derecha.',
        ),
        _makeSession(
          id: 'session-ss-002',
          taskId: _taskId1,
          taskTitle: 'Escala de Do Mayor',
          start: _refDateMinus1,
          durationSeconds: 1500, // 25 min
        ),
        _makeSession(
          id: 'session-ss-003',
          taskId: _taskId2,
          taskTitle: 'Estudio nº 1 de Czerny',
          start: _refDateMinus2,
          durationSeconds: 2700, // 45 min
          notes: 'Practiqué manos juntas por primera vez.',
        ),
        _makeSession(
          id: 'session-ss-004',
          taskId: _taskId1,
          taskTitle: 'Escala de Do Mayor',
          start: _refDateMinus3,
          durationSeconds: 1200, // 20 min
        ),
        _makeSession(
          id: 'session-ss-005',
          taskId: _taskId1,
          taskTitle: 'Escala de Do Mayor',
          start: _refDateMinus4,
          durationSeconds: 1800, // 30 min
          notes: 'Practiqué a 80 BPM sin errores.',
        ),
      ];

  // ---------------------------------------------------------------------------
  // Progreso del alumno
  // ---------------------------------------------------------------------------

  /// Progreso global: 2 horas totales, 12 sesiones, 8 tareas, 6 completadas.
  static StudentProgressModel get studentProgress => StudentProgressModel(
        studentId: _studentId,
        studentName: 'Ana García',
        totalDuration: 7200, // 2 horas en segundos
        totalSessions: 12,
        currentStreak: 5,
        longestStreak: 8,
        lastSessionDate: _refDate,
        totalTasks: 8,
        completedTasks: 6,
        averageSessionDuration: 600, // 10 min promedio
      );

  // ---------------------------------------------------------------------------
  // Estadísticas semanales
  // ---------------------------------------------------------------------------

  /// Semana actual: 90 minutos, 5 sesiones, 3 tareas únicas.
  static WeeklyStatsModel get currentWeekStats => WeeklyStatsModel(
        weekStart: _weekStart,
        weekEnd: _weekEnd,
        totalDuration: 5400, // 90 min en segundos
        totalSessions: 5,
        uniqueTasks: 3,
        previousWeekDuration: 3600, // 60 min semana anterior
      );
}
