# 🚀 SPRINT 8: Rediseño Premium y General de UI

**Fecha de Inicio**: [Fecha Actual]
**Objetivo General**: Rediseño visual completo de **toda la aplicación y de todas sus features** utilizando Google Stitch. El enfoque es lograr un estilo "Premium Académico", con soporte nativo de Material 3 dinámico, que motive a estudiantes (iconos hermosos y llamativos) y ofrezca una experiencia profesional a docentes.

---

## 🎨 Fase 1: Feature Auth

En esta primera fase nos centraremos en el rediseño del flujo de logueo, registro y recuperación de contraseñas.

### Cambios Esquemáticos y Prompts de Stitch

*   **Identificación General**:
    *   Ajuste de `CustomButton` y `CustomTextField` para el nuevo estándar (borde de `16.0`).
    *   Generación de interfaces agnósticas a colores "hardcodeados", basándose en `context.colorScheme`.
    *   Transiciones y estados visuales responsivos, reemplazando `.withOpacity()` por `.withValues(alpha: X)`.

*   **LoginScreen**:
    *   **Modificaciones**: Integración de interfaz para Apple Sign-In y Google Sign-In adaptadas al nuevo estilo. Limpieza del layout mejorando la legibilidad.
    *   **Prompt Stitch**: > "Diseña una pantalla de Login premium, moderna y académica para Playing Tracker. Debe tener iconos hermosos y atractivos, utilizando fondos con sutiles degradados, tarjetas con elevación Material 3 (surface containers) y bordes redondeados (16px). Incluye campos para email y contraseña, botón de 'Olvidé mi contraseña' alineado a la derecha, un botón principal de 'Entrar' y opciones de login social con Google y Apple. Usa tokens dinámicos de Material 3 (primary, surfaceVariant, etc.) para soporte automático de modo claro/oscuro".

*   **RegisterScreen**:
    *   **Modificaciones**: Formulario de registro rediseñado. Selección visual clara del tipo de cuenta (Docente / Alumno).
    *   **Prompt Stitch**: > "Diseña una pantalla de Registro académica y motivadora. Debe permitir al usuario elegir entre perfil 'Docente' o 'Alumno' de forma muy visual y atractiva. Utiliza tarjetas con bordes redondeados (16px), elevación Material 3 y una paleta de colores dinámica. Los campos de texto deben ser limpios y elegantes. Asegúrate de que el diseño motive a estudiantes de 8-18 años pero mantenga la profesionalidad para docentes".

*   **ForgotPasswordScreen**:
    *   **Modificaciones**: Diseño limpio para enfocarse en la acción principal.
    *   **Prompt Stitch**: > "Diseña una pantalla de recuperación de contraseña premium. Debe ser minimalista, con una jerarquía tipográfica fuerte y un indicador visual claro del paso a seguir. Usa tokens dinámicos de Material 3, bordes redondeados y un estilo académico limpio que emane confianza".

*   **CompleteProfileScreen**:
    *   **Modificaciones**: Adaptación del flujo de "completar datos" tras un inicio de sesión federado a los nuevos layouts y paletas dinámicas.
    *   **Prompt Stitch**: > "Diseña una interfaz para completar el perfil tras el login social. Debe sentirse como una extensión natural del flujo premium, con campos elegantes, iconos hermosos y un botón de acción claro. Mantén la estética de bordes redondeados (16px) y colores dinámicos de Material 3".

---

## 🎨 Fase 2: Home Screens

En esta fase rediseñaremos las pantallas principales de la aplicación para ambos roles, asegurando que el "Dashboard" sea motivador y funcional.

### Cambios Esquemáticos y Prompts de Stitch

*   **StudentHomeScreen**:
    *   **Modificaciones**: Dashboard dinámico con tarjetas de progreso, accesos directos visuales a clases y tareas, y un resumen de actividad motivador.
    *   **Prompt Stitch**: > "Diseña una pantalla de inicio (Dashboard) premium para un estudiante de música (8-18 años). Debe ser vibrante, moderna y académica. Incluye una tarjeta de bienvenida personalizada, una sección de 'Acciones Rápidas' con iconos hermosos para 'Mis Clases', 'Mis Tareas', 'Historial' y 'Unirse a Clase'. Añade una sección de 'Logros' o 'Progreso' visualmente atractiva utilizando tarjetas con elevación Material 3 (surface containers), bordes redondeados (16px) y fondos con sutiles degradados. Usa tokens dinámicos de Material 3 para soporte de modo claro/oscuro".

*   **TeacherHomeScreen**:
    - [x] **Rediseño Premium Docente**:
        - ✅ Implementado `HomeDashboardHeader` con degradado adaptativo y SafeArea.
        - ✅ Creada sección de estadísticas rápidas con `HomeStatCard`.
        - ✅ Implementado listado compacto de clases con `HomeClassCardCompact`.
        - ✅ Integrado saludo personalizado: "Hola, {nombre}".
        - ✅ 6/6 tests pasando (widgets y navegación).
    - **Prompt Stitch**: > "Diseña una pantalla de inicio para un docente de música. Debe ser limpia, profesional y emanar confianza. Incluye una tarjeta de bienvenida, una sección para 'Gestionar Clases' y un botón destacado para 'Crear Nueva Clase'. La jerarquía tipográfica debe ser fuerte y la información debe estar organizada de forma clara utilizando tarjetas Material 3 con bordes redondeados (16px). Usa tokens dinámicos de Material 3 para que el diseño sea profesional tanto en modo claro como oscuro".


---

## 🌍 Localización y Textos

Cualquier nuevo string generado en los diseños de Stitch que se deba mostrar en pantalla, se debe incorporar en `app_es.arb` y `app_en.arb`. 
**Nota Obligatoria**: Después de editar cualquier fichero `.arb`, ejecuta en la terminal el comando `make clean-l10n` para compilar de nuevo las traducciones sin errores.

---

## 🧪 Plan de Verificación Obligatorio

Antes de dar por buenas las pantallas generadas o modificadas, debes comprobarlas desde los simuladores siguiendo el rol que predomina en dicha plataforma:

### 1. Perfil Estudiante (Simulador Android)
* Construir y correr app en un emulador Android.
* Navegar por el flujo de **Registro** centrándose en el alta de cuenta de tipo **Estudiante**.
* **Criterios**: ¿Tiene el diseño los componentes visuales vibrantes (colores dinámicos) y formas redondeadas atractivas y motivantes requeridas?
* Cambiar el modo Claro / Oscuro del sistema operativo Android para validar que el colorTheme soporta los cambios y la paleta no pierde legibilidad.

### 2. Perfil Docente (Simulador iOS)
* Construir y correr app en simulador iOS.
* Efectuar Login empleando **Sign in with Apple** entrando como **Docente**.
* **Criterios**: ¿Se percibe el layout seguro, claro y profesional? Los botones deben respetar el guideline de Apple y mantener una estructuración elegante de jerarquía de interfaz.
* Navegar a recuperación de contraseña para validar diseño minimalista y libre de distracciones.
