import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/value_objects/join_class_input.dart';
import '../cubit/class_cubit.dart';
import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import '../utils/class_validators.dart';

/// Pantalla para que los estudiantes se unan a una clase con código real.
///
/// Integra MembershipCubit para ejecutar el flujo y refresca ClassCubit
/// cuando la unión es exitosa.
class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _codeController = TextEditingController();
  String? _codeError;
  String? _formError;
  String? _successMessage;
  bool _navigationScheduled = false;
  Timer? _successPopTimer;

  @override
  void dispose() {
    _successPopTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    if (_codeError != null || _formError != null) {
      setState(() {
        _codeError = null;
        _formError = null;
      });
    }
  }

  Future<void> _handleJoin() async {
    FocusScope.of(context).unfocus();
    final validationError = validateAccessCodeField(_codeController.text);
    if (validationError != null) {
      setState(() {
        _codeError = validationError;
        _formError = validationError;
        _successMessage = null;
      });
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      log(
        'JoinClassScreen#_handleJoin sin sesión activa',
        name: 'JoinClassScreen',
      );
      setState(() {
        _formError = ClassesStrings.membershipGenericError;
        _successMessage = null;
      });
      return;
    }

    final normalizedCode = normalizeAccessCode(_codeController.text);
    final input = (studentId: authState.userId, accessCode: normalizedCode);

    try {
      validateJoinClassInput(input);
    } on ArgumentError catch (error) {
      setState(() {
        _formError = error.message;
        _successMessage = null;
      });
      return;
    }

    log(
      'JoinClassScreen#_handleJoin intentando unión con código $normalizedCode',
      name: 'JoinClassScreen',
      level: 800,
    );

    await context.read<MembershipCubit>().joinClass(input);
  }

  void _handleSuccess(MembershipSuccess state) {
    if (state.action != MembershipAction.joinedClass) {
      return;
    }
    log(
      'JoinClassScreen unión exitosa, refrescando clases',
      name: 'JoinClassScreen',
      level: 700,
    );
    setState(() {
      _successMessage = state.message ?? ClassesStrings.membershipJoinSuccess;
      _formError = null;
    });
    final classCubit = _maybeReadClassCubit();
    classCubit?.refreshClasses();
    if (_navigationScheduled || !Navigator.of(context).canPop()) {
      return;
    }
    _navigationScheduled = true;
    _successPopTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (!Navigator.of(context).canPop()) {
        _navigationScheduled = false;
        return;
      }
      context.pop(true);
    });
  }

  ClassCubit? _maybeReadClassCubit() {
    try {
      return context.read<ClassCubit>();
    } catch (_) {
      return null;
    }
  }

  void _handleError(MembershipError state) {
    log(
      'JoinClassScreen error al unirse: ${state.message}',
      name: 'JoinClassScreen',
      error: state.cause,
    );
    setState(() {
      _formError = state.message;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ClassesStrings.joinClass),
      body: BlocConsumer<MembershipCubit, MembershipState>(
        listenWhen: (previous, current) =>
            current is MembershipSuccess || current is MembershipError,
        listener: (context, state) {
          if (state is MembershipSuccess) _handleSuccess(state);
          if (state is MembershipError) _handleError(state);
        },
        builder: (context, state) {
          final isLoading = state is MembershipLoading;
          final showError = _formError != null && _formError!.isNotEmpty;
          final hasSuccess = _successMessage != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ClassesStrings.joinClassTitle,
                  style: context.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.l),
                CustomCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          ClassesStrings.accessCodeInstructions,
                          style: context.bodyMediumOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                CustomTextField(
                  controller: _codeController,
                  label: ClassesStrings.accessCodeLabel,
                  hint: ClassesStrings.accessCodeHint,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  keyboardType: TextInputType.text,
                  errorText: _codeError,
                  onSubmitted: (_) => _handleJoin(),
                  onChanged: _onCodeChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                ),
                if (showError) ...[
                  const SizedBox(height: AppSpacing.l),
                  SelectableText.rich(
                    TextSpan(
                      text: _formError,
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
                  label: ClassesStrings.joinButton,
                  variant: CustomButtonVariant.filled,
                  icon: Icons.login,
                  onPressed: isLoading ? null : _handleJoin,
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

/// Banner simple que confirma al usuario la unión exitosa antes de salir.
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
