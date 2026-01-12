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

/// Pantalla de inicio para estudiantes con accesos directos y resumen.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final quickActions = _buildStudentActions(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: HomeStrings.studentHomeTitle,
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
                icon: Icons.emoji_events_outlined,
                title: HomeStrings.studentWelcomeTitle,
                subtitle: HomeStrings.studentWelcomeSubtitle,
                buttonLabel: HomeStrings.studentClassesAction,
                onPressed: () => context.go(AppRoutes.studentClassesList),
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeQuickActionsSection(
                title: HomeStrings.quickActionsTitle,
                subtitle: HomeStrings.studentQuickActionsSubtitle,
                actions: quickActions,
              ),
              const SizedBox(height: AppSpacing.xl),
              const HomeHighlightsCard(
                icon: Icons.auto_graph_outlined,
                description: HomeStrings.studentHighlightsDescription,
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
        title: HomeStrings.studentClassesAction,
        description: HomeStrings.studentClassesDescription,
        onTap: () => context.go(AppRoutes.studentClassesList),
      ),
      HomeQuickActionConfig(
        icon: Icons.group_add_outlined,
        title: HomeStrings.joinClassAction,
        description: HomeStrings.joinClassDescription,
        onTap: () => context.push(AppRoutes.joinClass),
      ),
    ];
  }
}
