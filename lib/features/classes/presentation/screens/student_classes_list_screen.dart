import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/membership_model.dart';
import '../cubit/student_classes_cubit.dart';
import '../cubit/student_classes_state.dart';

/// Pantalla de lista de clases a las que pertenece el estudiante
///
/// Muestra las clases reales a las que pertenece el estudiante.
class StudentClassesListScreen extends StatefulWidget {
  const StudentClassesListScreen({super.key});

  @override
  State<StudentClassesListScreen> createState() =>
      _StudentClassesListScreenState();
}

class _StudentClassesListScreenState extends State<StudentClassesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<StudentClassesCubit>().watchStudentClasses(
          studentId: authState.userId,
        );
      }
    });
  }

  Future<void> _handleRefresh() =>
      context.read<StudentClassesCubit>().refresh();

  void _openJoinClass(BuildContext context) =>
      context.push(AppRoutes.joinClass);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ClassesStrings.myClassesTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            onPressed: () => _openJoinClass(context),
            tooltip: ClassesStrings.joinClass,
          ),
        ],
      ),
      body: BlocBuilder<StudentClassesCubit, StudentClassesState>(
        builder: (context, state) {
          return switch (state) {
            StudentClassesLoading() => _LoadingState(onRefresh: _handleRefresh),
            StudentClassesEmpty(:final message) => _EmptyClassesState(
              message: message,
              onRefresh: _handleRefresh,
              onAction: () => _openJoinClass(context),
            ),
            StudentClassesError(:final message) => _ErrorState(
              message: message,
              onRetry: _handleRefresh,
            ),
            StudentClassesSuccess(:final memberships) => _ClassesList(
              memberships: memberships,
              onRefresh: _handleRefresh,
            ),
            _ => _LoadingState(onRefresh: _handleRefresh),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openJoinClass(context),
        icon: const Icon(Icons.add),
        label: Text(ClassesStrings.joinClassAction),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: context.colorScheme.outline),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: context.titleLargeBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: context.bodyMediumOnSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ClassesList extends StatelessWidget {
  const _ClassesList({required this.memberships, required this.onRefresh});

  final List<MembershipModel> memberships;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: memberships.length,
        itemBuilder: (context, index) {
          final membership = memberships[index];
          final joinedAt = dateFormat.format(membership.joinedAt.toDate());
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: CustomCard(
              title: membership.className,
              subtitle: '${ClassesStrings.teacherLabel}${membership.teacherId}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    '${StudentStrings.joinedAtLabel} $joinedAt',
                    style: context.bodySmallOnSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: AppSpacing.xxl),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _EmptyClassesState extends StatelessWidget {
  const _EmptyClassesState({
    required this.message,
    required this.onRefresh,
    required this.onAction,
  });

  final String message;
  final Future<void> Function() onRefresh;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _EmptyState(
            icon: Icons.class_outlined,
            title: message,
            subtitle: ClassesStrings.joinClassWithCode,
            actionLabel: ClassesStrings.joinClassAction,
            onAction: onAction,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
          const SizedBox(height: AppSpacing.m),
          SelectableText.rich(
            TextSpan(
              text: message,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton.tonal(
            onPressed: () => onRetry(),
            child: Text(CommonStrings.retry),
          ),
        ],
      ),
    );
  }
}
