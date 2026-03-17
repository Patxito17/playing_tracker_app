/// Estadísticas de un alumno dentro de una clase para un periodo de tiempo.
class StudentClassStatsModel {
  const StudentClassStatsModel({
    required this.studentId,
    required this.studentName,
    required this.totalDuration,
    required this.totalSessions,
    this.lastSessionDate,
  });

  final String studentId;
  final String studentName;
  final int totalDuration;
  final int totalSessions;
  final DateTime? lastSessionDate;

  String get durationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) return '$hours h ${minutes > 0 ? "$minutes min" : ""}';
    if (minutes > 0) return '$minutes min';
    if (totalDuration > 0) return '${totalDuration % 60} s';
    return '—';
  }

  int get daysSinceLastSession {
    if (lastSessionDate == null) return -1;
    return DateTime.now().difference(lastSessionDate!).inDays;
  }
}
