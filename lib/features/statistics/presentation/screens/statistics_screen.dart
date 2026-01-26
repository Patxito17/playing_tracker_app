import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../classes/presentation/cubit/class_cubit.dart';
import '../../../classes/presentation/cubit/class_state.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../cubit/student_stats_cubit.dart';
import 'student_statistics_screen.dart';

/// Pantalla de estadísticas (Integración de Gráficos - Sprint 6 Fase 2)
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
        // Para docente, mostramos la lista de sus clases para que elija una.
        return BlocProvider(
          create: (context) =>
              ClassCubit(context.read<ClassRepository>())
                ..watchClasses(teacherId: authState.userId),
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Estadísticas por Clase'),
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
                        child: Text(
                          'No tienes clases para ver estadísticas todavía.',
                          textAlign: TextAlign.center,
                          style: context.bodyMediumOnSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classModel = classes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: CustomCard(
                          title: classModel.name,
                          subtitle: classModel.description ?? 'Sin descripción',
                          onTap: () {
                            // Navegar a las estadísticas de la clase
                            context.push(
                              '${AppRoutes.teacherClassDetail}/${classModel.id}/statistics',
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Text(
                                'Ver estadísticas',
                                style: context.bodySmallOnSurfaceVariant
                                    ?.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right),
                            ],
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
