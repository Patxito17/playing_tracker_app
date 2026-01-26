import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/home_sections.dart';

/// Pantalla de inicio para docentes con acciones y resumen rápido.
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final quickActions = _buildTeacherActions(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.teacherHomeTitle,
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
                icon: Icons.school_rounded,
                title: context.l10n.teacherWelcomeTitle,
                subtitle: context.l10n.teacherWelcomeSubtitle,
                buttonLabel: context.l10n.manageClassesAction,
                onPressed: () => context.go(AppRoutes.teacherClassesList),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeQuickActionsSection(
                title: context.l10n.quickActionsTitle,
                subtitle: context.l10n.teacherQuickActionsSubtitle,
                actions: quickActions,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeHighlightsCard(
                icon: Icons.lightbulb_outline,
                description: context.l10n.teacherHighlightsDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HomeQuickActionConfig> _buildTeacherActions(BuildContext context) {
    final colorScheme = context.colorScheme;
    return [
      HomeQuickActionConfig(
        icon: Icons.class_rounded,
        title: context.l10n.manageClassesAction,
        description: context.l10n.manageClassesDescription,
        onTap: () => context.go(AppRoutes.teacherClassesList),
      ),
      HomeQuickActionConfig(
        icon: Icons.add_circle_outline,
        title: context.l10n.createClassAction,
        description: context.l10n.createClassDescription,
        onTap: () => context.push(AppRoutes.createClass),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
    ];
  }
}
