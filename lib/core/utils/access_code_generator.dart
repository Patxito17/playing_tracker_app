import 'dart:math';

/// Helper responsable de generar y validar códigos de acceso alfanuméricos.
///
/// Los códigos siguen el formato `A2B3C4` (seis caracteres en mayúsculas) para
/// facilitar su lectura en clase y minimizar errores de digitación. Se excluyen
/// caracteres ambiguos como `0`, `O`, `I` o `1`.
class AccessCodeGenerator {
  /// Crea una nueva instancia del generador de códigos.
  ///
  /// [length] define la longitud del código (por defecto 6) y puede ajustarse
  /// en pruebas. [random] permite inyectar una fuente determinista durante
  /// tests para obtener resultados reproducibles.
  AccessCodeGenerator({this.length = _defaultLength, Random? random})
    : assert(length > 0, 'La longitud del código debe ser mayor que cero'),
      _random = random ?? Random.secure();

  /// Longitud deseada del código.
  final int length;

  /// Fuente de aleatoriedad utilizada para construir el código.
  final Random _random;

  /// Genera un nuevo código alfanumérico siguiendo las reglas del proyecto.
  String generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final index = _random.nextInt(_allowedCharacters.length);
      buffer.write(_allowedCharacters[index]);
    }
    return buffer.toString();
  }

  /// Valida que [code] respete la longitud y caracteres permitidos.
  bool isValid(String code) => _accessCodePattern.hasMatch(code.trim());
}

/// Genera un código usando la configuración por defecto.
String generateAccessCode() => AccessCodeGenerator().generate();

/// Valida códigos en llamados puntuales sin necesidad de instanciar la clase.
bool isValidAccessCode(String code) => AccessCodeGenerator().isValid(code);

const _defaultLength = 6;
const _allowedCharacters = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
final _accessCodePattern = RegExp(r'^[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{6}$');
