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
- [ ] **Implementar `SessionRepository`**:
  - Contrato e implementación que orquesta la llamada al servicio.
  - Manejo de errores (`SessionException`).
- [ ] **Tests Unitarios**:
  - Validar serialización del modelo.
  - Mockear `FirebaseFirestore` para validar la lógica de transacción (o al menos la llamada).

### ⏱️ Fase 2: Lógica del Cronómetro (State Management)
**Objetivo:** Crear el motor del cronómetro independiente de la UI.

- [ ] **Implementar `TimerTicker`**: Clase auxiliar streamable que emite ticks cada segundo.
- [ ] **Implementar `SessionCubit`**:
  - Estados: `SessionInitial`, `SessionRunning` (duration), `SessionPaused` (duration), `SessionSuccess` (summary), `SessionError`.
  - Métodos: `startSession(taskId)`, `pauseSession()`, `resumeSession()`, `stopSession()` (pre-guardado), `saveSession()`.
  - **Manejo de ciclo de vida:** Detectar `AppLifecycleState` para ajustar el tiempo si la app se minimiza (guardar timestamp de "pause" background y recalcular al volver).
- [ ] **Tests Unitarios del Cubit**:
  - Validar transiciones de estado `idle` -> `running` -> `paused`.
  - Validar cálculo de tiempo.

### 📱 Fase 3: Interfaz de Práctica (Timer UI)
**Objetivo:** Pantalla donde el alumno realiza la práctica.

- [ ] **Crear `TimerScreen`**:
  - Diseño circular (progress indicator) visualmente atractivo.
  - Mostrar tiempo transcurrido (MM:SS o HH:MM:SS).
  - Botones grandes de control (Play/Pause/Stop).
  - Input opcional para "Notas de sesión" al finalizar.
- [ ] **Integración en Navegación**:
  - Acceso desde `StudentTaskDetailScreen` -> botón "Practicar".
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
