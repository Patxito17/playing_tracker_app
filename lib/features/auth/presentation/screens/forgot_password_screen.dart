import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';

/// Pantalla de recuperación de contraseña
///
/// Implementa un formulario para solicitar recuperación de contraseña
/// con validación visual básica y mensaje informativo claro.
///
/// Sprint 0 - Fase 5: UI completa implementada (sin lógica de autenticación real)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controlador de texto
  final _emailController = TextEditingController();

  // Estado de validación
  String? _emailError;

  // Estado de carga (mock)
  bool _isLoading = false;

  // Estado de confirmación enviada
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Valida el campo de email
  void _validateEmail(String value) {
    setState(() {
      _emailError = Validators.email(value);
    });
  }

  /// Maneja el envío del formulario
  void _handleSendEmail() {
    // Validar email
    _validateEmail(_emailController.text);

    // Si hay error, no continuar
    if (_emailError != null) {
      return;
    }

    // Mock: simular envío de email
    setState(() {
      _isLoading = true;
    });

    // Simular carga (mock)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Recuperar Contraseña'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaciado superior
              SizedBox(height: context.screenHeight * 0.1),

              // Icono ilustrativo
              Icon(
                Icons.lock_reset_outlined,
                size: 80,
                color: context.colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Título principal
              Text(
                '¿Olvidaste tu contraseña?',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.m),

              // Mensaje informativo
              if (!_emailSent)
                Text(
                  'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                // Mensaje de confirmación
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Email enviado',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'Revisa tu bandeja de entrada. Si no encuentras el email, verifica tu carpeta de spam.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              if (!_emailSent) ...[
                const SizedBox(height: AppSpacing.xxl),

                // Campo de email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'usuario@ejemplo.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
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
                  onSubmitted: (_) => _handleSendEmail(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Botón de envío
                CustomButton(
                  label: 'Enviar enlace de recuperación',
                  variant: CustomButtonVariant.filled,
                  isLoading: _isLoading,
                  onPressed: _handleSendEmail,
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Link para volver al login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Recordaste tu contraseña? ',
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
