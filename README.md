# 🎵 Playing Tracker

**Sistema de Seguimiento de Estudio Musical**

![Project Status](https://img.shields.io/badge/Estado-Sprint%205%20Completado-success)
![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart Version](https://img.shields.io/badge/Dart-3.x-blue)

**Playing Tracker** es una aplicación móvil multiplataforma desarrollada con Flutter y Firebase, diseñada para digitalizar y objetivar el seguimiento del estudio instrumental fuera del aula. Permite a los docentes asignar tareas específicas y a los alumnos registrar el tiempo dedicado a cada una de ellas de forma precisa y honesta.

---

## 🚀 Características Principales

### 👨‍🎓 Módulo de Estudiante
- **Gestión de Clases:** Unirse a clases mediante códigos de acceso únicos generados por el docente.
- **Tareas Asignadas:** Visualización de todas las tareas pendientes y sus objetivos de práctica.
- **Cronómetro Inteligente:** 
  - Registro de tiempo de práctica en tiempo real.
  - **Auto-Pausa en Background:** Si el alumno sale de la app, el cronómetro se pausa automáticamente para mayor seguridad y precisión.
  - Reanudación manual al volver a la app.
- **Historial de Práctica:** Registro detallado de todas las sesiones realizadas, incluyendo fechas, duraciones y notas.

### 👩‍🏫 Módulo de Docente
- **Gestión de Clases:** Crear, editar y archivar clases grupales.
- **Gestión de Alumnos:** Administración de miembros, códigos de invitación y monitoreo de actividad.
- **Asignación de Tareas:** Creación de tareas con títulos, descripciones y tiempos sugeridos.
- **Seguimiento:** (En desarrollo) Visualización del tiempo total de estudio por alumno y clase.

### 🔐 Seguridad y Tecnología
- **Autenticación Robusta:** Login/Registro con Email y Contraseña mediante Firebase Auth.
- **Roles Definidos:** Interfaces y permisos granulares separados para Docentes y Alumnos.
- **Diseño Moderno:** Interfaz basada enteramente en **Material Design 3** con soporte para tema claro y oscuro.
- **Arquitectura Feature-First:** Código organizado, testeado y escalable.

---

## 📊 Estado del Proyecto

**Estado Actual:** Sprint 5 Completado (Core Loop Operativo) ✅
**Última actualización:** 24 de Enero 2026

### Roadmap de Desarrollo

```text
Sprint 0: ████████████████████ 100% ✅ Diseño UI/UX
Sprint 1: ████████████████████ 100% ✅ Modelos y Arquitectura
Sprint 2: ████████████████████ 100% ✅ Autenticación
Sprint 3: ████████████████████ 100% ✅ Clases y Membresías
Sprint 4: ████████████████████ 100% ✅ Tareas y Asignaciones
Sprint 5: ████████████████████ 100% ✅ Cronómetro y Sesiones
Sprint 6: ░░░░░░░░░░░░░░░░░░░░ 0%  📅 Estadísticas (Planificación)
Sprint 7: ░░░░░░░░░░░░░░░░░░░░ 0%  📅 Testing y Optimización
```

---

## 📚 Documentación

- 📄 **[Guía Maestra del Proyecto](docs/Guia_Proyecto_PlayingTracker.md)** - Roadmap y Visión General.
- 🎨 **[Guía de Componentes UI](docs/components/COMPONENTS_GUIDE.md)** - Documentación de widgets reutilizables.
- 📙 **[Reglas de Estilo](.cursor/rules/flutter_style_rules.mdc)** - Convenciones de código.

### Implementación por Sprints
- [Sprint 0: Diseño UI/UX](docs/sprints/SPRINT_0_IMPLEMENTACION.md)
- [Sprint 1: Datos y Modelos](docs/sprints/SPRINT_1_IMPLEMENTACION.md)
- [Sprint 2: Autenticación](docs/sprints/SPRINT_2_IMPLEMENTACION.md)
- [Sprint 3: Clases y Miembros](docs/sprints/SPRINT_3_IMPLEMENTACION.md)
- [Sprint 4: Tareas y Asignaciones](docs/sprints/SPRINT_4_IMPLEMENTACION.md)
- [Sprint 5: Cronómetro y Sesiones](docs/sprints/SPRINT_5_IMPLEMENTACION.md)
- [Sprint 6: Estadísticas y Dashboards (Draft)](docs/sprints/SPRINT_6_IMPLEMENTACION.md)

---

## 🛠️ Stack Tecnológico

- **Frontend:** Flutter 3.x / Dart 3.x.
- **Backend:** Firebase (Authentication, Cloud Firestore).
- **Gestión de Estado:** flutter_bloc (Cubit Pattern).
- **Navegación:** go_router (Guardas reactivas por rol).
- **Testing:** flutter_test, mocktail, fake_cloud_firestore.

---

## 🔧 Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone <repository-url>
   cd playing_tracker
   ```

2. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```

3. **Generar código (JSON serialization):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Ejecutar tests:**
   ```bash
   flutter test
   ```

5. **Lanzar la app:**
   ```bash
   flutter run
   ```

> **Nota:** Se requieren los archivos de configuración de Firebase (`google-services.json` / `GoogleService-Info.plist`) para la conexión con el backend.

---

## 📁 Estructura del Proyecto

```text
lib/
├── config/                 # Temas y Rutas
├── core/                   # Constantes, Utils y Extensions
├── features/               # Funcionalidades por módulos
│   ├── auth/              # Login y Registro
│   ├── classes/           # Clases y Membresías
│   ├── tasks/             # Gestión de Tareas
│   ├── sessions/          # Cronómetro e Historial
│   ├── statistics/        # (Próximamente)
│   └── settings/          # Ajustes de la App
└── shared/                 # Widgets y componentes comunes
```

---

## 📝 Licencia

Este proyecto es privado y para fines educativos. Todos los derechos reservados.
