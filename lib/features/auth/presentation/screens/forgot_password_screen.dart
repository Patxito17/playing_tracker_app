import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

/// Pantalla de recuperación de contraseña
///
/// Implementa un formulario para solicitar recuperación de contraseña
/// con validación visual básica y mensaje informativo claro.
/// Rediseñada con estética premium académica.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
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

  /// Maneja la solicitud de recuperación.
  void _handleSendEmail() {
    _validateEmail(_emailController.text);

    if (_emailError != null) {
      return;
    }

    context.read<ForgotPasswordCubit>().sendResetLink(
      _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(backgroundColor: Colors.transparent),
      body: Container(
        decoration: BoxDecoration(gradient: context.gradients.mainBackground),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ForgotPasswordLoading;
                    final emailSent = state is ForgotPasswordSuccess;
                    final errorMessage = state is ForgotPasswordError
                        ? state.message
                        : null;

                    return AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.lock_reset_rounded,
                            size: 100,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            context.l10n.forgotPasswordQuestion,
                            style: context.displaySmallBold,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          if (!emailSent)
                            Text(
                              context.l10n.forgotPasswordInstructions,
                              style: context.bodyLargeOnSurfaceVariant,
                              textAlign: TextAlign.center,
                            )
                          else
                            Semantics(
                              label: context
                                  .l10n
                                  .forgotPasswordSuccessSemanticLabel,
                              liveRegion: true,
                              child: AnimatedContainer(
                                duration: AppDurations.medium,
                                padding: const EdgeInsets.all(AppSpacing.l),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.large,
                                  ),
                                  border: Border.all(
                                    color: context.colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 64,
                                      color: context
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                    const SizedBox(height: AppSpacing.m),
                                    Text(
                                      context.l10n.emailSentTitle,
                                      style: context.titleLargeBold?.copyWith(
                                        color: context
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppSpacing.s),
                                    Text(
                                      context.l10n.emailSentMessage,
                                      style: context.bodyMediumOnSurfaceVariant
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.m),
                            Semantics(
                              label:
                                  context.l10n.forgotPasswordErrorSemanticLabel,
                              liveRegion: true,
                              child: SelectableText.rich(
                                TextSpan(
                                  text: context.translateError(errorMessage),
                                  style: context.bodyMediumOnSurface?.copyWith(
                                    color: context.colorScheme.error,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          if (!emailSent) ...[
                            const SizedBox(height: AppSpacing.xxl),
                            Card(
                              elevation: 0,
                              color: context.colorScheme.surfaceContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.large,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.l),
                                child: CustomTextField(
                                  controller: _emailController,
                                  label: context.l10n.emailLabel,
                                  hint: context.l10n.emailHint,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
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
                                  onSubmitted: (_) => _handleSendEmail(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            CustomButton(
                              label: context.l10n.sendRecoveryLinkButton,
                              variant: CustomButtonVariant.filled,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _handleSendEmail,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.l10n.rememberPasswordQuestion,
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
      ),
    );
  }
}
