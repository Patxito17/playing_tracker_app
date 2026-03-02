/// Filtros de tiempo disponibles para las consultas de estadísticas.
enum TimeFilter {
  /// Esta semana (los últimos 7 días o desde el lunes)
  thisWeek,

  /// Este mes actual
  thisMonth,

  /// Últimos 3 meses usando los índices mensuales
  last3Months,

  /// Últimos 9 meses usando índices mensuales
  last9Months,

  /// Histórico (todo el tiempo, preferiblemente con vistas globalizadas/agregadas)
  allTime,
}
