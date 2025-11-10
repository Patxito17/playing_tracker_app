import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla para crear una tarea
///
/// Permite al docente crear una nueva tarea con título, descripción,
/// tiempo estimado, destinatarios y adjuntos.
/// Sprint 0 - Fase 8: UI completa con Material Design 3
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

  // Datos mock de estudiantes disponibles
  final List<Map<String, String>> _availableStudents = [
    {'id': 'student1', 'name': 'Juan Pérez'},
    {'id': 'student2', 'name': 'María García'},
    {'id': 'student3', 'name': 'Carlos López'},
    {'id': 'student4', 'name': 'Ana Martínez'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState?.validate() ?? false) {
      // Placeholder: crear tarea
      // En Sprint 2, aquí se guardará en Firestore
      context.pop(); // Volver a la lista de tareas después de crear
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: TaskStrings.createTask),
      body: SingleChildScrollView(
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
              ),
              const SizedBox(height: AppSpacing.l),
              CustomCard(
                title: TaskStrings.recipientsLabel,
                subtitle:
                    '${_selectedRecipients.length} ${TaskStrings.selectedRecipients}',
                margin: EdgeInsets.zero, // Mismo ancho que los TextField
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
                          onSelected: (_) => _toggleRecipient(student['id']!),
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
                margin: EdgeInsets.zero, // Mismo ancho que los TextField
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
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: TaskStrings.createTaskButton,
                variant: CustomButtonVariant.filled,
                icon: Icons.add,
                onPressed: _handleCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
