# 🎯 Sprint 4 · Gestión de Tareas y Asignaciones

| Campo | Valor |
| --- | --- |
| Proyecto | Playing Tracker |
| Alcance | Backend + UI (docentes/alumnos) |
| Duración | 2 semanas (Enero 2026) |
| Estado | 🚧 En fase final de UI y QA |
| Última actualización | 07/01/2026 |
| Responsable | Equipo de desarrollo |

---

## 1. Objetivo y Resultado Esperado
- Habilitar a docentes para crear, editar, filtrar y asignar tareas reales a sus clases mediante fan-out automático.
- Permitir que los alumnos visualicen todas sus tareas asignadas con información completa y preparación para el cronómetro del Sprint 5.

## 2. Alcance
### Incluido
- CRUD completo de `tasks` (colección raíz, ownership del docente).
- Sistema de asignaciones (`assignments` raíz) vía fan-out preparado en Sprint 3.
- Filtros soportados por Firestore.
- UI docente/alumno conectada a Cubits reales.
- **Validación de seguridad:** Reglas de Firestore actualizadas para permitir lectura segura de clases/memberships.

### Excluido
- Upload en Firebase Storage (solo URLs externas validadas).
- Cambios de estado realizados por alumnos (solo visualización y progreso local futuro).
- Cronómetro y métricas avanzadas (Sprint 5).

## 3. Prerrequisitos (Verificados)
- ✅ Flutter 3.x y Firebase configurado.
- ✅ Sprint 3 Completado (Clases y Memberships funcionales).
- ✅ Reglas de seguridad ajustadas (`isClassOwner`, permisos de lectura).

---

## 4. Estado Actual de Implementación

### ✅ Completado
1.  **Dominio e Infraestructura**:
    *   Repositorios y Servicios (`TaskService`, `AssignmentService`) implementados.
    *   Modelos y Value Objects creados.
    *   `FanOutHelper` actualizado para distribución masiva.
    *   Índices de Firestore (`firestore.indexes.json`) definidos.

2.  **Gestión de Estado (Cubits)**:
    *   `TaskCubit` (Docente) implementado.
    *   `AssignmentCubit` (Alumno) implementado.

3.  **UI Docente**:
    *   `TaskListScreen` conectada y funcional.
    *   `CreateTaskScreen` implementada.
    *   `TaskFiltersBottomSheet` lógica implementada.

### 🚧 Pendiente / Por Revisar
1.  **UI Alumno**: Verificar conexión final de `AssignmentListScreen` y `AssignmentDetailScreen`.
2.  **Validación de flujos**: Asegurar que la creación de tarea dispare el Fan-Out correctamente en el emulador.
3.  **Tests**: Cobertura de tests unitarios y de widgets.

---

## 5. Plan de Trabajo Restante (Agent-Optimized)

### Fase 5: UI Alumno y Detalles Visuales (Prioridad Alta)
- [ ] **Revisar `AssignmentListScreen`**:
    - Verificar que use `AssignmentCubit`.
    - Validar diseño de `AssignmentCard` (estados, fechas).
    - Implementar estados vacíos y manejo de errores.
- [ ] **Revisar `AssignmentDetailScreen`**:
    - Mostrar detalles completos (adjuntos, descripción).
    - Botón "Iniciar Práctica" (deshabilitado o con SnackBar "Próximamente").

### Fase 6: Validación de Flujos (Integration)
- [ ] **Prueba de Creación y Asignación**:
    - Crear tarea como docente -> Verificar que `fanOutTaskHook` cree los documentos en `assignments`.
    - Verificar que el alumno vea la tarea nueva en su lista.
- [ ] **Prueba de Edición/Eliminación**:
    - Docente edita tarea -> Alumno ve cambios.
    - Docente elimina tarea -> Alumno deja de verla (o la ve archivada, según lógica).

### Fase 7: Calidad y Tests
- [ ] **Unit Tests**:
    - `task_cubit_test.dart`
    - `assignment_cubit_test.dart`
- [ ] **Widget Tests**:
    - Smoke test de `TaskListScreen`.
    - Smoke test de `AssignmentListScreen`.
- [ ] **Linting Final**: Ejecutar `flutter analyze` y corregir warnings residuales.

---

## 6. Archivos Clave para el Agente

| Funcionalidad | Archivo Principal | Estado |
| --- | --- | --- |
| **Lista Tareas (Docente)** | `lib/features/tasks/presentation/screens/task_list_screen.dart` | ✅ Listo |
| **Crear Tarea** | `lib/features/tasks/presentation/screens/create_task_screen.dart` | ✅ Listo |
| **Cubit Docente** | `lib/features/tasks/presentation/cubit/task_cubit.dart` | ✅ Listo |
| **Lista Asignaciones (Alumno)** | `lib/features/tasks/presentation/screens/assignment_list_screen.dart` | ❓ Revisar |
| **Detalle Asignación** | `lib/features/tasks/presentation/screens/assignment_detail_screen.dart` | ❓ Revisar |
| **Fan Out** | `lib/features/classes/data/helpers/fan_out_helper.dart` | ✅ Listo |
