# 📋 Análisis de Requisitos y Fase de Diseño - Playing Tracker

**Proyecto:** Playing Tracker - Sistema de Seguimiento de Estudio Musical
**Fecha:** Octubre 2025
**Versión:** 1.0

---

## 1. 📋 Documento de Análisis de Requisitos

### 1.1 Descripción del Proyecto

**Playing Tracker** es una aplicación móvil multiplataforma desarrollada en Flutter que digitaliza y objetiva el seguimiento del estudio instrumental fuera del aula. Permite a los docentes asignar tareas específicas y a los alumnos registrar el tiempo dedicado a cada una de ellas, generando estadísticas de progreso.

### 1.2 Requisitos Funcionales

El sistema Playing Tracker debe proporcionar un conjunto completo de funcionalidades que permitan a los docentes gestionar eficientemente sus clases y tareas, mientras que los alumnos puedan registrar y seguir su progreso de estudio de manera objetiva y motivadora.

**Gestión de Usuarios y Autenticación (RF-001):** El sistema implementará un sistema de autenticación robusto basado en Firebase Authentication que permitirá el registro de usuarios con dos roles diferenciados: Docente y Alumno. Los docentes podrán crear y gestionar múltiples clases, mientras que los alumnos se unirán a las clases mediante códigos de acceso únicos. El sistema incluirá funcionalidades de recuperación de contraseñas y gestión completa de perfiles de usuario, garantizando la seguridad y privacidad de los datos personales.

**Gestión de Clases y Membresías (RF-002):** Los docentes tendrán la capacidad de crear clases virtuales con nombres descriptivos y códigos de acceso únicos de 6 caracteres alfanuméricos. El sistema generará automáticamente estos códigos asegurando su unicidad. Los alumnos podrán unirse a las clases introduciendo el código correspondiente, estableciendo así una relación de membresía que permitirá al docente gestionar su grupo de estudiantes de manera eficiente.

**Gestión de Tareas y Asignaciones (RF-003):** El núcleo del sistema radica en la capacidad de los docentes para crear tareas detalladas que incluyan título, descripción completa, tiempo sugerido de estudio en minutos, y archivos adjuntos opcionales (PDFs, archivos de audio, o enlaces externos). Las tareas podrán ser asignadas tanto a clases completas como a alumnos específicos, permitiendo una personalización del aprendizaje. El sistema implementará un mecanismo de fan-out optimizado para crear automáticamente las asignaciones individuales cuando se asigna una tarea a una clase completa.

**Cronómetro y Registro de Sesiones (RF-004):** Los alumnos dispondrán de un cronómetro funcional y persistente que les permitirá registrar su tiempo de estudio con controles completos: iniciar, pausar, reiniciar y finalizar sesiones. El sistema registrará automáticamente cada sesión de estudio, incluyendo la duración total, tiempo en pausa, y notas opcionales del alumno. La persistencia en segundo plano garantizará que el cronómetro continúe funcionando incluso si el usuario cambia de aplicación o recibe una llamada telefónica.

**Estadísticas y Reportes (RF-005):** El sistema generará estadísticas detalladas y visualizaciones atractivas del progreso de estudio, tanto para docentes como para alumnos. Los docentes podrán acceder a dashboards que muestren el progreso de todos sus alumnos, con filtros por fecha, tarea específica, o clase. Los alumnos tendrán acceso a su progreso personal con gráficos que muestren su evolución temporal. El sistema incluirá funcionalidades de exportación de datos en formatos CSV y PDF para análisis externos o reportes institucionales.

### 1.3 Requisitos No Funcionales

Los requisitos no funcionales establecen las características de calidad, rendimiento y restricciones técnicas que el sistema debe cumplir para garantizar una experiencia de usuario óptima y un funcionamiento robusto en entornos educativos reales.

**Rendimiento y Eficiencia (RNF-001):** El sistema debe garantizar tiempos de respuesta inferiores a 2 segundos para todas las operaciones CRUD (crear, leer, actualizar, eliminar), asegurando una experiencia fluida para los usuarios. La arquitectura debe soportar un mínimo de 1000 usuarios concurrentes sin degradación del rendimiento, implementando optimizaciones como índices compuestos en Firestore, cache inteligente de datos frecuentemente accedidos, y técnicas de paginación para listas extensas. El cronómetro debe mantener una precisión de milisegundos y actualizar la interfaz de usuario cada segundo sin afectar el rendimiento general de la aplicación.

**Seguridad y Privacidad (RNF-002):** La seguridad del sistema es crítica dado que maneja datos de menores de edad. Todas las operaciones requerirán autenticación obligatoria, implementando reglas de seguridad granulares que restringen el acceso a datos según el rol del usuario. Los datos se cifrarán tanto en tránsito (HTTPS/TLS) como en reposo (cifrado de Firestore), y el sistema cumplirá estrictamente con el RGPD y la LOPDGDD, incluyendo funcionalidades de consentimiento explícito, derecho al olvido, y portabilidad de datos. Las contraseñas se almacenarán con hash seguro y se implementará autenticación de dos factores como opción adicional.

**Usabilidad y Accesibilidad (RNF-003):** La interfaz de usuario seguirá los principios de Material Design 3, proporcionando una experiencia moderna e intuitiva que se adapte tanto a usuarios jóvenes como adultos. El sistema incluirá soporte completo para temas claro y oscuro, con transiciones suaves entre modos. La accesibilidad será una prioridad, garantizando un contraste mínimo de 4.5:1 para textos normales y 3:1 para textos grandes, soporte completo para TalkBack (Android) y VoiceOver (iOS), y áreas de toque mínimas de 48x48 dp para todos los elementos interactivos. La navegación será fluida con animaciones de 300ms y feedback táctil apropiado.

**Escalabilidad y Mantenibilidad (RNF-004):** La arquitectura NoSQL estará optimizada para evitar hotspots mediante la distribución inteligente de datos y el uso de claves compuestas. El sistema implementará un mecanismo de fan-out eficiente que permita asignar tareas a clases de hasta 100 alumnos simultáneamente sin degradación del rendimiento. La escalabilidad horizontal en Firebase permitirá el crecimiento orgánico del sistema, y la arquitectura modular facilitará el mantenimiento y la adición de nuevas funcionalidades sin afectar el código existente.

### 1.4 Planificación del Proyecto

El proyecto Playing Tracker se desarrollará siguiendo una metodología Scrum adaptada con un enfoque de "diseño primero", priorizando la experiencia de usuario desde las primeras fases del desarrollo. El alcance del proyecto abarca 8 sprints de 2 semanas cada uno, totalizando 16 semanas de desarrollo intensivo con un equipo de un desarrollador full-stack especializado en Flutter y Firebase.

**Metodología y Enfoque:** La metodología adoptada combina los principios ágiles de Scrum con un enfoque centrado en el diseño, donde las primeras dos semanas se dedicarán exclusivamente a la creación de prototipos de alta fidelidad y la implementación del sistema de diseño Material Design 3. Este enfoque garantiza que todas las decisiones de UX/UI estén tomadas antes de comenzar la implementación de la lógica de negocio, reduciendo significativamente los riesgos de rework y mejorando la calidad final del producto.

**Cronograma Detallado:** El Sprint 0 se centrará en la configuración del proyecto, implementación del sistema de diseño Material Design 3, prototipado completo de todas las pantallas, y desarrollo de los componentes base reutilizables. El Sprint 1 abordará la arquitectura de datos, implementando las 7 colecciones de Firestore, modelos de dominio, reglas de seguridad, e índices optimizados. Los Sprints 2-4 cubrirán la funcionalidad core: autenticación, sistema de clases y membresías, y gestión completa de tareas. Los Sprints 5-6 implementarán las funcionalidades avanzadas: cronómetro persistente y sistema de estadísticas. El Sprint 7 se dedicará al testing exhaustivo, optimización de rendimiento, auditoría de seguridad, y preparación para producción.

**Estimación de Costes:** El coste total del proyecto se estima en 32,000€, calculado sobre la base de 16 semanas de desarrollo a 40 horas semanales con una tarifa de 50€/hora para un desarrollador senior especializado en Flutter. Esta estimación incluye el desarrollo completo de la aplicación, pero excluye costes de infraestructura (Firebase ofrece un tier gratuito generoso) y herramientas de desarrollo (Flutter, Android Studio, VS Code son gratuitas). El presupuesto es competitivo para una aplicación de esta complejidad y alcance, especialmente considerando la calidad y escalabilidad de la solución propuesta.

### 1.5 Cronograma de Desarrollo (Diagrama de Gantt)

El siguiente diagrama de Gantt muestra la planificación detallada del proyecto Playing Tracker, organizando las actividades por sprints con sus respectivos entregables y dependencias:

```mermaid
sequenceDiagram
    participant Dev as Desarrollador
    participant UI as UI/UX
    participant DB as Base de Datos
    participant Auth as Autenticación
    participant Core as Funcionalidad Core
    participant Prod as Producción

    Note over Dev,Prod: Cronograma del Proyecto Playing Tracker - 16 Semanas

    Dev->>UI: Sprint 0: Diseño UI/UX (Días 0-14)
    Note over UI: Configuración y Material Design 3<br/>Prototipado y Componentes

    Dev->>DB: Sprint 1: Arquitectura (Días 15-28)
    Note over DB: Modelos y Base de Datos<br/>Reglas de Seguridad

    Dev->>Auth: Sprint 2: Autenticación (Días 29-42)
    Note over Auth: Firebase Auth y Perfiles<br/>Navegación por Roles

    Dev->>Core: Sprint 3: Sistema de Clases (Días 43-56)
    Note over Core: CRUD Clases y Membresías<br/>Gestión de Alumnos

    Dev->>Core: Sprint 4: Gestión de Tareas (Días 57-70)
    Note over Core: CRUD Tareas y Asignaciones<br/>Estados y Filtros

    Dev->>Core: Sprint 5: Cronómetro (Días 71-84)
    Note over Core: Cronómetro y Sesiones<br/>Persistencia y Historial

    Dev->>Core: Sprint 6: Estadísticas (Días 85-98)
    Note over Core: Gráficos y Dashboards<br/>Filtros y Exportación

    Dev->>Prod: Sprint 7: Testing y Producción (Días 99-112)
    Note over Prod: Testing y Optimización<br/>Auditoría y Producción
```

**Metodología de Seguimiento:** Cada sprint incluye entregables específicos y medibles, con revisiones semanales para asegurar el cumplimiento de los objetivos. El diagrama muestra las dependencias entre tareas, permitiendo una gestión eficiente de recursos y la identificación temprana de posibles retrasos. Las actividades están distribuidas de manera que permitan testing continuo y feedback iterativo, garantizando la calidad del producto final.

---

## 2. 💻 Necesidades Hardware, Software y Personal

### 2.1 Infraestructura Hardware

**Equipamiento de Desarrollo:** Para el desarrollo eficiente de Playing Tracker se requiere un ordenador de desarrollo de alta gama, específicamente un MacBook Pro M2 con 16GB de RAM y 512GB de SSD. Esta elección se justifica por la necesidad de compatibilidad nativa con iOS y Android, ya que Flutter requiere acceso a los SDKs de ambas plataformas. El chip M2 proporciona el rendimiento necesario para compilaciones rápidas y simulaciones fluidas, mientras que los 16GB de RAM permiten ejecutar múltiples emuladores simultáneamente para testing cross-platform. El coste estimado es de 2,500€ si no se posee el equipo.

**Dispositivos de Testing:** Para garantizar la calidad y compatibilidad de la aplicación, se necesitan dispositivos físicos de testing que representen los casos de uso más comunes. Se recomienda un iPhone 14 Pro para testing en iOS y un Samsung Galaxy S23 para testing en Android, cubriendo así las dos plataformas principales y diferentes tamaños de pantalla. Estos dispositivos permitirán testing de funcionalidades específicas como el cronómetro en segundo plano, notificaciones push, y optimizaciones de rendimiento. El coste total de los dispositivos de testing es de 1,500€.

### 2.2 Software Necesario

**Software de Desarrollo Gratuito:** El stack tecnológico de Playing Tracker se basa principalmente en herramientas de código abierto y gratuitas. Flutter SDK 3.x servirá como framework principal, proporcionando desarrollo multiplataforma nativo. Android Studio será el IDE principal para desarrollo Android, mientras que VS Code con extensiones Flutter ofrecerá un entorno de desarrollo ligero y personalizable. Firebase CLI facilitará la gestión de servicios de Firebase, Git proporcionará control de versiones robusto, y Dart SDK será el lenguaje de programación. Esta selección minimiza los costes de licencias mientras proporciona herramientas de clase empresarial.

**Software de Pago Opcional:** Para optimizar el proceso de diseño y desarrollo, se recomienda Figma Pro (20€/mes) para la creación de prototipos de alta fidelidad y colaboración en el diseño. Firebase Blaze Plan será necesario para producción, operando bajo un modelo pay-as-you-go que se adapta al crecimiento del usuario. Estos costes son opcionales durante la fase de desarrollo pero recomendados para un producto de calidad profesional.

### 2.3 Personal Necesario

**Perfil del Desarrollador:** El proyecto requiere un desarrollador full-stack senior especializado en Flutter con un mínimo de 3 años de experiencia en desarrollo móvil y integración con Firebase. Este profesional será responsable del desarrollo completo de la aplicación, incluyendo la implementación de UI/UX según las especificaciones de Material Design 3, la integración completa con Firebase (Authentication, Firestore, Storage), y el testing exhaustivo en múltiples dispositivos. El desarrollador debe poseer conocimientos profundos en arquitectura de aplicaciones móviles, gestión de estado con Cubit, y optimización de rendimiento. El coste total del desarrollo se estima en 32,000€ (640 horas × 50€/hora), representando el 88% del presupuesto total del proyecto.

### 2.4 Recursos de Interconexión y Hosting

**Infraestructura en la Nube:** Firebase proporcionará la infraestructura completa de backend para Playing Tracker, ofreciendo servicios gratuitos generosos que cubren las necesidades iniciales del proyecto. Firebase Authentication será completamente gratuito, Firestore proporciona 1GB de almacenamiento gratuito (luego $0.18/GB), Firebase Storage incluye 1GB gratuito (luego $0.026/GB), y Firebase Hosting es completamente gratuito. Esta arquitectura serverless elimina la necesidad de gestión de servidores y proporciona escalabilidad automática.

**Estimación de Costes Operativos:** Los costes anuales de infraestructura se estiman entre 0-100€ dependiendo del crecimiento de usuarios, más 15€/año para el dominio de la aplicación. El modelo de pago por uso de Firebase se adapta perfectamente al crecimiento orgánico del proyecto, permitiendo comenzar con costes mínimos y escalar según la demanda real. El total anual estimado de 115€ representa menos del 0.5% del presupuesto total del proyecto.

### 2.5 Alternativas Técnicas Consideradas

**Análisis de Alternativas:** Durante la fase de planificación se evaluaron múltiples alternativas tecnológicas. React Native + Node.js ofrecía un ecosistema más maduro pero con menor rendimiento y mayor complejidad de desarrollo. Flutter + Supabase proporcionaba una solución open source atractiva pero con menor madurez y mayor configuración inicial. Flutter + AWS ofrecía máxima escalabilidad pero con mayor complejidad y costes operativos significativos.

**Justificación de la Elección:** La combinación Flutter + Firebase se seleccionó por ofrecer el mejor balance entre velocidad de desarrollo, coste controlado, y escalabilidad para un MVP. Material Design 3 garantiza consistencia visual y accesibilidad nativa, mientras que la arquitectura NoSQL de Firestore proporciona la flexibilidad necesaria para evolucionar el esquema de datos según las necesidades del proyecto. Esta elección minimiza los riesgos técnicos y acelera el time-to-market.

### 2.6 Presupuesto Detallado y Financiación

**Desglose de Costes:** El presupuesto total del proyecto asciende a 36,340€, distribuido en hardware (4,000€ si no se posee), software (340€/año), y personal (32,000€). El coste de desarrollo representa el 88% del presupuesto, lo cual es típico para proyectos de software donde el valor principal reside en el conocimiento y la experiencia del desarrollador. Los costes de hardware y software son una inversión única o recurrente mínima comparada con el valor generado.

**Estrategia de Financiación:** El proyecto se financiará inicialmente mediante autofinanciación, permitiendo control total sobre el desarrollo y la propiedad intelectual. Para fases posteriores de marketing y expansión se considerará crowdfunding dirigido a la comunidad educativa musical. Adicionalmente, se explorarán subvenciones de programas de innovación educativa que reconozcan el valor pedagógico de la aplicación. Esta estrategia diversificada minimiza los riesgos financieros y permite un crecimiento sostenible del proyecto.

---

## 3. 🎯 Diagrama de Casos de Uso

### 3.1 Actores del Sistema

El sistema Playing Tracker interactúa con tres tipos de actores principales que representan los diferentes roles y entidades involucradas en el proceso educativo musical:

**Docente:** Representa al profesor de música que utiliza la aplicación para gestionar sus clases, crear tareas, asignar actividades a sus alumnos, y supervisar el progreso de estudio. El docente tiene permisos administrativos completos sobre las clases que crea y puede acceder a estadísticas detalladas de todos sus alumnos. Este actor es responsable de la configuración inicial del entorno educativo y la definición de los objetivos de aprendizaje.

**Alumno:** Representa al estudiante de música que utiliza la aplicación para acceder a sus tareas asignadas, registrar sesiones de estudio mediante el cronómetro, y consultar su progreso personal. El alumno tiene permisos limitados a sus propios datos y tareas asignadas, garantizando la privacidad y seguridad de la información. Este actor es el usuario final que se beneficia directamente de las funcionalidades de seguimiento y motivación.

**Sistema:** Representa la aplicación Playing Tracker y sus componentes internos que procesan automáticamente los datos, generan estadísticas, envían notificaciones, y mantienen la sincronización entre dispositivos. El sistema actúa como intermediario entre docentes y alumnos, facilitando la comunicación y el seguimiento del progreso educativo.

### 3.2 Diagrama de Casos de Uso

```mermaid
flowchart LR
flowchart LR
    subgraph "Actores"
        D[👨‍🏫 Docente]
        A[👨‍🎓 Alumno]
    end

    subgraph "Sistema Playing Tracker"
        UC1[Autenticación]
        UC2[Crear clase]
        UC3[Ver clase]
        UC4[Crear tarea]
        UC5[Ver tareas]
        UC6[Estadísticas]
        UC7[Unirse a clase]
        UC8[Iniciar sesión]
        UC9[Finalizar sesión]
        UC10[Progreso]
    end

    %% Flujo Docente
    D --> UC1
    UC1 --> UC2
    UC2 --> UC3
    UC3 --> UC4
    UC4 --> UC5
    UC5 --> UC6

    %% Flujo Alumno
    A --> UC1
    UC1 --> UC7
    UC7 --> UC5
    UC5 --> UC8
    UC8 --> UC9
    UC9 --> UC10

    %% Estilos
    classDef actor fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef docente fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef alumno fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef comun fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px

    class D,A actor
    class UC2,UC3,UC4,UC5,UC6 docente
    class UC7,UC8,UC9,UC10 alumno
    class UC1 comun
```

### 3.3 Casos de Uso Principales

#### UC-001: Autenticación de Usuario

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El usuario se autentica en el sistema Playing Tracker utilizando sus credenciales de email y contraseña, siendo redirigido automáticamente a la interfaz correspondiente según su rol (docente o alumno). |
| **Precondiciones** | El usuario debe estar registrado previamente en el sistema con un email válido y contraseña. La aplicación debe estar instalada y funcionando correctamente en el dispositivo del usuario. |
| **Pasos habituales** | 1. El usuario abre la aplicación Playing Tracker. 2. El sistema presenta la pantalla de login con campos para email y contraseña. 3. El usuario introduce sus credenciales y presiona el botón "Iniciar Sesión". 4. El sistema valida las credenciales contra Firebase Authentication. 5. Si las credenciales son correctas, el sistema consulta el rol del usuario en Firestore. 6. El sistema redirige al usuario a la pantalla home correspondiente (docente o alumno). 7. El sistema establece la sesión activa y carga los datos del usuario. |
| **Postcondiciones** | El usuario está autenticado en el sistema con su sesión activa. Se ha cargado su perfil completo con nombre, apellidos, email y rol. El usuario puede acceder a todas las funcionalidades permitidas según su rol. |
| **Excepciones** | Si las credenciales son incorrectas, el sistema muestra un mensaje de error específico. Si el usuario no existe, se ofrece la opción de registro. Si hay problemas de conectividad, se muestra un mensaje de error de red. Si el usuario está desactivado, se informa del estado de la cuenta. |

#### UC-002: Crear Clase (Docente)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El docente crea una nueva clase virtual en el sistema, definiendo su nombre, descripción opcional, y obteniendo automáticamente un código de acceso único que podrá compartir con sus alumnos para que se unan a la clase. |
| **Precondiciones** | El docente debe estar autenticado en el sistema con rol de docente. Debe tener conexión a internet activa. No debe existir una clase con el mismo nombre creada por el mismo docente. |
| **Pasos habituales** | 1. El docente accede a la pantalla "Mis Clases" desde el menú principal. 2. Presiona el botón "Crear Nueva Clase". 3. El sistema presenta un formulario con campos para nombre de clase y descripción opcional. 4. El docente introduce el nombre de la clase (mínimo 3 caracteres) y una descripción opcional. 5. Presiona el botón "Crear Clase". 6. El sistema valida los datos introducidos. 7. El sistema genera automáticamente un código de acceso único de 6 caracteres alfanuméricos. 8. El sistema crea el documento de clase en Firestore con todos los datos. 9. El sistema muestra la nueva clase creada con su código de acceso. |
| **Postcondiciones** | Se ha creado una nueva clase en el sistema con un identificador único. La clase tiene un código de acceso único generado automáticamente. El docente puede ver la clase en su lista de clases. La clase está activa y lista para que los alumnos se unan. |
| **Excepciones** | Si el nombre de la clase ya existe para el mismo docente, se muestra un mensaje de error pidiendo un nombre diferente. Si hay problemas de conectividad, se informa del error y se sugiere reintentar. Si el formulario está incompleto, se resaltan los campos obligatorios. Si hay un error interno del sistema, se muestra un mensaje genérico de error. |

#### UC-003: Unirse a Clase (Alumno)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El alumno se une a una clase existente introduciendo el código de acceso proporcionado por su docente, estableciendo así una relación de membresía que le permitirá acceder a las tareas y actividades de esa clase. |
| **Precondiciones** | El alumno debe estar autenticado en el sistema con rol de alumno. Debe tener un código de acceso válido proporcionado por un docente. La clase debe existir y estar activa en el sistema. El alumno no debe estar ya unido a esa clase. |
| **Pasos habituales** | 1. El alumno accede a la pantalla "Unirse a Clase" desde el menú principal. 2. El sistema presenta un campo de texto para introducir el código de acceso. 3. El alumno introduce el código de 6 caracteres proporcionado por su docente. 4. Presiona el botón "Unirse a Clase". 5. El sistema valida el formato del código (6 caracteres alfanuméricos). 6. El sistema busca la clase correspondiente al código en Firestore. 7. Si la clase existe y está activa, el sistema crea un documento de membresía. 8. El sistema actualiza la lista de clases del alumno. 9. El sistema muestra un mensaje de confirmación de unión exitosa. |
| **Postcondiciones** | El alumno se ha unido exitosamente a la clase. Se ha creado una relación de membresía en el sistema. El alumno puede ver la clase en su lista de clases. El alumno puede acceder a las tareas asignadas a esa clase. El docente puede ver al alumno en la lista de miembros de la clase. |
| **Excepciones** | Si el código introducido no existe, se muestra un mensaje de error indicando que el código es inválido. Si la clase está desactivada, se informa que la clase no está disponible. Si el alumno ya está unido a la clase, se muestra un mensaje informativo. Si hay problemas de conectividad, se sugiere verificar la conexión e intentar nuevamente. |

#### UC-004: Crear Tarea (Docente)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El docente crea una nueva tarea de estudio definiendo todos sus detalles (título, descripción, tiempo sugerido, archivos adjuntos) y la asigna a una clase completa o a alumnos específicos, generando automáticamente las asignaciones individuales correspondientes. |
| **Precondiciones** | El docente debe estar autenticado con rol de docente. Debe tener al menos una clase creada o alumnos disponibles para asignar. Debe tener conexión a internet activa. Los datos de la tarea deben cumplir con las validaciones establecidas. |
| **Pasos habituales** | 1. El docente accede a la pantalla "Crear Tarea" desde el menú de gestión de tareas. 2. El sistema presenta un formulario completo con todos los campos necesarios. 3. El docente introduce el título de la tarea (mínimo 5 caracteres). 4. El docente escribe una descripción detallada de la tarea (mínimo 10 caracteres). 5. El docente especifica el tiempo sugerido de estudio en minutos (mínimo 5, máximo 480). 6. Opcionalmente, el docente adjunta archivos (PDF, audio) o enlaces externos. 7. El docente selecciona los destinatarios: clase completa o alumnos específicos. 8. Opcionalmente, el docente establece una fecha límite para la tarea. 9. El docente presiona el botón "Crear y Asignar Tarea". 10. El sistema valida todos los datos introducidos. 11. El sistema crea el documento de tarea en Firestore. 12. El sistema ejecuta el fan-out para crear las asignaciones individuales. 13. El sistema muestra confirmación de creación exitosa. |
| **Postcondiciones** | Se ha creado una nueva tarea en el sistema con identificador único. La tarea ha sido asignada a todos los destinatarios seleccionados. Cada alumno destinatario tiene una asignación individual creada. Los alumnos pueden ver la nueva tarea en su lista de tareas pendientes. El docente puede gestionar la tarea desde su panel de control. |
| **Excepciones** | Si algún campo obligatorio está vacío, se resaltan los campos faltantes. Si el tiempo sugerido está fuera del rango permitido, se muestra un mensaje de error específico. Si hay problemas durante el fan-out, se informa del error y se sugiere reintentar. Si los archivos adjuntos exceden el tamaño permitido, se informa del límite. Si no hay destinatarios disponibles, se sugiere crear una clase o agregar alumnos. |

#### UC-005: Iniciar Sesión de Estudio (Alumno)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El alumno inicia una sesión de estudio cronometrada para una tarea específica, activando el cronómetro persistente que registrará automáticamente el tiempo dedicado al estudio, incluso si la aplicación pasa a segundo plano. |
| **Precondiciones** | El alumno debe estar autenticado con rol de alumno. Debe tener al menos una tarea asignada con estado "pending" o "in_progress". No debe tener una sesión activa en curso. Debe tener conexión a internet para el registro inicial. |
| **Pasos habituales** | 1. El alumno accede a su lista de tareas desde el menú principal. 2. El alumno selecciona una tarea específica de la lista. 3. El sistema muestra los detalles de la tarea y el botón "Iniciar Estudio". 4. El alumno presiona el botón "Iniciar Estudio". 5. El sistema presenta la pantalla de cronómetro con controles de estudio. 6. El sistema registra el inicio de la sesión con timestamp preciso. 7. El sistema inicia el cronómetro y lo mantiene activo. 8. El sistema actualiza el estado de la asignación a "in_progress". 9. El alumno puede pausar, reanudar o finalizar la sesión en cualquier momento. |
| **Postcondiciones** | Se ha iniciado una sesión de estudio activa para la tarea seleccionada. El cronómetro está funcionando y registrando el tiempo transcurrido. El estado de la asignación se ha actualizado a "in_progress". El sistema está preparado para persistir la sesión en segundo plano. El alumno puede ver el tiempo transcurrido en tiempo real. |
| **Excepciones** | Si la tarea no está disponible, se muestra un mensaje explicativo. Si ya hay una sesión activa, se informa y se ofrece la opción de finalizarla primero. Si hay problemas de conectividad, se inicia la sesión en modo offline. Si la tarea ha expirado, se informa del estado y se sugiere contactar al docente. |

#### UC-006: Finalizar Sesión de Estudio (Alumno)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El alumno finaliza su sesión de estudio cronometrada, confirmando la finalización y permitiendo al sistema calcular la duración total, actualizar las estadísticas, y registrar la sesión completada en la base de datos. |
| **Precondiciones** | Debe existir una sesión de estudio activa iniciada previamente. El cronómetro debe estar funcionando y haber registrado al menos 1 minuto de tiempo. El alumno debe estar autenticado y tener conexión a internet para sincronizar los datos. |
| **Pasos habituales** | 1. El alumno está en la pantalla de cronómetro con una sesión activa. 2. El alumno presiona el botón "Finalizar Sesión". 3. El sistema presenta una pantalla de confirmación mostrando el tiempo total registrado. 4. El alumno puede agregar notas opcionales sobre la sesión de estudio. 5. El alumno confirma la finalización presionando "Confirmar". 6. El sistema calcula la duración total de la sesión (tiempo activo menos pausas). 7. El sistema crea el documento de sesión en Firestore con todos los datos. 8. El sistema actualiza las estadísticas del alumno (sesiones totales, tiempo total). 9. El sistema actualiza el progreso de la asignación correspondiente. 10. El sistema muestra un mensaje de confirmación y regresa a la lista de tareas. |
| **Postcondiciones** | La sesión de estudio ha sido registrada exitosamente en la base de datos. Las estadísticas del alumno se han actualizado con la nueva sesión. El progreso de la tarea se ha actualizado con el tiempo adicional registrado. El cronómetro se ha detenido y la sesión ya no está activa. El alumno puede ver la sesión en su historial personal. |
| **Excepciones** | Si el tiempo registrado es menor a 1 minuto, se sugiere continuar estudiando. Si hay problemas de conectividad, se guarda localmente y se sincroniza cuando se recupere la conexión. Si hay errores al guardar, se informa del problema y se sugiere reintentar. Si la sesión ya fue finalizada, se muestra un mensaje informativo. |

#### UC-007: Consultar Estadísticas de Progreso (Docente/Alumno)

| Campo | Descripción |
|-------|-------------|
| **Descripción breve** | El usuario (docente o alumno) consulta estadísticas detalladas de progreso de estudio, aplicando filtros específicos según sus necesidades, y visualizando gráficos y métricas que le permiten evaluar el rendimiento y evolución del aprendizaje musical. |
| **Precondiciones** | El usuario debe estar autenticado en el sistema. Debe existir al menos una sesión de estudio registrada para generar estadísticas. Para docentes, debe tener al menos una clase con alumnos activos. Para alumnos, debe tener al menos una tarea asignada y una sesión completada. |
| **Pasos habituales** | 1. El usuario accede a la sección "Estadísticas" desde el menú principal. 2. El sistema presenta la pantalla de estadísticas con filtros disponibles. 3. El usuario selecciona el período de tiempo (última semana, mes, trimestre, año). 4. Para docentes: selecciona la clase específica o "todas las clases". 5. Para alumnos: selecciona la tarea específica o "todas las tareas". 6. El usuario aplica filtros adicionales (días de la semana, horas del día). 7. El sistema consulta los datos correspondientes en Firestore. 8. El sistema genera gráficos y métricas en tiempo real. 9. El usuario visualiza las estadísticas con gráficos interactivos. 10. El usuario puede exportar los datos en formato CSV o PDF. |
| **Postcondiciones** | Se han mostrado las estadísticas solicitadas con los filtros aplicados. Los gráficos son interactivos y permiten exploración detallada. Los datos están actualizados y reflejan el estado actual del progreso. El usuario puede exportar la información para análisis externo. Las métricas son precisas y basadas en datos reales de sesiones registradas. |
| **Excepciones** | Si no hay datos suficientes para el período seleccionado, se muestra un mensaje informativo y se sugieren otros períodos. Si hay problemas de conectividad, se muestran los datos en caché con indicador de actualización pendiente. Si los filtros no devuelven resultados, se sugiere ampliar el rango de búsqueda. Si hay errores en la generación de gráficos, se muestran los datos en formato tabular. |

---

## 4. 🎨 Diseño de la Interfaz de la Aplicación

### 4.1 Flujo de Navegación Principal

```
Splash Screen
    ↓
Login/Register
    ↓
Home (según rol)
    ├── Docente: Dashboard → Clases → Tareas → Estadísticas
    └── Alumno: Dashboard → Tareas → Cronómetro → Progreso
```

### 4.2 Pantallas Principales

#### Pantalla de Login
- **Elementos:** Logo, campos email/contraseña, botón login, enlace registro
- **Diseño:** Material Design 3, tema claro/oscuro
- **Validaciones:** Email válido, contraseña requerida

#### Pantalla de Registro
- **Elementos:** Formulario completo (nombre, apellidos, email, contraseña, rol)
- **Diseño:** Formulario paso a paso, validaciones en tiempo real
- **Validaciones:** Todos los campos obligatorios, email único

#### Home Docente
- **Elementos:** Cards de clases, botón crear clase, estadísticas rápidas
- **Diseño:** Grid de cards, navegación por tabs
- **Funcionalidades:** Acceso rápido a funciones principales

#### Home Alumno
- **Elementos:** Lista de tareas pendientes, cronómetro rápido, progreso
- **Diseño:** Lista vertical, cards de tareas
- **Funcionalidades:** Inicio rápido de estudio

#### Pantalla de Cronómetro
- **Elementos:** Cronómetro grande, controles (iniciar/pausar/finalizar), información de tarea
- **Diseño:** Interfaz minimalista, colores de estado
- **Funcionalidades:** Persistencia en segundo plano

### 4.3 Componentes Reutilizables

- **CustomButton:** Botones con Material Design 3
- **CustomTextField:** Campos de texto con validaciones
- **CustomCard:** Cards para mostrar información
- **LoadingOverlay:** Indicadores de carga
- **CustomAppBar:** Barra de navegación personalizada

---

## 5. 🗄️ Diseño de la Base de Datos

### 5.1 Modelo de Datos NoSQL (Firestore)

#### Tipo de Base de Datos
- **Tipo:** Document-store (Firestore)
- **Justificación:** Escalabilidad, flexibilidad, integración con Firebase

#### Entidades Principales

##### 1. Teachers (Docentes)
```json
{
  "id": "string (UID)",
  "firstName": "string (obligatorio)",
  "lastName": "string (obligatorio)",
  "email": "string (obligatorio, único)",
  "createdAt": "timestamp (obligatorio)",
  "updatedAt": "timestamp (obligatorio)",
  "isActive": "boolean (obligatorio, default: true)"
}
```

##### 2. Students (Alumnos)
```json
{
  "id": "string (UID)",
  "firstName": "string (obligatorio)",
  "lastName": "string (obligatorio)",
  "email": "string (obligatorio, único)",
  "createdAt": "timestamp (obligatorio)",
  "updatedAt": "timestamp (obligatorio)",
  "isActive": "boolean (obligatorio, default: true)",
  "totalSessionsCount": "number (obligatorio, default: 0)",
  "totalDurationLogged": "number (obligatorio, default: 0)",
  "lastSessionDate": "timestamp (opcional)"
}
```

##### 3. Classes (Clases)
```json
{
  "id": "string (obligatorio, único)",
  "name": "string (obligatorio)",
  "description": "string (opcional)",
  "ownerTeacherId": "string (obligatorio)",
  "accessCode": "string (obligatorio, único, 6 caracteres)",
  "createdAt": "timestamp (obligatorio)",
  "updatedAt": "timestamp (obligatorio)",
  "isActive": "boolean (obligatorio, default: true)"
}
```

##### 4. Memberships (Membresías)
```json
{
  "id": "string (obligatorio, único)",
  "classId": "string (obligatorio)",
  "studentId": "string (obligatorio)",
  "teacherId": "string (obligatorio)",
  "className": "string (obligatorio)",
  "joinedAt": "timestamp (obligatorio)",
  "isActive": "boolean (obligatorio, default: true)"
}
```

##### 5. Tasks (Tareas)
```json
{
  "id": "string (obligatorio, único)",
  "title": "string (obligatorio)",
  "description": "string (obligatorio)",
  "createdBy": "string (obligatorio)",
  "durationSuggested": "number (obligatorio, minutos)",
  "attachments": "array (opcional)",
  "createdAt": "timestamp (obligatorio)",
  "updatedAt": "timestamp (obligatorio)",
  "dueDate": "timestamp (opcional)",
  "isActive": "boolean (obligatorio, default: true)"
}
```

##### 6. Assignments (Asignaciones)
```json
{
  "id": "string (obligatorio, formato: taskId_studentId)",
  "taskId": "string (obligatorio)",
  "studentId": "string (obligatorio)",
  "teacherId": "string (obligatorio)",
  "status": "string (obligatorio, enum: pending|in_progress|completed)",
  "assignedAt": "timestamp (obligatorio)",
  "completedAt": "timestamp (opcional)",
  "sessionsCount": "number (obligatorio, default: 0)",
  "totalDurationLogged": "number (obligatorio, default: 0)",
  "lastSessionDate": "timestamp (opcional)"
}
```

##### 7. Sessions (Sesiones)
```json
{
  "id": "string (obligatorio, único)",
  "studentId": "string (obligatorio)",
  "taskId": "string (obligatorio)",
  "teacherId": "string (obligatorio)",
  "startTime": "timestamp (obligatorio)",
  "endTime": "timestamp (obligatorio)",
  "totalDuration": "number (obligatorio, segundos)",
  "pausedDuration": "number (obligatorio, default: 0)",
  "dateLogged": "timestamp (obligatorio)",
  "monthBucket": "string (obligatorio, formato: YYYY-MM)",
  "notes": "string (opcional)",
  "createdAt": "timestamp (obligatorio)"
}
```

### 5.2 Ejemplos de Documentos

#### Ejemplo 1: Teacher
```json
{
  "id": "teacher_123",
  "firstName": "María",
  "lastName": "García López",
  "email": "maria.garcia@conservatorio.com",
  "createdAt": "2025-10-15T10:30:00Z",
  "updatedAt": "2025-10-15T10:30:00Z",
  "isActive": true
}
```

#### Ejemplo 2: Student con Agregados
```json
{
  "id": "student_456",
  "firstName": "Carlos",
  "lastName": "Rodríguez Martín",
  "email": "carlos.rodriguez@estudiante.com",
  "createdAt": "2025-10-15T11:00:00Z",
  "updatedAt": "2025-10-20T15:30:00Z",
  "isActive": true,
  "totalSessionsCount": 15,
  "totalDurationLogged": 4500,
  "lastSessionDate": "2025-10-20T15:30:00Z"
}
```

#### Ejemplo 3: Session Completa
```json
{
  "id": "session_789",
  "studentId": "student_456",
  "taskId": "task_101",
  "teacherId": "teacher_123",
  "startTime": "2025-10-20T14:00:00Z",
  "endTime": "2025-10-20T15:30:00Z",
  "totalDuration": 5400,
  "pausedDuration": 300,
  "dateLogged": "2025-10-20T14:00:00Z",
  "monthBucket": "2025-10",
  "notes": "Estudio de escalas mayores",
  "createdAt": "2025-10-20T15:30:00Z"
}
```

### 5.3 Scripts de Configuración

#### Reglas de Seguridad Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuth() { return request.auth != null; }

    match /teachers/{teacherId} {
      allow read, write: if isAuth() && request.auth.uid == teacherId;
    }

    match /students/{studentId} {
      allow read, write: if isAuth() && request.auth.uid == studentId;
    }

    match /classes/{classId} {
      allow write: if isAuth() && resource.data.ownerTeacherId == request.auth.uid;
      allow read: if isAuth();
    }

    match /memberships/{membershipId} {
      allow write: if isAuth() && request.resource.data.teacherId == request.auth.uid;
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
    }

    match /tasks/{taskId} {
      allow write: if isAuth() && resource.data.createdBy == request.auth.uid;
      allow read: if isAuth();
    }

    match /assignments/{assignmentId} {
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
      allow write: if isAuth() && (resource.data.teacherId == request.auth.uid
                                  || request.resource.data.studentId == request.auth.uid);
    }

    match /sessions/{sessionId} {
      allow create: if isAuth() && request.resource.data.studentId == request.auth.uid;
      allow read: if isAuth() && (resource.data.studentId == request.auth.uid
                                  || resource.data.teacherId == request.auth.uid);
      allow update, delete: if false;
    }
  }
}
```

#### Datos Iniciales de Prueba
```json
{
  "teachers": [
    {
      "id": "teacher_001",
      "firstName": "Ana",
      "lastName": "Martínez",
      "email": "ana.martinez@conservatorio.com",
      "createdAt": "2025-10-01T09:00:00Z",
      "updatedAt": "2025-10-01T09:00:00Z",
      "isActive": true
    }
  ],
  "students": [
    {
      "id": "student_001",
      "firstName": "Luis",
      "lastName": "González",
      "email": "luis.gonzalez@estudiante.com",
      "createdAt": "2025-10-01T10:00:00Z",
      "updatedAt": "2025-10-01T10:00:00Z",
      "isActive": true,
      "totalSessionsCount": 0,
      "totalDurationLogged": 0
    }
  ],
  "classes": [
    {
      "id": "class_001",
      "name": "Piano Nivel 1",
      "description": "Clase de piano para principiantes",
      "ownerTeacherId": "teacher_001",
      "accessCode": "ABC123",
      "createdAt": "2025-10-01T09:30:00Z",
      "updatedAt": "2025-10-01T09:30:00Z",
      "isActive": true
    }
  ]
}
```

---

## 6. 🏗️ Diagrama de Clases

### 6.1 Clases Principales del Sistema

#### AuthCubit
```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> loginUser(String email, String password);
  Future<void> registerUser(UserModel user);
  Future<void> logout();
  Future<void> resetPassword(String email);
}
```

#### TaskCubit
```dart
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;

  TaskCubit(this._taskRepository) : super(TaskInitial());

  Future<void> createTask(TaskModel task);
  Future<void> assignTask(String taskId, List<String> studentIds);
  Future<void> updateTaskStatus(String taskId, TaskStatus status);
  Future<void> getTasksByClass(String classId);
}
```

#### SessionCubit
```dart
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository _sessionRepository;

  SessionCubit(this._sessionRepository) : super(SessionInitial());

  Future<void> startSession(String taskId);
  Future<void> pauseSession();
  Future<void> resumeSession();
  Future<void> endSession();
  Future<void> getSessionHistory(String studentId);
}
```

### 6.2 Modelos de Dominio

#### UserModel
```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

#### TaskModel
```dart
@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required String createdBy,
    required int durationSuggested,
    List<Attachment>? attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dueDate,
    @Default(true) bool isActive,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
}
```

#### SessionModel
```dart
@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String studentId,
    required String taskId,
    required String teacherId,
    required DateTime startTime,
    required DateTime endTime,
    required int totalDuration,
    @Default(0) int pausedDuration,
    required DateTime dateLogged,
    required String monthBucket,
    String? notes,
    required DateTime createdAt,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}
```

### 6.3 Diagrama de Objetos

```
AuthCubit
├── AuthRepository
│   ├── AuthService
│   └── FirestoreService
└── AuthState
    ├── AuthInitial
    ├── AuthLoading
    ├── AuthSuccess
    └── AuthError

TaskCubit
├── TaskRepository
│   └── TaskService
└── TaskState
    ├── TaskInitial
    ├── TaskLoading
    ├── TaskSuccess
    └── TaskError

SessionCubit
├── SessionRepository
│   └── SessionService
└── SessionState
    ├── SessionInitial
    ├── SessionRunning
    ├── SessionPaused
    └── SessionCompleted
```

---

## 📊 Resumen del Diseño

Este documento establece las bases técnicas y funcionales para el desarrollo de **Playing Tracker**, una aplicación móvil innovadora para el seguimiento del estudio musical. La arquitectura propuesta, basada en Flutter + Firebase con gestión de estado mediante Cubit, garantiza escalabilidad, rendimiento y una excelente experiencia de usuario.

**Puntos clave del diseño:**
- ✅ Arquitectura NoSQL optimizada con 7 colecciones
- ✅ Gestión de estado con Cubit para simplicidad
- ✅ Material Design 3 para experiencia moderna
- ✅ Seguridad robusta con reglas granulares
- ✅ Escalabilidad anti-hotspot implementada
- ✅ Presupuesto controlado y desarrollo iterativo

El proyecto está listo para comenzar con el **Sprint 0** de implementación del diseño UI/UX.
