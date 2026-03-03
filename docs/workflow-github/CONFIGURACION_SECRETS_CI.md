# 🔐 Guía Completa de Configuración CI/CD para GitHub Actions (2026)

Esta guía te ayudará a configurar manualmente (paso a paso) todos los **Secrets** y **Variables** de entorno necesarios para que el flujo `.github/workflows/production_build.yml` funcione de forma autónoma, segura y profesional.

> [!CAUTION]
> **NUNCA** incluyas archivos sensibles (keystores, certificados `.p8`, perfiles de aprovisionamiento o tokens) directamente en el código fuente del repositorio.

> [!IMPORTANT]
> **¿Dónde están los ajustes?** A lo largo de esta guía se distingue explícitamente entre dos áreas de configuración:
> - 📦 **Ajustes del Repositorio** → `github.com/TU_USUARIO/TU_REPO` → pestaña **Settings**
> - 👤 **Ajustes del Perfil General** → `github.com/settings` (solo para temas de tokens OAuth, no aplica aquí)
>
> **Todo lo que se configura en esta guía va en los Ajustes del Repositorio**, no en el perfil global.

---

## ✅ Paso 0: Activar el Workflow en GitHub Actions

El workflow `production_build.yml` solo se dispara cuando:
1. Se hace **push de un tag** con formato `v*.*.*` (ej: `v1.0.0`)
2. Se lanza **manualmente** desde la UI de GitHub (gracias al trigger `workflow_dispatch` que ya está configurado)

### Para ejecutarlo manualmente (recomendado durante la configuración inicial):

1. Ve a tu repositorio en GitHub.
2. Haz clic en la pestaña **Actions** (en la barra superior del repositorio).
3. En el panel izquierdo verás **"Production Build"** → haz clic sobre él.
4. Haz clic en el botón **"Run workflow"** (esquina superior derecha de la lista de ejecuciones).
5. Selecciona la rama `main` y haz clic en **"Run workflow"** (botón verde).

> [!NOTE]
> Si el workflow **no aparece** en el panel izquierdo de Actions, es porque el archivo `production_build.yml` aún no ha sido commiteado y pusheado a la rama principal (`main`). Asegúrate de que el archivo esté en el repositorio remoto ejecutando `git push origin main`.

---

## 🔒 Paso 1: Configurar GitHub Environments para Producción

Antes de añadir los secrets, crea un **Environment** de producción para controlar quién puede ejecutar el workflow y proteger los secrets de alta confidencialidad.

📦 **Ajustes del Repositorio** → **Settings** → **Environments** → **New environment**

1. Nómbralo: `production`
2. En **Deployment protection rules**, activa **Required reviewers** y añade tu usuario de GitHub.
3. Haz clic en **Save protection rules**.

> [!NOTE]
> La sección de *Environments* solo existe si tienes un repositorio **público** o estás en un plan de GitHub que lo soporte (GitHub Pro, Team o Enterprise). Si no ves esa opción, puedes usar secrets a nivel de repositorio igualmente (sin la protección de aprobación manual).

---

## 📱 Paso 2: Secrets de Android (Play App Signing)

El sistema de **Play App Signing** de Google separa la *upload key* (la que tú controlas en el pipeline) de la *signing key* real de la app (que Google custodia). Esto significa que si tu upload key se ve comprometida, puedes resetearla sin perder el acceso a tu app en la Play Store.

### 2.1. Generar el Upload Key Keystore

Usa directamente el formato **PKCS12** (estándar moderno, recomendado desde Java 9+). Evita JKS ya que es un formato propietario en desuso:

```bash
keytool -genkey -v \
  -keystore upload_key.jks \
  -storetype PKCS12 \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -dname "CN=Playing Tracker, OU=Dev, O=TuOrganizacion, L=TuCiudad, ST=TuProvincia, C=ES"
```

Durante el proceso te pedirá:
- **Store password**: Elige una contraseña segura → esta será `ANDROID_STORE_PASSWORD`
- **Key password**: En PKCS12 es la misma que la del almacén → también `ANDROID_KEY_PASSWORD`
- **Key alias**: En este caso usa `upload` → este será `ANDROID_KEY_ALIAS`

> [!NOTE]
> **¿Ya creaste un keystore con formato JKS?** No pasa nada, puedes migrarlo a PKCS12 con un solo comando:
> ```bash
> keytool -importkeystore \
>   -srckeystore upload_key.jks \
>   -destkeystore upload_key.jks \
>   -deststoretype pkcs12
> ```
> Te pedirá la contraseña del keystore actual y el resultado sobreescribirá el archivo ya en formato PKCS12. El aviso "Warning: JKS..." desaparecerá.

> [!IMPORTANT]
> Guarda el archivo `upload_key.jks` en un lugar **muy seguro** fuera del repositorio Git. Si lo pierdes, no podrás subir actualizaciones a la Play Store con esa upload key.

### 2.2. Codificar el Keystore en Base64

```bash
base64 -i upload_key.jks | pbcopy
```

Esto copia el contenido codificado al portapapeles de Mac. Lo pegarás como valor del secret `ANDROID_KEYSTORE_BASE64`.

### 2.3. Crear los Secrets en GitHub

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor | Descripción |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | Contenido base64 del archivo keystore | El keystore codificado |
| `ANDROID_STORE_PASSWORD` | Contraseña del keystore | La que elegiste al crearlo |
| `ANDROID_KEY_ALIAS` | `upload` | El alias de la clave dentro del keystore |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave | La misma que `ANDROID_STORE_PASSWORD` en PKCS12 |

> [!TIP]
> Para **verificar** que el base64 es correcto, puedes decodificarlo localmente: `echo "TU_BASE64" | base64 --decode > verificacion.jks` y luego `keytool -list -keystore verificacion.jks`.

---

## 🍏 Paso 3: Secrets de iOS (Firma Definitiva con Certificado)

El workflow implementa la **solución oficial y estándar de GitHub** para firmar apps de iOS: se inyecta el Certificado de Distribución y el Perfil de Aprovisionamiento directamente en un llavero (Keychain) temporal del runner macOS. Esto produce un `.ipa` real, firmado y listo para subir a la App Store.

### 3.1. Obtener el Certificado de Distribución (`.p12`)

Necesitas el certificado **"Apple Distribution"** exportado desde el llavero de tu Mac de desarrollo (donde ya tienes el Xcode configurado).

1. Abre **Xcode → Settings → Accounts** → tu Apple ID → **Manage Certificates**.
2. Si no tienes un certificado de tipo **"Apple Distribution"**, haz clic en **"+"** → **"Apple Distribution"** para crearlo.
3. Abre la aplicación **Llavero de Acceso** (`/Applications/Utilities/Keychain Access.app`).
4. En el panel izquierdo selecciona **"login"** en Llaveros y **"Mis certificados"** en Categoría.
5. Busca el certificado **"Apple Distribution: Tu Nombre"**, haz clic derecho sobre él → **"Exportar..."**.
6. Elige formato **Personal Information Exchange (`.p12`)** y guárdalo en una carpeta segura fuera del repo.
7. Durante la exportación te pedirá una **contraseña de protección** — **anótala**, será el valor de `P12_PASSWORD`.

### 3.2. Obtener el Provisioning Profile (`.mobileprovision`)

1. Ve al [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list).
2. En **Profiles** → haz clic en **"+"** para crear uno nuevo.
3. Selecciona **"App Store Connect"** como tipo de distribución → **Continue**.
4. Selecciona el **App ID `com.gabriom.playingtrackerapp`** → **Continue**.
5. Selecciona tu certificado de distribución → **Continue**.
6. Ponle un nombre descriptivo (ej: "Playing Tracker AppStore") → **Generate**.
7. Descarga el archivo `.mobileprovision`.

### 3.3. Codificar los archivos en Base64

```bash
# Certificado .p12 → al portapapeles
base64 -i /ruta/a/tu/certificado.p12 | pbcopy

# Provisioning Profile → al portapapeles (recuerda guardarlo antes de hacer el siguiente)
base64 -i /ruta/a/tu/profile.mobileprovision | pbcopy
```

### 3.4. Crear los Secrets en GitHub

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor | Descripción |
|---|---|---|
| `BUILD_CERTIFICATE_BASE64` | Contenido base64 del `.p12` | El certificado de distribución |
| `P12_PASSWORD` | Contraseña elegida al exportar el `.p12` | Contraseña del certificado |
| `BUILD_PROVISION_PROFILE_BASE64` | Contenido base64 del `.mobileprovision` | El perfil de aprovisionamiento |
| `KEYCHAIN_PASSWORD` | Cualquier contraseña aleatoria segura (ej: `generada por 1Password`) | Protege el llavero temporal del runner |

> [!IMPORTANT]
> El `KEYCHAIN_PASSWORD` no es para Apple — es solo la contraseña que usamos para proteger el llavero virtual que se crea y se destruye dentro del runner de GitHub Actions en cada ejecución. Puede ser cualquier cadena segura aleatoria.

> [!TIP]
> Puedes verificar que tu `.p12` es válido antes de subirlo ejecutando:
> `openssl pkcs12 -info -in /ruta/a/certificado.p12 -noout`

---

---

## 🔥 Paso 4: Secrets de Firebase (Crashlytics y CLI)

El uso de `FIREBASE_CLI_TOKEN` (generado con `firebase login:ci`) está **oficialmente deprecado** y será eliminado en versiones futuras del CLI. La alternativa correcta en 2026 es usar una **Cuenta de Servicio de Google Cloud**.

### 4.1. Crear la Cuenta de Servicio en Google Cloud

1. Ve a [Google Cloud Console](https://console.cloud.google.com) → selecciona tu proyecto Firebase.
2. Menú lateral → **IAM y Administración** → **Cuentas de servicio**.
3. Haz clic en **"Crear cuenta de servicio"**.
4. Ponle un nombre (ej: `github-ci-cd`) y una descripción.
5. Asígnale los siguientes **roles mínimos necesarios**:
   - `Firebase Crashlytics Admin` (para subir símbolos de desofuscación)
   - `Firebase App Distribution Admin` (si en el futuro quieres distribuir builds)
6. Haz clic en **"Listo"**.
7. En la tabla de cuentas de servicio, haz clic en la que acabas de crear → pestaña **Claves**.
8. Haz clic en **"Agregar clave"** → **"Crear nueva clave"** → selecciona formato **JSON** → **"Crear"**.
9. Se descargará automáticamente un archivo `.json`. Guárdalo de forma segura.

### 4.2. Codificar el JSON en Base64

```bash
base64 -i tu-proyecto-firebase-XXXXXX.json | pbcopy
```

### 4.3. Crear el Secret en GitHub

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor | Descripción |
|---|---|---|
| `GOOGLE_SERVICE_ACCOUNT_JSON_BASE64` | Contenido base64 del JSON | Credenciales de la cuenta de servicio |

> [!IMPORTANT]
> El workflow actual usa el secret `FIREBASE_CLI_TOKEN`. Para migrar al nuevo método, deberás actualizar el yml para decodificar este JSON y apuntar `GOOGLE_APPLICATION_CREDENTIALS` al archivo resultante. De momento, si quieres que funcione rápidamente sin la migración, puedes crear el secret `FIREBASE_CLI_TOKEN` usando el método legacy: ejecuta `firebase login:ci` en tu terminal y copia el token generado.

### 4.4. Alternativa Rápida (Legacy, Compatibilidad Inmediata)

Si prefieres que funcione inmediatamente sin reestructurar el workflow:

```bash
# En tu terminal local (con Firebase CLI instalado y sesión iniciada)
firebase login:ci
```

Copia el token generado y créalo como secret:

| Secret | Valor |
|---|---|
| `FIREBASE_CLI_TOKEN` | Token copiado del comando anterior |

### 4.5. Archivo Firebase Options (`firebase_options.dart`)

Dado que el archivo `lib/firebase_options.dart` incluye configuraciones específicas de tu proyecto Firebase, está excluido del control de versiones (`.gitignore`). Para que el workflow pueda compilar la aplicación, necesitamos inyectarlo como un Secret.

1. En tu máquina local, codifica el archivo base64:
   ```bash
   base64 -i lib/firebase_options.dart | pbcopy
   ```
2. Crea un nuevo Secret en GitHub:

| Secret | Valor | Descripción |
|---|---|---|
| `FIREBASE_OPTIONS_BASE64` | Contenido base64 del archivo | El archivo `firebase_options.dart` codificado |

### 4.6. Archivos de Google Services (Archivos Nativos)

De manera similar al `firebase_options.dart`, los archivos nativos de configuración que conectan las apps de Android e iOS a Firebase (`google-services.json` y `GoogleService-Info.plist` correspondientemente) tampoco deben subirse al repositorio Git. Sin embargo, las fases de build nativas (Gradle / Xcode) los exigen estrictamente para compilar con éxito.

Debemos convertirlos en base64 y guardarlos como secretos de igual manera para inyectarlos durante el CI:

1. **Para Android (`google-services.json`)**:
   - En tu terminal, ejecuta para codificar y copiar:
     ```bash
     base64 -i android/app/google-services.json | pbcopy
     ```
   - Crea el secreto en GitHub con el nombre `GOOGLE_SERVICES_JSON_BASE64`.

2. **Para iOS (`GoogleService-Info.plist`)**:
   - En tu terminal, ejecuta para codificar y copiar:
     ```bash
     base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
     ```
   - Crea el secreto en GitHub con el nombre `GOOGLE_SERVICE_INFO_PLIST_BASE64`.

---

## 📊 Paso 5: Variables de Entorno (No secretas)

Las variables de entorno no son datos sensibles (son IDs públicos de la app), por lo que van en **Variables**, no en Secrets.

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → pestaña **Variables** → **New repository variable**

### Cómo obtener los App IDs de Firebase

Usando el **MCP de Firebase** (ya configurado en este proyecto), los IDs se pueden consultar directamente. Alternativamente:

1. Ve a la [Consola de Firebase](https://console.firebase.google.com) → tu proyecto.
2. Haz clic en el ⚙️ (engranaje) → **Configuración del proyecto**.
3. En la sección **Tus apps**, cada app muestra su **ID de aplicación**.

| Variable | Ejemplo de valor | Descripción |
|---|---|---|
| `FIREBASE_APP_ID_ANDROID` | `1:123456789:android:abc123def456` | ID de la app Android en Firebase |
| `FIREBASE_APP_ID_IOS` | `1:123456789:ios:abc123def456` | ID de la app iOS en Firebase |

---

## � Workarounds Activos (Solución Temporal)

Debido a los recientes errores en GitHub Actions, hemos modificado temporalmente el archivo `production_build.yml` para evitar fallos mientras completas la configuración de tus credenciales:

1. **Android (Crashlytics)**: El volcado de símbolos a Crashlytics falló porque faltaban las credenciales. Se ha añadido un condicional (`if`) para que este paso **sólo** se ejecute si `FIREBASE_APP_ID_ANDROID` y `FIREBASE_CLI_TOKEN` no están en blanco.
2. **iOS (Code Signing)**: El paso `flutter build ipa` fallaba debido a certificados faltantes. Se ha añadido el *flag* `--no-codesign`. Esto compilará exitosamente la app garantizando la integridad de tu código Dart, pero solo producirá un **`.xcarchive`** no instalable. No producirá un `.ipa`.

> [!WARNING]
> **Para eliminar estos *workarounds* y tener un CI 100% funcional, DEBES configurar prioritariamente los siguientes pasos de este documento:**
> - [Paso 3](#-paso-3-secrets-de-ios-firma-definitiva-con-certificado) para habilitar el firmado real en iOS (configurando `BUILD_CERTIFICATE_BASE64`, `P12_PASSWORD`, `BUILD_PROVISION_PROFILE_BASE64` y `KEYCHAIN_PASSWORD`).
> - [Paso 4](#-paso-4-secrets-de-firebase-crashlytics-y-cli) y [Paso 5](#-paso-5-variables-de-entorno-no-secretas) para arreglar Crashlytics en Android (configurando `FIREBASE_APP_ID_ANDROID` y `FIREBASE_CLI_TOKEN`).

---

## �📋 Resumen: Checklist de Configuración

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions**

### Secrets (pestaña "Secrets")

**Android:**
- [ ] `ANDROID_KEYSTORE_BASE64`
- [ ] `ANDROID_STORE_PASSWORD`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`

**iOS (firma definitiva):**
- [ ] `BUILD_CERTIFICATE_BASE64`
- [ ] `P12_PASSWORD`
- [ ] `BUILD_PROVISION_PROFILE_BASE64`
- [ ] `KEYCHAIN_PASSWORD`

**Firebase:**
- [ ] `FIREBASE_CLI_TOKEN` *(legacy)* o `GOOGLE_SERVICE_ACCOUNT_JSON_BASE64` *(recomendado)*
- [ ] `FIREBASE_OPTIONS_BASE64`
- [ ] `GOOGLE_SERVICES_JSON_BASE64`
- [ ] `GOOGLE_SERVICE_INFO_PLIST_BASE64`

### Variables (pestaña "Variables")
- [ ] `FIREBASE_APP_ID_ANDROID`
- [ ] `FIREBASE_APP_ID_IOS`

---

## 🧪 Paso 6: Verificación — Cómo Comprobar que Todo Funciona

### 6.1. Lanzar el Workflow Manualmente

1. Ve a tu repositorio en GitHub → pestaña **Actions**.
2. Panel izquierdo → **"Production Build"** → botón **"Run workflow"** → rama `main`.
3. Verás una nueva ejecución aparecer en la lista. Haz clic sobre ella para ver el progreso en tiempo real.

### 6.2. Qué Verificar en Cada Job

| Job | ✅ Señal de éxito |
|---|---|
| **Lint & Tests** | Todos los pasos en verde (analyze + test) |
| **Build Android AAB** | El step "Build App Bundle" finaliza sin errores; aparece artefacto `android-aab-*` al fondo |
| **Build iOS IPA** | El step "Build IPA" finaliza sin errores; aparece artefacto `ios-ipa-*` al fondo |
| **Upload Crashlytics symbols** | El CLI de Firebase reporta "done" sin errores de autenticación |

### 6.3. Prueba en Simulador Android (Perfil Estudiante)

1. Descarga el artefacto `android-aab-*` desde la ejecución de Actions.
2. Para probar localmente, necesitas convertirlo a APK o usar `bundletool`:
   ```bash
   bundletool build-apks --bundle=app-release.aab --output=app.apks --local-testing
   bundletool install-apks --apks=app.apks
   ```
3. En el simulador Android, inicia sesión con credenciales de **Estudiante**.
4. Verifica: navegación a clases, visualización de tareas, cronómetro.

### 6.4. Prueba en Simulador iOS (Perfil Docente)

1. Descarga el artefacto `ios-ipa-*` desde la ejecución de Actions.
2. Instala el `.ipa` en el simulador iOS con:
   ```bash
   xcrun simctl install booted ruta/al/archivo.ipa
   ```
3. Inicia sesión con credenciales de **Docente**.
4. Verifica: creación de clases, gestión de alumnos, estadísticas.

> [!NOTE]
> Para instalar un `.ipa` en el simulador de iOS, la app debe haber sido compilada para el tipo `generic/platform=iOS Simulator`. Los builds de producción firmados (para App Store) solo se pueden instalar en dispositivos físicos.

---

*Última actualización: Marzo 2026 | Generado para el proyecto Playing Tracker*
