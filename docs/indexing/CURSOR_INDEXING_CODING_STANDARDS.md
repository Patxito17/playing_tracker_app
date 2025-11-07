# Estándares de Código - Playing Tracker

**Última actualización:** Octubre 2025
**Propósito:** Convenciones de código, reglas de estilo y mejores prácticas para el proyecto

---

## Principios Generales

### Reglas Fundamentales
- **SIEMPRE** escribir comentarios en español claro y detallado
- **SIEMPRE** usar nombres descriptivos en inglés para variables, funciones y clases
- **SIEMPRE** estructurar el código en componentes/módulos pequeños y reutilizables
- **SIEMPRE** seguir el principio DRY (Don't Repeat Yourself)
- **SIEMPRE** aplicar principios SOLID cuando sea aplicable
- **SIEMPRE** priorizar la legibilidad sobre la brevedad
- **SIEMPRE** preferir soluciones simples y elegantes sobre complejas
- **SIEMPRE** favorecer composición sobre herencia
- **SIEMPRE** implementar funciones puras cuando sea posible
- **SIEMPRE** usar inmutabilidad para prevenir bugs

---

## Convenciones de Flutter / Dart

### Const y Widgets Inmutables
- Usar `const` siempre que sea posible en widgets inmutables
- Preferir constructores `const` para optimizar reconstrucciones

```dart
// ✅ CORRECTO
const Text('Hola mundo')
const SizedBox(height: 16)

// ❌ INCORRECTO
Text('Hola mundo')  // Sin const cuando es posible
```

### Freezed o Sealed Class para Estados
- Usar **Freezed** o **sealed class** (Dart 3+) para clases de estado inmutables
- Aprovechar **record types** cuando sea apropiado para retornar múltiples valores

```dart
// ✅ CORRECTO - Sealed class
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

// ✅ CORRECTO - Record type
(String name, int age) getUserInfo() => ('Juan', 25);
```

### Sintaxis de Funciones
- Para funciones simples, usar la sintaxis flecha (`=>`)
- Getters/setters simples deben usar cuerpos de expresión

```dart
// ✅ CORRECTO
String get fullName => '$firstName $lastName';
bool get isValid => email.isNotEmpty && password.length >= 6;

// ✅ CORRECTO - Función simple
int sum(int a, int b) => a + b;
```

### Comas Finales
- Usar comas finales para que el formateo con `dart format` quede bien estructurado

```dart
// ✅ CORRECTO
Column(
  children: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),  // Coma final
  ],
)
```

---

## Material Design 3

### Configuración del Tema
- Usar `useMaterial3: true` en el ThemeData de la app
- Generar paletas de colores con `ColorScheme.fromSeed(seedColor: Colors.blue)`
- Usar tokens de diseño del tema: `Theme.of(context).colorScheme.primary`

```dart
// ✅ CORRECTO
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5),
    brightness: Brightness.light,
  ),
)
```

### Componentes M3
- Usar los nuevos componentes M3: `FilledButton`, `FilledButton.tonal`, `OutlinedButton`, `TextButton`
- Aplicar elevación mediante `surfaceTintColor` en lugar de sombras fuertes
- Para formularios, usar `InputDecoration` con `filled: true` y bordes redondeados

```dart
// ✅ CORRECTO - Botón M3
FilledButton(
  onPressed: () {},
  child: Text('Guardar'),
)

// ✅ CORRECTO - TextField M3
TextField(
  decoration: InputDecoration(
    filled: true,
    labelText: 'Email',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Extension Methods para Acceso Rápido
- Usar extension methods para acceso rápido al tema

```dart
// core/extensions/context_extensions.dart
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

// Uso
Container(
  color: context.colorScheme.primary,
)
```

---

## Arquitectura

### Feature-First Organization
- Organizar el código por **features** (feature-first), no por tipos técnicos
- Separar en capas dentro de cada feature: `presentation`, `domain`, `data`
- Widgets pequeños y reutilizables (máximo 300 líneas por archivo)

### Extension Methods
- Usar **extension methods** para añadir funcionalidad específica a tipos

```dart
// ✅ CORRECTO
extension StringX on String {
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
```

### Dependency Injection
- Implementar dependency injection manual o con paquetes como `get_it`
- Mantener un solo sistema de gestión de estado por proyecto (Cubit)

---

## Cubit / State Management

### Sistema Principal: Cubit
- **Cubit** es el sistema principal de gestión de estado
- Todos los estados deben definirse con **Freezed** o **sealed class** (inmutabilidad)
- Los nombres de los métodos del Cubit deben ser descriptivos: `loginUser()`, `createTask()`

### Uso en Widgets
- Usar `context.read<CubitType>()` para acciones
- Usar `context.watch<CubitType>()` para escuchar cambios
- Usar `BlocBuilder`, `BlocListener` y `BlocConsumer` según necesites rebuilds, side effects o ambos

```dart
// ✅ CORRECTO
ElevatedButton(
  onPressed: () => context.read<AuthCubit>().loginUser(email, password),
  child: Text('Login'),
)

BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthError) return Text(state.message);
    return SizedBox.shrink();
  },
)
```

---

## Manejo de Errores / Validaciones

### Mostrar Errores
- Las vistas deben mostrar errores con `SelectableText.rich`, no con SnackBars
- Usar colores distintivos (rojo) para errores visibles
- Gestionar estados vacíos (sin datos) dentro de la pantalla correspondiente

```dart
// ✅ CORRECTO
if (state is AuthError)
  SelectableText.rich(
    TextSpan(
      text: state.message,
      style: TextStyle(color: context.colorScheme.error),
    ),
  )
```

### Validaciones
- La lógica de carga / error debe estar dentro de los estados del Cubit/Bloc
- Validar parámetros de entrada en funciones críticas

```dart
// ✅ CORRECTO
Future<void> createTask(TaskData data) async {
  // Validación de entrada
  if (data.title.isEmpty) {
    throw ArgumentError('El título es requerido');
  }

  emit(TaskLoading());
  try {
    final task = await _repository.createTask(data);
    emit(TaskSuccess(task));
  } catch (e) {
    emit(TaskError(e.toString()));
  }
}
```

---

## Widgets y UI

### Evitar Métodos `_buildSomething`
- **Evitar métodos `_buildSomething(...)`** — crear widgets privados pequeños (`_MyWidget`) en su lugar
- Si un widget supera ~100 líneas, moverlo a su propio archivo

```dart
// ✅ CORRECTO
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderWidget(),
        _ContentWidget(),
        _FooterWidget(),
      ],
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Header');
  }
}

// ❌ INCORRECTO
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),  // Evitar métodos _build
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() { ... }  // ❌ No usar
}
```

### Const Constructors
- Usar `const` constructores siempre que sea posible para optimizar reconstrucciones
- Preferiblemente usar extension methods: `context.theme` en lugar de `Theme.of(context)`

### TextField
- En `TextField`, siempre configurar: `textCapitalization`, `keyboardType`, `textInputAction`
- Siempre incluir `errorBuilder` y `loadingBuilder` en `Image.network`

```dart
// ✅ CORRECTO
TextField(
  textCapitalization: TextCapitalization.words,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  decoration: InputDecoration(
    labelText: 'Email',
  ),
)
```

### Accesibilidad
- Usar `Semantics` para mejorar accesibilidad en widgets personalizados
- Asegurar contraste mínimo de 4.5:1 en textos normales y 3:1 en textos grandes
- Proporcionar labels semánticos descriptivos a todos los botones, inputs y elementos interactivos

---

## Comentarios y Documentación

### Comentarios en Español
- Cada función/método debe tener un comentario explicando:
  - Qué hace la función
  - Qué parámetros recibe
  - Qué retorna
  - Ejemplo de uso cuando sea complejo

```dart
/// Realiza el proceso de login del usuario
///
/// [email] Correo electrónico del usuario
/// [password] Contraseña del usuario
///
/// Returns: Future<bool> indicando si el login fue exitoso
///
/// Throws: [ArgumentError] si los parámetros están vacíos
/// Throws: [Exception] si hay errores de red o servidor
Future<bool> loginUser({
  required String email,
  required String password,
}) async {
  // Implementación
}
```

### Documentación de Clases
- Usar **dartdoc comments** (`///`) para documentar APIs públicas
- Incluir ejemplos de uso en comentarios de funciones/clases complejas

```dart
/// Servicio para gestionar la autenticación de usuarios
///
/// Esta clase proporciona métodos para login, logout y gestión
/// del estado de autenticación de la aplicación.
class AuthService {
  // ...
}
```

---

## Optimización

### Widgets Const
- Usar widgets `const` siempre que sea posible para optimizar reconstrucciones
- Usar `ListView.builder` u otros widgets optimizados para listas largas

### Imágenes
- `AssetImage` para recursos locales
- `cached_network_image` para imágenes remotas con cache

### Firestore
- Usar índices y límites para consultas eficientes
- Implementar paginación para listas largas

---

## Testing

### Estructura de Tests
- Escribir **unit tests** para toda la lógica de negocio (Cubits, funciones puras, utilidades)
- Usar **widget tests** para componentes críticos de UI y flujos de interacción
- Organizar tests en la misma estructura de carpetas que `/lib`

### Testing de Cubit
```dart
group('AuthCubit', () {
  late AuthCubit authCubit;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authCubit = AuthCubit(mockAuthService);
  });

  test('should emit [Loading, Success] when login is successful', () async {
    // Arrange
    when(() => mockAuthService.login('test@test.com', 'password'))
        .thenAnswer((_) async => User(id: '1', email: 'test@test.com'));

    // Act & Assert
    expectLater(
      authCubit.stream,
      emitsInOrder([AuthLoading(), AuthSuccess(any())]),
    );

    await authCubit.loginUser('test@test.com', 'password');
  });
});
```

---

## Utilidades y Extras

### Depuración
- Para depuración, usar `log()` de `dart:developer` en lugar de `print()`
- Configurar un `BlocObserver` para monitorear las transiciones de Cubit en desarrollo

### Formateo
- Mantener las líneas por debajo de ~80 caracteres (configurable en `analysis_options.yaml`)
- Usar `flutter analyze` para verificar problemas antes de commit
- Configurar shortcuts de teclado en el IDE para formateo automático con `dart format`

---

## Referencias

- **Effective Dart:** https://dart.dev/guides/language/effective-dart
- **Flutter Best Practices:** https://docs.flutter.dev/development/best-practices
- **Material Design 3:** https://m3.material.io/
- **Cubit Documentation:** https://bloclibrary.dev/docs/cubit
- **Guía del proyecto:** [Guia_Proyecto_PlayingTracker.md](./Guia_Proyecto_PlayingTracker.md)

