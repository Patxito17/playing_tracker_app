# 🚀 SPRINT 8: Rediseño Premium y General de UI

**Fecha de Inicio**: [Fecha Actual]
**Objetivo General**: Rediseño visual completo de **toda la aplicación y de todas sus features** utilizando Google Stitch. El enfoque es lograr un estilo "Premium Académico", con soporte nativo de Material 3 dinámico, que motive a estudiantes (iconos hermosos y llamativos) y ofrezca una experiencia profesional a docentes.

---

## 🎨 Fase 1: Feature Auth

En esta primera fase nos centraremos en el rediseño del flujo de logueo, registro y recuperación de contraseñas.

### Cambios Esquemáticos

*   **Identificación General**:
    *   Generación de interfaces agnósticas a colores "hardcodeados", basándose en `context.colorScheme`.
    *   Bordes redondeados uniformes (`16.0`).
    *   Transiciones y estados visuales responsivos, reemplazando `.withOpacity()` por `.withValues(alpha: X)`.

*   **LoginScreen**:
    *   Integración de interfaz para Apple Sign-In y Google Sign-In adaptadas al nuevo estilo.
    *   Limpieza del layout mejorando la legibilidad.

*   **RegisterScreen**:
    *   Formulario de registro rediseñado.
    *   Selección visual clara del tipo de cuenta (Docente / Alumno).

*   **ForgotPasswordScreen**:
    *   Diseño limpio para enfocarse en la acción principal.

*   **CompleteProfileScreen**:
    *   Adaptación del flujo de "completar datos" tras un inicio de sesión federado a los nuevos layouts y paletas dinámicas.

---

*(Nota: Los prompts específicos utilizados con Stitch se registrarán aquí conforme avancemos en la generación).*
