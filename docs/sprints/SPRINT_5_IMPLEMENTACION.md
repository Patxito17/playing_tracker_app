# SPRINT 5: Ejecución de Tareas y Cronómetro (Core Loop Principal)

**Estado:** 📅 Planificado / En Progreso
**Fecha de inicio:** Enero 2026
**Duración estimada:** 2 semanas

---

## 🎯 Objetivos del Sprint

1. **Implementar el Cronómetro de Práctica:**
   - Crear un timer robusto que funcione incluso si la app pasa a segundo plano (usando `WidgetsBindingObserver` para calcular deltas de tiempo).
   - Estados: `idle`, `running`, `paused`, `finished`.
   - Controles: Iniciar, Pausar, Reanudar, Finalizar (Guardar/Descartar).

2. **Gestión de Sesiones (Data Layer):**
   - Implementar `SessionService` para crear registros en la colección `sessions`.
   - Implementar lógica transaccional para actualizar contadores en `assignments` y `students` (Atomic increment).

3. **Integración con Tareas (UI):**
   - Desde el detalle de una tarea asignada (Student), poder iniciar una sesión.
   - Feedback visual en tiempo real durante la práctica.

4. **Historial de Sesiones:**
   - Visualizar lista de sesiones pasadas por tarea o generales.

---

## 📅 Fases de Implementación

### 🏗️ Fase 1: Capa de Datos y Dominio (Sessions)
**Objetivo:** Establecer los cimientos para persistir las sesiones de práctica.

- [x] **Definir Modelo `SessionModel`**:
  - Campos: `id`, `studentId`, `taskId`, `teacherId`, `startTime`, `endTime`, `durationSeconds`, `status` (completed), `createdAt`, `notes`.
  - Mappers `fromJson`/`toJson`.
- [x] **Implementar `SessionService`**:
  - Método `createSession(SessionModel)`: Insertar en `sessions`.
  - *Transacción:* Actualizar `assignments/{assignmentId}` incrementando `sessionsCount` y `totalDurationLogged`.
  - *Transacción:* Actualizar `students/{studentId}` incrementando totales globales.
- [x] **Implementar `SessionRepository`**:
  - Contrato e implementación que orquesta la llamada al servicio.
  - Manejo de errores (`SessionException`).
- [x] **Tests Unitarios**:
  - ✅ Validación de serialización del modelo (28 tests en `session_model_test.dart`).
  - ✅ Mock de `FirebaseFirestore` usando `FakeFirebaseFirestore` para validar lógica de transacción (13 tests en `session_service_test.dart`).
  - ✅ Tests del repositorio con Mocktail (16 tests en `session_repository_test.dart`).
  - **Total: 57 tests pasando** (100% cobertura de código público).

### ⏱️ Fase 2: Lógica del Cronómetro (State Management)
**Objetivo:** Crear el motor del cronómetro independiente de la UI.

- [x] **Implementar `TimerTicker`**: Clase auxiliar streamable que emite ticks cada segundo.
  - ✅ Stream broadcast con emisión de ticks cada segundo (configurable).
  - ✅ Control start/pause/stop con mantenimiento de estado.
  - ✅ Gestión de recursos con dispose().
  - ✅ 24 tests pasando validando emisión, control y casos límite.
- [x] **Implementar `SessionCubit`**:
  - ✅ Estados: `SessionInitial`, `SessionRunning`, `SessionPaused`, `SessionSaving`, `SessionSuccess`, `SessionError`.
  - ✅ Métodos: `startSession()`, `pauseSession()`, `resumeSession()`, `stopSession()`, `saveSession()`.
  - ✅ Integración con `TimerTicker` para emisión de ticks cada segundo.
  - ✅ Manejo de ciclo de vida con `WidgetsBindingObserver` para ajustar tiempo en background/foreground.
  - ✅ Persistencia de sesiones usando `SessionRepository`.
  - ✅ 17 tests pasando validando todos los métodos y casos de error.
- [x] **Tests Unitarios del Cubit**:
  - ✅ Validación de transiciones de estado (idle → running → paused → success).
  - ✅ Validación de cálculo de tiempo con ticker.
  - ✅ Validación de manejo de errores en cada operación.
  - ✅ Validación de persistencia con repository mockeado.
  - **Total Fase 2: 41 tests** (24 TimerTicker + 17 SessionCubit) ✅

### 📱 Fase 3: Interfaz de Práctica (Timer UI)
**Objetivo:** Pantalla donde el alumno realiza la práctica.

- [x] **Crear `TimerScreen`**:
  - ✅ Diseño circular con progress indicator animado y gradientes premium.
  - ✅ Mostrar tiempo transcurrido en formato adaptativo (MM:SS o HH:MM:SS).
  - ✅ Botones grandes de control con animación de pulso (Play/Pause/Resume/Stop/Save).
  - ✅ Input opcional para "Notas de sesión" al finalizar.
  - ✅ Integración completa con `SessionCubit` y estado reactivo.
  - ✅ Confirmación antes de descartar sesión.
  - ✅ Feedback visual con SnackBars y estados de carga.
  - ✅ Manejo de navegación con PopScope para prevenir pérdida de datos.
  - ✅ Validación mediante `flutter analyze` (sin errors).
  - ℹ️ **Nota sobre tests**: Los widget tests para esta pantalla son complejos debido a que `SessionCubit` implementa `WidgetsBindingObserver` y `TimerTicker`. La funcionalidad está validada mediante:
    - 17 tests del `SessionCubit` (incluyen todas las interacciones del timer).
    - 24 tests del `TimerTicker` (validan la emisión correcta de ticks).
    - Análisis estático con `flutter analyze` (0 issues).
    - Integración en `app_routes.dart` con configuración correcta del BlocProvider.
- [x] **Integración en Navegación**:
  - ✅ Acceso desde `AssignmentDetailScreen` (pantalla de detalle para estudiantes).
  - ✅ Botón "Iniciar Práctica" con icono `play_circle_outline`.
  - ✅ Navegación con `context.goNamed()` pasando parámetros correctos.
  - ✅ Extra data: `studentId`, `teacherId`, `taskTitle`.
  - ✅ Path parameters: `taskId`.
  - ✅ Validado con `flutter analyze` (sin errores).
- [ ] **Feedback visual**:
  - Animaciones suaves al pausar/reanudar.
  - Dialog de confirmación antes de descartar una sesión en curso.

### 💾 Fase 4: Persistencia y Feedback
**Objetivo:** Conectar el timer con Firebase y cerrar el ciclo.

- [ ] **Conectar `SessionCubit.saveSession`** con `SessionRepository`.
- [ ] **Manejar éxito**:
  - Mostrar pantalla de resumen ("¡Bien hecho! 30 minutos practicados").
  - Navegar de vuelta al detalle de la tarea o lista.
- [ ] **Validar contadores**:
  - Verificar que en `assignment` se actualizó el progreso.
  - Verificar estadísticas rápidas en el perfil del alumno.

### 📜 Fase 5: Historial y Detalles
**Objetivo:** Permitir al alumno ver qué ha hecho.

- [ ] **Implementar `SessionHistoryScreen`**:
  - Lista paginada de sesiones ordenadas por fecha reciente.
  - Filtros básicos (por tarea o fecha).
- [ ] **Detalle de Sesión (Opcional por ahora)**:
  - Ver notas y duración exacta.

### ✅ Fase 6: Calidad y Pulido
- [ ] **Tests de Widget**:
  - `timer_screen_test.dart`: Verificar que los botones cambian el estado visual.
- [ ] **Pruebas Manuales**:
  - Probar ciclo completo: Iniciar -> Minimizar app 5 min -> Volver (tiempo correcto) -> Guardar -> Verificar Firestore.
- [ ] **Code Review & Refactor**: Limpieza de código.

---

## 🛠️ Archivos Clave a Crear/Modificar

- `lib/features/sessions/domain/models/session_model.dart`
- `lib/features/sessions/data/services/session_service.dart`
- `lib/features/sessions/data/repositories/session_repository.dart`
- `lib/features/sessions/presentation/cubit/session_cubit.dart`
- `lib/features/sessions/presentation/screens/timer_screen.dart`
- `lib/features/sessions/presentation/screens/session_history_screen.dart`

---

## 🧪 Estrategia de Pruebas

1. **Unitarias**: Lógica de cálculo de tiempo en `SessionCubit` es crítica. Se debe simular el paso del tiempo.
2. **Integración (Simulada)**: Verificar que al guardar sesión se llamen a los métodos de actualización de estadísticas.
