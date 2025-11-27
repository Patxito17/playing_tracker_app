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
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/value_objects/create_class_input.dart';
import '../cubit/class_cubit.dart';
import '../cubit/class_state.dart';

/// Pantalla para crear una clase conectada al [ClassCubit].
class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _nameError;
  String? _descriptionError;
  String? _formError;
  String? _successMessage;
  Timer? _autoPopTimer;
  bool _navigationScheduled = false;

  @override
  void dispose() {
    _autoPopTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Valida campos básicos del formulario usando strings centralizados.
  bool _validateFields() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    String? nameError;
    String? descriptionError;

    if (name.isEmpty) {
      nameError = ValidationStrings.required(ClassesStrings.classNameLabel);
    } else if (name.length < 3) {
      nameError = ValidationStrings.nameMinLength(
        ClassesStrings.classNameLabel,
      );
    }

    if (description.isEmpty) {
      descriptionError = ValidationStrings.required(
        ClassesStrings.classDescriptionLabel,
      );
    }

    setState(() {
      _nameError = nameError;
      _descriptionError = descriptionError;
      if (nameError == null && descriptionError == null) {
        _formError = null;
      }
    });

    return nameError == null && descriptionError == null;
  }

  Future<void> _handleCreate() async {
    FocusScope.of(context).unfocus();
    if (!_validateFields()) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _formError = ClassesStrings.classGenericError;
      });
      return;
    }

    final input = (
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      ownerId: authState.userId,
    );

    try {
      validateCreateClassInput(input);
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

    await context.read<ClassCubit>().createClass(input);
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _nameError = null;
      _descriptionError = null;
      _formError = null;
    });
  }

  String _resolveErrorMessage(ClassState state) {
    if (state is ClassError) {
      return state.message;
    }
    return _formError ?? '';
  }

  bool _shouldDisplayError(ClassState state) =>
      _formError != null || state is ClassError;

  bool _isFormValid() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    return name.length >= 3 && description.isNotEmpty;
  }

  void _handleSuccess(ClassActionSuccess state) {
    setState(() {
      _successMessage = state.message ?? ClassesStrings.classCreateSuccess;
      _formError = null;
    });
    _clearForm();
    if (!mounted || _navigationScheduled) {
      return;
    }
    _navigationScheduled = true;
    _autoPopTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.go(AppRoutes.teacherClassesList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ClassesStrings.createClass),
      body: BlocConsumer<ClassCubit, ClassState>(
        listenWhen: (previous, current) =>
            current is ClassActionSuccess || current is ClassError,
        listener: (context, state) {
          if (state is ClassActionSuccess &&
              state.action == ClassAction.created) {
            _handleSuccess(state);
          }
          if (state is ClassError) {
            if (!mounted) return;
            setState(() {
              _formError = state.message;
            });
          }
        },
        buildWhen: (previous, current) => current is! ClassActionSuccess,
        builder: (context, state) {
          final isLoading = state is ClassLoading;
          final showError = !isLoading && _shouldDisplayError(state);
          final errorText = _resolveErrorMessage(state);
          final hasSuccess = _successMessage != null;
          final isFormValid = _isFormValid();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ClassesStrings.createClassTitle,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.l),
                CustomTextField(
                  controller: _nameController,
                  label: ClassesStrings.classNameLabel,
                  hint: ClassesStrings.classNameHint,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                CustomTextField(
                  controller: _descriptionController,
                  label: ClassesStrings.classDescriptionLabel,
                  hint: ClassesStrings.classDescriptionHint,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  errorText: _descriptionError,
                  onChanged: (_) {
                    if (_descriptionError != null) {
                      setState(() => _descriptionError = null);
                    }
                    setState(() {});
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
                          '••••••',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: ClassesStrings.accessCodeGenerated,
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                if (showError) ...[
                  const SizedBox(height: AppSpacing.l),
                  SelectableText.rich(
                    TextSpan(
                      text: errorText,
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
                  label: ClassesStrings.createClassButton,
                  variant: CustomButtonVariant.filled,
                  icon: Icons.add,
                  onPressed: (isLoading || !isFormValid) ? null : _handleCreate,
                  isLoading: isLoading,
                ),
              ],
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
