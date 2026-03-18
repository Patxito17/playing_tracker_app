# Guía de Release — Playing Tracker

Documento operativo para publicar nuevas versiones en App Store (iOS) y Google Play (Android).

> **Credenciales:** Ya configuradas en `fastlane/.env` y `fastlane/gc_keys.json`.
> Esos archivos no están en git. Si trabajas desde un Mac nuevo, ver sección [Restaurar credenciales](#restaurar-credenciales-en-un-mac-nuevo).

---

## Índice

1. [Primera publicación — iOS (manual)](#1-primera-publicación--ios-manual)
2. [Primera publicación — Android (manual)](#2-primera-publicación--android-manual)
3. [Release posterior — flujo normal](#3-release-posterior--flujo-normal)
4. [Cuándo regenerar screenshots](#4-cuándo-regenerar-screenshots)
5. [Restaurar credenciales en un Mac nuevo](#5-restaurar-credenciales-en-un-mac-nuevo)
6. [Solución de problemas](#6-solución-de-problemas)

---

## 1. Primera publicación — iOS (manual)

La primera subida del binario a App Store Connect debe hacerse desde Xcode o Transporter.
Fastlane **no puede** subir el primer binario; sí puede subir metadatos y screenshots.

### 1.1 Crear el listing en App Store Connect

1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Mis Apps → +** → Nueva app
3. Rellena:
   - Plataformas: iOS
   - Nombre: `Playing Tracker`
   - Idioma principal: Español (España) o Inglés
   - Bundle ID: `com.gabriom.playingtrackerapp`
   - SKU: `playing-tracker-001` (cualquier identificador único tuyo)
4. Pulsa **Crear**

### 1.2 Generar screenshots

```bash
# Abre el simulador "iPhone 15 Pro Max" en Xcode antes de ejecutar
make screenshots-ios
```

Los screenshots quedan en `fastlane/screenshots/en-US/` y `fastlane/screenshots/es-ES/`.

### 1.3 Subir metadatos y screenshots con Fastlane

```bash
make store-upload-ios
```

Esto sube descripciones, keywords, notas de versión y screenshots a App Store Connect.

### 1.4 Generar y subir el binario

```bash
# Incrementa el build number y genera el IPA firmado
make build-all
```

El IPA queda en `releases/ipa/`. Súbelo desde Xcode:
- Xcode → **Product → Archive** → Ventana Organizer → **Distribute App** → App Store Connect

O con Transporter (app gratuita del Mac App Store).

### 1.5 Completar en App Store Connect

1. Ve a la app → **Información de la app** → completa categoría, clasificación de edad, copyright
2. Ve a la pestaña **Precios y disponibilidad** → configura precio (gratuita) y territorios
3. En la versión pendiente → **Enviar para revisión**

> La revisión de Apple suele tardar 24–48 horas.

---

## 2. Primera publicación — Android (manual)

Google Play también requiere subir el primer AAB manualmente desde la consola web.

### 2.1 Configurar el listing en Play Console

1. Ve a [play.google.com/console](https://play.google.com/console) → tu app en borrador
2. Completa el **Panel de configuración** (todas las tareas marcadas como pendientes):
   - Ficha de Play Store → descripción, screenshots, icono, imagen de portada
   - Clasificación del contenido → completa el cuestionario
   - Público objetivo → selecciona edad mínima
   - App de noticias → No
   - Apps de acceso a datos → completa el formulario de seguridad de datos

### 2.2 Generar screenshots

```bash
# Arranca un emulador Android antes de ejecutar
flutter emulators --launch <id_emulador>   # ver IDs con: flutter emulators
make screenshots-android
```

### 2.3 Subir metadatos con Fastlane

```bash
make store-upload-android
```

### 2.4 Subir el AAB

```bash
make build-all
```

El AAB queda en `releases/aab/`. Súbelo desde Play Console:
- Tu app → **Versiones** → **Producción** → **Crear nueva versión** → sube el `.aab`

### 2.5 Enviar a revisión

- Revisa el resumen de la versión → **Guardar** → **Enviar a revisión**

> La revisión de Google suele tardar desde unas horas hasta 3 días.

---

## 3. Release posterior — flujo normal

Este es el flujo para todas las versiones después de la primera.

### Paso 1 — Actualizar las notas de versión

Edita estos dos archivos con los cambios reales de esta versión:

```
fastlane/metadata/en-US/release_notes.txt
fastlane/metadata/es-ES/release_notes.txt
```

Formato recomendado:
```
• Nueva funcionalidad X
• Corrección del bug Y
• Mejoras de rendimiento
```

### Paso 2 — Generar el build

```bash
make build-all
```

Esto incrementa el build number automáticamente y genera IPA + APK + AAB en la carpeta `releases/`.

### Paso 3 — Subir metadatos a las stores

```bash
make store-release
```

Sube descripciones, keywords, notas de versión y screenshots (si los hay) a ambas stores.

### Paso 4 — Subir el binario iOS

Desde Xcode Organizer o Transporter, sube el IPA de `releases/ipa/` a App Store Connect.

En App Store Connect → tu app → la nueva versión aparecerá automáticamente al procesar el binario → añade las notas de versión si no se subieron → **Enviar para revisión**.

### Paso 5 — Subir el binario Android

En [Play Console](https://play.google.com/console) → tu app → **Versiones** → **Producción** → **Crear nueva versión** → sube el `.aab` de `releases/aab/`.

Revisa y **Enviar a revisión**.

---

## 4. Cuándo regenerar screenshots

Los screenshots **no se guardan en git** y deben regenerarse antes de subirlos si la UI ha cambiado.

| Situación | ¿Regenerar? |
|---|---|
| Solo se corrigen bugs, sin cambios visuales | No |
| Se añade o modifica una pantalla | Sí |
| Se cambia el tema/colores/tipografía | Sí |
| Primera publicación | Sí (obligatorio) |

```bash
# iOS — necesita simulador "iPhone 15 Pro Max" arrancado
make screenshots-ios

# Android — necesita emulador corriendo
make screenshots-android

# Ambos a la vez
make screenshots
```

Los screenshots se organizan automáticamente en:
```
fastlane/screenshots/
├── en-US/iPhone 15 Pro Max/    ← App Store EN
├── es-ES/iPhone 15 Pro Max/    ← App Store ES
├── en-US/Pixel 7 Pro/          ← Play Store EN
└── es-ES/Pixel 7 Pro/          ← Play Store ES
```

---

## 5. Restaurar credenciales en un Mac nuevo

Los archivos de credenciales no están en git. Si cambias de Mac o los pierdes:

### iOS

1. Ve a [App Store Connect](https://appstoreconnect.apple.com) → Usuarios y acceso → Claves de API
2. La clave `XPCURJHGMJ` ya existe — si tienes el `.p8` original, cópialo a `fastlane/`
3. Si no tienes el `.p8`, revoca la clave y crea una nueva (actualiza `fastlane/.env`)
4. Crea `fastlane/.env`:

```
APP_STORE_CONNECT_API_KEY_KEY_ID=XPCURJHGMJ
APP_STORE_CONNECT_API_KEY_ISSUER_ID=8a777dde-2292-4fc7-a57b-9fe17c1e83a0
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=./AuthKey_XPCURJHGMJ.p8
```

### Android

1. Ve a [Play Console](https://play.google.com/console) → Configuración → Acceso a la API
2. Localiza la Service Account `fastlane-playing-tracker`
3. Crea una nueva clave JSON → guárdala como `fastlane/gc_keys.json`

### Verificar que todo funciona

```bash
# Verificar conexión iOS
cd fastlane && bundle exec fastlane run app_store_connect_api_key \
  key_id:XPCURJHGMJ \
  issuer_id:8a777dde-2292-4fc7-a57b-9fe17c1e83a0 \
  key_filepath:./AuthKey_XPCURJHGMJ.p8

# Verificar conexión Android
cd fastlane && bundle exec fastlane run validate_play_store_json_key json_key:./gc_keys.json
```

---

## 6. Solución de problemas

### Screenshots iOS: "No se encontró el contenedor de la app"

La app no quedó instalada en el simulador tras el test.

```bash
# Verifica que el simulador está arrancado
xcrun simctl list devices | grep "iPhone 15 Pro Max"

# Ejecuta el test directamente para ver el error
flutter test integration_test/screenshots_test.dart -d "iPhone 15 Pro Max"
```

### Screenshots Android: "No hay emulador corriendo"

```bash
flutter emulators                          # lista los disponibles
flutter emulators --launch <emulator_id>   # arranca uno
```

### Fastlane: error de autenticación iOS

```bash
# Comprueba que el .env tiene los valores correctos
cat fastlane/.env

# Comprueba que el .p8 existe
ls fastlane/AuthKey_XPCURJHGMJ.p8
```

### Fastlane: error de autenticación Android

```bash
# Comprueba que el JSON existe y es válido
cat fastlane/gc_keys.json | python3 -m json.tool | head -5
```

Si el JSON es válido pero falla, verifica en Play Console que la Service Account tiene el permiso **Administrador de versiones**.

### Build number no se incrementa

```bash
make bump-build    # solo sube el número sin compilar
```

### `bundle exec fastlane` no funciona desde raíz del proyecto

Los comandos de Fastlane deben ejecutarse desde el directorio `fastlane/` o usando los targets del Makefile (que ya hacen `cd fastlane` automáticamente).

```bash
# Correcto
make store-release

# También correcto
cd fastlane && bundle exec fastlane ios upload_metadata
```
