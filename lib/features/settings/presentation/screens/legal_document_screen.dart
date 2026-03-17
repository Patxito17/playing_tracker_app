import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Pantalla genérica para visualizar documentos Markdown legales (T&C, Privacidad)
///
/// Lee el archivo desde los assets de la aplicación y lo renderiza con
/// el estilo de Material Design 3 del proyecto.
class LegalDocumentScreen extends StatefulWidget {
  /// Título que aparece en el AppBar
  final String title;

  /// Ruta del asset Markdown a cargar (ej. 'assets/legal/terms_es.md')
  final String assetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late final Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = rootBundle.loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      context.l10n.legalTextLoadError,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(AppSpacing.m),
            styleSheet: MarkdownStyleSheet(
              h1: textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              h2: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              p: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              listBullet: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              blockquoteDecoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border(
                  left: BorderSide(color: colorScheme.primary, width: 4),
                ),
              ),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              strong: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              a: TextStyle(color: colorScheme.primary),
            ),
          );
        },
      ),
    );
  }
}
