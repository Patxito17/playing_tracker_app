import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../sessions/domain/repositories/session_repository.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../tutorial/domain/tutorial_keys.dart';
import '../../../tutorial/presentation/tutorial_target_builder.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import '../widgets/home_accomplishment_card.dart';
import '../widgets/home_greeting_hero.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/home_progress_card.dart';

/// Pantalla de inicio para estudiantes con diseño premium "Student Dashboard".
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _keys = StudentTutorialKeys();
  bool _tutorialTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detecta si el flag fue reseteado desde Ajustes (p.ej. "Repetir tutorial").
    // Se ejecuta cada vez que el widget vuelve a ser visible en el IndexedStack.
    // Leemos desde el estado reactivo del cubit para garantizar consistencia.
    final done =
        context.read<SettingsCubit>().state.studentTutorialDone;
    if (!done) _tutorialTriggered = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tutorialTriggered) _scheduleTutorial();
    });
  }

  Future<void> _scheduleTutorial() async {
    if (!mounted) return;
    final cubit = context.read<SettingsCubit>();
    if (cubit.state.studentTutorialDone) return;
    _tutorialTriggered = true;
    await cubit.markStudentTutorialDone();
    if (!mounted) return;
    _showTutorial();
  }

  void _showTutorial() {
    final colorScheme = context.colorScheme;
    TutorialCoachMark(
      targets: [
        ...TutorialTargetBuilder.buildStudentTargets(context, _keys),
        ...TutorialTargetBuilder.buildStudentNavBarTargets(context),
      ],
      colorShadow: colorScheme.primary,
      opacityShadow: 0.75,
      useSafeArea: true,
      beforeFocus: (target) async {
        // Se captura el router antes de cualquier await para satisfacer
        // use_build_context_synchronously.
        final router = GoRouter.of(context);
        // Desplaza el contenido para que el widget sea visible
        final key = target.keyTarget;
        if (key?.currentContext != null) {
          await Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.3,
          );
        }
        // Navega a la pestaña correspondiente para los pasos de la nav bar.
        String? route;
        switch (target.identify) {
          case 'nav_student_classes':
            route = AppRoutes.studentClassesList;
          case 'nav_student_history':
            route = AppRoutes.studentHistory;
          case 'nav_student_statistics':
            route = AppRoutes.studentStatistics;
          case 'nav_student_settings':
            route = AppRoutes.studentSettings;
        }
        if (route != null) {
          router.go(route);
          await Future.delayed(const Duration(milliseconds: 350));
        }
      },
      skipWidget: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Text(
          context.l10n.tutorialSkip,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onFinish: () {},
      onSkip: () => true,
    ).show(context: context, rootOverlay: true);
  }

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

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current.tutorialResetVersion != previous.tutorialResetVersion,
      listener: (context, state) {
        _tutorialTriggered = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_tutorialTriggered) _scheduleTutorial();
        });
      },
      child: BlocProvider(
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
        child: Scaffold(
          appBar: CustomAppBar(
            showLogo: true,
            title: 'Playing Tracker',
            actions: [
              Container(
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
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.m),

                // Hero de Saludo
                HomeGreetingHero(
                  key: _keys.greetingHero,
                  title: l10n.welcomeUser(userName),
                  subtitle: l10n.musicalControlPanel,
                ),

                const SizedBox(height: AppSpacing.l),

                // Progreso Semanal y Racha de Días Consecutivos
                BlocBuilder<ProgressCubit, ProgressState>(
                  builder: (context, state) {
                    final loaded = state is ProgressLoaded ? state : null;
                    return Column(
                      children: [
                        HomeProgressCard(
                          key: _keys.progressCard,
                          progress:
                              loaded != null ? loaded.weeklyPercentage / 100 : 0.0,
                          weeklyData: loaded?.dailyValues ?? List.filled(7, 0.0),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        HomeAccomplishmentCard(
                          key: _keys.accomplishmentCard,
                          title: l10n.currentStreak,
                          subtitle: (loaded?.currentStreak ?? 0) > 0
                              ? l10n.streakSubtitleActive(loaded!.currentStreak)
                              : l10n.streakSubtitleInactive,
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ],
                    );
                  },
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
                      key: _keys.classesCard,
                      icon: Icons.piano_rounded,
                      label: l10n.myClassesLabel,
                      onTap: () => context.go(AppRoutes.studentClassesList),
                    ),
                    HomeMenuCard(
                      key: _keys.tasksCard,
                      icon: Icons.menu_book_rounded,
                      label: l10n.studentTasksAction,
                      onTap: () => context.push(AppRoutes.assignmentList),
                    ),
                    HomeMenuCard(
                      key: _keys.historyCard,
                      icon: Icons.history_rounded,
                      label: l10n.historyTab,
                      onTap: () => context.go(AppRoutes.studentHistory),
                    ),
                    HomeMenuCard(
                      key: _keys.enrollCard,
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
      ),
    );
  }
}

