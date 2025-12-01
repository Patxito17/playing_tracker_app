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
  final Set<String> _selectedRecipients = {};
  final List<String> _attachments = [];
  DateTime? _dueDate;
  String? _formError;
  String? _successMessage;
  Timer? _autoPopTimer;
  bool _navigationScheduled = false;

  // Datos mock de estudiantes disponibles
  final List<Map<String, String>> _availableStudents = [
    {'id': 'student1', 'name': 'Juan Pérez'},
    {'id': 'student2', 'name': 'María García'},
    {'id': 'student3', 'name': 'Carlos López'},
    {'id': 'student4', 'name': 'Ana Martínez'},
  ];

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

    // En este punto el formulario ya fue validado, por lo que el valor
    // debe ser un entero positivo. Usamos int.parse directamente.
    final minutes = int.parse(_estimatedTimeController.text.trim());

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

    setState(() {
      _formError = null;
      _successMessage = null;
    });

    await context.read<TaskCubit>().createTask(input);
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _estimatedTimeController.clear();
    setState(() {
      _formError = null;
      _successMessage = null;
      _dueDate = null;
    });
  }

  /// Maneja el estado de éxito tras crear una tarea.
  void _handleSuccess(TaskActionSuccess state) {
    setState(() {
      _successMessage = state.message ?? TaskStrings.taskCreateSuccess;
      _formError = null;
    });
    _clearForm();
    if (!mounted || _navigationScheduled) {
      return;
    }
    _navigationScheduled = true;
    _autoPopTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.go(AppRoutes.taskList);
    });
  }

  void _toggleRecipient(String studentId) {
    setState(() {
      if (_selectedRecipients.contains(studentId)) {
        _selectedRecipients.remove(studentId);
      } else {
        _selectedRecipients.add(studentId);
      }
    });
  }

  void _selectAllRecipients() {
    setState(() {
      _selectedRecipients.clear();
      _selectedRecipients.addAll(
        _availableStudents.map((s) => s['id']!).toList(),
      );
    });
  }

  void _deselectAllRecipients() {
    setState(() {
      _selectedRecipients.clear();
    });
  }

  bool _isFormValid() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final minutes = int.tryParse(_estimatedTimeController.text.trim()) ?? 0;
    return title.length >= 3 && description.isNotEmpty && minutes > 0;
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
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (previous, current) =>
            current is TaskActionSuccess || current is TaskError,
        listener: (context, state) {
          if (state is TaskActionSuccess &&
              state.action == TaskAction.created) {
            _handleSuccess(state);
          }
          if (state is TaskError) {
            if (!mounted) return;
            setState(() {
              _formError = state.message;
            });
          }
        },
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
                          : TaskStrings.estimatedTimeHint,
                    ),
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  CustomCard(
                    title: TaskStrings.recipientsLabel,
                    subtitle:
                        '${_selectedRecipients.length} ${TaskStrings.selectedRecipients}',
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                TaskStrings.recipientsHint,
                                style: context.bodySmallOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            TextButton(
                              onPressed: _selectAllRecipients,
                              child: Text(TaskStrings.selectAllStudents),
                            ),
                            TextButton(
                              onPressed: _deselectAllRecipients,
                              child: Text(TaskStrings.deselectAllStudents),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: _availableStudents.map((student) {
                            final isSelected = _selectedRecipients.contains(
                              student['id'],
                            );
                            return FilterChip(
                              label: Text(student['name']!),
                              selected: isSelected,
                              onSelected: (_) =>
                                  _toggleRecipient(student['id']!),
                              avatar: isSelected
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
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
