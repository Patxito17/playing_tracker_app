# Arquitectura del Proyecto - Playing Tracker

**Última actualización:** Octubre 2025
**Propósito:** Documentación de la arquitectura Feature-First, patrones de diseño y gestión de estado

---

## Arquitectura General

### Feature-First Architecture

El proyecto sigue una arquitectura **Feature-First** (organización por funcionalidad), no por tipo técnico. Esto facilita el mantenimiento, escalabilidad y comprensión del código.

### Estructura de Carpetas

```
lib/
├── core/                              # Código compartido entre features
│   ├── constants/                     # Constantes globales
│   │   ├── app_constants.dart        # Espaciado, colores, tamaños
│   │   └── app_strings.dart          # Strings organizados por categorías
│   ├── extensions/                   # Extension methods
│   │   └── context_extensions.dart   # Extensions para BuildContext
│   └── utils/                         # Utilidades generales
│       ├── validators.dart           # Validadores de formularios
│       └── firebase_error_mapper.dart # Mapeo de errores Firebase a español
│
├── config/                            # Configuración de la app
│   ├── theme/                        # Sistema de temas
│   │   └── app_theme.dart           # ThemeData Material Design 3
│   └── routes/                       # Navegación
│       └── app_routes.dart          # Configuración de go_router
│
├── features/                          # Features por funcionalidad
│   ├── auth/                         # Autenticación
│   ├── home/                         # Pantallas home
│   ├── classes/                      # Gestión de clases
│   ├── tasks/                        # Gestión de tareas
│   ├── sessions/                     # Cronómetro y sesiones
│   ├── statistics/                   # Estadísticas
│   └── settings/                     # Configuración
│
└── shared/                            # Widgets compartidos
    └── widgets/                      # Componentes reutilizables
```

### Estructura de un Feature

Cada feature sigue la estructura **Clean Architecture simplificada** con tres capas:

```
features/[feature]/
├── domain/                           # Capa de dominio (lógica de negocio)
│   ├── models/                      # Modelos de datos
│   ├── enums/                       # Enumeraciones
│   └── repositories/               # Interfaces de repositorios (opcional)
│
├── data/                            # Capa de datos
│   ├── services/                   # Servicios de Firebase/API
│   └── repositories/               # Implementación de repositorios
│
└── presentation/                    # Capa de presentación
    ├── cubit/                      # Gestión de estado
    │   ├── [feature]_cubit.dart   # Cubit principal
    │   └── [feature]_state.dart   # Estados
    ├── screens/                    # Pantallas
    └── widgets/                    # Widgets específicos del feature
```

---

## Gestión de Estado

### Sistema Principal: Cubit

**Cubit** es el sistema principal de gestión de estado (más simple que Bloc). Se usa para la mayoría de casos de uso.

**Cuándo usar Cubit:**
- Estado simple y directo
- Lógica de negocio sin necesidad de historial de eventos
- La mayoría de casos de uso del proyecto

**Cuándo usar Bloc:**
- Solo cuando necesites historial de eventos
- Lógica basada en eventos complejos
- Casos especiales que requieran eventos explícitos

### Estructura de un Cubit

```dart
// features/auth/presentation/cubit/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> loginUser(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

### Estados con Freezed o Sealed Class

Todos los estados deben ser inmutables. Usar **Freezed** o **sealed class** (Dart 3+):

```dart
// Opción 1: Sealed class (Dart 3+)
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Opción 2: Freezed (más verboso pero más potente)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.success(User user) = _Success;
  const factory AuthState.error(String message) = _Error;
}
```

### Uso en Widgets

```dart
// Usar context.read<CubitType>() para acciones
ElevatedButton(
  onPressed: () => context.read<AuthCubit>().loginUser(email, password),
  child: Text('Login'),
)

// Usar context.watch<CubitType>() para escuchar cambios
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthError) return Text(state.message);
    if (state is AuthSuccess) return Text('Bienvenido');
    return SizedBox.shrink();
  },
)
```

---

## Patrones de Diseño Utilizados

### 1. Repository Pattern

Abstrae el acceso a datos, permitiendo cambiar la implementación sin afectar la lógica de negocio.

```dart
// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(UserData userData);
  Future<void> logout();
}

// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl(this._authService, this._firestoreService);

  @override
  Future<User> login(String email, String password) async {
    final authUser = await _authService.signInWithEmailAndPassword(email, password);
    final userData = await _firestoreService.getUserData(authUser.uid);
    return User.fromFirestore(userData);
  }
}
```

### 2. Service Layer

Servicios encapsulan la comunicación con Firebase u otras APIs externas.

```dart
// data/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
```

### 3. Dependency Injection Manual

Usar `BlocProvider` y `RepositoryProvider` para inyección de dependencias:

```dart
// main.dart
BlocProvider(
  create: (context) => AuthCubit(
    AuthRepositoryImpl(
      AuthService(),
      FirestoreService(),
    ),
  ),
  child: MyApp(),
)
```

---

## Navegación

### go_router con ShellRoute

Usar `ShellRoute` para BottomNavigationBar persistente:

```dart
// config/routes/app_routes.dart
final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/classes',
          builder: (context, state) => const ClassesListScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
```

### Navegación Condicional por Rol

```dart
// Redirigir según rol después de login
GoRoute(
  path: '/home',
  redirect: (context, state) {
    final userRole = context.read<AuthCubit>().state.user?.role;
    if (userRole == UserRole.teacher) return '/teacher/classes';
    if (userRole == UserRole.student) return '/student/classes';
    return '/login';
  },
)
```

---

## Extension Methods

Usar extension methods para mejorar la legibilidad:

```dart
// core/extensions/context_extensions.dart
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  // Helpers para navegación
  void pushNamed(String route) => GoRouter.of(this).go(route);
  void pop() => GoRouter.of(this).pop();
}
```

---

## Principios de Diseño

### 1. Single Responsibility Principle (SRP)
Cada clase/función debe tener una sola responsabilidad.

### 2. Dependency Inversion Principle (DIP)
Depender de abstracciones (interfaces), no de implementaciones concretas.

### 3. Open/Closed Principle (OCP)
Abierto para extensión, cerrado para modificación.

### 4. Composition over Inheritance
Preferir composición sobre herencia.

### 5. DRY (Don't Repeat Yourself)
Evitar duplicación de código mediante componentes reutilizables.

---

## Convenciones de Nombres

### Archivos
- **snake_case** para nombres de archivos: `auth_cubit.dart`, `user_model.dart`
- **Descriptivos:** `teacher_classes_list_screen.dart` en lugar de `teacher_list.dart`

### Clases y Widgets
- **PascalCase** para clases: `AuthCubit`, `UserModel`, `LoginScreen`
- **Sufijos descriptivos:** `Screen`, `Widget`, `Cubit`, `State`, `Model`, `Service`, `Repository`

### Variables y Funciones
- **camelCase** para variables y funciones: `userEmail`, `loginUser()`
- **Nombres descriptivos:** `totalDurationLogged` en lugar de `total`

### Constantes
- **lowerCamelCase** con prefijo: `kDefaultPadding`, `kMaxPasswordLength`

---

## Flujo de Datos

```
UI (Widget)
  ↓
Cubit (Estado)
  ↓
Repository (Orquestación)
  ↓
Service (Firebase/API)
  ↓
Firestore/API Externa
```

### Ejemplo Completo

```dart
// 1. Widget llama al Cubit
onPressed: () => context.read<TaskCubit>().createTask(taskData)

// 2. Cubit llama al Repository
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;

  Future<void> createTask(TaskData data) async {
    emit(TaskLoading());
    try {
      final task = await _repository.createTask(data);
      emit(TaskSuccess(task));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}

// 3. Repository orquesta Services
class TaskRepositoryImpl implements TaskRepository {
  final TaskService _taskService;
  final FirestoreService _firestoreService;

  @override
  Future<Task> createTask(TaskData data) async {
    final taskDoc = await _taskService.createTask(data);
    await _firestoreService.updateClassTaskCount(data.classId);
    return Task.fromFirestore(taskDoc);
  }
}

// 4. Service interactúa con Firebase
class TaskService {
  Future<DocumentSnapshot> createTask(TaskData data) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .add(data.toMap())
        .then((ref) => ref.get());
  }
}
```

---

## Referencias

- **Guía completa del proyecto:** [Guia_Proyecto_PlayingTracker.md](./Guia_Proyecto_PlayingTracker.md)
- **Documentación de flutter_bloc:** https://bloclibrary.dev/
- **Documentación de go_router:** https://pub.dev/packages/go_router
- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

