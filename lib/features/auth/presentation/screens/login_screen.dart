import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_wrapper.dart';

/// Pantalla de inicio de sesión
///
/// Implementa un formulario completo de login con validación visual básica,
/// toggle para mostrar/ocultar contraseña y diseño Material Design 3.
///
/// Sprint 0 - Fase 5: UI completa implementada (sin lógica de autenticación real)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estados de validación
  String? _emailError;
  String? _passwordError;

  // Estado para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  // Estado de carga (mock)
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    });
  }

  /// Maneja el submit del formulario
  void _handleLogin() {
    // Validar ambos campos
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    // Si hay errores, no continuar
    if (_emailError != null || _passwordError != null) {
      return;
    }

    // Mock: establecer rol como teacher para probar navegación
    setState(() {
      _isLoading = true;
    });

    // Simular carga (mock)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AuthWrapper.mockRole = 'teacher';
        context.go('/home/teacher');
      }
    });
  }

  /// Maneja el login como alumno (mock)
  void _handleLoginAsStudent() {
    // Mock: establecer rol como student para probar navegación
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AuthWrapper.mockRole = 'student';
        context.go('/home/student');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Iniciar Sesión'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaciado superior
              SizedBox(height: context.screenHeight * 0.1),

              // Título principal
              Text(
                'Bienvenido',
                style: context.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Inicia sesión para continuar',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

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
                  // Mover foco al campo de contraseña
                  FocusScope.of(context).nextFocus();
                },
              ),

              const SizedBox(height: AppSpacing.l),

              // Campo de contraseña
              CustomTextField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: 'Ingresa tu contraseña',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
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
                },
                onSubmitted: (_) => _handleLogin(),
              ),

              const SizedBox(height: AppSpacing.s),

              // Link a recuperación de contraseña
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Botón de login
              CustomButton(
                label: 'Iniciar Sesión',
                variant: CustomButtonVariant.filled,
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: AppSpacing.m),

              // Botón de login como alumno (mock)
              CustomButton(
                label: 'Iniciar como Alumno (Mock)',
                variant: CustomButtonVariant.outlined,
                isLoading: _isLoading,
                onPressed: _handleLoginAsStudent,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Link a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'Regístrate',
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
