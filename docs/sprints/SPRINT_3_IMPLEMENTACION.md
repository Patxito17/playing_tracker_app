# 🚀 Sprint 3 — Implementación del Sistema de Clases y Membresías

**Proyecto:** Playing Tracker - Sistema de Seguimiento de Estudio Musical
**Temporalidad:** Diciembre 2025 (2 semanas)
**Contexto:** Depende del cierre del Sprint 2 (infraestructura + autenticación)
**Propósito:** Implementar toda la capa funcional de clases, membresías y fan-out inicial manteniendo arquitectura Domain → Repository → Service → UI y Material Design 3.
**Estado:** 🚧 En progreso
**Versión del documento:** 0.5
**Última actualización:** 21 de Noviembre 2025
**Responsable:** Equipo de Desarrollo (documento apto para ejecución por IA-agents y desarrolladores humanos)

---

## 🎯 Objetivo del Sprint

Implementar la lógica completa de **creación y gestión de clases**, el **sistema de membresías N:M** y la preparación del **fan-out de asignaciones** que permitirá escalar las tareas en el Sprint 4. Este sprint conecta la UI diseñada en Sprint 0 con los modelos y reglas definidos en Sprint 1, habilitando a los docentes para crear clases reales y a los alumnos para unirse mediante códigos seguros.

### Resultado esperado

- Docentes pueden crear, editar, archivar y listar clases en Firestore.
- Alumnos pueden unirse o abandonar clases usando un código de acceso válido.
- Se registra y sincroniza la relación N:M en la colección `memberships` con datos denormalizados.
- La UI existente (TeacherClassesList, CreateClass, JoinClass, ManageStudents) consume la nueva lógica vía Cubits.
- Se documenta la estrategia de fan-out para asignaciones y se dejan ganchos listos para Sprint 4.

---

## 📐 Alcance del Sprint

### ✅ Incluido

1. **Servicios y repositorios de clases**
   - CRUD completo sobre `classes` y `memberships`.
   - Generación e invalidación de códigos de acceso.
2. **Cubits y estados**
   - `ClassCubit`, `MembershipCubit` con estados sealed e inmutables.
   - Manejo de carga, éxito, error y vacíos.
3. **Integración UI**
   - `CreateClassScreen`, `JoinClassScreen`, `TeacherClassesListScreen`, `ManageStudentsScreen`.
   - Estados vacíos y feedback con `SelectableText.rich`.
4. **Fan-out inicial**
   - Helpers para propagar tareas hacia `assignments` (sólo preparación y documentación).
5. **Testing mínimo**
   - Unit tests para repositorios y Cubits (bloc_test + mocktail).
6. **Documentación**
   - Actualización de `Guia_Proyecto_PlayingTracker.md`, `docs/indexing/` y documento de sprint.

### ❌ Excluido

- CRUD completo de tareas/asignaciones (Sprint 4).
- Cronómetro y sesiones (Sprint 5).
- Dashboards o estadísticas avanzadas.
- Integraciones con Cloud Functions (sólo se documentan requisitos).

---

## 🛠️ Stack tecnológico y dependencias

| Capa | Herramienta | Uso |
|------|-------------|-----|
| Datos | `cloud_firestore`, `firebase_auth` | CRUD de clases/memberships + seguridad |
| Estado | `flutter_bloc`, `hydrated_bloc` | Cubits persistentes por rol |
| Helpers | `uuid`, `intl` | Generación de IDs y formateo de fechas |
| Testing | `bloc_test`, `mocktail` | Unit/widget tests |

> **Nota:** No se agregan nuevas dependencias respecto al Sprint 2, pero se documentan versiones mínimas en `pubspec.yaml` y se valida compatibilidad con Flutter 3.38.x / Dart 3.10.x.

### Dependencias Descontinuadas (Resuelto)

**Estado anterior (antes de actualizar a Dart 3.10.0):**
- `build_resolvers` (descontinuado) - Dependencia transitiva de `build_runner 2.7.1`
- `build_runner_core` (descontinuado) - Dependencia transitiva de `build_runner 2.7.1`

**Resolución:**
- ✅ **Actualización completada:** Con la actualización a Dart 3.10.0 y Flutter 3.38.2, se pudo actualizar `build_runner` a 2.10.4
- ✅ **Paquetes discontinuados eliminados:** Los paquetes `build_resolvers` y `build_runner_core` ya no aparecen en las dependencias
- ✅ **Funcionalidad migrada:** Su funcionalidad está ahora en el paquete `build 4.0.3` (actualizado desde 3.1.0)
- ✅ **Estado actual:** El proyecto compila y funciona sin errores, sin dependencias discontinuadas
- ✅ **Impacto:** Resuelto completamente con la actualización del SDK

---

## 📦 Entregables

### Código

- `lib/features/classes/data/services/class_service.dart`
- `lib/features/classes/data/repositories/class_repository_impl.dart`
- `lib/features/classes/domain/repositories/class_repository.dart`
- `lib/features/classes/presentation/cubit/class_cubit.dart`
- `lib/features/classes/presentation/cubit/class_state.dart`
- `lib/features/classes/presentation/cubit/membership_cubit.dart`
- `lib/features/classes/presentation/cubit/membership_state.dart`
- Actualizaciones de pantallas en `lib/features/classes/presentation/screens/`
- Tests en `test/features/classes/...`

### Documentación

- `docs/Guia_Proyecto_PlayingTracker.md` (sección Sprint 3 y roadmap).
- `docs/sprints/SPRINT_3_IMPLEMENTACION.md` (este documento).
- `docs/indexing/CURSOR_INDEXING_PROJECT_OVERVIEW.md` (nuevas rutas de archivos).
- Checklist de fan-out en `docs/analisis_requisitos_fase_diseño/`.

---

## 📁 Estructura generada / modificada en este Sprint

```
lib/
  core/
    utils/
      access_code_generator.dart         # NUEVO - generador centralizado
      firebase_error_mapper.dart         # YA EXISTE (Sprint 2)
  features/
    classes/
      data/
        services/
          class_service.dart             # NUEVO
          membership_service.dart        # NUEVO
        repositories/
          class_repository_impl.dart     # NUEVO
        models/
          class_model.dart               # EXISTE (Sprint 1) → agregar helpers, no romper firmas
          membership_model.dart          # EXISTE (Sprint 1) → agregar helpers, no romper firmas
      domain/
        repositories/
          class_repository.dart          # NUEVO
        value_objects/
          create_class_input.dart        # NUEVO record typedef
          invite_student_input.dart      # NUEVO record typedef
      presentation/
        cubit/
          class_cubit.dart               # NUEVO
          class_state.dart               # NUEVO
          membership_cubit.dart          # NUEVO
          membership_state.dart          # NUEVO
        screens/
          teacher_classes_list_screen.dart # YA EXISTE → conectar Cubits
          create_class_screen.dart         # YA EXISTE → conectar Cubits
          join_class_screen.dart           # YA EXISTE → conectar Cubits
          manage_students_screen.dart      # YA EXISTE → conectar Cubits
    shared/
      widgets/
        custom_button.dart               # YA EXISTE (uso obligatorio)
        custom_text_field.dart           # YA EXISTE (uso obligatorio)
```

> **Nota para IA-agents:** No crear archivos fuera de esta estructura salvo que se documente explícitamente en este sprint.

---

## 📘 Modelos existentes vs. nuevos

- `ClassModel` y `MembershipModel` ya fueron creados en Sprint 1 (`lib/features/classes/domain/models`).
  - Se permiten **solo adiciones no disruptivas**: getters derivados (`bool get isActive`), campos opcionales (`DateTime? accessCodeExpiresAt`) o métodos utilitarios.
  - **Prohibido** eliminar campos, cambiar nombres existentes o modificar `fromJson`/`toJson` sin documentar compatibilidad.
- No se crean modelos nuevos; se introducen **value objects** de entrada como records (`CreateClassInput`, `InviteStudentInput`, `JoinClassInput`).
- Todos los modelos de dominio deben ser clases inmutables simples escritas a mano (POJOs) sin generadores automáticos; Dart 3.10 promueve records y clases compactas para evitar boilerplate innecesario.
- Cualquier cambio estructural debe estar documentado en `docs/Guia_Proyecto_PlayingTracker.md` y acompañado de migración en Firestore.

---

## 🔒 Reglas de no rotura

1. No modificar firmas públicas definidas en Sprint 1 (modelos, enums, helpers).
2. No eliminar campos existentes en `ClassModel`, `MembershipModel` o cualquier DTO.
3. No mover pantallas fuera de `lib/features/classes/presentation/screens/`.
4. No alterar rutas declaradas en GoRouter; solo extender mediante nuevos `routes.add()`.
5. No introducir dependencias nuevas sin registrar en `pubspec.yaml` y documentar en README.
6. `ClassRepositoryImpl` es el único punto que conversa con servicios; Cubits jamás llaman servicios directamente y los servicios siempre deben mapear documentos de Firestore a modelos tipados del dominio (no `Map<String, dynamic>`).
7. Mantener compatibilidad con Flutter 3.38.x / Dart 3.10.x (`environment.sdk` sin cambios).

---

## 📊 Métricas y KPIs

- ✅ 100% de clases creadas reflejadas en Firestore con campos obligatorios (`name`, `description`, `ownerTeacherId`, `accessCode`).
- ✅ Tiempo de creación de clase < 400 ms promedio (profiling con DevTools).
- ✅ Cobertura de pruebas para lógica de clases ≥ 80%.
- ✅ `flutter analyze` y `flutter test` sin errores antes del cierre del sprint.
- ✅ Documentación actualizada el mismo día de cada entrega parcial.

---

## ⚠️ Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| Códigos de acceso duplicados | Medio | Generar códigos con `uuid` + validación transaccional |
| Condiciones de carrera al unir alumnos | Alto | Uso de `runTransaction` y retry exponencial |
| Reglas de Firestore desalineadas | Alto | Revisar `firestore.rules` en Fase 3 con escenarios reales |
| Fan-out incompleto | Medio | Documentar hooks y asegurar pruebas unitarias del helper |

---

## 📌 Validación del fan-out preparado

El sprint se considera listo respecto al fan-out cuando:

- Existe `FanOutHelper` en `lib/features/classes/data/helpers/fan_out_helper.dart` con:
  ```dart
  Future<void> prepareFanOut(String taskId, String classId);
  Future<void> propagateToAssignments(String taskId, String classId);
  ```
- `ClassRepositoryImpl` expone `Future<void> fanOutTask(String taskId, String classId)` que delega en el helper (implementación pendiente para Sprint 4, pero con logs y TODOs documentados).
- `membership_service.dart` provee `Future<List<String>> getStudentsForClass(String classId)` reutilizable por futuros fan-outs.
- Documentación del flujo guardada en `docs/analisis_requisitos_fase_diseño/Analisis_Requisitos_Fase_Diseño.md`.
- Tests unitarios del helper (aunque sea stub) validan que se llamen los servicios esperados y que los TODOs estén marcados.

---

## 🗂️ Plan de trabajo por fases

### Fase 1 · Kickoff y saneamiento técnico (0.5 día)
- ✅ Revisar backlog pendiente de Sprint 2 y cerrar issues bloqueantes.
- ✅ Actualizar `pubspec.lock` si hay upgrades menores.
- ✅ Ejecutar `flutter clean`, `flutter pub get`, `dart format .`, `flutter analyze`.
- ✅ Documentar en este archivo la fecha real de inicio.

**Estado:** ✅ Completada (21 de Noviembre 2025)

**Checklist**
- [x] Dependencias validadas.
  - ✅ SDK actualizado de ^3.9.2 a ^3.10.0 (Flutter 3.38.2 con Dart 3.10.0)
  - ✅ Flutter actualizado de 3.35.6 a 3.38.2 (incluye Dart 3.10.0)
  - ✅ Agregada dependencia `uuid: ^4.5.1` para generación de códigos de acceso
  - ✅ Agregada dependencia `bloc_test: ^10.0.0` para testing de Cubits
  - ✅ Actualizadas dependencias de desarrollo a versiones más recientes:
    - `build_runner: ^2.7.1` → `^2.10.4` (resuelve dependencias discontinuadas)
    - `json_serializable: ^6.8.0` → `^6.11.2`
  - ✅ Paquetes discontinuados eliminados:
    - `build_resolvers` y `build_runner_core` ya no son dependencias (resuelto con actualización)
  - ✅ Ejecutado `flutter pub outdated` y `flutter pub upgrade --major-versions`: todas las dependencias actualizadas
  - ✅ Todas las dependencias requeridas para Sprint 3 presentes y compatibles
- [x] Proyecto compila en iOS/Android.
  - ✅ `flutter doctor` ejecutado sin problemas críticos
  - ✅ `flutter analyze` sin errores (0 issues found)
  - ✅ `dart analyze --fatal-infos --fatal-warnings` sin errores ni warnings
  - ✅ `dart format .` ejecutado sin cambios necesarios (0 changed)
  - ✅ `flutter test` ejecutado: 15 tests pasados exitosamente
- [x] Documentación sincronizada (README + guía general).
  - ✅ Este documento actualizado con fecha de inicio y estado de Fase 1
  - ✅ Sección de dependencias discontinuadas actualizada (resuelto)
  - ✅ Historial de versiones actualizado con actualización del SDK

---

### Fase 2 · Contratos y modelos de dominio (1 día)
- Revisar modelos existentes (`ClassModel`, `MembershipModel`) y añadir getters/helpers necesarios (por ejemplo `bool get isActive`).
- Crear `lib/features/classes/domain/repositories/class_repository.dart` con métodos:
  - `Future<ClassModel> createClass(CreateClassInput input)`
  - `Stream<List<ClassModel>> watchTeacherClasses(String teacherId)`
  - `Future<void> inviteStudent(InviteStudentInput input)`
  - `Future<void> joinClassWithCode(String studentId, String code)`
  - `Future<void> updateClassStatus(String classId, bool isActive)`
- Definir `typedef` con records para inputs (`typedef CreateClassInput = ({String name, String description, String ownerId});`).
- Documentar cada contrato con dartdoc.

**Checklist**
- [x] Repositorio de dominio creado y documentado.
- [x] Typedefs con records definidos.
- [x] Tests base generados con mocks (aunque fallen) para guiar TDD.

**Actualización 21/11/2025**
- Se añadieron getters derivados en `ClassModel` y `MembershipModel` para exponer estados de forma declarativa sin romper compatibilidad.
- Se crearon los records `CreateClassInput`, `InviteStudentInput` y `JoinClassInput` con validaciones sincrónicas y ejemplos de uso.
- Se definió el contrato `ClassRepository` con excepciones especializadas y nota explícita sobre paginación (20 ítems) y hook de fan-out.
- Se agregaron pruebas base en `test/features/classes/domain/repositories/class_repository_test.dart` marcadas como pendientes para guiar las fases 4-7.
- Riesgo registrado: falta definir índices de Firestore adicionales para consultas por `ownerTeacherId` antes de implementar `watchTeacherClasses`.

---

### Fase 3 · Servicios Firebase y reglas (2 días)
- Implementar `ClassService` y `MembershipService` con operaciones CRUD y transacciones.
- Añadir validaciones de acceso en `firebase/firestore.rules` (write restringido a owner, read filtrado por rol).
- Configurar índices necesarios en `firebase/firestore.indexes.json` para consultas por `ownerTeacherId` y `classId`.
- Crear helper `AccessCodeGenerator` en `lib/core/utils/access_code_generator.dart`.
- Documentar flujos en `docs/analisis_requisitos_fase_diseño/`.

**Checklist**
- [x] Servicios completados con manejo de excepciones traducidas vía `firebase_error_mapper`.
- [x] Reglas y archivos de índices actualizados.
- [x] Tests unitarios de servicios con `fake_cloud_firestore`.

**Actualización 21/11/2025**
- Se implementó `AccessCodeGenerator` con caracteres sin ambigüedad, reutilizado por `ClassService`.
- `ClassService` cubre creación paginada, regeneración de códigos, observación en tiempo real y hook `fanOutTaskHook` con TODO para Sprint 4.
- `MembershipService` soporta invitaciones manuales, unión por código, reactivación de membresías y obtención de alumnos para el futuro fan-out.
- Reglas de Firestore permiten que alumnos creen/reactiven membresías verificadas por código y exigen `updatedAt`; los índices incluyen `classes.ownerTeacherId+createdAt` y `memberships.classId+isActive+joinedAt`.
- Nuevos tests en `test/features/classes/data/services/` usando `fake_cloud_firestore` + `mocktail`; ejecutados con `flutter test test/features/classes/data/services` (100% passing).
- Documentación sincronizada (Guía del Proyecto, README, índice Cursor y análisis de requisitos) y registro de la nueva dependencia `fake_cloud_firestore`.
- Se ejecutaron `flutter pub outdated` y `flutter pub upgrade`; sólo `built_value` avanzó a 8.12.1, mientras que `json_serializable >=6.11.3` permanece bloqueado por `bloc_test`/`flutter_test` (analyzer 9), documentándose la restricción para próximas migraciones de SDK.

---

### Fase 4 · Repositorio e integración Cubit (1 día)
- Implementar `ClassRepositoryImpl` inyectando servicios y mappers.
- Crear `ClassCubit` y `ClassState` (sealed) con casos: `initial`, `loading`, `success`, `empty`, `error`.
- Añadir `MembershipCubit` para operaciones de unión/expulsión.
- Escribir pruebas con `bloc_test` cubriendo escenarios felices y de error.

**Checklist**
- [x] Cubits creados con métodos descritos (`createClass`, `watchClasses`, `joinClass`, `removeStudent`).
- [x] Bloc observer loggea transiciones relevantes.
- [ ] Cobertura ≥ 80% en `test/features/classes/presentation/cubit/`.

**Actualización 24/11/2025**
- Se implementó `ClassRepositoryImpl` con contratos desacoplados (`ClassServiceContract`, `MembershipServiceContract`, `FanOutHelperContract`) y manejo exhaustivo de excepciones específicas (`InvalidAccessCodeException`, `MembershipNotFoundException`, etc.).
- Se añadieron los Cubits `ClassCubit` y `MembershipCubit` con estados sealed (`ClassState`, `MembershipState`) alineados a Material 3, validaciones sincrónicas y hooks para refresco manual.
- Nuevo `FanOutHelper` documentado en `lib/features/classes/data/helpers/fan_out_helper.dart` con logs y TODO explícitos para Sprint 4.
- Suite de pruebas en `test/features/classes/data/repositories/class_repository_impl_test.dart` y `test/features/classes/presentation/cubit/` usando `bloc_test` + `mocktail`.
- Comandos QA ejecutados: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.
- Bloc observer global (`AppBlocObserver`) configurado en `main.dart` registrando métricas agregadas (`BlocMetricsRecorder`) para depurar cambios, transiciones y errores de todos los Cubits.

---

### Fase 5 · Integración en UI docente (1.5 días)
- Conectar `TeacherClassesListScreen` para leer `ClassCubit` mediante `BlocBuilder`.
- Integrar `CreateClassScreen` con formularios validados y uso de `CustomTextField`.
- Implementar `_EmptyState` reutilizable para listas sin datos.
- Mostrar errores con `SelectableText.rich` siguiendo las guías.
- Actualizar navegación (`GoRouter`) para recibir `classId` real y refrescar tras creación.

**Checklist**
- [ ] UI refleja estados loading/empty/error/success.
- [ ] Botón "Crear clase" deshabilitado mientras `ClassCubit` está cargando.
- [ ] `dart format` y `flutter analyze` ejecutados.

---

### Fase 6 · Flujo de unión de alumnos (1 día)
- Conectar `JoinClassScreen` con `MembershipCubit`.
- Validar códigos en frontend (6 caracteres alfanuméricos) antes de llamar al backend.
- Implementar pantalla de confirmación y actualización instantánea de la lista de clases (`context.read<ClassCubit>().refresh()`).
- Registrar métricas básicas (log() temporal) para depurar.

**Checklist**
- [ ] Formulario con `CustomTextField` y mensajes centralizados en `app_strings.dart`.
- [ ] Estados visuales coherentes (carga, éxito, error).
- [ ] Tests widget básicos para `JoinClassScreen`.

---

### Fase 7 · Gestión de alumnos y fan-out (1 día)
- Conectar `ManageStudentsScreen` para listar memberships con paginación básica.
- Implementar acciones de expulsar alumno y regenerar código de acceso.
- Documentar y crear `FanOutHelper` que reciba `(taskId, classId)` y devuelva assignments pendientes (solo stub con logs).
- Añadir métricas y TODO explícitos para Sprint 4.

**Checklist**
- [ ] Acciones protegidas con confirmaciones (`showDialog` M3).
- [ ] Helper documentado con ejemplo de uso.
- [ ] Tests de integración mínimos para expulsión/regeneración de código (mock services).

---

### Fase 8 · Testing, QA y documentación (0.5 día)
- Ejecutar `dart format .`, `flutter analyze`, `flutter test`.
- Actualizar `README.md` (sección estado del proyecto) y `Guia_Proyecto_PlayingTracker.md`.
- Completar este documento con métricas reales, fechas y resultados.
- Preparar changelog del sprint (`docs/sprints/SPRINT_3_IMPLEMENTACION.md` → Versión 1.0).

**Checklist**
- [ ] Comandos de QA ejecutados sin errores.
- [ ] Documentación sincronizada (README, guía, sprint doc, tablero).
- [ ] Capturas de pantalla nuevas si cambió la UI.

---

## 📅 Cronograma Tentativo

| Día | Actividad principal |
|-----|--------------------|
| Día 1 | Fase 1 + Fase 2 |
| Día 2 | Fase 3 (servicios + reglas) |
| Día 3 | Fase 3 (indices) + inicio Fase 4 |
| Día 4 | Fase 4 + inicio Fase 5 |
| Día 5 | Fase 5 completo |
| Día 6 | Fase 6 |
| Día 7 | Fase 7 |
| Día 8 | Fase 8 (QA + documentación) |

> El cronograma puede ajustarse si Sprint 2 requiere días adicionales de cierre. Cualquier cambio debe reflejarse en la sección de versiones de este documento.

---

## ✅ Checklist de cierre del Sprint

- [ ] `flutter analyze` sin errores.
- [ ] `flutter test` con cobertura ≥ 80% en lógica de clases.
- [ ] `dart format .` ejecutado.
- [ ] Documentación actualizada (README, guía, sprint).
- [ ] Capturas de pantalla nuevas (si aplica).
- [ ] Registro en `docs/sprints/SPRINT_3_IMPLEMENTACION.md` con resultados finales.

---

## 🧪 Comandos QA obligatorios (CI/CD-ready)

```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
```

> Estos comandos deben ejecutarse antes de cerrar cada fase y al término del sprint. Los resultados (especialmente coverage) deben adjuntarse en la sección de métricas.

---

## 🧱 Hooks obligatorios para dejar listos

- `class_repository_impl.dart`
  ```dart
  Future<void> fanOutTask(String taskId, String classId);
  ```
- `fan_out_helper.dart`
  ```dart
  Future<void> prepareFanOut(String taskId, String classId);
  Future<void> propagateToAssignments(String taskId, String classId);
  ```
- `membership_service.dart`
  ```dart
  Future<List<String>> getStudentsForClass(String classId);
  ```
- `class_service.dart`
  ```dart
  Future<List<MembershipModel>> listClassMembers(String classId);
  ```

Todos los métodos deben contener TODOs y logs si su implementación dependerá del Sprint 4.

---

## 🤖 Resumen técnico para agentes

- Mantener arquitectura limpia: `Domain → Repository → Service → Presentation`.
- Ningún Cubit realiza llamadas directas a Firestore; siempre usa repositorios.
- Los servicios (`class_service.dart`, `membership_service.dart`) no deben depender de Flutter; solo de `firebase_*`.
- Todos los servicios deben devolver modelos del dominio (o records tipados) en lugar de mapas dinámicos para garantizar type-safety extremo.
- Usar records para inputs y clases inmutables manuales (no `freezed`).
- UI debe apoyarse en `BlocBuilder`, `BlocListener` y widgets reutilizables (`CustomButton`, `CustomTextField`).
- Evitar crear métodos `_buildX`; usar widgets privados o archivos separados.
- Respetar strings centralizados en `app_strings.dart` y las reglas de capitalización.
- Solo se hidratarán cubits cuyos estados representen selección, filtros o contexto de UI; los cubits que reflejen datos provenientes de Firestore deben permanecer efímeros (recomendación Flutter 2025).
- No hidratar `MembershipCubit` (estado efímero); `ClassCubit` sí puede hidratarse si se justifica y se documenta.
- `watchTeacherClasses` y cualquier stream deben estar paginados en lotes de 20 elementos para evitar costos innecesarios y alinearse con las recomendaciones Firebase 2025; documentar cursor para futuras mejoras.

---

## 📚 Referencias cruzadas

- `docs/Guia_Proyecto_PlayingTracker.md` (roadmap y arquitectura).
- `docs/indexing/CURSOR_INDEXING_FIRESTORE_SCHEMA.md` (colecciones y reglas).
- `docs/components/COMPONENTS_GUIDE.md` (widgets reutilizables obligatorios).
- `.cursor/rules/flutter_style_rules.mdc` (estándares de código y UI).

---

## 📝 Historial de versiones

| Versión | Fecha | Descripción |
|---------|-------|-------------|
| 0.6 | 24/11/2025 | Fase 4 completada: `ClassRepositoryImpl`, Cubits y estados sealed, helper de fan-out, pruebas unitarias y QA (`dart format`, `flutter analyze`, `flutter test`). |
| 0.5 | 21/11/2025 | Fase 3 completada: helper de códigos, servicios de clases/membresías, reglas/índices de Firestore y suite de tests con `fake_cloud_firestore`. Documentación y README actualizados. |
| 0.4 | 21/11/2025 | Actualización del SDK completada: Flutter 3.35.6 → 3.38.2, Dart 3.9.2 → 3.10.0. Actualizado build_runner a 2.10.4. Dependencias discontinuadas (build_resolvers, build_runner_core) resueltas y eliminadas. Todas las verificaciones de calidad pasadas: `flutter analyze` (0 issues), `dart analyze --fatal-infos --fatal-warnings` (0 issues), `dart format .` (0 changed), `flutter test` (15 tests pasados). |
| 0.3 | 21/11/2025 | Fase 1 completada: kickoff y saneamiento técnico. Dependencias validadas y agregadas (uuid, bloc_test). Actualizadas restricciones de build_runner y json_serializable. Ejecutado flutter pub outdated/upgrade. Estado del sprint actualizado a "En progreso". |
| 0.2 | 20/11/2025 | Añadidos file plan, reglas de no rotura, hooks, QA y guía para agentes. |
| 0.1 | 20/11/2025 | Primera versión del plan del Sprint 3. |


