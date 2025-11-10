# 📚 Guía de Componentes Base - Playing Tracker

**Proyecto:** Playing Tracker - Sistema de Seguimiento de Estudio Musical
**Sprint:** 0 - Componentes Base Material Design 3
**Última actualización:** 7 de Noviembre 2025

---

## 📋 Índice

1. [CustomButton](#custombutton)
2. [CustomTextField](#customtextfield)
3. [CustomCard](#customcard)
4. [CustomAppBar](#customappbar)
5. [CustomTabBar](#customtabbar)
6. [CustomBottomNavigationBar](#custombottomnavigationbar)
7. [LoadingOverlay](#loadingoverlay)

---

## 🎯 CustomButton

Botón personalizado que encapsula los estilos Material Design 3 con soporte para múltiples variantes y estados.

### Ubicación
`lib/shared/widgets/custom_button.dart`

### Variantes Disponibles

- **`CustomButtonVariant.filled`** - Botón con fondo sólido (FilledButton)
- **`CustomButtonVariant.outlined`** - Botón con borde (OutlinedButton)
- **`CustomButtonVariant.text`** - Botón de texto plano (TextButton)

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `label` | `String` | Texto del botón | ✅ Sí |
| `onPressed` | `VoidCallback?` | Callback al presionar | ❌ No |
| `variant` | `CustomButtonVariant` | Variante del botón | ❌ No (default: `filled`) |
| `icon` | `IconData?` | Icono opcional | ❌ No |
| `isLoading` | `bool` | Estado de carga | ❌ No (default: `false`) |
| `isEnabled` | `bool` | Estado habilitado | ❌ No (default: `true`) |
| `style` | `ButtonStyle?` | Estilo personalizado | ❌ No |

### Ejemplos de Uso

#### Botón Filled Básico
```dart
CustomButton(
  label: 'Guardar',
  onPressed: () => saveData(),
  variant: CustomButtonVariant.filled,
)
```

#### Botón Outlined con Icono
```dart
CustomButton(
  label: 'Cancelar',
  icon: Icons.cancel,
  onPressed: () => cancelAction(),
  variant: CustomButtonVariant.outlined,
)
```

#### Botón Text en Estado Loading
```dart
CustomButton(
  label: 'Cargando...',
  isLoading: true,
  variant: CustomButtonVariant.text,
)
```

#### Botón Deshabilitado
```dart
CustomButton(
  label: 'Enviar',
  isEnabled: false,
  onPressed: null, // También deshabilita el botón
)
```

### Características de Accesibilidad

- ✅ Widget `Semantics` con `button: true`
- ✅ Label descriptivo para lectores de pantalla
- ✅ Estado `enabled` correctamente configurado
- ✅ Tamaño táctil mínimo de 48x48 dp (garantizado por Material Design 3)

---

## 📝 CustomTextField

Campo de texto personalizado con estilos Material Design 3 y validación visual.

### Ubicación
`lib/shared/widgets/custom_text_field.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `label` | `String?` | Label del campo | ❌ No |
| `hint` | `String?` | Texto de ayuda | ❌ No |
| `errorText` | `String?` | Mensaje de error | ❌ No |
| `onChanged` | `ValueChanged<String>?` | Callback al cambiar texto | ❌ No |
| `keyboardType` | `TextInputType?` | Tipo de teclado | ❌ No |
| `obscureText` | `bool` | Ocultar texto (contraseñas) | ❌ No (default: `false`) |
| `enabled` | `bool` | Campo habilitado | ❌ No (default: `true`) |
| `controller` | `TextEditingController?` | Controlador de texto | ❌ No |
| `maxLines` | `int?` | Máximo de líneas | ❌ No (default: `1`) |
| `maxLength` | `int?` | Máximo de caracteres | ❌ No |

### Ejemplos de Uso

#### Campo de Texto Básico
```dart
CustomTextField(
  label: 'Nombre',
  hint: 'Ingresa tu nombre',
  onChanged: (value) => updateName(value),
)
```

#### Campo de Email con Validación
```dart
CustomTextField(
  label: 'Email',
  hint: 'usuario@ejemplo.com',
  keyboardType: TextInputType.emailAddress,
  errorText: _emailError,
  onChanged: (value) => validateEmail(value),
)
```

#### Campo de Contraseña
```dart
CustomTextField(
  label: 'Contraseña',
  obscureText: true,
  textCapitalization: TextCapitalization.none,
  onChanged: (value) => updatePassword(value),
)
```

#### Campo Multilínea
```dart
CustomTextField(
  label: 'Descripción',
  hint: 'Ingresa una descripción',
  maxLines: 5,
  onChanged: (value) => updateDescription(value),
)
```

### Características de Accesibilidad

- ✅ Widget `Semantics` con `textField: true`
- ✅ Label y hint para lectores de pantalla
- ✅ Valor de error accesible
- ✅ Estado `enabled` y `readOnly` correctamente configurados

---

## 🃏 CustomCard

Card personalizado con elevación configurable y soporte para títulos, subtítulos y acciones.

### Ubicación
`lib/shared/widgets/custom_card.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `child` | `Widget` | Contenido del card | ✅ Sí |
| `title` | `String?` | Título del card | ❌ No |
| `subtitle` | `String?` | Subtítulo del card | ❌ No |
| `trailingAction` | `Widget?` | Acción al final del header | ❌ No |
| `leadingAction` | `Widget?` | Acción al inicio del header | ❌ No |
| `elevation` | `double?` | Elevación del card | ❌ No |
| `padding` | `EdgeInsetsGeometry?` | Padding interno | ❌ No |
| `margin` | `EdgeInsetsGeometry?` | Margen externo | ❌ No |
| `onTap` | `VoidCallback?` | Callback al hacer tap | ❌ No |

### Ejemplos de Uso

#### Card Básico
```dart
CustomCard(
  child: Text('Contenido del card'),
)
```

#### Card con Título y Subtítulo
```dart
CustomCard(
  title: 'Título del Card',
  subtitle: 'Subtítulo descriptivo',
  child: Text('Contenido aquí'),
)
```

#### Card con Acciones
```dart
CustomCard(
  title: 'Tarea',
  trailingAction: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => deleteTask(),
  ),
  child: Text('Descripción de la tarea'),
)
```

#### Card Interactivo
```dart
CustomCard(
  title: 'Clase de Música',
  subtitle: 'Profesor: Juan Pérez',
  onTap: () => navigateToClass(),
  child: Text('Información adicional'),
)
```

### Características de Accesibilidad

- ✅ Feedback táctil con `InkWell` cuando tiene `onTap`
- ✅ Estructura semántica clara con título y contenido

---

## 📱 CustomAppBar

AppBar personalizado con título, acciones configurables y navegación hacia atrás automática.

### Ubicación
`lib/shared/widgets/custom_app_bar.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `title` | `String?` | Título del AppBar | ❌ No |
| `customTitle` | `Widget?` | Título personalizado | ❌ No |
| `actions` | `List<Widget>?` | Acciones del AppBar | ❌ No |
| `onBackPressed` | `VoidCallback?` | Callback personalizado para retroceso | ❌ No |
| `automaticallyImplyLeading` | `bool` | Mostrar botón de retroceso | ❌ No (default: `true`) |
| `backgroundColor` | `Color?` | Color de fondo | ❌ No |
| `elevation` | `double?` | Elevación del AppBar | ❌ No |

### Ejemplos de Uso

#### AppBar Básico
```dart
Scaffold(
  appBar: CustomAppBar(title: 'Mi Pantalla'),
  body: MyContent(),
)
```

#### AppBar con Acciones
```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'Configuración',
    actions: [
      IconButton(
        icon: Icon(Icons.save),
        onPressed: () => saveSettings(),
      ),
    ],
  ),
  body: SettingsContent(),
)
```

#### AppBar con Título Personalizado
```dart
Scaffold(
  appBar: CustomAppBar(
    customTitle: Row(
      children: [
        Icon(Icons.music_note),
        SizedBox(width: 8),
        Text('Playing Tracker'),
      ],
    ),
  ),
  body: MyContent(),
)
```

#### AppBar sin Botón de Retroceso
```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'Pantalla Principal',
    automaticallyImplyLeading: false,
  ),
  body: MyContent(),
)
```

### Características de Accesibilidad

- ✅ Botón de retroceso con `tooltip` descriptivo
- ✅ Navegación automática usando `context.canPop()` y `context.pop()`

---

## 📑 CustomTabBar

TabBar personalizado con Material Design 3 y estilos consistentes usando tokens del tema.

### Ubicación
`lib/shared/widgets/custom_tab_bar.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `tabs` | `List<Tab>` | Lista de tabs | ✅ Sí |
| `onTap` | `ValueChanged<int>?` | Callback al seleccionar tab | ❌ No |
| `isScrollable` | `bool` | Tabs scrollables | ❌ No (default: `false`) |

### Ejemplos de Uso

#### TabBar Básico
```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: CustomTabBar(
        tabs: [
          Tab(icon: Icon(Icons.assignment), text: 'Tareas'),
          Tab(icon: Icon(Icons.people), text: 'Estudiantes'),
          Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        TasksTab(),
        StudentsTab(),
        StatisticsTab(),
      ],
    ),
  ),
)
```

#### TabBar Scrollable
```dart
CustomTabBar(
  isScrollable: true,
  tabs: [
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
    Tab(text: 'Tab 3'),
    Tab(text: 'Tab 4'),
  ],
)
```

### Características de Accesibilidad

- ✅ Colores de contraste adecuados usando tokens del tema
- ✅ Indicador visual claro del tab activo

---

## 🧭 CustomBottomNavigationBar

BottomNavigationBar personalizado con Material Design 3 y soporte para StatefulNavigationShell.

### Ubicación
`lib/shared/widgets/custom_bottom_navigation_bar.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `navigationShell` | `StatefulNavigationShell` | Shell de navegación | ✅ Sí |

### Ejemplos de Uso

#### Con StatefulShellRoute
```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomBottomNavigationBar(
        navigationShell: navigationShell,
      ),
    );
  },
  branches: [
    StatefulShellBranch(routes: [...]), // Branch 0: Clases
    StatefulShellBranch(routes: [...]), // Branch 1: Estadísticas
    StatefulShellBranch(routes: [...]), // Branch 2: Configuración
  ],
)
```

### Tabs Disponibles

1. **Clases** - Lista de clases (según rol)
2. **Estadísticas** - Estadísticas generales
3. **Configuración** - Ajustes de la aplicación

### Características de Accesibilidad

- ✅ Labels descriptivos usando `NavigationStrings`
- ✅ Iconos con estados seleccionado/no seleccionado
- ✅ Navegación accesible con `NavigationBar` de Material Design 3

---

## ⏳ LoadingOverlay

Overlay modal que bloquea la interacción mientras muestra un indicador de carga.

### Ubicación
`lib/shared/widgets/loading_overlay.dart`

### Propiedades Principales

| Propiedad | Tipo | Descripción | Requerido |
|-----------|------|-------------|-----------|
| `message` | `String?` | Mensaje opcional | ❌ No |
| `backgroundColor` | `Color?` | Color de fondo | ❌ No |

### Ejemplos de Uso

#### Como Widget
```dart
Stack(
  children: [
    MyContent(),
    if (isLoading) LoadingOverlay(message: 'Cargando...'),
  ],
)
```

#### Como Función Helper
```dart
// Mostrar overlay
showLoadingOverlay(context, message: 'Guardando...');

// Realizar operación asíncrona
await saveData();

// Ocultar overlay
hideLoadingOverlay(context);
```

#### Con Operación Asíncrona
```dart
showLoadingOverlay(context, message: 'Cargando datos...');

try {
  await fetchData();
} finally {
  hideLoadingOverlay(context);
}
```

### Funciones Helper

- **`showLoadingOverlay(BuildContext context, {String? message, Color? backgroundColor})`** - Muestra el overlay
- **`hideLoadingOverlay(BuildContext context)`** - Oculta el overlay

### Características de Accesibilidad

- ✅ Bloquea la interacción con `AbsorbPointer`
- ✅ Indicador visual claro de carga
- ✅ Mensaje opcional para contexto adicional

---

## 🎨 Convenciones de Uso

### Estilos Centralizados

Todos los componentes usan:
- **`AppTextStyles`** - Estilos de texto centralizados
- **`AppSpacing`** - Espaciado consistente
- **`AppBorderRadius`** - Radios de borde consistentes
- **`context.colorScheme`** - Tokens de color del tema

### Material Design 3

Todos los componentes siguen las especificaciones de Material Design 3:
- Uso de tokens de diseño (`colorScheme`, `textTheme`)
- Componentes M3 nativos (`FilledButton`, `OutlinedButton`, `TextField`, etc.)
- Elevación sutil con `surfaceTintColor`
- Tema claro y oscuro completamente soportados

### Accesibilidad

Todos los componentes incluyen:
- Widgets `Semantics` con labels descriptivos
- Tamaños táctiles mínimos de 48x48 dp
- Contraste adecuado usando tokens del tema
- Soporte para lectores de pantalla (TalkBack, VoiceOver)

---

## 📚 Referencias

- [Material Design 3](https://m3.material.io/)
- [Flutter Accessibility](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

**Última actualización:** 7 de Noviembre 2025
**Versión:** 1.0.0

