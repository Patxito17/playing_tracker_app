import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/classes/domain/models/class_model.dart';
import '../../../../features/classes/domain/models/membership_model.dart';
import '../../../../features/classes/domain/repositories/class_repository.dart';
import '../../../../features/classes/presentation/cubit/membership_cubit.dart';
import '../../../../features/classes/presentation/cubit/membership_state.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla para gestionar alumnos de una clase conectada al [MembershipCubit].
class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key, required this.classId});

  final String classId;

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  late final MembershipCubit _membershipCubit;
  late final Future<ClassModel?> _classFuture;

  @override
  void initState() {
    super.initState();
    _membershipCubit = context.read<MembershipCubit>();
    _classFuture = context.read<ClassRepository>().getClassById(widget.classId);
    _membershipCubit.loadMembers(classId: widget.classId, refresh: true);
  }

  void _handleOperationSuccess(BuildContext context, MembershipSuccess state) {
    final message = state.message;
    if (message == null) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleOperationError(BuildContext context, MembershipError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: context.colorScheme.error,
      ),
    );
  }

  Future<void> _confirmRemoveStudent(MembershipModel member) async {
    final shouldRemove =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(StudentStrings.removeStudent),
            content: Text(StudentStrings.removeStudentConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(CommonStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(CommonStrings.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldRemove) {
      return;
    }
    await _membershipCubit.removeStudent(
      classId: widget.classId,
      studentId: member.studentId,
    );
  }

  Future<void> _confirmRegenerateCode() async {
    final shouldRegenerate =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(ClassesStrings.regenerateAccessCodeAction),
            content: Text(ClassesStrings.regenerateCodeConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(CommonStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(CommonStrings.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldRegenerate) {
      return;
    }
    await _membershipCubit.regenerateAccessCode(widget.classId);
  }

  Future<void> _handleRefresh() => _membershipCubit.refreshMembers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ClassDetailStrings.manageStudentsTitle,
        actions: [
          IconButton(
            onPressed: _confirmRegenerateCode,
            icon: const Icon(Icons.refresh),
            tooltip: ClassesStrings.regenerateAccessCodeAction,
          ),
        ],
      ),
      body: BlocConsumer<MembershipCubit, MembershipState>(
        listenWhen: (previous, current) =>
            current is MembershipSuccess || current is MembershipError,
        buildWhen: (previous, current) =>
            current is MembershipListLoading ||
            current is MembershipListSuccess ||
            current is MembershipListError ||
            current is MembershipEmpty ||
            current is MembershipInitial,
        listener: (context, state) {
          if (state is MembershipSuccess) {
            _handleOperationSuccess(context, state);
          }
          if (state is MembershipError) {
            _handleOperationError(context, state);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _ClassSummaryHeader(classFuture: _classFuture),
              Expanded(
                child: _StateAwareMembersContent(
                  state,
                  _handleRefresh,
                  (member) => _confirmRemoveStudent(member),
                  () {
                    _membershipCubit.loadMembers(classId: widget.classId);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClassSummaryHeader extends StatelessWidget {
  const _ClassSummaryHeader({required this.classFuture});

  final Future<ClassModel?> classFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel?>(
      future: classFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.m),
            child: LinearProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SelectableText.rich(
              TextSpan(
                text: ClassesStrings.classGenericError,
                style: context.bodyMediumOnSurfaceVariant,
              ),
            ),
          );
        }

        final classModel = snapshot.data!;
        final statusLabel = classModel.canJoin
            ? ClassesStrings.classStatusActive
            : ClassesStrings.classStatusArchived;
        final statusColor = classModel.canJoin
            ? context.colorScheme.primary
            : context.colorScheme.error;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: CustomCard(
            title: classModel.name,
            subtitle: classModel.description ?? '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    Chip(
                      label: Text(statusLabel),
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      labelStyle: context.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.password_rounded, size: 16),
                      label: Text(
                        '${ClassesStrings.accessCodeValueLabel}: ${classModel.accessCode}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  StudentStrings.studentsJoinWithCode,
                  style: context.bodySmallOnSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StateAwareMembersContent extends StatelessWidget {
  const _StateAwareMembersContent(
    this.state,
    this.onRefresh,
    this.onRemoveStudent,
    this.onLoadMore,
  );

  final MembershipState state;
  final Future<void> Function() onRefresh;
  final void Function(MembershipModel member) onRemoveStudent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      MembershipListLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      MembershipEmpty(:final message) => _EmptyManageStudentsState(
        title: message,
        subtitle: StudentStrings.studentsJoinWithCode,
        actionLabel: CommonStrings.close,
        onAction: () => Navigator.of(context).maybePop(),
      ),
      MembershipListError(:final message) => _ErrorState(
        message: message,
        onRetry: onRefresh,
      ),
      MembershipListSuccess() => _StudentsList(
        state: state as MembershipListSuccess,
        onRefresh: onRefresh,
        onRemoveStudent: onRemoveStudent,
        onLoadMore: onLoadMore,
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _StudentsList extends StatelessWidget {
  const _StudentsList({
    required this.state,
    required this.onRefresh,
    required this.onRemoveStudent,
    required this.onLoadMore,
  });

  final MembershipListSuccess state;
  final Future<void> Function() onRefresh;
  final void Function(MembershipModel member) onRemoveStudent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final members = state.members;
    final itemCount = members.length + (state.hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= members.length) {
            return _LoadMoreTile(
              isPaginating: state.isPaginating,
              onLoadMore: onLoadMore,
            );
          }
          final member = members[index];
          return _StudentTile(
            member: member,
            onRemove: () => onRemoveStudent(member),
          );
        },
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({required this.isPaginating, required this.onLoadMore});

  final bool isPaginating;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isPaginating) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      child: FilledButton.tonal(
        onPressed: onLoadMore,
        child: Text(CommonStrings.loadMore),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.member, required this.onRemove});

  final MembershipModel member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final joinedAt = DateFormat(
      'dd/MM/yyyy - HH:mm',
    ).format(member.joinedAt.toDate());
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: CustomCard(
        title: '${StudentStrings.studentIdLabel}: ${member.studentId}',
        subtitle: '${StudentStrings.joinedAtLabel} $joinedAt',
        trailingAction: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: StudentStrings.removeStudent,
          color: context.colorScheme.error,
          onPressed: onRemove,
        ),
        child: const SizedBox.shrink(),
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

/// Widget para mostrar estado vacío en gestión de estudiantes.
class _EmptyManageStudentsState extends StatelessWidget {
  const _EmptyManageStudentsState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: context.colorScheme.outline,
          ),
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
            icon: const Icon(Icons.close),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
