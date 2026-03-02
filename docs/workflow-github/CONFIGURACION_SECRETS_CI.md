# Guía de Configuración de Credenciales CI/CD (GitHub Actions) - Nivel Producción 2026

Para que el flujo de integración continua (`.github/workflows/production_build.yml`) funcione de manera autónoma, profesional y segura, es necesario configurar una serie de "Secrets" (Secretos) y "Variables" en GitHub.

> [!CAUTION]
> NUNCA incluyas archivos sensibles (keystores, certificados, perfiles o tokens) en el código fuente del proyecto.

---

## 🔒 1. Mejores Prácticas Universales (Seguridad y GitHub Environments)

En un entorno de producción moderno (2026), no deberías exponer secretos a nivel global del repositorio donde cualquier PR malicioso externo pueda interceptarlos al ejecutar actions. 

**Recomendación:** Usa **GitHub Environments**.
1. En GitHub ve a **Settings** -> **Environments** -> `New environment` (nómbralo `production`).
2. Añade **Protection rules**: marca `Required reviewers` y selecciona tu usuario o equipo.
3. El workflow requerirá tu aprobación manual antes de desplegar código a producción y consumir estos secretos de alta confidencialidad. 
4. Añade todos los Secrets descritos abajo dentro de ester **Environment secrets** en lugar de globales.

Adicionalmente, el pipeline debe apoyarse en un **Versionado automático** (ej. leyendo dinámicamente el `pubspec.yaml` e inyectando un nuevo `buildNumber` que auto-incremente por Action en tags formales como `v1.0.0`).

---

## 📱 2. Secrets Requeridos (Android)

Para Android usamos un *Keystore* local y delegamos la distribución real al sistema seguro de Google.

**🔥 Play App Signing (Recomendado 2026)**: No debes usar tu Keystore de lanzamiento como la única clave. Sube una *Upload Key* a tu Action que la firme y envíe a la Play Store. Google utilizará su *Play App Signing Key* interna para firmar el binario final a los usuarios. Si la *Upload Key* se ve comprometida, puedes revocarla sin perder el acceso o la posibilidad de actualizar tu propia app en Play Store.

### `ANDROID_KEYSTORE_BASE64`
- **¿Qué es?**: Tu archivo `upload_key.jks` codificado en texto base64 para que GitHub pueda leerlo.
- **Obtención terminal**: `base64 upload_key.jks | pbcopy`

### `ANDROID_STORE_PASSWORD` / `ANDROID_KEY_PASSWORD` / `ANDROID_KEY_ALIAS`
- Las contraseñas elegidas al crear el fichero jks y el nombre del alias interno (ej: `upload`).

---

## 🍏 3. Secrets Requeridos (iOS - App Store Connect)

> [!WARNING]  
> Mover .p12 y `.mobileprovision` manuales es funcionalmente aceptable pero propensos al fallo (expiran silenciadamente, rompen despliegues automatizados y asumen manteniblidad manual).

**🥇 Opción Óptima Profesional 2026: Fastlane Match + App Store Connect API Key**

En lugar de subir ficheros manualmente cifrados, debes permitir a tu pipeline conectarse seguro mediante claves API delegadas. Tu pipeline genera y sincroniza lo que necesita al instante usando un Storage Seguro (git, gcloud, s3).

### Requisitos con este enfoque moderno:
1. **`APP_STORE_CONNECT_API_KEY_ISSUER_ID`** 
2. **`APP_STORE_CONNECT_API_KEY_KEY_ID`**
3. **`APP_STORE_CONNECT_API_KEY_KEY`** (Contenido base64 del archivo `.p8` que descargas desde App Store Connect -> Users and Access -> Keys).
4. **`MATCH_PASSWORD`**: Contraseña maestra que utilices para encriptar el repositorio o bucket donde Fastlane almacena tus perfiles sincronizados automáticamente.

*Ventajas*: Se elimina la necesidad de manejar renovaciones manuales de perfiles de aprovisionamiento; revocaciones o creaciones de equipos paralelos ocurren fluidamente.

---

## 📊 4. Subida y Gestión de Símbolos (Firebase Crashlytics)

Para poder desofuscar y leer las trazas (stack traces) de cuelgues reales, Crashlytics necesita recibir los diccionarios generados en cada compilación (`build/symbols/`).

**🥇 Workload Identity Federation (OIDC) o Google Service Accounts**

El antiguo `firebase login:ci` con tokens locales crudos (legacy) se considera obsoleto por sus riesgos permanentes. 

En 2026 la aproximación es:
1. Utilizar un JSON Key de Google Cloud de la cuenta de servicio asociada y pasarlo a Base 64 como `GOOGLE_APPLICATION_CREDENTIALS_BASE64` (o directamente integrarle Identidad Federal (OIDC) mapeando el GitHub runner sin secrets manuales en absoluto).
2. Para compatibilidad interina directa con los Action de Firebase estándar y herramientas CLI modernas se requerirá la exportación como Variable de Entorno:
   `GOOGLE_APPLICATION_CREDENTIALS` apuntando a dicho JSON generado en ejecución temporal.

**Variables requeridas adicionales (En "Variables", no Secrets):**
- **`FIREBASE_APP_ID_ANDROID`**: ID de app Android (Ej: `1:123456...:android:abc`).
- **`FIREBASE_APP_ID_IOS`**: ID de app iOS.
