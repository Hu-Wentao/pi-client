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
  final TextEditingController _workingDirectoryController =
      TextEditingController();
  final FocusNode _workingDirectoryFocusNode = FocusNode(
    debugLabel: 'new session working directory',
  );
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _workingDirectoryController.dispose();
    _workingDirectoryFocusNode.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => FrView<WorkspaceViewModel, WorkspaceModel>(
    builder: (context, snapshot, child) {
      final viewModel = snapshot.vm;
      final model = snapshot.data;
      final selectedSession = _selectedSession(model);
      final connected =
          model.connection.status == PiNodeConnectionStatus.connected;
      final running = selectedSession?.isRunning ?? false;
      final connectionActionAvailable = switch (model.nodeAvailability) {
        PiNodeCompositionAvailability.localHost ||
        PiNodeCompositionAvailability.externalNode => true,
        PiNodeCompositionAvailability.remoteNodeRequired ||
        PiNodeCompositionAvailability.unsupported => false,
      };

      final connection = NodeConnectionView(
        snapshot: model.connection,
        title: switch (model.nodeAvailability) {
          PiNodeCompositionAvailability.localHost => 'Local Pi Node',
          PiNodeCompositionAvailability.externalNode => 'Pi Node',
          PiNodeCompositionAvailability.remoteNodeRequired =>
            'Remote Pi Node required',
          PiNodeCompositionAvailability.unsupported => 'Pi Node unavailable',
        },
        errorMessage: model.nodeError,
        onConnect:
            connectionActionAvailable &&
                model.connection.status == PiNodeConnectionStatus.disconnected
            ? () => viewModel.add(const WorkspaceConnectionRetried())
            : null,
        onRetry: connectionActionAvailable
            ? () => viewModel.add(const WorkspaceConnectionRetried())
            : null,
      );
      final sessionBrowser = SessionBrowserView(
        sessions: model.sessions,
        selectedSessionId: model.selectedSessionId,
        isLoading: model.sessionsLoading,
        errorMessage: model.sessionError,
        onRetry: connected
            ? () => viewModel.add(const WorkspaceSessionsRefreshed())
            : null,
        onRefresh: connected
            ? () => viewModel.add(const WorkspaceSessionsRefreshed())
            : null,
        onCreateSession: connected ? () => _focusWorkingDirectory() : null,
        onSessionSelected: (sessionId) =>
            viewModel.add(WorkspaceSessionSelected(sessionId)),
      );
      final sidebar = _WorkspaceSidebar(
        connection: connection,
        sessionBrowser: sessionBrowser,
        workingDirectoryController: _workingDirectoryController,
        workingDirectoryFocusNode: _workingDirectoryFocusNode,
        canCreate: connected && !model.creatingSession,
        creating: model.creatingSession,
        onCreate: () {
          viewModel.add(
            WorkspaceNewSessionRequested(_workingDirectoryController.text),
          );
        },
      );
      final conversation = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ConversationView(
              session: selectedSession,
              messages: model.messages,
              isLoading: model.conversationLoading,
              errorMessage: model.conversationError,
              onRetry: model.selectedSessionId == null
                  ? null
                  : () => viewModel.add(
                      WorkspaceSessionSelected(model.selectedSessionId!),
                    ),
            ),
          ),
          _WorkspaceStatusLine(model: model),
          PromptComposerView(
            controller: _promptController,
            enabled: connected && selectedSession != null,
            isSubmitting: model.sending,
            isRunning: running || model.stopping,
            errorMessage: model.promptError,
            onSubmitted: (prompt) =>
                viewModel.add(WorkspacePromptSubmitted(prompt)),
            onStop: running && !model.stopping
                ? () => viewModel.add(const WorkspaceAgentStopped())
                : null,
          ),
        ],
      );

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
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.forum_outlined), text: 'Sessions'),
                        Tab(
                          icon: Icon(Icons.chat_bubble_outline_rounded),
                          text: 'Conversation',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(children: [sidebar, conversation]),
                    ),
                  ],
                ),
              );
            }
            return Row(
              children: [
                SizedBox(width: 360, child: sidebar),
                const VerticalDivider(width: 1),
                Expanded(child: conversation),
              ],
            );
          },
        ),
      );
    },
  );

  void _focusWorkingDirectory() {
    _workingDirectoryFocusNode.requestFocus();
    _workingDirectoryController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _workingDirectoryController.text.length,
    );
  }
}

class _WorkspaceSidebar extends StatelessWidget {
  const _WorkspaceSidebar({
    required this.connection,
    required this.sessionBrowser,
    required this.workingDirectoryController,
    required this.workingDirectoryFocusNode,
    required this.canCreate,
    required this.creating,
    required this.onCreate,
  });

  final Widget connection;
  final Widget sessionBrowser;
  final TextEditingController workingDirectoryController;
  final FocusNode workingDirectoryFocusNode;
  final bool canCreate;
  final bool creating;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: connection,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('workingDirectoryField'),
                  controller: workingDirectoryController,
                  focusNode: workingDirectoryFocusNode,
                  enabled: canCreate,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'New session working directory',
                    hintText: '/Projects/example',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const Key('createSessionButton'),
                tooltip: 'Create Pi session',
                onPressed: canCreate ? onCreate : null,
                icon: creating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        Expanded(child: sessionBrowser),
      ],
    ),
  );
}

class _WorkspaceStatusLine extends StatelessWidget {
  const _WorkspaceStatusLine({required this.model});

  final WorkspaceModel model;

  @override
  Widget build(BuildContext context) {
    final active =
        model.sending ||
        model.stopping ||
        model.conversationLoading ||
        model.eventStatus == WorkspaceEventStatus.recovering;
    return Container(
      key: const Key('workspaceStatusLine'),
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          if (active) ...[
            const SizedBox.square(
              dimension: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              model.statusMessage ?? 'Ready for Pi Node.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (model.selectedSessionId != null) ...[
            const SizedBox(width: 12),
            Tooltip(
              message: 'Pi event stream ${model.eventStatus.name}',
              child: Icon(
                switch (model.eventStatus) {
                  WorkspaceEventStatus.listening => Icons.sync_alt_rounded,
                  WorkspaceEventStatus.recovering => Icons.sync_rounded,
                  WorkspaceEventStatus.error => Icons.sync_problem_rounded,
                  WorkspaceEventStatus.idle => Icons.sync_disabled_rounded,
                },
                size: 17,
                color: model.eventStatus == WorkspaceEventStatus.listening
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
