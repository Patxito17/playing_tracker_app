import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/models/session_model.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

/// Pantalla de historial de sesiones de estudio con datos reales.
///
/// Sprint 5 - Fase 5: Lista de sesiones desde Firestore con filtros por fecha.
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({required this.studentId, this.taskId, super.key});

  final String studentId;
  final String? taskId;

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().watchSessions(
      studentId: widget.studentId,
      taskId: widget.taskId,
    );
  }

  /// Filtra las sesiones según el filtro seleccionado
  List<SessionModel> _filterSessions(List<SessionModel> sessions) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'today':
        return sessions.where((session) {
          final sessionDate = session.endTime.toDate();
          return sessionDate.year == now.year &&
              sessionDate.month == now.month &&
              sessionDate.day == now.day;
        }).toList();

      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return sessions.where((session) {
          final sessionDate = session.endTime.toDate();
          return sessionDate.isAfter(startOfWeek);
        }).toList();

      case 'month':
        return sessions.where((session) {
          final sessionDate = session.endTime.toDate();
          return sessionDate.year == now.year && sessionDate.month == now.month;
        }).toList();

      case 'all':
      default:
        return sessions;
    }
  }

  /// Formatea la duración en formato HH:MM:SS o MM:SS
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Formatea la duración en texto legible (ej: "30 min")
  String _formatDurationReadable(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours h';
    }
    return '$hours h $remainingMinutes min';
  }

  /// Formatea la fecha y hora de la sesión
  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(date)} • ${timeFormat.format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taskId != null
            ? 'Historial de la tarea'
            : SessionStrings.sessionHistoryTitle,
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
            return _ErrorState(message: state.message);
          }

          if (state is HistoryEmpty) {
            return _EmptyState(
              title: SessionStrings.noSessions,
              subtitle: SessionStrings.startFirstSession,
              icon: Icons.history_outlined,
            );
          }

          if (state is HistorySuccess) {
            final filteredSessions = _filterSessions(state.sessions);

            if (filteredSessions.isEmpty) {
              return _EmptyState(
                title: 'No hay sesiones para este filtro',
                subtitle: 'Intenta cambiar el filtro de fecha',
                icon: Icons.filter_list_off,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HistoryCubit>().watchSessions(
                  studentId: widget.studentId,
                  taskId: widget.taskId,
                );
              },
              child: ListView(
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
                          selected: _selectedFilter == 'today',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? 'today' : 'all';
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.thisWeek,
                          selected: _selectedFilter == 'week',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? 'week' : 'all';
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.thisMonth,
                          selected: _selectedFilter == 'month',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? 'month' : 'all';
                            });
                          },
                        ),
                        _FilterChip(
                          label: SessionStrings.all,
                          selected: _selectedFilter == 'all',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'all';
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
                      child: _SessionCard(
                        session: session,
                        formatDuration: _formatDuration,
                        formatDurationReadable: _formatDurationReadable,
                        formatDateTime: _formatDateTime,
                      ),
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Widget de tarjeta de sesión individual
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.formatDuration,
    required this.formatDurationReadable,
    required this.formatDateTime,
  });

  final SessionModel session;
  final String Function(int) formatDuration;
  final String Function(int) formatDurationReadable;
  final String Function(Timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Sesión de práctica',
      subtitle: formatDateTime(session.endTime),
      trailingAction: Chip(
        label: Text(
          formatDurationReadable(session.totalDuration),
          style: context.textPrimary?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: context.textTheme.bodySmall?.fontSize,
          ),
        ),
        backgroundColor: context.colorScheme.primaryContainer.withValues(
          alpha: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s),
          _InfoRow(
            icon: Icons.access_time,
            label: SessionStrings.sessionDuration,
            value: formatDuration(session.totalDuration),
          ),
          const SizedBox(height: AppSpacing.s),
          _InfoRow(
            icon: Icons.calendar_today,
            label: SessionStrings.sessionDate,
            value: formatDateTime(session.endTime),
          ),
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            _InfoRow(icon: Icons.notes, label: 'Notas', value: session.notes!),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar un chip de filtro
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

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
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.bodySmallOnSurfaceVariant,
              children: [
                TextSpan(text: '$label: '),
                TextSpan(text: value, style: context.bodySmallBold),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar estado vacío
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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

/// Widget para mostrar estado de error
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Error al cargar el historial',
              style: context.titleLargeBold?.copyWith(
                color: context.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              style: context.bodyMediumOnSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
