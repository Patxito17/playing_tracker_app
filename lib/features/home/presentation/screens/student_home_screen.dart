import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../sessions/domain/repositories/session_repository.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import '../widgets/home_greeting_hero.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/home_progress_card.dart';
import '../widgets/home_accomplishment_card.dart';

/// Pantalla de inicio para estudiantes con diseño premium "Student Dashboard".
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    final userName = context.select((AuthCubit cubit) {
      final state = cubit.state;
      if (state is AuthAuthenticated) {
        return state.firstName;
      }
      return '';
    });

    return Scaffold(
      appBar: CustomAppBar(
        showLogo: true,
        title: 'Playing Tracker',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.l),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: l10n.logout,
                icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ),
          ),
        ],
      ),

      body: BlocProvider(
        create: (context) {
          final cubit = ProgressCubit(
            sessionRepository: context.read<SessionRepository>(),
            taskRepository: context.read<TaskRepository>(),
          );
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            cubit.watchProgress(authState.userId);
          }
          return cubit;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.m),

              // Hero de Saludo
              HomeGreetingHero(
                title: l10n.welcomeUser(userName),
                subtitle: l10n.musicalControlPanel,
              ),

              const SizedBox(height: AppSpacing.l),

              // Progreso Semanal
              BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                  if (state is ProgressLoaded) {
                    return HomeProgressCard(
                      progress: state.weeklyPercentage / 100,
                      weeklyData: state.dailyValues,
                    );
                  }
                  
                  // Estado de carga o inicial: Shimmer o progreso estático
                  return HomeProgressCard(
                    progress: 0.0,
                    weeklyData: List.filled(7, 0.0),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

            // Medalla / Logro Reciente
            HomeAccomplishmentCard(
              title: l10n.constancyMedal,
              subtitle: l10n.constancyDescription,
              icon: Icons.emoji_events_rounded,
            ),

            const SizedBox(height: AppSpacing.m),

            // Acciones Rápidas
            Text(l10n.quickActionsTitle, style: context.titleLargeBold),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              children: [
                HomeMenuCard(
                  icon: Icons.piano_rounded,
                  label: l10n.myClassesLabel,
                  onTap: () => context.go(AppRoutes.studentClassesList),
                ),
                HomeMenuCard(
                  icon: Icons.menu_book_rounded,
                  label: l10n.studentTasksAction,
                  onTap: () => context.push(AppRoutes.assignmentList),
                ),
                HomeMenuCard(
                  icon: Icons.history_rounded,
                  label: l10n.historyTab,
                  onTap: () => context.go(AppRoutes.studentHistory),
                ),
                HomeMenuCard(
                  icon: Icons.library_music_rounded,
                  label: l10n.inscriptionsAction,
                  onTap: () => context.push(AppRoutes.joinClass),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    ),
  );
}
}
