/// Utilidad para manejar la navegación condicional según el rol del usuario
///
/// En este sprint (Sprint 0), utiliza lógica mock simple. En Sprint 2
/// se reemplazará con lógica real de Firebase Authentication.
///
/// **Lógica de redirección (implementada en GoRouter):**
/// - Si rol = 'teacher' → redirige a /home/teacher
/// - Si rol = 'student' → redirige a /home/student
/// - Si no hay rol → redirige a /login
///
/// **Ejemplo de uso:**
/// ```dart
/// // Establecer rol mock (temporal)
/// AuthWrapper.mockRole = 'teacher';
///
/// // O limpiar rol para ir a login
/// AuthWrapper.mockRole = null;
/// ```
class AuthWrapper {
  /// Mock del rol actual del usuario (temporal)
  ///
  /// Valores posibles:
  /// - 'teacher' → Usuario docente
  /// - 'student' → Usuario alumno
  /// - null → No autenticado
  ///
  /// **Nota:** En Sprint 2, esto se reemplazará con lógica real
  /// usando Firebase Authentication y Firestore.
  ///
  /// La redirección se maneja automáticamente en GoRouter según este valor.
  static String? mockRole;
}
