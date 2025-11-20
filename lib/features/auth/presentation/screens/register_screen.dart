import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Pantalla de registro
///
/// Implementa un formulario completo de registro con validación visual básica,
/// selector de rol (docente/alumno) y diseño Material Design 3.
///
/// Sprint 0 - Fase 5: UI completa implementada (sin lógica de autenticación real)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de validación
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Estado para mostrar/ocultar contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Rol seleccionado ('teacher' o 'student')
  String _selectedRole = 'teacher';

  // Checkbox de términos aceptados
  bool _termsAccepted = false;

  // Mensaje de error global (por ejemplo, términos no aceptados)
  String? _formError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida el campo de nombre
  void _validateFirstName(String value) {
    setState(() {
      _firstNameError = Validators.name(
        value,
        ValidationStrings.firstNameField,
      );
    });
  }

  /// Valida el campo de apellidos
  void _validateLastName(String value) {
    setState(() {
      _lastNameError = Validators.name(value, ValidationStrings.lastNameField);
    });
  }

  /// Valida el campo de email
  void _validateEmail(String value) {
    setState(() {
      _emailError = Validators.email(value);
    });
  }

  /// Valida el campo de contraseña
  void _validatePassword(String value) {
    setState(() {
      _passwordError = Validators.password(value);
      // Si hay confirmación, validarla también
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordError = Validators.confirmPassword(
          _passwordController.text,
          _confirmPasswordController.text,
        );
      }
    });
  }

  /// Valida el campo de confirmación de contraseña
  void _validateConfirmPassword(String value) {
    setState(() {
      _confirmPasswordError = Validators.confirmPassword(
        _passwordController.text,
        value,
      );
    });
  }

  /// Maneja el submit del formulario
  void _handleRegister() {
    // Validar todos los campos
    _validateFirstName(_firstNameController.text);
    _validateLastName(_lastNameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    // Validar términos aceptados con mensaje persistente
    if (!_termsAccepted) {
      setState(() {
        _formError = AuthStrings.termsNotAcceptedMessage;
      });
      return;
    }
    setState(() {
      _formError = null;
    });

    // Si hay errores, no continuar
    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    final cubit = context.read<AuthCubit>();
    if (_selectedRole == 'teacher') {
      cubit.registerTeacher(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      cubit.registerStudent(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AuthStrings.registerTitle),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final cubitError = state is AuthError ? state.message : null;
                  final displayError = _formError ?? cubitError;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título principal
                      Text(
                        AuthStrings.createAccountTitle,
                        style: context.displaySmallBold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        AuthStrings.createAccountSubtitle,
                        style: context.bodyLargeOnSurfaceVariant,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      if (displayError != null) ...[
                        SelectableText.rich(
                          TextSpan(
                            text: displayError,
                            style: context.bodyMediumOnSurface?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],

                      // Selector de rol
                      Text(
                        AuthStrings.accountTypeLabel,
                        style: context.titleMediumBold,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'teacher',
                            label: Text(AuthStrings.teacherRole),
                            icon: Icon(Icons.school_outlined),
                          ),
                          ButtonSegment<String>(
                            value: 'student',
                            label: Text(AuthStrings.studentRole),
                            icon: Icon(Icons.person_outline),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedRole = newSelection.first;
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Campo de nombre
                      CustomTextField(
                        controller: _firstNameController,
                        label: AuthStrings.firstNameLabel,
                        hint: AuthStrings.firstNameHint,
                        textInputAction: TextInputAction.next,
                        errorText: _firstNameError,
                        prefix: Icon(
                          Icons.person_outline,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (value) {
                          // Limpiar error al escribir
                          if (_firstNameError != null) {
                            setState(() {
                              _firstNameError = null;
                            });
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Campo de apellidos
                      CustomTextField(
                        controller: _lastNameController,
                        label: AuthStrings.lastNameLabel,
                        hint: AuthStrings.lastNameHint,
                        textInputAction: TextInputAction.next,
                        errorText: _lastNameError,
                        prefix: Icon(
                          Icons.person_outline,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (value) {
                          // Limpiar error al escribir
                          if (_lastNameError != null) {
                            setState(() {
                              _lastNameError = null;
                            });
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Campo de email
                      CustomTextField(
                        controller: _emailController,
                        label: AuthStrings.emailLabel,
                        hint: AuthStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        errorText: _emailError,
                        prefix: Icon(
                          Icons.email_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (value) {
                          // Limpiar error al escribir
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Campo de contraseña
                      CustomTextField(
                        controller: _passwordController,
                        label: AuthStrings.passwordLabel,
                        hint: AuthStrings.passwordMinLengthHint,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        errorText: _passwordError,
                        prefix: Icon(
                          Icons.lock_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          tooltip: _obscurePassword
                              ? CommonStrings.showPassword
                              : CommonStrings.hidePassword,
                        ),
                        onChanged: (value) {
                          // Limpiar error al escribir
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                          // Validar confirmación si ya tiene valor
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _validateConfirmPassword(
                              _confirmPasswordController.text,
                            );
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Campo de confirmación de contraseña
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: AuthStrings.confirmPasswordLabel,
                        hint: AuthStrings.confirmPasswordHint,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        errorText: _confirmPasswordError,
                        prefix: Icon(
                          Icons.lock_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          tooltip: _obscureConfirmPassword
                              ? CommonStrings.showPassword
                              : CommonStrings.hidePassword,
                        ),
                        onChanged: (value) {
                          // Limpiar error al escribir
                          if (_confirmPasswordError != null) {
                            setState(() {
                              _confirmPasswordError = null;
                            });
                          }
                        },
                        onSubmitted: (_) => _handleRegister(),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Checkbox de términos y condiciones
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                                if (_termsAccepted) {
                                  _formError = null;
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _termsAccepted = !_termsAccepted;
                                  if (_termsAccepted) {
                                    _formError = null;
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.s,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: context.bodySmallOnSurfaceVariant,
                                    children: [
                                      TextSpan(
                                        text: AuthStrings.acceptTermsPrefix,
                                      ),
                                      TextSpan(
                                        text: AuthStrings.termsAndConditions,
                                        style: context.textPrimary?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context
                                              .textTheme
                                              .bodySmall
                                              ?.fontSize,
                                        ),
                                      ),
                                      TextSpan(
                                        text: AuthStrings.acceptTermsMiddle,
                                      ),
                                      TextSpan(
                                        text: AuthStrings.privacyPolicy,
                                        style: context.textPrimary?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context
                                              .textTheme
                                              .bodySmall
                                              ?.fontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Botón de registro
                      CustomButton(
                        label: AuthStrings.registerButton,
                        variant: CustomButtonVariant.filled,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleRegister,
                      ),

                      const SizedBox(height: AppSpacing.m),

                      // Link a login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AuthStrings.alreadyHaveAccountQuestion,
                            style: context.bodyMediumOnSurfaceVariant,
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              AuthStrings.loginLink,
                              style: context.textPrimary?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    context.textTheme.bodyMedium?.fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
