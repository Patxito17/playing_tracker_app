import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla para crear una clase
///
/// Permite al docente crear una nueva clase con nombre y descripción.
/// El código de acceso se genera automáticamente.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accessCode = 'ABC123'; // Mock: código generado automáticamente

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState?.validate() ?? false) {
      // Placeholder: crear clase
      // En Sprint 2, aquí se guardará en Firestore
      context.pop(); // Volver a la lista de clases después de crear
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ClassesStrings.createClass),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ClassesStrings.createClassTitle,
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: ClassesStrings.classNameLabel,
                  hintText: ClassesStrings.classNameHint,
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ValidationStrings.required(
                      ClassesStrings.classNameLabel,
                    );
                  }
                  if (value.trim().length < 3) {
                    return ValidationStrings.nameMinLength(
                      ClassesStrings.classNameLabel,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: ClassesStrings.classDescriptionLabel,
                  hintText: ClassesStrings.classDescriptionHint,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ValidationStrings.required(
                      ClassesStrings.classDescriptionLabel,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.l),
              CustomCard(
                title: ClassesStrings.accessCodeLabel,
                subtitle: ClassesStrings.accessCodeGenerated,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _accessCode,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () {
                        // Placeholder: copiar código
                      },
                      tooltip: CommonStrings.copy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: ClassesStrings.createClassButton,
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
