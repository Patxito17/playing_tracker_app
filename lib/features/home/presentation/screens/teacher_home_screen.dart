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
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../tutorial/domain/tutorial_keys.dart';
import '../../../tutorial/presentation/tutorial_target_builder.dart';
import '../widgets/home_greeting_hero.dart';
import '../widgets/home_menu_card.dart';

/// Pantalla de inicio para docentes con diseño premium de "Dashboard Musical".
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final _keys = TeacherTutorialKeys();
  bool _tutorialTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detecta si el flag fue reseteado desde Ajustes (p.ej. "Repetir tutorial").
    // Se ejecuta cada vez que el widget vuelve a ser visible en el IndexedStack.
    final done = context.read<SettingsCubit>().isTeacherTutorialDone();
    if (!done) _tutorialTriggered = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tutorialTriggered) _scheduleTutorial();
    });
  }

  Future<void> _scheduleTutorial() async {
    if (!mounted) return;
    final cubit = context.read<SettingsCubit>();
    if (cubit.isTeacherTutorialDone()) return;
    _tutorialTriggered = true;
    await cubit.markTeacherTutorialDone();
    if (!mounted) return;
    _showTutorial();
  }

  void _showTutorial() {
    final colorScheme = context.colorScheme;
    TutorialCoachMark(
      targets: TutorialTargetBuilder.buildTeacherTargets(context, _keys),
      colorShadow: colorScheme.primary,
      opacityShadow: 0.75,
      useSafeArea: true,
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
    ).show(context: context);
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

    return Scaffold(
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

            // Sección Hero de Saludo
            HomeGreetingHero(
              key: _keys.greetingHero,
              title: userName.isNotEmpty
                  ? l10n.welcomeUser(userName)
                  : l10n.teacherWelcomeProfe,
              subtitle: l10n.musicalControlPanel,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección Clases
            _buildSectionHeader(context, l10n.manageMyClasses),
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
                  icon: Icons.library_music_rounded,
                  label: l10n.myClassesLabel,
                  onTap: () => context.go(AppRoutes.teacherClassesList),
                ),
                HomeMenuCard(
                  key: _keys.createClass,
                  icon: Icons.add_rounded,
                  customIcon: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 32),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 14,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  label: l10n.createClassAction,
                  iconColor: colorScheme.tertiary,
                  iconBackgroundColor: colorScheme.tertiary.withValues(
                    alpha: 0.12,
                  ),
                  onTap: () => context.push(AppRoutes.createClass),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección Tareas
            _buildSectionHeader(context, l10n.tasksSectionTitle),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              key: _keys.tasksGrid,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              children: [
                HomeMenuCard(
                  icon: Icons.assignment_rounded,
                  label: l10n.viewTasksLabel,
                  iconColor: colorScheme.secondary,
                  iconBackgroundColor: colorScheme.secondary.withValues(
                    alpha: 0.12,
                  ),
                  onTap: () => context.push(AppRoutes.taskList),
                ),
                HomeMenuCard(
                  icon: Icons.add_task_rounded,
                  label: l10n.newTaskLabel,
                  onTap: () => context.push(AppRoutes.createTask),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección Estadísticas
            _buildSectionHeader(context, l10n.statsSectionTitle),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              key: _keys.statsGrid,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              children: [
                HomeMenuCard(
                  icon: Icons.analytics_rounded,
                  label: l10n.progressLabel,
                  iconColor: colorScheme.tertiary,
                  iconBackgroundColor: colorScheme.tertiary.withValues(
                    alpha: 0.12,
                  ),
                  onTap: () => context.go(AppRoutes.teacherStatistics),
                ),
                HomeMenuCard(
                  icon: Icons.history_rounded,
                  label: l10n.historyLabel,
                  iconColor: colorScheme.onSurfaceVariant,
                  iconBackgroundColor: colorScheme.surfaceContainerHighest,
                  onTap: () {
                    // Historial funcional próximamente para docentes
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: context.titleLargeBold);
  }
}
