# 🎵 Playing Tracker

**Sistema de Seguimiento de Estudio Musical**

Playing Tracker es una aplicación móvil multiplataforma desarrollada con Flutter y Firebase, diseñada para digitalizar y objetivar el seguimiento del estudio instrumental fuera del aula. Permite a los docentes asignar tareas específicas y a los alumnos registrar el tiempo dedicado a cada una de ellas.

---

## 📋 Descripción

Playing Tracker facilita la gestión del estudio musical mediante:

- **Para Docentes:**
  - Creación y gestión de clases
  - Asignación de tareas específicas a estudiantes
  - Visualización de estadísticas de progreso de los alumnos
  - Seguimiento del tiempo de estudio por tarea

- **Para Estudiantes:**
  - Visualización de tareas asignadas
  - Cronómetro integrado para registrar tiempo de estudio
  - Historial de sesiones de práctica
  - Estadísticas personales de progreso

---

## 🚀 Características Principales

- 🎨 **Material Design 3** - Interfaz moderna y accesible
- 🔐 **Autenticación segura** - Sistema de roles (Docente/Estudiante)
- ⏱️ **Cronómetro persistente** - Registro de tiempo de estudio
- 📊 **Estadísticas visuales** - Gráficos y métricas de progreso
- 📱 **Multiplataforma** - iOS y Android
- 🔄 **Tiempo real** - Sincronización con Firebase

---

## 🛠️ Tecnologías

- **Frontend:** Flutter 3.x (Dart 3.9.2+)
- **Backend:** Firebase
  - Firebase Authentication (Email/Password)
  - Cloud Firestore (Base de datos NoSQL)
  - Firebase Storage (Próximamente)
- **Gestión de Estado:** flutter_bloc (Cubit)
- **Navegación:** go_router
- **Diseño:** Material Design 3

---

## 📦 Requisitos Previos

- **Flutter SDK:** 3.x o superior
- **Dart:** 3.9.2 o superior
- **IDE:** VS Code o Android Studio con extensiones de Flutter
- **Dispositivos:** Simulador iOS y/o emulador Android configurados

---

## 🔧 Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd playing_tracker
```

### 2. Verificar versión de Flutter

```bash
flutter --version
```

Asegúrate de tener Flutter 3.x y Dart 3.9.2+ instalados.

### 3. Obtener dependencias

```bash
flutter pub get
```

### 4. Generar código de serialización JSON (Requerido para Sprint 1+)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Configurar Firebase (Próximamente)

En sprints futuros se requerirá:
- Archivo `google-services.json` para Android
- Archivo `GoogleService-Info.plist` para iOS

### 6. Ejecutar la aplicación

```bash
flutter run
```

---

## 📁 Estructura del Proyecto

El proyecto sigue una arquitectura **Feature-First** organizada por funcionalidad:

```
lib/
├── core/                    # Código compartido
│   ├── constants/          # Constantes y strings centralizados
│   ├── extensions/         # Extension methods
│   └── utils/             # Utilidades y validadores
├── config/                 # Configuración
│   ├── theme/             # Tema Material Design 3
│   └── routes/             # Configuración de navegación
├── features/               # Features por funcionalidad
│   ├── auth/              # Autenticación
│   ├── classes/           # Gestión de clases
│   ├── tasks/             # Gestión de tareas
│   ├── sessions/          # Cronómetro y sesiones
│   ├── statistics/        # Estadísticas
│   └── settings/          # Configuración
└── shared/                 # Widgets compartidos
    └── widgets/           # Componentes reutilizables
```

Para más detalles sobre la arquitectura, consulta la [Guía del Proyecto](docs/Guia_Proyecto_PlayingTracker.md).

---

## 🎯 Comandos Útiles

### Desarrollo

```bash
# Obtener dependencias
flutter pub get

# Generar código de serialización JSON
dart run build_runner build --delete-conflicting-outputs

# Formatear código
dart format .

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Ejecutar en dispositivo/simulador
flutter run

# Limpiar proyecto
flutter clean
```

### Firebase (Sprint 1+)

```bash
# Verificar instalación de Firebase CLI
firebase --version

# Validar reglas de Firestore (dry-run)
firebase deploy --only firestore:rules --dry-run

# Validar índices de Firestore (dry-run)
firebase deploy --only firestore:indexes --dry-run

# Deploy de reglas e índices (cuando esté configurado)
firebase deploy --only firestore
```

### Build

```bash
# Build para Android
flutter build apk

# Build para iOS
flutter build ios

# Build para Web
flutter build web
```

---

## 📊 Estado del Proyecto

**Sprint Actual:** Sprint 1 - Modelos de Dominio y Arquitectura de Datos ✅ COMPLETADO

**Progreso Sprint 1:** 100% completado (6/6 fases) ✅

### ✅ Sprint 0 - Diseño UI/UX (Completado)

- ✅ Sistema de tema Material Design 3 (claro/oscuro)
- ✅ Componentes base reutilizables (Botones, TextFields, Cards, AppBar, TabBar, BottomNavigationBar)
- ✅ Pantallas de autenticación (Login, Registro, Recuperación)
- ✅ Pantallas de docente (Lista de clases, Detalle con tabs, Estadísticas)
- ✅ Pantallas de estudiante (Lista de clases, Detalle con tabs, Estadísticas)
- ✅ Pantallas de tareas (Crear, Lista, Detalle)
- ✅ Pantallas de sesiones (Cronómetro, Historial)
- ✅ Navegación con StatefulShellRoute (BottomNavigationBar persistente)
- ✅ Strings centralizados (`app_strings.dart`)
- ✅ Estilos de texto centralizados (`AppTextStyles`)
- ✅ Validaciones de formularios
- ✅ Accesibilidad completa (Semantics, tamaños táctiles, contraste)
- ✅ Documentación de componentes completa

### ✅ Sprint 1 - Modelos de Dominio (Completado)

⚠️ **IMPORTANTE:** Existe un problema conocido de inconsistencia de Bundle IDs entre plataformas que debe corregirse antes del Sprint 2. Ver: [`docs/FIREBASE_BUNDLE_ID_FIX.md`](docs/FIREBASE_BUNDLE_ID_FIX.md)

**Fase 1 Completada: Enums de Dominio** ✅
- ✅ 5 enums implementados con serialización JSON
- ✅ Dependencias de Firebase y JSON añadidas
- ✅ Documentación dartdoc completa
- ✅ Código formateado y analizado sin errores

**Fase 2 Completada: Modelos de Dominio** ✅
- ✅ 8 modelos implementados con serialización JSON completa
- ✅ TimestampConverter para Firestore implementado
- ✅ build_runner ejecutado (8 archivos .g.dart generados)
- ✅ Todos los modelos son inmutables con métodos copyWith
- ✅ Documentación dartdoc completa en español
- ✅ Código formateado y analizado sin errores

**Fase 3 Completada: Validadores de Dominio** ✅
- ✅ 8 funciones de validación implementadas en `domain_validators.dart`
- ✅ Bug corregido: `pausedDuration` en SessionModel con default = 0
- ✅ Validadores para nombres, emails, códigos de acceso, duraciones, IDs, descripciones, URLs y títulos
- ✅ Documentación dartdoc completa con ejemplos de uso
- ✅ Mensajes de error descriptivos en español
- ✅ Código formateado y analizado sin errores

**Fase 4 Completada: Configuración de Firestore** ✅
- ✅ Firebase CLI y FlutterFire CLI configurados
- ✅ Archivos de configuración implementados:
  - `firebase.json` - Configuración principal
  - `firebase/firestore.rules` - Reglas de seguridad (227 líneas)
  - `firebase/firestore.indexes.json` - Archivo de índices
  - `lib/firebase_options.dart` - Configuración multiplataforma
  - `android/app/google-services.json` - Android
  - `ios/Runner/GoogleService-Info.plist` - iOS
  - `macos/Runner/GoogleService-Info.plist` - macOS
- ✅ Validación de roles con `isTeacher()` e `isStudent()`
- ✅ Solo teachers pueden crear classes y tasks
- ✅ Separación granular de permisos (create/read/update/delete)
- ✅ Sesiones inmutables (no update/delete)
- ✅ Validación exitosa con `firebase deploy --dry-run`
- ✅ **Nota:** API keys de Firebase son públicas por diseño. Seguridad garantizada por reglas de Firestore

**Fase 5 Completada: Índices Compuestos de Firestore** ✅
- ✅ 11 índices compuestos implementados en `firebase/firestore.indexes.json`
- ✅ **Memberships:** 2 índices (`classId+isActive`, `studentId+isActive`)
- ✅ **Assignments:** 3 índices (`taskId+status`, `studentId+status`, `teacherId+status`)
- ✅ **Sessions:** 4 índices (`studentId+dateLogged DESC`, `taskId+dateLogged DESC`, `teacherId+dateLogged DESC`, `monthBucket+dateLogged DESC`)
- ✅ **Tasks:** 1 índice (`createdBy+isActive`)
- ✅ **Classes:** 1 índice (`ownerTeacherId+isActive`)
- ✅ Uso correcto de `collectionId` para colecciones top-level (no `collectionGroup`)
- ✅ Índices optimizados para consultas frecuentes del sistema
- ✅ Validación exitosa con `firebase deploy --only firestore:indexes --dry-run`

**Fase 6 Completada: Documentación y Pruebas Finales** ✅
- ✅ Revisión completa de documentación de 8 modelos, 5 enums y 8 validadores
- ✅ Sección de ejemplos de uso agregada (8 ejemplos prácticos)
- ✅ Validaciones finales exitosas:
  - `dart format .` ✅ 0 cambios necesarios (65 archivos)
  - `flutter analyze` ✅ No issues found!
  - `dart run build_runner build` ✅ Ejecutado exitosamente
- ✅ **Sprint 1 completado al 100%**

### 📋 Sprints Futuros

- Sprint 2: Autenticación y Gestión de Usuarios
- Sprint 3: Sistema de Clases y Membresías
- Sprint 4: Gestión de Tareas y Asignaciones
- Sprint 5: Cronómetro y Sesiones de Estudio
- Sprint 6: Estadísticas y Dashboards
- Sprint 7: Testing y Optimización

Para más detalles sobre el progreso, consulta:
- [Documentación del Sprint 0](docs/sprints/SPRINT_0_IMPLEMENTACION.md)
- [Documentación del Sprint 1](docs/sprints/SPRINT_1_IMPLEMENTACION.md)

---

## 📚 Documentación

### Documentación Principal

- 📄 [Guía del Proyecto](docs/Guia_Proyecto_PlayingTracker.md) - Visión general, arquitectura y roadmap
- 📄 [Sprint 0 - Implementación](docs/sprints/SPRINT_0_IMPLEMENTACION.md) - Diseño UI/UX (Completado)
- 📄 [Sprint 1 - Implementación](docs/sprints/SPRINT_1_IMPLEMENTACION.md) - Modelos de Dominio (En Progreso)
- 📄 [Guía de Componentes](docs/components/COMPONENTS_GUIDE.md) - Documentación completa de componentes base
- 📄 [Reglas de Estilo](.cursor/rules/flutter_style_rules.mdc) - Convenciones de código y buenas prácticas

### Estructura de Documentación

```
docs/
├── sprints/
│   ├── SPRINT_0_IMPLEMENTACION.md  # Diseño UI/UX (Completado)
│   └── SPRINT_1_IMPLEMENTACION.md  # Modelos de Dominio (En Progreso)
├── components/
│   └── COMPONENTS_GUIDE.md          # Guía completa de componentes base
├── screenshots/                      # Screenshots de todas las pantallas
│   └── (17 screenshots disponibles)
├── Guia_Proyecto_PlayingTracker.md
└── (más documentación próximamente)
```

### Screenshots

Todas las pantallas implementadas en el Sprint 0 están documentadas visualmente. Consulta la [sección de Screenshots](docs/sprints/SPRINT_0_IMPLEMENTACION.md#-screenshots-de-pantallas) en el documento del sprint para ver todas las capturas organizadas por categorías (17 pantallas disponibles en `docs/screenshots/`).

### Componentes Base

La aplicación incluye una librería completa de componentes reutilizables documentados en la [Guía de Componentes](docs/components/COMPONENTS_GUIDE.md):

- **CustomButton** - Botones con variantes (filled, outlined, text) y estados (loading, disabled)
- **CustomTextField** - Campos de texto con validación visual y estilos M3
- **CustomCard** - Cards con título, subtítulo y acciones configurables
- **CustomAppBar** - AppBar con navegación automática y acciones
- **CustomTabBar** - TabBar personalizado con estilos M3
- **CustomBottomNavigationBar** - BottomNavigationBar con StatefulNavigationShell
- **LoadingOverlay** - Overlay modal de carga con bloqueo de interacción

### Estilos Centralizados

La aplicación utiliza un sistema de estilos centralizados para garantizar consistencia:

- **AppTextStyles** - Clase con métodos estáticos para todos los estilos de texto comunes
- **Extension Methods** - Acceso fácil desde `context` (ej: `context.displaySmallBold`, `context.bodyMediumOnSurface`)
- **AppSpacing** - Constantes de espaciado consistentes
- **AppBorderRadius** - Radios de borde uniformes
- **AppColors** - Colores del tema accesibles mediante `context.colorScheme`

---

## 🎨 Diseño

La aplicación implementa **Material Design 3** completamente:

- Paleta de colores generada con `ColorScheme.fromSeed`
- Componentes M3 modernos (FilledButton, OutlinedButton, TextField)
- Tema claro y oscuro completamente funcionales
- Tipografía con Google Fonts (Roboto)
- Tokens de diseño accesibles mediante extension methods

---

## 🧪 Testing

El testing se implementará en el Sprint 7. La estrategia incluirá:

- Unit tests para lógica de negocio (Cubits, funciones puras)
- Widget tests para componentes críticos
- Integration tests para flujos completos
- Golden tests para validación visual
- Testing de accesibilidad (TalkBack, VoiceOver)

---

## 🤝 Contribución

Este es un proyecto en desarrollo activo. Para contribuir:

1. Revisa la [Guía del Proyecto](docs/Guia_Proyecto_PlayingTracker.md)
2. Consulta las [Reglas de Estilo](.cursor/rules/flutter_style_rules.mdc)
3. Asegúrate de seguir las convenciones de código establecidas
4. Actualiza la documentación pertinente con tus cambios

---

## 📝 Licencia

Este proyecto es privado y no está disponible para uso público.

---

## 🔗 Enlaces Útiles

- [Flutter Documentation](https://docs.flutter.dev)
- [Material Design 3](https://m3.material.io/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Bloc Documentation](https://bloclibrary.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

## 📧 Contacto

Para más información sobre el proyecto, consulta la documentación en `docs/`.

---

**Última actualización:** 13 de Noviembre 2025
**Versión:** 1.2.0
**Estado:** Sprint 1 en progreso 🚧 - Fases 1 y 2 completadas ✅
