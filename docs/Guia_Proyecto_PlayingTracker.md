# 🧭 Guía de Desarrollo del Proyecto "Playing Tracker"

**Última actualización:** 24 de Noviembre 2025
**Estado del proyecto:** Sprint 3 - Sistema de Clases y Membresías (Fase 7 completada) 🚧

---

## 📘 Descripción General

**Playing Tracker** es una aplicación móvil multiplataforma (Flutter + Firebase) orientada al ámbito educativo musical. Su objetivo es **digitalizar y objetivar el seguimiento del estudio instrumental** fuera del aula, permitiendo a los docentes asignar tareas específicas y a los alumnos registrar el tiempo dedicado a cada una de ellas.

### 🎯 Enfoque de Desarrollo
- 🎨 **Diseño primero:** Implementación de UI/UX completa antes de la lógica
- 🏗️ **Arquitectura escalable:** Base de datos NoSQL optimizada con 6 colecciones top-level
- 🔄 **Desarrollo iterativo:** Sprints enfocados en funcionalidades completas
- 📱 **Material Design 3:** Experiencia de usuario moderna y accesible
- 🔐 **Seguridad robusta:** Reglas de Firestore optimizadas para roles docente/alumno

---

## 🎯 Objetivos

### Objetivo General
Desarrollar una app móvil multiplataforma (iOS y Android) que permita **asignar tareas de estudio, medir el tiempo real de práctica y generar estadísticas de progreso**.

### Objetivos Específicos
1. Implementar autenticación con Firebase distinguiendo los roles de **Docente** y **Alumno**.
2. Crear interfaces intuitivas para **asignación de tareas (Docente)** y **ejecución/registro (Alumno)**.
3. Integrar un **cronómetro persistente** para registrar el tiempo de práctica incluso en segundo plano.
4. Guardar y procesar datos de práctica (tiempo, tarea, fecha) en **Firestore**.
5. Generar **estadísticas visuales** (diarias, semanales, mensuales y anuales) accesibles desde la app.

---

## 🧩 Arquitectura del Proyecto

### Lenguaje y Framework
- **Frontend:** Flutter 3.38.x (Dart 3.10.x) ✅
  Migración de `environment.sdk` a ^3.10.x documentada en Sprint 2 y validada nuevamente al incorporar `fake_cloud_firestore` para las pruebas de servicios en Sprint 3.
- **Backend:** Firebase ✅
  - Firebase Authentication ✅ (Email/Password)
  - Cloud Firestore ✅ (Base de datos NoSQL)
  - Firebase Storage 📅 (Próximamente)
  - Cloud Functions 📅 (Próximamente)
- **Control de versiones:** Git/GitHub ✅
- **Diseño UI:** Material Design 3 ✅
- **Herramientas:** DevTools, Flutter Widget Inspector ✅
- **Testing helpers:** fake_cloud_firestore + mocktail para aislar servicios (Sprint 3)

### Gestión de Estado
- **flutter_bloc** ✅ Dependencia configurada (Sprint 0) y usada en wrappers de UI.
- **Cubit** 🚧 Sistema principal definido en flutter_style_rules; AuthCubit inicia en Sprint 2.
- **ForgotPasswordCubit** ✅ Añadido en Sprint 2 (Fase 5) para manejar recuperación de contraseña desacoplada del flujo principal.
- **Equatable** ✅ Disponible para estados/entidades desde Sprint 1.
- **BlocProvider** ✅ Configurado en ejemplos y listo para inyección en Sprint 2.
- **AppBlocObserver** ✅ (Sprint 3 Fase 4) definido en `core/config/bloc/app_bloc_observer.dart`, registra métricas globales (`BlocMetricsRecorder`) y se inicializa en `main.dart` antes de correr la app.
- **BlocBuilder/BlocConsumer** ✅ Utilizados en pantallas de autenticación (Sprint 0) como base.

### Diseño y Tema (Material Design 3)
La aplicación implementa **Material Design 3** completamente:
- ✅ `ThemeData` con `useMaterial3: true`
- ✅ Paleta de colores generada con `ColorScheme.fromSeed(seedColor: Color(0xFF1E88E5))`
- ✅ Componentes modernos: `FilledButton`, `OutlinedButton`, `TextField` con bordes redondeados
- ✅ Tokens de diseño accesibles mediante `Theme.of(context).colorScheme`
- ✅ Elevación mediante `surfaceTintColor`
- ✅ Tipografía y espaciado según especificaciones M3
- ✅ Tema claro y oscuro con `Brightness.light` y `Brightness.dark`
- ✅ Extension methods para acceso rápido: `context.theme`, `context.colorScheme`

### Estructura lógica de la app (Feature-First Architecture)

```
lib/
├── core/                              # Código compartido 📅
│   ├── constants/                     # 📅 Por implementar
│   │   ├── app_constants.dart        # Constantes globales (espaciado, colores)
│   │   └── app_strings.dart          # Strings organizados por categorías
│   ├── extensions/                    # 📅 Por implementar
│   │   └── context_extensions.dart   # Extensions para BuildContext
│   └── utils/                         # Helpers compartidos activos
│       ├── validators.dart           # Validadores de formularios
│       ├── firebase_error_mapper.dart # Mapeo de errores Firebase a español
│       └── access_code_generator.dart # Generador centralizado de códigos (Sprint 3)
│
├── config/                            # Configuración de la app 📅
│   ├── theme/                        # 📅 Por implementar
│   │   └── app_theme.dart           # ThemeData Material Design 3
│   └── routes/                       # 📅 Por implementar
│       └── app_routes.dart          # Navegación y rutas
│
├── features/                          # Features por funcionalidad
│   ├── auth/                         # 📅 Autenticación (Sprint 2)
│   │   ├── domain/                  # 📅 Por implementar
│   │   │   ├── enums/
│   │   │   │   └── user_role.dart  # Enum: docente | alumno
│   │   │   └── models/
│   │   │       ├── teacher_model.dart # Modelo de docente
│   │   │       └── student_model.dart # Modelo de alumno
│   │   ├── data/                    # 📅 Por implementar
│   │   │   ├── services/
│   │   │   │   ├── auth_service.dart       # Firebase Authentication
│   │   │   │   └── firestore_service.dart  # CRUD usuarios Firestore
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart    # Orquestación de services
│   │   └── presentation/            # 📅 Por implementar
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart         # Cubit de autenticación
│   │       │   └── auth_state.dart         # Estados de autenticación
│   │       ├── screens/
│   │       │   ├── login_screen.dart       # Pantalla de login
│   │       │   └── register_screen.dart    # Pantalla de registro
│   │       └── widgets/
│   │           └── auth_wrapper.dart       # Navegación condicional
│   │
│   ├── home/                         # 📅 Pantallas Home (Sprint 0)
│   │   └── presentation/            # 📅 Por implementar
│   │       └── screens/
│   │           ├── teacher_home_screen.dart  # Redirige a teacher_classes_list_screen
│   │           └── student_home_screen.dart  # Redirige a student_classes_list_screen
│   │
│   ├── classes/                      # Gestión de clases (Sprint 0 - UI, Sprint 3 - Lógica)
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── class_model.dart # Modelo de clase
│   │   │   │   └── membership_model.dart # Modelo de membresía
│   │   │   └── enums/
│   │   │       └── class_status.dart # Estados de clase
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   ├── class_service.dart     # CRUD + generación de códigos (Sprint 3)
│   │   │   │   └── membership_service.dart # Relación N:M (Sprint 3)
│   │   │   ├── helpers/
│   │   │   │   └── fan_out_helper.dart    # Hook preparado para assignments (Sprint 3 Fase 4)
│   │   │   └── repositories/
│   │   │       ├── class_repository.dart      # Contrato dominio
│   │   │       └── class_repository_impl.dart # Implementación + mapping (Sprint 3 Fase 4)
│   │   └── presentation/            # Sprint 3 - Cubits conectados a Firestore
│   │       ├── cubit/
│   │       │   ├── class_cubit.dart       # Cubit docente (streams + refresh)
│   │       │   ├── class_state.dart       # Estados sealed (initial/loading/empty/success/error)
│   │       │   ├── membership_cubit.dart  # Operaciones N:M (join/invite/remove/code)
│   │       │   └── membership_state.dart  # Estados sealed para feedback inmediato
│   │       └── screens/
│   │           ├── create_class_screen.dart # Crear clase
│   │           ├── join_class_screen.dart # Unirse a clase
│   │           └── manage_students_screen.dart # Gestionar alumnos
│   │
│   ├── tasks/                        # 📅 Gestión de tareas (Sprint 4)
│   │   ├── domain/                  # 📅 Por implementar
│   │   │   ├── models/
│   │   │   │   ├── task_model.dart # Modelo de tarea
│   │   │   │   └── assignment_model.dart # Modelo de asignación
│   │   │   └── enums/
│   │   │       └── task_status.dart # Estados de tarea
│   │   ├── data/                    # 📅 Por implementar
│   │   │   ├── services/
│   │   │   │   └── task_service.dart # CRUD de tareas
│   │   │   └── repositories/
│   │   │       └── task_repository.dart # Orquestación
│   │   └── presentation/            # 📅 Por implementar
│   │       ├── cubit/
│   │       │   ├── task_cubit.dart # Cubit de tareas
│   │       │   └── task_state.dart # Estados de tareas
│   │       └── screens/
│   │           ├── create_task_screen.dart # Crear tarea
│   │           ├── task_list_screen.dart # Lista de tareas
│   │           └── task_detail_screen.dart # Detalle de tarea
│   │
│   ├── sessions/                     # 📅 Cronómetro (Sprint 5)
│   │   ├── domain/                  # 📅 Por implementar
│   │   │   ├── models/
│   │   │   │   └── session_model.dart # Modelo de sesión
│   │   │   └── enums/
│   │   │       └── session_status.dart # Estados de sesión
│   │   ├── data/                    # 📅 Por implementar
│   │   │   ├── services/
│   │   │   │   └── session_service.dart # CRUD de sesiones
│   │   │   └── repositories/
│   │   │       └── session_repository.dart # Orquestación
│   │   └── presentation/            # 📅 Por implementar
│   │       ├── cubit/
│   │       │   ├── session_cubit.dart # Cubit de sesiones
│   │       │   └── session_state.dart # Estados de sesiones
│   │       └── screens/
│   │           ├── timer_screen.dart # Pantalla de cronómetro
│   │           └── session_history_screen.dart # Historial de sesiones
│   │
│   ├── statistics/                   # 📅 Estadísticas (Sprint 0 - UI, Sprint 6 - Lógica)
│   │   ├── domain/                  # 📅 Por implementar
│   │   │   └── models/
│   │   │       └── statistics_model.dart # Modelo de estadísticas
│   │   ├── data/                    # 📅 Por implementar
│   │   │   ├── services/
│   │   │   │   └── statistics_service.dart # Cálculo de estadísticas
│   │   │   └── repositories/
│   │   │       └── statistics_repository.dart # Orquestación
│   │   └── presentation/            # 📅 Sprint 0 - UI placeholder
│   │       ├── cubit/
│   │       │   ├── statistics_cubit.dart # Cubit de estadísticas
│   │       │   └── statistics_state.dart # Estados de estadísticas
│   │       └── screens/
│   │           └── statistics_screen.dart # Estadísticas generales (reutilizable según contexto)
│   │
│   └── settings/                     # 📅 Configuración (Sprint 0 - Placeholder)
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart # Pantalla de configuración (placeholder)
│
├── shared/                            # Widgets compartidos 📅
│   └── widgets/                      # 📅 Sprint 0 - Componentes base
│       ├── custom_button.dart       # Botones reutilizables
│       ├── custom_text_field.dart   # TextField personalizado
│       ├── loading_overlay.dart     # Overlay de carga
│       ├── custom_card.dart         # Cards reutilizables
│       ├── custom_app_bar.dart      # AppBar personalizado
│       ├── custom_bottom_navigation_bar.dart # BottomNavigationBar M3
│       ├── custom_tab_bar.dart      # TabBar personalizado
│       └── (otros helpers menores)
│
└── main.dart                          # 📅 Entry point con Firebase init
```

> **Nota:** Los módulos `core/*`, `config/*` y las pantallas base de `features/auth`, `features/classes`, `features/tasks`, `features/sessions` y `shared/widgets` se completaron durante los Sprints 0 y 1 siguiendo las `flutter_style_rules`. Los marcadores 📅 del diagrama indican lógica pendiente (por ejemplo, repositorios o Cubits definitivos) que se abordará en los Sprints 2+.

---

## 🧱 Funcionalidades Principales

### 📌 Sprint 3 · Fase 3 (21/11/2025)

- Implementado `AccessCodeGenerator` con validaciones alfanuméricas para códigos de 6 caracteres.
- Nuevos servicios `ClassService` y `MembershipService` (Firestore + transacciones) listos para ser consumidos por los Cubits de la Fase 4.
- Reglas de Firestore actualizadas para permitir que alumnos creen/reactiven membresías mediante códigos y para exigir `updatedAt` en `memberships`.
- Índices compuestos extendidos (`classes.ownerTeacherId+createdAt`, `memberships.classId+isActive+joinedAt`) asegurando streams paginados en 400 ms.
- Suite de pruebas dedicada (`test/features/classes/data/services`) usando `fake_cloud_firestore` y `mocktail`.
- Documentación y roadmap sincronizados con el alcance real del Sprint 3.

### 📌 Sprint 3 · Fase 4 (24/11/2025)

- `ClassRepositoryImpl` implementado con contratos desacoplados (`ClassService`, `MembershipService`, `FanOutHelper`) y manejo exhaustivo de excepciones (`InvalidAccessCodeException`, `MembershipNotFoundException`, etc.).
- `ClassCubit` y `MembershipCubit` consumen el repositorio, exponen estados sealed (`ClassActionSuccess`, `MembershipSuccess`) y soportan refrescos manuales (`_manualRefreshPending`).
- `fan_out_helper.dart` documentado como stub para Sprint 4; `ClassRepositoryImpl.fanOutTask` delega en el helper + hook del servicio.
- Pruebas unitarias (`test/features/classes/data/repositories/...`, `test/features/classes/presentation/cubit/...`) usando `bloc_test` + `mocktail`.
- QA completo: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.

### 📌 Sprint 3 · Fase 5 (24/11/2025)

- `TeacherClassesListScreen` conectado al `ClassCubit` real (estados loading/empty/error/success), `_EmptyState` reutilizable, chips de estado y errores con `SelectableText.rich`.
- `CreateClassScreen` integra `CustomTextField`, `CreateClassInput`, validaciones de dominio y navegación segura (`Navigator.canPop()`) tras emitir `ClassActionSuccess`.
- Strings operativos agregados en `app_strings.dart` (mensajes de clases/membresías, etiquetas de estado, textos de retry) y reutilizados en la UI.
- Nuevos widget tests (`test/features/classes/presentation/screens/*.dart`) montan GoRouter embebido para validar navegación, formularios y estados.
- QA completo: `dart format .`, `flutter analyze`, `flutter test`.

### 👩‍🏫 Módulo Docente

**✅ Implementado (Sprint 2):**
- ✅ Registro y autenticación con Firebase
- ✅ Login con email y contraseña
- ✅ Recuperación de contraseña
- ✅ Home docente con hero card, acciones rápidas y CTA hacia clases
- ✅ Navegación declarativa GoRouter (guardada por rol)
- ✅ Visualización de datos de perfil (nombre completo)
- ✅ Logout seguro

**📅 Sprint 0 - UI Placeholder:**
- ✅ Lista de clases creadas (`TeacherClassesListScreen`) con BottomNavigationBar
- ✅ Detalle de clase con 3 tabs: Tareas, Estudiantes, Estadísticas de clase
- ✅ Estadísticas generales (todos los alumnos)
- ✅ Pantalla de configuración (placeholder)

**📅 Próximamente (Sprint 3+):**
- 📅 Creación de tareas con:
  - Título, descripción, tiempo sugerido
  - Archivo adjunto (PDF/audio opcional)
- 📅 Asignación a uno o varios alumnos
- 📅 Visualización de:
  - Tiempo total de estudio por alumno
  - Estadísticas filtradas por tarea o fecha
- 📅 Dashboard con resumen de actividad

### 👨‍🎓 Módulo Alumno

**✅ Implementado (Sprint 2):**
- ✅ Registro y autenticación con Firebase
- ✅ Login con email y contraseña
- ✅ Recuperación de contraseña
- ✅ Home alumno con acciones rápidas (unirse a clase, ver tareas, continuar práctica)
- ✅ Navegación a pantalla home específica de alumno
- ✅ Visualización de datos de perfil (nombre completo)
- ✅ Logout seguro

**📅 Sprint 0 - UI Placeholder:**
- ✅ Lista de clases a las que pertenece (`StudentClassesListScreen`) con BottomNavigationBar
- ✅ Detalle de clase con 3 tabs: Tareas (clickeables para iniciar sesión), Información de clase, Estadísticas de clase
- ✅ Estadísticas generales (todas las clases del estudiante)
- ✅ Pantalla de configuración (placeholder)

**📅 Próximamente (Sprint 3+):**
- 📅 Visualización de tareas asignadas
- 📅 Inicio de estudio mediante **cronómetro**
- 📅 Posibilidad de **pausar, reiniciar o finalizar** sesión
- 📅 Registro automático de tiempo (guardado en Firestore)
- 📅 Visualización de historial y progreso personal
- 📅 Estadísticas de tiempo de estudio

### 🔐 Módulo de Autenticación (Común)

**✅ Completamente Implementado:**
- ✅ Registro con firstName, lastName, email, password y rol
- ✅ Validaciones en español:
  - Email válido
  - Nombre y apellidos (mínimo 3 caracteres, solo letras y espacios)
  - Contraseña (mínimo 6 caracteres)
  - Confirmación de contraseña
  - Aceptación de términos
- ✅ Login con email y contraseña
- ✅ Recuperación de contraseña (envío de email)
- ✅ Persistencia de sesión automática
- ✅ Manejo de errores de Firebase en español
- ✅ Estados de carga y feedback visual
- ✅ Navegación condicional según rol (docente/alumno)
- ✅ Suite de pruebas unitarias/widget que cubre AuthCubit y las redirecciones del router

#### Estado actual de pruebas

- `test/features/auth/presentation/cubit/auth_cubit_test.dart` abarca login, registro (teacher/student), logout, manejo de errores y persistencia `toJson/fromJson` usando `mocktail` + `HydratedBloc`.
- `test/features/home/presentation/router_navigation_test.dart` monta un `GoRouter` real con un `AuthCubit` controlado para validar las redirecciones hacia login/home y los guards por rol.
- `test/widget_test.dart` mantiene un smoke test completo del `PlayingTrackerApp`, inyectando un repositorio mock para evitar dependencias externas.

---

## 📊 Base de Datos (Firestore) - Arquitectura Optimizada

### 🏗️ Modelo de Colecciones Top-Level (6 Colecciones)

Adoptamos una **arquitectura de colecciones desanidadas de primer nivel** que modela relaciones N:M mediante documentos intermedios, optimizada para **rendimiento en lectura** y **escalabilidad anti-hotspot**.

| Colección | Propósito | Justificación |
|-----------|-----------|---------------|
| 👨‍🏫 `teachers` | Perfiles de docentes | Colección top-level con UID como ID |
| 👨‍🎓 `students` | Perfiles de alumnos con agregados | Incluye contadores denormalizados para métricas |
| 📚 `classes` | Definiciones de clases/grupos | IDs globales únicos para consultas eficientes |
| 🔗 `memberships` | Relación Alumno ↔ Clase (N:M) | Evita arrays grandes y hotspots |
| 🎯 `tasks` | Definición maestra de tareas | Top-level para reutilización entre clases |
| ✍️ `assignments` | Progreso individual tarea-alumno | Estado 1:1 con clave compuesta `${taskId}_${studentId}` |
| ⏱️ `sessions` | Registros atómicos de estudio | Top-level para collection group queries |

---

### 📋 Estructura Detallada de Colecciones

#### 1. `teachers` - Perfiles de Docentes
```javascript
teachers/{teacherId}
{
  id: string,                    // UID de Firebase Auth
  firstName: string,             // Nombre (mín 3 caracteres)
  lastName: string,              // Apellidos (mín 3 caracteres)
  email: string,                 // Email único
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean              // Estado de la cuenta
}
```

#### 2. `students` - Perfiles de Alumnos (Con Agregados)
```javascript
students/{studentId}
{
  id: string,                    // UID de Firebase Auth
  firstName: string,             // Nombre (mín 3 caracteres)
  lastName: string,              // Apellidos (mín 3 caracteres)
  email: string,                 // Email único
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean,             // Estado de la cuenta

  // Agregados denormalizados para rendimiento
  totalSessionsCount: number,    // Total de sesiones completadas
  totalDurationLogged: number,   // Segundos totales de estudio
  lastSessionDate: Timestamp    // Fecha de la última sesión
}
```

#### 3. `classes` - Definiciones de Clases
```javascript
classes/{classId}
{
  id: string,                    // ID único global
  name: string,                  // Nombre de la clase
  description: string,           // Descripción opcional
  ownerTeacherId: string,        // ID del docente propietario
  accessCode: string,            // Código de acceso (6 caracteres)
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean              // Estado de la clase
}
```

#### 4. `memberships` - Relación Alumno ↔ Clase
```javascript
memberships/{membershipId}
{
  id: string,                    // ID único del membership
  classId: string,              // ID de la clase
  studentId: string,             // ID del alumno
  teacherId: string,             // ID del docente (denormalizado)
  className: string,             // Nombre de la clase (denormalizado)
  joinedAt: Timestamp,          // Fecha de unión
  updatedAt: Timestamp,         // Última modificación (re-activaciones)
  isActive: boolean              // Estado de la membresía
}
```

#### 5. `tasks` - Definición Maestra de Tareas
```javascript
tasks/{taskId}
{
  id: string,                    // ID único global
  title: string,                 // Título de la tarea
  description: string,           // Descripción detallada
  createdBy: string,            // ID del docente creador
  durationSuggested: number,     // Minutos sugeridos de estudio
  attachments: [                 // Archivos adjuntos (opcional)
    {
      name: string,
      url: string,
      type: string               // "pdf" | "audio" | "link"
    }
  ],
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  dueDate: Timestamp,            // Fecha límite (opcional)
  isActive: boolean              // Estado de la tarea
}
```

#### 6. `assignments` - Progreso Individual Tarea-Alumno
```javascript
assignments/{taskId_studentId}  // Clave compuesta para idempotencia
{
  id: string,                    // Clave compuesta: ${taskId}_${studentId}
  taskId: string,                // ID de la tarea
  studentId: string,             // ID del alumno
  teacherId: string,             // ID del docente (denormalizado)
  status: string,                // "pending" | "in_progress" | "completed"
  assignedAt: Timestamp,         // Fecha de asignación
  completedAt: Timestamp,         // Fecha de finalización (opcional)

  // Contadores de progreso
  sessionsCount: number,          // Número de sesiones realizadas
  totalDurationLogged: number,   // Segundos totales registrados
  lastSessionDate: Timestamp     // Fecha de la última sesión
}
```

#### 7. `sessions` - Registros Atómicos de Estudio
```javascript
sessions/{sessionId}
{
  id: string,                    // ID único de la sesión
  studentId: string,             // ID del alumno
  taskId: string,                // ID de la tarea
  teacherId: string,             // ID del docente (denormalizado)
  startTime: Timestamp,          // Hora de inicio
  endTime: Timestamp,            // Hora de finalización
  totalDuration: number,         // Segundos totales de estudio
  pausedDuration: number,        // Segundos en pausa
  dateLogged: Timestamp,         // Fecha de la sesión
  monthBucket: string,          // 2025-10 para queries de métricas
  notes: string,                 // Notas opcionales del alumno
  createdAt: Timestamp           // Fecha de creación del registro
}
```

---

### 🔄 Estrategia de Fan-out y Anti-Hotspot

#### Crear Tarea a una Clase (Fan-out)
1. **Crear** documento en `tasks/{taskId}`
2. **Leer** `memberships` por `classId`
3. **Batch Write** para crear documentos en `assignments/{taskId_studentId}`

#### Registrar Sesión (Alta Concurrencia)
1. **Crear** documento en `sessions/{sessionId}`
2. **Transaction Write** para actualizar:
   - Contadores en `assignments/{taskId_studentId}`
   - Agregados en `students/{studentId}`

---

### 🔐 Reglas de Seguridad Optimizadas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuth() { return request.auth != null; }
    function isOwner(doc) { return isAuth() && doc.ownerTeacherId == request.auth.uid; }

    // Perfiles de usuarios
    match /teachers/{teacherId} {
      allow read, write: if isAuth() && request.auth.uid == teacherId;
    }

    match /students/{studentId} {
      allow read, write: if isAuth() && request.auth.uid == studentId;
    }

    // Clases
    match /classes/{classId} {
      allow write: if isAuth() && resource.data.ownerTeacherId == request.auth.uid;
      allow read: if isAuth();
    }

    // Membresías
    match /memberships/{membershipId} {
      allow write: if isAuth() && request.resource.data.teacherId == request.auth.uid;
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
    }

    // Tareas
    match /tasks/{taskId} {
      allow write: if isAuth() && resource.data.createdBy == request.auth.uid;
      allow read: if isAuth();
    }

    // Asignaciones
    match /assignments/{assignmentId} {
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
      allow write: if isAuth() && (resource.data.teacherId == request.auth.uid
                                  || request.resource.data.studentId == request.auth.uid);
    }

    // Sesiones
    match /sessions/{sessionId} {
      allow create: if isAuth() && request.resource.data.studentId == request.auth.uid;
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
      allow update, delete: if false; // Inmutabilidad de métricas
    }
  }
}
```

---

**📄 Documentación completa:** Ver [FIRESTORE_SCHEMA.md](docs/FIRESTORE_SCHEMA.md) para detalles de implementación, índices y reglas de seguridad.

---

## 🔁 Metodología de Trabajo (Scrum Adaptado)

### ✅ Sprint 0: Configuración Inicial y Diseño UI/UX
**Duración:** Octubre 2025
**Estado:** ✅ Finalizado (entregables aprobados)

📄 **Documentación detallada:** [SPRINT_0_IMPLEMENTACION.md](sprints/SPRINT_0_IMPLEMENTACION.md)

**Objetivos:**
- 🎨 **Diseño completo de la aplicación** con Material Design 3
- 🏗️ **Configuración de arquitectura** y estructura de carpetas
- 📱 **Prototipado de todas las pantallas** (sin lógica de negocio)
- 🎯 **Definición de componentes reutilizables**
- 🔧 **Setup de herramientas de desarrollo**

**Entregables:**
- 📱 Pantallas de autenticación (Login, Registro, Recuperación)
- 📱 Pantallas de docente:
  - Lista de clases creadas (con BottomNavigationBar)
  - Detalle de clase con tabs (Tareas, Estudiantes, Estadísticas de clase)
  - Estadísticas generales
  - Configuración (placeholder)
- 📱 Pantallas de alumno:
  - Lista de clases a las que pertenece (con BottomNavigationBar)
  - Detalle de clase con tabs (Tareas, Información de clase, Estadísticas de clase)
  - Estadísticas generales
  - Configuración (placeholder)
- 🧩 Componentes base (Botones, TextFields, Cards, Loading, BottomNavigationBar, TabBar)
- 🎨 Sistema de tema completo (claro/oscuro)
- 📐 Navegación y routing definidos con ShellRoute para BottomNavigationBar

---

### ✅ Sprint 1: Modelos de Dominio y Arquitectura de Datos
**Duración:** Noviembre 2025
**Estado:** ✅ Finalizado (13 de Noviembre 2025)

📄 **Documentación detallada:** [SPRINT_1_IMPLEMENTACION.md](sprints/SPRINT_1_IMPLEMENTACION.md)

**Objetivos:**
- 📊 **Implementación de 7 colecciones Firestore** con estructura optimizada
- 🏗️ **Modelos de dominio** (Teacher, Student, Class, Task, Assignment, Session)
- 🔐 **Reglas de seguridad** de Firestore implementadas
- 📈 **Índices compuestos** para consultas eficientes
- 🧪 **Validadores de datos** y enums de estado

**Entregables:**
- 📋 Esquema completo de base de datos
- 🏗️ Modelos Dart con serialización JSON
- 🔐 Reglas de seguridad de Firestore
- 📈 Índices optimizados para consultas
- 🧪 Validadores y enums de dominio

---

### 🚧 Sprint 2: Autenticación y Gestión de Usuarios
**Duración:** 2-3 semanas
**Estado:** 🚧 En progreso (Fase 1 completada, 12.5%)
**Documento:** [`SPRINT_2_IMPLEMENTACION.md`](sprints/SPRINT_2_IMPLEMENTACION.md)

**Objetivos:**
- 🔐 **Firebase Authentication** integrado (email/password)
- 👥 **Gestión de perfiles** diferenciados (Teacher/Student) en Firestore
- 🔄 **Gestión de estado** con Cubit + hydrated_bloc
- 🧭 **Navegación condicional** por rol con GoRouter
- 💾 **Persistencia de sesión** automática entre reinicios
- 🎨 **UI completa** usando custom widgets del Sprint 0
- ✅ **Validaciones** usando validadores del Sprint 1

**Stack Tecnológico:**
- `firebase_auth: ^6.1.2` - Autenticación
- `hydrated_bloc: ^10.1.1` - Persistencia automática de estado
- `go_router: ^17.0.0` - Navegación declarativa con guards reactivos
- `path_provider: ^2.1.5` - Storage multiplataforma

**Avances recientes (20 nov 2025):**
- ✅ Fase 2 completada con `AuthCubit` hidratado + tests unitarios.
- ✅ Fase 3 completada con `AuthRepositoryImpl` (Firebase Auth + Firestore) y helper `firebase_error_mapper.dart`.
- ✅ Fase 4 completada: `AppRoutes` ahora escucha `AuthCubit`, se creó `GoRouterRefreshStream` y se removieron mocks (`AuthWrapper`, `navigation_helper.dart`).
- 🧪 `flutter analyze` y `flutter test` integrados al flujo diario antes de continuar con la Fase 4.

**Entregables:**
- 🔐 Sistema de autenticación completo (login, registro Teacher/Student, logout)
- 👥 Perfiles de usuario en Firestore (collections `teachers` y `students`)
- 🔄 AuthCubit con HydratedBloc para persistencia
- 🧭 GoRouter con guards de autenticación y rol
- 📱 Pantallas: Splash, Login, Registro, TeacherHome, StudentHome, Profile
- 🧪 Tests unitarios de AuthCubit (>=80% cobertura)
- 📚 Documentación completa y ejemplos de uso

---

### 📅 Sprint 3: Sistema de Clases y Membresías
**Duración:** Diciembre 2025 (2 semanas)
**Estado:** 🚧 En progreso (Fases 1-7 completadas)

**Objetivos:**
- 📚 **Gestión de clases** (crear, editar, eliminar)
- 🔗 **Sistema de membresías** (unirse con código)
- 👥 **Gestión de alumnos** por clase
- 🔄 **Fan-out optimizado** para asignaciones
- 📱 **UI completa** de gestión de clases

**Entregables:**
- 📚 CRUD de clases con códigos de acceso
- 🔗 Sistema de membresías N:M
- 👥 Gestión de alumnos por clase (ManageStudentsScreen integrada a Cubits reales)
- 🔄 Lógica de fan-out para asignaciones (hooks y TODOs documentados)
- 📱 Pantallas de gestión de clases

**Avances recientes (24 nov 2025):**
- `MembershipService` y `ClassRepositoryImpl` exponen paginación segura (`MembershipPage`) con cursores y validaciones de argumentos.
- `MembershipCubit` separa estados para operaciones vs. listados, habilitando `loadMembers`, `refreshMembers`, confirmaciones M3 y reutilización en UI.
- `ManageStudentsScreen` consume la capa real (header con `ClassModel`, listados paginados, `SelectableText.rich` para errores y diálogos de confirmación para expulsar o regenerar códigos).
- Se añadieron tests widget (`manage_students_screen_test.dart`) y unitarios de servicios para cubrir paginación, junto a actualizaciones de documentación e índices.
- `TeacherClassesListScreen` navega directo a `ManageStudentsScreen` (sin tabs mock heredados) y los HomeScreens muestran únicamente acciones respaldadas por lógica real.
- `StudentClassesListScreen` incorpora `StudentClassesCubit`, escucha los memberships activos del alumno y ofrece pull-to-refresh + CTA para unirse usando códigos reales.

---

### 📅 Sprint 4: Gestión de Tareas y Asignaciones
**Duración:** Próximamente
**Estado:** 📅 Planificado

**Objetivos:**
- 🎯 **CRUD de tareas** con asignaciones masivas
- 📋 **Gestión de asignaciones** individuales
- 🔄 **Estados de progreso** (pending, in_progress, completed)
- 📱 **UI de gestión** para docentes y alumnos
- 🔍 **Filtros y búsquedas** avanzadas

**Entregables:**
- 🎯 Sistema completo de tareas
- 📋 Gestión de asignaciones con estados
- 🔄 Lógica de progreso y contadores
- 📱 Pantallas de gestión de tareas
- 🔍 Sistema de filtros y búsquedas

---

### 📅 Sprint 5: Cronómetro y Sesiones de Estudio
**Duración:** Próximamente
**Estado:** 📅 Planificado

**Objetivos:**
- ⏱️ **Cronómetro funcional** con controles completos
- 📊 **Registro de sesiones** en Firestore
- 🔄 **Actualización de contadores** en tiempo real
- 📱 **UI de cronómetro** con Material Design 3
- 📈 **Métricas básicas** de progreso

**Entregables:**
- ⏱️ Cronómetro con pausa, reinicio, finalización
- 📊 Sistema de sesiones con persistencia
- 🔄 Actualización automática de contadores
- 📱 Pantalla de cronómetro optimizada
- 📈 Métricas de tiempo de estudio

---

### 📅 Sprint 6: Estadísticas y Dashboards
**Duración:** Próximamente
**Estado:** 📅 Planificado

**Objetivos:**
- 📊 **Gráficos y visualizaciones** de progreso
- 📈 **Dashboards** para docentes y alumnos
- 🔍 **Filtros avanzados** por fecha, tarea, clase
- 📤 **Exportación de datos** (CSV, PDF)
- 📱 **UI de estadísticas** con Material Design 3

**Entregables:**
- 📊 Sistema de gráficos y visualizaciones
- 📈 Dashboards personalizados por rol
- 🔍 Filtros y consultas avanzadas
- 📤 Exportación de reportes
- 📱 Pantallas de estadísticas

---

### 📅 Sprint 7: Testing y Optimización
**Duración:** Próximamente
**Estado:** 📅 Planificado

**Objetivos:**
- 🧪 **Testing completo** (Unit, Widget, Integration)
- ⚡ **Optimización de rendimiento**
- 🔒 **Auditoría de seguridad**
- 📱 **Testing de accesibilidad**
- 🚀 **Preparación para producción**

**Entregables:**
- 🧪 Suite completa de tests
- ⚡ Optimizaciones de rendimiento
- 🔒 Auditoría de seguridad
- 📱 Testing de accesibilidad
- 🚀 App lista para producción

---

### 📊 Progreso General del Proyecto

```
Sprint 0: ████████████████████ 100% ✅ Diseño UI/UX (Completado)
Sprint 1: ████████████████████ 100% ✅ Modelos y Arquitectura
Sprint 2: ██████░░░░░░░░░░░░ 50% 🚧 Autenticación
Sprint 3: ███████████░░░░░░░ 70% 🚧 Clases y Membresías (Fase 7 lista)
Sprint 4: ░░░░░░░░░░░░░░░░░░░░ 0% 📅 Tareas y Asignaciones
Sprint 5: ░░░░░░░░░░░░░░░░░░░░ 0% 📅 Cronómetro y Sesiones
Sprint 6: ░░░░░░░░░░░░░░░░░░░░ 0% 📅 Estadísticas
Sprint 7: ░░░░░░░░░░░░░░░░░░░░ 0% 📅 Testing y Producción

Progreso Total: ████░░░░░░░░░░░░░░░ 33% (2 sprints terminados + Sprint 2 en curso + Sprint 3 Fase 7)
```

---

## 🧪 Pruebas y Validación

### 📅 Testing Planificado (Sprint 7)
- 📅 **Unit tests:** Cubits, Repositories, Services, Validators
- 📅 **Widget tests:** Screens, Widgets reutilizables
- 📅 **Integration tests:** Flujos completos E2E
- 📅 **Golden tests:** Validación visual de componentes
- 📅 **Testing de accesibilidad** (TalkBack, VoiceOver)
- 📅 **Testing de rendimiento** (tiempo de carga, memoria)
- 📅 **Testing con usuarios beta** (docentes y alumnos reales)

### 📅 Herramientas de Testing (Por Configurar)
- 📅 **flutter_test** - Framework de testing de Flutter
- 📅 **bloc_test** - Testing específico para Cubit
- 📅 **mocktail** - Mocking para dependencias
- 📅 **golden_toolkit** - Golden tests para UI
- 📅 **integration_test** - Testing de integración
- 📅 **flutter_driver** - Testing E2E (opcional)

### 📅 Estrategia de Testing
- 📅 **Testing manual** durante desarrollo
- 📅 **Testing automatizado** en CI/CD
- 📅 **Testing de accesibilidad** con herramientas nativas
- 📅 **Testing de rendimiento** con Flutter DevTools
- 📅 **Testing de usuarios** con docentes y alumnos reales

---

## 🔐 Consideraciones Legales y Éticas

### Cumplimiento Normativo (Por Implementar)
Cumplimiento del **RGPD (Reglamento General de Protección de Datos)** y **LOPDGDD** por manejo de datos de menores:

- 📅 **Consentimiento explícito** de padres/tutores para menores de edad
- 📅 **Autenticación segura** con Firebase Authentication
- 📅 **Cifrado de datos** en tránsito (HTTPS) y en reposo (Firestore)
- 📅 **Minimización de datos:** Solo se recogen datos necesarios
- 📅 **Derecho al olvido:** Posibilidad de eliminación de cuenta
- 📅 **Política de privacidad** transparente y accesible
- 📅 **Términos de servicio** claros y en español
- 📅 **Gestión de consentimientos** documentada

### Seguridad Planificada (Por Implementar)
- 📅 Reglas de seguridad de Firestore (solo acceso a datos propios)
- 📅 Validación de datos en cliente y servidor
- 📅 Autenticación obligatoria para todas las operaciones
- 📅 Rate limiting en Cloud Functions (próximamente)
- 📅 Backup automático de datos (próximamente)

---

## 💡 Escalabilidad y Roadmap Futuro

### Funcionalidades Avanzadas (Post-MVP)
- 🎮 **Gamificación:** Logros, recompensas, rachas de estudio
- 📄 **Integración con partituras** en PDF con anotaciones
- 🎵 **Módulo de grabación** de práctica con audio
- 📱 **Modo offline** con sincronización diferida
- 🔔 **Notificaciones push** para recordatorios de tareas
- 📊 **Exportación avanzada** de datos (CSV, PDF, Excel)
- 👥 **Sistema de grupos** y clases
- 💬 **Chat docente-alumno** integrado
- 🌍 **Internacionalización** (múltiples idiomas)
- 🎨 **Personalización** de temas y colores

### Escalabilidad Técnica
- ☁️ **Cloud Functions** para lógica del servidor
- 📈 **Analytics** con Firebase Analytics
- 🔍 **Search** avanzado con Algolia o Elasticsearch
- 🚀 **CI/CD** con GitHub Actions
- 📦 **App bundles** para reducir tamaño
- 🌐 **Versión web** con Flutter Web
- 💻 **Versión desktop** (Windows, macOS, Linux)

---

## 🛠️ Dependencias del Proyecto

### Dependencias Principales (Por Implementar)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1        # 📅 Core de Firebase
  firebase_auth: ^5.3.3        # 📅 Autenticación
  cloud_firestore: ^5.5.3      # 📅 Base de datos
  firebase_storage: ^12.3.2    # 📅 Almacenamiento de archivos

  # State Management
  flutter_bloc: ^8.1.6         # 📅 Gestión de estado con Cubit
  equatable: ^2.0.7            # 📅 Comparación de objetos

  # UI y Utilidades
  cupertino_icons: ^1.0.8      # 📅 Iconos iOS
  google_fonts: ^6.2.1         # 📅 Fuentes personalizadas
  cached_network_image: ^3.4.1 # 📅 Imágenes con cache
  intl: ^0.19.0                # 📅 Internacionalización

  # Navegación
  go_router: ^14.2.7           # 📅 Navegación declarativa

  # Utilidades
  uuid: ^4.4.2                 # 📅 Generación de IDs únicos
  path_provider: ^2.1.4       # 📅 Rutas del sistema
  shared_preferences: ^2.3.2   # 📅 Almacenamiento local

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0        # 📅 Linting
  build_runner: ^2.4.13        # 📅 Generación de código
  json_annotation: ^4.9.0      # 📅 Anotaciones JSON
  json_serializable: ^6.8.0    # 📅 Serialización JSON
  bloc_test: ^9.1.7            # 📅 Testing de Bloc
  mocktail: ^1.0.4             # 📅 Mocking para tests
```

### Configuración de Firebase (Por Implementar)

**Archivos de configuración necesarios:**
- `android/app/google-services.json` - Configuración Android
- `ios/Runner/GoogleService-Info.plist` - Configuración iOS
- `web/firebase-config.js` - Configuración Web (opcional)

**Reglas de Firestore (Por Implementar):**
- Reglas de seguridad optimizadas por rol
- Índices compuestos para consultas eficientes
- Estructura de 7 colecciones top-level

---

## 📚 Documentación del Proyecto

### Documentación Técnica
- ✅ [README.md](README.md) - Descripción general, setup y estado actualizado por sprint
- ✅ [Guia_Proyecto_PlayingTracker.md](Guia_Proyecto_PlayingTracker.md) - Este documento
- 📄 [docs/FIRESTORE_SCHEMA.md](docs/FIRESTORE_SCHEMA.md) - Esquema de base de datos (backlog Sprint 3)
- 📄 [docs/DEVTOOLS_SETUP.md](docs/DEVTOOLS_SETUP.md) - Configuración de herramientas (pendiente)

### Documentación de Sprints
- ✅ [docs/sprints/SPRINT_0_IMPLEMENTACION.md](sprints/SPRINT_0_IMPLEMENTACION.md) - Diseño UI/UX (Sprint 0)
- ✅ [docs/sprints/SPRINT_1_IMPLEMENTACION.md](sprints/SPRINT_1_IMPLEMENTACION.md) - Modelos y Arquitectura (Sprint 1)
- 🚧 [docs/sprints/SPRINT_2_IMPLEMENTACION.md](sprints/SPRINT_2_IMPLEMENTACION.md) - Autenticación (Sprint 2 en curso)

### Reglas de Desarrollo
- ✅ [.cursor/rules/flutter_style_rules.mdc](.cursor/rules/flutter_style_rules.mdc) - Convenciones activas del proyecto
- ✅ [analysis_options.yaml](analysis_options.yaml) - Reglas de linting basadas en `flutter_lints`

### Estructura de Documentación
```
docs/
├── sprints/
│   ├── SPRINT_0_IMPLEMENTACION.md  ✅ # Implementación detallada Sprint 0
│   ├── SPRINT_1_IMPLEMENTACION.md  ✅ # Implementación detallada Sprint 1
│   └── SPRINT_2_IMPLEMENTACION.md  🚧 # Documento vivo Sprint 2
├── FIRESTORE_SCHEMA.md           📅 # Esquema de base de datos
├── DEVTOOLS_SETUP.md             📅 # Configuración de herramientas
├── ARCHITECTURE.md               📅 # Arquitectura del proyecto
├── API_DOCUMENTATION.md          📅 # Documentación de APIs
└── DEPLOYMENT.md                 📅 # Guía de despliegue
```

---

## 🧭 Conclusión

**Playing Tracker** se posiciona como una **herramienta pedagógica innovadora y viable**, centrada en la objetividad del estudio musical. Su desarrollo con enfoque **diseño primero** y arquitectura optimizada permite:

✅ **Experiencia de usuario excepcional:** Material Design 3 desde el inicio
✅ **Arquitectura escalable:** Base de datos NoSQL optimizada con 7 colecciones
✅ **Rendimiento superior:** Anti-hotspot y fan-out optimizado
✅ **Seguridad robusta:** Reglas de Firestore granulares por rol
✅ **Mantenibilidad:** Código limpio con documentación completa
✅ **Adaptabilidad:** Arquitectura preparada para nuevas funcionalidades

Con **enfoque en diseño primero**, el proyecto establece una base sólida de UI/UX antes de implementar la lógica de negocio, asegurando una experiencia de usuario excepcional desde el primer momento.

---

## 📂 Contexto para Cursor AI

Este documento sirve como **guía integral para el entorno Cursor**, proporcionando:

- 📋 Visión completa del propósito y alcance del proyecto
- 🏗️ Arquitectura de base de datos optimizada con 7 colecciones
- 🎨 Enfoque de desarrollo: Diseño primero, lógica después
- 📊 Roadmap de 8 sprints con objetivos claros
- 🔧 Tecnologías, dependencias y configuraciones
- 📚 Referencias a documentación detallada
- ✅ Progreso verificable con enfoque iterativo

**Última actualización:** 20 de Noviembre 2025
**Versión del documento:** 5.1
**Progreso del proyecto:** Sprint 2 en progreso (Sprints 0 y 1 completados)
**Siguiente sprint:** Sprint 3 - Sistema de Clases y Membresías (planificado)
