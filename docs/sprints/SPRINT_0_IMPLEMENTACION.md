# 📋 Implementación Sprint 0: Diseño UI/UX y Configuración Inicial

**Proyecto:** Playing Tracker - Sistema de Seguimiento de Estudio Musical
**Sprint:** 0 - Configuración Inicial y Diseño UI/UX
**Duración:** Octubre 2025 (2 semanas)
**Estado:** 📅 En desarrollo - Fase 1 completada ✅
**Versión del documento:** 1.1
**Última actualización:** 29 de Octubre 2025

---

## 🎯 Objetivo del Sprint

Establecer la base sólida del proyecto con enfoque **"diseño primero"**, priorizando la experiencia de usuario mediante la implementación completa de Material Design 3 y la creación de prototipos funcionales de todas las pantallas **sin lógica de negocio**. Este sprint prepara la arquitectura, la estructura de carpetas, el sistema de temas y la navegación necesarios para el desarrollo iterativo posterior.

### Principios Fundamentales

- **Diseño primero:** Toda la UI/UX debe estar completa antes de implementar la lógica de negocio
- **Material Design 3:** Implementación completa y coherente en toda la aplicación
- **Feature-First Architecture:** Estructura organizada por funcionalidad, no por tipo técnico
- **Componentes reutilizables:** Crear una librería base de widgets compartidos
- **Accesibilidad:** Desde el inicio, asegurar accesibilidad completa (TalkBack, VoiceOver, contraste)

---

## 📐 Alcance del Sprint

### ✅ Incluido en este Sprint

1. **Setup y Configuración del Proyecto**
   - Configuración inicial de Flutter 3.x con Dart 3.9.2+
   - Inicialización de Firebase (solo estructura, sin conexión real)
   - Configuración de análisis estático (`analysis_options.yaml`)
   - Dependencias básicas de UI y navegación

2. **Sistema de Tema Material Design 3**
   - ThemeData completo con `useMaterial3: true`
   - Paleta de colores generada con `ColorScheme.fromSeed`
   - Tema claro y oscuro completamente funcionales
   - Tipografía con Google Fonts
   - Tokens de diseño accesibles mediante extension methods

3. **Componentes Base Reutilizables**
   - `CustomButton` - Botones con estilos M3 consistentes
   - `CustomTextField` - Campos de texto con validación visual básica
   - `CustomCard` - Cards para mostrar información
   - `LoadingOverlay` - Indicadores de carga
   - `CustomAppBar` - Barra de navegación personalizada

4. **Prototipos de Pantallas (UI estática)**
   - **Autenticación:**
     - `LoginScreen` - Pantalla de inicio de sesión
     - `RegisterScreen` - Pantalla de registro
     - `ForgotPasswordScreen` - Recuperación de contraseña
   - **Docente:**
     - `TeacherHomeScreen` - Dashboard principal para docentes
     - `CreateClassScreen` - Formulario para crear clases
     - `ManageStudentsScreen` - Gestión de alumnos por clase
     - `CreateTaskScreen` - Formulario para crear tareas
   - **Alumno:**
     - `StudentHomeScreen` - Dashboard principal para alumnos
     - `JoinClassScreen` - Unirse a clase con código
     - `TaskListScreen` - Lista de tareas asignadas
     - `TaskDetailScreen` - Detalle de tarea
     - `TimerScreen` - Pantalla de cronómetro

5. **Navegación y Routing**
   - Configuración de `go_router` con todas las rutas principales
   - Navegación condicional según rol (mock inicial)
   - Shell navigation y rutas anidadas

6. **Estructura de Carpetas Feature-First**
   - Crear todas las carpetas según la arquitectura definida
   - Archivos placeholder donde sea necesario
   - Estructura preparada para sprints futuros

### ❌ No Incluido en este Sprint

- Lógica de autenticación real con Firebase
- CRUD de datos en Firestore
- Gestión de estado real con Cubit (solo estructura)
- Validaciones de negocio complejas
- Integración con servicios externos
- Persistencia de datos
- Testing automatizado (se cubrirá en Sprint 7)

---

## 📦 Entregables

### Código Funcional

1. **Proyecto Flutter Base**
   - Compila sin errores en iOS y Android
   - Estructura de carpetas completa según Feature-First Architecture
   - Análisis estático (`flutter analyze`) sin errores

2. **Sistema de Tema Completo**
   - Archivo `lib/config/theme/app_theme.dart` con ThemeData M3
   - Tema claro y oscuro completamente funcionales
   - Toggle manual de tema (temporal, puede ser en ajustes o dev menu)
   - Extension methods: `context.theme`, `context.colorScheme`

3. **Componentes Base en `lib/shared/widgets/`**
   - `custom_button.dart` - Botón reutilizable con variantes
   - `custom_text_field.dart` - TextField con estilos M3
   - `custom_card.dart` - Card con elevación y bordes redondeados
   - `loading_overlay.dart` - Overlay de carga modal
   - `custom_app_bar.dart` - AppBar personalizado con acciones

4. **Pantallas Prototipo en `lib/features/`**
   - Todas las pantallas listadas en el alcance implementadas
   - UI completa y coherente con Material Design 3
   - Placeholders de datos donde sea necesario
   - Navegación entre pantallas funcional

5. **Configuración de Navegación**
   - Archivo `lib/config/routes/app_routes.dart` con go_router configurado
   - Todas las rutas principales definidas
   - Navegación condicional por rol (mock)

6. **Dependencias Configuradas**
   - `pubspec.yaml` con todas las dependencias necesarias
   - Versiones compatibles y documentadas
   - Dependencias solo de UI y navegación (sin Firebase aún)

### Documentación

1. **README del Sprint**
   - Comandos para ejecutar el proyecto
   - Estructura de carpetas explicada
   - Convenciones de código seguidas

2. **Guía de Componentes**
   - Documentación de cada componente base con ejemplos de uso
   - Variantes y props disponibles

3. **Screenshots/Mockups**
   - Capturas de todas las pantallas en tema claro y oscuro
   - Documentación visual del diseño

---

## 🏗️ Estructura Técnica Detallada

### Archivos a Crear

#### Configuración y Tema

```
lib/config/
├── theme/
│   └── app_theme.dart              # ThemeData Material Design 3 completo
└── routes/
    └── app_routes.dart             # Configuración de go_router con todas las rutas
```

#### Componentes Compartidos

```
lib/shared/widgets/
├── custom_button.dart              # Botón con variantes (filled, outlined, text)
├── custom_text_field.dart          # TextField con estilos M3 y validación visual
├── custom_card.dart                # Card reutilizable con elevación configurable
├── loading_overlay.dart            # Overlay modal de carga
└── custom_app_bar.dart             # AppBar personalizado con acciones
```

#### Feature: Auth (UI solamente)

```
lib/features/auth/presentation/screens/
├── login_screen.dart              # Pantalla de login (formulario sin lógica)
├── register_screen.dart           # Pantalla de registro (formulario sin lógica)
└── forgot_password_screen.dart    # Recuperación de contraseña (formulario sin lógica)
```

#### Feature: Home

```
lib/features/home/presentation/screens/
├── teacher_home_screen.dart       # Dashboard docente con cards y navegación
└── student_home_screen.dart       # Dashboard alumno con tareas y cronómetro rápido
```

#### Feature: Classes (UI solamente)

```
lib/features/classes/presentation/screens/
├── create_class_screen.dart       # Formulario crear clase (sin guardado real)
├── join_class_screen.dart         # Formulario unirse a clase (sin validación real)
└── manage_students_screen.dart    # Lista de alumnos (datos mock)
```

#### Feature: Tasks (UI solamente)

```
lib/features/tasks/presentation/screens/
├── create_task_screen.dart       # Formulario crear tarea (sin guardado real)
├── task_list_screen.dart          # Lista de tareas (datos mock)
└── task_detail_screen.dart        # Detalle de tarea (datos mock)
```

#### Feature: Sessions (UI solamente)

```
lib/features/sessions/presentation/screens/
├── timer_screen.dart              # Cronómetro con UI completa (sin funcionalidad real)
└── session_history_screen.dart    # Historial de sesiones (datos mock)
```

### Extensiones y Utilidades

```
lib/core/extensions/
└── context_extensions.dart        # context.theme, context.colorScheme, etc.

lib/core/constants/
└── app_constants.dart              # Espaciado, radios de bordes, duraciones de animaciones
```

---

## 🔧 Setup y Configuración

### Requisitos Previos

- **Flutter SDK:** 3.x (Dart 3.9.2+)
- **IDE:** VS Code o Android Studio con extensiones de Flutter
- **Dispositivos:** Simulador iOS y/o emulador Android configurados

### Comandos de Setup

```bash
# Verificar versión de Flutter
flutter --version

# Limpiar proyecto si existe
flutter clean

# Obtener dependencias
flutter pub get

# Formatear código
dart format .

# Analizar código
flutter analyze

# Ejecutar en dispositivo/simulador
flutter run
```

### Dependencias a Añadir

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI y Tema
  google_fonts: ^6.2.1          # Fuentes personalizadas
  cupertino_icons: ^1.0.8      # Iconos iOS

  # Navegación
  go_router: ^14.2.7            # Navegación declarativa

  # Gestión de Estado (solo estructura, sin lógica aún)
  flutter_bloc: ^8.1.6          # Framework de gestión de estado
  equatable: ^2.0.7             # Comparación de objetos (para estados futuros)

  # Utilidades
  intl: ^0.19.0                 # Internacionalización (formateo de fechas, etc.)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0         # Reglas de linting
```

### Configuración de Análisis Estático

El archivo `analysis_options.yaml` ya existe en el proyecto. Se debe respetar y asegurar que:

- Todas las reglas de linting están habilitadas
- No hay warnings sin resolver
- Se siguen las convenciones de nombres establecidas

### Configuración de Firebase (Solo Estructura)

**Nota:** En este sprint NO se realiza la conexión real con Firebase. Solo se prepara la estructura:

- Crear carpeta `firebase/` en la raíz (opcional, para futuros archivos de configuración)
- Documentar dónde irán los archivos `google-services.json` y `GoogleService-Info.plist` en sprints futuros

---

## 🎨 Diseño Material Design 3

### Paleta de Colores

**Color Semilla:** `Color(0xFF1E88E5)` (Azul Material)

El tema se generará automáticamente usando `ColorScheme.fromSeed()`:

```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1E88E5),
  brightness: Brightness.light, // o Brightness.dark para tema oscuro
);
```

**Tokens de Color Accesibles:**
- `context.colorScheme.primary` - Color primario
- `context.colorScheme.secondary` - Color secundario
- `context.colorScheme.surface` - Color de superficie
- `context.colorScheme.error` - Color de error
- `context.colorScheme.onPrimary` - Color sobre primario (contraste)
- Y todos los demás tokens del ColorScheme M3

### Tipografía

**Fuente Principal:** Google Fonts (Roboto o Montserrat recomendadas)

```dart
textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
```

**Estilos M3 a Utilizar:**
- `displayLarge`, `displayMedium`, `displaySmall` - Títulos grandes
- `headlineLarge`, `headlineMedium`, `headlineSmall` - Encabezados
- `titleLarge`, `titleMedium`, `titleSmall` - Títulos de sección
- `bodyLarge`, `bodyMedium`, `bodySmall` - Texto de cuerpo
- `labelLarge`, `labelMedium`, `labelSmall` - Etiquetas y botones

### Componentes M3

**Botones:**
- `FilledButton` - Botón principal con fondo sólido
- `FilledButton.tonal()` - Botón secundario con fondo tonal
- `OutlinedButton` - Botón con borde
- `TextButton` - Botón de texto plano

**Inputs:**
- `TextField` con:
  - `filled: true`
  - `borderRadius` en `InputDecoration`
  - `filledColor: colorScheme.surfaceVariant`

**Elevación:**
- Usar `surfaceTintColor` en lugar de sombras fuertes
- Elevación suave (1-3 para cards, 4-6 para dialogs)

### Tema Claro vs Oscuro

Ambos temas deben estar completamente implementados y ser intercambiables mediante un toggle (puede ser temporal en ajustes o en un dev menu).

**Diferencias clave:**
- Tema claro: fondos claros, texto oscuro, elevación visible
- Tema oscuro: fondos oscuros, texto claro, elevación sutil

---

## 🧭 Navegación y Routing

### Estructura de Rutas

Usando `go_router` con rutas declarativas:

```
/                    → LoginScreen (si no autenticado) o Home según rol
/login               → LoginScreen
/register            → RegisterScreen
/forgot-password     → ForgotPasswordScreen

/home
  /teacher           → TeacherHomeScreen
  /student           → StudentHomeScreen

/classes
  /create            → CreateClassScreen
  /join              → JoinClassScreen
  /manage/:classId   → ManageStudentsScreen

/tasks
  /                  → TaskListScreen
  /create            → CreateTaskScreen
  /:taskId           → TaskDetailScreen

/timer/:taskId       → TimerScreen

/statistics          → StatisticsScreen (placeholder)
```

### Navegación Condicional

Implementar `AuthWrapper` (estático, sin lógica real) que:
- Si "rol mock = docente" → redirige a `/home/teacher`
- Si "rol mock = alumno" → redirige a `/home/student`
- Si no hay rol → redirige a `/login`

**Nota:** En Sprint 2, esto se implementará con lógica real de Firebase Auth.

### Shell Navigation (GoRouter)

Usar `ShellRoute` para layouts compartidos (AppBar, BottomNavigation, etc.)

---

## ✅ Criterios de Aceptación

### Funcionales

1. **Compilación:**
   - ✅ El proyecto compila sin errores en iOS y Android
   - ✅ No hay warnings críticos en el análisis estático

2. **Tema:**
   - ✅ Tema claro y oscuro funcionan correctamente
   - ✅ Todos los componentes respetan los tokens de Material Design 3
   - ✅ El toggle de tema funciona (temporal, puede ser manual)

3. **Navegación:**
   - ✅ Todas las rutas están definidas y son accesibles
   - ✅ La navegación entre pantallas funciona sin errores
   - ✅ El routing condicional por rol funciona (mock)

4. **Componentes:**
   - ✅ Todos los componentes base están implementados y funcionan
   - ✅ Los componentes son reutilizables (usados en ≥2 pantallas)
   - ✅ Los componentes respetan Material Design 3

5. **Pantallas:**
   - ✅ Todas las pantallas listadas en el alcance están implementadas
   - ✅ Las pantallas tienen UI completa (aunque sea con datos mock)
   - ✅ La coherencia visual entre pantallas es evidente

### Técnicos

1. **Código:**
   - ✅ `dart format` no requiere cambios
   - ✅ `flutter analyze` no muestra errores
   - ✅ El código sigue las convenciones establecidas en `.cursor/rules/`

2. **Estructura:**
   - ✅ Todas las carpetas de la arquitectura Feature-First están creadas
   - ✅ Los archivos están organizados según la estructura definida

3. **Accesibilidad:**
   - ✅ Tamaños táctiles mínimos de 48x48 dp
   - ✅ Contraste mínimo de 4.5:1 en textos normales
   - ✅ Labels semánticos en botones e inputs

### Diseño

1. **Visual:**
   - ✅ Coherencia visual en todas las pantallas
   - ✅ Material Design 3 implementado correctamente
   - ✅ Responsive en diferentes tamaños de pantalla (básico)

2. **UX:**
   - ✅ Feedback visual en interacciones
   - ✅ Estados de carga visibles
   - ✅ Navegación intuitiva

---

## 📋 Definición de Hecho (DoD)

El Sprint 0 se considera **completo** cuando se cumplen **TODOS** estos criterios:

1. ✅ **Código formateado:** `dart format .` ejecutado y código formateado
2. ✅ **Sin errores de análisis:** `flutter analyze` sin errores
3. ✅ **Compilación exitosa:** Proyecto compila en iOS y Android
4. ✅ **Todos los entregables:** Componentes, pantallas y navegación implementados
5. ✅ **Documentación:** README del sprint completo y guía de componentes
6. ✅ **Revisión visual:** Todas las pantallas revisadas visualmente
7. ✅ **Accesibilidad básica:** Contraste y tamaños táctiles verificados
8. ✅ **Trazabilidad:** Todo alineado con la Guía del Proyecto

---

## 🎯 Tareas Detalladas

### Fase 1: Setup Inicial (Días 1-2) ✅ COMPLETADA

- [x] Verificar Flutter SDK 3.x instalado y funcionando (Flutter 3.35.6, Dart 3.9.2)
- [x] Configurar proyecto base si no existe (ya existía)
- [x] Añadir dependencias al `pubspec.yaml` (google_fonts, go_router, flutter_bloc, equatable, intl)
- [x] Ejecutar `flutter pub get` (todas las dependencias descargadas correctamente)
- [x] Verificar que el proyecto compila (verificación exitosa)
- [x] Configurar `analysis_options.yaml` si necesita ajustes (no requiere cambios)
- [x] Crear estructura de carpetas Feature-First completa (29 carpetas creadas)

### Fase 2: Sistema de Tema (Días 3-4) ✅ COMPLETADA

- [x] Crear `lib/config/theme/app_theme.dart` (archivo placeholder ya existe ✅)
- [x] Implementar ThemeData con `useMaterial3: true`
- [x] Configurar paleta de colores con `ColorScheme.fromSeed`
- [x] Implementar tema claro
- [x] Implementar tema oscuro
- [x] Añadir Google Fonts (dependencia ya añadida ✅)
- [x] Crear extension methods: `context.theme`, `context.colorScheme` (archivo placeholder ya existe ✅)
- [x] Integrar tema en `main.dart`
- [x] Crear toggle temporal para cambiar tema
- [x] Probar tema en ambas variantes

### Fase 3: Componentes Base (Días 5-6)

- [ ] Crear `lib/shared/widgets/custom_button.dart`
  - [ ] Variante Filled
  - [ ] Variante Outlined
  - [ ] Variante Text
  - [ ] Estados: enabled, disabled, loading
- [ ] Crear `lib/shared/widgets/custom_text_field.dart`
  - [ ] Estilos M3
  - [ ] Validación visual básica (mostrar errores)
  - [ ] Label y hint text
- [ ] Crear `lib/shared/widgets/custom_card.dart`
  - [ ] Elevación configurable
  - [ ] Bordes redondeados
  - [ ] Soporte para acciones
- [ ] Crear `lib/shared/widgets/loading_overlay.dart`
  - [ ] Overlay modal
  - [ ] Indicador de carga
  - [ ] Bloqueo de interacción mientras carga
- [ ] Crear `lib/shared/widgets/custom_app_bar.dart`
  - [ ] Título
  - [ ] Acciones configurables
  - [ ] Navegación hacia atrás

### Fase 4: Navegación (Día 7)

- [ ] Crear `lib/config/routes/app_routes.dart`
- [ ] Configurar `go_router` con todas las rutas
- [ ] Implementar navegación condicional (mock)
- [ ] Crear `AuthWrapper` estático
- [ ] Probar navegación entre todas las pantallas
- [ ] Implementar Shell navigation si es necesario

### Fase 5: Pantallas de Autenticación (Día 8)

- [ ] Crear `lib/features/auth/presentation/screens/login_screen.dart`
  - [ ] Formulario con email y contraseña
  - [ ] Botón de login (sin funcionalidad real)
  - [ ] Link a registro
  - [ ] Link a recuperación de contraseña
- [ ] Crear `lib/features/auth/presentation/screens/register_screen.dart`
  - [ ] Formulario completo (nombre, apellidos, email, contraseña, rol)
  - [ ] Validación visual básica
  - [ ] Botón de registro (sin funcionalidad real)
- [ ] Crear `lib/features/auth/presentation/screens/forgot_password_screen.dart`
  - [ ] Formulario con email
  - [ ] Botón de envío (sin funcionalidad real)

### Fase 6: Pantallas Home (Día 9)

- [ ] Crear `lib/features/home/presentation/screens/teacher_home_screen.dart`
  - [ ] Cards con información relevante
  - [ ] Navegación rápida a funcionalidades principales
  - [ ] Placeholders de datos
- [ ] Crear `lib/features/home/presentation/screens/student_home_screen.dart`
  - [ ] Lista de tareas pendientes (mock)
  - [ ] Acceso rápido al cronómetro
  - [ ] Progreso personal (mock)

### Fase 7: Pantallas de Clases (Día 10)

- [ ] Crear `lib/features/classes/presentation/screens/create_class_screen.dart`
  - [ ] Formulario crear clase (nombre, descripción)
  - [ ] Placeholder para código de acceso
  - [ ] Botón crear (sin funcionalidad real)
- [ ] Crear `lib/features/classes/presentation/screens/join_class_screen.dart`
  - [ ] Campo para código de acceso
  - [ ] Botón unirse (sin funcionalidad real)
- [ ] Crear `lib/features/classes/presentation/screens/manage_students_screen.dart`
  - [ ] Lista de alumnos (datos mock)
  - [ ] Acciones por alumno

### Fase 8: Pantallas de Tareas (Día 11)

- [ ] Crear `lib/features/tasks/presentation/screens/create_task_screen.dart`
  - [ ] Formulario completo (título, descripción, tiempo, adjuntos)
  - [ ] Selector de destinatarios (mock)
  - [ ] Botón crear (sin funcionalidad real)
- [ ] Crear `lib/features/tasks/presentation/screens/task_list_screen.dart`
  - [ ] Lista de tareas (datos mock)
  - [ ] Filtros básicos (UI solamente)
  - [ ] Navegación al detalle
- [ ] Crear `lib/features/tasks/presentation/screens/task_detail_screen.dart`
  - [ ] Información completa de tarea (mock)
  - [ ] Acciones disponibles según rol

### Fase 9: Pantallas de Sesiones (Día 12)

- [ ] Crear `lib/features/sessions/presentation/screens/timer_screen.dart`
  - [ ] Cronómetro grande y visible
  - [ ] Controles: iniciar, pausar, reiniciar, finalizar (sin funcionalidad real)
  - [ ] Información de tarea actual
  - [ ] UI completa para estados del cronómetro
- [ ] Crear `lib/features/sessions/presentation/screens/session_history_screen.dart`
  - [ ] Lista de sesiones (datos mock)
  - [ ] Filtros por fecha (UI solamente)

### Fase 10: Pulido y Documentación (Días 13-14)

- [ ] Revisar todas las pantallas visualmente
- [ ] Verificar coherencia de diseño
- [ ] Probar navegación completa
- [ ] Verificar accesibilidad (contraste, tamaños táctiles)
- [ ] Ejecutar `dart format .`
- [ ] Ejecutar `flutter analyze` y corregir errores
- [ ] Crear README del sprint
- [ ] Documentar componentes base
- [ ] Capturar screenshots de todas las pantallas
- [ ] Revisión final y ajustes

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Deriva de Alcance en UI

**Problema:** Tendencia a añadir funcionalidad real en lugar de solo UI.

**Mitigación:**
- Establecer límites claros: solo UI, sin lógica de negocio
- Usar placeholders y datos mock en todos lados
- Documentar explícitamente qué NO se implementa en este sprint

### Riesgo 2: Inconsistencia de Estilos

**Problema:** Diferentes pantallas con estilos inconsistentes.

**Mitigación:**
- Crear tokens centralizados en `app_theme.dart`
- Reutilizar componentes base en todas las pantallas
- Revisión visual periódica durante el desarrollo

### Riesgo 3: Dependencias No Utilizadas

**Problema:** Añadir dependencias que no se usan en este sprint.

**Mitigación:**
- Revisar `pubspec.yaml` al final del sprint
- Solo incluir dependencias necesarias para UI y navegación
- Documentar dependencias añadidas y su propósito

### Riesgo 4: Acoplamiento Fuertemente a Mock Data

**Problema:** Difícil cambiar de mock a datos reales en sprints futuros.

**Mitigación:**
- Usar estructura similar a la que tendrán los datos reales
- Separar claramente la capa de presentación
- Documentar dónde se usarán los servicios reales

---

## 🧪 Plan de Pruebas

### Pruebas Manuales

1. **Navegación:**
   - Recorrer todas las rutas manualmente
   - Verificar que no hay errores de navegación
   - Probar navegación condicional por rol

2. **Tema:**
   - Verificar que el toggle de tema funciona
   - Revisar contraste en ambos temas
   - Verificar que todos los componentes se ven bien en ambos temas

3. **Componentes:**
   - Probar todas las variantes de cada componente
   - Verificar estados (enabled, disabled, loading, error)
   - Verificar accesibilidad (TalkBack/VoiceOver)

4. **Responsividad:**
   - Probar en diferentes tamaños de pantalla (teléfono pequeño y mediano)
   - Verificar que los layouts se adaptan correctamente

### Validación Visual

- Revisar todas las pantallas en tema claro
- Revisar todas las pantallas en tema oscuro
- Verificar coherencia visual entre pantallas
- Comparar con especificaciones de Material Design 3

---

## 📚 Referencias y Recursos

### Documentación Oficial

- [Flutter Documentation](https://docs.flutter.dev)
- [Material Design 3](https://m3.material.io/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Bloc](https://bloclibrary.dev/)

### Recursos de Diseño

- [Material Design 3 Component Gallery](https://m3.material.io/components)
- [Material Design Color Tool](https://m2.material.io/design/color/the-color-system.html)

### Guías del Proyecto

- [Guía de Desarrollo del Proyecto Playing Tracker](../Guia_Proyecto_PlayingTracker.md)
- [Análisis de Requisitos y Fase de Diseño](../analisis_requisitos_fase_diseño/Analisis_Requisitos_Fase_Diseño.md)

---

## 🔄 Próximos Pasos (Sprint 1)

Una vez completado el Sprint 0, el siguiente sprint se enfocará en:

- Implementación de modelos de dominio (Teacher, Student, Class, Task, etc.)
- Configuración completa de Firestore con 7 colecciones
- Reglas de seguridad de Firestore
- Índices compuestos para consultas eficientes
- Validadores de datos y enums de estado

**Nota:** El Sprint 1 no añadirá UI nueva, solo preparará la base de datos y los modelos para el Sprint 2 donde se implementará la autenticación real.

---

## ✅ Checklist Final del Sprint

**Progreso General: 20% (2/10 fases completadas)**

### Fase 1: Setup Inicial ✅
- [x] Todas las tareas de la Fase 1 completadas
- [x] Proyecto compila sin errores
- [x] `dart format .` ejecutado (7 archivos formateados)
- [x] `flutter analyze` sin errores (0 issues)
- [x] Estructura Feature-First creada (29 carpetas, 5 archivos placeholder)

### Fase 2: Sistema de Tema ✅
- [x] Tema claro y oscuro funcionando
- [x] Constantes de diseño implementadas (espaciado, radios, duraciones)
- [x] Extension methods implementadas (`context.theme`, `context.colorScheme`, etc.)
- [x] Toggle temporal de tema funcionando
- [x] Material Design 3 completamente configurado
- [x] Google Fonts integrado (Roboto)
- [x] Componentes M3 configurados (botones, TextFields, Cards, AppBar)
- [x] Pantalla de prueba creada para validar el tema

### Pendiente (Fases 3-10)
- [ ] Todos los componentes base implementados
- [ ] Todas las pantallas creadas y navegables
- [ ] Navegación completa funcional
- [ ] Accesibilidad básica verificada
- [ ] Documentación del sprint completa
- [ ] Screenshots capturados
- [ ] Revisión final realizada
- [ ] Listo para Sprint 1

---

## 📝 Historial de Cambios

### Versión 1.2 - 29 de Octubre 2025
- ✅ **Fase 2 completada:** Sistema de tema Material Design 3
- ✅ Tema claro y oscuro completamente implementados con `ColorScheme.fromSeed`
- ✅ Constantes de diseño implementadas: `AppSpacing`, `AppBorderRadius`, `AppDurations`
- ✅ Extension methods implementadas: `context.theme`, `context.colorScheme`, `context.textTheme`, `context.mediaQuery`, `context.screenWidth`, `context.screenHeight`
- ✅ Toggle temporal de tema implementado en pantalla de prueba
- ✅ Componentes M3 configurados: FilledButton, OutlinedButton, TextButton, TextField, Card, AppBar
- ✅ Google Fonts (Roboto) integrado en ambos temas
- ✅ Pantalla de prueba creada para validar componentes M3 y paleta de colores
- ✅ `flutter analyze` sin errores (0 issues)
- ✅ Código formateado con `dart format`

### Versión 1.1 - 29 de Octubre 2025
- ✅ **Fase 1 completada:** Setup inicial y estructura Feature-First
- ✅ Dependencias añadidas: google_fonts, go_router, flutter_bloc, equatable, intl
- ✅ 29 carpetas creadas siguiendo arquitectura Feature-First
- ✅ 5 archivos placeholder con documentación en español
- ✅ 7 archivos .gitkeep para mantener estructura en git
- ✅ `flutter analyze` sin errores (0 issues)
- ✅ Código formateado con `dart format`

### Versión 1.0 - 29 de Octubre 2025
- Documento inicial creado con planificación completa del Sprint 0
- 10 fases definidas con tareas detalladas
- Criterios de aceptación y DoD establecidos

---

**Última actualización:** 29 de Octubre 2025
**Estado:** En desarrollo - Fase 2 completada ✅
**Progreso:** 20% (2/10 fases)
**Responsable:** Equipo de desarrollo Playing Tracker

