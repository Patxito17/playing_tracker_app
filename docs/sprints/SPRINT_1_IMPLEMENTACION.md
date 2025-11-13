# 📋 Implementación Sprint 1: Modelos de Dominio y Arquitectura de Datos

**Proyecto:** Playing Tracker - Sistema de Seguimiento de Estudio Musical
**Sprint:** 1 - Modelos de Dominio y Arquitectura de Datos
**Duración:** Noviembre 2025 (2 semanas)
**Estado:** 🚧 En Progreso
**Versión del documento:** 1.5
**Última actualización:** 13 de Noviembre 2025

---

## 🎯 Objetivo del Sprint

Establecer la **arquitectura de datos sólida** del proyecto mediante la implementación completa de modelos de dominio, enums de estado, validadores y configuración de Firestore. Este sprint prepara la base de datos, los modelos Dart con serialización JSON y las reglas de seguridad necesarias para el desarrollo de funcionalidades en sprints posteriores.

### Principios Fundamentales

- **Modelos inmutables:** Todos los modelos deben ser inmutables usando `freezed` o clases con `const` constructors
- **Serialización JSON:** Todos los modelos deben tener serialización JSON completa para Firestore
- **Validación de datos:** Validadores de dominio para asegurar integridad de datos
- **Seguridad primero:** Reglas de Firestore implementadas desde el inicio
- **Documentación completa:** Cada modelo y enum debe estar completamente documentado

---

## 📐 Alcance del Sprint

### ✅ Incluido en este Sprint

1. **Enums de Dominio**
   - `UserRole` - Roles de usuario (teacher, student)
   - `TaskStatus` - Estados de tarea (pending, in_progress, completed)
   - `SessionStatus` - Estados de sesión (idle, running, paused, completed)
   - `ClassStatus` - Estados de clase (active, inactive)
   - `AttachmentType` - Tipos de adjuntos (pdf, audio, link)

2. **Modelos de Dominio**
   - `TeacherModel` - Perfil de docente con serialización JSON
   - `StudentModel` - Perfil de alumno con agregados denormalizados
   - `ClassModel` - Definición de clase con código de acceso
   - `TaskModel` - Definición maestra de tarea con attachments
   - `AssignmentModel` - Progreso individual tarea-alumno con clave compuesta
   - `SessionModel` - Registro atómico de estudio con monthBucket
   - `MembershipModel` - Relación alumno-clase con denormalización
   - `AttachmentModel` - Modelo auxiliar para archivos adjuntos

3. **Validadores de Dominio**
   - Validadores de nombres (longitud mínima, solo letras)
   - Validadores de email (formato válido)
   - Validadores de códigos de acceso (6 caracteres alfanuméricos)
   - Validadores de duraciones (tiempo positivo)
   - Validadores de IDs (no vacíos)

4. **Configuración de Firestore**
   - Reglas de seguridad completas para todas las colecciones
   - Archivo `firestore.rules` con reglas optimizadas
   - Documentación de reglas de seguridad

5. **Índices Compuestos**
   - Índices para consultas frecuentes
   - Collection group indexes para sessions
   - Documentación de índices necesarios en `firestore.indexes.json`

6. **Documentación**
   - Documentación completa de cada modelo
   - Ejemplos de uso de modelos
   - Guía de validadores

### ❌ No Incluido en este Sprint

- Lógica de negocio (se implementará en Sprint 2+)
- Servicios de Firebase (se implementará en Sprint 2)
- Repositorios (se implementará en Sprint 2)
- Cubits/Blocs (se implementará en Sprint 2)
- Integración con UI (ya implementada en Sprint 0)
- Testing automatizado (se cubrirá en Sprint 7)

---

## 📦 Entregables

### Código Funcional

1. **Enums de Dominio**
   - `lib/features/auth/domain/enums/user_role.dart`
   - `lib/features/tasks/domain/enums/task_status.dart`
   - `lib/features/sessions/domain/enums/session_status.dart`
   - `lib/features/classes/domain/enums/class_status.dart`
   - `lib/features/tasks/domain/enums/attachment_type.dart`

2. **Modelos de Dominio**
   - `lib/features/auth/domain/models/teacher_model.dart`
   - `lib/features/auth/domain/models/student_model.dart`
   - `lib/features/classes/domain/models/class_model.dart`
   - `lib/features/classes/domain/models/membership_model.dart`
   - `lib/features/tasks/domain/models/task_model.dart`
   - `lib/features/tasks/domain/models/assignment_model.dart`
   - `lib/features/tasks/domain/models/attachment_model.dart`
   - `lib/features/sessions/domain/models/session_model.dart`

3. **Validadores**
   - `lib/core/utils/domain_validators.dart`

4. **Configuración de Firestore**
   - `firebase/firestore.rules` - Reglas de seguridad
   - `firebase/firestore.indexes.json` - Índices compuestos

5. **Dependencias Configuradas**
   - `pubspec.yaml` con dependencias necesarias:
     - `json_annotation: ^4.9.0`
     - `json_serializable: ^6.8.0`
     - `build_runner: ^2.4.13`
     - `cloud_firestore: ^5.5.3`
     - `freezed: ^2.5.7` (opcional, para modelos inmutables)

### Documentación

1. **Documentación de Modelos**
   - Comentarios dartdoc en cada modelo
   - Ejemplos de uso de cada modelo
   - Guía de validadores

2. **Documentación de Firestore**
   - Reglas de seguridad documentadas
   - Índices documentados con justificación

---

## 🏗️ Estructura Técnica Detallada

### Archivos a Crear

#### Enums de Dominio

```
lib/features/auth/domain/enums/
└── user_role.dart              # Enum: teacher, student

lib/features/tasks/domain/enums/
├── task_status.dart            # Enum: pending, in_progress, completed
└── attachment_type.dart        # Enum: pdf, audio, link

lib/features/sessions/domain/enums/
└── session_status.dart         # Enum: idle, running, paused, completed

lib/features/classes/domain/enums/
└── class_status.dart           # Enum: active, inactive
```

#### Modelos de Dominio

```
lib/features/auth/domain/models/
├── teacher_model.dart          # Modelo de docente con serialización JSON
└── student_model.dart          # Modelo de alumno con agregados denormalizados

lib/features/classes/domain/models/
├── class_model.dart            # Modelo de clase con código de acceso
└── membership_model.dart       # Modelo de membresía con denormalización

lib/features/tasks/domain/models/
├── task_model.dart             # Modelo de tarea con attachments
├── assignment_model.dart       # Modelo de asignación con clave compuesta
└── attachment_model.dart       # Modelo auxiliar para adjuntos

lib/features/sessions/domain/models/
└── session_model.dart          # Modelo de sesión con monthBucket
```

#### Validadores y Utilidades

```
lib/core/utils/
└── domain_validators.dart      # Validadores de dominio
```

#### Configuración de Firestore

```
firebase/
├── firestore.rules             # Reglas de seguridad de Firestore
└── firestore.indexes.json      # Índices compuestos
```

---

## 🔧 Setup y Configuración

### Requisitos Previos

- **Flutter SDK:** 3.x (Dart 3.9.2+)
- **Firebase CLI:** Instalado y configurado
- **Proyecto Firebase:** Creado en Firebase Console
- **IDE:** VS Code o Android Studio con extensiones de Flutter

### Comandos de Setup

```bash
# Verificar versión de Flutter
flutter --version

# Obtener dependencias
flutter pub get

# Generar código de serialización JSON
dart run build_runner build --delete-conflicting-outputs

# Formatear código
dart format .

# Analizar código
flutter analyze
```

### Dependencias a Añadir

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  cloud_firestore: ^5.5.3        # Base de datos Firestore
  firebase_core: ^3.8.1          # Core de Firebase

  # Serialización JSON
  json_annotation: ^4.9.0        # Anotaciones JSON

  # Utilidades
  equatable: ^2.0.7              # Comparación de objetos (ya existe)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0          # Linting (ya existe)
  build_runner: ^2.4.13          # Generación de código
  json_serializable: ^6.8.0      # Serialización JSON
```

### Configuración de Firebase

**Archivos de configuración necesarios:**
- `firebase/firestore.rules` - Reglas de seguridad
- `firebase/firestore.indexes.json` - Índices compuestos

**Nota:** Los archivos `google-services.json` y `GoogleService-Info.plist` se configurarán en Sprint 2 cuando se implemente la autenticación real.

---

## 📊 Estructura de Modelos de Datos

### Modelo de Datos Firestore

El proyecto utiliza **7 colecciones top-level** optimizadas para rendimiento y escalabilidad:

| Colección | Propósito | ID del Documento |
|-----------|-----------|------------------|
| `teachers` | Perfiles de docentes | UID de Firebase Auth |
| `students` | Perfiles de alumnos con agregados | UID de Firebase Auth |
| `classes` | Definiciones de clases/grupos | ID único global |
| `memberships` | Relación Alumno ↔ Clase (N:M) | ID único del membership |
| `tasks` | Definición maestra de tareas | ID único global |
| `assignments` | Progreso individual tarea-alumno | Clave compuesta: `${taskId}_${studentId}` |
| `sessions` | Registros atómicos de estudio | ID único de la sesión |

### Campos Comunes

Todos los modelos incluyen campos comunes:
- `id` - Identificador único
- `createdAt` - Timestamp de creación
- `updatedAt` - Timestamp de última actualización
- `isActive` - Estado activo/inactivo (donde aplique)

---

## ✅ Criterios de Aceptación

### Funcionales

1. **Modelos:**
   - ✅ Todos los modelos compilan sin errores
   - ✅ Serialización JSON funciona correctamente (toJson/fromJson)
   - ✅ Modelos son inmutables (const constructors o freezed)
   - ✅ Todos los campos tienen tipos correctos

2. **Enums:**
   - ✅ Todos los enums tienen valores correctos
   - ✅ Enums tienen serialización JSON (usando @JsonValue)
   - ✅ Enums están documentados

3. **Validadores:**
   - ✅ Validadores implementados para todos los campos críticos
   - ✅ Validadores retornan mensajes de error descriptivos
   - ✅ Validadores están documentados

4. **Firestore:**
   - ✅ Reglas de seguridad implementadas y validadas
   - ✅ Índices compuestos documentados
   - ✅ Reglas permiten acceso según roles correctamente

### Técnicos

1. **Código:**
   - ✅ `dart format` no requiere cambios
   - ✅ `flutter analyze` no muestra errores
   - ✅ `build_runner` genera código sin errores
   - ✅ El código sigue las convenciones establecidas

2. **Estructura:**
   - ✅ Todos los archivos están organizados según Feature-First Architecture
   - ✅ Modelos están en carpetas `domain/models/`
   - ✅ Enums están en carpetas `domain/enums/`

3. **Documentación:**
   - ✅ Cada modelo tiene comentarios dartdoc
   - ✅ Ejemplos de uso documentados
   - ✅ Reglas de Firestore documentadas

---

## 📋 Definición de Hecho (DoD)

El Sprint 1 se considera **completo** cuando se cumplen **TODOS** estos criterios:

1. ✅ **Código formateado:** `dart format .` ejecutado y código formateado
2. ✅ **Sin errores de análisis:** `flutter analyze` sin errores
3. ✅ **Serialización generada:** `build_runner` ejecutado sin errores
4. ✅ **Todos los modelos:** 8 modelos implementados con serialización JSON
5. ✅ **Todos los enums:** 5 enums implementados con serialización
6. ✅ **Validadores:** Validadores implementados para campos críticos
7. ✅ **Reglas Firestore:** Reglas de seguridad implementadas y validadas
8. ✅ **Índices:** Índices compuestos documentados
9. ✅ **Documentación:** Modelos y enums completamente documentados
10. ✅ **Trazabilidad:** Todo alineado con la Guía del Proyecto

---

## 🎯 Tareas Detalladas

### Fase 1: Enums de Dominio (Día 1) ✅ COMPLETADA

- [x] Crear `lib/features/auth/domain/enums/user_role.dart`
  - [x] Enum `UserRole` con valores: `teacher`, `student`
  - [x] Serialización JSON con `@JsonValue`
  - [x] Documentación completa
  - [x] Método helper `displayName` para UI
- [x] Crear `lib/features/tasks/domain/enums/task_status.dart`
  - [x] Enum `TaskStatus` con valores: `pending`, `inProgress`, `completed`
  - [x] Serialización JSON con `@JsonValue`
  - [x] Documentación completa
  - [x] Métodos helper `displayName` y `color` para UI
- [x] Crear `lib/features/tasks/domain/enums/attachment_type.dart`
  - [x] Enum `AttachmentType` con valores: `pdf`, `audio`, `link`
  - [x] Serialización JSON con `@JsonValue`
  - [x] Documentación completa
  - [x] Métodos helper `displayName` e `icon` para UI
- [x] Crear `lib/features/sessions/domain/enums/session_status.dart`
  - [x] Enum `SessionStatus` con valores: `idle`, `running`, `paused`, `completed`
  - [x] Serialización JSON con `@JsonValue`
  - [x] Documentación completa
  - [x] Métodos helper `displayName` y `color` para UI
- [x] Crear `lib/features/classes/domain/enums/class_status.dart`
  - [x] Enum `ClassStatus` con valores: `active`, `inactive`
  - [x] Serialización JSON con `@JsonValue`
  - [x] Documentación completa
  - [x] Método helper `displayName` para UI
- [x] Ejecutar `flutter analyze` y corregir errores
- [x] Ejecutar `dart format .`

### Fase 2: Modelos de Dominio (Días 2-5) ✅ COMPLETADA

- [x] Crear `lib/core/utils/timestamp_converter.dart`
  - [x] Converter personalizado para serializar Timestamp de Firestore
  - [x] Manejo de diferentes formatos de entrada
  - [x] Documentación completa
- [x] Crear `lib/features/auth/domain/models/teacher_model.dart`
  - [x] Modelo `TeacherModel` con campos: id, firstName, lastName, email, createdAt, updatedAt, isActive
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
  - [x] Getter `fullName` para nombre completo
- [x] Crear `lib/features/auth/domain/models/student_model.dart`
  - [x] Modelo `StudentModel` con campos: id, firstName, lastName, email, createdAt, updatedAt, isActive
  - [x] Agregados denormalizados: totalSessionsCount, totalDurationLogged, lastSessionDate
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
  - [x] Getter `fullName` para nombre completo
- [x] Crear `lib/features/classes/domain/models/class_model.dart`
  - [x] Modelo `ClassModel` con campos: id, name, description, ownerTeacherId, accessCode, createdAt, updatedAt, isActive
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
- [x] Crear `lib/features/classes/domain/models/membership_model.dart`
  - [x] Modelo `MembershipModel` con campos: id, classId, studentId, teacherId, className, joinedAt, isActive
  - [x] Campos denormalizados: teacherId, className
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
- [x] Crear `lib/features/tasks/domain/models/attachment_model.dart`
  - [x] Modelo `AttachmentModel` con campos: name, url, type
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
- [x] Crear `lib/features/tasks/domain/models/task_model.dart`
  - [x] Modelo `TaskModel` con campos: id, title, description, createdBy, durationSuggested, attachments, createdAt, updatedAt, dueDate, isActive
  - [x] Lista de `AttachmentModel` para attachments
  - [x] Serialización JSON con `json_serializable` y `explicitToJson: true`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
  - [x] Getter `durationFormatted` para formato legible
- [x] Crear `lib/features/tasks/domain/models/assignment_model.dart`
  - [x] Modelo `AssignmentModel` con campos: id (clave compuesta), taskId, studentId, teacherId, status, assignedAt, completedAt, sessionsCount, totalDurationLogged, lastSessionDate
  - [x] Clave compuesta: `${taskId}_${studentId}`
  - [x] Campos denormalizados: teacherId
  - [x] Contadores de progreso: sessionsCount, totalDurationLogged, lastSessionDate
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
  - [x] Método estático `generateId` para crear IDs compuestos
  - [x] Getters de estado: `isCompleted`, `isInProgress`, `isPending`
- [x] Crear `lib/features/sessions/domain/models/session_model.dart`
  - [x] Modelo `SessionModel` con campos: id, studentId, taskId, teacherId, startTime, endTime, totalDuration, pausedDuration, dateLogged, monthBucket, notes, createdAt
  - [x] Campo `monthBucket` para queries de métricas (formato: "YYYY-MM")
  - [x] Campos denormalizados: teacherId
  - [x] Serialización JSON con `json_serializable`
  - [x] Constructor con `const` para inmutabilidad
  - [x] Métodos `copyWith` para crear copias modificadas
  - [x] Documentación completa con ejemplos
  - [x] Método estático `generateMonthBucket` para crear monthBucket
  - [x] Getters formatados: `durationFormatted`, `pausedDurationFormatted`
- [x] Ejecutar `dart run build_runner build --delete-conflicting-outputs`
- [x] Ejecutar `flutter analyze` y corregir errores
- [x] Ejecutar `dart format .`

### Fase 3: Validadores de Dominio (Día 6) ✅ COMPLETADA

- [x] Crear `lib/core/utils/domain_validators.dart`
  - [x] Función `validateName(String name)` - Longitud mínima 3, solo letras y espacios
  - [x] Función `validateEmail(String email)` - Formato de email válido
  - [x] Función `validateAccessCode(String code)` - 6 caracteres alfanuméricos
  - [x] Función `validateDuration(int duration)` - Duración positiva en segundos
  - [x] Función `validateId(String id)` - ID no vacío
  - [x] Función `validateDescription(String? description)` - Descripción opcional, máximo 1000 caracteres
  - [x] Función `validateUrl(String url)` - URL válida para attachments
  - [x] Función `validateTitle(String title)` - Títulos de tareas (3-100 caracteres)
  - [x] Todas las funciones retornan `String?` (null si válido, mensaje de error si inválido)
  - [x] Documentación completa con ejemplos
- [x] Ejecutar `flutter analyze` y corregir errores
- [x] Ejecutar `dart format .`

### Fase 4: Configuración de Firestore (Día 7) ✅ COMPLETADA

- [x] Crear carpeta `firebase/` en la raíz del proyecto
- [x] Crear `firebase.json` con configuración de Firebase CLI
- [x] Crear `firebase/firestore.rules`
  - [x] Reglas para colección `teachers` (solo lectura/escritura del propio perfil)
  - [x] Reglas para colección `students` (solo lectura/escritura del propio perfil)
  - [x] Reglas para colección `classes` (lectura para autenticados, **creación solo para teachers**)
  - [x] Reglas para colección `memberships` (lectura para teacher/student relacionados, escritura solo para teacher)
  - [x] Reglas para colección `tasks` (lectura para autenticados, **creación solo para teachers**)
  - [x] Reglas para colección `assignments` (lectura para teacher/student relacionados, escritura para teacher o student)
  - [x] Reglas para colección `sessions` (creación solo por student con validación, lectura para teacher/student relacionados, sin update/delete)
  - [x] Funciones helper: `isAuth()`, `isOwner()`, `isTeacher()`, `isStudent()`
  - [x] Validación de roles mediante verificación de existencia en colecciones
  - [x] Separación granular de permisos (create/read/update/delete)
  - [x] Validación de campos obligatorios en operaciones create
  - [x] Documentación extensa de reglas en comentarios
- [x] Crear `firebase/firestore.indexes.json` (vacío, se llenará en Fase 5)
- [x] Validar reglas con Firebase CLI: `firebase deploy --only firestore:rules --dry-run` ✅
- [x] Validar código con `flutter analyze` (0 issues) ✅

### Fase 5: Índices Compuestos (Día 8) ✅ COMPLETADA

- [x] Crear `firebase/firestore.indexes.json`
  - [x] Índice para `memberships` por `classId` y `isActive`
  - [x] Índice para `memberships` por `studentId` y `isActive`
  - [x] Índice para `assignments` por `taskId` y `status`
  - [x] Índice para `assignments` por `studentId` y `status`
  - [x] Índice para `assignments` por `teacherId` y `status`
  - [x] Índice para `sessions` por `studentId` y `dateLogged`
  - [x] Índice para `sessions` por `taskId` y `dateLogged`
  - [x] Índice para `sessions` por `teacherId` y `dateLogged`
  - [x] Collection group index para `sessions` por `monthBucket` y `dateLogged`
  - [x] Índice para `tasks` por `createdBy` y `isActive`
  - [x] Índice para `classes` por `ownerTeacherId` y `isActive`
  - [x] Documentación de cada índice con justificación
- [x] Documentar índices en el documento del sprint

### Fase 6: Documentación y Pruebas (Día 9) 📅

- [ ] Revisar documentación de todos los modelos
  - [ ] Comentarios dartdoc completos
  - [ ] Ejemplos de uso en comentarios
  - [ ] Descripción de campos denormalizados
- [ ] Revisar documentación de todos los enums
  - [ ] Comentarios dartdoc completos
  - [ ] Descripción de cada valor
- [ ] Revisar documentación de validadores
  - [ ] Comentarios dartdoc completos
  - [ ] Ejemplos de uso
- [ ] Crear sección de ejemplos de uso en el documento del sprint
- [ ] Actualizar README.md con información del Sprint 1
- [ ] Ejecutar `flutter analyze` y verificar 0 errores
- [ ] Ejecutar `dart format .` y verificar 0 cambios
- [ ] Ejecutar `dart run build_runner build --delete-conflicting-outputs` y verificar éxito

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Complejidad de Serialización JSON

**Problema:** Errores en serialización JSON con Timestamp de Firestore.

**Mitigación:**
- Usar `@JsonKey` con converters personalizados para Timestamp
- Crear converters reutilizables para Timestamp
- Probar serialización con datos reales de Firestore

### Riesgo 2: Reglas de Seguridad Incorrectas

**Problema:** Reglas de Firestore demasiado permisivas o restrictivas.

**Mitigación:**
- Revisar reglas con Firebase Emulator antes de deploy
- Documentar cada regla con su propósito
- Probar reglas con diferentes roles de usuario

### Riesgo 3: Índices Faltantes

**Problema:** Consultas lentas por falta de índices.

**Mitigación:**
- Documentar todas las consultas planificadas
- Crear índices para todas las consultas frecuentes
- Usar Firebase Console para identificar índices faltantes

### Riesgo 4: Modelos Incompatibles con Firestore

**Problema:** Tipos de Dart no compatibles con tipos de Firestore.

**Mitigación:**
- Usar tipos compatibles (String, int, bool, Timestamp)
- Crear converters para tipos complejos
- Probar lectura/escritura con Firestore Emulator

---

## 🧪 Plan de Pruebas

### Pruebas Manuales

1. **Serialización JSON:**
   - Probar `toJson()` de cada modelo
   - Probar `fromJson()` de cada modelo
   - Verificar que los datos se serializan correctamente

2. **Validadores:**
   - Probar cada validador con datos válidos
   - Probar cada validador con datos inválidos
   - Verificar mensajes de error descriptivos

3. **Reglas de Firestore:**
   - Probar lectura/escritura con Firebase Emulator
   - Probar con diferentes roles de usuario
   - Verificar que las reglas funcionan correctamente

### Validación de Código

- Ejecutar `flutter analyze` y verificar 0 errores
- Ejecutar `dart format .` y verificar 0 cambios
- Ejecutar `build_runner` y verificar generación exitosa
- Verificar que todos los modelos compilan sin errores

---

## 📚 Referencias y Recursos

### Documentación Oficial

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [JSON Serialization in Dart](https://dart.dev/guides/json)
- [json_serializable Package](https://pub.dev/packages/json_serializable)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

### Guías del Proyecto

- [Guía del Proyecto Playing Tracker](../Guia_Proyecto_PlayingTracker.md)
- [Sprint 0 - Implementación](SPRINT_0_IMPLEMENTACION.md)

---

## 🔄 Próximos Pasos (Sprint 2)

Una vez completado el Sprint 1, el siguiente sprint se enfocará en:

- Implementación de Firebase Authentication
- Servicios de Firestore para CRUD de modelos
- Repositorios para orquestación de servicios
- Cubits para gestión de estado
- Integración con UI existente

**Nota:** El Sprint 2 utilizará los modelos y validadores creados en este sprint para implementar la lógica de negocio.

---

## ✅ Checklist Final del Sprint

**Progreso General: 83% (5/6 fases completadas) ✅**

### Fase 1: Enums de Dominio ✅
- [x] Todos los enums creados (5 enums)
- [x] Serialización JSON implementada
- [x] Documentación completa
- [x] `flutter analyze` sin errores
- [x] Código formateado con `dart format`

### Fase 2: Modelos de Dominio ✅
- [x] Todos los modelos creados (8 modelos + TimestampConverter)
- [x] Serialización JSON implementada
- [x] `build_runner` ejecutado exitosamente (8 archivos .g.dart generados)
- [x] Documentación completa
- [x] `flutter analyze` sin errores
- [x] Código formateado con `dart format` (9 archivos formateados)

### Fase 3: Validadores de Dominio ✅
- [x] Validadores implementados (8 funciones de validación)
- [x] Documentación completa
- [x] `flutter analyze` sin errores
- [x] Código formateado con `dart format`

### Fase 4: Configuración de Firestore ✅
- [x] Reglas de seguridad implementadas con validación de roles
- [x] Reglas validadas con Firebase CLI (dry-run exitoso)
- [x] Documentación de reglas completa (comentarios extensos)
- [x] `firebase/firestore.rules` creado con funciones helper
- [x] `firebase.json` creado con configuración
- [x] `firebase/firestore.indexes.json` creado

### Fase 5: Índices Compuestos ✅
- [x] Índices documentados
- [x] `firebase/firestore.indexes.json` creado
- [x] Documentación de índices completa

### Fase 6: Documentación y Pruebas 📅
- [ ] Documentación de modelos revisada
- [ ] Documentación de enums revisada
- [ ] Documentación de validadores revisada
- [ ] README actualizado
- [ ] Ejemplos de uso documentados
- [ ] `flutter analyze` sin errores (0 issues)
- [ ] Código formateado con `dart format`
- [ ] `build_runner` ejecutado exitosamente

---

## 📝 Historial de Cambios

### Versión 1.5 - 13 de Noviembre 2025
- ✅ **Fase 5 COMPLETADA:** Índices Compuestos de Firestore
- ✅ Archivo `firebase/firestore.indexes.json` creado con 11 índices compuestos optimizados
- ✅ **Índices implementados:**
  - **Memberships (2 índices):** `classId+isActive`, `studentId+isActive`
  - **Assignments (3 índices):** `taskId+status`, `studentId+status`, `teacherId+status`
  - **Sessions (4 índices):** `studentId+dateLogged DESC`, `taskId+dateLogged DESC`, `teacherId+dateLogged DESC`, `monthBucket+dateLogged DESC` (collection group)
  - **Tasks (1 índice):** `createdBy+isActive`
  - **Classes (1 índice):** `ownerTeacherId+isActive`
- ✅ **Justificación documentada** para cada índice:
  - Índices de memberships optimizan consultas de alumnos por clase y clases por alumno
  - Índices de assignments permiten filtrado eficiente por estado (pending/in_progress/completed)
  - Índices de sessions ordenados DESC para mostrar historial más reciente primero
  - Collection group index permite métricas mensuales agregadas con `monthBucket`
  - Índices de tasks y classes filtran elementos activos del teacher
- ✅ **Validación exitosa:**
  - `firebase deploy --only firestore:indexes --dry-run` ✅ Compilación exitosa
  - `flutter analyze` ✅ 0 issues
- ✅ Progreso del sprint actualizado a 83% (5/6 fases completadas)

### Versión 1.4 - 13 de Noviembre 2025
- ✅ **Fase 4 COMPLETADA:** Configuración de Firestore
- ✅ **Firebase CLI** configurado en el proyecto
- ✅ Archivos de configuración creados:
  - `firebase.json` - Configuración principal de Firebase CLI
  - `firebase/firestore.rules` - Reglas de seguridad completas (227 líneas)
  - `firebase/firestore.indexes.json` - Archivo de índices (se llenará en Fase 5)
- ✅ **Reglas de seguridad implementadas** para las 7 colecciones:
  - `teachers` - Solo el propio docente puede leer/escribir su perfil
  - `students` - Solo el propio alumno puede leer/escribir su perfil
  - `classes` - Lectura para autenticados, **creación solo para teachers**
  - `memberships` - Lectura para relacionados, escritura solo para teacher
  - `tasks` - Lectura para autenticados, **creación solo para teachers**
  - `assignments` - Lectura para relacionados, escritura para teacher/student
  - `sessions` - Creación solo por students, lectura para relacionados, inmutables
- ✅ **Funciones helper** implementadas:
  - `isAuth()` - Verificación de autenticación
  - `isOwner(userId)` - Verificación de propiedad
  - `isTeacher()` - Validación de rol docente (exists en colección teachers)
  - `isStudent()` - Validación de rol alumno (exists en colección students)
- ✅ **Mejoras de seguridad**:
  - Separación granular de permisos (create/read/update/delete)
  - Validación de campos obligatorios en operaciones create
  - Validación de roles mediante verificación de existencia
  - Inmutabilidad de sesiones (no update/delete)
- ✅ **Validación exitosa**:
  - `firebase deploy --only firestore:rules --dry-run` ✅ Compilación exitosa
  - `flutter analyze` ✅ 0 issues
- ✅ Progreso del sprint actualizado a 67% (4/6 fases completadas)

### Versión 1.3 - 13 de Noviembre 2025
- ✅ **Fase 3 COMPLETADA:** Validadores de Dominio
- ✅ **BUG CORREGIDO:** Campo `pausedDuration` en SessionModel ahora tiene default value = 0 (consistente con otros modelos)
- ✅ **BUG CORREGIDO:** TimestampConverter.fromJson ahora tiene manejo seguro de null (evita `null as int` en runtime)
- ✅ Archivo `lib/core/utils/domain_validators.dart` creado con 8 funciones de validación:
  - `validateName` - Valida nombres con mínimo 3 caracteres, solo letras, espacios, guiones y apóstrofes
  - `validateEmail` - Valida formato de email con RegExp, máximo 254 caracteres
  - `validateAccessCode` - Valida códigos de 6 caracteres alfanuméricos
  - `validateDuration` - Valida duraciones en segundos (valores positivos)
  - `validateId` - Valida IDs no vacíos
  - `validateDescription` - Valida descripciones opcionales con máximo 1000 caracteres
  - `validateUrl` - Valida URLs con Uri.tryParse (requiere esquema y host)
  - `validateTitle` - Valida títulos de tareas (3-100 caracteres)
- ✅ Todas las funciones incluyen:
  - Documentación dartdoc completa en español
  - Ejemplos de uso detallados
  - Mensajes de error descriptivos
  - Validación de null y strings vacíos
- ✅ `build_runner` ejecutado exitosamente después del fix del bug
- ✅ `flutter analyze` sin errores (0 issues)
- ✅ Código formateado con `dart format` (1 archivo formateado)
- ✅ Progreso del sprint actualizado a 50% (3/6 fases completadas)

### Versión 1.2 - 13 de Noviembre 2025
- ✅ **Fase 2 COMPLETADA:** Modelos de Dominio
- ✅ TimestampConverter implementado para serialización de Timestamp de Firestore
- ✅ Implementados 8 modelos con serialización JSON:
  - TeacherModel (con getter fullName)
  - StudentModel (con agregados denormalizados y getter fullName)
  - ClassModel
  - MembershipModel (con campos denormalizados)
  - AttachmentModel
  - TaskModel (con lista de attachments y getter durationFormatted)
  - AssignmentModel (con clave compuesta, método generateId y getters de estado)
  - SessionModel (con monthBucket, método generateMonthBucket y getters formatados)
- ✅ Todos los modelos incluyen:
  - Serialización JSON completa con json_serializable
  - Constructores const para inmutabilidad
  - Métodos copyWith para crear copias modificadas
  - Operadores == y hashCode
  - Método toString descriptivo
  - Documentación dartdoc completa en español
- ✅ `dart run build_runner build` ejecutado exitosamente (8 archivos .g.dart generados)
- ✅ `flutter analyze` sin errores (0 issues)
- ✅ Código formateado con `dart format` (9 archivos formateados)
- ✅ Estructura de carpetas domain/models creada en cada feature

### Versión 1.1 - 13 de Noviembre 2025
- ✅ **Fase 1 COMPLETADA:** Enums de Dominio
- ✅ Implementados 5 enums con serialización JSON: UserRole, TaskStatus, AttachmentType, SessionStatus, ClassStatus
- ✅ Todos los enums incluyen métodos helper para UI (displayName, color, icon según corresponda)
- ✅ Documentación dartdoc completa en español para cada enum
- ✅ Dependencias añadidas: json_annotation, json_serializable, build_runner, cloud_firestore, firebase_core
- ✅ `flutter pub get` ejecutado exitosamente
- ✅ `flutter analyze` sin errores (0 issues)
- ✅ Código formateado con `dart format` (5 archivos formateados)
- ✅ Estructura de carpetas domain/enums creada en cada feature

### Versión 1.0 - 7 de Noviembre 2025
- Documento inicial creado con planificación completa del Sprint 1
- 6 fases definidas con tareas detalladas
- Estructura de modelos y enums definida
- Criterios de aceptación y DoD establecidos

---

**Última actualización:** 13 de Noviembre 2025
**Estado:** 🚧 En Progreso
**Progreso:** 83% (5/6 fases) ✅
**Responsable:** Equipo de desarrollo Playing Tracker

