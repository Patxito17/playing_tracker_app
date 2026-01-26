import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/value_objects/task_filters.dart';
import '../cubit/assignment_cubit.dart';

/// Bottom sheet reutilizable para aplicar filtros de asignaciones compatibles
/// con Firestore mediante [TaskFilters].
///
/// Permite:
/// - Filtrar por estado de asignación (pending, inProgress, completed).
/// - Filtrar por rango de fechas de asignación.
/// - Aplicar o limpiar filtros invocando al [AssignmentCubit].
class AssignmentFiltersBottomSheet extends StatefulWidget {
  /// Filtros iniciales a mostrar en el bottom sheet
  final TaskFilters initialFilters;

  const AssignmentFiltersBottomSheet({super.key, required this.initialFilters});

  @override
  State<AssignmentFiltersBottomSheet> createState() =>
      _AssignmentFiltersBottomSheetState();
}

class _AssignmentFiltersBottomSheetState
    extends State<AssignmentFiltersBottomSheet> {
  TaskStatus? _selectedStatus;
  DateTime? _assignedFrom;
  DateTime? _assignedTo;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilters.status;
    _assignedFrom = widget.initialFilters.assignedFrom;
    _assignedTo = widget.initialFilters.assignedTo;
  }

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
      isActive: null,
      createdFrom: null,
      createdTo: null,
      dueFrom: null,
      dueTo: null,
      status: _selectedStatus,
      assignedFrom: _assignedFrom,
      assignedTo: _assignedTo,
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
    context.read<AssignmentCubit>().applyFilters(filters);
    Navigator.of(context).pop();
  }

  void _handleClear() {
    context.read<AssignmentCubit>().applyFilters(_emptyFilters());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.filters,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: AppSpacing.m),
            // Filtro por estado de asignación
            Text(
              context.l10n.filterByAssignmentStatus,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            SegmentedButton<TaskStatus?>(
              segments: [
                ButtonSegment<TaskStatus?>(
                  value: TaskStatus.pending,
                  label: Text(context.l10n.pending),
                ),
                ButtonSegment<TaskStatus?>(
                  value: TaskStatus.inProgress,
                  label: Text(context.l10n.inProgress),
                ),
                ButtonSegment<TaskStatus?>(
                  value: TaskStatus.completed,
                  label: Text(context.l10n.completed),
                ),
              ],
              selected: _selectedStatus != null ? {_selectedStatus} : {},
              multiSelectionEnabled: false,
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedStatus = selection.isEmpty ? null : selection.single;
                });
              },
            ),
            const SizedBox(height: AppSpacing.m),
            // Rango de fechas de asignación
            Text(context.l10n.filterByDate, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(
                      onSelected: (date) => _assignedFrom = date,
                      initialDate: _assignedFrom,
                    ),
                    child: Text(
                      _assignedFrom != null
                          ? '${_assignedFrom!.day.toString().padLeft(2, '0')}/${_assignedFrom!.month.toString().padLeft(2, '0')}/${_assignedFrom!.year}'
                          : context.l10n.fromLabel,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(
                      onSelected: (date) => _assignedTo = date,
                      initialDate: _assignedTo,
                    ),
                    child: Text(
                      _assignedTo != null
                          ? '${_assignedTo!.day.toString().padLeft(2, '0')}/${_assignedTo!.month.toString().padLeft(2, '0')}/${_assignedTo!.year}'
                          : context.l10n.toLabel,
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
                    child: Text(context.l10n.clearFilters),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleApply,
                    child: Text(context.l10n.applyFilters),
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
