import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/value_objects/task_filters.dart';
import '../cubit/task_cubit.dart';

/// Bottom sheet reutilizable para aplicar filtros de tareas compatibles
/// con Firestore mediante [TaskFilters].
///
/// Permite:
/// - Filtrar por tareas activas/archivadas.
/// - Elegir un único rango de fechas (creación *o* vencimiento).
/// - Aplicar o limpiar filtros invocando al [TaskCubit].
class TaskFiltersBottomSheet extends StatefulWidget {
  const TaskFiltersBottomSheet({super.key});

  @override
  State<TaskFiltersBottomSheet> createState() => _TaskFiltersBottomSheetState();
}

class _TaskFiltersBottomSheetState extends State<TaskFiltersBottomSheet> {
  bool _showOnlyActive = true;
  bool _useCreatedRange = true;
  DateTime? _createdFrom;
  DateTime? _createdTo;
  DateTime? _dueFrom;
  DateTime? _dueTo;

  /// Muestra un selector de fecha simple y devuelve el valor escogido.
  Future<void> _pickDate({
    required ValueChanged<DateTime?> onSelected,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      onSelected(picked);
    });
  }

  /// Construye el record [TaskFilters] a partir del estado local.
  TaskFilters _buildFilters() {
    return (
      isActive: _showOnlyActive ? true : null,
      createdFrom: _useCreatedRange ? _createdFrom : null,
      createdTo: _useCreatedRange ? _createdTo : null,
      dueFrom: _useCreatedRange ? null : _dueFrom,
      dueTo: _useCreatedRange ? null : _dueTo,
      status: null,
      assignedFrom: null,
      assignedTo: null,
    );
  }

  /// Devuelve un filtro vacío (sin restricciones).
  TaskFilters _emptyFilters() => (
    isActive: null,
    createdFrom: null,
    createdTo: null,
    dueFrom: null,
    dueTo: null,
    status: null,
    assignedFrom: null,
    assignedTo: null,
  );

  void _handleApply() {
    final filters = _buildFilters();
    context.read<TaskCubit>().applyFilters(filters);
    Navigator.of(context).pop();
  }

  void _handleClear() {
    context.read<TaskCubit>().applyFilters(_emptyFilters());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TaskStrings.filters,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: AppSpacing.m),
            // Filtro por estado activo/archivado.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TaskStrings.filterByActiveStatus,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _showOnlyActive
                            ? TaskStrings.showActiveOnly
                            : TaskStrings.showArchivedOnly,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _showOnlyActive,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyActive = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            // Rango de fechas: creación o vencimiento (mutuamente excluyentes).
            Text(TaskStrings.filterByDate, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text(TaskStrings.selectCreatedDate),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(TaskStrings.selectDueDate),
                ),
              ],
              selected: {_useCreatedRange},
              onSelectionChanged: (selection) {
                final value = selection.single;
                setState(() {
                  _useCreatedRange = value;
                  if (_useCreatedRange) {
                    _dueFrom = null;
                    _dueTo = null;
                  } else {
                    _createdFrom = null;
                    _createdTo = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.s),
            if (_useCreatedRange)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(
                        onSelected: (date) => _createdFrom = date,
                        initialDate: _createdFrom,
                      ),
                      child: Text(
                        _createdFrom != null
                            ? TaskStrings.formatShortDate(_createdFrom!)
                            : TaskStrings.fromLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(
                        onSelected: (date) => _createdTo = date,
                        initialDate: _createdTo,
                      ),
                      child: Text(
                        _createdTo != null
                            ? TaskStrings.formatShortDate(_createdTo!)
                            : TaskStrings.toLabel,
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(
                        onSelected: (date) => _dueFrom = date,
                        initialDate: _dueFrom,
                      ),
                      child: Text(
                        _dueFrom != null
                            ? TaskStrings.formatShortDate(_dueFrom!)
                            : TaskStrings.fromLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(
                        onSelected: (date) => _dueTo = date,
                        initialDate: _dueTo,
                      ),
                      child: Text(
                        _dueTo != null
                            ? TaskStrings.formatShortDate(_dueTo!)
                            : TaskStrings.toLabel,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleClear,
                    child: const Text(TaskStrings.clearFilters),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleApply,
                    child: const Text(TaskStrings.applyFilters),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
