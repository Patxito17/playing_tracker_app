import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/enums/user_role.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Pantalla de inicio de sesión
///
/// Implementa un formulario completo de login con validación visual básica,
/// toggle para mostrar/ocultar contraseña y diseño Material Design 3.
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

  // Estados de carga independientes para evitar spinners redundantes
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isEmailLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      _obscurePassword = true; // No es necesario, pero lo mantenemos si estaba
      _passwordError = Validators.password(
        value,
        requiredMsg: context.l10n.passwordRequired,
        minLengthMsg: context.l10n.passwordMinLength,
      );
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

    setState(() => _isEmailLoading = true);
    context.read<AuthCubit>().loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.surface,
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is! AuthLoading) {
                      setState(() {
                        _isGoogleLoading = false;
                        _isAppleLoading = false;
                        _isEmailLoading = false;
                      });
                    }

                    if (state is AuthAuthenticated) {
                      final destination = state.role == UserRole.teacher
                          ? AppRoutes.teacherHome
                          : AppRoutes.studentHome;
                      if (!mounted) {
                        return;
                      }
                      context.go(destination);
                    }
                    if (state is AuthProfileIncomplete) {
                      if (!mounted) return;
                      context.go(
                        AppRoutes.completeProfile,
                        extra: {
                          'email': state.email,
                          'displayName': state.displayName,
                        },
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    final errorMessage = state is AuthError
                        ? state.message
                        : null;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: context.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image(
                                image: AssetImage("assets/images/logo.png"),
                                height: 100,
                              ),
                              const SizedBox(height: AppSpacing.l),
                              Text(
                                context.l10n.welcomeTitle,
                                style: context.displaySmallBold,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                context.l10n.loginSubtitle,
                                style: context.bodyLargeOnSurfaceVariant,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              if (errorMessage != null) ...[
                                Semantics(
                                  label: context.l10n.loginErrorSemanticLabel,
                                  liveRegion: true,
                                  child: SelectableText.rich(
                                    TextSpan(
                                      text: context.translateError(
                                        errorMessage,
                                      ),
                                      style: context.bodyMediumOnSurface
                                          ?.copyWith(
                                            color: context.colorScheme.error,
                                          ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.l),
                              ],
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
                                  if (_emailError != null) {
                                    setState(() {
                                      _emailError = null;
                                    });
                                  }
                                },
                                onSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              CustomTextField(
                                controller: _passwordController,
                                label: context.l10n.passwordLabel,
                                hint: context.l10n.passwordHint,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                autofillHints: const [AutofillHints.password],
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
                                  if (_passwordError != null) {
                                    setState(() {
                                      _passwordError = null;
                                    });
                                  }
                                },
                                onSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  child: Text(
                                    context.l10n.forgotPasswordLink,
                                    style: context.textPrimary?.copyWith(
                                      fontSize:
                                          context.textTheme.bodySmall?.fontSize,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              CustomButton(
                                label: context.l10n.loginButton,
                                variant: CustomButtonVariant.filled,
                                isLoading: _isEmailLoading,
                                onPressed: isLoading ? null : _handleLogin,
                              ),
                              const SizedBox(height: AppSpacing.l),

                              // Separador OAuth
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s,
                                    ),
                                    child: Text(
                                      context.l10n.orDivider,
                                      style: context.bodyMediumOnSurfaceVariant,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.l),

                              // Botón de Google Sign-In
                              CustomButton(
                                label: context.l10n.continueWithGoogle,
                                variant: CustomButtonVariant.outlined,
                                isLoading: _isGoogleLoading,
                                prefixWidget: Image.asset(
                                  'assets/icons/google_logo.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.login, size: 20),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() => _isGoogleLoading = true);
                                        context
                                            .read<AuthCubit>()
                                            .signInWithGoogle();
                                      },
                              ),

                              // Botón de Apple Sign-In (solo iOS)
                              if (Theme.of(context).platform ==
                                  TargetPlatform.iOS) ...[
                                const SizedBox(height: AppSpacing.l),
                                CustomButton(
                                  label: context.l10n.continueWithApple,
                                  variant: CustomButtonVariant.outlined,
                                  isLoading: _isAppleLoading,
                                  prefixWidget: const Icon(
                                    Icons.apple,
                                    size: 24,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          setState(
                                            () => _isAppleLoading = true,
                                          );
                                          context
                                              .read<AuthCubit>()
                                              .signInWithApple();
                                        },
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.noAccountQuestion,
                                    style: context.bodyMediumOnSurfaceVariant,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.push(AppRoutes.register),
                                    child: Text(
                                      context.l10n.registerLink,
                                      style: context.textPrimary?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context
                                            .textTheme
                                            .bodyMedium
                                            ?.fontSize,
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
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
