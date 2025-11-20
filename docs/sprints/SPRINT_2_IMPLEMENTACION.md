# SPRINT 2: Autenticación y Gestión de Usuarios

> **Documento técnico de planificación y ejecución del Sprint 2 del proyecto Playing Tracker, centrado en la implementación del sistema de autenticación, roles y persistencia de sesión.**

---

## 📋 Información del Sprint

| Campo | Valor |
|-------|-------|
| **Proyecto** | Playing Tracker |
| **Sprint** | Sprint 2 |
| **Duración** | 2-3 semanas |
| **Estado** | En progreso (Fase 1 completada) |
| **Versión del documento** | 1.2 |
| **Fecha** | 13 de Noviembre 2025 |
| **Última actualización** | 20 de Noviembre 2025 |
| **Responsable** | Equipo de Desarrollo |

---

## 🎯 Objetivo del Sprint

Implementar un sistema completo de autenticación con Firebase que permita:

- **Autenticación robusta** con Firebase Authentication (email/password)
- **Gestión de perfiles** diferenciados (Teacher/Student) en Firestore
- **Navegación condicional** por rol usando GoRouter con guards
- **Persistencia de sesión** automática entre reinicios con hydrated_bloc
- **UI completa** de autenticación usando custom widgets del Sprint 0

### Resultado Esperado

**Al finalizar este Sprint, la aplicación deberá permitir a cualquier usuario registrarse o iniciar sesión, mantener su sesión activa, y ser redirigido automáticamente a su entorno de usuario (Teacher/Student) sin intervención manual.**

---

## 🛠️ Stack Tecnológico

### Dependencias a Agregar en `pubspec.yaml`

```yaml
dependencies:
  # Firebase Core y Firestore (necesarios para inicialización y datos)
  firebase_core: ^4.2.1
  cloud_firestore: ^6.1.0

  # Firebase Authentication
  firebase_auth: ^6.1.2

  # Gestión de Estado (ya incluido en Sprint 1)
  flutter_bloc: ^9.1.1

  # Persistencia automática de estado
  hydrated_bloc: ^10.1.1

  # Navegación declarativa y guards
  go_router: ^17.0.0

  # Storage para hydrated_bloc
  path_provider: ^2.1.5
```

### Justificación Técnica

- **`firebase_core` y `cloud_firestore`**: Necesarios para inicializar Firebase y manejar la capa de datos de usuarios (roles y perfiles).
- **`hydrated_bloc`**: Debe inicializarse **después de Firebase** para evitar conflictos de acceso al filesystem en macOS o Windows.
- **`go_router`**: Proporciona navegación declarativa y guards reactivos integrados con el estado de autenticación.
- **`path_provider`**: Requerido por `hydrated_bloc` para determinar el directorio de almacenamiento multiplataforma.

---

## 📊 Progreso del Sprint

**Total de Fases:** 8
**Duración Estimada:** 2-3 semanas
**Progreso:** 37.5% (3/8 fases completadas)

| Fase | Descripción | Estado | Duración |
|------|-------------|--------|----------|
| **Fase 1** | Configuración Inicial y Dependencias | ✅ Completada | 2 horas |
| **Fase 2** | AuthCubit y Estados de Autenticación | ✅ Completada | 4 horas |
| **Fase 3** | Repositorios de Autenticación y Firestore | ✅ Completada | 3 horas |
| **Fase 4** | GoRouter y Navegación Condicional | ⏳ Pendiente | 4 horas |
| **Fase 5** | UI de Login y Registro | ⏳ Pendiente | 5 horas |
| **Fase 6** | Pantallas Home y Navegación Principal | ⏳ Pendiente | 4 horas |
| **Fase 7** | Testing y Validaciones | ⏳ Pendiente | 3 horas |
| **Fase 8** | Documentación y Refinamiento | ⏳ Pendiente | 2 horas |

---

## 📝 Fases del Sprint

### Fase 1: Configuración Inicial y Dependencias

**Duración:** 2 horas
**Estado:** ✅ Completada

#### Archivos a Crear/Modificar

- `pubspec.yaml` - Agregar dependencias completas
- `lib/main.dart` - Inicializar Firebase, hydrated_bloc, y GoRouter
- `lib/core/config/router/app_router.dart` - Configuración base de GoRouter

#### Tareas Detalladas

1. **Actualizar `pubspec.yaml`** con todas las dependencias listadas
2. **Ejecutar `flutter pub get`** para descargar dependencias
3. **Configurar `HydratedBloc`** en `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase primero
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Configurar HydratedBloc storage después de Firebase
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // 3. Ejecutar app con HydratedBloc
  HydratedBloc.storage = storage;

  runApp(const MyApp());
}
```

**⚠️ Nota importante:** En macOS y Windows, `path_provider_foundation` se incluye transitivamente, pero es crítico inicializar Firebase **antes** de HydratedBloc para evitar conflictos de acceso al filesystem.

4. **Crear estructura base de `AppRouter`** (implementación completa en Fase 4)
5. **Ejecutar `flutter analyze`** - 0 errores esperados

#### Checklist de Fase 1

- [x] Dependencies agregadas en `pubspec.yaml`
- [x] `flutter pub get` ejecutado exitosamente
- [x] Firebase inicializado en `main.dart`
- [x] HydratedBloc configurado correctamente
- [x] `flutter analyze` sin errores

**Dependencias agregadas (19 de Noviembre 2025):** `firebase_auth`, `hydrated_bloc`, `path_provider`, `mocktail` (dev).

---

### Fase 2: AuthCubit y Estados de Autenticación

**Duración:** 4 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `lib/core/enums/user_role.dart` - Enum compartido de roles
- `lib/features/auth/presentation/cubit/auth_cubit.dart` - Cubit principal
- `lib/features/auth/presentation/cubit/auth_state.dart` - Estados de auth

#### Estados de AuthCubit

Definir estados usando **sealed classes** para pattern matching:

```dart
// lib/features/auth/presentation/cubit/auth_state.dart

import 'package:playing_tracker/core/enums/user_role.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserRole role; // teacher o student
  final String userId;

  const AuthAuthenticated({
    required this.role,
    required this.userId,
  });
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
```

#### Implementación de AuthCubit con HydratedBloc

```dart
// lib/features/auth/presentation/cubit/auth_cubit.dart

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:playing_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/core/enums/user_role.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final IAuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    // Verificar estado de autenticación al inicializar
    checkAuthState();
  }

  /// Verifica si hay una sesión activa al iniciar la app
  Future<void> checkAuthState() async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final role = await _authRepository.getUserRole(user.uid);
        emit(AuthAuthenticated(role: role, userId: user.uid));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Login con email y password
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithEmail(email, password);
      final role = await _authRepository.getUserRole(userCredential.user!.uid);
      emit(AuthAuthenticated(role: role, userId: userCredential.user!.uid));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Registro de Teacher
  Future<void> registerTeacher(String email, String password, String name) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _authRepository.registerWithEmail(email, password);
      await _authRepository.createTeacher(userCredential.user!.uid, name, email);
      emit(AuthAuthenticated(role: UserRole.teacher, userId: userCredential.user!.uid));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Registro de Student
  Future<void> registerStudent(String email, String password, String name) async {
    emit(const AuthLoading());
    try {
      final userCredential = await _authRepository.registerWithEmail(email, password);
      await _authRepository.createStudent(userCredential.user!.uid, name, email);
      emit(AuthAuthenticated(role: UserRole.student, userId: userCredential.user!.uid));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Persistencia con HydratedBloc
  /// ⚠️ IMPORTANTE: Solo persistir campos ligeros (role y userId)
  /// NO persistir UserCredential completo ni tokens sensibles
  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'authenticated') {
        return AuthAuthenticated(
          role: UserRole.values[json['roleIndex'] as int],
          userId: json['userId'] as String,
        );
      }
      return const AuthUnauthenticated();
    } catch (e) {
      return null; // Retornar null fuerza estado inicial
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {
        'type': 'authenticated',
        'roleIndex': state.role.index,
        'userId': state.userId,
      };
    }
    return null; // No persistir otros estados
  }
}
```

#### Enum UserRole Compartido

```dart
// lib/core/enums/user_role.dart

/// Roles de usuario en el sistema
enum UserRole {
  /// Docente/Profesor
  teacher,

  /// Alumno/Estudiante
  student;

  /// Nombre display para UI
  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Docente';
      case UserRole.student:
        return 'Alumno';
    }
  }
}
```

#### Checklist de Fase 2

- [x] Enum `UserRole` creado en `lib/features/auth/domain/enums/`
- [x] Estados de `AuthCubit` definidos con sealed classes
- [x] `AuthCubit` extendiendo `HydratedCubit`
- [x] Métodos `fromJson()` y `toJson()` implementados
- [x] Solo se persisten `userId` y `role` (no tokens sensibles)
- [x] Tests unitarios básicos de AuthCubit creados

---

### Fase 3: Repositorios de Autenticación y Firestore

**Duración:** 3 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `lib/features/auth/domain/repositories/auth_repository.dart` - Contrato principal
- `lib/features/auth/data/repositories/auth_repository_impl.dart` - Implementación Firebase
- `lib/core/utils/firebase_error_mapper.dart` - Helper común de mapeo de errores

#### Interface del AuthRepository

```dart
// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:playing_tracker/core/enums/user_role.dart';

abstract class IAuthRepository {
  /// Usuario actual de Firebase Auth
  User? get currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges;

  /// Login con email y password
  Future<UserCredential> signInWithEmail(String email, String password);

  /// Registro con email y password
  Future<UserCredential> registerWithEmail(String email, String password);

  /// Obtener rol del usuario
  Future<UserRole> getUserRole(String userId);

  /// Crear perfil de Teacher en Firestore
  Future<void> createTeacher(String userId, String name, String email);

  /// Crear perfil de Student en Firestore
  Future<void> createStudent(String userId, String name, String email);

  /// Cerrar sesión
  Future<void> signOut();
}
```

#### Implementación del AuthRepository

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playing_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:playing_tracker/features/auth/domain/models/teacher_model.dart';
import 'package:playing_tracker/features/auth/domain/models/student_model.dart';
import 'package:playing_tracker/core/enums/user_role.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Referencias a colecciones (nombres consistentes con Sprint 1)
  late final CollectionReference<Map<String, dynamic>> _teachersRef;
  late final CollectionReference<Map<String, dynamic>> _studentsRef;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _teachersRef = _firestore.collection('teachers');
    _studentsRef = _firestore.collection('students');
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserRole> getUserRole(String userId) async {
    // Verificar en colección de teachers
    final teacherDoc = await _teachersRef.doc(userId).get();
    if (teacherDoc.exists) {
      return UserRole.teacher;
    }

    // Verificar en colección de students
    final studentDoc = await _studentsRef.doc(userId).get();
    if (studentDoc.exists) {
      return UserRole.student;
    }

    throw Exception('Usuario no encontrado en ninguna colección');
  }

  @override
  Future<void> createTeacher(String userId, String name, String email) async {
    final teacher = TeacherModel(
      id: userId,
      name: name,
      email: email,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isActive: true,
    );

    await _teachersRef.doc(userId).set(teacher.toJson());
  }

  @override
  Future<void> createStudent(String userId, String name, String email) async {
    final student = StudentModel(
      id: userId,
      name: name,
      email: email,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isActive: true,
      // Campos denormalizados con valores iniciales
      classesCount: 0,
      assignmentsCount: 0,
      completedAssignmentsCount: 0,
      totalPracticeTime: 0,
    );

    await _studentsRef.doc(userId).set(student.toJson());
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
```

#### Checklist de Fase 3

- [x] Contrato `AuthRepository` definido
- [x] `AuthRepositoryImpl` implementado con Firebase Auth + Firestore
- [x] Referencias a colecciones `teachers` y `students` configuradas
- [x] Método `getUserRole()` implementado con lógica de búsqueda
- [x] Modelos del Sprint 1 (TeacherModel, StudentModel) utilizados
- [x] Manejo de errores consistente con `FirebaseErrorMapper`

---

### Fase 4: GoRouter y Navegación Condicional

**Duración:** 4 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `lib/core/config/router/app_router.dart` - Configuración completa de GoRouter
- `lib/core/config/router/route_names.dart` - Constantes de rutas
- `lib/core/config/router/go_router_refresh_stream.dart` - Stream para reactividad

#### GoRouterRefreshStream (Navegación Reactiva)

Para que GoRouter reaccione automáticamente a cambios en el AuthState:

```dart
// lib/core/config/router/go_router_refresh_stream.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Listenable que escucha un Stream y notifica cambios
/// Permite que GoRouter recalcule rutas cuando cambia el AuthState
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

#### Constantes de Rutas

```dart
// lib/core/config/router/route_names.dart

class RouteNames {
  // Rutas públicas
  static const splash = '/splash';
  static const login = '/login';
  static const registerSelection = '/register';
  static const registerTeacher = '/register/teacher';
  static const registerStudent = '/register/student';

  // Rutas protegidas - Teacher
  static const teacherHome = '/teacher/home';
  static const teacherProfile = '/teacher/profile';

  // Rutas protegidas - Student
  static const studentHome = '/student/home';
  static const studentProfile = '/student/profile';
}
```

#### Configuración Completa de GoRouter

```dart
// lib/core/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/core/config/router/route_names.dart';
import 'package:playing_tracker/core/config/router/go_router_refresh_stream.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/core/enums/user_role.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,

    // refreshListenable escucha cambios en AuthCubit para reevaluar redirect
    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final currentLocation = state.matchedLocation;

      // Mientras carga, mostrar splash
      if (authState is AuthLoading || authState is AuthInitial) {
        return currentLocation == RouteNames.splash
            ? null
            : RouteNames.splash;
      }

      // Si no está autenticado
      if (authState is AuthUnauthenticated) {
        // Permitir acceso a rutas públicas
        final publicRoutes = [
          RouteNames.login,
          RouteNames.registerSelection,
          RouteNames.registerTeacher,
          RouteNames.registerStudent,
        ];

        return publicRoutes.contains(currentLocation)
            ? null
            : RouteNames.login;
      }

      // Si está autenticado
      if (authState is AuthAuthenticated) {
        // Prevenir acceso a rutas de auth cuando ya está logueado
        final authRoutes = [
          RouteNames.login,
          RouteNames.registerSelection,
          RouteNames.registerTeacher,
          RouteNames.registerStudent,
        ];

        if (authRoutes.contains(currentLocation)) {
          // Redirigir según rol
          return authState.role == UserRole.teacher
              ? RouteNames.teacherHome
              : RouteNames.studentHome;
        }

        // Verificar acceso a rutas protegidas por rol
        if (currentLocation.startsWith('/teacher') && authState.role != UserRole.teacher) {
          return RouteNames.studentHome;
        }

        if (currentLocation.startsWith('/student') && authState.role != UserRole.student) {
          return RouteNames.teacherHome;
        }
      }

      return null; // Permitir navegación
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Selección de tipo de registro
      GoRoute(
        path: RouteNames.registerSelection,
        builder: (context, state) => const RegisterSelectionScreen(),
      ),

      // Registro Teacher
      GoRoute(
        path: RouteNames.registerTeacher,
        builder: (context, state) => const RegisterTeacherScreen(),
      ),

      // Registro Student
      GoRoute(
        path: RouteNames.registerStudent,
        builder: (context, state) => const RegisterStudentScreen(),
      ),

      // Teacher Home
      GoRoute(
        path: RouteNames.teacherHome,
        builder: (context, state) => const TeacherHomeScreen(),
      ),

      // Teacher Profile
      GoRoute(
        path: RouteNames.teacherProfile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Student Home
      GoRoute(
        path: RouteNames.studentHome,
        builder: (context, state) => const StudentHomeScreen(),
      ),

      // Student Profile
      GoRoute(
        path: RouteNames.studentProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],

    // Error handler
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
```

#### Integración en main.dart

```dart
// lib/main.dart (fragmento)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepositoryImpl()),
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          final appRouter = AppRouter(authCubit);

          return MaterialApp.router(
            title: 'Playing Tracker',
            routerConfig: appRouter.router,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

#### Checklist de Fase 4

- [ ] `GoRouterRefreshStream` implementado para reactividad
- [ ] Constantes de rutas definidas en `RouteNames`
- [ ] GoRouter configurado con `refreshListenable`
- [ ] Lógica de `redirect` completa con guards por rol
- [ ] Rutas públicas y protegidas correctamente separadas
- [ ] Deep linking funcionando
- [ ] Navegación reactiva ante cambios de AuthState

---

### Fase 5: UI de Login y Registro

**Duración:** 5 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/register_selection_screen.dart`
- `lib/features/auth/presentation/screens/register_teacher_screen.dart`
- `lib/features/auth/presentation/screens/register_student_screen.dart`
- `lib/core/constants/app_strings.dart` - Centralización de strings (AuthStrings / ClassesStrings)

#### Strings Centralizados

```dart
// lib/core/constants/app_strings.dart

class AuthStrings {
  // Login
  static const loginTitle = 'Iniciar sesión';
  static const emailLabel = 'Correo electrónico';
  static const passwordLabel = 'Contraseña';
  static const loginButton = 'Entrar';
  static const noAccountQuestion = '¿No tienes cuenta?';
  static const registerLink = 'Regístrate';

  // Register Selection
  static const registerTitle = 'Crear cuenta';
  static const selectRoleSubtitle = 'Selecciona tu rol';
  static const teacherOption = 'Soy docente';
  static const studentOption = 'Soy alumno';

  // Register Teacher
  static const registerTeacherTitle = 'Registro de docente';
  static const nameLabel = 'Nombre completo';
  static const createAccountButton = 'Crear cuenta';

  // Register Student
  static const registerStudentTitle = 'Registro de alumno';

  // Errores
  static const errorInvalidCredentials = 'Email o contraseña incorrectos';
  static const errorEmailInUse = 'Este correo ya está registrado';
  static const errorWeakPassword = 'La contraseña debe tener al menos 6 caracteres';
  static const errorGeneric = 'Ocurrió un error. Intenta nuevamente';
}
```

#### LoginScreen (Ejemplo Completo)

```dart
// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/shared/widgets/custom_text_field.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';
import 'package:playing_tracker/core/utils/domain_validators.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/config/router/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMessage =
                state is AuthError ? state.message : null;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título
                          Text(
                            AuthStrings.loginTitle,
                            style: textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          if (errorMessage != null) ...[
                            SelectableText.rich(
                              TextSpan(
                                text: errorMessage,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Campo Email
                          CustomTextField(
                            controller: _emailController,
                            label: AuthStrings.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: validateEmail, // Del Sprint 1
                            // Semantics para accesibilidad
                            semanticsLabel: 'Campo de correo electrónico',
                          ),
                          const SizedBox(height: 16),

                          // Campo Password
                          CustomTextField(
                            controller: _passwordController,
                            label: AuthStrings.passwordLabel,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return ValidationStrings.passwordRequired;
                              }
                              if (value.length < 6) {
                                return AuthStrings.errorWeakPassword;
                              }
                              return null;
                            },
                            semanticsLabel: 'Campo de contraseña',
                          ),
                          const SizedBox(height: 24),

                          // Botón Login
                          CustomButton(
                            text: AuthStrings.loginButton,
                            onPressed: isLoading ? null : _handleLogin,
                            isLoading: isLoading,
                            semanticsLabel: 'Botón de iniciar sesión',
                          ),
                          const SizedBox(height: 16),

                          // Link a registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AuthStrings.noAccountQuestion),
                              TextButton(
                                onPressed: () => context
                                    .push(RouteNames.registerSelection),
                                child: Text(AuthStrings.registerLink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

#### RegisterSelectionScreen (Simplificado)

```dart
// lib/features/auth/presentation/screens/register_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';
import 'package:playing_tracker/shared/widgets/custom_button.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/core/config/router/route_names.dart';

class RegisterSelectionScreen extends StatelessWidget {
  const RegisterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AuthStrings.registerTitle),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AuthStrings.selectRoleSubtitle,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Opción Teacher
                    CustomButton(
                      text: AuthStrings.teacherOption,
                      onPressed: () => context.push(RouteNames.registerTeacher),
                      icon: Icons.school,
                    ),
                    const SizedBox(height: 16),

                    // Opción Student
                    CustomButton.outlined(
                      text: AuthStrings.studentOption,
                      onPressed: () => context.push(RouteNames.registerStudent),
                      icon: Icons.person,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Notas Técnicas de UI

**Gestión de TextEditingController:**
- Usar `BlocBuilder<AuthCubit, AuthState>` para envolver solo los widgets que deben reconstruirse
- Los `TextEditingController` deben mantenerse en el State, no reconstruirse con cada cambio de estado

**Errores accesibles (según flutter_style_rules):**
- Mostrar los mensajes directamente en la UI usando `SelectableText.rich` con contraste adecuado.
- Evitar `SnackBar` para errores de formularios de autenticación; la información debe permanecer visible.

**Accesibilidad:**
- Todos los botones deben tener `semanticsLabel` para VoiceOver/TalkBack
- Contraste mínimo de 4.5:1 en textos (ya garantizado por Material 3)
- Área de toque mínima de 48x48 dp (CustomButton ya lo cumple)

#### Checklist de Fase 5

- [ ] `SplashScreen` implementada
- [ ] `LoginScreen` con validaciones y manejo de errores
- [ ] `RegisterSelectionScreen` con opciones Teacher/Student
- [ ] `RegisterTeacherScreen` con formulario completo
- [ ] `RegisterStudentScreen` con formulario completo
- [ ] Strings centralizados en `auth_strings.dart`
- [ ] Validadores del Sprint 1 utilizados
- [ ] Custom widgets del Sprint 0 utilizados
- [ ] Manejo de errores con `SelectableText.rich`
- [ ] Accesibilidad implementada (semanticsLabel)
- [ ] `TextEditingController` gestionados correctamente

---

### Fase 6: Pantallas Home y Navegación Principal

**Duración:** 4 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `lib/features/home/presentation/screens/teacher_home_screen.dart`
- `lib/features/home/presentation/screens/student_home_screen.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/shared/widgets/custom_drawer.dart`

#### TeacherHomeScreen (Estructura)

```dart
// lib/features/home/presentation/screens/teacher_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/shared/widgets/custom_app_bar.dart';
import 'package:playing_tracker/shared/widgets/custom_card.dart';
import 'package:playing_tracker/shared/widgets/custom_drawer.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de docente',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/teacher/profile'),
            tooltip: 'Perfil',
          ),
        ],
      ),
      drawer: const CustomDrawer(role: UserRole.teacher),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cards de acceso rápido
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _DashboardCard(
                      title: 'Mis clases',
                      icon: Icons.class_,
                      color: colorScheme.primary,
                      onTap: () {
                        // TODO: Navegar a clases (Sprint 3)
                      },
                    ),
                    _DashboardCard(
                      title: 'Mis tareas',
                      icon: Icons.assignment,
                      color: colorScheme.secondary,
                      onTap: () {
                        // TODO: Navegar a tareas (Sprint 4)
                      },
                    ),
                    _DashboardCard(
                      title: 'Estadísticas',
                      icon: Icons.analytics,
                      color: colorScheme.tertiary,
                      onTap: () {
                        // TODO: Navegar a estadísticas (Sprint 5)
                      },
                    ),
                    _DashboardCard(
                      title: 'Alumnos',
                      icon: Icons.people,
                      color: colorScheme.error,
                      onTap: () {
                        // TODO: Navegar a alumnos (Sprint 3)
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Crear nueva clase (Sprint 3)
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva clase'),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

#### CustomDrawer con Logout

```dart
// lib/shared/widgets/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/core/enums/user_role.dart';

class CustomDrawer extends StatelessWidget {
  final UserRole role;

  const CustomDrawer({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  role == UserRole.teacher ? Icons.school : Icons.person,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  role == UserRole.teacher ? 'Panel de docente' : 'Panel de alumno',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              context.go(role == UserRole.teacher ? '/teacher/home' : '/student/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              context.push(role == UserRole.teacher ? '/teacher/profile' : '/student/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer primero
              context.read<AuthCubit>().logout();
              // GoRouter maneja la redirección automáticamente
            },
          ),
        ],
      ),
    );
  }
}
```

#### Checklist de Fase 6

- [ ] `TeacherHomeScreen` con cards de acceso rápido
- [ ] `StudentHomeScreen` con estructura similar
- [ ] `ProfileScreen` compartida entre roles
- [ ] `CustomDrawer` con navegación y logout
- [ ] Logout ejecuta `Navigator.pop()` antes de `context.read<AuthCubit>().logout()`
- [ ] FAB (FloatingActionButton) en TeacherHome para crear clase
- [ ] Navegación entre pantallas funcionando

---

### Fase 7: Testing y Validaciones

**Duración:** 3 horas
**Estado:** ⏳ Pendiente

#### Archivos a Crear

- `test/features/auth/presentation/cubit/auth_cubit_test.dart`
- `test/helpers/mock_hydrated_storage.dart`
- `test/helpers/mock_auth_repository.dart`

#### Setup de Testing con HydratedBloc

```dart
// test/helpers/mock_hydrated_storage.dart

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHydratedStorage extends Mock implements Storage {}

/// Configurar storage mock para tests
void setupHydratedStorage() {
  final storage = MockHydratedStorage();

  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  when(() => storage.delete(any())).thenAnswer((_) async {});
  when(() => storage.clear()).thenAnswer((_) async {});

  HydratedBloc.storage = storage;
}
```

#### Tests de AuthCubit

```dart
// test/features/auth/presentation/cubit/auth_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:playing_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:playing_tracker/core/enums/user_role.dart';
import '../../../helpers/mock_hydrated_storage.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    // Configurar HydratedBloc storage mock
    setupHydratedStorage();

    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit Login', () {
    test('debe emitir [Loading, Authenticated] cuando login es exitoso', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('test-user-id');
      when(() => mockUserCredential.user).thenReturn(mockUser);

      when(() => mockAuthRepository.signInWithEmail('test@test.com', 'password'))
          .thenAnswer((_) async => mockUserCredential);

      when(() => mockAuthRepository.getUserRole('test-user-id'))
          .thenAnswer((_) async => UserRole.teacher);

      // Act & Assert
      expectLater(
        authCubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.userId, 'userId', 'test-user-id')
              .having((state) => state.role, 'role', UserRole.teacher),
        ]),
      );

      await authCubit.loginWithEmail('test@test.com', 'password');
    });

    test('debe emitir [Loading, Error] cuando login falla', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithEmail(any(), any()))
          .thenThrow(Exception('Credenciales inválidas'));

      // Act & Assert
      expectLater(
        authCubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>()
              .having((state) => state.message, 'message', contains('Credenciales')),
        ]),
      );

      await authCubit.loginWithEmail('wrong@test.com', 'wrongpass');
    });
  });

  group('AuthCubit Logout', () {
    test('debe emitir [Unauthenticated] cuando logout es exitoso', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act & Assert
      expectLater(
        authCubit.stream,
        emits(isA<AuthUnauthenticated>()),
      );

      await authCubit.logout();
    });
  });

  group('AuthCubit Persistencia', () {
    test('toJson debe serializar solo campos necesarios', () {
      // Arrange
      final state = AuthAuthenticated(
        role: UserRole.teacher,
        userId: 'test-id',
      );

      // Act
      final json = authCubit.toJson(state);

      // Assert
      expect(json, isNotNull);
      expect(json!['type'], 'authenticated');
      expect(json['userId'], 'test-id');
      expect(json['roleIndex'], UserRole.teacher.index);
      // NO debe incluir tokens sensibles
      expect(json.containsKey('token'), false);
    });

    test('fromJson debe restaurar estado correctamente', () {
      // Arrange
      final json = {
        'type': 'authenticated',
        'userId': 'restored-id',
        'roleIndex': UserRole.student.index,
      };

      // Act
      final state = authCubit.fromJson(json);

      // Assert
      expect(state, isA<AuthAuthenticated>());
      final authState = state as AuthAuthenticated;
      expect(authState.userId, 'restored-id');
      expect(authState.role, UserRole.student);
    });
  });
}
```

#### Validaciones Finales

```bash
# Ejecutar todos los tests
flutter test

# Verificar cobertura (opcional)
flutter test --coverage

# Análisis de código
flutter analyze

# Formateo
dart format .

# Probar en dispositivo real
flutter run
```

#### Checklist de Fase 7

- [ ] `MockHydratedStorage` configurado para tests
- [ ] Tests de login exitoso/fallido
- [ ] Tests de registro Teacher/Student
- [ ] Tests de logout
- [ ] Tests de persistencia (toJson/fromJson)
- [ ] Tests de navegación con GoRouter
- [ ] `flutter analyze` sin errores (0 issues)
- [ ] `dart format .` ejecutado
- [ ] `flutter test` todos los tests pasan
- [ ] Flujo completo probado en dispositivo/emulador

---

### Fase 8: Documentación y Refinamiento

**Duración:** 2 horas
**Estado:** ⏳ Pendiente

#### Tareas de Documentación

1. **Actualizar `SPRINT_2_IMPLEMENTACION.md`**
   - Marcar todas las fases como completadas
   - Actualizar progreso a 100%
   - Agregar versión final con fecha

2. **Actualizar `README.md`**
   - Cambiar "Sprint Actual" a Sprint 2 completado
   - Agregar sección de Sprint 2 con logros

3. **Actualizar `docs/Guia_Proyecto_PlayingTracker.md`**
   - Marcar Sprint 2 como completado
   - Actualizar roadmap

4. **Crear `docs/examples/auth_flow_example.dart`**

```dart
// docs/examples/auth_flow_example.dart

/// Ejemplo de flujo completo de autenticación
///
/// Este ejemplo demuestra:
/// - Registro de usuario (Teacher y Student)
/// - Login con credenciales
/// - Persistencia de sesión con hydrated_bloc
/// - Navegación condicional con GoRouter
/// - Logout

import 'package:flutter/material.dart';

void main() {
  // Ver implementación completa en:
  // - lib/features/auth/presentation/cubit/auth_cubit.dart
  // - lib/core/config/router/app_router.dart
  // - lib/features/auth/presentation/screens/login_screen.dart

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Configurar BlocProvider con AuthCubit
    // 2. Configurar GoRouter con AuthCubit.stream
    // 3. MaterialApp.router con routerConfig

    return const Placeholder(); // Ver main.dart real
  }
}

// Ejemplo de uso de AuthCubit:
void exampleLoginFlow(BuildContext context) async {
  final authCubit = context.read<AuthCubit>();

  // Login
  await authCubit.loginWithEmail('teacher@test.com', 'password');

  // El estado cambiará a AuthAuthenticated
  // GoRouter redirigirá automáticamente a /teacher/home
}

// Ejemplo de registro:
void exampleRegisterFlow(BuildContext context) async {
  final authCubit = context.read<AuthCubit>();

  // Registro de Teacher
  await authCubit.registerTeacher(
    'newteacher@test.com',
    'securepassword',
    'Nombre Completo',
  );

  // Se crea el documento en Firestore collection 'teachers'
  // El estado cambia a AuthAuthenticated con role: UserRole.teacher
}

// Ejemplo de persistencia:
// Al cerrar y reabrir la app:
// 1. HydratedBloc restaura el último AuthState desde disco
// 2. Si era AuthAuthenticated, el usuario permanece logueado
// 3. GoRouter verifica el estado y redirige a la pantalla correcta
```

#### Checklist Final del Sprint

- [ ] Todas las dependencias instaladas (`flutter pub get`)
- [ ] AuthCubit implementado con HydratedBloc
- [ ] Repositorios de Firebase Auth y Firestore funcionando
- [ ] GoRouter configurado con guards y navegación reactiva
- [ ] hydrated_bloc persistiendo sesión entre reinicios
- [ ] UI de login/registro completamente funcional
- [ ] Navegación separada para Teacher y Student
- [ ] Custom widgets del Sprint 0 utilizados consistentemente
- [ ] Validadores del Sprint 1 integrados
- [ ] Tests unitarios pasando (`flutter test`)
- [ ] Código analizado sin errores (`flutter analyze`)
- [ ] Código formateado (`dart format .`)
- [ ] Documentación actualizada (README, Guía del Proyecto, Sprint doc)
- [ ] Ejemplo de uso creado en `docs/examples/`
- [ ] **Prueba en dispositivo real:** Login, registro, persistencia, y logout funcionando

---

## ✅ Criterios de Aceptación

**Funcionalidad:**
1. ✅ El usuario puede registrarse como Teacher o Student
2. ✅ El usuario puede iniciar sesión con email y password
3. ✅ La sesión persiste entre reinicios de la app
4. ✅ La navegación es condicional según el rol del usuario
5. ✅ Los teachers ven TeacherHomeScreen
6. ✅ Los students ven StudentHomeScreen
7. ✅ El logout funciona correctamente
8. ✅ Los datos de sesión no se pierden tras cerrar y reabrir la app en todas las plataformas (incluyendo macOS y Windows)

**Código:**
9. ✅ Todos los formularios usan validadores del Sprint 1
10. ✅ Toda la UI usa custom widgets del Sprint 0
11. ✅ El código pasa `flutter analyze` sin errores
12. ✅ Los tests unitarios cubren AuthCubit con >= 80% cobertura

---

## 📚 Notas Técnicas

### Ventajas de hydrated_bloc

- **Persistencia automática** del AuthState sin código manual
- **No requiere SharedPreferences** manual
- **Serialización/deserialización** integrada con `toJson`/`fromJson`
- **Restauración automática** al abrir la app
- **⚠️ Seguridad:** hydrated_bloc usa JSON en disco (no encriptado), por tanto el AuthState **NO debe almacenar tokens ni contraseñas**, solo `userId` y `role`.

### Ventajas de GoRouter

- **Navegación declarativa** con rutas tipadas
- **Guards integrados** mediante función `redirect`
- **Deep linking** nativo sin configuración extra
- **Navegación reactiva** con `refreshListenable: GoRouterRefreshStream`
- **Mejor control del stack** comparado con Navigator 1.0
- **Opcional:** Considerar `go_router_builder` para generar rutas tipadas si el proyecto escala

### GoRouterRefreshStream

Implementar `refreshListenable: GoRouterRefreshStream(authCubit.stream)` permite que GoRouter **reevalúe automáticamente** la lógica de `redirect` cada vez que cambia el `AuthState`, sin necesidad de reiniciar la app. Esto proporciona una UX fluida y reactiva.

### Por qué NO usar firebase_ui_auth

- **No se alinea** con custom widgets del Sprint 0
- **Menor control** sobre flujos Teacher/Student diferenciados
- **Estilos predefinidos** rompen consistencia visual con Material Design 3 personalizado
- **Mayor flexibilidad** con implementación manual para requisitos específicos del proyecto

### Seguridad y Datos Sensibles

**⚠️ IMPORTANTE:**
- Las **API keys de Firebase** son públicas por diseño (ver Sprint 1)
- La seguridad se garantiza mediante:
  - Reglas de Firestore (implementadas en Sprint 1)
  - Firebase Auth configuration
  - Dominios autorizados en Firebase Console
- **NO almacenar** tokens de autenticación ni contraseñas en HydratedBloc
- **Solo persistir** `userId` y `role` en AuthState

---

## 📅 Historial de Cambios

### Versión 1.0 - 13 de Noviembre 2025

- ✅ Documento inicial creado
- ✅ Estructura de 8 fases definida detalladamente
- ✅ Stack tecnológico seleccionado: GoRouter + hydrated_bloc + firebase_auth
- ✅ Decisión arquitectónica: NO usar firebase_ui_auth
- ✅ Mejoras técnicas incorporadas:
  - Inicialización correcta de HydratedBloc después de Firebase
  - GoRouterRefreshStream para navegación reactiva
  - Mock de HydratedStorage para testing
  - Seguridad: solo persistir userId y role, no tokens
  - Referencias completas a firebase_core y cloud_firestore
  - Helper `getUserRole()` en repositorio
  - Notas de accesibilidad (semanticsLabel)
  - Gestión correcta de TextEditingController
  - Drawer con logout que cierra drawer primero
  - Criterio de aceptación adicional (persistencia multiplataforma)

---

**Próximo Sprint:** Sprint 3 - Sistema de Clases y Membresías

---

**Documento generado el 13 de Noviembre 2025**
**Playing Tracker - Sprint 2**

