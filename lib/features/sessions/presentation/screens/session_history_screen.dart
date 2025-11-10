import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla de historial de sesiones de estudio
///
/// Muestra una lista de todas las sesiones de estudio completadas con filtros
/// por fecha (UI solamente, sin funcionalidad real).
///
/// Sprint 0 - Fase 9: UI completa con Material Design 3
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String _selectedFilter = SessionStrings.all;

  // Datos mock de sesiones
  final List<Map<String, dynamic>> _mockSessions = [
    {
      'id': 'session1',
      'taskId': 'task1',
      'taskName': 'Escala de Do Mayor',
      'duration': 1800, // segundos (30 minutos)
      'date': '2025-11-07',
      'time': '14:30',
      'status': 'completed',
    },
    {
      'id': 'session2',
      'taskId': 'task2',
      'taskName': 'Arpegios de Do Menor',
      'duration': 2700, // segundos (45 minutos)
      'date': '2025-11-06',
      'time': '16:00',
      'status': 'completed',
    },
    {
      'id': 'session3',
      'taskId': 'task1',
      'taskName': 'Escala de Do Mayor',
      'duration': 1200, // segundos (20 minutos)
      'date': '2025-11-05',
      'time': '10:15',
      'status': 'completed',
    },
    {
      'id': 'session4',
      'taskId': 'task3',
      'taskName': 'Ejercicio de velocidad',
      'duration': 900, // segundos (15 minutos)
      'date': '2025-11-04',
      'time': '18:45',
      'status': 'completed',
    },
  ];

  List<Map<String, dynamic>> get _filteredSessions {
    // Placeholder: filtrado por fecha (sin funcionalidad real)
    return _mockSessions;
  }

  /// Formatea los segundos en formato HH:MM:SS o MM:SS si es menos de una hora
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  /// Formatea la duración en formato legible (ej: "30 min")
  String _formatDurationReadable(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes ${TaskStrings.minutes}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ${TaskStrings.hours}';
      } else {
        return '$hours ${TaskStrings.hours} $remainingMinutes ${TaskStrings.minutes}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _filteredSessions;

    return Scaffold(
      appBar: const CustomAppBar(title: SessionStrings.sessionHistoryTitle),
      body: RefreshIndicator(
        onRefresh: () async {
          // Placeholder: aquí se recargarían las sesiones desde la base de datos
          await Future.delayed(const Duration(seconds: 1));
        },
        child: filteredSessions.isEmpty
            ? _EmptyState(
                title: SessionStrings.noSessions,
                subtitle: SessionStrings.startFirstSession,
                icon: Icons.history_outlined,
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.m),
                children: [
                  // Filtros por fecha
                  CustomCard(
                    title: SessionStrings.filterByDate,
                    child: Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: [
                        _FilterChip(
                          label: SessionStrings.today,
                          selected: _selectedFilter == SessionStrings.today,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected
                                  ? SessionStrings.today
                                  : SessionStrings.all;
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.thisWeek,
                          selected: _selectedFilter == SessionStrings.thisWeek,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected
                                  ? SessionStrings.thisWeek
                                  : SessionStrings.all;
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.thisMonth,
                          selected: _selectedFilter == SessionStrings.thisMonth,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected
                                  ? SessionStrings.thisMonth
                                  : SessionStrings.all;
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.all,
                          selected: _selectedFilter == SessionStrings.all,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = SessionStrings.all;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Lista de sesiones
                  ...filteredSessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: CustomCard(
                        title: session['taskName'] as String,
                        subtitle:
                            '${session['date'] as String} • ${session['time'] as String}',
                        trailingAction: Chip(
                          label: Text(
                            _formatDurationReadable(session['duration'] as int),
                            style: context.textPrimary?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: context.textTheme.bodySmall?.fontSize,
                            ),
                          ),
                          backgroundColor: context.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.s),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: SessionStrings.sessionDuration,
                              value: _formatDuration(
                                session['duration'] as int,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: SessionStrings.sessionDate,
                              value:
                                  '${session['date'] as String} ${session['time'] as String}',
                            ),
                            const SizedBox(height: AppSpacing.m),
                            // Botón para ver detalles (opcional)
                            OutlinedButton.icon(
                              onPressed: () {
                                // Placeholder: navegar a detalle de sesión o tarea
                                final taskId = session['taskId'] as String;
                                context.push(
                                  AppRoutes.taskDetail.replaceAll(
                                    ':taskId',
                                    taskId,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info_outline),
                              label: Text(SessionStrings.viewDetails),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

/// Widget para mostrar un chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: context.colorScheme.primaryContainer,
      checkmarkColor: context.colorScheme.onPrimaryContainer,
      labelStyle: selected
          ? context.bodySmallBold?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
            )
          : context.bodySmallOnSurface,
    );
  }
}

/// Widget para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Text('$label: ', style: context.bodySmallOnSurfaceVariant),
        Text(value, style: context.bodySmallBold),
      ],
    );
  }
}

/// Widget para mostrar estado vacío
class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              title,
              style: context.titleLargeBold?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              subtitle,
              style: context.bodyMediumOnSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
