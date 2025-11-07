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

### 4. Configurar Firebase (Próximamente)

En sprints futuros se requerirá:
- Archivo `google-services.json` para Android
- Archivo `GoogleService-Info.plist` para iOS

### 5. Ejecutar la aplicación

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

**Sprint Actual:** Sprint 0 - Diseño UI/UX

**Progreso:** 80% completado (Fase 8 de 10)

### ✅ Completado

- ✅ Sistema de tema Material Design 3 (claro/oscuro)
- ✅ Componentes base reutilizables (Botones, TextFields, Cards, AppBar, TabBar)
- ✅ Pantallas de autenticación (Login, Registro, Recuperación)
- ✅ Pantallas de docente (Lista de clases, Detalle con tabs, Estadísticas)
- ✅ Pantallas de estudiante (Lista de clases, Detalle con tabs, Estadísticas)
- ✅ Pantallas de tareas (Crear, Lista, Detalle)
- ✅ Navegación con StatefulShellRoute (BottomNavigationBar persistente)
- ✅ Strings centralizados
- ✅ Validaciones de formularios

### 📅 En Progreso

- 📅 Pantallas de sesiones (Cronómetro, Historial)
- 📅 Pulido y documentación final

### 📋 Próximos Sprints

- Sprint 1: Modelos de Dominio y Arquitectura de Datos
- Sprint 2: Autenticación y Gestión de Usuarios
- Sprint 3: Sistema de Clases y Membresías
- Sprint 4: Gestión de Tareas y Asignaciones
- Sprint 5: Cronómetro y Sesiones de Estudio
- Sprint 6: Estadísticas y Dashboards
- Sprint 7: Testing y Optimización

Para más detalles sobre el progreso, consulta la [Documentación del Sprint 0](docs/sprints/SPRINT_0_IMPLEMENTACION.md).

---

## 📚 Documentación

### Documentación Principal

- 📄 [Guía del Proyecto](docs/Guia_Proyecto_PlayingTracker.md) - Visión general, arquitectura y roadmap
- 📄 [Sprint 0 - Implementación](docs/sprints/SPRINT_0_IMPLEMENTACION.md) - Detalles de implementación del sprint actual
- 📄 [Reglas de Estilo](.cursor/rules/flutter_style_rules.mdc) - Convenciones de código y buenas prácticas

### Estructura de Documentación

```
docs/
├── sprints/
│   └── SPRINT_0_IMPLEMENTACION.md
├── Guia_Proyecto_PlayingTracker.md
└── (más documentación próximamente)
```

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

**Última actualización:** Noviembre 2025
**Versión:** 1.0.0
**Estado:** En desarrollo - Sprint 0
