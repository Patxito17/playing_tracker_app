import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';

/// Pantalla para unirse a una clase
///
/// Permite al estudiante unirse a una clase usando un código de acceso.
/// Sprint 0 - Fase 7: UI completa con Material Design 3
class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleJoin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Placeholder: unirse a clase
      // En Sprint 2, aquí se validará el código y se agregará el estudiante
      context.pop(); // Volver a la lista de clases después de unirse
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ClassesStrings.joinClass),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ClassesStrings.joinClassTitle,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            ClassesStrings.accessCodeInstructions,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: ClassesStrings.accessCodeLabel,
                  hintText: ClassesStrings.accessCodeHint,
                  counterText: '', // Ocultar contador
                ),
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ValidationStrings.required(
                      ClassesStrings.accessCodeLabel,
                    );
                  }
                  if (value.trim().length < 3) {
                    return 'El código debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: ClassesStrings.joinButton,
                variant: CustomButtonVariant.filled,
                icon: Icons.login,
                onPressed: _handleJoin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
