import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playing_tracker/core/constants/app_constants.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_cubit.dart';
import 'package:playing_tracker/features/classes/presentation/cubit/membership_state.dart';

class StudentSelectionModal extends StatefulWidget {
  const StudentSelectionModal({
    super.key,
    required this.classId,
    required this.initialSelectedIds,
    required this.onSelectionChanged,
  });

  final String classId;
  final Set<String> initialSelectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<StudentSelectionModal> createState() => _StudentSelectionModalState();
}

class _StudentSelectionModalState extends State<StudentSelectionModal> {
  late Set<String> _selectedIds;
  late MembershipCubit _membershipCubit;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
    _membershipCubit = context.read<MembershipCubit>();
    // Cargar miembros si es necesario
    _membershipCubit.loadMembers(classId: widget.classId);
  }

  void _toggleStudent(String studentId) {
    setState(() {
      if (_selectedIds.contains(studentId)) {
        _selectedIds.remove(studentId);
      } else {
        _selectedIds.add(studentId);
      }
    });
  }

  void _toggleAll(List<String> allIds) {
    setState(() {
      if (_selectedIds.length == allIds.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(allIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.selectStudentsTitle, style: context.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: BlocBuilder<MembershipCubit, MembershipState>(
              builder: (context, state) {
                if (state is MembershipLoading ||
                    state is MembershipListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MembershipEmpty) {
                  return Center(
                    child: Text(context.l10n.noActiveStudentsInClass),
                  );
                }

                if (state is MembershipListSuccess) {
                  final students = state.members
                      .where((m) => m.isActive) // Solo alumnos activos
                      .toList();

                  if (students.isEmpty) {
                    return const Center(
                      child: Text('No hay alumnos activos en esta clase.'),
                    );
                  }

                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _toggleAll(
                            students.map((s) => s.studentId).toList(),
                          ),
                          child: Text(
                            _selectedIds.length == students.length
                                ? context.l10n.deselectAllStudents
                                : context.l10n.selectAllStudents,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final isSelected = _selectedIds.contains(
                              student.studentId,
                            );
                            final displayName =
                                student.studentName ?? student.studentId;

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (_) =>
                                  _toggleStudent(student.studentId),
                              title: Text(displayName),
                              subtitle: student.studentEmail != null
                                  ? Text(student.studentEmail!)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is MembershipError || state is MembershipListError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: context.colorScheme.error),
                        const SizedBox(height: AppSpacing.s),
                        Text(context.l10n.errorLoadingStudents),
                        TextButton(
                          onPressed: () => _membershipCubit.loadMembers(
                            classId: widget.classId,
                            refresh: true,
                          ),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton(
            onPressed: () {
              widget.onSelectionChanged(_selectedIds);
              Navigator.pop(context);
            },
            child: Text(context.l10n.confirmSelectionButton),
          ),
        ],
      ),
    );
  }
}
