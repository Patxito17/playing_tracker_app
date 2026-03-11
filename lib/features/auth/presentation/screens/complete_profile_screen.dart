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

/// Pantalla de completar perfil para usuarios que se registran vía Google.
///
/// Se muestra cuando [AuthProfileIncomplete] es emitido por [AuthCubit].
/// El usuario elige su rol (docente/alumno), introduce nombre y apellidos,
/// y acepta los términos de uso.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, this.email, this.displayName});

  /// Email del usuario de Google (pre-rellenado, no editable).
  final String? email;

  /// Nombre de visualización de Google (opcional, como referencia).
  final String? displayName;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;

  UserRole _selectedRole = UserRole.teacher;
  bool _termsAccepted = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    // Recuperar datos de Google del estado actual si no vienen por GoRouter
    final cubit = context.read<AuthCubit>();
    final state = cubit.state;

    String? displayName = widget.displayName;
    if (displayName == null && state is AuthProfileIncomplete) {
      displayName = state.displayName;
    }

    if (displayName != null) {
      final names = displayName.split(' ');
      if (names.isNotEmpty) {
        _firstNameController.text = names.first;
        if (names.length > 1) {
          _lastNameController.text = names.sublist(1).join(' ');
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Abre el diálogo de términos legales y marca el checkbox si se acepta.
  Future<void> _openLegalDialog() async {
    final locale = Localizations.localeOf(context).languageCode;
    final assetPath = locale == 'es'
        ? 'assets/legal/terms_es.md'
        : 'assets/legal/terms_en.md';

    String legalText;
    try {
      legalText = await rootBundle.loadString(assetPath);
    } catch (_) {
      if (!mounted) return;
      legalText = context.l10n.legalTextLoadError;
    }

    if (!mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => LegalConsentDialog(
        legalText: legalText,
        version: kCurrentTermsVersion,
      ),
    );

    if (accepted == true && mounted) {
      setState(() {
        _termsAccepted = true;
        _formError = null;
      });
    }
  }

  void _validateFirstName(String value) {
    setState(() {
      _firstNameError = Validators.name(
        value,
        requiredMsg: context.l10n.firstNameRequired,
      );
    });
  }

  void _validateLastName(String value) {
    setState(() {
      _lastNameError = Validators.name(
        value,
        requiredMsg: context.l10n.lastNameRequired,
      );
    });
  }

  /// Valida y envía el formulario.
  void _handleSubmit() {
    _validateFirstName(_firstNameController.text);
    _validateLastName(_lastNameController.text);

    if (!_termsAccepted) {
      setState(() => _formError = context.l10n.termsNotAccepted);
    }

    if (_firstNameError != null || _lastNameError != null || !_termsAccepted) {
      return;
    }

    final cubit = context.read<AuthCubit>();
    if (_selectedRole == UserRole.teacher) {
      cubit.completeGoogleTeacherProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        acceptedTermsVersion: kCurrentTermsVersion,
      );
    } else {
      cubit.completeGoogleStudentProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        acceptedTermsVersion: kCurrentTermsVersion,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.completeProfileTitle),
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
                    if (!mounted) return;
                    context.go(destination);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final errorMessage = state is AuthError
                      ? state.message
                      : _formError;

                  final displayEmail = widget.email ??
                      (state is AuthProfileIncomplete ? state.email : null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        context.l10n.completeProfileTitle,
                        style: context.displaySmallBold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      if (displayEmail != null)
                        Text(
                          displayEmail,
                          style: context.bodyLargeOnSurfaceVariant,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Error message
                      if (errorMessage != null) ...[
                        Semantics(
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
                        const SizedBox(height: AppSpacing.l),
                      ],

                      // Selector de rol
                      Text(
                        context.l10n.roleLabel,
                        style: context.bodyMediumOnSurface,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      SegmentedButton<UserRole>(
                        segments: [
                          ButtonSegment(
                            value: UserRole.teacher,
                            label: Text(context.l10n.roleTeacher),
                            icon: const Icon(Icons.school_outlined),
                          ),
                          ButtonSegment(
                            value: UserRole.student,
                            label: Text(context.l10n.roleStudent),
                            icon: const Icon(Icons.person_outlined),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: isLoading
                            ? null
                            : (selected) => setState(
                                () => _selectedRole = selected.first,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Nombre
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
                          Icons.person_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (_) {
                          if (_firstNameError != null) {
                            setState(() => _firstNameError = null);
                          }
                        },
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Apellidos
                      CustomTextField(
                        controller: _lastNameController,
                        label: context.l10n.lastNameLabel,
                        hint: context.l10n.lastNameHint,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.familyName],
                        errorText: _lastNameError,
                        prefix: Icon(
                          Icons.person_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (_) {
                          if (_lastNameError != null) {
                            setState(() => _lastNameError = null);
                          }
                        },
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Términos y condiciones
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value == true) {
                                      _openLegalDialog();
                                    } else {
                                      setState(() {
                                        _termsAccepted = false;
                                      });
                                    }
                                  },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: isLoading ? null : _openLegalDialog,
                              child: Text.rich(
                                TextSpan(
                                  text: '${context.l10n.acceptTermsPrefix} ',
                                  style: context.bodyMediumOnSurface,
                                  children: [
                                    TextSpan(
                                      text: context.l10n.termsLinkText,
                                      style: context.textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Botón de enviar
                      CustomButton(
                        label: context.l10n.completeProfileButton,
                        variant: CustomButtonVariant.filled,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleSubmit,
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
