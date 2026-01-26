/// Excepción base para todos los errores relacionados con estadísticas.
///
/// Todas las excepciones del módulo de estadísticas deben extender esta clase.
/// Incluye un mensaje técnico y un mensaje para mostrar al usuario.
class StatisticsException implements Exception {
  /// Mensaje técnico del error (para logs)
  final String message;

  /// Mensaje amigable para mostrar al usuario (desde app_strings.dart)
  final String userMessage;

  /// Código de error opcional para debugging
  final String? errorCode;

  /// Constructor de la excepción base
  const StatisticsException({
    required this.message,
    required this.userMessage,
    this.errorCode,
  });

  @override
  String toString() =>
      'StatisticsException: $message${errorCode != null ? " (code: $errorCode)" : ""}';
}

/// Excepción lanzada cuando no se encuentran datos para el período solicitado.
class NoDataFoundException extends StatisticsException {
  /// Constructor
  const NoDataFoundException({
    required super.userMessage,
    super.message = 'No data found for the requested period',
    super.errorCode = 'STATS_NO_DATA',
  });
}

/// Excepción lanzada cuando el rango de fechas es inválido.
class InvalidDateRangeException extends StatisticsException {
  /// Constructor
  const InvalidDateRangeException({
    required super.userMessage,
    super.message = 'Invalid date range provided',
    super.errorCode = 'STATS_INVALID_DATE_RANGE',
  });
}

/// Excepción lanzada cuando hay un error en el servicio de Firestore.
class StatisticsServiceException extends StatisticsException {
  /// Constructor
  const StatisticsServiceException({
    required super.userMessage,
    required super.message,
    super.errorCode = 'STATS_SERVICE_ERROR',
  });
}

/// Excepción lanzada cuando se solicitan estadísticas para un recurso inexistente.
class ResourceNotFoundException extends StatisticsException {
  /// Tipo de recurso no encontrado (student, task, class)
  final String resourceType;

  /// ID del recurso no encontrado
  final String resourceId;

  /// Constructor
  const ResourceNotFoundException({
    required this.resourceType,
    required this.resourceId,
    required super.userMessage,
    super.errorCode = 'STATS_RESOURCE_NOT_FOUND',
  }) : super(message: 'Resource not found: $resourceType with id $resourceId');

  @override
  String toString() =>
      'ResourceNotFoundException: $resourceType ($resourceId) not found';
}

/// Excepción lanzada cuando faltan permisos para acceder a las estadísticas.
class PermissionDeniedException extends StatisticsException {
  /// Constructor
  const PermissionDeniedException({
    required super.userMessage,
    super.message = 'Permission denied to access statistics',
    super.errorCode = 'STATS_PERMISSION_DENIED',
  });
}
