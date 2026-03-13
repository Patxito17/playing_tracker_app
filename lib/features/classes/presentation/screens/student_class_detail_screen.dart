import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_tab_bar.dart';
import '../../../auth/domain/enums/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../statistics/data/repositories/statistics_repository_impl.dart';
import '../../../statistics/presentation/cubit/student_stats_cubit.dart';
import '../../domain/models/class_model.dart';
import '../../domain/models/membership_model.dart';
import '../../domain/repositories/class_repository.dart';
import '../widgets/class_info_tab.dart';
import '../widgets/class_statistics_tab.dart';
import '../widgets/student_class_tasks_tab.dart';

/// Pantalla de detalle de clase para estudiante
///
/// Ofrece 3 pestañas:
/// 1. Información general de la clase (código, docente, fechas)
/// 2. Tareas asignadas al alumno
/// 3. Estadísticas personales
class StudentClassDetailScreen extends StatefulWidget {
  const StudentClassDetailScreen({
    super.key,
    required this.classId,
    this.membership,
  });

  final String classId;
  final MembershipModel? membership;

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  late Future<ClassModel?> _classFuture;
  MembershipModel? _currentMembership;
  StreamSubscription<ClassModel?>? _classSubscription;
  StreamSubscription<List<MembershipModel>>? _membershipSubscription;
  bool _hasForcedExit = false;

  @override
  void initState() {
    super.initState();
    final repository = context.read<ClassRepository>();
    _classFuture = repository.getClassById(widget.classId);
    _currentMembership = widget.membership;
    _listenClassChanges();
    _listenMembershipChanges();
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    _membershipSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshClassDetails() async {
    final repository = context.read<ClassRepository>();
    setState(() {
      _classFuture = repository.getClassById(widget.classId);
    });
  }

  void _listenClassChanges() {
    _classSubscription = context
        .read<ClassRepository>()
        .watchClassById(widget.classId)
        .listen(
          (classModel) {
            if (!mounted || _hasForcedExit) {
              return;
            }
            if (classModel == null) {
              _handleForcedExit(
                AppLocalizations.of(context)!.classDeletedExitMessage,
              );
              return;
            }
            if (!classModel.isActive) {
              _handleForcedExit(
                AppLocalizations.of(context)!.classArchivedExitMessage,
              );
              return;
            }
            setState(() {
              _classFuture = Future.value(classModel);
            });
          },
          onError: (_) {
            if (!mounted || _hasForcedExit) {
              return;
            }
            _handleForcedExit(context.l10n.classGenericError);
          },
        );
  }

  void _listenMembershipChanges() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated ||
        authState.role != UserRole.student ||
        authState.userId.isEmpty) {
      return;
    }
    _membershipSubscription = context
        .read<ClassRepository>()
        .watchStudentMemberships(studentId: authState.userId)
        .listen(
          (memberships) {
            if (!mounted || _hasForcedExit) {
              return;
            }
            final membership = _findMembership(memberships);
            if (membership == null || !membership.isActive) {
              _handleForcedExit(
                AppLocalizations.of(context)!.membershipRevokedExitMessage,
              );
              return;
            }
            if (_currentMembership != membership) {
              setState(() {
                _currentMembership = membership;
              });
            }
          },
          onError: (_) {
            if (!mounted || _hasForcedExit) {
              return;
            }
            _handleForcedExit(context.l10n.classGenericError);
          },
        );
  }

  MembershipModel? _findMembership(List<MembershipModel> memberships) {
    for (final membership in memberships) {
      if (membership.classId == widget.classId) {
        return membership;
      }
    }
    return null;
  }

  void _handleForcedExit(String message) {
    if (_hasForcedExit || !mounted) {
      return;
    }
    _hasForcedExit = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    context.go(AppRoutes.studentClassesList);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is AuthAuthenticated ? authState.userId : '';

    return BlocProvider(
      create: (context) =>
          StudentStatsCubit(StatisticsRepositoryImpl())
            ..loadStats(studentId: studentId, classId: widget.classId),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.l10n.classDetailTitle,
              style: context.titleLargeBold?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.m),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
                tooltip: context.l10n.back,
              ),
            ),
            leadingWidth: 48 + AppSpacing.m,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: CustomTabBar(
              tabs: [
                Tab(
                  icon: const Icon(Icons.info_rounded),
                  text: context.l10n.infoTab,
                ),
                Tab(
                  icon: const Icon(Icons.assignment_rounded),
                  text: context.l10n.tasksTab,
                ),
                Tab(
                  icon: const Icon(Icons.bar_chart_rounded),
                  text: context.l10n.statisticsTab,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              StudentClassInfoTab(
                classId: widget.classId,
                classFuture: _classFuture,
                membership: _currentMembership,
                onRefreshRequested: _refreshClassDetails,
              ),
              StudentClassTasksTab(classId: widget.classId),
              ClassStatisticsTab(classId: widget.classId, isTeacher: false),
            ],
          ),
        ),
      ),
    );
  }
}
