import 'package:flutter/material.dart';
import 'package:playing_tracker/core/extensions/context_extensions.dart';

/// Diálogo de consentimiento legal (Términos y Condiciones + Política de Privacidad).
///
/// Implementa el patrón "consentimiento informado":
/// - Muestra el texto legal desde un asset local versionado.
/// - El botón Aceptar permanece **deshabilitado** hasta que el usuario llega
///   al final del scroll Y marca el checkbox explícito.
/// - Devuelve `true` si el usuario acepta, `null` / `false` si cancela.
///
/// Uso:
/// ```dart
/// final accepted = await LegalConsentDialog.show(context);
/// if (accepted == true) { /* persistir consentimiento */ }
/// ```
class LegalConsentDialog extends StatefulWidget {
  /// Texto legal completo ya cargado (Términos + Política, en Markdown plano).
  final String legalText;

  /// Versión de los términos a mostrar (e.g. "1.0").
  final String version;

  /// Si es `true`, el título mostrará "Términos actualizados" en lugar del título normal.
  final bool isUpdate;

  const LegalConsentDialog({
    super.key,
    required this.legalText,
    required this.version,
    this.isUpdate = false,
  });

  /// Muestra el diálogo y devuelve `true` si el usuario acepta.
  static Future<bool?> show(
    BuildContext context, {
    required String legalText,
    required String version,
    bool isUpdate = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LegalConsentDialog(
        legalText: legalText,
        version: version,
        isUpdate: isUpdate,
      ),
    );
  }

  @override
  State<LegalConsentDialog> createState() => _LegalConsentDialogState();
}

class _LegalConsentDialogState extends State<LegalConsentDialog> {
  final ScrollController _scrollController = ScrollController();

  bool _hasScrolledToEnd = false;
  bool _checkboxChecked = false;

  bool get _canAccept => _hasScrolledToEnd && _checkboxChecked;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasScrolledToEnd) return;
    final pos = _scrollController.position;
    // Consideramos "llegado al final" si quedan menos de 40px
    if (pos.pixels >= pos.maxScrollExtent - 40) {
      setState(() => _hasScrolledToEnd = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = widget.isUpdate
        ? l10n.legalConsentUpdatedTitle
        : l10n.legalConsentTitle;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabecera ─────────────────────────────────────────────────
            _Header(
              title: title,
              version: l10n.legalConsentVersionLabel(widget.version),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),

            // Aviso de re-aceptación si procede
            if (widget.isUpdate)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  l10n.legalConsentUpdatedMessage,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // ── Instrucción de scroll ─────────────────────────────────────
            if (!_hasScrolledToEnd)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_down_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.legalConsentScrollInstruction,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Cuerpo con scroll ─────────────────────────────────────────
            Flexible(
              child: Stack(
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: _LegalMarkdownText(
                        text: widget.legalText,
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                  // Gradiente para indicar más contenido
                  if (!_hasScrolledToEnd)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.surface.withValues(alpha: 0),
                                colorScheme.surface,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Checkbox de aceptación ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: CheckboxListTile(
                value: _checkboxChecked,
                onChanged: _hasScrolledToEnd
                    ? (v) => setState(() => _checkboxChecked = v ?? false)
                    : null,
                title: Text(
                  l10n.legalConsentCheckboxLabel,
                  style: textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),

            // ── Botones ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.legalConsentDeclineButton),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _canAccept
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    child: Text(l10n.legalConsentAcceptButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final String version;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Header({
    required this.title,
    required this.version,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_rounded, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  version,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renderiza un texto en Markdown plano (sin paquete externo).
/// Soporta: ## Títulos, **negrita**, separador --- y párrafos.
class _LegalMarkdownText extends StatelessWidget {
  final String text;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _LegalMarkdownText({
    required this.text,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              trimmed.substring(2),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              trimmed.substring(3),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('---')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: colorScheme.outlineVariant),
          ),
        );
      } else {
        // Procesar **negrita** de forma simple
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _BoldText(
              text: trimmed,
              style:
                  textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ) ??
                  const TextStyle(),
              boldStyle:
                  textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ) ??
                  const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

/// Renderiza inline **bold** sin usar paquetes externos.
class _BoldText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextStyle boldStyle;

  const _BoldText({
    required this.text,
    required this.style,
    required this.boldStyle,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    if (parts.length == 1) return Text(text, style: style);

    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: i.isOdd ? boldStyle : style));
    }
    return Text.rich(TextSpan(children: spans));
  }
}
