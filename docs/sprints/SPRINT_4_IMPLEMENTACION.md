# 🎯 Sprint 4 · Gestión de Tareas y Asignaciones

| Campo | Valor |
| --- | --- |
| Proyecto | Playing Tracker |
| Alcance | Backend + UI (docentes/alumnos) |
| Duración | 2 semanas (dic 2025) |
| Estado | 🚧 En progreso |
| Última actualización | 01/12/2025 |
| Responsable | Equipo de desarrollo |

---

## 1. Objetivo y Resultado Esperado
- Habilitar a docentes para crear, editar, filtrar y asignar tareas reales a sus clases mediante fan-out automático.
- Permitir que los alumnos visualicen todas sus tareas asignadas con información completa y preparación para el cronómetro del Sprint 5.

## 2. Alcance
### Incluido
- CRUD completo de `tasks` (colección raíz, ownership del docente).
- Sistema de asignaciones (`assignments` raíz) vía fan-out preparado en Sprint 3.
- Filtros soportados por Firestore (ver sección 6).
- UI docente/alumno conectada a Cubits reales.
- Preparación de hooks para cronómetro (sin lógica de sesiones).

### Excluido
- Upload en Firebase Storage (solo URLs externas validadas).
- Cambios de estado realizados por alumnos (solo visualización).
- Búsqueda textual completa (se evaluará Algolia posteriormente).
- Cronómetro y métricas avanzadas (Sprint 5+).

## 3. Dependencias y Prerrequisitos
- Flutter 3.38.x · Dart 3.10.x · Firebase SDK 2025 (ya configurado).
- Clases y memberships productivos (Sprint 3 completado).
- FanOutHelper existente (Sprint 3) listo para extender.
- Credenciales Firebase y emuladores operativos.
- Sprint 3 cerrado (documento actualizado a versión 1.0 y estado Completado).
- QA baseline ejecutado el 01/12/2025:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze --fatal-infos --fatal-warnings`
  - `flutter test` (todas las pruebas pasan, con tests pendientes marcados como `skip`).

## 4. Entregables por Capa
### Dominio
- `task_repository.dart` (contrato + excepciones).
- Value objects en records (`create_task_input.dart`, `update_task_input.dart`, `assign_task_input.dart`, `task_filters.dart`).

### Infraestructura
- Servicios Firestore (`task_service.dart`, `assignment_service.dart`).
- `task_repository_impl.dart` (usa servicios + FanOutHelper).
- `fan_out_helper.dart` actualizado (único punto que ejecuta batch writes, límite 500).
- Nuevos índices en `firebase/firestore.indexes.json`.

### Presentación
- `task_cubit.dart` y `assignment_cubit.dart` con estados sealed.
- UI docente: `create_task_screen.dart`, `task_list_screen.dart`, `task_detail_screen.dart` conectadas.
- UI alumno: lista y detalle de assignments (widgets + screens nuevas).
- Componentes reutilizables: `task_card`, `assignment_card`, `task_filters_bottom_sheet`.

### Testing & Docs
- Unit tests de servicios y repositorio (`fake_cloud_firestore`, `mocktail`).
- Tests de Cubits (`bloc_test`).
- Widget tests básicos de pantallas.
- Actualización de `docs/Guia_Proyecto_PlayingTracker.md` + este documento.

## 5. Archivos a Crear / Modificar (resumen)
| Ruta | Acción | Responsabilidad |
| --- | --- | --- |
| `lib/features/tasks/domain/repositories/task_repository.dart` | Nuevo | Contrato + excepciones |
| `lib/features/tasks/domain/value_objects/*.dart` | Nuevos | Records para inputs y filtros |
| `lib/features/tasks/data/services/task_service.dart` | Nuevo | CRUD `tasks` |
| `lib/features/tasks/data/services/assignment_service.dart` | Nuevo | CRUD `assignments` |
| `lib/features/tasks/data/repositories/task_repository_impl.dart` | Nuevo | Orquesta dominio ↔ Firestore |
| `lib/features/classes/data/helpers/fan_out_helper.dart` | Modificar | Implementar fan-out real |
| `lib/features/tasks/presentation/cubit/*` | Nuevos | Cubits docentes/alumnos |
| `lib/features/tasks/presentation/screens/*` | Actualizar | Conectar Cubits + filtros |
| `test/features/tasks/**/*` | Nuevos | Unit + widget tests |
| `firebase/firestore.indexes.json` | Modificar | Índices para filtros soportados |

### Firmas obligatorias del repositorio
```dart
abstract class TaskRepository {
  Future<TaskModel> createTask(CreateTaskInput input);
  Future<void> updateTask(UpdateTaskInput input);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskModel>> watchTeacherTasks(
    String teacherId, {
    TaskFilters? filters,
  });
  Stream<List<AssignmentModel>> watchStudentAssignments(
    String studentId, {
    TaskFilters? filters,
  });
  Future<void> assignTaskToClass(AssignTaskInput input);
  Future<TaskModel?> getTaskById(String taskId);
  Future<AssignmentModel?> getAssignmentById(String assignmentId);
}
```

## 6. Flujos y Restricciones Clave
- **Colecciones:** `tasks` (docente owner, campos principales + `isActive`, `dueDate`), `assignments` (alumno owner, denormalizar `taskTitle`, `durationSuggested`).
- **Fan-out:** se ejecuta únicamente desde `FanOutHelper.fanOutTaskToClass()`. Prohibido duplicar lógica en repositorios o Cubits.
- **Filtros soportados (Firestore):**
  - Docente: `createdBy + isActive + createdAt` ó `createdBy + isActive + dueDate`.
  - Alumno: `studentId + status + assignedAt`.
  - No mezclar más de dos rangos simultáneos (p.ej. rango de fecha + duración + clase = ❌).
- **UI:** estados vacíos con `_EmptyState`, errores con `SelectableText.rich`, sin texto hardcodeado.
- **Accesibilidad:** botones ≥48dp, `Semantics` en bloques de error, strings capitalizados según reglas.

## 7. Plan por Fases (máx. 7 tareas cada una)
### Fase 1 · Kickoff (½ día)
1. Cerrar pendientes Sprint 3 y validar FanOutHelper.
2. Ejecutar `dart format`, `flutter analyze`, `flutter test` (baseline).
3. Documentar prerequisitos en este archivo.

### Fase 2 · Dominio (1 día)
1. Crear contrato `TaskRepository` + excepciones.
2. Definir records para inputs/filtros con validaciones mínimas.
3. Escribir tests base (TDD) que usará `mocktail`.

### Fase 3 · Infraestructura (2 días)
1. Implementar `task_service` y `assignment_service` (solo Firestore, sin lógica UI).
2. Actualizar `fan_out_helper` (batch único, logs no requeridos, solo TODO para métricas).
3. Completar `firestore.indexes.json` y validar con `firebase emulators`.
4. Tests unitarios con `fake_cloud_firestore`.

### Fase 4 · Repositorio + Cubits (1½ días)
1. Implementar `task_repository_impl` (inyección de servicios + helper).
2. Crear `task_cubit` (docente) y `assignment_cubit` (alumno) con estados sealed.
3. Añadir filtros compatibles y manejo de errores traducidos.
4. Tests `bloc_test` ≥80 % cobertura en lógica de estado.

### Fase 5 · UI Docente (1 día)
1. Conectar `create_task_screen`, `task_list_screen`, `task_detail_screen` a `TaskCubit`.
2. Agregar bottom sheet de filtros con combinaciones permitidas.
3. Confirmaciones Material 3 para asignar/eliminar.
4. Widget tests básicos.

### Fase 6 · UI Alumno (1 día)
1. Crear pantallas de lista/detalle de assignments.
2. Mostrar chips de estado, filtros simples y botón “Iniciar práctica” (placeholder).
3. Widget tests mínimos.

### Fase 7 · QA + Documentación (½ día)
1. Ejecutar `dart format --set-exit-if-changed .`.
2. `flutter analyze --fatal-infos --fatal-warnings`.
3. `flutter test --coverage` (≥80 % en `lib/features/tasks`).
4. Actualizar README + guía general + este documento.

## 8. Criterios de Aceptación (resumen)
1. Docente crea/edita/elim/filtra tareas y asigna a clases reales (fan-out ≤2s para ≤50 alumnos).
2. Alumno visualiza assignments con estados y adjuntos, sin modificar progreso.
3. Filtros solo aceptan combinaciones soportadas y reflejan índices definidos.
4. No se ejecuta fan-out fuera de `FanOutHelper`.
5. `flutter analyze` sin errores, cobertura ≥80 % en features/tasks.
6. Documentación y strings centralizados actualizados.

## 9. Próximos Pasos (Sprint 5)
- Implementar cronómetro, sesiones y actualización automática de assignments (`updateAssignmentProgress`).
- Integrar métricas de tiempo y dashboards básicos.

## 10. Historial de Versiones
| Versión | Fecha | Comentario |
| --- | --- | --- |
| 2.1 | 01/12/2025 | Fase 1 iniciada: Sprint 3 cerrado, prerequisitos validados y QA baseline ejecutado. |
| 2.0 | 27/11/2025 | Documento reducido y optimizado para Cursor (25 % del tamaño anterior). |
| 1.0 | 27/11/2025 | Versión inicial detallada (reemplazada). |
