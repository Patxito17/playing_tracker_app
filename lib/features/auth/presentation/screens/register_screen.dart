import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/legal_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/enums/user_role.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/legal_consent_dialog.dart';

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

  /// Abre el [LegalConsentDialog] cargando el texto legal desde los assets.
  /// Si el usuario acepta, marca automáticamente el checkbox de términos.
  Future<void> _openLegalDialog() async {
    // Carga el texto según el idioma actual del contexto
    final locale = Localizations.localeOf(context).languageCode;
    final assetPath = locale == 'es'
        ? 'assets/legal/terms_es.md'
        : 'assets/legal/terms_en.md';

    String legalText;
    try {
      legalText = await rootBundle.loadString(assetPath);
    } catch (_) {
      // Fallback al español si no se encuentra el asset
      legalText = await rootBundle.loadString('assets/legal/terms_es.md');
    }

    if (!mounted) return;

    final accepted = await LegalConsentDialog.show(
      context,
      legalText: legalText,
      version: kCurrentTermsVersion,
    );

    if (accepted == true && mounted) {
      setState(() {
        _termsAccepted = true;
        _formError = null;
      });
    }
  }

  /// Valida el campo de nombre
  void _validateFirstName(String value) {
    setState(() {
      _firstNameError = Validators.name(
        value,
        requiredMsg: context.l10n.fieldRequired(context.l10n.firstNameField),
        minLengthMsg: context.l10n.nameMinLength(context.l10n.firstNameField),
        invalidCharactersMsg: context.l10n.nameInvalidCharacters(
          context.l10n.firstNameField,
        ),
      );
    });
  }

  /// Valida el campo de apellidos
  void _validateLastName(String value) {
    setState(() {
      _lastNameError = Validators.name(
        value,
        requiredMsg: context.l10n.fieldRequired(context.l10n.lastNameField),
        minLengthMsg: context.l10n.nameMinLength(context.l10n.lastNameField),
        invalidCharactersMsg: context.l10n.nameInvalidCharacters(
          context.l10n.lastNameField,
        ),
      );
    });
  }

  /// Valida el campo de email
  void _validateEmail(String value) {
    setState(() {
      _emailError = Validators.email(
        value,
        requiredMsg: context.l10n.emailRequired,
        invalidMsg: context.l10n.emailInvalidFormat,
      );
    });
  }

  /// Valida el campo de contraseña
  void _validatePassword(String value) {
    setState(() {
      _passwordError = Validators.password(
        value,
        requiredMsg: context.l10n.passwordRequired,
        minLengthMsg: context.l10n.passwordMinLength,
      );
      // Si hay confirmación, validarla también
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordError = Validators.confirmPassword(
          _passwordController.text,
          _confirmPasswordController.text,
          requiredMsg: context.l10n.confirmPasswordRequired,
          matchMsg: context.l10n.passwordsDoNotMatch,
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
        requiredMsg: context.l10n.confirmPasswordRequired,
        matchMsg: context.l10n.passwordsDoNotMatch,
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
        _formError = context.l10n.termsNotAcceptedMessage;
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
    // Solo se persiste la versión si el usuario ha aceptado (validación previa garantiza esto)
    final acceptedVersion = _termsAccepted ? kCurrentTermsVersion : null;

    if (_selectedRole == 'teacher') {
      cubit.registerTeacher(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        acceptedTermsVersion: acceptedVersion,
      );
    } else {
      cubit.registerStudent(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        acceptedTermsVersion: acceptedVersion,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.registerTitle),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    final destination = state.role == UserRole.teacher
                        ? AppRoutes.teacherHome
                        : AppRoutes.studentHome;
                    if (!mounted) {
                      return;
                    }
                    context.go(destination);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final cubitError = state is AuthError ? state.message : null;
                  final displayError = _formError ?? cubitError;

                  return AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título principal
                        Text(
                          context.l10n.createAccountTitle,
                          style: context.displaySmallBold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          context.l10n.createAccountSubtitle,
                          style: context.bodyLargeOnSurfaceVariant,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        if (displayError != null) ...[
                          Semantics(
                            label: context.l10n.registerErrorSemanticLabel,
                            liveRegion: true,
                            child: SelectableText.rich(
                              TextSpan(
                                text: displayError,
                                style: context.bodyMediumOnSurface?.copyWith(
                                  color: context.colorScheme.error,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                        ],

                        // Selector de rol
                        Text(
                          context.l10n.accountTypeLabel,
                          style: context.titleMediumBold,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment<String>(
                              value: 'teacher',
                              label: Text(context.l10n.teacherRole),
                              icon: Icon(Icons.school_outlined),
                            ),
                            ButtonSegment<String>(
                              value: 'student',
                              label: Text(context.l10n.studentRole),
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
                          label: context.l10n.firstNameLabel,
                          hint: context.l10n.firstNameHint,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
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
                          label: context.l10n.lastNameLabel,
                          hint: context.l10n.lastNameHint,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
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
                          label: context.l10n.emailLabel,
                          hint: context.l10n.emailHint,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          autofillHints: const [AutofillHints.email],
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
                          label: context.l10n.passwordLabel,
                          hint: context.l10n.passwordMinLengthHint,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          autofillHints: const [AutofillHints.newPassword],
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
                                ? context.l10n.showPassword
                                : context.l10n.hidePassword,
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
                          label: context.l10n.confirmPasswordLabel,
                          hint: context.l10n.confirmPasswordHint,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.none,
                          autofillHints: const [AutofillHints.newPassword],
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
                                ? context.l10n.showPassword
                                : context.l10n.hidePassword,
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
                            Checkbox.adaptive(
                              value: _termsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                  if (_termsAccepted) _formError = null;
                                });
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.s,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: context.bodySmallOnSurfaceVariant,
                                    children: [
                                      TextSpan(
                                        text: context.l10n.acceptTermsPrefix,
                                      ),
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: GestureDetector(
                                          onTap: _openLegalDialog,
                                          child: Text(
                                            context.l10n.termsAndConditions,
                                            style: context.textPrimary
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: context
                                                      .textTheme
                                                      .bodySmall
                                                      ?.fontSize,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: context.l10n.acceptTermsMiddle,
                                      ),
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: GestureDetector(
                                          onTap: _openLegalDialog,
                                          child: Text(
                                            context.l10n.privacyPolicy,
                                            style: context.textPrimary
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: context
                                                      .textTheme
                                                      .bodySmall
                                                      ?.fontSize,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Botón de registro
                        CustomButton(
                          label: context.l10n.registerButton,
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
                              context.l10n.alreadyHaveAccountQuestion,
                              style: context.bodyMediumOnSurfaceVariant,
                            ),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: Text(
                                context.l10n.loginLink,
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
                    ),
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
