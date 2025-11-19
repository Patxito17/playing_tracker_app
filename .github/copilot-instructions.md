<!-- Copilot Instructions for Playing Tracker (es) -->
# Instrucciones para agentes AI (Playing Tracker)

> **Referencia oficial:**
> - [Flutter Documentation](https://docs.flutter.dev)
> - [Dart Documentation](https://dart.dev/guides)
> - [Firebase for Flutter](https://firebase.flutter.dev/docs/overview)
> - [Bloc/Cubit](https://bloclibrary.dev/#/)
> - [GoRouter](https://pub.dev/packages/go_router)


Este archivo contiene la información mínima y accionable que un agente de codificación necesita para ser productivo en este repositorio Flutter + Firebase.

**Resumen arquitectónico (rápido):**
- Sigue la arquitectura Feature-First y las convenciones de estado, navegación y serialización recomendadas en la documentación oficial de Flutter y Dart.
- Arquitecture: Feature-First (carpeta `lib/features/`). Cada feature agrupa modelos, repositorios, cubits, vistas y widgets.
- Estado: `flutter_bloc` con Cubits. Buscar `lib/**/cubits` o `lib/**/bloc`.
- Navegación: `go_router` (configurada en `lib/config/routes/app_routes.dart`).
- Serialización: `json_serializable` con `build_runner` (archivos `*.g.dart` generados junto a los modelos).

**Archivos clave y patrones detectables**
- `lib/main.dart`: punto de entrada; usa `AppRoutes.router` y `AppTheme`.
- `pubspec.yaml`: dependencias (ej. `go_router`, `flutter_bloc`, `json_serializable`).
- `lib/firebase_options.dart`: configuración de Firebase por plataforma (API keys visibles; seguridad basada en reglas de Firestore).
- `firebase/firestore.rules` y `firebase/firestore.indexes.json`: reglas e índices de producción — respeta esas reglas al cambiar estructura de datos.
- `docs/` y `docs/components/COMPONENTS_GUIDE.md`: referencia de diseño y componentes reutilizables.

**Comandos de desarrollo (macOS / zsh)**
Consulta siempre la documentación oficial para comandos avanzados y troubleshooting.
- `flutter pub get` — instalar dependencias.
- `dart run build_runner build --delete-conflicting-outputs` — regenerar serializadores `*.g.dart`.
- `dart format .` — formateo.
- `flutter analyze` — análisis estático.
- `flutter test` — ejecutar tests.
- `flutter run -d <device>` — correr en dispositivo/emulador.
- `flutter build apk` / `flutter build ios` — builds.

Si vas a tocar modelos o anotaciones JSON, siempre regenera con `build_runner` y ejecuta `flutter analyze`.

**Convenciones específicas del proyecto**
- Para estados, usa sealed classes nativas de Dart 3 o Freezed (opcional). Para modelos, usa json_serializable. Ejemplos y convenciones en `.cursor/rules/flutter_style_rules.mdc`.
- Organización Feature-First: agrega nuevas funciones bajo `lib/features/<feature>/...`.
- Modelos inmutables con `copyWith` y `TimestampConverter` para Firestore timestamps (buscar en `lib/core` o `lib/features/*/models`).
- Extensiones y utilidades centralizadas en `lib/core/extensions` y `lib/core/utils`.
- Temas y rutas en `lib/config/theme/` y `lib/config/routes/`.
- Strings y estilos centralizados (`app_strings.dart`, `AppTextStyles`) — evita duplicarlos.

**Integraciones y consideraciones de seguridad**
- Revisa la [documentación oficial de Firebase](https://firebase.google.com/docs/firestore/security/get-started) para reglas y buenas prácticas de seguridad.
- Firebase ya configurado: `lib/firebase_options.dart` + `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` presentes.
- Las API keys en `lib/firebase_options.dart` son intencionalmente públicas; valida la seguridad en `firebase/firestore.rules` antes de exponer nuevas colecciones o campos.

**Ejemplos concretos (código/ubicaciones)**
- Añadir un nuevo Cubit para la feature `sessions` → colocar en `lib/features/sessions/cubit/` y tests en `test/features/sessions/`.
- Si creas un nuevo modelo `SessionModel`, añade las anotaciones `@JsonSerializable()` y ejecuta `dart run build_runner build --delete-conflicting-outputs`.
- Para cambiar rutas globales, editar `lib/config/routes/app_routes.dart` y actualizar los guards según roles (`isTeacher()` / `isStudent()` logic está en repositorios/servicios de auth).

**Checks rápidos antes de abrir PR**
5. **Actualiza la documentación en `/docs`**: Cada cambio relevante (modelos, arquitectura, features, sprints, componentes, reglas) debe reflejarse en los archivos de `/docs` (Guía, sprints, componentes, etc). Mantén sincronizados los cambios y registra el historial de modificaciones.
1. `dart format .` ✅
2. `flutter analyze` ✅
3. Regenerar `*.g.dart` si tocaste modelos: `dart run build_runner build --delete-conflicting-outputs` ✅
4. Asegurarse de no romper reglas de Firestore; ejecutar `firebase deploy --only firestore:rules --dry-run` si cambias reglas.

**Dónde consultar estilo y reglas del equipo**
- Las reglas vivas y ejemplos de patrones están en `.cursor/rules/flutter_style_rules.mdc`. Si hay conflicto entre dependencias o convenciones, consulta la documentación oficial y pide confirmación.
- Reglas de estilo Flutter: `.cursor/rules/flutter_style_rules.mdc`.
- Guía de componentes: `docs/components/COMPONENTS_GUIDE.md`.


**Documentación y registro de cambios**
- Siempre que realices cambios en el código, arquitectura, modelos, rutas, roles, o cualquier feature, **actualiza la documentación correspondiente en `/docs`**. Esto incluye:
	- `docs/Guia_Proyecto_PlayingTracker.md` para arquitectura y roadmap
	- `docs/sprints/SPRINT_X_IMPLEMENTACION.md` para avances y tareas
	- `docs/components/COMPONENTS_GUIDE.md` para nuevos widgets/componentes
	- Cualquier otro documento relevante
- Añade fecha y breve descripción del cambio en la documentación.
- Si tienes dudas sobre cómo documentar, consulta los ejemplos y checklists en `.cursor/rules/flutter_style_rules.mdc`.

Si algo en el repositorio no es evidente (por ejemplo, flujos auth-roles o decisiones de seguridad), pregunta: ¿quieres que verifique `firebase/firestore.rules` y resuma las políticas actuales para roles y colecciones?

---
Si quieres que integre o preserve contenido previo en un `.github/copilot-instructions.md` existente, indícame y haré una fusión específica.

Última revisión automática: 19 de noviembre de 2025
