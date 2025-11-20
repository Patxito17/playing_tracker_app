# SPRINT 2: Autenticación y Gestión de Usuarios

> **Documento técnico de planificación y ejecución del Sprint 2 del proyecto Playing Tracker, centrado en la implementación del sistema de autenticación, roles y persistencia de sesión.**

---

## 📋 Información del Sprint

| Campo | Valor |
|-------|-------|
| **Proyecto** | Playing Tracker |
| **Sprint** | Sprint 2 |
| **Duración** | 2-3 semanas |
| **Estado** | En progreso (Fase 5 completada) |
| **Versión del documento** | 1.3 |
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
**Progreso:** 75% (6/8 fases completadas)

| Fase | Descripción | Estado | Duración |
|------|-------------|--------|----------|
| **Fase 1** | Configuración Inicial y Dependencias | ✅ Completada | 2 horas |
| **Fase 2** | AuthCubit y Estados de Autenticación | ✅ Completada | 4 horas |
| **Fase 3** | Repositorios de Autenticación y Firestore | ✅ Completada | 3 horas |
| **Fase 4** | GoRouter y Navegación Condicional | ✅ Completada | 4 horas |
| **Fase 5** | UI de Login y Registro | ✅ Completada | 5 horas |
| **Fase 6** | Pantallas Home y Navegación Principal | ✅ Completada | 4 horas |
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
**Estado:** ✅ Completada (20/nov/2025)

#### Cambios clave

- Creación de `lib/core/config/router/go_router_refresh_stream.dart` para notificar a GoRouter cuando cambie el `AuthCubit`.
- `AppRoutes` ahora es instanciable, recibe el `AuthCubit` y protege rutas según `AuthState` + `UserRole`.
- Se eliminó `AuthWrapper` (y el viejo `navigation_helper.dart`), por lo que la navegación depende únicamente del estado real persistido.

```dart
class AppRoutes {
  AppRoutes(this.authCubit);

  static const String splash = '/';
  static const String login = '/login';
  // ...

  late final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.uri.path;

      if (authState is AuthInitial || authState is AuthLoading) {
        return location == splash ? null : splash;
      }

      if (authState is AuthUnauthenticated) {
        return _publicRoutes.contains(location) ? null : login;
      }

      if (authState is AuthAuthenticated) {
        final home = authState.role == UserRole.teacher
            ? teacherHome
            : studentHome;

        if (location == splash || _publicRoutes.contains(location)) {
          return home;
        }

        if (location.startsWith('/home/teacher') &&
            authState.role != UserRole.teacher) {
          return studentHome;
        }

        if (location.startsWith('/home/student') &&
            authState.role != UserRole.student) {
          return teacherHome;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      // resto de rutas (login, register, shells teacher/student, etc.)
    ],
  );
}
```

`main.dart` ahora obtiene el cubit desde el `BlocProvider`, instancia `AppRoutes` y sólo expone `routerConfig: appRoutes.router`.

#### Checklist de Fase 4

- [x] `GoRouterRefreshStream` implementado para reactividad
- [x] GoRouter configurado con `refreshListenable`
- [x] Lógica de `redirect` completa con guards por rol
- [x] Rutas públicas y protegidas correctamente separadas
- [x] Navegación reactiva ante cambios de AuthState

---

### Fase 5: UI de Login, Registro y Recuperación

**Duración:** 5 horas
**Estado:** ✅ Completada

#### Archivos Actualizados

- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/register_screen.dart`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `lib/features/auth/presentation/cubit/forgot_password_cubit.dart`
- `lib/features/auth/presentation/cubit/forgot_password_state.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart` + `auth_repository_impl.dart`
- `lib/shared/widgets/custom_text_field.dart`
- `lib/config/routes/app_routes.dart`
- `lib/core/constants/app_strings.dart`

#### Resumen de Implementación

- **LoginScreen** ahora usa `AutofillGroup`, `CustomTextField` con hints nativos y `Semantics` para los errores persistentes. Las acciones secundarias (`¿olvidaste tu contraseña?`, `Regístrate`) se enlazan mediante `AppRoutes` para mantener una sola fuente de verdad de rutas.
- **RegisterScreen** incorpora autofill para nombres/apellidos, validación visual inmediata, `SegmentedButton` para rol docente/alumno y `Checkbox` adaptativo para los términos. Se añadió un mensaje accesible para los errores globales y navegación explícita a login via `context.go`.
- **ForgotPasswordScreen** dejó de usar mocks y ahora depende de un nuevo `ForgotPasswordCubit`, el cual orquesta el envío real del email mediante `AuthRepository.sendPasswordResetEmail`. La UI muestra estados `loading/success/error` persistentes usando `SelectableText.rich` y contenedores con contraste.
- **CustomTextField** soporta `autofillHints`, garantizando compatibilidad con Material 3 y mejores métricas de accesibilidad.
- **AuthRepository** expone `sendPasswordResetEmail`, implementado en `AuthRepositoryImpl` con mapeo centralizado de errores para mantener los mensajes en español.
- **GoRouter** crea el `ForgotPasswordCubit` en el builder de la ruta `forgotPassword`, asegurando que cada visita tenga su propio ciclo de vida y evitando inyecciones ad-hoc desde la UI.

```601:629:lib/features/auth/presentation/screens/login_screen.dart
                        if (errorMessage != null) ...[
                          Semantics(
                            label: AuthStrings.loginErrorSemanticLabel,
                            liveRegion: true,
                            child: SelectableText.rich(
                              TextSpan(
                                text: errorMessage,
                                style: context.bodyMediumOnSurface?.copyWith(
                                  color: context.colorScheme.error,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
```

```24:49:lib/features/auth/presentation/cubit/forgot_password_cubit.dart
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._authRepository)
      : super(const ForgotPasswordInitial());

  final AuthRepository _authRepository;

  Future<void> sendResetLink(String email) async {
    emit(const ForgotPasswordLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(ForgotPasswordSuccess(email));
    } catch (error) {
      emit(ForgotPasswordError(FirebaseErrorMapper.map(error)));
    }
  }
```

#### Checklist de Fase 5

- [x] `LoginScreen` con validaciones visuales, Semantics y navegación centralizada
- [x] `RegisterScreen` con selector de rol, autofill y aceptación de términos
- [x] `ForgotPasswordScreen` real con Cubit dedicado y feedback persistente
- [x] `AuthRepository` actualizado con `sendPasswordResetEmail`
- [x] `CustomTextField` actualizado con soporte de `autofillHints`
- [x] Strings de autenticación con etiquetas semánticas (`AuthStrings.*SemanticLabel`)
- [x] GoRouter creando el `ForgotPasswordCubit` por ruta protegida
- [x] Tests (`flutter test`) y análisis (`flutter analyze`) ejecutados sin errores

---

### Fase 6: Pantallas Home y Navegación Principal

**Duración:** 4 horas
**Estado:** ✅ Completada

#### Archivos actualizados

- `lib/features/home/presentation/screens/teacher_home_screen.dart`
- `lib/features/home/presentation/screens/student_home_screen.dart`
- `lib/features/home/presentation/widgets/home_quick_action_card.dart`
- `lib/features/home/presentation/widgets/home_sections.dart`
- `lib/core/constants/app_strings.dart` (`HomeStrings`)

#### Resumen de implementación

Creamos una experiencia de inicio real para cada rol, aprovechando GoRouter, AuthCubit y Material 3:

```39:70:lib/features/home/presentation/screens/teacher_home_screen.dart
return Scaffold(
  appBar: CustomAppBar(
    title: HomeStrings.teacherHomeTitle,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        tooltip: SettingsStrings.logout,
        icon: const Icon(Icons.logout_rounded),
        onPressed: () => context.read<AuthCubit>().logout(),
      ),
    ],
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeroCard(...),
          const SizedBox(height: AppSpacing.xl),
          HomeQuickActionsSection(...),
          const SizedBox(height: AppSpacing.xl),
          const HomeHighlightsCard(...),
        ],
      ),
    ),
  ),
);
```

- **TeacherHomeScreen** expone un hero card con CTA hacia las clases, un bloque de acciones rápidas (Crear clase, ir a estadísticas, etc.) y un recordatorio visual que servirá para futuras alertas.
- **StudentHomeScreen** reutiliza los mismos widgets para mostrar acciones orientadas al alumno (unirse a clase, revisar tareas, continuar práctica). Ambos flujos ahora funcionan sin redirecciones silenciosas y respetan el estado actual del router.
- Se introdujeron componentes reutilizables (`HomeHeroCard`, `HomeQuickActionsSection`, `HomeHighlightsCard`, `HomeQuickActionCard`) para facilitar la expansión futura y reducir duplicación.
- `HomeStrings` centraliza todos los textos visibles siguiendo las reglas de capitalización del proyecto.

#### Checklist de Fase 6

- [x] `TeacherHomeScreen` con hero, acciones rápidas y cierre de sesión vía AuthCubit
- [x] `StudentHomeScreen` equivalente con navegación declarativa y acciones específicas
- [x] Componentes reutilizables (`HomeHeroCard`, `HomeQuickActionsSection`, `HomeHighlightsCard`, `HomeQuickActionCard`)
- [x] Strings centralizados (`HomeStrings`) y uso de `CustomAppBar`
- [x] Navegación con GoRouter (`context.go`/`context.push`) conectada al router principal
- [x] QA completo (`dart format`, `flutter analyze`, `flutter test`) sin errores

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

