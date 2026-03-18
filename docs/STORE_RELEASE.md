# Guía de Release en App Store y Google Play

## Primera publicación (manual)

La primera subida a cada store debe hacerse manualmente desde la web.
Usa esta guía para preparar todo el material necesario.

---

## Prerrequisitos (solo la primera vez)

### 1. Instalar dependencias Fastlane

```bash
cd fastlane && bundle install && cd ..
```

### 2. Configurar credenciales iOS (App Store Connect)

1. Ve a [App Store Connect](https://appstoreconnect.apple.com) → Usuarios y acceso → Claves de API
2. Crea una nueva clave con rol **App Manager**
3. Descarga el archivo `AuthKey_XXXXXXXXXX.p8`
4. Guárdalo en `fastlane/AuthKey_XXXXXXXXXX.p8` (está en `.gitignore`)
5. Crea el archivo `fastlane/.env`:

```
APP_STORE_CONNECT_API_KEY_KEY_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_KEY_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=./AuthKey_XXXXXXXXXX.p8
```

### 3. Configurar credenciales Android (Google Play)

1. Ve a [Google Play Console](https://play.google.com/console) → Configuración → Acceso a la API
2. Vincula un proyecto de Google Cloud o crea uno nuevo
3. Crea una **Service Account** con rol de Administrador de Versiones
4. Descarga la clave JSON y guárdala como `fastlane/gc_keys.json` (está en `.gitignore`)

---

## Flujo de release (versiones posteriores)

### Antes de cada release

Actualiza las notas de versión:

```bash
# Edita con los cambios reales de esta versión
nano fastlane/metadata/en-US/release_notes.txt
nano fastlane/metadata/es-ES/release_notes.txt
```

### Generar screenshots (solo si cambió la UI)

```bash
# iOS — requiere simulador "iPhone 15 Pro Max" disponible
make screenshots-ios

# Android — requiere emulador corriendo
# Arrancarlo con: flutter emulators --launch <id>
make screenshots-android
```

Los screenshots se guardan en `fastlane/screenshots/` (no se commitean).

### Subir metadatos y screenshots

```bash
# Solo iOS
make store-upload-ios

# Solo Android
make store-upload-android

# Ambas tiendas a la vez
make store-release
```

### Subir el binario

El binario se sube **por separado** de los metadatos:

```bash
# iOS — genera IPA
make ipa
# Luego subir con Xcode Organizer o Transporter

# Android — genera AAB
make aab
# Luego subir en Google Play Console → Versiones de producción
```

---

## Estructura de archivos

```
fastlane/
├── Gemfile                    # Dependencias Ruby (versionado)
├── Gemfile.lock               # Lock de versiones (versionado)
├── Appfile                    # Bundle ID y Apple ID
├── Fastfile                   # Lanes de automatización
├── Deliverfile                # Configuración entrega iOS
├── .env                       # API Key iOS (NO en git)
├── AuthKey_*.p8               # Clave privada App Store (NO en git)
├── gc_keys.json               # Service Account Android (NO en git)
├── metadata/
│   ├── en-US/                 # Textos App Store en inglés
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   ├── release_notes.txt  # ← Actualizar en cada release
│   │   ├── privacy_url.txt
│   │   └── support_url.txt
│   ├── es-ES/                 # Textos App Store en español
│   └── android/
│       ├── en-US/             # Textos Play Store en inglés
│       └── es-ES/             # Textos Play Store en español
└── screenshots/               # Generadas (NO en git)

scripts/
├── screenshots_ios.sh         # Captura screenshots en simulador iOS
└── screenshots_android.sh     # Captura screenshots en emulador Android

integration_test/
├── screenshots_test.dart      # Test que navega la app y captura pantallas
└── helpers/
    ├── screenshot_helper.dart      # Función captureScreenshot()
    └── screenshot_mock_data.dart   # Datos realistas para las capturas
```

---

## Solución de problemas

### "No se encontró el contenedor de la app" (iOS)

La app no se instaló correctamente durante el test. Soluciones:
- Verifica que el Bundle ID es correcto: `com.gabriom.playingtrackerapp`
- Asegúrate de que el simulador está arrancado antes de ejecutar el script
- Prueba ejecutando el test directamente: `flutter test integration_test/screenshots_test.dart -d "iPhone 15 Pro Max"`

### "No hay emulador Android corriendo"

```bash
# Ver emuladores disponibles
flutter emulators

# Arrancar un emulador
flutter emulators --launch <emulator_id>
```

### Error de autenticación en App Store Connect

- Verifica que `fastlane/.env` existe y tiene los valores correctos
- Comprueba que el archivo `.p8` existe en la ruta indicada en `.env`
- La clave no debe haber sido revocada en App Store Connect

### Error de autenticación en Google Play

- Verifica que `fastlane/gc_keys.json` existe
- La Service Account necesita permisos de **Administrador de versiones** en Play Console
- Accede a Google Play Console → Configuración → Acceso a la API para verificar

---

## Testing manual recomendado antes de publicar

### Android (rol estudiante)

1. Instalar APK de release en dispositivo físico Android
2. Iniciar sesión como estudiante
3. Navegar por: Inicio → Estadísticas → Perfil

### iOS (rol profesor)

1. Instalar IPA via TestFlight o directamente en dispositivo
2. Iniciar sesión como profesor
3. Navegar por: Inicio → Clases → Ajustes
