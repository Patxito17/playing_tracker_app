import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/home_greeting_hero.dart';
import '../widgets/home_menu_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Pantalla de inicio para docentes con diseño premium de "Dashboard Musical".
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.m),

            // Sección Hero de Saludo
            HomeGreetingHero(
              title: userName.isNotEmpty
                  ? l10n.welcomeUser(userName)
                  : l10n.teacherWelcomeProfe,
              subtitle: l10n.musicalControlPanel,
              backgroundIcon: Icons.piano_rounded,
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
                  icon: Icons.library_music_rounded,
                  label: l10n.myClassesLabel,
                  onTap: () => context.go(AppRoutes.teacherClassesList),
                ),
                HomeMenuCard(
                  icon: Icons.add_rounded,
                  customIcon: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 32),
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 14,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  label: l10n.createClassAction,
                  iconColor: const Color(0xFF059669),
                  iconBackgroundColor: const Color(
                    0xFF059669,
                  ).withValues(alpha: 0.1),
                  onTap: () => context.push(AppRoutes.createClass),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección Tareas
            _buildSectionHeader(context, l10n.tasksSectionTitle),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              children: [
                HomeMenuCard(
                  icon: Icons.assignment_rounded,
                  label: l10n.viewTasksLabel,
                  iconColor: Colors.amber[700],
                  iconBackgroundColor: Colors.amber.withValues(alpha: 0.1),
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              children: [
                HomeMenuCard(
                  icon: Icons.analytics_rounded,
                  label: l10n.progressLabel,
                  iconColor: Colors.purple[700],
                  iconBackgroundColor: Colors.purple.withValues(alpha: 0.1),
                  onTap: () => context.go(AppRoutes.teacherStatistics),
                ),
                HomeMenuCard(
                  icon: Icons.history_rounded,
                  label: l10n.historyLabel,
                  iconColor: Colors.blueGrey[700],
                  iconBackgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
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
