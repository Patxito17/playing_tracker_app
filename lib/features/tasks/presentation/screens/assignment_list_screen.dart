import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/value_objects/task_filters.dart';
import '../cubit/assignment_cubit.dart';
import '../cubit/assignment_state.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_filters_bottom_sheet.dart';

/// Pantalla de lista de asignaciones del alumno.
///
/// Diseño gamificado con fondo degradado sutil y cards de estado coloreadas.
/// Cada asignación visual y motivadoramente diferenciada por su estado.
class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  TaskFilters _activeFilters = (
    isActive: null,
    createdFrom: null,
    createdTo: null,
    dueFrom: null,
    dueTo: null,
    status: null,
    assignedFrom: null,
    assignedTo: null,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<AssignmentCubit>().watchAssignments(
          studentId: authState.userId,
          filters: _activeFilters,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.myAssignmentsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showModalBottomSheet<TaskFilters>(
                context: context,
                builder: (context) => AssignmentFiltersBottomSheet(
                  initialFilters: _activeFilters,
                ),
              );
              if (result != null && context.mounted) {
                setState(() => _activeFilters = result);
                context.read<AssignmentCubit>().applyFilters(result);
              }
            },
            tooltip: context.l10n.filters,
          ),
        ],
      ),
      // Degradado sutil de fondo que refuerza el ambiente motivador
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colorScheme.primary.withValues(alpha: 0.06),
              context.colorScheme.surface,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: BlocBuilder<AssignmentCubit, AssignmentState>(
          builder: (context, state) {
            if (state is AssignmentLoading || state is AssignmentInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AssignmentError) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Center(
                  child: SelectableText.rich(
                    TextSpan(
                      text: state.message,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is AssignmentEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<AssignmentCubit>().refreshAssignments(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    _AssignmentEmptyState(
                      icon: Icons.task_alt_outlined,
                      title: state.message.isNotEmpty
                          ? state.message
                          : context.l10n.noAssignmentsReceived,
                      subtitle: context.l10n.adjustFilters,
                    ),
                  ],
                ),
              );
            }

            if (state is! AssignmentSuccess) return const SizedBox.shrink();

            final assignments = state.assignments;

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AssignmentCubit>().refreshAssignments(),
              child: assignments.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.l),
                      children: [
                        _AssignmentEmptyState(
                          icon: Icons.task_alt_outlined,
                          title: context.l10n.noAssignmentsReceived,
                          subtitle: context.l10n.adjustFilters,
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.m),
                      itemCount: assignments.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.s),
                      itemBuilder: (context, index) {
                        return AssignmentCard(
                          assignment: assignments[index],
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Estado vacío motivador para la lista de asignaciones del alumno.
class _AssignmentEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AssignmentEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color:
                  context.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
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
    );
  }
}
