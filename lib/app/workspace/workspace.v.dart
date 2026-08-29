part of 'workspace.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({super.key});

  @override
  Widget build(BuildContext context) => const _WorkspaceViewBody();
}

class _WorkspaceViewBody extends StatefulWidget {
  const _WorkspaceViewBody();

  @override
  State<_WorkspaceViewBody> createState() => _WorkspaceViewBodyState();
}

class _WorkspaceViewBodyState extends State<_WorkspaceViewBody> {
  final _baseUrlController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cwdController = TextEditingController();
  final _promptController = TextEditingController();
  final _messageScrollController = ScrollController();
  bool _initialized = false;
  int _lastMessageCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _baseUrlController.text = context.read<WorkspaceViewModel>().state.baseUrl;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _passwordController.dispose();
    _cwdController.dispose();
    _promptController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  void _submitPrompt(WorkspaceViewModel viewModel) {
    final message = _promptController.text.trim();
    if (message.isEmpty) return;
    viewModel.add(WorkspacePromptSubmitted(message));
    _promptController.clear();
  }

  void _scheduleMessageScroll(int messageCount) {
    if (messageCount == _lastMessageCount) return;
    _lastMessageCount = messageCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) =>
      FrView<WorkspaceViewModel, WorkspaceModel>(
        builder: (context, snapshot, child) {
          final viewModel = snapshot.vm;
          final model = snapshot.data;
          _scheduleMessageScroll(model.messages.length);
          return Scaffold(
            key: const Key('workspaceScaffold'),
            appBar: AppBar(
              titleSpacing: 20,
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terminal_rounded, size: 22),
                  SizedBox(width: 10),
                  Text('Pi Client'),
                ],
              ),
              actions: [
                _ConnectionBadge(model: model),
                IconButton(
                  key: const Key('refreshSessionsButton'),
                  tooltip: 'Refresh sessions',
                  onPressed: model.sessionsLoading
                      ? null
                      : () => viewModel.add(const WorkspaceSessionsRefreshed()),
                  icon: model.sessionsLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final sidebar = _SessionSidebar(
                  model: model,
                  baseUrlController: _baseUrlController,
                  passwordController: _passwordController,
                  cwdController: _cwdController,
                  onConnect: () => viewModel.add(
                    WorkspaceConnectionApplied(
                      baseUrl: _baseUrlController.text,
                      password: _passwordController.text,
                    ),
                  ),
                  onCreateSession: () => viewModel.add(
                    WorkspaceNewSessionRequested(_cwdController.text),
                  ),
                  onSelectSession: (sessionId) =>
                      viewModel.add(WorkspaceSessionSelected(sessionId)),
                );
                final conversation = _ConversationPane(
                  model: model,
                  promptController: _promptController,
                  messageScrollController: _messageScrollController,
                  onSubmit: () => _submitPrompt(viewModel),
                  onStop: () => viewModel.add(const WorkspaceAgentStopped()),
                  onRetryConversation: model.selectedSessionId == null
                      ? null
                      : () => viewModel.add(
                          WorkspaceSessionSelected(model.selectedSessionId!),
                        ),
                );
                if (constraints.maxWidth < 840) {
                  return Column(
                    children: [
                      SizedBox(height: 330, child: sidebar),
                      const Divider(height: 1),
                      Expanded(child: conversation),
                    ],
                  );
                }
                return Row(
                  children: [
                    SizedBox(width: 320, child: sidebar),
                    const VerticalDivider(width: 1),
                    Expanded(child: conversation),
                  ],
                );
              },
            ),
          );
        },
      );
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.model});

  final WorkspaceModel model;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (model.connectionStatus) {
      WorkspaceConnectionStatus.connected => (
        'Connected',
        Colors.green,
        Icons.check_circle_outline_rounded,
      ),
      WorkspaceConnectionStatus.connecting => (
        'Connecting',
        Colors.amber,
        Icons.sync_rounded,
      ),
      WorkspaceConnectionStatus.error => (
        'Unavailable',
        Theme.of(context).colorScheme.error,
        Icons.error_outline_rounded,
      ),
      WorkspaceConnectionStatus.disconnected => (
        'Disconnected',
        Theme.of(context).colorScheme.outline,
        Icons.link_off_rounded,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        key: const Key('connectionStatusChip'),
        avatar: Icon(icon, color: color, size: 17),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _SessionSidebar extends StatelessWidget {
  const _SessionSidebar({
    required this.model,
    required this.baseUrlController,
    required this.passwordController,
    required this.cwdController,
    required this.onConnect,
    required this.onCreateSession,
    required this.onSelectSession,
  });

  final WorkspaceModel model;
  final TextEditingController baseUrlController;
  final TextEditingController passwordController;
  final TextEditingController cwdController;
  final VoidCallback onConnect;
  final VoidCallback onCreateSession;
  final ValueChanged<String> onSelectSession;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConnectionPanel(
          model: model,
          baseUrlController: baseUrlController,
          passwordController: passwordController,
          onConnect: onConnect,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('cwdField'),
                  controller: cwdController,
                  enabled:
                      model.connectionStatus ==
                          WorkspaceConnectionStatus.connected &&
                      !model.creatingSession,
                  decoration: const InputDecoration(
                    labelText: 'New session cwd',
                    hintText: '/absolute/project/path',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const Key('createSessionButton'),
                tooltip: 'Create session',
                onPressed:
                    model.connectionStatus ==
                            WorkspaceConnectionStatus.connected &&
                        !model.creatingSession
                    ? onCreateSession
                    : null,
                icon: model.creatingSession
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
          child: Row(
            children: [
              Text('Sessions', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(
                '${model.sessions.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _SessionList(model: model, onSelectSession: onSelectSession),
        ),
      ],
    ),
  );
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({
    required this.model,
    required this.baseUrlController,
    required this.passwordController,
    required this.onConnect,
  });

  final WorkspaceModel model;
  final TextEditingController baseUrlController;
  final TextEditingController passwordController;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('baseUrlField'),
          controller: baseUrlController,
          enabled:
              model.connectionStatus != WorkspaceConnectionStatus.connecting,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'pi-web URL',
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('passwordField'),
                controller: passwordController,
                enabled:
                    model.connectionStatus !=
                    WorkspaceConnectionStatus.connecting,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              key: const Key('connectButton'),
              onPressed:
                  model.connectionStatus == WorkspaceConnectionStatus.connecting
                  ? null
                  : onConnect,
              icon:
                  model.connectionStatus == WorkspaceConnectionStatus.connecting
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link_rounded),
              label: const Text('Connect'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.model, required this.onSelectSession});

  final WorkspaceModel model;
  final ValueChanged<String> onSelectSession;

  @override
  Widget build(BuildContext context) {
    if (model.sessionsLoading && model.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            model.connectionStatus == WorkspaceConnectionStatus.connected
                ? 'No sessions yet. Create one with an absolute cwd.'
                : 'Connect to pi-web to load sessions.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      key: const Key('sessionList'),
      itemCount: model.sessions.length,
      itemBuilder: (context, index) {
        final session = model.sessions[index];
        final selected = session.id == model.selectedSessionId;
        return ListTile(
          key: Key('session-${session.id}'),
          selected: selected,
          onTap: () => onSelectSession(session.id),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded),
              if (session.running)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            session.cwd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${session.messageCount}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      },
    );
  }
}

class _ConversationPane extends StatelessWidget {
  const _ConversationPane({
    required this.model,
    required this.promptController,
    required this.messageScrollController,
    required this.onSubmit,
    required this.onStop,
    required this.onRetryConversation,
  });

  final WorkspaceModel model;
  final TextEditingController promptController;
  final ScrollController messageScrollController;
  final VoidCallback onSubmit;
  final VoidCallback onStop;
  final VoidCallback? onRetryConversation;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _ConversationHeader(model: model),
      const Divider(height: 1),
      if (model.error != null)
        MaterialBanner(
          key: const Key('workspaceErrorBanner'),
          content: Text(model.error!),
          leading: Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          actions: [
            if (onRetryConversation != null)
              TextButton(
                key: const Key('retryConversationButton'),
                onPressed: onRetryConversation,
                child: const Text('Retry'),
              ),
          ],
        ),
      Expanded(
        child: _MessageTimeline(
          model: model,
          scrollController: messageScrollController,
        ),
      ),
      _StatusLine(model: model),
      _Composer(
        model: model,
        promptController: promptController,
        onSubmit: onSubmit,
        onStop: onStop,
      ),
    ],
  );
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.model});

  final WorkspaceModel model;

  @override
  Widget build(BuildContext context) {
    final selected = model.sessions.cast<PiSessionModel?>().firstWhere(
      (session) => session?.id == model.selectedSessionId,
      orElse: () => null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected?.title ?? 'Select a session',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  selected?.cwd ??
                      'Choose a pi session from the sidebar or create a new one.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (model.selectedSessionId != null)
            Tooltip(
              message: 'SSE ${model.streamStatus.name}',
              child: Icon(
                switch (model.streamStatus) {
                  WorkspaceStreamStatus.connected => Icons.wifi_rounded,
                  WorkspaceStreamStatus.connecting => Icons.sync_rounded,
                  WorkspaceStreamStatus.reconnecting =>
                    Icons.wifi_tethering_error_rounded,
                  WorkspaceStreamStatus.error => Icons.wifi_off_rounded,
                  WorkspaceStreamStatus.idle => Icons.wifi_off_rounded,
                },
                size: 18,
                color: model.streamStatus == WorkspaceStreamStatus.connected
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageTimeline extends StatelessWidget {
  const _MessageTimeline({required this.model, required this.scrollController});

  final WorkspaceModel model;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (model.conversationLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.selectedSessionId == null) {
      return const _ConversationEmptyState(
        icon: Icons.chat_outlined,
        title: 'Open a pi session',
        message: 'Session history and live agent events will appear here.',
      );
    }
    if (model.messages.isEmpty) {
      return const _ConversationEmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'Ready for a prompt',
        message: 'This session has no visible messages yet.',
      );
    }
    return ListView.builder(
      key: const Key('messageTimeline'),
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      itemCount: model.messages.length,
      itemBuilder: (context, index) =>
          _MessageBubble(message: model.messages[index]),
    );
  }
}

class _ConversationEmptyState extends StatelessWidget {
  const _ConversationEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final PiMessageModel message;

  @override
  Widget build(BuildContext context) {
    final user = message.role == PiMessageRole.user;
    final scheme = Theme.of(context).colorScheme;
    final background = switch (message.role) {
      PiMessageRole.user => scheme.primaryContainer,
      PiMessageRole.assistant => scheme.surfaceContainerHigh,
      PiMessageRole.tool => scheme.tertiaryContainer,
      PiMessageRole.custom => scheme.secondaryContainer,
      PiMessageRole.bash => scheme.inverseSurface,
    };
    final foreground = message.role == PiMessageRole.bash
        ? scheme.onInverseSurface
        : message.isError
        ? scheme.error
        : scheme.onSurface;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: message.streaming
              ? Border.all(color: scheme.primary.withValues(alpha: 0.55))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  switch (message.role) {
                    PiMessageRole.user => Icons.person_outline_rounded,
                    PiMessageRole.assistant => Icons.auto_awesome_rounded,
                    PiMessageRole.tool => Icons.build_outlined,
                    PiMessageRole.custom => Icons.extension_outlined,
                    PiMessageRole.bash => Icons.terminal_rounded,
                  },
                  size: 15,
                  color: foreground,
                ),
                const SizedBox(width: 6),
                Text(
                  message.role.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.streaming) ...[
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: foreground,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 7),
            SelectableText(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                height: 1.45,
                fontFamily: message.role == PiMessageRole.bash
                    ? 'monospace'
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.model});

  final WorkspaceModel model;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('workspaceStatusLine'),
    constraints: const BoxConstraints(minHeight: 30),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Row(
      children: [
        if (model.streaming || model.sending) ...[
          const SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            model.statusMessage ?? 'Ready.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.model,
    required this.promptController,
    required this.onSubmit,
    required this.onStop,
  });

  final WorkspaceModel model;
  final TextEditingController promptController;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final canSend = model.selectedSessionId != null && !model.sending;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('promptField'),
                controller: promptController,
                enabled: model.selectedSessionId != null && !model.sending,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText:
                      'Ask pi to inspect, change, or explain the project…',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (model.sending || model.streaming)
              IconButton.filledTonal(
                key: const Key('stopAgentButton'),
                tooltip: 'Stop agent',
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded),
              )
            else
              IconButton.filled(
                key: const Key('sendPromptButton'),
                tooltip: 'Send prompt',
                onPressed: canSend ? onSubmit : null,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
