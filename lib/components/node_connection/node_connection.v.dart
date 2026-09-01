part of 'node_connection.dart';

class NodeConnectionView extends StatelessWidget {
  const NodeConnectionView({
    required this.snapshot,
    this.errorMessage,
    this.onConnect,
    this.onRetry,
    this.onDisconnect,
    this.title = 'Pi Node',
    super.key,
  });

  final PiNodeConnectionSnapshot snapshot;
  final String? errorMessage;
  final VoidCallback? onConnect;
  final VoidCallback? onRetry;
  final VoidCallback? onDisconnect;
  final String title;

  @override
  Widget build(BuildContext context) {
    final presentation = _NodeConnectionPresentation.from(snapshot);
    final primaryAction = errorMessage != null && onRetry != null
        ? (label: 'Retry', icon: Icons.refresh_rounded, callback: onRetry!)
        : switch (snapshot.status) {
            PiNodeConnectionStatus.disconnected ||
            PiNodeConnectionStatus.closed when onConnect != null => (
              label: 'Connect',
              icon: Icons.link_rounded,
              callback: onConnect!,
            ),
            _ => null,
          };
    final mayDisconnect = switch (snapshot.status) {
      PiNodeConnectionStatus.connecting ||
      PiNodeConnectionStatus.connected => onDisconnect != null,
      _ => false,
    };

    return Semantics(
      container: true,
      label: '$title connection',
      liveRegion: presentation.inProgress || errorMessage != null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 440;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  NodeConnectionBadge(snapshot: snapshot),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage ?? presentation.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: errorMessage == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (presentation.inProgress) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      label: presentation.progressLabel,
                      child: const LinearProgressIndicator(),
                    ),
                  ],
                ],
              );
              final actions = <Widget>[
                if (primaryAction != null)
                  FilledButton.icon(
                    key: const Key('nodeConnectionPrimaryAction'),
                    onPressed: primaryAction.callback,
                    icon: Icon(primaryAction.icon),
                    label: Text(primaryAction.label),
                  ),
                if (mayDisconnect)
                  OutlinedButton.icon(
                    key: const Key('nodeConnectionDisconnectAction'),
                    onPressed: onDisconnect,
                    icon: Icon(
                      snapshot.status == PiNodeConnectionStatus.connecting
                          ? Icons.close_rounded
                          : Icons.link_off_rounded,
                    ),
                    label: Text(
                      snapshot.status == PiNodeConnectionStatus.connecting
                          ? 'Cancel'
                          : 'Disconnect',
                    ),
                  ),
              ];

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...actions.map(
                        (action) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: action,
                        ),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: details),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 20),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class NodeConnectionBadge extends StatelessWidget {
  const NodeConnectionBadge({
    required this.snapshot,
    this.showProtocolVersion = true,
    super.key,
  });

  final PiNodeConnectionSnapshot snapshot;
  final bool showProtocolVersion;

  @override
  Widget build(BuildContext context) {
    final presentation = _NodeConnectionPresentation.from(snapshot);
    final protocol = snapshot.negotiatedVersion;
    final label = showProtocolVersion && protocol != null
        ? '${presentation.label} · v$protocol'
        : presentation.label;

    return Semantics(
      label: 'Pi Node $label',
      liveRegion: presentation.inProgress,
      child: Chip(
        key: const Key('nodeConnectionBadge'),
        avatar: Icon(
          presentation.icon,
          size: 17,
          color: presentation.color(Theme.of(context).colorScheme),
        ),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

final class _NodeConnectionPresentation {
  const _NodeConnectionPresentation({
    required this.label,
    required this.description,
    required this.progressLabel,
    required this.icon,
    required this.inProgress,
    required this.color,
  });

  factory _NodeConnectionPresentation.from(PiNodeConnectionSnapshot snapshot) =>
      switch (snapshot.status) {
        PiNodeConnectionStatus.disconnected => _NodeConnectionPresentation(
          label: 'Disconnected',
          description: 'Connect to a trusted Pi Node to browse sessions.',
          progressLabel: '',
          icon: Icons.link_off_rounded,
          inProgress: false,
          color: (scheme) => scheme.outline,
        ),
        PiNodeConnectionStatus.connecting => _NodeConnectionPresentation(
          label: 'Connecting',
          description: 'Negotiating a secure first-party Pi protocol session.',
          progressLabel: 'Connecting to Pi Node',
          icon: Icons.sync_rounded,
          inProgress: true,
          color: (scheme) => scheme.tertiary,
        ),
        PiNodeConnectionStatus.connected => _NodeConnectionPresentation(
          label: 'Connected',
          description: snapshot.negotiatedVersion == null
              ? 'The Pi Node connection is ready.'
              : 'Protocol ${snapshot.negotiatedVersion} is ready.',
          progressLabel: '',
          icon: Icons.check_circle_outline_rounded,
          inProgress: false,
          color: (scheme) => scheme.primary,
        ),
        PiNodeConnectionStatus.closing => _NodeConnectionPresentation(
          label: 'Disconnecting',
          description: 'Closing the Pi Node connection safely.',
          progressLabel: 'Disconnecting from Pi Node',
          icon: Icons.sync_rounded,
          inProgress: true,
          color: (scheme) => scheme.tertiary,
        ),
        PiNodeConnectionStatus.closed => _NodeConnectionPresentation(
          label: 'Closed',
          description: 'This Pi Node client has been closed.',
          progressLabel: '',
          icon: Icons.block_rounded,
          inProgress: false,
          color: (scheme) => scheme.error,
        ),
      };

  final String label;
  final String description;
  final String progressLabel;
  final IconData icon;
  final bool inProgress;
  final Color Function(ColorScheme scheme) color;
}
