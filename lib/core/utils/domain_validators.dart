/// Utilidades de validación para el dominio de Playing Tracker.
///
/// Este archivo contiene funciones de validación reutilizables para validar
/// datos de entrada en la capa de dominio de la aplicación. Cada función
/// retorna un String con el mensaje de error si la validación falla, o null
/// si la validación es exitosa.
///
/// Todas las funciones están documentadas con ejemplos de uso y siguen los
/// principios de validación del proyecto.
///
/// Ejemplo de uso:
/// ```dart
/// final nameError = validateName('Juan');
/// if (nameError != null) {
///   print('Error: $nameError');
/// }
/// ```
library;

/// Valida que un nombre tenga el formato correcto.
///
/// Reglas de validación:
/// - No puede estar vacío o contener solo espacios en blanco
/// - Debe tener al menos 3 caracteres (sin contar espacios al inicio/final)
/// - Puede contener letras, espacios, guiones y apóstrofes
///
/// Retorna:
/// - null si el nombre es válido
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateName('María');
/// // error = null (válido)
///
/// final error2 = validateName('AB');
/// // error2 = 'El nombre debe tener al menos 3 caracteres'
/// ```
String? validateName(String? name) {
  // Verificar que no sea null o vacío
  if (name == null || name.trim().isEmpty) {
    return 'El nombre es requerido y no puede estar vacío';
  }

  // Verificar longitud mínima
  if (name.trim().length < 3) {
    return 'El nombre debe tener al menos 3 caracteres';
  }

  // Verificar que contenga caracteres válidos (letras, espacios, guiones, apóstrofes)
  final validNameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$");
  if (!validNameRegex.hasMatch(name.trim())) {
    return 'El nombre solo puede contener letras, espacios, guiones y apóstrofes';
  }

  return null;
}

/// Valida que un email tenga el formato correcto.
///
/// Reglas de validación:
/// - No puede estar vacío
/// - Debe tener formato de email válido (contiene @ y dominio)
/// - Longitud máxima de 254 caracteres (estándar RFC 5321)
///
/// Retorna:
/// - null si el email es válido
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateEmail('usuario@ejemplo.com');
/// // error = null (válido)
///
/// final error2 = validateEmail('correo-invalido');
/// // error2 = 'El formato del email no es válido'
/// ```
String? validateEmail(String? email) {
  // Verificar que no sea null o vacío
  if (email == null || email.trim().isEmpty) {
    return 'El email es requerido y no puede estar vacío';
  }

  // Verificar longitud máxima estándar para emails
  if (email.trim().length > 254) {
    return 'El email es demasiado largo (máximo 254 caracteres)';
  }

  // Regex para validar formato de email
  // Patrón simplificado pero robusto para la mayoría de casos
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(email.trim())) {
    return 'El formato del email no es válido';
  }

  return null;
}

/// Valida que un código de acceso tenga el formato correcto.
///
/// Reglas de validación:
/// - Debe tener exactamente 6 caracteres
/// - Solo puede contener caracteres alfanuméricos (letras y números)
/// - No distingue entre mayúsculas y minúsculas
///
/// Retorna:
/// - null si el código es válido
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateAccessCode('ABC234');
/// // error = null (válido)
///
/// final error2 = validateAccessCode('AB12');
/// // error2 = 'El código de acceso debe tener exactamente 6 caracteres'
/// ```
String? validateAccessCode(String? code) {
  // Verificar que no sea null o vacío
  if (code == null || code.trim().isEmpty) {
    return 'El código de acceso es requerido';
  }

  // Verificar longitud exacta de 6 caracteres
  if (code.trim().length != 6) {
    return 'El código de acceso debe tener exactamente 6 caracteres';
  }

  // Verificar que solo contenga caracteres alfanuméricos
  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  if (!alphanumericRegex.hasMatch(code.trim())) {
    return 'El código de acceso solo puede contener letras y números';
  }

  return null;
}

/// Valida que una duración en segundos sea válida.
///
/// Reglas de validación:
/// - Debe ser un número positivo (mayor a 0)
/// - No puede ser negativo
/// - Se usa para validar duraciones de tareas y sesiones
///
/// Retorna:
/// - null si la duración es válida
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateDuration(3600); // 1 hora
/// // error = null (válido)
///
/// final error2 = validateDuration(-100);
/// // error2 = 'La duración debe ser un número positivo'
/// ```
String? validateDuration(int? duration) {
  // Verificar que no sea null
  if (duration == null) {
    return 'La duración es requerida';
  }

  // Verificar que sea positivo
  if (duration <= 0) {
    return 'La duración debe ser un número positivo';
  }

  return null;
}

/// Valida que un ID no esté vacío.
///
/// Reglas de validación:
/// - No puede estar vacío o contener solo espacios en blanco
/// - Se usa para validar IDs de documentos en Firestore
///
/// Retorna:
/// - null si el ID es válido
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateId('user_123');
/// // error = null (válido)
///
/// final error2 = validateId('');
/// // error2 = 'El ID es requerido y no puede estar vacío'
/// ```
String? validateId(String? id) {
  // Verificar que no sea null o vacío
  if (id == null || id.trim().isEmpty) {
    return 'El ID es requerido y no puede estar vacío';
  }

  return null;
}

/// Valida que una descripción tenga el formato correcto.
///
/// Reglas de validación:
/// - Es opcional (puede ser null o vacío)
/// - Si no es vacío, debe tener máximo 1000 caracteres
/// - Se usa para descripciones de tareas y clases
///
/// Retorna:
/// - null si la descripción es válida o está vacía
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateDescription('Una descripción corta');
/// // error = null (válido)
///
/// final error2 = validateDescription(null);
/// // error2 = null (válido, es opcional)
///
/// final error3 = validateDescription('x' * 1001);
/// // error3 = 'La descripción debe tener máximo 1000 caracteres'
/// ```
String? validateDescription(String? description) {
  // Si es null o vacío, es válido (campo opcional)
  if (description == null || description.trim().isEmpty) {
    return null;
  }

  // Verificar longitud máxima
  if (description.trim().length > 1000) {
    return 'La descripción debe tener máximo 1000 caracteres';
  }

  return null;
}

/// Valida que una URL tenga el formato correcto.
///
/// Reglas de validación:
/// - No puede estar vacía
/// - Debe ser una URL válida según Uri.tryParse
/// - Debe tener esquema (http, https, etc.)
/// - Se usa para validar enlaces a recursos externos
///
/// Retorna:
/// - null si la URL es válida
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateUrl('https://www.ejemplo.com/recurso');
/// // error = null (válido)
///
/// final error2 = validateUrl('url-invalida');
/// // error2 = 'La URL no tiene un formato válido'
/// ```
String? validateUrl(String? url) {
  // Verificar que no sea null o vacío
  if (url == null || url.trim().isEmpty) {
    return 'La URL es requerida y no puede estar vacía';
  }

  // Intentar parsear la URL
  final uri = Uri.tryParse(url.trim());

  // Verificar que el parseo fue exitoso
  if (uri == null) {
    return 'La URL no tiene un formato válido';
  }

  // Verificar que tenga un esquema (http, https, etc.)
  if (!uri.hasScheme) {
    return 'La URL debe incluir un protocolo (http, https, etc.)';
  }

  // Verificar que tenga un host
  if (uri.host.isEmpty) {
    return 'La URL debe incluir un dominio válido';
  }

  return null;
}

/// Valida que un título de tarea tenga el formato correcto.
///
/// Reglas de validación:
/// - No puede estar vacío o contener solo espacios en blanco
/// - Debe tener al menos 3 caracteres
/// - Debe tener máximo 100 caracteres
/// - Se usa para títulos de tareas
///
/// Retorna:
/// - null si el título es válido
/// - String con mensaje de error si la validación falla
///
/// Ejemplo de uso:
/// ```dart
/// final error = validateTitle('Práctica de escalas en Do Mayor');
/// // error = null (válido)
///
/// final error2 = validateTitle('AB');
/// // error2 = 'El título debe tener al menos 3 caracteres'
///
/// final error3 = validateTitle('x' * 101);
/// // error3 = 'El título debe tener máximo 100 caracteres'
/// ```
String? validateTitle(String? title) {
  // Verificar que no sea null o vacío
  if (title == null || title.trim().isEmpty) {
    return 'El título es requerido y no puede estar vacío';
  }

  // Verificar longitud mínima
  if (title.trim().length < 3) {
    return 'El título debe tener al menos 3 caracteres';
  }

  // Verificar longitud máxima
  if (title.trim().length > 100) {
    return 'El título debe tener máximo 100 caracteres';
  }

  return null;
}
