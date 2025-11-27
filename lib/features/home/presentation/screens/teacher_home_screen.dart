import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
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
        title: HomeStrings.teacherHomeTitle,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: SettingsStrings.logout,
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
                title: HomeStrings.teacherWelcomeTitle,
                subtitle: HomeStrings.teacherWelcomeSubtitle,
                buttonLabel: HomeStrings.manageClassesAction,
                onPressed: () => context.go(AppRoutes.teacherClassesList),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeQuickActionsSection(
                title: HomeStrings.quickActionsTitle,
                subtitle: HomeStrings.teacherQuickActionsSubtitle,
                actions: quickActions,
              ),
              const SizedBox(height: AppSpacing.xl),
              const HomeHighlightsCard(
                icon: Icons.lightbulb_outline,
                description: HomeStrings.teacherHighlightsDescription,
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
        title: HomeStrings.manageClassesAction,
        description: HomeStrings.manageClassesDescription,
        onTap: () => context.go(AppRoutes.teacherClassesList),
      ),
      HomeQuickActionConfig(
        icon: Icons.add_circle_outline,
        title: HomeStrings.createClassAction,
        description: HomeStrings.createClassDescription,
        onTap: () => context.push(AppRoutes.createClass),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
    ];
  }
}
