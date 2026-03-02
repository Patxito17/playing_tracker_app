import 'package:playing_tracker/features/statistics/domain/models/class_stats_model.dart';

/// Clase auxiliar para mantener las estadísticas en memoria (caché).
class CachedClassStats {
  const CachedClassStats({required this.stats, required this.timestamp});

  /// Los datos almacenados.
  final ClassStatsModel stats;

  /// El momento en que se guardaron en caché.
  final DateTime timestamp;

  /// Verifica si la caché ha expirado según el [ttl] especificado.
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}
