# SPRINT 6: Estadísticas y Dashboards

**Estado:** � En Desarrollo
**Fecha de inicio:** 2026-01-26

**Duración estimada:** 2-3 semanas

---

## 🎯 Objetivos del Sprint

1. **Sistema de Estadísticas:**
   - Implementar consultas agregadas a Firestore para obtener métricas de tiempo de estudio.
   - Crear modelos de datos para estadísticas (diarias, semanales, mensuales, anuales).
   - Calcular estadísticas por tarea, por clase y por alumno.

2. **Visualizaciones Gráficas:**
   - Integrar librería de gráficos (fl_chart) para visualizaciones atractivas.
   - Crear gráficos de barras para tiempo de estudio por día/semana.
   - Crear gráficos de progreso para tareas completadas.
   - Crear gráfico circular para distribución de tiempo por tarea.

3. **Dashboards Personalizados:**
   - **Dashboard del Docente:**
     - Resumen de actividad de todos sus alumnos.
     - Estadísticas por clase y por tarea.
     - Identificar alumnos que necesitan más atención.
   - **Dashboard del Alumno:**
     - Progreso personal (tiempo total, rachas de práctica).
     - Comparativa con objetivos de tiempo sugerido.
     - Histórico de sesiones con tendencias.

4. **Filtros Avanzados:**
   - Filtrar por rango de fechas (hoy, esta semana, este mes, personalizado).
   - Filtrar por clase y/o tarea específica.
   - Ordenación por diferentes métricas.

5. **Exportación de Datos (Opcional):**
   - Exportar estadísticas a CSV.
   - Generar reportes PDF con resumen.

---

## 📅 Fases de Implementación

### 🏗️ Fase 1: Capa de Datos y Dominio (Statistics)
**Objetivo:** Establecer los cimientos para calcular y obtener estadísticas.

- [x] **Definir Modelos de Estadísticas**:
  - `DailyStatsModel`: Estadísticas de un día específico.
  - `WeeklyStatsModel`: Agregado semanal con comparativa.
  - `TaskStatsModel`: Estadísticas por tarea (tiempo total, sesiones, promedio).
  - `ClassStatsModel`: Estadísticas por clase (todos los alumnos).
  - `StudentProgressModel`: Progreso individual del alumno.
- [x] **Implementar `StatisticsService`**:
  - Método `getDailyStats(studentId, date)`: Estadísticas de un día.
  - Método `getWeeklyStats(studentId, weekStart)`: Estadísticas semanales.
  - Método `getMonthlyStats(studentId, month, year)`: Estadísticas mensuales.
  - Método `getTaskStats(taskId, studentId?)`: Estadísticas por tarea.
  - Método `getClassStats(classId, teacherId)`: Estadísticas de clase para docente.
  - Utilizar `monthBucket` de `sessions` para consultas eficientes.
- [x] **Implementar `StatisticsRepository`**:
  - Contrato e implementación que orquesta las consultas.
  - Manejo de errores (`StatisticsException`).
- [x] **Tests Unitarios**:
  - Validación de serialización de modelos.
  - Tests del repositorio con Mocktail.


### 📊 Fase 2: Componentes de Gráficos Reutilizables
**Objetivo:** Crear widgets de gráficos reutilizables con Material Design 3.

- [x] **Configurar dependencia `fl_chart`**:
  - Agregar `fl_chart: ^1.1.1` a `pubspec.yaml`.
  - Crear wrapper widgets con tema M3.
- [x] **Implementar Widgets de Gráficos**:
  - `AppBarChart`: Gráfico de barras para tiempo diario/semanal.
  - `AppPieChart`: Gráfico circular para distribución.
  - `AppProgressChart`: Indicador de progreso circular.
- [x] **Aplicar Tema Material Design 3**:
  - Colores coherentes con `colorScheme`.
  - Animaciones suaves y feedback táctil.
  - Tooltips informativos al tocar datos.
- [x] **Tests de Widget**:
  - Renderizado correcto con datos de ejemplo.
  - Manejo de casos vacíos (sin datos).

### 📱 Fase 3: Dashboard del Alumno
**Objetivo:** Crear la pantalla de estadísticas para el alumno.

- [ ] **Implementar `StudentStatsCubit`**:
  - Estados: `Initial`, `Loading`, `Loaded`, `Error`.
  - Cargar estadísticas al abrir la pantalla.
  - Método para cambiar período (día/semana/mes).
- [ ] **Diseñar UI de Estadísticas del Alumno**:
  - Hero card con tiempo total de práctica.
  - Gráfico de barras: Tiempo por día (últimos 7 días).
  - Gráfico circular: Distribución por tarea.
  - Lista de tareas con progreso individual.
  - Racha de práctica (días consecutivos).
- [ ] **Implementar Filtros**:
  - Selector de período (Hoy, Esta Semana, Este Mes, Personalizado).
  - Filtro por clase.
- [ ] **Tests**:
  - Tests unitarios del Cubit.
  - Tests de widget para la UI.

### 👩‍🏫 Fase 4: Dashboard del Docente
**Objetivo:** Crear la pantalla de estadísticas para el docente.

- [ ] **Implementar `TeacherStatsCubit`**:
  - Estados: `Initial`, `Loading`, `Loaded`, `Error`.
  - Cargar estadísticas agregadas de todos los alumnos.
  - Método para filtrar por clase o alumno específico.
- [ ] **Diseñar UI de Estadísticas del Docente**:
  - Resumen global: Total alumnos activos, tiempo total de práctica.
  - Ranking de alumnos por tiempo de estudio.
  - Gráfico de barras: Actividad semanal de la clase.
  - Lista de tareas con estadísticas agregadas.
  - Identificar alumnos con poca actividad.
- [ ] **Implementar Filtros Avanzados**:
  - Selector de clase.
  - Selector de período.
  - Filtro por tarea.
- [ ] **Tests**:
  - Tests unitarios del Cubit.
  - Tests de widget para la UI.

### 🔄 Fase 5: Integración con Navigation
**Objetivo:** Conectar las pantallas de estadísticas con el flujo de la app.

- [ ] **Actualizar Navegación**:
  - Tab de Estadísticas en BottomNavigationBar ya existente.
  - Rutas en GoRouter para navegación profunda.
- [ ] **Conectar con Pantallas Existentes**:
  - Desde detalle de clase → Ver estadísticas de clase.
  - Desde detalle de tarea → Ver estadísticas de tarea.
  - Desde perfil de alumno (docente) → Ver estadísticas del alumno.
- [ ] **Probar Flujo Completo**:
  - Navegación sin glitches.
  - Estados de carga y error correctos.

### 📤 Fase 6: Exportación de Datos (Opcional)
**Objetivo:** Permitir exportar estadísticas para uso externo.

- [ ] **Exportación CSV**:
  - Generar archivo CSV con datos de sesiones.
  - Compartir mediante Share Sheet del sistema.
- [ ] **Generación de Reportes PDF**:
  - Crear PDF con resumen de estadísticas.
  - Incluir gráficos como imágenes.
  - Compartir o guardar en dispositivo.
- [ ] **Tests**:
  - Validar formato de archivos generados.

### ✅ Fase 7: Calidad y Pulido
**Objetivo:** Asegurar la calidad del código y la experiencia de usuario.

- [ ] **Tests de Integración**:
  - Flujo completo de carga de estadísticas.
  - Navegación entre pantallas.
- [ ] **Optimización de Rendimiento**:
  - Caché de consultas frecuentes.
  - Lazy loading de gráficos pesados.
  - Paginación si hay muchos datos.
- [ ] **Code Review & Refactor**:
  - Revisión según `flutter_style_rules`.
  - Eliminar código muerto.
  - Documentar APIs públicas.
- [ ] **Pruebas Manuales**:
  - Probar en dispositivos físicos (iOS y Android).
  - Verificar accesibilidad (VoiceOver/TalkBack).
  - **Checklist de pruebas manuales:**
    1. Abrir pantalla de estadísticas como alumno → Verificar que carga datos.
    2. Cambiar filtro de período (Hoy → Esta Semana → Este Mes) → Verificar que datos cambian.
    3. Tocar un gráfico → Verificar que muestra tooltip con información.
    4. Abrir estadísticas como docente → Verificar ranking de alumnos.
    5. Filtrar por clase → Verificar que solo muestra datos de esa clase.
    6. Navegar desde detalle de tarea a estadísticas de tarea → Verificar datos.
    7. Probar con datos vacíos (alumno nuevo sin sesiones) → Verificar mensaje apropiado.
    8. Ejecutar `flutter analyze` → Sin errores ni warnings.
    9. Ejecutar `flutter test` → Todos los tests pasando.

### 🏁 Fase 8: Cierre y Planificación
**Objetivo:** Cerrar el sprint y preparar el siguiente.

- [ ] **Verificación Final**:
  - Ejecutar `flutter analyze` y confirmar 0 errores.
  - Ejecutar `flutter test` y confirmar todos los tests pasando.
  - Revisar que todos los criterios de aceptación se cumplen.
- [ ] **Actualizar Documentación**:
  - Actualizar `docs/Guia_Proyecto_PlayingTracker.md`:
    - Progreso del Sprint 6 al 100%.
    - Estado del proyecto actualizado.
    - Documentar nuevas funcionalidades en secciones correspondientes.
  - Marcar todas las fases de este documento como completadas.
- [ ] **Preparar Sprint 7**:
  - Crear el documento `docs/sprints/SPRINT_7_IMPLEMENTACION.md` siguiendo la estructura y estándares definidos en `docs/Guia_Proyecto_PlayingTracker.md`.
  - Definir objetivos, fases y entregables para el módulo de Testing y Optimización según el roadmap:
    - 🧪 Testing completo (Unit, Widget, Integration)
    - 🌐 Internacionalización (l10n) y Refactorización de Strings profesional (archivos .arb)
    - 🧭 **Refactorización de Navegación**: Modularización de `app_routes.dart` y migración a **Typed Routes** (Type-safety).
    - ⚡ Optimización de rendimiento
    - 🔒 Auditoría de seguridad
    - 📱 Testing de accesibilidad
    - 🚀 Preparación para producción

---

## 🛠️ Archivos Clave a Crear/Modificar

### Nuevos Archivos
- `lib/features/statistics/domain/models/daily_stats_model.dart`
- `lib/features/statistics/domain/models/weekly_stats_model.dart`
- `lib/features/statistics/domain/models/task_stats_model.dart`
- `lib/features/statistics/domain/models/class_stats_model.dart`
- `lib/features/statistics/data/services/statistics_service.dart`
- `lib/features/statistics/data/repositories/statistics_repository.dart`
- `lib/features/statistics/presentation/cubit/student_stats_cubit.dart`
- `lib/features/statistics/presentation/cubit/teacher_stats_cubit.dart`
- `lib/features/statistics/presentation/screens/student_statistics_screen.dart`
- `lib/features/statistics/presentation/screens/teacher_statistics_screen.dart`
- `lib/features/statistics/presentation/widgets/bar_chart_widget.dart`
- `lib/features/statistics/presentation/widgets/pie_chart_widget.dart`
- `lib/features/statistics/presentation/widgets/progress_chart_widget.dart`

### Archivos a Modificar
- `lib/config/routes/app_routes.dart` - Agregar rutas de estadísticas
- `pubspec.yaml` - Agregar dependencia `fl_chart`
- `lib/core/constants/app_strings.dart` - Agregar strings de estadísticas

---

## 📐 Diseño de Datos

### Consultas Principales

```dart
// Estadísticas diarias de un alumno
sessions
  .where('studentId', isEqualTo: studentId)
  .where('dateLogged', isEqualTo: dateTimestamp)
  .get()

// Estadísticas mensuales usando monthBucket
sessions
  .where('studentId', isEqualTo: studentId)
  .where('monthBucket', isEqualTo: '2026-01')
  .get()

// Estadísticas de clase para docente
sessions
  .where('teacherId', isEqualTo: teacherId)
  .where('taskId', isEqualTo: taskId)
  .get()
```

### Campos Agregados Existentes

Los contadores ya implementados en Sprint 5 que se reutilizarán:
- `assignments.sessionsCount`: Número de sesiones por tarea-alumno
- `assignments.totalDurationLogged`: Tiempo total por tarea-alumno
- `students.totalPracticeTime`: Tiempo total del alumno (todos los registros)
- `students.totalSessions`: Número total de sesiones del alumno

---

## ✅ Criterios de Aceptación

1. ✓ El alumno puede ver sus estadísticas de tiempo de estudio.
2. ✓ El docente puede ver estadísticas agregadas de sus clases/alumnos.
3. ✓ Los gráficos muestran datos correctos y son interactivos.
4. ✓ Los filtros funcionan correctamente (fecha, clase, tarea).
5. ✓ La UI sigue Material Design 3 y es coherente con el resto de la app.
6. ✓ Los tests unitarios y de widget cubren la funcionalidad principal.
7. ✓ El rendimiento es aceptable (carga < 2 segundos en datos moderados).

---

## 📚 Referencias

- **Guía del Proyecto:** `docs/Guia_Proyecto_PlayingTracker.md`
- **Sprint Anterior:** `docs/sprints/SPRINT_5_IMPLEMENTACION.md`
- **Librería de Gráficos:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Material Design 3:** [Data Visualization Guidelines](https://m3.material.io/styles/color/data-visualization)

---

## 🏁 Notas de Cierre

- Este sprint depende de la completitud del Sprint 5 (cronómetro y sesiones).
- La Fase 6 (Exportación) es opcional y puede posponerse a un sprint posterior.
- Se recomienda priorizar la experiencia del alumno (Fase 3) antes que la del docente (Fase 4).
