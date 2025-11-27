import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/auth/domain/models/teacher_model.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/classes/domain/models/class_model.dart';
import '../../../../features/classes/domain/repositories/class_repository.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_tab_bar.dart';
import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import '../widgets/class_statistics_tab.dart';
import '../widgets/class_tasks_tab.dart';
import '../widgets/teacher_class_overview_card.dart';
import 'manage_students_screen.dart';

/// Pantalla de detalle de clase para docente
///
/// Muestra la información de la clase con 3 tabs y un resumen superior con
/// datos clave (código, estado y acciones rápidas).
class TeacherClassDetailScreen extends StatefulWidget {
  const TeacherClassDetailScreen({super.key, required this.classId});

  final String classId;

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  late Future<ClassModel?> _classFuture;
  StreamSubscription<ClassModel?>? _classSubscription;
  bool _classRemoved = false;

  static const int? _mockActiveTasksCount =
      null; // Placeholder hasta integrar tareas reales

  @override
  void initState() {
    super.initState();
    final repository = context.read<ClassRepository>();
    _classFuture = repository.getClassById(widget.classId);
    _listenClassLifecycle();
    context.read<MembershipCubit>().loadMembers(
      classId: widget.classId,
      refresh: true,
    );
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    super.dispose();
  }

  void _listenClassLifecycle() {
    _classSubscription = context
        .read<ClassRepository>()
        .watchClassById(widget.classId)
        .listen(
          (classModel) {
            if (!mounted || _classRemoved) {
              return;
            }
            if (classModel == null) {
              _handleClassRemoved();
            } else {
              setState(() {
                _classFuture = Future.value(classModel);
              });
            }
          },
          onError: (_) {
            if (!mounted || _classRemoved) {
              return;
            }
            _handleClassRemoved();
          },
        );
  }

  void _handleClassRemoved() {
    if (_classRemoved || !mounted) {
      return;
    }
    _classRemoved = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ClassDetailStrings.classDeletedExitMessage)),
    );
    context.go(AppRoutes.teacherClassesList);
  }

  Future<void> _refreshClassDetails() async {
    final repository = context.read<ClassRepository>();
    setState(() {
      _classFuture = repository.getClassById(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(ClassDetailStrings.classDetailTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: CommonStrings.back,
          ),
          bottom: CustomTabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.info_outline),
                text: ClassDetailStrings.infoTab,
              ),
              Tab(
                icon: Icon(Icons.assignment),
                text: ClassDetailStrings.tasksTab,
              ),
              Tab(
                icon: Icon(Icons.people),
                text: ClassDetailStrings.studentsTab,
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: ClassDetailStrings.statisticsTab,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TeacherClassInfoTab(
              classId: widget.classId,
              classFuture: _classFuture,
              onRefreshRequested: _refreshClassDetails,
              activeTasksCount: _mockActiveTasksCount,
            ),
            ClassTasksTab(classId: widget.classId),
            ManageStudentsTab(classId: widget.classId),
            ClassStatisticsTab(classId: widget.classId, isTeacher: true),
          ],
        ),
      ),
    );
  }
}

class TeacherClassInfoTab extends StatefulWidget {
  const TeacherClassInfoTab({
    super.key,
    required this.classId,
    required this.classFuture,
    required this.onRefreshRequested,
    this.activeTasksCount,
  });

  final String classId;
  final Future<ClassModel?> classFuture;
  final Future<void> Function() onRefreshRequested;
  final int? activeTasksCount;

  @override
  State<TeacherClassInfoTab> createState() => _TeacherClassInfoTabState();
}

class _TeacherClassInfoTabState extends State<TeacherClassInfoTab> {
  ClassModel? _lastClassModel;
  String? _teacherProfileOwnerId;
  Future<TeacherModel?>? _teacherProfileFuture;
  bool _isStatusLoading = false;
  bool _isDeletingClass = false;

  Future<void> _refreshClassAndMembers() async {
    await Future.wait([
      widget.onRefreshRequested(),
      context.read<MembershipCubit>().loadMembers(
        classId: widget.classId,
        refresh: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel?>(
      future: widget.classFuture,
      builder: (context, snapshot) {
        final hasError = snapshot.hasError;
        if (snapshot.hasData) {
          _lastClassModel = snapshot.data;
        }
        final classModel = snapshot.data ?? _lastClassModel;

        if (classModel == null) {
          if (hasError) {
            return Center(
              child: SelectableText.rich(
                TextSpan(
                  text: ClassesStrings.classGenericError,
                  style: context.bodyMediumOnSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshClassAndMembers,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              BlocBuilder<MembershipCubit, MembershipState>(
                builder: (context, state) {
                  final studentsCount = switch (state) {
                    MembershipListSuccess(:final members) =>
                      members.where((member) => member.isActive).length,
                    MembershipEmpty() => 0,
                    _ => null,
                  };
                  return TeacherClassOverviewCard(
                    classModel: classModel,
                    studentsCount: studentsCount,
                    activeTasksCount: widget.activeTasksCount,
                    showStudentsHint: false,
                    onCopyCode: (code) => _copyAccessCode(context, code),
                    onRegenerateCode: () =>
                        _regenerateAccessCode(widget.classId),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.m),
              _ClassInformationSection(classModel: classModel),
              const SizedBox(height: AppSpacing.m),
              FutureBuilder<TeacherModel?>(
                future: _getTeacherProfileFuture(classModel.ownerTeacherId),
                builder: (context, snapshot) {
                  final teacher = snapshot.data;
                  return _TeacherInformationSection(
                    teacherId: classModel.ownerTeacherId,
                    teacherName: teacher?.fullName,
                    teacherEmail: teacher?.email,
                    isClassActive: classModel.isActive,
                    isStatusLoading: _isStatusLoading,
                    isDeleteLoading: _isDeletingClass,
                    onToggleStatus: () => _handleToggleClassStatus(classModel),
                    onDeleteClass: () => _handleDeleteClass(classModel),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<TeacherModel?> _getTeacherProfileFuture(String teacherId) {
    if (_teacherProfileFuture != null && _teacherProfileOwnerId == teacherId) {
      return _teacherProfileFuture!;
    }
    final future = context.read<AuthRepository>().getTeacherProfile(teacherId);
    _teacherProfileOwnerId = teacherId;
    _teacherProfileFuture = future;
    return future;
  }

  Future<void> _handleToggleClassStatus(ClassModel classModel) async {
    setState(() => _isStatusLoading = true);
    final repository = context.read<ClassRepository>();
    final targetState = !classModel.isActive;
    try {
      await repository.updateClassStatus(
        classId: classModel.id,
        isActive: targetState,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ClassesStrings.classStatusUpdatedSuccess)),
      );
      await widget.onRefreshRequested();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ClassesStrings.classGenericError),
          backgroundColor: context.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStatusLoading = false);
      }
    }
  }

  Future<void> _handleDeleteClass(ClassModel classModel) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(ClassesStrings.deleteClassAction),
            content: Text(ClassesStrings.deleteClassConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(CommonStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  foregroundColor: context.colorScheme.onError,
                ),
                child: Text(CommonStrings.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _isDeletingClass = true);
    final repository = context.read<ClassRepository>();
    try {
      await repository.deleteClassPermanent(classModel.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ClassesStrings.classDeleteSuccess)),
      );
      context.go(AppRoutes.teacherClassesList);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ClassesStrings.classGenericError),
          backgroundColor: context.colorScheme.error,
        ),
      );
      setState(() => _isDeletingClass = false);
    }
  }

  void _copyAccessCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(CommonStrings.copied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _regenerateAccessCode(String classId) async {
    final shouldRegenerate =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(ClassesStrings.regenerateAccessCodeAction),
            content: Text(ClassesStrings.regenerateCodeConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(CommonStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(CommonStrings.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !shouldRegenerate) {
      return;
    }
    await context.read<MembershipCubit>().regenerateAccessCode(classId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ClassesStrings.membershipRegenerateSuccess)),
    );
    await widget.onRefreshRequested();
  }
}

class ManageStudentsTab extends StatelessWidget {
  const ManageStudentsTab({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return ManageStudentsView(
      classId: classId,
      showOverview: false,
      showStudentsHint: false,
    );
  }
}

class _ClassInformationSection extends StatelessWidget {
  const _ClassInformationSection({required this.classModel});

  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateFormat(
      'dd/MM/yyyy – HH:mm',
    ).format(classModel.createdAt.toDate());
    final statusLabel = classModel.canJoin
        ? ClassesStrings.classStatusActive
        : ClassesStrings.classStatusArchived;

    return CustomCard(
      title: ClassDetailStrings.classInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: ClassesStrings.classNameLabel,
            value: classModel.name,
          ),
          _InfoRow(
            label: ClassesStrings.classDescriptionLabel,
            value:
                classModel.description ?? ClassesStrings.classDescriptionHint,
          ),
          _InfoRow(label: ClassesStrings.classStatusActive, value: statusLabel),
          _InfoRow(label: ClassDetailStrings.created, value: createdAt),
          _InfoRow(
            label: ClassesStrings.accessCodeValueLabel,
            value: classModel.accessCode,
          ),
        ],
      ),
    );
  }
}

class _TeacherInformationSection extends StatelessWidget {
  const _TeacherInformationSection({
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.isClassActive,
    required this.isStatusLoading,
    required this.isDeleteLoading,
    required this.onToggleStatus,
    required this.onDeleteClass,
  });

  final String teacherId;
  final String? teacherName;
  final String? teacherEmail;
  final bool isClassActive;
  final bool isStatusLoading;
  final bool isDeleteLoading;
  final VoidCallback onToggleStatus;
  final VoidCallback onDeleteClass;

  @override
  Widget build(BuildContext context) {
    final displayName = teacherName?.isNotEmpty == true
        ? teacherName!
        : '${ClassesStrings.teacherLabel}$teacherId';
    final displayEmail = teacherEmail?.isNotEmpty == true ? teacherEmail! : '—';

    return CustomCard(
      title: ClassDetailStrings.teacherInfo,
      subtitle: displayName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ClassDetailStrings.email}: $displayEmail',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${StudentStrings.studentIdLabel}: $teacherId',
            style: context.bodySmallOnSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: (isStatusLoading || isDeleteLoading)
                      ? null
                      : onToggleStatus,
                  child: isStatusLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isClassActive
                              ? ClassesStrings.archiveClassAction
                              : ClassesStrings.activateClassAction,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: FilledButton(
                  onPressed: (isDeleteLoading || isStatusLoading)
                      ? null
                      : onDeleteClass,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.error,
                    foregroundColor: context.colorScheme.onError,
                  ),
                  child: isDeleteLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(ClassesStrings.deleteClassAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: context.bodySmallOnSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            flex: 3,
            child: Text(value, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
