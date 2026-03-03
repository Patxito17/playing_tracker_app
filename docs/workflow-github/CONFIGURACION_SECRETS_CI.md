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

### 2.1. Generar el Upload Key Keystore (Si aún no lo tienes)

Ejecuta este comando en tu terminal (en cualquier directorio):

```bash
keytool -genkey -v \
  -keystore upload_key.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -dname "CN=Playing Tracker, OU=Dev, O=TuOrganizacion, L=TuCiudad, ST=TuProvincia, C=ES"
```

Durante el proceso te pedirá:
- **Store password**: Elige una contraseña segura → esta será `ANDROID_STORE_PASSWORD`
- **Key password**: Puede ser la misma que la anterior → esta será `ANDROID_KEY_PASSWORD`
- **Key alias**: En este caso usa `upload` → este será `ANDROID_KEY_ALIAS`

> [!IMPORTANT]
> Guarda el archivo `upload_key.jks` en un lugar **muy seguro** (fuera del repositorio Git). Si lo pierdes, no podrás subir actualizaciones a la Play Store con esa upload key.

### 2.2. Codificar el Keystore en Base64

```bash
base64 -i upload_key.jks | pbcopy
```

Esto copia el contenido codificado al portapapeles de Mac. Lo pegarás como valor del secret `ANDROID_KEYSTORE_BASE64`.

### 2.3. Crear los Secrets en GitHub

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor | Descripción |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | Contenido base64 del `.jks` | El keystore codificado |
| `ANDROID_STORE_PASSWORD` | Contraseña del keystore | La que elegiste al crear el `.jks` |
| `ANDROID_KEY_ALIAS` | `upload` | El alias de la clave dentro del keystore |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave | Generalmente la misma que `ANDROID_STORE_PASSWORD` |

> [!TIP]
> Para **verificar** que el base64 es correcto, puedes decodificarlo localmente: `echo "TU_BASE64" | base64 --decode > verificacion.jks` y luego `keytool -list -keystore verificacion.jks`.

---

## 🍏 Paso 3: Secrets de iOS (App Store Connect API Key)

**¿Por qué usar una API Key en lugar de certificados manuales?**
Las API Keys de App Store Connect no caducan nunca, no requieren mantenimiento manual y evitan el caos de gestionar perfiles de aprovisionamiento que expiran silenciosamente.

### 3.1. Crear la API Key en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com) → inicia sesión con tu Apple ID (debe ser rol **Admin** o **Account Holder**).
2. Ve a **Users and Access** (menú superior derecho).
3. Haz clic en la pestaña **Integrations** → columna izquierda → **App Store Connect API**.
4. Asegúrate de que estás en la subpestaña **Team Keys**.
5. Haz clic en el botón **"+"** (Generate API Key).
6. Ponle un nombre descriptivo (ej: `Playing Tracker CI/CD`) y asígnale el rol **App Manager**.
7. Haz clic en **Generate**.
8. En la tabla aparecerá la nueva API Key. **Descarga el archivo `.p8` inmediatamente** (solo se puede descargar una vez).
9. Anota también el **Key ID** (columna "Key ID" de la tabla) y el **Issuer ID** (que aparece arriba de la tabla).

### 3.2. Codificar la API Key en Base64

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

*(Reemplaza `XXXXXXXXXX` con tu Key ID real)*

### 3.3. Crear los Secrets en GitHub

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Dónde encontrarlo | Descripción |
|---|---|---|
| `APP_STORE_CONNECT_API_KEY_KEY_ID` | Tabla de la API Key (columna "Key ID") | Ej: `ABC1234DEF` |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | Encima de la tabla de API Keys ("Issuer ID") | Ej: `57246542-96fe-1a63-e053...` |
| `APP_STORE_CONNECT_API_KEY_KEY` | Contenido base64 del archivo `.p8` | El archivo descargado |
| `MATCH_PASSWORD` | Contraseña que tú decides | Clave maestra para cifrar el repo de Fastlane Match |

> [!NOTE]
> El secret `MATCH_PASSWORD` es solo necesario si configuras **Fastlane Match** para sincronizar certificados. Para una configuración inicial básica con `flutter build ipa`, puedes omitirlo.

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

## 📋 Resumen: Checklist de Configuración

📦 **Ajustes del Repositorio** → **Settings** → **Secrets and variables** → **Actions**

### Secrets (pestaña "Secrets")
- [ ] `ANDROID_KEYSTORE_BASE64`
- [ ] `ANDROID_STORE_PASSWORD`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`
- [ ] `APP_STORE_CONNECT_API_KEY_KEY_ID`
- [ ] `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- [ ] `APP_STORE_CONNECT_API_KEY_KEY`
- [ ] `FIREBASE_CLI_TOKEN` *(legacy)* o `GOOGLE_SERVICE_ACCOUNT_JSON_BASE64` *(recomendado)*
- [ ] `FIREBASE_OPTIONS_BASE64`

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
