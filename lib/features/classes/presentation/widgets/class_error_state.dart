import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Estado de error reutilizable para screens de la feature de clases.
///
/// Muestra un ícono de error, el mensaje descriptivo y un botón de reintento.
/// No incluye [RefreshIndicator]: el caller lo añade si necesita pull-to-refresh.
class ClassErrorState extends StatelessWidget {
  const ClassErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: context.colorScheme.error,
        ),
        const SizedBox(height: AppSpacing.m),
        SelectableText.rich(
          TextSpan(
            text: message,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton.tonal(
          onPressed: onRetry,
          child: Text(context.l10n.retry),
        ),
      ],
    );
  }
}
