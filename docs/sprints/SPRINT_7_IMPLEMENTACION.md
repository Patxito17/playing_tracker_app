# SPRINT 7: Testing, l10n y Optimización Profesional

**Estado:** ✅ Fase 3 Completada (Filtros de Stats Docente/Alumno) | Fases 4 y 5 pendientes
**Fecha de inicio:** 2026-01-26
**Fecha última actualización:** 2 de Marzo 2026
**Duración estimada:** 3 semanas

---

## 🎯 Objetivos del Sprint

1.  **Testing Integral:** AlcaNZar una cobertura robusta mediante tests unitarios, de widget e integración.
2.  **Internacionalización (l10n):** Migrar todos los strings a archivos `.arb` siguiendo las mejores prácticas de Flutter.
3.  **Calidad de Producción:** Realizar auditoría de seguridad, optimización de rendimiento y pruebas de accesibilidad.
4.  **Optimización:** Mejorar el rendimiento de listas y transiciones.

---

## 📅 Fases de Implementación

### 🏗️ Fase 1: Refactorización de Infraestructura (Navegación y Strings)
**Objetivo:** Modernizar la base técnica del proyecto para escalabilidad.

- [x] **Sistema de Internacionalización**:
    - [x] Configurar `flutter_localizations` y generar archivos `.arb`.
    - [x] Migrar `app_strings.dart` y constantes relacionadas a `AppLocalizations`.
    - [x] Implementar selectores y extensión `context.l10n`.
    - [x] Implementar selector de idioma en la pestaña settings (para estudiantes y docentes) o detección automática.

### 🧪 Fase 2: Suite de Testing Automatizado
**Objetivo:** Garantizar la estabilidad regresiva y la calidad del software.

- [x] **Testing de Cobertura**:
    - [x] Tests unitarios de `StatisticsService` (getDailyStats, getWeeklyStats, getMonthlyStats, getTaskStats, getClassStats) usando `fake_cloud_firestore`.
    - [x] Tests unitarios de `StatisticsRepositoryImpl` (validaciones de argumentos, mapeo de excepciones de dominio).
    - [x] Widget tests para componentes compartidos (`CustomButton`, `CustomTextField`, `LoadingOverlay`, `CustomCard`).
    - [x] `SessionService`, `SessionRepositoryImpl`, `TaskService` y `TaskRepositoryImpl` confirman cobertura completa preexistente.
    - [x] Inyección de dependencia añadida a `StatisticsRepositoryImpl` (parámetro `firestore` opcional).
    - **Suite total:** 345 tests ✅ (65 nuevos tests añadidos en esta fase).
- [x] **Tests de Integración (E2E)**:
    - `integration_test/teacher_flow_test.dart`: flujo docente completo (Registro → Custom Claim → Dashboard → Crear Clase → Éxito).
    - `integration_test/student_flow_test.dart`: flujo alumno completo (Registro → Custom Claim → Dashboard → Pantalla de Clases).
    - Helper compartido `integration_test/helpers/e2e_test_helpers.dart` con generación de emails únicos y limpieza automática de usuarios de prueba.
    - Usa exclusivamente `integration_test` del SDK (sin `flutter_driver`).
    - Flujo del cronómetro (E2E completo alumno) verificado manualmente según el plan (requiere datos previos en Firestore).
- [x] **Golden Tests**:
    - `test/golden/critical_components_golden_test.dart`: 10 casos de test en 4 grupos.
    - `test/flutter_test_config.dart`: comparador de rutas relativas para golden files por componente.
    - Componentes cubiertos: `CustomButton` (4 variantes: filled, outlined, loading, con icón), `CustomCard` (simple y con header), `CustomTextField` (normal y error), `LoadingOverlay` (con y sin mensaje).
    - Imágenes de referencia en `test/golden/goldens/` (10 archivos `.png`).
    - **10 Golden Tests ✅ | 0 fallos | 0 regresiones**.
- [x] **Hotfix: Error de Permisos (Race Condition)**:
    - Diagnosticada la causa: condición de carrera entre el registro en Firestore y la asignación del rol vía Cloud Functions.
    - `AuthRepositoryImpl`: polling robusto de hasta 15 segundos (reintentos con backoff) esperando al Custom Claim.
    - `AuthCubit`: el estado `AuthAuthenticated` solo se emite tras confirmar el rol en el token JWT.
    - 12 tests unitarios de `AuthCubit` actualizados para cubrir el nuevo flujo sincronizado.

### ✅ Fase 3: Estadísticas Avanzadas y Optimización (Implementado)
**Objetivo:** Finalizar los compromisos de datos y mejorar la eficiencia.

- [x] **Filtros Temporales Avanzados (Docente y Alumno)**:
    - [x] Implementar `TimeFilterSelector` (reutilizable) con `SegmentedButton`.
    - [x] Soporte para: Esta semana, Este mes, Últimos 3 meses, Últimos 9 meses, Histórico.
    - [x] Integración en `TeacherStatisticsScreen`, `StudentStatisticsScreen` y `ClassStatisticsTab`.
    - [x] Optimización de consultas Firestore usando `monthBucket` para rangos largos.
- [x] **Caché y Experiencia de Usuario**:
    - [x] Implementar política de caché en memoria con TTL (2 min) en `StatisticsRepositoryImpl`.
    - [x] UI Flicker-free: Preservación de datos previos durante estados de carga (`StudentStatsLoading`, `TeacherStatsLoading`).
    - [x] Barra de progreso sutil superior para indicar refresco de datos sin interrumpir la visualización.

### 🔒 Fase 4: Seguridad y Accesibilidad
**Objetivo:** Preparar la aplicación para el cumplimiento normativo y uso universal.

- [ ] **Auditoría de Seguridad**:
    - Revisión final de reglas de Firestore.
    - Validación de inputs en *edge cases*.
- [ ] **Accesibilidad (A11y)**:
    - Asegurar etiquetas de semántica correctas para VoiceOver/TalkBack.
    - Verificar contraste de colores y escalado de fuentes.

### 🚀 Fase 5: Preparación para Lanzamiento
**Objetivo:** Generar los artefactos finales para producción.

- [ ] **Ofuscación y App Bundles**:
    - Configurar ProGuard/R8.
    - Generar `.aab` para Android y descarga de símbolos para iOS.
- [ ] **Verificación de Criterios legales**:
    - Implementar diálogos de términos y condiciones (placeholders finales).

---

## ✅ Criterios de Aceptación
1.  ✓ Todos los strings son gestionados mediante el sistema l10n de Flutter.
2.  ✓ La cobertura de tests es superior al 80% en lógica de negocio.
3.  ✓ La app cumple con los estándares básicos de accesibilidad WCAG.

---

## 📚 Referencias
- **Guía del Proyecto:** `docs/Guia_Proyecto_PlayingTracker.md`
- **Sprint Anterior:** `docs/sprints/SPRINT_6_IMPLEMENTACION.md`
- **Documentación Flutter:** [Internationalizing Flutter apps](https://docs.flutter.dev/accessibility-and-localization/internationalization)
