import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/value_objects/task_filters.dart';
import '../cubit/assignment_cubit.dart';
import '../cubit/assignment_state.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_filters_bottom_sheet.dart';

/// Pantalla de lista de asignaciones conectada a [AssignmentCubit].
///
/// Muestra las asignaciones reales del alumno y permite filtrarlas por estado
/// y rango de fechas de asignación mediante un bottom sheet.
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
    // Inicializamos la suscripción al stream de asignaciones en initState para
    // garantizar que se establezca correctamente antes del primer build.
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
        title: TaskStrings.myAssignmentsTitle,
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
              if (result != null) {
                setState(() {
                  _activeFilters = result;
                });
                if (!mounted) return;
                context.read<AssignmentCubit>().applyFilters(result);
              }
            },
            tooltip: TaskStrings.filters,
          ),
        ],
      ),
      body: BlocBuilder<AssignmentCubit, AssignmentState>(
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
              onRefresh: () => context.read<AssignmentCubit>().refreshAssignments(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  _EmptyState(
                    icon: Icons.assignment_outlined,
                    title: state.message,
                    subtitle: TaskStrings.adjustFilters,
                  ),
                ],
              ),
            );
          }

          if (state is! AssignmentSuccess) {
            return const SizedBox.shrink();
          }

          final assignments = state.assignments;

          return RefreshIndicator(
            onRefresh: () => context.read<AssignmentCubit>().refreshAssignments(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (assignments.isEmpty)
                    _EmptyState(
                      icon: Icons.assignment_outlined,
                      title: TaskStrings.noAssignmentsReceived,
                      subtitle: TaskStrings.adjustFilters,
                    )
                  else
                    ...assignments.map((assignment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: AssignmentCard(
                          assignment: assignment,
                          onTap: () => context.push(
                            AppRoutes.assignmentDetail.replaceAll(
                              ':assignmentId',
                              assignment.id,
                            ),
                            extra: context.read<AssignmentCubit>(),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
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
        ],
      ),
    );
  }
}

