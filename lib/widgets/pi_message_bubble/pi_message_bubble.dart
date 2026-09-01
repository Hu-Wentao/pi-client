import 'package:flutter/material.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';

/// Capabilities:
/// - Render a first-party Pi message by role with selectable text, local time,
///   responsive width, and accessible streaming state.
/// Public Widgets:
/// - [PiMessageBubble] — pure presentation for one `PiMessage`.
class PiMessageBubble extends StatelessWidget {
  const PiMessageBubble({
    required this.message,
    this.maxWidth = 760,
    super.key,
  });

  final PiMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rolePresentation = _presentationFor(message.role, scheme);
    final time = TimeOfDay.fromDateTime(
      message.createdAt.toLocal(),
    ).format(context);

    return Semantics(
      container: true,
      label:
          '${rolePresentation.label} message'
          '${message.isStreaming ? ', streaming' : ''}',
      liveRegion: message.isStreaming,
      child: Align(
        alignment: message.role == PiMessageRole.user
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: rolePresentation.background,
              borderRadius: BorderRadius.circular(16),
              border: message.isStreaming
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        rolePresentation.icon,
                        size: 16,
                        color: rolePresentation.foreground,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          rolePresentation.label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: rolePresentation.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: rolePresentation.foreground.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      if (message.isStreaming) ...[
                        const SizedBox(width: 8),
                        Semantics(
                          label: 'Receiving message',
                          child: SizedBox.square(
                            dimension: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: rolePresentation.foreground,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  SelectableText(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: rolePresentation.foreground,
                      height: 1.45,
                      fontFamily: message.role == PiMessageRole.tool
                          ? 'monospace'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_RolePresentation _presentationFor(PiMessageRole role, ColorScheme scheme) =>
    switch (role) {
      PiMessageRole.user => _RolePresentation(
        label: 'You',
        icon: Icons.person_outline_rounded,
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      PiMessageRole.assistant => _RolePresentation(
        label: 'Pi',
        icon: Icons.auto_awesome_rounded,
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurface,
      ),
      PiMessageRole.tool => _RolePresentation(
        label: 'Tool',
        icon: Icons.build_outlined,
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
      PiMessageRole.system => _RolePresentation(
        label: 'System',
        icon: Icons.info_outline_rounded,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
    };

final class _RolePresentation {
  const _RolePresentation({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}
