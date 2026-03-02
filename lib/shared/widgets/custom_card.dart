import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';

/// Card personalizado con elevación configurable y soporte para acciones
///
/// Encapsula un Card de Material Design 3 con estilos consistentes y
/// soporte para títulos, subtítulos y acciones opcionales.
///
/// **Ejemplo de uso:**
/// ```dart
/// // Card básico con contenido
/// CustomCard(
///   child: Text('Contenido del card'),
/// )
///
/// // Card con título y subtítulo
/// CustomCard(
///   title: 'Título del Card',
///   subtitle: 'Subtítulo descriptivo',
///   child: Text('Contenido aquí'),
/// )
///
/// // Card con acciones
/// CustomCard(
///   title: 'Tarea',
///   trailingAction: IconButton(
///     icon: Icon(Icons.delete),
///     onPressed: () => deleteTask(),
///   ),
///   child: Text('Descripción de la tarea'),
/// )
///
/// // Card con elevación personalizada
/// CustomCard(
///   elevation: 4,
///   child: Text('Card con más elevación'),
/// )
/// ```
class CustomCard extends StatelessWidget {
  /// Contenido principal del card (obligatorio)
  final Widget child;

  /// Título del card (opcional)
  final String? title;

  /// Subtítulo del card (opcional)
  final String? subtitle;

  /// Acción que aparece al final del header (opcional)
  final Widget? trailingAction;

  /// Acción que aparece al inicio del header (opcional)
  final Widget? leadingAction;

  /// Elevación del card (por defecto usa la del tema)
  final double? elevation;

  /// Padding interno del contenido
  final EdgeInsetsGeometry? padding;

  /// Padding del card completo
  final EdgeInsetsGeometry? margin;

  /// Callback al hacer tap en el card
  final VoidCallback? onTap;

  /// Etiqueta semántica personalizada para lectores de pantalla.
  ///
  /// Si no se proporciona, se usa el [title] como etiqueta.
  /// Cuando el card no tiene acciones interactivas internas, se aplica
  /// [MergeSemantics] para que TalkBack/VoiceOver lea el card completo
  /// como un único elemento coherente.
  final String? semanticLabel;

  const CustomCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailingAction,
    this.leadingAction,
    this.elevation,
    this.padding,
    this.margin,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cardElevation = elevation ?? 1.0;
    final cardPadding = padding ?? const EdgeInsets.all(AppSpacing.m);

    // Determina si hay acciones interactivas en el header.
    // Si las hay, NO usamos MergeSemantics global para no inhibir
    // el foco individual de esas acciones.
    final bool hasInteractiveActions =
        trailingAction != null || leadingAction != null;

    // Construir el contenido del card
    Widget cardContent = Padding(
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con título, subtítulo y acciones (si existen)
          if (title != null ||
              subtitle != null ||
              trailingAction != null ||
              leadingAction != null)
            _buildHeader(context),

          // Contenido principal
          child,
        ],
      ),
    );

    // Si hay onTap, envolver en InkWell para feedback táctil
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: cardContent,
      );
    }

    // Envolver con semántica apropiada:
    // - Sin acciones internas: MergeSemantics agrupa el card como un único nodo
    //   coherente para TalkBack/VoiceOver (ideal para cards informativos simples).
    // - Con acciones internas: Semantics con label proporciona contexto al card
    //   pero permite que cada acción interna sea navegable individualmente.
    Widget semanticWrapper;
    if (!hasInteractiveActions) {
      semanticWrapper = MergeSemantics(
        child: Semantics(label: semanticLabel ?? title, child: cardContent),
      );
    } else {
      semanticWrapper = Semantics(
        label: semanticLabel ?? title,
        child: cardContent,
      );
    }

    return Card(
      elevation: cardElevation,
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
      child: semanticWrapper,
    );
  }

  /// Construye el header del card con título, subtítulo y acciones
  Widget _buildHeader(BuildContext context) {
    final hasTitle = title != null;
    final hasSubtitle = subtitle != null;
    final hasActions = trailingAction != null || leadingAction != null;

    // Si no hay título ni subtítulo pero hay acciones, mostrar solo las acciones
    if (!hasTitle && !hasSubtitle && hasActions) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [?leadingAction, ?trailingAction],
      );
    }

    // Construir header completo
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Acción inicial (si existe)
          if (leadingAction != null) ...[
            leadingAction!,
            const SizedBox(width: AppSpacing.s),
          ],

          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTitle) Text(title!, style: context.textTheme.titleLarge),
                if (hasSubtitle) ...[
                  if (hasTitle) const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Acción final (si existe)
          if (trailingAction != null) ...[
            const SizedBox(width: AppSpacing.s),
            trailingAction!,
          ],
        ],
      ),
    );
  }
}
