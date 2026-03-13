import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/membership_model.dart';
import '../cubit/student_classes_cubit.dart';
import '../cubit/student_classes_state.dart';
import '../widgets/class_chips.dart';
import '../widgets/class_empty_state.dart';
import '../widgets/class_error_state.dart';

/// Pantalla de lista de clases a las que pertenece el estudiante
///
/// Muestra las clases reales a las que pertenece el estudiante.
class StudentClassesListScreen extends StatefulWidget {
  const StudentClassesListScreen({super.key});

  @override
  State<StudentClassesListScreen> createState() =>
      _StudentClassesListScreenState();
}

class _StudentClassesListScreenState extends State<StudentClassesListScreen> {
  void _openClassDetail(BuildContext context, MembershipModel membership) {
    context.push(
      '${AppRoutes.studentClassDetail}/${membership.classId}',
      extra: membership,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<StudentClassesCubit>().watchStudentClasses(
          studentId: authState.userId,
        );
      }
    });
  }

  Future<void> _handleRefresh() =>
      context.read<StudentClassesCubit>().refresh();

  void _openJoinClass(BuildContext context) =>
      context.push(AppRoutes.joinClass);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.myClassesTitle,
        showLogo: true,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.group_add_rounded, color: colorScheme.primary),
              onPressed: () => _openJoinClass(context),
              tooltip: context.l10n.joinClassAction,
            ),
          ),
        ],
      ),
      body: BlocBuilder<StudentClassesCubit, StudentClassesState>(
        builder: (context, state) {
          return switch (state) {
            StudentClassesLoading() => _LoadingState(onRefresh: _handleRefresh),
            StudentClassesEmpty(:final message) => RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  ClassEmptyState(
                    icon: Icons.class_outlined,
                    title: message ?? context.l10n.noClassesJoined,
                    subtitle: context.l10n.joinClassWithCode,
                    actionLabel: context.l10n.joinClassAction,
                    onAction: () => _openJoinClass(context),
                  ),
                ],
              ),
            ),
            StudentClassesError(:final message) => RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ClassErrorState(
                message: message ?? context.l10n.classGenericError,
                onRetry: _handleRefresh,
              ),
            ),
            StudentClassesSuccess(:final memberships) => _ClassesList(
              memberships: memberships,
              onRefresh: _handleRefresh,
              onClassSelected: (membership) =>
                  _openClassDetail(context, membership),
            ),
            _ => _LoadingState(onRefresh: _handleRefresh),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openJoinClass(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.joinClassAction),
      ),
    );
  }
}

class _ClassesList extends StatelessWidget {
  const _ClassesList({
    required this.memberships,
    required this.onRefresh,
    required this.onClassSelected,
  });

  final List<MembershipModel> memberships;
  final Future<void> Function() onRefresh;
  final void Function(MembershipModel membership) onClassSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.manageMyClasses,
                      style: context.headlineMediumBold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.xlarge,
                      ),
                    ),
                    child: Text(
                      '${memberships.length}',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.xxl,
            ),
            sliver: SliverList.builder(
              itemCount: memberships.length,
              itemBuilder: (context, index) {
                final membership = memberships[index];
                final joinedAt = dateFormat.format(
                  membership.joinedAt.toDate(),
                );
                final teacherName = membership.teacherName?.trim();
                final teacherSubtitle =
                    '${context.l10n.teacherLabel}'
                    '${teacherName?.isNotEmpty == true ? teacherName : membership.teacherId}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.large,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onClassSelected(membership),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.large,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.medium,
                                ),
                              ),
                              child: Icon(
                                Icons.library_music_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    membership.className,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    teacherSubtitle,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  ClassInfoChip(
                                    icon: Icons.calendar_month_rounded,
                                    label:
                                        '${context.l10n.joinedAtLabel} $joinedAt',
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: AppSpacing.xxl),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
