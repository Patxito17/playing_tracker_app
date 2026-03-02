/// Clase genérica para mantener estadísticas en memoria (caché).
class CachedStats<T> {
  const CachedStats({required this.stats, required this.timestamp});

  /// Los datos almacenados.
  final T stats;

  /// El momento en que se guardaron en caché.
  final DateTime timestamp;

  /// Verifica si la caché ha expirado según el [ttl] especificado.
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}
