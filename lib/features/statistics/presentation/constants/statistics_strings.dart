/// Strings relacionados con estadísticas
class StatisticsStrings {
  // Títulos
  static const String statisticsTitle = 'Estadísticas';
  static const String generalOverview = 'Vista General';
  static const String timeByDay = 'Tiempo por día';
  static const String timeByTask = 'Distribución por tarea';
  static const String studentRanking = 'Ranking de alumnos';
  static const String studentProgress = 'Progreso del alumno';

  // Métricas
  static const String totalPracticeTime = 'Tiempo total de práctica';
  static const String totalSessions = 'Sesiones totales';
  static const String activeDays = 'Días activos';
  static const String averagePerSession = 'Promedio por sesión';
  static const String currentStreak = 'Racha actual';
  static const String longestStreak = 'Racha más larga';

  // Períodos
  static const String today = 'Hoy';
  static const String yesterday = 'Ayer';
  static const String thisWeek = 'Esta semana';
  static const String lastWeek = 'Semana pasada';
  static const String thisMonth = 'Este mes';
  static const String lastMonth = 'Mes pasado';
  static const String customRange = 'Personalizado';

  // Etiquetas de gráficos
  static const String hoursAbbr = 'h';
  static const String minutesAbbr = 'm';
  static const String secondsAbbr = 's';
  static const String noDataAvailable = 'No hay datos disponibles';
  static const String loadingStats = 'Cargando estadísticas...';

  // Comparativas
  static const String moreThanLastPeriod = 'más que el período anterior';
  static const String lessThanLastPeriod = 'menos que el período anterior';
  static const String sameAsLastPeriod = 'igual que el período anterior';

  // Racha
  static String daysStreak(int days) => '$days días';
  static const String streakMotivation = '¡Mantén viva la llama!';

  // Dashboard Docente
  static const String activeStudents = 'Alumnos activos';
  static const String passiveStudents = 'Alumnos inactivos';
  static const String classAverage = 'Media de la clase';
  static const String topPerfomers = 'Alumnos destacados';
  static const String needsAttention = 'Necesitan atención';

  // Filtros
  static const String filterByClass = 'Filtrar por clase';
  static const String filterByStudent = 'Filtrar por alumno';
  static const String selectPeriod = 'Seleccionar período';

  // Mensajes de error
  static const String statisticsGenericError =
      'Ocurrió un error al cargar las estadísticas.';
  static const String statisticsServiceError =
      'El servicio de estadísticas no está disponible actualmente.';
  static const String permissionDeniedError =
      'No tienes permisos para ver estas estadísticas.';
  static const String resourceNotFoundError = 'No se encontró la información.';
  static const String invalidDateRangeError = 'Rango de fechas no válido.';

  // Ranking
  static String position(int pos) => 'Nº $pos';

  // Formatos de tiempo
  static String hoursFormat(int hours) => '$hours h';
  static String minutesFormat(int minutes) => '$minutes min';
  static String secondsFormat(int seconds) => '$seconds s';
  static String hoursMinutesFormat(int hours, int minutes) =>
      '$hours h $minutes m';

  // Tooltips
  static const String tapForDetails = 'Toca para ver detalles';
  static const String totalTimeOn = 'Tiempo total el';
}
