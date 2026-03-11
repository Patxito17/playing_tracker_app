---
trigger: model_decision
description: Cuando se te pide implementar funcionalidades relacionadas con algún sprint del proyecto, SIEMPRE debes seguir este flujo de trabajo completo.
---

FLUJO OBLIGATORIO

### 1. **Desarrollo del Código** 📝
- Implementa la funcionalidad solicitada
- Asegúrate de seguir las convenciones del proyecto
- Usa las arquitecturas y patrones establecidos (Clean Architecture, BLoC, etc.)
- Revisa que no haya errores de compilación

### 2. **Análisis de Código** 🔍
- Ejecuta `flutter analyze` en los archivos creados/modificados
- Corrige todos los errores y warnings
- Asegúrate de que el código pasa el análisis estático
- **NO continúes al siguiente paso hasta que `flutter analyze` muestre "No issues found"**

### 3. **Escritura de Tests** ✅
- **SIEMPRE** crea tests unitarios para el código nuevo
- Para widgets: usa `flutter_test` y widget tests
- Para Cubits/Blocs: usa `bloc_test`
- Para servicios: usa mocks con `mocktail` o `fake_cloud_firestore`
- Para modelos: valida serialización, constructores, métodos
- **Cobertura mínima esperada**: 80% de las funcionalidades públicas

#### Tipos de tests según componente:
- **Screens/Widgets**: Widget tests con `pumpWidget`, simulación de interacciones
- **Cubits**: `blocTest` con estados esperados, manejo de errores
- **Repositorios**: Tests con mocks del servicio
- **Servicios**: Tests con `FakeFirebaseFirestore` o mocks
- **Modelos**: Serialización, `copyWith`, `==`, `hashCode`
- **Utilidades**: Tests unitarios de funciones puras

### 4. **Ejecución de Tests** 🧪
- Ejecuta `flutter test` en los archivos de test creados
- Verifica que TODOS los tests pasen
- Si algún test falla, corrige el código o el test
- **NO continúes hasta que todos los tests pasen**

### 5. **Actualización de Documentación** 📚
- Actualiza el documento del sprint correspondiente (`docs/sprints/SPRINT_X_IMPLEMENTACION.md`)
- Marca las tareas como completadas `[x]`
- Agrega detalles de implementación (número de tests, características)
- **Formato esperado**:
  ```markdown
  - [x] **Nombre de la Tarea**:
    - ✅ Característica 1 implementada
    - ✅ Característica 2 implementada
    - ✅ X tests pasando validando Y
  ```

## Checklist para Cada Implementación

Antes de considerar una tarea completada, verifica:

- [ ] Código implementado sin errores de compilación
- [ ] `flutter analyze` pasa sin issues
- [ ] Tests unitarios/widget creados
- [ ] Tests ejecutados y pasando (100%)
- [ ] Documento del sprint actualizado con [x]
- [ ] Resumen de implementación proporcionado al usuario

## Excepciones

Las siguientes situaciones NO requieren tests:
- Archivos de configuración (pubspec.yaml, análisis_options, etc.)
- Constantes simples (colores, strings)
- Archivos generados automáticamente (*.g.dart, *.freezed.dart)
- Documentación (README, CHANGELOG, etc.)

## Ejemplos de Cumplimiento

### ✅ CORRECTO
```
1. Implementar SessionCubit
2. flutter analyze → No issues
3. Crear session_cubit_test.dart con bloc_test
4. flutter test → 17/17 passing
5. Actualizar SPRINT_5_IMPLEMENTACION.md
6. Proporcionar resumen al usuario
```

### ❌ INCORRECTO
```
1. Implementar SessionCubit
2. flutter analyze → No issues
3. [OMITIDO] No crear tests
4. Actualizar SPRINT_5_IMPLEMENTACION.md
5. Proporcionar resumen al usuario
```

## Notas Importantes

- Los tests NO son opcionales. Son parte integral de la implementación.
- Si el código es tan complejo que no sabes cómo testearlo, probablemente necesite refactoring.
- Widget tests son especialmente importantes para pantallas complejas.
- Usa `blocTest` para todos los Cubits/Blocs - facilita enormemente el testing.

## En Resumen

**Implementar sin tests = Trabajo incompleto**

El flujo correcto es:
```
Código → Análisis → Tests → Ejecución → Documentación → Resumen
```

Nunca omitas los pasos intermedios.