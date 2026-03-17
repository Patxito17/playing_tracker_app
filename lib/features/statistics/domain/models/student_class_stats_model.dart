/// Estadísticas de un alumno dentro de una clase para un periodo de tiempo.
///
/// Modelo liviano usado en el ranking de la vista del docente. Solo contiene
/// los campos necesarios para ordenar y mostrar la actividad por alumno,
/// sin repetir datos completos del perfil del estudiante.
class StudentClassStatsModel {
  const StudentClassStatsModel({
    required this.studentId,
    required this.studentName,
    required this.totalDuration,
    required this.totalSessions,
    this.lastSessionDate,
  });

  /// Identificador único del alumno (UID de Firebase Authentication).
  final String studentId;

  /// Nombre completo del alumno (denormalizado desde la membresía).
  final String studentName;

  /// Tiempo total de práctica en el periodo, en segundos.
  final int totalDuration;

  /// Número de sesiones completadas en el periodo.
  final int totalSessions;

  /// Fecha de la última sesión registrada en el periodo; null si no hay actividad.
  final DateTime? lastSessionDate;

  /// Duración total formateada en formato legible (h, min, s).
  /// Devuelve "—" si no hay actividad registrada.
  String get durationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    if (minutes > 0) return '$minutes min';
    if (totalDuration > 0) return '${totalDuration % 60} s';
    return '—';
  }

  /// Número de días transcurridos desde la última sesión.
  /// Devuelve -1 si el alumno no ha registrado ninguna sesión.
  int get daysSinceLastSession {
    if (lastSessionDate == null) return -1;
    return DateTime.now().difference(lastSessionDate!).inDays;
  }
}
