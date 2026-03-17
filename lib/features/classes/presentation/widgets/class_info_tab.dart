import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/models/class_model.dart';
import '../../domain/models/membership_model.dart';

/// Tab de información de la clase para estudiantes con datos reales.
class StudentClassInfoTab extends StatefulWidget {
  const StudentClassInfoTab({
    super.key,
    required this.classId,
    required this.classFuture,
    required this.onRefreshRequested,
    this.membership,
  });

  final String classId;
  final Future<ClassModel?> classFuture;
  final Future<void> Function() onRefreshRequested;
  final MembershipModel? membership;

  @override
  State<StudentClassInfoTab> createState() => _StudentClassInfoTabState();
}

class _StudentClassInfoTabState extends State<StudentClassInfoTab> {
  ClassModel? _lastClassModel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel?>(
      future: widget.classFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _lastClassModel = snapshot.data;
        }
        final classModel = snapshot.data ?? _lastClassModel;

        if (classModel == null) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText.rich(
                TextSpan(
                  text: context.l10n.classGenericError,
                  style: context.bodyMediumOnSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: widget.onRefreshRequested,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _ClassSummaryCard(
                classModel: classModel,
                membership: widget.membership,
                onCopyCode: () => _copyAccessCode(classModel.accessCode),
              ),
              const SizedBox(height: AppSpacing.m),
              _TeacherInformationCard(
                membership: widget.membership,
                teacherId: classModel.ownerTeacherId,
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyAccessCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copied),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ClassSummaryCard extends StatelessWidget {
  const _ClassSummaryCard({
    required this.classModel,
    required this.membership,
    required this.onCopyCode,
  });

  final ClassModel classModel;
  final MembershipModel? membership;
  final VoidCallback onCopyCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusLabel = classModel.canJoin
        ? context.l10n.classStatusActive
        : context.l10n.classStatusArchived;
    final statusColor = classModel.canJoin
        ? colorScheme.primary
        : colorScheme.outline;
    final createdAt = DateFormat(
      'dd/MM/yyyy – HH:mm',
    ).format(classModel.createdAt.toDate());
    final joinedAt = membership == null
        ? null
        : DateFormat(
            'dd/MM/yyyy – HH:mm',
          ).format(membership!.joinedAt.toDate());

    return CustomCard(
      title: classModel.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor.withValues(alpha: 0.16),
                labelStyle: TextStyle(color: statusColor),
              ),
              Chip(
                avatar: const Icon(Icons.event, size: 16),
                label: Text('${context.l10n.createdDateLabel}: $createdAt'),
              ),
              if (joinedAt != null)
                Chip(
                  avatar: const Icon(Icons.calendar_month, size: 16),
                  label: Text('${context.l10n.joinedAtLabel} $joinedAt'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            context.l10n.infoTab, // O classDescription
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            classModel.description?.trim().isNotEmpty == true
                ? classModel.description!
                : context.l10n.classGenericError, // O similar
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TeacherInformationCard extends StatelessWidget {
  const _TeacherInformationCard({
    required this.membership,
    required this.teacherId,
  });

  final MembershipModel? membership;
  final String teacherId;

  @override
  Widget build(BuildContext context) {
    final teacherName = membership?.teacherName?.trim();
    final teacherDisplayName = teacherName?.isNotEmpty == true
        ? teacherName
        : '${context.l10n.teacherLabel}$teacherId'; // O similar
    final teacherEmail = membership?.teacherEmail?.trim();
    final studentName = membership?.studentName?.trim();
    final studentDisplayName = studentName?.isNotEmpty == true
        ? studentName
        : membership?.studentId ?? '—';

    return CustomCard(
      title: context.l10n.infoTab, // O teacherInfo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.teacherLabel + teacherDisplayName!,
            style: context.bodyMediumOnSurface,
          ),
          Text(
            '${context.l10n.emailLabel}: $teacherEmail',
            style: context.bodyMediumOnSurface,
          ),
          Text(
            '${context.l10n.manageStudentsTitle}: $studentDisplayName', // O studentNameLabel
            style: context.bodyMediumOnSurface,
          ),
        ],
      ),
    );
  }
}
