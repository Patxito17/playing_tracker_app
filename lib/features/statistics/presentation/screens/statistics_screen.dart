import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../classes/presentation/cubit/class_cubit.dart';
import '../../../classes/presentation/cubit/class_state.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../cubit/student_stats_cubit.dart';
import 'student_statistics_screen.dart';

/// Pantalla de estadísticas: redirige a la vista de alumno o muestra la
/// lista de clases del docente para que elija una.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is AuthAuthenticated) {
      if (authState.role == UserRole.student) {
        return BlocProvider(
          create: (context) =>
              StudentStatsCubit(StatisticsRepositoryImpl())
                ..loadStats(studentId: authState.userId),
          child: StudentStatisticsScreen(studentId: authState.userId),
        );
      } else {
        return BlocProvider(
          create: (context) =>
              ClassCubit(context.read<ClassRepository>())
                ..watchClasses(teacherId: authState.userId),
          child: Scaffold(
            appBar: CustomAppBar(title: context.l10n.statisticsByClass),
            body: BlocBuilder<ClassCubit, ClassState>(
              builder: (context, state) {
                if (state is ClassLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ClassError) {
                  return Center(
                    child: Text(
                      state.message ?? context.l10n.classGenericError,
                    ),
                  );
                }

                if (state is ClassSuccess) {
                  final classes = state.classes;

                  if (classes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bar_chart_outlined,
                                size: 48,
                                color: context.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.l),
                            Text(
                              context.l10n.noClassesForStats,
                              textAlign: TextAlign.center,
                              style: context.bodyMediumOnSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.xxl,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classModel = classes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.large),
                            side: BorderSide(
                              color: context.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          color: context.colorScheme.surfaceContainerLow,
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => context.push(
                              '${AppRoutes.teacherClassDetail}/${classModel.id}/statistics',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: context
                                          .colorScheme.primaryContainer
                                          .withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(
                                        AppBorderRadius.medium,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.bar_chart_rounded,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          classModel.name,
                                          style: context.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (classModel.description != null &&
                                            classModel
                                                .description!.isNotEmpty) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            classModel.description!,
                                            style:
                                                context.bodySmallOnSurfaceVariant,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.l10n.viewStatsAction,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                          color: context.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: context.colorScheme.primary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
