# SPRINT 7: Testing, l10n y Optimización Profesional

**Estado:** 📅 Planificado
**Fecha de inicio:** 2026-01-26
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
    - [ ] Implementar selector de idioma en la pestaña settings (para estudiantes y docentes) o detección automática.

### 🧪 Fase 2: Suite de Testing Automatizado
**Objetivo:** Garantizar la estabilidad regresiva y la calidad del software.

- [ ] **Testing de Cobertura**:
    - Implementar tests unitarios faltantes en Repositorios y Servicios.
    - Completar widget tests para componentes compartidos (`shared/widgets`).
- [ ] **Tests de Integración (E2E)**:
    - Crear flujos completos: Registro -> Creación de Clase -> Asignación de Tarea.
    - Flujo de estudio: Login -> Cronómetro -> Ver Estadísticas.
- [ ] **Golden Tests**:
    - Validar consistencia visual de componentes críticos en diferentes resoluciones.

### 📊 Fase 3: Estadísticas Avanzadas y Optimización
**Objetivo:** Finalizar los compromisos de datos y mejorar la eficiencia.

- [ ] **Filtro Temporal Avanzado (Docente)**:
    - Implementar `SegmentedButton` en `TeacherStatisticsScreen`.
    - Optimizar consultas Firestore usando agregaciones por `monthBucket`.
- [ ] **Caché y Rendimiento**:
    - Implementar política de caché para estadísticas históricas.
    - Perfilado de la app con Flutter DevTools para eliminar frames lentos.

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
