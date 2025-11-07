import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla de lista de tareas
///
/// Muestra todas las tareas con filtros básicos (UI solamente).
/// Sprint 0 - Fase 8: UI completa con Material Design 3
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedStatus = TaskStrings.allStatuses;
  String _selectedDate = TaskStrings.allDates;
  String _selectedClass = TaskStrings.allClasses;

  // Datos mock de tareas
  final List<Map<String, dynamic>> _mockTasks = [
    {
      'id': 'task1',
      'title': 'Escala de Do Mayor',
      'description': 'Practicar la escala de Do Mayor en todas las octavas',
      'status': 'pending',
      'estimatedTime': 30,
      'class': 'Piano Nivel 1',
      'createdDate': '2025-11-01',
    },
    {
      'id': 'task2',
      'title': 'Arpegios de Do Menor',
      'description': 'Estudiar arpegios de Do Menor con ambas manos',
      'status': 'in_progress',
      'estimatedTime': 45,
      'class': 'Piano Nivel 1',
      'createdDate': '2025-11-02',
    },
    {
      'id': 'task3',
      'title': 'Ejercicio de velocidad',
      'description': 'Ejercicios de velocidad con metrónomo',
      'status': 'completed',
      'estimatedTime': 20,
      'class': 'Guitarra Avanzada',
      'createdDate': '2025-11-03',
    },
  ];

  List<Map<String, dynamic>> get _filteredTasks {
    return _mockTasks.where((task) {
      if (_selectedStatus != TaskStrings.allStatuses &&
          task['status'] != _selectedStatus) {
        return false;
      }
      if (_selectedDate != TaskStrings.allDates &&
          task['createdDate'] != _selectedDate) {
        return false;
      }
      if (_selectedClass != TaskStrings.allClasses &&
          task['class'] != _selectedClass) {
        return false;
      }
      return true;
    }).toList();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return TaskStrings.pending;
      case 'in_progress':
        return TaskStrings.inProgress;
      case 'completed':
        return TaskStrings.completed;
      default:
        return TaskStrings.pending;
    }
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'pending':
        return colorScheme.outline;
      case 'in_progress':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TaskStrings.myTasksTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.createTask),
            tooltip: TaskStrings.createTask,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Mock: simular refresh
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filtros
              CustomCard(
                title: TaskStrings.filters,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TaskStrings.filterByStatus,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children:
                          [
                            TaskStrings.allStatuses,
                            TaskStrings.pending,
                            TaskStrings.inProgress,
                            TaskStrings.completed,
                          ].map((status) {
                            final isSelected = _selectedStatus == status;
                            return FilterChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStatus = selected
                                      ? status
                                      : TaskStrings.allStatuses;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      TaskStrings.filterByDate,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children:
                          [
                            TaskStrings.allDates,
                            '2025-11-01',
                            '2025-11-02',
                            '2025-11-03',
                          ].map((date) {
                            final isSelected = _selectedDate == date;
                            return FilterChip(
                              label: Text(date),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDate = selected
                                      ? date
                                      : TaskStrings.allDates;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      TaskStrings.filterByClass,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children:
                          [
                            TaskStrings.allClasses,
                            'Piano Nivel 1',
                            'Guitarra Avanzada',
                          ].map((classItem) {
                            final isSelected = _selectedClass == classItem;
                            return FilterChip(
                              label: Text(classItem),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedClass = selected
                                      ? classItem
                                      : TaskStrings.allClasses;
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              // Lista de tareas o estado vacío
              if (_filteredTasks.isEmpty)
                _EmptyState(
                  icon: Icons.assignment_outlined,
                  title: TaskStrings.noTasksFound,
                  subtitle: TaskStrings.adjustFilters,
                  actionLabel: TaskStrings.createTask,
                  onAction: () => context.push(AppRoutes.createTask),
                )
              else
                ..._filteredTasks.map((taskData) {
                  final status = taskData['status'] as String;
                  final statusText = _getStatusText(status);
                  final statusColor = _getStatusColor(status);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: CustomCard(
                      title: taskData['title'] as String,
                      subtitle: taskData['description'] as String,
                      trailingAction: Chip(
                        label: Text(statusText),
                        backgroundColor: statusColor.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                        avatar: Icon(
                          status == 'pending'
                              ? Icons.pending_outlined
                              : status == 'in_progress'
                              ? Icons.play_circle_outline
                              : Icons.check_circle_outline,
                          size: 16,
                          color: statusColor,
                        ),
                      ),
                      onTap: () => context.push(
                        AppRoutes.taskDetail.replaceAll(
                          ':taskId',
                          taskData['id'] as String,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.s),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${taskData['estimatedTime']} ${TaskStrings.minutes}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Icon(
                                Icons.class_,
                                size: 16,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                taskData['class'] as String,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createTask),
        icon: const Icon(Icons.add),
        label: Text(TaskStrings.createTask),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: context.colorScheme.outline),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
