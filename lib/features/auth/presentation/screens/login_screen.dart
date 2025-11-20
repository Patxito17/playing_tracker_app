import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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

    context.read<AuthCubit>().loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AuthStrings.loginTitle),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final errorMessage = state is AuthError
                      ? state.message
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Espaciado superior
                      SizedBox(height: context.screenHeight * 0.1),

                      // Título principal
                      Text(
                        AuthStrings.welcomeTitle,
                        style: context.displaySmallBold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        AuthStrings.loginSubtitle,
                        style: context.bodyLargeOnSurfaceVariant,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      if (errorMessage != null) ...[
                        SelectableText.rich(
                          TextSpan(
                            text: errorMessage,
                            style: context.bodyMediumOnSurface?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],

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
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                          }
                        },
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Campo de contraseña
                      CustomTextField(
                        controller: _passwordController,
                        label: AuthStrings.passwordLabel,
                        hint: AuthStrings.passwordHint,
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
                              ? CommonStrings.showPassword
                              : CommonStrings.hidePassword,
                        ),
                        onChanged: (value) {
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
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            AuthStrings.forgotPasswordLink,
                            style: context.textPrimary?.copyWith(
                              fontSize: context.textTheme.bodySmall?.fontSize,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Botón de login
                      CustomButton(
                        label: AuthStrings.loginButton,
                        variant: CustomButtonVariant.filled,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleLogin,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Link a registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AuthStrings.noAccountQuestion,
                            style: context.bodyMediumOnSurfaceVariant,
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: Text(
                              AuthStrings.registerLink,
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
