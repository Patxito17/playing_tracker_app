# SPRINT 7: Testing, l10n y Optimización Profesional

**Estado:** ✅ COMPLETADO
**Fecha de inicio:** 2026-01-26
**Fecha de completación:** 11 de Marzo 2026
**Duración estimada:** 3 semanas

---

## 🎯 Objetivos del Sprint

1.  **Testing Integral:** Alcanzar una cobertura robusta mediante tests unitarios, de widget e integración.
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
    - **Suite total:** 360 tests ✅ (100% code stability).
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

### 🔒 Fase 4: Seguridad y Accesibilidad ✅ COMPLETADA
**Objetivo:** Preparar la aplicación para el cumplimiento normativo y uso universal.
**Fecha de completación:** 2 de Marzo 2026

- [x] **Auditoría de Seguridad**:
    - [x] Validaciones espejo en Firestore Rules (`isValidName`, `isValidTitle`, `isValidDescription`) para prevenir bypasses via REST API.
    - [x] `lib/core/utils/validators.dart`: límites de longitud (60 nombres, 100 títulos/email), sanitización mínima (trim + colapso de espacios múltiples). Nuevo validador `Validators.title()`.
    - [x] Reglas publicadas en Firebase: `firebase deploy --only firestore:rules` ✅ publicadas y validadas el 11 de Marzo de 2026.
- [x] **Accesibilidad (A11y)**:
    - [x] `CustomCard`: `MergeSemantics` contextual (sin acciones = merge todo; con acciones = Semantics individual) + propiedad `semanticLabel` personalizable.
    - [x] `LoadingOverlay`: `Semantics(liveRegion: true)` + anuncio de "Carga completada" via `SemanticsService.sendAnnouncement` al finalizar el `Future`.
    - [x] Tests semánticos de árbol A11y añadidos en `test/shared/widgets/shared_widgets_test.dart` (5 nuevos tests, **30 tests totales ✅**).
    - [x] `CustomTextField` expone `FocusNode` externo para focus management desde formularios padre.

### 🚀 Fase 5: Preparación para Lanzamiento — Production-Ready 2026 ✅ COMPLETADA
**Objetivo:** Generar los artefactos finales para producción con estándar moderno 2026.
**Fecha de completación:** 2 de Marzo 2026

#### 5.1 Consentimiento Legal Versionado (RGPD/GDPR)

- [x] **Modelos actualizados** (`TeacherModel`, `StudentModel`):
    - `acceptedTermsVersion` (String, nullable): versión de T&C aceptada.
    - `acceptedTermsAt` (Timestamp, nullable): timestamp de aceptación.
    - Archivos `.g.dart` regenerados con `build_runner`.
- [x] **Constante de versión** en `lib/core/constants/legal_constants.dart`:
    - `kCurrentTermsVersion = '1.0'` — cambiar este valor fuerza re-aceptación global.
- [x] **Assets Markdown Legales** en `assets/legal/`:
    - `terms_es.md` / `terms_en.md`: Términos y Condiciones + Política de Privacidad con referencias RGPD, Firebase/US transfer disclosure, y versión explícita.
    - `terms_version.txt`: archivo de versión actual.
    - Assets registrados en `pubspec.yaml`.
- [x] **Diálogo `LegalConsentDialog`** (`lib/features/auth/presentation/widgets/legal_consent_dialog.dart`):
    - UX de consentimiento informado: scroll obligatorio antes de habilitar el botón Aceptar.
    - Checkbox de aceptación explícita habilitado solo al llegar al final del texto.
    - Gradiente indicador de contenido pendiente de scroll.
    - Render Markdown básico integrado (sin dependencias externas): `# h1`, `## h2`, `**bold**`, `---`.
    - Soporte para modo "re-aceptación" cuando los T&C se actualizan.
- [x] **`RegisterScreen` integrado**:
    - Tap en "términos y condiciones" o "política de privacidad" abre `LegalConsentDialog`.
    - Si el usuario acepta, el checkbox se activa automáticamente.
    - Texto legal cargado desde assets según locale del usuario (ES/EN).
- [x] **Strings l10n** añadidos a `app_es.arb` y `app_en.arb`:
    - `legalConsentTitle`, `legalConsentScrollInstruction`, `legalConsentCheckboxLabel`, `legalConsentAcceptButton`, `legalConsentDeclineButton`, `legalConsentVersionLabel`, `legalConsentUpdatedTitle`, `legalConsentUpdatedMessage`, `privacyPolicyTitle`, `termsAndConditionsTitle`.

#### 5.2 Ofuscación y Builds de Producción

- [x] **Builds con ofuscación**:
    - Android: `flutter build appbundle --obfuscate --split-debug-info=build/symbols/android`
    - iOS: `flutter build ipa --obfuscate --split-debug-info=build/symbols/ios`
- [x] **Subida de símbolos a Firebase Crashlytics**:
    - `firebase crashlytics:symbols:upload --app=<APP_ID> build/symbols/android/`
    - Permite deofuscar stack traces en producción para depuración efectiva.

#### 5.3 CI/CD con GitHub Actions

- [x] **Workflow** `.github/workflows/production_build.yml`:
    - Se activa en tags `v*.*.*` (e.g., `v1.0.0`).
    - Job `quality_check`: lint + tests antes de compilar.
    - Job `build_android`: AAB firmado con keystore + upload de símbolos a Crashlytics.
    - Job `build_ios`: IPA con obfuscation + upload de dSYM.
    - Artifacts versionados en GitHub Actions.
    - **Secrets necesarios**: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `FIREBASE_CLI_TOKEN`.
    - **Variables de entorno**: `FIREBASE_APP_ID_ANDROID`, `FIREBASE_APP_ID_IOS`.

---

### Corrección de Errores y Optimizaciones Finales (11/03/2026)

- **Corrección de ruteo**: Se solventó un `_TypeError` al navegar a `CompleteProfileScreen` ajustando el casting de `state.extra` de `Map<String, String?>?` a `Map<String, dynamic>?`.
- **Persistencia UI**: Se implementó un fallback en `CompleteProfileScreen` para recuperar datos del perfil directamente desde el estado de `AuthCubit`, evitando fallos si los datos de navegación se pierden en una redirección o recarga.
- **UX y UI**: 
  - Pre-rellenado automático de nombre y apellidos extraídos del `displayName` de Google.
  - Independización de estados de carga en `LoginScreen` para evitar indicadores redundantes en el botón de Google Sign-In.
- **Validación y Permisos**:
  - Actualización de `Validators.dart` y `firestore.rules` para permitir nombres de **2 caracteres**, resolviendo errores de "Permission Denied" para usuarios con nombres cortos.
- **Localización**:
  - Implementación de `FirebaseErrorMapper` y extensión `context.translateError()` para mostrar errores de autenticación localizados según el idioma del dispositivo.
- **Seguridad**: Revisión final y despliegue exitoso de las reglas de Firestore para la arquitectura de 7 colecciones.

### Estado de Verificación Automática
- [x] Unit Tests: 360/360 pass.
- [x] Integration Tests: Pass.
- [x] Golden Tests: Pass.

---

## 🧪 Instrucciones de Verificación en Simuladores

### Simulador Android (Perfil Alumno)
1. Lanzar la app en el emulador Android.
2. Pulsar "Crear cuenta" — en el campo de términos y condiciones pulsar el texto subrayado "términos y condiciones".
3. **Verificar**: se abre el diálogo `LegalConsentDialog` con el texto legal completo en español.
4. **Verificar**: el botón "Aceptar y continuar" está **deshabilitado** hasta llegar al final del scroll.
5. Hacer scroll hasta el final → el checkbox se habilita.
6. Marcar el checkbox → el botón "Aceptar y continuar" se habilita.
7. Aceptar → el checkbox del formulario se marca automáticamente.
8. Completar el registro con rol **alumno** y verificar que el login funciona correctamente.

### Simulador iOS (Perfil Docente)
1. Lanzar la app en el simulador iOS.
2. Mismo flujo anterior con rol **docente**.
3. **Verificar**: el idioma del diálogo cambia según la configuración del sistema (ES → `terms_es.md`, EN → `terms_en.md`).
4. Verificar que el tap en "política de privacidad" también abre el mismo diálogo completo.
5. Pulsar "No acepto" → el checkbox del formulario **no** se activa.
6. Completar registro → verificar navegación al Dashboard del docente sin errores.

---

## ✅ Criterios de Aceptación
1.  ✓ Todos los strings son gestionados mediante el sistema l10n de Flutter.
2.  ✓ La cobertura de tests es superior al 80% en lógica de negocio.
3.  ✓ La app cumple con los estándares básicos de accesibilidad WCAG.
4.  ✓ El consentimiento legal es explícito, versionado y conforme RGPD.
5.  ✓ Los builds de producción incluyen ofuscación + símbolos para Crashlytics.
6.  ✓ El pipeline CI/CD está configurado para builds reproducibles.

---

## 📚 Referencias
- **Guía del Proyecto:** `docs/Guia_Proyecto_PlayingTracker.md`
- **Sprint Anterior:** `docs/sprints/SPRINT_6_IMPLEMENTACION.md`
- **Documentación Flutter:** [Internationalizing Flutter apps](https://docs.flutter.dev/accessibility-and-localization/internationalization)
- **RGPD/GDPR:** [EU Data Privacy Framework](https://www.dataprivacyframework.gov/)
