import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/classes/domain/models/class_model.dart';
import '../../../../features/classes/domain/models/membership_model.dart';
import '../../../../features/classes/domain/repositories/class_repository.dart';
import '../../../../features/classes/presentation/cubit/membership_cubit.dart';
import '../../../../features/classes/presentation/cubit/membership_state.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/class_chips.dart';
import '../widgets/class_empty_state.dart';
import '../widgets/class_error_state.dart';
import '../widgets/teacher_class_overview_card.dart';

/// Pantalla para gestionar alumnos de una clase conectada al [MembershipCubit].
class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.manageStudentsTitle,
        actions: const [],
      ),
      body: ManageStudentsView(classId: classId),
    );
  }
}

/// Vista reutilizable para listar y administrar los alumnos de una clase.
class ManageStudentsView extends StatefulWidget {
  const ManageStudentsView({
    super.key,
    required this.classId,
    this.showOverview = true,
    this.showStudentsHint = true,
  });

  final String classId;
  final bool showOverview;
  final bool showStudentsHint;

  @override
  State<ManageStudentsView> createState() => _ManageStudentsViewState();
}

class _ManageStudentsViewState extends State<ManageStudentsView> {
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
    var message = state.message;
    if (message == null || message.isEmpty) {
      message = switch (state.action) {
        MembershipAction.regeneratedAccessCode =>
          context.l10n.membershipRegenerateSuccess,
        _ => context.l10n.genericOperationSuccess,
      };
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleOperationError(BuildContext context, MembershipError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message ?? context.l10n.membershipServiceError),
        backgroundColor: context.colorScheme.error,
      ),
    );
  }

  Future<void> _confirmRegenerateCode() async {
    final shouldRegenerate =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.regenerateAccessCodeAction),
            content: Text(context.l10n.regenerateCodeConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n.confirm),
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

  void _copyAccessCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleStudentStatus(MembershipModel member) {
    _membershipCubit.updateStudentMembershipStatus(
      classId: widget.classId,
      studentId: member.studentId,
      isActive: !member.isActive,
    );
  }

  Future<void> _confirmDeleteStudentPermanent(MembershipModel member) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.removeStudent),
            content: Text(context.l10n.removeStudentConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  foregroundColor: context.colorScheme.onError,
                ),
                child: Text(context.l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }
    await _membershipCubit.deleteStudentMembership(
      classId: widget.classId,
      studentId: member.studentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MembershipCubit, MembershipState>(
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
        final membersCount = switch (state) {
          MembershipListSuccess(:final members) =>
            members.where((member) => member.isActive).length,
          MembershipEmpty() => 0,
          _ => null,
        };
        return Column(
          children: [
            if (widget.showOverview)
              FutureBuilder<ClassModel?>(
                future: _classFuture,
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
                          text: context.l10n.classGenericError,
                          style: context.bodyMediumOnSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: TeacherClassOverviewCard(
                      classModel: snapshot.data!,
                      studentsCount: membersCount,
                      activeTasksCount: null,
                      showStudentsHint: widget.showStudentsHint,
                      onCopyCode: _copyAccessCode,
                      onRegenerateCode: _confirmRegenerateCode,
                    ),
                  );
                },
              ),
            Expanded(
              child: _StateAwareMembersContent(
                state,
                _handleRefresh,
                (member) => _toggleStudentStatus(member),
                (member) => _confirmDeleteStudentPermanent(member),
                () {
                  _membershipCubit.loadMembers(classId: widget.classId);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StateAwareMembersContent extends StatelessWidget {
  const _StateAwareMembersContent(
    this.state,
    this.onRefresh,
    this.onToggleStatus,
    this.onDeleteStudent,
    this.onLoadMore,
  );

  final MembershipState state;
  final Future<void> Function() onRefresh;
  final void Function(MembershipModel member) onToggleStatus;
  final void Function(MembershipModel member) onDeleteStudent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      MembershipListLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      MembershipEmpty(:final message) => ClassEmptyState(
        icon: Icons.people_outline_rounded,
        title: message?.isNotEmpty == true ? message! : context.l10n.noStudentsInClass,
        subtitle: context.l10n.studentsJoinWithCode,
        actionLabel: context.l10n.close,
        actionIcon: Icons.close_rounded,
        onAction: () => Navigator.of(context).maybePop(),
      ),
      MembershipListError(:final message) => ClassErrorState(
        message: message ?? context.l10n.loadingError,
        onRetry: onRefresh,
      ),
      MembershipListSuccess() => _StudentsList(
        state: state as MembershipListSuccess,
        onRefresh: onRefresh,
        onToggleStatus: onToggleStatus,
        onDeleteStudent: onDeleteStudent,
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
    required this.onToggleStatus,
    required this.onDeleteStudent,
    required this.onLoadMore,
  });

  final MembershipListSuccess state;
  final Future<void> Function() onRefresh;
  final void Function(MembershipModel member) onToggleStatus;
  final void Function(MembershipModel member) onDeleteStudent;
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
            onToggleStatus: () => onToggleStatus(member),
            onDelete: () => onDeleteStudent(member),
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
        child: Text(context.l10n.loadMore),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.member,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final MembershipModel member;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final joinedAt = DateFormat('dd/MM/yyyy - HH:mm').format(member.joinedAt.toDate());
    final studentName = member.studentName?.trim();
    final title = studentName?.isNotEmpty == true ? studentName! : member.studentId;
    final studentEmail = member.studentEmail?.trim();
    final subtitle = studentEmail?.isNotEmpty == true ? studentEmail! : 'ID: ${member.studentId}';
    final isActive = member.isActive;
    final statusColor = isActive ? colorScheme.primary : colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con inicial
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Wrap(
                        spacing: AppSpacing.s,
                        runSpacing: AppSpacing.s,
                        children: [
                          ClassStatusChip(
                            label: isActive
                                ? context.l10n.classStatusActive
                                : context.l10n.classStatusArchived,
                            color: statusColor,
                          ),
                          ClassInfoChip(
                            icon: Icons.calendar_month_rounded,
                            label: joinedAt,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Acciones
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onToggleStatus,
                      tooltip: isActive
                          ? context.l10n.archiveClassAction
                          : context.l10n.activateClassAction,
                      icon: Icon(
                        isActive
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: isActive
                            ? colorScheme.secondary
                            : colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      tooltip: context.l10n.delete,
                      icon: const Icon(Icons.delete_forever_rounded),
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
