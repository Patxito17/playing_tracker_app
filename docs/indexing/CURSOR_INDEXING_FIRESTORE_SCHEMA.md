# Esquema de Firestore - Playing Tracker

**Última actualización:** Octubre 2025
**Propósito:** Documentación completa del esquema de base de datos, modelos de datos y reglas de seguridad

---

## Arquitectura de Colecciones

### Modelo de Colecciones Top-Level (7 Colecciones)

Adoptamos una **arquitectura de colecciones desanidadas de primer nivel** que modela relaciones N:M mediante documentos intermedios, optimizada para **rendimiento en lectura** y **escalabilidad anti-hotspot**.

| Colección | Propósito | Justificación |
|-----------|-----------|---------------|
| `teachers` | Perfiles de docentes | Colección top-level con UID como ID |
| `students` | Perfiles de alumnos con agregados | Incluye contadores denormalizados para métricas |
| `classes` | Definiciones de clases/grupos | IDs globales únicos para consultas eficientes |
| `memberships` | Relación Alumno ↔ Clase (N:M) | Evita arrays grandes y hotspots |
| `tasks` | Definición maestra de tareas | Top-level para reutilización entre clases |
| `assignments` | Progreso individual tarea-alumno | Estado 1:1 con clave compuesta `${taskId}_${studentId}` |
| `sessions` | Registros atómicos de estudio | Top-level para collection group queries |

---

## Estructura Detallada de Colecciones

### 1. `teachers` - Perfiles de Docentes

**Ruta:** `teachers/{teacherId}`
**ID:** UID de Firebase Auth

```javascript
{
  id: string,                    // UID de Firebase Auth
  firstName: string,             // Nombre (mín 3 caracteres)
  lastName: string,              // Apellidos (mín 3 caracteres)
  email: string,                 // Email único
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean              // Estado de la cuenta
}
```

**Índices requeridos:**
- Ninguno (consultas por ID directo)

**Reglas de seguridad:**
- Lectura/Escritura: Solo el propio docente (`request.auth.uid == teacherId`)

---

### 2. `students` - Perfiles de Alumnos (Con Agregados)

**Ruta:** `students/{studentId}`
**ID:** UID de Firebase Auth

```javascript
{
  id: string,                    // UID de Firebase Auth
  firstName: string,             // Nombre (mín 3 caracteres)
  lastName: string,              // Apellidos (mín 3 caracteres)
  email: string,                 // Email único
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean,             // Estado de la cuenta

  // Agregados denormalizados para rendimiento
  totalSessionsCount: number,    // Total de sesiones completadas
  totalDurationLogged: number,   // Segundos totales de estudio
  lastSessionDate: Timestamp    // Fecha de la última sesión
}
```

**Índices requeridos:**
- Ninguno (consultas por ID directo)

**Reglas de seguridad:**
- Lectura/Escritura: Solo el propio alumno (`request.auth.uid == studentId`)

**Nota:** Los agregados se actualizan mediante transacciones cuando se crean sesiones.

---

### 3. `classes` - Definiciones de Clases

**Ruta:** `classes/{classId}`
**ID:** ID único global generado

```javascript
{
  id: string,                    // ID único global
  name: string,                  // Nombre de la clase
  description: string,           // Descripción opcional
  ownerTeacherId: string,        // ID del docente propietario
  accessCode: string,            // Código de acceso (6 caracteres)
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  isActive: boolean              // Estado de la clase
}
```

**Índices requeridos:**
- `ownerTeacherId` (ascending) - Para listar clases de un docente
- `accessCode` (ascending) - Para búsqueda por código de acceso

**Reglas de seguridad:**
- Escritura: Solo el docente propietario (`resource.data.ownerTeacherId == request.auth.uid`)
- Lectura: Cualquier usuario autenticado

---

### 4. `memberships` - Relación Alumno ↔ Clase

**Ruta:** `memberships/{membershipId}`
**ID:** ID único generado

```javascript
{
  id: string,                    // ID único del membership
  classId: string,              // ID de la clase
  studentId: string,             // ID del alumno
  teacherId: string,             // ID del docente (denormalizado)
  className: string,             // Nombre de la clase (denormalizado)
  joinedAt: Timestamp,          // Fecha de unión
  isActive: boolean              // Estado de la membresía
}
```

**Índices requeridos:**
- `classId` (ascending) + `isActive` (ascending) - Para listar alumnos de una clase
- `studentId` (ascending) + `isActive` (ascending) - Para listar clases de un alumno
- `teacherId` (ascending) + `isActive` (ascending) - Para listar membresías de un docente

**Reglas de seguridad:**
- Escritura: Solo el docente propietario (`request.resource.data.teacherId == request.auth.uid`)
- Lectura: El alumno o el docente propietario (`resource.data.studentId == request.auth.uid || resource.data.teacherId == request.auth.uid`)

**Nota:** Esta colección evita arrays grandes en `classes` y previene hotspots.

---

### 5. `tasks` - Definición Maestra de Tareas

**Ruta:** `tasks/{taskId}`
**ID:** ID único global generado

```javascript
{
  id: string,                    // ID único global
  title: string,                 // Título de la tarea
  description: string,           // Descripción detallada
  createdBy: string,            // ID del docente creador
  durationSuggested: number,     // Minutos sugeridos de estudio
  attachments: [                 // Archivos adjuntos (opcional)
    {
      name: string,
      url: string,
      type: string               // "pdf" | "audio" | "link"
    }
  ],
  createdAt: Timestamp,          // Fecha de creación
  updatedAt: Timestamp,          // Última actualización
  dueDate: Timestamp,            // Fecha límite (opcional)
  isActive: boolean              // Estado de la tarea
}
```

**Índices requeridos:**
- `createdBy` (ascending) + `createdAt` (descending) - Para listar tareas de un docente
- `createdBy` (ascending) + `isActive` (ascending) - Para filtrar tareas activas

**Reglas de seguridad:**
- Escritura: Solo el docente creador (`resource.data.createdBy == request.auth.uid`)
- Lectura: Cualquier usuario autenticado

---

### 6. `assignments` - Progreso Individual Tarea-Alumno

**Ruta:** `assignments/{taskId_studentId}`
**ID:** Clave compuesta `${taskId}_${studentId}` para idempotencia

```javascript
{
  id: string,                    // Clave compuesta: ${taskId}_${studentId}
  taskId: string,                // ID de la tarea
  studentId: string,             // ID del alumno
  teacherId: string,             // ID del docente (denormalizado)
  status: string,                // "pending" | "in_progress" | "completed"
  assignedAt: Timestamp,         // Fecha de asignación
  completedAt: Timestamp,         // Fecha de finalización (opcional)

  // Contadores de progreso
  sessionsCount: number,          // Número de sesiones realizadas
  totalDurationLogged: number,   // Segundos totales registrados
  lastSessionDate: Timestamp     // Fecha de la última sesión
}
```

**Índices requeridos:**
- `taskId` (ascending) + `status` (ascending) - Para listar asignaciones de una tarea
- `studentId` (ascending) + `status` (ascending) - Para listar asignaciones de un alumno
- `teacherId` (ascending) + `status` (ascending) - Para listar asignaciones de un docente
- `studentId` (ascending) + `assignedAt` (descending) - Para ordenar por fecha de asignación

**Reglas de seguridad:**
- Lectura: El alumno o el docente propietario (`resource.data.studentId == request.auth.uid || resource.data.teacherId == request.auth.uid`)
- Escritura: El docente propietario o el alumno (solo actualización de progreso)

**Nota:** Los contadores se actualizan mediante transacciones cuando se crean sesiones.

---

### 7. `sessions` - Registros Atómicos de Estudio

**Ruta:** `sessions/{sessionId}`
**ID:** ID único generado

```javascript
{
  id: string,                    // ID único de la sesión
  studentId: string,             // ID del alumno
  taskId: string,                // ID de la tarea
  teacherId: string,             // ID del docente (denormalizado)
  startTime: Timestamp,          // Hora de inicio
  endTime: Timestamp,            // Hora de finalización
  totalDuration: number,         // Segundos totales de estudio
  pausedDuration: number,        // Segundos en pausa
  dateLogged: Timestamp,         // Fecha de la sesión
  monthBucket: string,          // 2025-10 para queries de métricas
  notes: string,                 // Notas opcionales del alumno
  createdAt: Timestamp           // Fecha de creación del registro
}
```

**Índices requeridos:**
- `studentId` (ascending) + `dateLogged` (descending) - Para historial de sesiones de un alumno
- `taskId` (ascending) + `dateLogged` (descending) - Para sesiones de una tarea
- `teacherId` (ascending) + `dateLogged` (descending) - Para sesiones de alumnos de un docente
- `monthBucket` (ascending) + `studentId` (ascending) - Para métricas mensuales
- Collection group index: `studentId` + `dateLogged` - Para consultas globales

**Reglas de seguridad:**
- Crear: Solo el alumno (`request.resource.data.studentId == request.auth.uid`)
- Lectura: El alumno o el docente propietario (`resource.data.studentId == request.auth.uid || resource.data.teacherId == request.auth.uid`)
- Actualizar/Eliminar: **PROHIBIDO** (inmutabilidad de métricas)

**Nota:** Esta colección es inmutable después de la creación para mantener la integridad de las métricas.

---

## Estrategias de Optimización

### Fan-out para Asignaciones

Cuando se crea una tarea para una clase, se debe hacer un **fan-out** para crear asignaciones:

1. **Crear** documento en `tasks/{taskId}`
2. **Leer** `memberships` por `classId` donde `isActive == true`
3. **Batch Write** para crear documentos en `assignments/{taskId_studentId}` para cada alumno

**Ejemplo:**
```dart
// 1. Crear tarea
final taskRef = await FirebaseFirestore.instance
    .collection('tasks')
    .add(taskData.toMap());

// 2. Obtener miembros activos de la clase
final memberships = await FirebaseFirestore.instance
    .collection('memberships')
    .where('classId', isEqualTo: classId)
    .where('isActive', isEqualTo: true)
    .get();

// 3. Crear asignaciones en batch
final batch = FirebaseFirestore.instance.batch();
for (final membership in memberships.docs) {
  final assignmentRef = FirebaseFirestore.instance
      .collection('assignments')
      .doc('${taskRef.id}_${membership.data()['studentId']}');

  batch.set(assignmentRef, {
    'id': '${taskRef.id}_${membership.data()['studentId']}',
    'taskId': taskRef.id,
    'studentId': membership.data()['studentId'],
    'teacherId': teacherId,
    'status': 'pending',
    'assignedAt': FieldValue.serverTimestamp(),
    'sessionsCount': 0,
    'totalDurationLogged': 0,
  });
}
await batch.commit();
```

### Actualización de Contadores (Transacciones)

Cuando se crea una sesión, se deben actualizar los contadores mediante **transacciones**:

1. **Crear** documento en `sessions/{sessionId}`
2. **Transaction Write** para actualizar:
   - Contadores en `assignments/{taskId_studentId}`
   - Agregados en `students/{studentId}`

**Ejemplo:**
```dart
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // 1. Crear sesión
  final sessionRef = FirebaseFirestore.instance
      .collection('sessions')
      .doc();
  transaction.set(sessionRef, sessionData.toMap());

  // 2. Actualizar assignment
  final assignmentRef = FirebaseFirestore.instance
      .collection('assignments')
      .doc('${taskId}_${studentId}');
  final assignmentDoc = await transaction.get(assignmentRef);

  transaction.update(assignmentRef, {
    'sessionsCount': FieldValue.increment(1),
    'totalDurationLogged': FieldValue.increment(duration),
    'lastSessionDate': FieldValue.serverTimestamp(),
    'status': 'in_progress',
  });

  // 3. Actualizar student
  final studentRef = FirebaseFirestore.instance
      .collection('students')
      .doc(studentId);

  transaction.update(studentRef, {
    'totalSessionsCount': FieldValue.increment(1),
    'totalDurationLogged': FieldValue.increment(duration),
    'lastSessionDate': FieldValue.serverTimestamp(),
  });
});
```

---

## Reglas de Seguridad

### Reglas Completas de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuth() {
      return request.auth != null;
    }

    function isOwner(doc) {
      return isAuth() && doc.ownerTeacherId == request.auth.uid;
    }

    // Perfiles de usuarios
    match /teachers/{teacherId} {
      allow read, write: if isAuth() && request.auth.uid == teacherId;
    }

    match /students/{studentId} {
      allow read, write: if isAuth() && request.auth.uid == studentId;
    }

    // Clases
    match /classes/{classId} {
      allow write: if isAuth() && resource.data.ownerTeacherId == request.auth.uid;
      allow read: if isAuth();
    }

    // Membresías
    match /memberships/{membershipId} {
      allow write: if isAuth() && request.resource.data.teacherId == request.auth.uid;
      allow read: if isAuth() && (
        resource.data.studentId == request.auth.uid ||
        resource.data.teacherId == request.auth.uid
      );
    }

    // Tareas
    match /tasks/{taskId} {
      allow write: if isAuth() && resource.data.createdBy == request.auth.uid;
      allow read: if isAuth();
    }

    // Asignaciones
    match /assignments/{assignmentId} {
      allow read: if isAuth() && (
        resource.data.studentId == request.auth.uid ||
        resource.data.teacherId == request.auth.uid
      );
      allow write: if isAuth() && (
        resource.data.teacherId == request.auth.uid ||
        request.resource.data.studentId == request.auth.uid
      );
    }

    // Sesiones
    match /sessions/{sessionId} {
      allow create: if isAuth() && request.resource.data.studentId == request.auth.uid;
      allow read: if isAuth() && (
        resource.data.studentId == request.auth.uid ||
        resource.data.teacherId == request.auth.uid
      );
      allow update, delete: if false; // Inmutabilidad de métricas
    }
  }
}
```

---

## Índices Compuestos Requeridos

### Índices para Consultas Comunes

1. **memberships**
   - `classId` (ascending) + `isActive` (ascending)
   - `studentId` (ascending) + `isActive` (ascending)
   - `teacherId` (ascending) + `isActive` (ascending)

2. **assignments**
   - `taskId` (ascending) + `status` (ascending)
   - `studentId` (ascending) + `status` (ascending)
   - `teacherId` (ascending) + `status` (ascending)
   - `studentId` (ascending) + `assignedAt` (descending)

3. **sessions**
   - `studentId` (ascending) + `dateLogged` (descending)
   - `taskId` (ascending) + `dateLogged` (descending)
   - `teacherId` (ascending) + `dateLogged` (descending)
   - `monthBucket` (ascending) + `studentId` (ascending)
   - Collection group: `studentId` + `dateLogged`

4. **tasks**
   - `createdBy` (ascending) + `createdAt` (descending)
   - `createdBy` (ascending) + `isActive` (ascending)

5. **classes**
   - `ownerTeacherId` (ascending)
   - `accessCode` (ascending)

---

## Modelos Dart (Estructura Esperada)

### Ejemplo: Task Model

```dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final int durationSuggested;
  final List<TaskAttachment>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final bool isActive;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.durationSuggested,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    required this.isActive,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      durationSuggested: data['durationSuggested'] ?? 0,
      attachments: (data['attachments'] as List?)?.map((e) => TaskAttachment.fromMap(e)).toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'durationSuggested': durationSuggested,
      'attachments': attachments?.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isActive': isActive,
    };
  }
}
```

---

## Referencias

- **Guía completa del proyecto:** [Guia_Proyecto_PlayingTracker.md](./Guia_Proyecto_PlayingTracker.md)
- **Documentación de Firestore:** https://firebase.google.com/docs/firestore
- **Reglas de seguridad:** https://firebase.google.com/docs/firestore/security/get-started
- **Índices compuestos:** https://firebase.google.com/docs/firestore/query-data/index-overview
- **Transacciones:** https://firebase.google.com/docs/firestore/manage-data/transactions

