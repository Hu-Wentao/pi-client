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
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode(
    debugLabel: 'workspace prompt composer',
  );

  @override
  void dispose() {
    _promptController.dispose();
    _promptFocusNode.dispose();
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
        errorMessage: model.sessionAdminError ?? model.sessionError,
        onRetry: connected
            ? () => viewModel.add(const WorkspaceSessionsRefreshed())
            : null,
        onRefresh: connected
            ? () => viewModel.add(const WorkspaceSessionsRefreshed())
            : null,
        onCreateSession: connected
            ? () => _requestCreateSession(viewModel, model.selectedProject)
            : null,
        onRenameSession: connected && !model.sessionAdminLoading
            ? (session, name) => viewModel.add(
                WorkspaceSessionRenamed(sessionId: session.id, name: name),
              )
            : null,
        onClearSessionName: connected && !model.sessionAdminLoading
            ? (session) =>
                  viewModel.add(WorkspaceSessionCustomNameCleared(session.id))
            : null,
        onAutoNameSession: connected && !model.sessionAdminLoading
            ? (session) => viewModel.add(WorkspaceSessionAutoNamed(session.id))
            : null,
        onDeleteSessionConfirmed: connected && !model.sessionAdminLoading
            ? (confirmation) =>
                  viewModel.add(WorkspaceSessionDeleted(confirmation))
            : null,
        sessionActionInProgressId: model.sessionAdminSessionId,
        sessionActionInProgressOperation: model.sessionAdminOperation,
        onSessionSelected: (sessionId) => _requestSessionSelection(
          viewModel,
          model.selectedProject,
          sessionId,
        ),
      );
      final projectBrowser = ProjectBrowserView(
        selectedProject: model.selectedProject,
        knownProjects: model.knownProjects,
        directory: model.projectDirectory,
        isLoading: model.projectLoading,
        isBrowsing: model.projectBrowsing,
        isValidating: model.projectValidating,
        errorMessage: model.projectError,
        onBrowseDirectory: (directory) =>
            viewModel.add(WorkspaceProjectDirectoryBrowsed(directory)),
        onValidatePath: (directory) =>
            viewModel.add(WorkspaceProjectPathValidated(directory)),
        onProjectSelected: (project) =>
            viewModel.add(WorkspaceProjectSelected(project)),
      );
      final sidebar = _WorkspaceSidebar(
        connection: connection,
        projectBrowser: projectBrowser,
        sessionBrowser: sessionBrowser,
        canCreate:
            connected &&
            model.selectedProject != null &&
            !model.creatingSession,
        creating: model.creatingSession,
        onCreate: () => _requestCreateSession(viewModel, model.selectedProject),
      );
      final editableMessageIds =
          model.sessionTree?.nodes
              .where((node) => node.canEditFromHere)
              .map((node) => PiMessageId(node.id.value))
              .toSet() ??
          const <PiMessageId>{};
      final forkableMessageIds =
          model.sessionTree?.nodes
              .where((node) => node.canFork)
              .map((node) => PiMessageId(node.id.value))
              .toSet() ??
          const <PiMessageId>{};
      final branchActionsEnabled =
          connected &&
          selectedSession != null &&
          !running &&
          !model.conversationLoading &&
          !model.sessionTreeLoading &&
          !model.sessionAdminLoading &&
          !model.sessionTreeMutationLoading;
      final conversation = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BranchNavigatorView(
                  tree: model.sessionTree,
                  isLoading:
                      model.sessionTreeLoading ||
                      model.sessionTreeMutationLoading,
                  errorMessage: model.sessionTreeError,
                  onRetry: model.selectedSessionId == null
                      ? null
                      : () => viewModel.add(
                          WorkspaceSessionSelected(model.selectedSessionId!),
                        ),
                  onNavigate: branchActionsEnabled
                      ? (node) => viewModel.add(
                          WorkspaceSessionTreeNavigated(node.id),
                        )
                      : null,
                  onFork: branchActionsEnabled
                      ? (node) => viewModel.add(WorkspaceSessionForked(node.id))
                      : null,
                  onClone:
                      branchActionsEnabled &&
                          model.sessionTree?.canCloneActiveBranch == true
                      ? () => viewModel.add(const WorkspaceSessionCloned())
                      : null,
                ),
                const Divider(height: 1),
                Expanded(
                  child: ConversationView(
                    session: selectedSession,
                    messages: model.messages,
                    isLoading: model.conversationLoading,
                    errorMessage: model.conversationError,
                    canLoadOlder: model.historyHasMore,
                    isLoadingOlder: model.historyLoading,
                    onLoadOlder: model.historyHasMore
                        ? () => viewModel.add(
                            const WorkspaceOlderHistoryRequested(),
                          )
                        : null,
                    onRetry: model.selectedSessionId == null
                        ? null
                        : () => viewModel.add(
                            WorkspaceSessionSelected(model.selectedSessionId!),
                          ),
                    editableMessageIds: editableMessageIds,
                    forkableMessageIds: forkableMessageIds,
                    branchActionsEnabled: branchActionsEnabled,
                    onEditFromHere: (message) => viewModel.add(
                      WorkspaceSessionTreeNavigated(
                        PiSessionTreeEntryId(message.id.value),
                      ),
                    ),
                    onForkFromHere: (message) => viewModel.add(
                      WorkspaceSessionForked(
                        PiSessionTreeEntryId(message.id.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SessionDataPanel(
            session: selectedSession,
            stats: model.sessionStats,
            statsLoading: model.sessionStatsLoading,
            statsError: model.sessionStatsError,
            exportLoading: model.sessionExportLoading,
            exportSavedBytes: model.sessionExportSavedBytes,
            exportTotalBytes: model.sessionExportTotalBytes,
            exportError: model.sessionExportError,
            lastExportFileName: model.lastExportFileName,
            canExport:
                connected &&
                selectedSession != null &&
                !running &&
                !model.conversationLoading &&
                !model.sessionAdminLoading &&
                !model.sessionTreeMutationLoading &&
                !model.sessionExportLoading,
            onRefreshStats: model.sessionStatsLoading
                ? null
                : () => viewModel.add(const WorkspaceSessionStatsRefreshed()),
            onExport: (format) =>
                viewModel.add(WorkspaceSessionExportRequested(format)),
            onCancelExport: () =>
                viewModel.add(const WorkspaceSessionExportCancelled()),
          ),
          _WorkspaceStatusLine(model: model),
          PromptComposerView(
            controller: _promptController,
            focusNode: _promptFocusNode,
            restoredText: model.composerDraft,
            restoreGeneration: model.composerDraftGeneration,
            enabled:
                connected &&
                selectedSession != null &&
                !model.sessionTreeMutationLoading,
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

  Future<void> _requestCreateSession(
    WorkspaceViewModel viewModel,
    PiProject? project,
  ) async {
    if (project?.trust.requiresApproval == true) {
      await _showProjectTrustDialog(
        viewModel,
        project!,
        createSessionAfterApproval: true,
      );
      return;
    }
    viewModel.add(const WorkspaceNewSessionRequested());
  }

  Future<void> _requestSessionSelection(
    WorkspaceViewModel viewModel,
    PiProject? project,
    PiSessionId sessionId,
  ) async {
    if (project?.trust.requiresApproval == true) {
      await _showProjectTrustDialog(
        viewModel,
        project!,
        sessionIdAfterApproval: sessionId,
      );
      return;
    }
    viewModel.add(WorkspaceSessionSelected(sessionId));
  }

  Future<void> _showProjectTrustDialog(
    WorkspaceViewModel viewModel,
    PiProject project, {
    bool createSessionAfterApproval = false,
    PiSessionId? sessionIdAfterApproval,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ProjectTrustDialog(
      project: project,
      onApprove: () {
        Navigator.of(dialogContext).pop();
        viewModel.add(
          WorkspaceProjectTrustApproved(
            createSessionAfterApproval: createSessionAfterApproval,
            sessionIdAfterApproval: sessionIdAfterApproval,
          ),
        );
      },
    ),
  );
}

class _WorkspaceSidebar extends StatelessWidget {
  const _WorkspaceSidebar({
    required this.connection,
    required this.projectBrowser,
    required this.sessionBrowser,
    required this.canCreate,
    required this.creating,
    required this.onCreate,
  });

  final Widget connection;
  final Widget projectBrowser;
  final Widget sessionBrowser;
  final bool canCreate;
  final bool creating;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            key: const Key('workspaceProjectControlsScroll'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: connection,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: projectBrowser,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: FilledButton.icon(
                    key: const Key('createSessionButton'),
                    onPressed: canCreate ? onCreate : null,
                    icon: creating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: const Text('New session in selected project'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(flex: 4, child: sessionBrowser),
      ],
    ),
  );
}

class _SessionDataPanel extends StatelessWidget {
  const _SessionDataPanel({
    required this.session,
    required this.stats,
    required this.statsLoading,
    required this.statsError,
    required this.exportLoading,
    required this.exportSavedBytes,
    required this.exportTotalBytes,
    required this.exportError,
    required this.lastExportFileName,
    required this.canExport,
    required this.onRefreshStats,
    required this.onExport,
    required this.onCancelExport,
  });

  final PiSessionSummary? session;
  final PiSessionStats? stats;
  final bool statsLoading;
  final String? statsError;
  final bool exportLoading;
  final int exportSavedBytes;
  final int exportTotalBytes;
  final String? exportError;
  final String? lastExportFileName;
  final bool canExport;
  final VoidCallback? onRefreshStats;
  final ValueChanged<PiSessionExportFormat> onExport;
  final VoidCallback onCancelExport;

  @override
  Widget build(BuildContext context) {
    if (session == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final progress = exportTotalBytes > 0
        ? (exportSavedBytes / exportTotalBytes).clamp(0.0, 1.0)
        : null;
    return Material(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (stats != null) ...[
                        _StatLabel(
                          icon: Icons.chat_bubble_outline_rounded,
                          label:
                              '${stats!.userMessages + stats!.assistantMessages} messages',
                        ),
                        _StatLabel(
                          icon: Icons.data_usage_rounded,
                          label: stats!.totalTokens == 0
                              ? 'No recorded usage'
                              : '${stats!.totalTokens} tokens',
                        ),
                        _StatLabel(
                          icon: Icons.timer_outlined,
                          label: _formatDuration(stats!.activeTime),
                        ),
                      ] else
                        Text(
                          statsLoading
                              ? 'Loading full-session statistics…'
                              : 'Full-session statistics unavailable',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('sessionStatsRefreshButton'),
                  tooltip: 'Refresh full-session statistics',
                  onPressed: onRefreshStats,
                  icon: statsLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
                if (exportLoading)
                  TextButton.icon(
                    key: const Key('sessionExportCancelButton'),
                    onPressed: onCancelExport,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel export'),
                  )
                else
                  PopupMenuButton<PiSessionExportFormat>(
                    key: const Key('sessionExportMenuButton'),
                    enabled: canExport,
                    tooltip: session!.isRunning
                        ? 'Stop the running session before exporting'
                        : 'Export complete session history',
                    onSelected: onExport,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: PiSessionExportFormat.html,
                        child: Text('Export HTML'),
                      ),
                      PopupMenuItem(
                        value: PiSessionExportFormat.jsonl,
                        child: Text('Export JSONL'),
                      ),
                    ],
                    icon: const Icon(Icons.download_rounded),
                  ),
              ],
            ),
            if (exportLoading) ...[
              const SizedBox(height: 4),
              Semantics(
                label: exportTotalBytes > 0
                    ? 'Exported $exportSavedBytes of $exportTotalBytes bytes'
                    : 'Preparing session export',
                child: LinearProgressIndicator(value: progress),
              ),
            ],
            if (statsError != null || exportError != null) ...[
              const SizedBox(height: 4),
              Text(
                statsError ?? exportError!,
                key: const Key('sessionDataErrorText'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ] else if (lastExportFileName != null) ...[
              const SizedBox(height: 4),
              Text(
                '$lastExportFileName saved and verified.',
                key: const Key('sessionExportSuccessText'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m active';
    if (minutes > 0) return '${minutes}m ${seconds}s active';
    return '${seconds}s active';
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
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
        model.sessionAdminLoading ||
        model.sessionTreeMutationLoading ||
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
