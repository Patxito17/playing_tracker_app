import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_wrapper.dart';

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

  // Estado de carga (mock)
  bool _isLoading = false;

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
      _firstNameError = Validators.name(value, 'El nombre');
    });
  }

  /// Valida el campo de apellidos
  void _validateLastName(String value) {
    setState(() {
      _lastNameError = Validators.name(value, 'Los apellidos');
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

    // Validar términos aceptados
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los términos y condiciones'),
          backgroundColor: context.colorScheme.error,
        ),
      );
      return;
    }

    // Si hay errores, no continuar
    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    // Mock: establecer rol y navegar
    setState(() {
      _isLoading = true;
    });

    // Simular carga (mock)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AuthWrapper.mockRole = _selectedRole;
        context.go(
          _selectedRole == 'teacher' ? '/home/teacher' : '/home/student',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Crear Cuenta'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título principal
              Text(
                'Crea tu cuenta',
                style: context.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Completa el formulario para registrarte',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Selector de rol
              Text(
                'Tipo de cuenta',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'teacher',
                    label: Text('Docente'),
                    icon: Icon(Icons.school_outlined),
                  ),
                  ButtonSegment<String>(
                    value: 'student',
                    label: Text('Alumno'),
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
                label: 'Nombre',
                hint: 'Ingresa tu nombre',
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
                label: 'Apellidos',
                hint: 'Ingresa tus apellidos',
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
                label: 'Email',
                hint: 'usuario@ejemplo.com',
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
                label: 'Contraseña',
                hint: 'Mínimo 6 caracteres',
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
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
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
                    _validateConfirmPassword(_confirmPasswordController.text);
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
                label: 'Confirmar Contraseña',
                hint: 'Repite tu contraseña',
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
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  tooltip: _obscureConfirmPassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
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
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _termsAccepted = !_termsAccepted;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.s),
                        child: RichText(
                          text: TextSpan(
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: 'Acepto los '),
                              TextSpan(
                                text: 'términos y condiciones',
                                style: TextStyle(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' y la '),
                              TextSpan(
                                text: 'política de privacidad',
                                style: TextStyle(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
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
                label: 'Registrarse',
                variant: CustomButtonVariant.filled,
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),

              const SizedBox(height: AppSpacing.m),

              // Link a login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Inicia sesión',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
