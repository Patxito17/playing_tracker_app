import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../classes/domain/models/class_model.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../classes/presentation/cubit/class_cubit.dart';
import '../../../classes/presentation/cubit/class_state.dart';
import '../../../classes/presentation/cubit/membership_cubit.dart';
import '../../../classes/presentation/cubit/membership_state.dart';
import '../../domain/models/attachment_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';

/// Pantalla para crear una tarea conectada al [TaskCubit].
///
/// Permite al docente crear una nueva tarea con título, descripción y duración
/// sugerida. En esta fase los destinatarios y adjuntos se mantienen como UI
/// placeholder a la espera de la integración completa con clases y Storage.
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final Set<String> _selectedClasses = {};
  final Set<String> _selectedStudentIds =
      {}; // IDs de alumnos seleccionados (vacío = todos)
  final List<String> _attachments = [];
  DateTime? _dueDate;
  String? _formError;
  String? _successMessage;

  Timer? _autoPopTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<ClassCubit>().watchClasses(teacherId: authState.userId);
      }
    });
  }

  @override
  void dispose() {
    _autoPopTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  /// Construye y envía el [CreateTaskInput] al [TaskCubit].
  Future<void> _handleCreate() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _formError = TaskStrings.taskGenericError;
      });
      return;
    }

    // En teoría el formulario ya fue validado y el valor debe ser un entero
    // positivo, pero usamos int.tryParse por seguridad ante cambios de última
    // hora en el campo entre la validación y este punto.
    final minutes = int.tryParse(_estimatedTimeController.text.trim());
    if (minutes == null || minutes <= 0) {
      setState(() {
        _formError = 'El tiempo estimado debe ser un número entero mayor que 0';
      });
      return;
    }

    final input = (
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: authState.userId,
      durationSuggested: minutes * 60,
      attachments: const <AttachmentModel>[],
      dueDate: _dueDate,
    );

    try {
      validateCreateTaskInput(input);
    } on ArgumentError catch (error) {
      setState(() {
        _formError = error.message;
      });
      return;
    }

    if (_selectedClasses.isEmpty) {
      setState(() {
        _formError = ValidationStrings.atLeastOneClassRequired;
      });
      return;
    }

    // Verificar que todas las clases seleccionadas tengan al menos un alumno
    // para evitar crear tareas "huérfanas" sin asignaciones.
    final classRepo = context.read<ClassRepository>();
    for (final classId in _selectedClasses) {
      try {
        final membersPage = await classRepo.listClassMembers(
          classId: classId,
          limit: 1,
        );
        if (membersPage.members.isEmpty) {
          if (!mounted) return;
          setState(() {
            _formError = TaskStrings.noStudentsInClassError;
          });
          return;
        }
      } catch (e) {
        // Si hay error al verificar, mejor prevenir la creación
        if (!mounted) return;
        setState(() {
          _formError = TaskStrings.taskGenericError;
        });
        return;
      }
    }

    await context.read<TaskCubit>().createTask(input);
  }

  /// Limpia solo los campos del formulario sin borrar el mensaje de éxito.
  /// Útil cuando queremos mantener el feedback visual del éxito mientras
  /// limpiamos los campos para una nueva entrada.
  void _clearFormFields() {
    // Verificar que el widget esté montado antes de modificar el estado
    if (!mounted) {
      return;
    }
    _titleController.clear();
    _descriptionController.clear();
    _estimatedTimeController.clear();
    setState(() {
      _formError = null;
      // NO borramos _successMessage aquí para que el banner se pueda mostrar
      _dueDate = null;
    });
  }

  /// Maneja el estado de éxito tras crear una tarea.
  void _handleSuccess(TaskActionSuccess state) {
    // Verificar que el widget esté montado antes de cualquier modificación de estado
    if (!mounted) {
      return;
    }

    // Si la acción fue crear, y tenemos clases seleccionadas, asignamos.
    if (state.action == TaskAction.created &&
        state.taskId != null &&
        _selectedClasses.isNotEmpty) {
      final authState = context.read<AuthCubit>().state;
      final teacherId = authState is AuthAuthenticated ? authState.userId : '';

      if (teacherId.isNotEmpty) {
        for (final classId in _selectedClasses) {
          // Si solo hay una clase seleccionada, usamos la selección granular de alumnos.
          // Si hay varias, se asigna a todos (studentIds: null o vacío).
          final studentIds = (_selectedClasses.length == 1)
              ? _selectedStudentIds.toList()
              : null;

          context.read<TaskCubit>().assignTaskToClass((
            taskId: state.taskId!,
            classId: classId,
            teacherId: teacherId,
            studentIds: studentIds,
          ));
        }
      }
    } else if (state.action == TaskAction.assigned) {
      // Opcional: Mostrar feedback específico de asignación,
      // pero por ahora el mensaje genérico de éxito es suficiente.
    }

    setState(() {
      _successMessage = state.message ?? TaskStrings.taskCreateSuccess;
      _formError = null;
    });

    _clearFormFields();

    // Si es creación, cerramos la pantalla.
    // Si llegan eventos de asignación después, ya estaremos saliendo o fuera.
    if (state.action == TaskAction.created) {
      _autoPopTimer?.cancel();
      _autoPopTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.taskList);
        }
      });
    }
  }

  void _toggleClass(String classId) {
    setState(() {
      if (_selectedClasses.contains(classId)) {
        _selectedClasses.remove(classId);
      } else {
        _selectedClasses.add(classId);
      }
      // Al cambiar la selección de clases, reseteamos la selección de alumnos
      // para evitar inconsistencias.
      _selectedStudentIds.clear();
    });
  }

  void _showStudentSelectionModal(BuildContext context, String classId) {
    // Capturamos el cubit del contexto padre antes de abrir el modal
    final membershipCubit = context.read<MembershipCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BlocProvider.value(
        value: membershipCubit,
        child: _StudentSelectionModal(
          classId: classId,
          initialSelectedIds: _selectedStudentIds,
          onSelectionChanged: (selectedIds) {
            setState(() {
              _selectedStudentIds.clear();
              _selectedStudentIds.addAll(selectedIds);
            });
          },
        ),
      ),
    );
  }

  void _toggleAllClasses(List<String> allClasses) {
    setState(() {
      if (_selectedClasses.length == allClasses.length) {
        _selectedClasses.clear();
      } else {
        _selectedClasses.clear();
        _selectedClasses.addAll(allClasses);
      }
      _selectedStudentIds.clear();
    });
  }

  bool _isFormValid() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final minutes = int.tryParse(_estimatedTimeController.text.trim()) ?? 0;
    return title.length >= 3 &&
        description.isNotEmpty &&
        minutes > 0 &&
        _selectedClasses.isNotEmpty;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: TaskStrings.createTask),
      body: MultiBlocListener(
        listeners: [
          // Escucha original de TaskCubit
          BlocListener<TaskCubit, TaskState>(
            listenWhen: (previous, current) =>
                current is TaskActionSuccess || current is TaskError,
            listener: (context, state) {
              if (state is TaskActionSuccess) {
                _handleSuccess(state);
              }
              if (state is TaskError) {
                if (!mounted) return;
                setState(() {
                  _formError = state.message;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<TaskCubit, TaskState>(
          buildWhen: (previous, current) => current is! TaskActionSuccess,
          builder: (context, state) {
            final isLoading = state is TaskLoading;
            final hasSuccess = _successMessage != null;
            final isFormValid = _isFormValid();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      TaskStrings.newTaskTitle,
                      style: context.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: TaskStrings.taskTitleLabel,
                        hintText: TaskStrings.taskTitleHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return ValidationStrings.required(
                            TaskStrings.taskTitleLabel,
                          );
                        }
                        if (value.trim().length < 3) {
                          return ValidationStrings.nameMinLength(
                            TaskStrings.taskTitleLabel,
                          );
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() => _formError = null);
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: TaskStrings.taskDescriptionLabel,
                        hintText: TaskStrings.taskDescriptionHint,
                      ),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return ValidationStrings.required(
                            TaskStrings.taskDescriptionLabel,
                          );
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() => _formError = null);
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _estimatedTimeController,
                      decoration: InputDecoration(
                        labelText: TaskStrings.estimatedTimeLabel,
                        hintText: TaskStrings.estimatedTimeHint,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return ValidationStrings.required(
                            TaskStrings.estimatedTimeLabel,
                          );
                        }
                        final minutes = int.tryParse(text);
                        if (minutes == null || minutes <= 0) {
                          return 'El tiempo estimado debe ser un número entero mayor que 0';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() => _formError = null);
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: Text(TaskStrings.dueDate),
                      subtitle: Text(
                        _dueDate != null
                            ? '${_dueDate!.day.toString().padLeft(2, '0')}/'
                                  '${_dueDate!.month.toString().padLeft(2, '0')}/'
                                  '${_dueDate!.year}'
                            : TaskStrings.dueDateHint,
                      ),
                      onTap: _pickDueDate,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    // Bloque de selección de CLASES
                    BlocBuilder<ClassCubit, ClassState>(
                      builder: (context, classState) {
                        final classes = (classState is ClassSuccess)
                            ? classState.classes
                            : <ClassModel>[];

                        return CustomCard(
                          title: TaskStrings.selectClassToAssign,
                          subtitle: classes.isEmpty
                              ? 'Cargando o sin clases...'
                              : _selectedClasses.isEmpty
                              ? 'Obligatorio seleccionar al menos una clase'
                              : '${_selectedClasses.length} seleccionadas',
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Ensure min size
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Asignar a:',
                                      style: context.bodySmallOnSurfaceVariant,
                                    ),
                                  ),
                                  if (classes.isNotEmpty)
                                    TextButton(
                                      onPressed: () => _toggleAllClasses(
                                        classes.map((c) => c.id).toList(),
                                      ),
                                      child: Text(
                                        _selectedClasses.length ==
                                                classes.length
                                            ? TaskStrings.deselectAllStudents
                                            : TaskStrings.selectAllStudents,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.m),
                              if (classState is ClassLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (classes.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(AppSpacing.s),
                                  child: Text(
                                    'No se encontraron clases activas.',
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: AppSpacing.s,
                                  runSpacing: AppSpacing.s,
                                  children: classes.map((classModel) {
                                    final isSelected = _selectedClasses
                                        .contains(classModel.id);
                                    return FilterChip(
                                      label: Text(classModel.name),
                                      selected: isSelected,
                                      onSelected: (_) =>
                                          _toggleClass(classModel.id),
                                      avatar: isSelected
                                          ? const Icon(Icons.check, size: 18)
                                          : null,
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Bloque de selección de Alumnos (solo si hay 1 clase seleccionada)
                    if (_selectedClasses.length == 1) ...[
                      const SizedBox(height: AppSpacing.m),
                      CustomCard(
                        title: 'Alumnos destinatarios',
                        subtitle: _selectedStudentIds.isEmpty
                            ? 'Todos los alumnos de la clase'
                            : '${_selectedStudentIds.length} alumnos seleccionados',
                        margin: EdgeInsets.zero,
                        onTap: () => _showStudentSelectionModal(
                          context,
                          _selectedClasses.first,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Text(
                                _selectedStudentIds.isEmpty
                                    ? 'Asignar a todos'
                                    : 'Asignación personalizada',
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.m),
                    CustomCard(
                      title: TaskStrings.attachmentsLabel,
                      subtitle: _attachments.isEmpty
                          ? TaskStrings.noAttachments
                          : '${_attachments.length} archivos',
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TaskStrings.attachmentsHint,
                            style: context.bodySmallOnSurfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Placeholder: agregar adjunto
                            },
                            icon: const Icon(Icons.attach_file),
                            label: Text(TaskStrings.addAttachment),
                          ),
                          if (_attachments.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.m),
                            ..._attachments.map((attachment) {
                              return ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: Text(attachment),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    setState(() {
                                      _attachments.remove(attachment);
                                    });
                                  },
                                  tooltip: CommonStrings.delete,
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: AppSpacing.l),
                      SelectableText.rich(
                        TextSpan(
                          text: _formError!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (hasSuccess) ...[
                      const SizedBox(height: AppSpacing.l),
                      _SuccessBanner(message: _successMessage!),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      label: TaskStrings.createTaskButton,
                      variant: CustomButtonVariant.filled,
                      icon: Icons.add,
                      onPressed: (isLoading || !isFormValid)
                          ? null
                          : _handleCreate,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: context.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSelectionModal extends StatefulWidget {
  const _StudentSelectionModal({
    required this.classId,
    required this.initialSelectedIds,
    required this.onSelectionChanged,
  });

  final String classId;
  final Set<String> initialSelectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<_StudentSelectionModal> createState() => _StudentSelectionModalState();
}

class _StudentSelectionModalState extends State<_StudentSelectionModal> {
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
              Text('Seleccionar alumnos', style: context.textTheme.titleLarge),
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
                  return const Center(
                    child: Text('No hay alumnos activos en esta clase.'),
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
                                ? 'Deseleccionar todos'
                                : 'Seleccionar todos',
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
                        const Icon(Icons.error_outline, color: Colors.orange),
                        const SizedBox(height: AppSpacing.s),
                        const Text('Error al cargar alumnos'),
                        TextButton(
                          onPressed: () => _membershipCubit.loadMembers(
                            classId: widget.classId,
                            refresh: true,
                          ),
                          child: const Text('Reintentar'),
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
            child: const Text('Confirmar selección'),
          ),
        ],
      ),
    );
  }
}
