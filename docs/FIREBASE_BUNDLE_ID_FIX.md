# 🔧 Corrección de Bundle ID - Firebase Configuration

**Fecha:** 13 de Noviembre 2025
**Prioridad:** 🔴 **CRÍTICA** - Debe corregirse antes del Sprint 2 (Autenticación)
**Estado:** ⚠️ Pendiente de corrección

---

## 🚨 Problema Identificado

Existe una **inconsistencia crítica** en los Bundle IDs entre plataformas que puede causar problemas de autenticación y sincronización de datos en Firebase.

### Estado Actual (Incorrecto)

| Plataforma | Bundle ID Actual | Formato |
|-----------|------------------|---------|
| Android | `com.example.playing_tracker` | snake_case ✅ |
| iOS | `com.example.playingTracker` | camelCase ❌ |
| macOS | `com.example.playingTracker` | camelCase ❌ |

### Estado Objetivo (Correcto)

| Plataforma | Bundle ID Objetivo | Formato |
|-----------|-------------------|---------|
| Android | `com.example.playing_tracker` | snake_case ✅ |
| iOS | `com.example.playing_tracker` | snake_case ✅ |
| macOS | `com.example.playing_tracker` | snake_case ✅ |

---

## 🎯 ¿Por qué es importante?

Firebase utiliza el Bundle ID para:
- ✅ Asociar usuarios entre plataformas
- ✅ Sincronizar datos de Firestore/Auth
- ✅ Validar configuraciones de seguridad
- ✅ Gestionar tokens de autenticación

**Sin consistencia:** Un usuario que se registre en iOS no podrá iniciar sesión en Android (o viceversa) porque Firebase los tratará como aplicaciones diferentes.

---

## 📋 Pasos para Corregir el Problema

### Opción A: Cambiar iOS/macOS para coincidir con Android (Recomendado)

Esta es la opción más simple porque solo requiere cambiar iOS/macOS.

#### Paso 1: Cambiar Bundle ID en Xcode (iOS)

1. Abre el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcodeproj
   ```

2. En Xcode:
   - Selecciona el proyecto **Runner** en el navegador de archivos
   - Selecciona el target **Runner**
   - Ve a la pestaña **Signing & Capabilities**
   - Cambia el **Bundle Identifier** de:
     - `com.example.playingTracker`
     - a: `com.example.playing_tracker`

3. Guarda los cambios (`Cmd + S`)

#### Paso 2: Cambiar Bundle ID en Xcode (macOS)

1. Abre el proyecto macOS en Xcode:
   ```bash
   open macos/Runner.xcodeproj
   ```

2. En Xcode:
   - Selecciona el proyecto **Runner** en el navegador de archivos
   - Selecciona el target **Runner**
   - Ve a la pestaña **Signing & Capabilities**
   - Cambia el **Bundle Identifier** de:
     - `com.example.playingTracker`
     - a: `com.example.playing_tracker`

3. Guarda los cambios (`Cmd + S`)

#### Paso 3: Regenerar configuración de Firebase con FlutterFire CLI

1. Asegúrate de tener FlutterFire CLI instalado:
   ```bash
   firebase --version
   # Si no está instalado: npm install -g firebase-tools

   flutterfire --version
   # Si no está instalado: dart pub global activate flutterfire_cli
   ```

2. **Configura nuevamente Firebase** (esto regenerará todos los archivos):
   ```bash
   cd /Users/ormog/Desarrollos\ Flutter/playing_tracker
   flutterfire configure
   ```

3. Durante la configuración:
   - Selecciona el proyecto: `playing-tracker-app`
   - Selecciona las plataformas: **iOS, Android, macOS, Web, Windows**
   - Confirma la regeneración de archivos existentes

4. FlutterFire CLI detectará automáticamente el nuevo Bundle ID (`com.example.playing_tracker`) y regenerará:
   - `lib/firebase_options.dart`
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`
   - `android/app/google-services.json` (sin cambios, ya es correcto)

#### Paso 4: Verificar los cambios

1. Verifica que los Bundle IDs ahora coincidan:
   ```bash
   # iOS
   grep -A1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist
   # Debe mostrar: <string>com.example.playing_tracker</string>

   # macOS
   grep -A1 "BUNDLE_ID" macos/Runner/GoogleService-Info.plist
   # Debe mostrar: <string>com.example.playing_tracker</string>

   # Android (sin cambios)
   grep "package_name" android/app/google-services.json
   # Debe mostrar: "package_name": "com.example.playing_tracker"
   ```

2. Verifica `lib/firebase_options.dart`:
   ```bash
   grep "iosBundleId" lib/firebase_options.dart
   # Ambas líneas deben mostrar: iosBundleId: 'com.example.playing_tracker',
   ```

3. Ejecuta análisis de código:
   ```bash
   flutter analyze
   # Debe mostrar: No issues found!
   ```

#### Paso 5: Actualizar Firebase Console (Importante)

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto **playing-tracker-app**
3. Ve a **Project Settings** (⚙️)
4. En la sección **Your apps**, verifica que existan las apps:
   - iOS app con Bundle ID: `com.example.playing_tracker`
   - Android app con Bundle ID: `com.example.playing_tracker`
   - macOS app con Bundle ID: `com.example.playing_tracker`

5. Si aparecen apps antiguas con `com.example.playingTracker`, puedes eliminarlas de forma segura (no tienen datos de producción).

---

### Opción B: Cambiar Android para coincidir con iOS/macOS (No Recomendado)

Esta opción requiere cambios más complejos en archivos nativos de Android. **No se recomienda** a menos que tengas una razón específica.

<details>
<summary>Ver instrucciones (solo si realmente necesitas esta opción)</summary>

#### Paso 1: Cambiar applicationId en Android

Edita `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.example.playingTracker" // Cambiar de playing_tracker
    // ... resto de la configuración
}
```

#### Paso 2: Cambiar namespace en Android

Edita `android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.playingTracker" // Cambiar de playing_tracker
    // ... resto de la configuración
}
```

#### Paso 3: Renombrar estructura de paquetes

1. Renombra el directorio:
   ```bash
   cd android/app/src/main/kotlin/com/example
   mv playing_tracker playingTracker
   ```

2. Edita todos los archivos Kotlin dentro de ese directorio y cambia el package:
   ```kotlin
   package com.example.playingTracker // Cambiar de playing_tracker
   ```

#### Paso 4: Regenerar configuración de Firebase

Sigue los pasos de la Opción A (Paso 3 y 4) para regenerar los archivos de configuración.

</details>

---

## ✅ Checklist de Verificación Final

Antes de comenzar el Sprint 2, verifica que:

- [ ] Los proyectos de Xcode (iOS y macOS) usan `com.example.playing_tracker`
- [ ] `lib/firebase_options.dart` tiene `iosBundleId: 'com.example.playing_tracker'` en ambas plataformas
- [ ] `ios/Runner/GoogleService-Info.plist` tiene `<string>com.example.playing_tracker</string>`
- [ ] `macos/Runner/GoogleService-Info.plist` tiene `<string>com.example.playing_tracker</string>`
- [ ] `android/app/google-services.json` tiene `"package_name": "com.example.playing_tracker"`
- [ ] `flutter analyze` no muestra errores
- [ ] Las apps en Firebase Console tienen Bundle IDs consistentes

---

## 📚 Referencias

- [Firebase Bundle ID Documentation](https://firebase.google.com/docs/projects/learn-more#config-files-objects)
- [FlutterFire CLI Documentation](https://firebase.flutter.dev/docs/cli/)
- [Flutter Platform Setup](https://docs.flutter.dev/get-started/install)

---

## 🆘 Soporte

Si encuentras problemas durante la corrección:

1. **Error en FlutterFire CLI:** Asegúrate de estar autenticado con `firebase login`
2. **Bundle ID no se actualiza:** Limpia el cache de Xcode (`Product > Clean Build Folder`)
3. **Errores de compilación:** Ejecuta `flutter clean` y `flutter pub get`

---

**Nota:** Esta corrección debe completarse **antes de implementar Firebase Authentication** en el Sprint 2 para evitar problemas de autenticación entre plataformas.

