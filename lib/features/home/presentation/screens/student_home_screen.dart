import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/home_sections.dart';

/// Pantalla de inicio para estudiantes con accesos directos y resumen.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final quickActions = _buildStudentActions(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.studentHomeTitle,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: context.l10n.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeroCard(
                icon: Icons.emoji_events_outlined,
                title: context.l10n.studentWelcomeTitle,
                subtitle: context.l10n.studentWelcomeSubtitle,
                buttonLabel: context.l10n.studentClassesAction,
                onPressed: () => context.go(AppRoutes.studentClassesList),
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeQuickActionsSection(
                title: context.l10n.quickActionsTitle,
                subtitle: context.l10n.studentQuickActionsSubtitle,
                actions: quickActions,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeHighlightsCard(
                icon: Icons.auto_graph_outlined,
                description: context.l10n.studentHighlightsDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HomeQuickActionConfig> _buildStudentActions(BuildContext context) {
    return [
      HomeQuickActionConfig(
        icon: Icons.class_rounded,
        title: context.l10n.studentClassesAction,
        description: context.l10n.studentClassesDescription,
        onTap: () => context.go(AppRoutes.studentClassesList),
      ),
      HomeQuickActionConfig(
        icon: Icons.assignment_outlined,
        title: context.l10n.myTasksTitle,
        description: context.l10n.studentTasksDescription,
        onTap: () => context.push(AppRoutes.assignmentList),
      ),
      HomeQuickActionConfig(
        icon: Icons.history,
        title: context.l10n.sessionHistoryTitle,
        description: context.l10n.sessionHistoryDescription,
        onTap: () => context.go(AppRoutes.studentHistory),
      ),
      HomeQuickActionConfig(
        icon: Icons.group_add_outlined,
        title: context.l10n.joinClassAction,
        description: context.l10n.joinClassDescription,
        onTap: () => context.push(AppRoutes.joinClass),
      ),
    ];
  }
}
