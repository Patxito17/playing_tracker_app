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
import '../../domain/models/class_model.dart';
import '../cubit/class_cubit.dart';
import '../cubit/class_state.dart';

/// Pantalla de lista de clases creadas por el docente conectada al [ClassCubit].
class TeacherClassesListScreen extends StatefulWidget {
  const TeacherClassesListScreen({super.key});

  @override
  State<TeacherClassesListScreen> createState() =>
      _TeacherClassesListScreenState();
}

class _TeacherClassesListScreenState extends State<TeacherClassesListScreen> {
  /// Abre la pantalla de creación reutilizando el cubit actual y refresca al volver.
  Future<void> _openCreateClass(BuildContext context) async {
    final classCubit = context.read<ClassCubit>();
    final result = await context.push<bool?>(
      AppRoutes.createClass,
      extra: classCubit,
    );
    if (!mounted) return;
    if (result == true) {
      await classCubit.refreshClasses();
    }
  }

  Future<void> _openClassDetail(BuildContext context, ClassModel classModel) =>
      context.push('${AppRoutes.teacherClassDetail}/${classModel.id}');

  Future<void> _handleRefresh(BuildContext context) =>
      context.read<ClassCubit>().refreshClasses();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      buildWhen: (previous, current) => current is! ClassActionSuccess,
      builder: (context, state) {
        final isLoading = state is ClassLoading;
        final navigationShell = StatefulNavigationShell.maybeOf(context);
        final VoidCallback? goHome = navigationShell == null
            ? null
            : () => navigationShell.goBranch(0);

        return Scaffold(
          appBar: CustomAppBar(
            title: ClassesStrings.myClassesTitle,
            actions: [
              IconButton(
                icon: const Icon(Icons.home_rounded),
                tooltip: HomeStrings.teacherHomeTitle,
                onPressed: goHome,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: isLoading ? null : () => _openCreateClass(context),
                tooltip: ClassesStrings.createNewClass,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _handleRefresh(context),
            child: _StateAwareContent(
              state: state,
              onCreateClass: () => _openCreateClass(context),
              onRetry: () => _handleRefresh(context),
              onClassSelected: (classModel) =>
                  _openClassDetail(context, classModel),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isLoading ? null : () => _openCreateClass(context),
            icon: const Icon(Icons.add),
            label: Text(ClassesStrings.createClass),
          ),
        );
      },
    );
  }
}

/// Contenido que reacciona al estado del [ClassCubit].
class _StateAwareContent extends StatelessWidget {
  const _StateAwareContent({
    required this.state,
    required this.onCreateClass,
    required this.onRetry,
    required this.onClassSelected,
  });

  final ClassState state;
  final VoidCallback onCreateClass;
  final VoidCallback onRetry;
  final ValueChanged<ClassModel> onClassSelected;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ClassLoading() => _LoadingState(),
      ClassEmpty(:final message) => LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: _EmptyState(
                    icon: Icons.class_outlined,
                    title: message,
                    subtitle: ClassesStrings.createFirstClass,
                    actionLabel: ClassesStrings.createClass,
                    onAction: onCreateClass,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ClassError(:final message) => _ErrorState(
        message: message,
        onRetry: onRetry,
      ),
      ClassSuccess(:final classes) => _ClassesList(
        classes: classes,
        onClassSelected: onClassSelected,
      ),
      _ => _LoadingState(),
    };
  }
}

/// Lista de clases utilizando `CustomCard` y navegación declarativa.
class _ClassesList extends StatelessWidget {
  const _ClassesList({required this.classes, required this.onClassSelected});

  final List<ClassModel> classes;
  final ValueChanged<ClassModel> onClassSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(
          ClassesStrings.classesCreatedTitle,
          style: context.headlineMediumBold,
        ),
        const SizedBox(height: AppSpacing.l),
        ...classes.map(
          (classModel) => _ClassCard(
            classModel: classModel,
            onTap: () => onClassSelected(classModel),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// Card individual que resume la clase y permite abrir el detalle.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classModel, required this.onTap});

  final ClassModel classModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = classModel.canJoin;
    final statusLabel = isActive
        ? ClassesStrings.classStatusActive
        : ClassesStrings.classStatusArchived;
    final statusColor = isActive
        ? context.colorScheme.primary
        : context.colorScheme.outline;
    final creationDate = DateFormat(
      'dd/MM/yyyy',
    ).format(classModel.createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Opacity(
        opacity: isActive ? 1 : 0.65,
        child: CustomCard(
          margin: EdgeInsets.zero,
          title: classModel.name,
          subtitle: classModel.description ?? '',
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.class_,
                    color: isActive
                        ? context.colorScheme.primary
                        : context.colorScheme.outline,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  _StatusChip(label: statusLabel, color: statusColor),
                  _InfoChip(
                    icon: Icons.password_rounded,
                    label:
                        '${ClassesStrings.accessCodeValueLabel}: ${classModel.accessCode}',
                  ),
                  _InfoChip(icon: Icons.calendar_month, label: creationDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: context.textTheme.bodySmall?.copyWith(color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

/// Estado de carga con indicador central y soporte para pull-to-refresh.
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: AppSpacing.xxl),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// Widget para mostrar estado vacío reutilizable.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de error que muestra mensajes con `SelectableText.rich`.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
          onPressed: onRetry,
          child: Text(CommonStrings.retry),
        ),
      ],
    );
  }
}
