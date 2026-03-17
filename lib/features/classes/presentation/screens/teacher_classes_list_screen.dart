import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/models/class_model.dart';
import '../cubit/class_cubit.dart';
import '../cubit/class_state.dart';
import '../widgets/class_chips.dart';
import '../widgets/class_empty_state.dart';
import '../widgets/class_error_state.dart';

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
    final colorScheme = context.colorScheme;
    return BlocBuilder<ClassCubit, ClassState>(
      buildWhen: (previous, current) => current is! ClassActionSuccess,
      builder: (context, state) {
        final isLoading = state is ClassLoading;

        return Scaffold(
          appBar: CustomAppBar(
            title: context.l10n.myClassesTitle,
            showLogo: true,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add_rounded, color: colorScheme.primary),
                  tooltip: context.l10n.createClassAction,
                  onPressed: isLoading ? null : () => _openCreateClass(context),
                ),
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
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.createClassAction),
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
  final Future<void> Function() onRetry;
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
                child: ClassEmptyState(
                  icon: Icons.library_music_rounded,
                  iconSize: 56,
                  iconBackgroundColor: context.colorScheme.primaryContainer
                      .withValues(alpha: 0.5),
                  title: message?.isNotEmpty == true
                      ? message!
                      : context.l10n.noClassesCreated,
                  subtitle: context.l10n.createFirstClass,
                  actionLabel: context.l10n.createClassAction,
                  onAction: onCreateClass,
                ),
              ),
            ),
          );
        },
      ),
      ClassError(:final message, :final errorType) => ClassErrorState(
        message: _getErrorMessage(context, message, errorType),
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

/// Lista de clases con encabezado y contador de clases activas.
class _ClassesList extends StatelessWidget {
  const _ClassesList({required this.classes, required this.onClassSelected});

  final List<ClassModel> classes;
  final ValueChanged<ClassModel> onClassSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final activeCount = classes.where((c) => c.canJoin).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.classesCreatedTitle,
                style: context.headlineMediumBold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
              ),
              child: Text(
                '$activeCount',
                style: context.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        ...classes.map(
          (classModel) => _ClassCard(
            classModel: classModel,
            onTap: () => onClassSelected(classModel),
          ),
        ),
      ],
    );
  }
}

/// Card premium individual con ícono musical, jerarquía tipográfica y chips informativos.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classModel, required this.onTap});

  final ClassModel classModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isActive = classModel.canJoin;
    final statusLabel = isActive
        ? context.l10n.classStatusActive
        : context.l10n.classStatusArchived;
    final statusColor = isActive ? colorScheme.primary : colorScheme.outline;
    final iconColor = isActive ? colorScheme.primary : colorScheme.outline;
    final creationDate = DateFormat(
      'dd/MM/yyyy',
    ).format(classModel.createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.65,
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado: ícono + nombre + chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.medium,
                          ),
                        ),
                        child: Icon(
                          Icons.library_music_rounded,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classModel.name,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (classModel.description != null &&
                                classModel.description!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                classModel.description!,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Chips informativos
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.s,
                    children: [
                      ClassStatusChip(label: statusLabel, color: statusColor),
                      ClassInfoChip(
                        icon: Icons.password_rounded,
                        label:
                            '${context.l10n.accessCodeLabel}: ${classModel.accessCode}',
                      ),
                      ClassInfoChip(
                        icon: Icons.calendar_month_rounded,
                        label: creationDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

String _getErrorMessage(
  BuildContext context,
  String? message,
  ClassErrorType? errorType,
) {
  if (message != null && message.isNotEmpty) {
    return message;
  }
  return switch (errorType) {
    ClassErrorType.createFailed => context.l10n.classCreateError,
    ClassErrorType.updateFailed => context.l10n.classUpdateError,
    ClassErrorType.loadFailed => context.l10n.classLoadError,
    ClassErrorType.refreshNoTeacher => context.l10n.classRefreshNoTeacherError,
    _ => context.l10n.classGenericError,
  };
}
