# Resumen Ejecutivo del Proyecto - Playing Tracker

**Última actualización:** 24 de Noviembre 2025
**Estado:** Sprint 3 - Sistema de Clases (Fase 5 completada)
**Versión:** 1.2

---

## Descripción General

**Playing Tracker** es una aplicación móvil multiplataforma (Flutter + Firebase) orientada al ámbito educativo musical. Su objetivo es **digitalizar y objetivar el seguimiento del estudio instrumental** fuera del aula, permitiendo a los docentes asignar tareas específicas y a los alumnos registrar el tiempo dedicado a cada una de ellas.

### Propósito Principal
- Asignación de tareas de estudio por parte de docentes
- Registro de tiempo de práctica mediante cronómetro persistente
- Generación de estadísticas visuales de progreso
- Seguimiento objetivo del estudio fuera del aula

---

## Objetivos del Proyecto

### Objetivo General
Desarrollar una app móvil multiplataforma (iOS y Android) que permita asignar tareas de estudio, medir el tiempo real de práctica y generar estadísticas de progreso.

### Objetivos Específicos
1. Autenticación con Firebase distinguiendo roles de **Docente** y **Alumno**
2. Interfaces intuitivas para asignación de tareas (Docente) y ejecución/registro (Alumno)
3. Cronómetro persistente para registrar tiempo de práctica incluso en segundo plano
4. Almacenamiento y procesamiento de datos en **Firestore**
5. Estadísticas visuales (diarias, semanales, mensuales y anuales)

---

## Enfoque de Desarrollo

- **Diseño primero:** Implementación de UI/UX completa antes de la lógica
- **Arquitectura escalable:** Base de datos NoSQL optimizada con 7 colecciones top-level
- **Desarrollo iterativo:** Sprints enfocados en funcionalidades completas
- **Material Design 3:** Experiencia de usuario moderna y accesible
- **Seguridad robusta:** Reglas de Firestore optimizadas para roles docente/alumno

---

## Estado Actual del Proyecto

### Sprint Actual: Sprint 3 - Sistema de Clases y Membresías
**Estado:** Fase 5 completada (UI docente integrada)
**Duración:** Noviembre 2025

**Completado recientemente:**
- `lib/features/classes/presentation/screens/teacher_classes_list_screen.dart` consume `ClassCubit` (loading/empty/success/error, `_EmptyState` reutilizable, `SelectableText.rich` para errores).
- `lib/features/classes/presentation/screens/create_class_screen.dart` validado con `CustomTextField`, `CreateClassInput`, desactivación de botones y navegación segura (`Navigator.canPop`).
- Nuevos strings operativos en `lib/core/constants/app_strings.dart` (mensajes de clases/membresías, estados activos/archivados).
- Tests widget dedicados: `test/features/classes/presentation/screens/create_class_screen_test.dart` y `teacher_classes_list_screen_test.dart` (GoRouter embebido).
- QA ejecutado: `dart format .`, `flutter analyze`, `flutter test`.

**En progreso (Sprint 3):**
- Flujo de unión de alumnos (`JoinClassScreen` + `MembershipCubit`)
- Gestión de alumnos/fan-out inicial (Fase 7)

**Siguientes sprints:** Tareas/Asignaciones, Cronómetro, Estadísticas, QA final

---

## Arquitectura General

### Stack Tecnológico
- **Frontend:** Flutter 3.38.x (Dart 3.10.x)
- **Backend:** Firebase
  - Firebase Authentication (Email/Password)
  - Cloud Firestore (Base de datos NoSQL)
  - Firebase Storage (Próximamente)
  - Cloud Functions (Próximamente)
- **Gestión de Estado:** flutter_bloc con Cubit
- **Navegación:** go_router
- **Diseño:** Material Design 3

### Estructura del Proyecto
```
lib/
├── core/              # Código compartido (constants, extensions, utils)
├── config/            # Configuración (theme, routes)
├── features/          # Features por funcionalidad (auth, classes, tasks, etc.)
│   └── [feature]/
│       ├── domain/    # Modelos y enums
│       ├── data/      # Services y repositories
│       └── presentation/  # Cubits, screens, widgets
└── shared/            # Widgets compartidos
```

### Base de Datos
- **7 colecciones top-level** en Firestore:
  - `teachers` - Perfiles de docentes
  - `students` - Perfiles de alumnos con agregados
  - `classes` - Definiciones de clases/grupos
  - `memberships` - Relación Alumno ↔ Clase (N:M)
  - `tasks` - Definición maestra de tareas
  - `assignments` - Progreso individual tarea-alumno
  - `sessions` - Registros atómicos de estudio

---

## Funcionalidades Principales

### Módulo Docente
- Creación y gestión de clases
- Asignación de tareas a alumnos
- Visualización de tiempo de estudio por alumno
- Estadísticas y dashboards de progreso
- Gestión de alumnos por clase

### Módulo Alumno
- Visualización de clases a las que pertenece
- Lista de tareas asignadas
- Cronómetro para registrar tiempo de estudio
- Historial de sesiones de práctica
- Estadísticas personales de progreso

---

## Referencias Principales

- **Guía completa del proyecto:** [Guia_Proyecto_PlayingTracker.md](./Guia_Proyecto_PlayingTracker.md)
- **Sprint 3 detalle:** [sprints/SPRINT_3_IMPLEMENTACION.md](../sprints/SPRINT_3_IMPLEMENTACION.md)
- **Sprint 0 detallado:** [sprints/SPRINT_0_IMPLEMENTACION.md](./sprints/SPRINT_0_IMPLEMENTACION.md)
- **Arquitectura técnica:** [CURSOR_INDEXING_ARCHITECTURE.md](./CURSOR_INDEXING_ARCHITECTURE.md)
- **Referencias técnicas:** [CURSOR_INDEXING_TECHNICAL_REFERENCES.md](./CURSOR_INDEXING_TECHNICAL_REFERENCES.md)
- **Esquema Firestore:** [CURSOR_INDEXING_FIRESTORE_SCHEMA.md](./CURSOR_INDEXING_FIRESTORE_SCHEMA.md)

---

## Notas Importantes para Desarrollo

1. **Siempre usar Material Design 3** - Todos los componentes deben seguir las especificaciones M3
2. **Feature-First Architecture** - Organizar código por funcionalidad, no por tipo técnico
3. **Cubit como sistema principal** - Usar Cubit para gestión de estado (más simple que Bloc)
4. **Comentarios en español** - Todo el código debe tener comentarios descriptivos en español
5. **Diseño primero** - Completar UI antes de implementar lógica de negocio
6. **Accesibilidad desde el inicio** - Asegurar contraste mínimo 4.5:1 y soporte para TalkBack/VoiceOver
7. **Servicios verificados** - Reutilizar `ClassService`/`MembershipService` antes de tocar Firestore directo; tests disponibles como referencia

