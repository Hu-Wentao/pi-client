part of 'session_browser.dart';

class SessionBrowserView extends StatefulWidget {
  const SessionBrowserView({
    required this.sessions,
    required this.onSessionSelected,
    this.selectedSessionId,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onRefresh,
    this.onCreateSession,
    this.onRenameSession,
    this.onClearSessionName,
    this.onAutoNameSession,
    this.onDeleteSessionConfirmed,
    this.sessionActionInProgressId,
    this.sessionActionInProgressOperation,
    this.title = 'Sessions',
    super.key,
  });

  final List<PiSessionSummary> sessions;
  final PiSessionId? selectedSessionId;
  final ValueChanged<PiSessionId> onSessionSelected;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;
  final VoidCallback? onCreateSession;
  final void Function(PiSessionSummary session, String name)? onRenameSession;
  final ValueChanged<PiSessionSummary>? onClearSessionName;
  final ValueChanged<PiSessionSummary>? onAutoNameSession;
  final ValueChanged<PiDeleteSessionConfirmation>? onDeleteSessionConfirmed;
  final PiSessionId? sessionActionInProgressId;
  final PiSessionAdminOperation? sessionActionInProgressOperation;
  final String title;

  @override
  State<SessionBrowserView> createState() => _SessionBrowserViewState();
}

class _SessionBrowserViewState extends State<SessionBrowserView> {
  final TextEditingController _filterController = TextEditingController();
  final FocusNode _listFocusNode = FocusNode(debugLabel: 'session browser');
  int _keyboardIndex = -1;
  PiSessionId? _deleteConfirmationSessionId;

  @override
  void didUpdateWidget(covariant SessionBrowserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final confirmationId = _deleteConfirmationSessionId;
    if (confirmationId != null &&
        !widget.sessions.any((session) => session.id == confirmationId)) {
      _deleteConfirmationSessionId = null;
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  List<PiSessionSummary> get _filteredSessions {
    final query = _filterController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.sessions;
    return widget.sessions
        .where(
          (session) =>
              session.title.toLowerCase().contains(query) ||
              session.workingDirectory.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Object? _moveSelection(_MoveSessionSelectionIntent intent) {
    final sessions = _filteredSessions;
    if (sessions.isEmpty) return null;
    final selectedIndex = sessions.indexWhere(
      (session) => session.id == widget.selectedSessionId,
    );
    final currentIndex = _keyboardIndex >= 0 ? _keyboardIndex : selectedIndex;
    final requested = currentIndex < 0
        ? (intent.delta > 0 ? 0 : sessions.length - 1)
        : currentIndex + intent.delta;
    final targetIndex = requested.clamp(0, sessions.length - 1);
    setState(() => _keyboardIndex = targetIndex);
    widget.onSessionSelected(sessions[targetIndex].id);
    return null;
  }

  Object? _activateSelection(_ActivateSessionSelectionIntent intent) {
    final sessions = _filteredSessions;
    if (sessions.isEmpty) return null;
    final selectedIndex = sessions.indexWhere(
      (session) => session.id == widget.selectedSessionId,
    );
    final targetIndex = _keyboardIndex >= 0 ? _keyboardIndex : selectedIndex;
    if (targetIndex >= 0 && targetIndex < sessions.length) {
      widget.onSessionSelected(sessions[targetIndex].id);
    }
    return null;
  }

  void _select(PiSessionSummary session, int index) {
    _listFocusNode.requestFocus();
    setState(() => _keyboardIndex = index);
    widget.onSessionSelected(session.id);
  }

  Future<void> _showRenameDialog(PiSessionSummary session) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _SessionRenameDialog(
        initialName: session.hasCustomName ? session.title : '',
      ),
    );
    if (!mounted || name == null || name.trim().isEmpty) return;
    widget.onRenameSession?.call(session, name.trim());
  }

  void _requestDelete(PiSessionSummary session) {
    setState(() => _deleteConfirmationSessionId = session.id);
  }

  void _cancelDelete() {
    setState(() => _deleteConfirmationSessionId = null);
  }

  void _confirmDelete(PiSessionSummary session) {
    setState(() => _deleteConfirmationSessionId = null);
    widget.onDeleteSessionConfirmed?.call(
      PiDeleteSessionConfirmation.confirmed(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _filteredSessions;
    final hasFilter = _filterController.text.trim().isNotEmpty;

    return Semantics(
      container: true,
      label: '${widget.title} browser',
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${widget.sessions.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.onRefresh != null)
                    IconButton(
                      key: const Key('sessionBrowserRefreshButton'),
                      tooltip: 'Refresh sessions',
                      onPressed: widget.isLoading ? null : widget.onRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                key: const Key('sessionBrowserFilterField'),
                controller: _filterController,
                onChanged: (_) => setState(() => _keyboardIndex = -1),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Filter sessions',
                  hintText: 'Title or working directory',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: hasFilter
                      ? IconButton(
                          tooltip: 'Clear session filter',
                          onPressed: () {
                            _filterController.clear();
                            setState(() => _keyboardIndex = -1);
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            if (widget.isLoading && widget.sessions.isNotEmpty)
              Semantics(
                label: 'Refreshing sessions',
                child: const LinearProgressIndicator(),
              ),
            if (widget.errorMessage != null)
              Semantics(
                liveRegion: true,
                child: MaterialBanner(
                  key: const Key('sessionBrowserErrorBanner'),
                  content: Text(widget.errorMessage!),
                  leading: Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  actions: [
                    if (widget.onRetry != null)
                      TextButton(
                        key: const Key('sessionBrowserRetryButton'),
                        onPressed: widget.onRetry,
                        child: const Text('Retry'),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            Expanded(
              child: _buildContent(context, sessions, hasFilter: hasFilter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PiSessionSummary> sessions, {
    required bool hasFilter,
  }) {
    if (widget.isLoading && widget.sessions.isEmpty) {
      return const _SessionBrowserState(
        progress: true,
        icon: Icons.sync_rounded,
        title: 'Loading sessions',
        message: 'Fetching session summaries from Pi Node.',
      );
    }
    if (sessions.isEmpty) {
      return _SessionBrowserState(
        icon: hasFilter ? Icons.search_off_rounded : Icons.chat_outlined,
        title: hasFilter ? 'No matching sessions' : 'No sessions yet',
        message: hasFilter
            ? 'Try another title or working directory.'
            : 'Create a session to start working with Pi.',
        actionLabel: hasFilter || widget.onCreateSession == null
            ? null
            : 'Create session',
        onAction: hasFilter ? null : widget.onCreateSession,
      );
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown):
            _MoveSessionSelectionIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp):
            _MoveSessionSelectionIntent(-1),
        SingleActivator(LogicalKeyboardKey.enter):
            _ActivateSessionSelectionIntent(),
        SingleActivator(LogicalKeyboardKey.space):
            _ActivateSessionSelectionIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveSessionSelectionIntent:
              CallbackAction<_MoveSessionSelectionIntent>(
                onInvoke: _moveSelection,
              ),
          _ActivateSessionSelectionIntent:
              CallbackAction<_ActivateSessionSelectionIntent>(
                onInvoke: _activateSelection,
              ),
        },
        child: Focus(
          focusNode: _listFocusNode,
          child: Semantics(
            label: 'Session list, ${sessions.length} items',
            explicitChildNodes: true,
            child: ListView.builder(
              key: const Key('sessionBrowserList'),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final busy = widget.sessionActionInProgressId == session.id;
                return Column(
                  key: ValueKey<PiSessionId>(session.id),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SessionTile(
                      session: session,
                      selected: session.id == widget.selectedSessionId,
                      busy: busy,
                      busyOperation: busy
                          ? widget.sessionActionInProgressOperation
                          : null,
                      onTap: () => _select(session, index),
                      onRename: widget.onRenameSession == null
                          ? null
                          : () => _showRenameDialog(session),
                      onClearName:
                          widget.onClearSessionName == null ||
                              !session.hasCustomName
                          ? null
                          : () => widget.onClearSessionName!(session),
                      onAutoName: widget.onAutoNameSession == null
                          ? null
                          : () => widget.onAutoNameSession!(session),
                      onDelete: widget.onDeleteSessionConfirmed == null
                          ? null
                          : () => _requestDelete(session),
                    ),
                    if (_deleteConfirmationSessionId == session.id)
                      _SessionDeleteConfirmation(
                        session: session,
                        onCancel: _cancelDelete,
                        onConfirm: () => _confirmDelete(session),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionRenameDialog extends StatefulWidget {
  const _SessionRenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_SessionRenameDialog> createState() => _SessionRenameDialogState();
}

class _SessionRenameDialogState extends State<_SessionRenameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const Key('sessionRenameDialog'),
    title: const Text('Rename session'),
    content: TextField(
      key: const Key('sessionRenameField'),
      controller: _controller,
      autofocus: true,
      maxLength: 120,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Custom session name',
        hintText: 'Describe this session',
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('sessionRenameSaveButton'),
        onPressed: _submit,
        child: const Text('Save name'),
      ),
    ],
  );
}

enum _SessionAction { rename, clearName, autoName, delete }

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.selected,
    required this.busy,
    required this.onTap,
    this.busyOperation,
    this.onRename,
    this.onClearName,
    this.onAutoName,
    this.onDelete,
  });

  final PiSessionSummary session;
  final bool selected;
  final bool busy;
  final PiSessionAdminOperation? busyOperation;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onClearName;
  final VoidCallback? onAutoName;
  final VoidCallback? onDelete;

  bool get _hasActions =>
      onRename != null ||
      onClearName != null ||
      onAutoName != null ||
      onDelete != null;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final localTime = session.updatedAt.toLocal();
    final modified =
        '${localizations.formatMediumDate(localTime)} '
        '${TimeOfDay.fromDateTime(localTime).format(context)}';

    return Semantics(
      selected: selected,
      button: true,
      label:
          '${session.title}. ${session.workingDirectory}. '
          'Updated $modified${session.isRunning ? '. Running' : ''}'
          '${session.hasUnread ? '. Unread activity' : ''}',
      child: ListTile(
        selected: selected,
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded),
            if (session.isRunning)
              Positioned(
                right: -3,
                top: -3,
                child: Semantics(
                  label: 'Running',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 10),
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
          session.workingDirectory,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session.hasUnread)
              Semantics(
                label: 'Unread activity',
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (busy)
              Semantics(
                key: ValueKey<String>(
                  'sessionActionProgress-${session.id.value}',
                ),
                liveRegion: true,
                label: 'Session ${busyOperation?.name ?? 'action'} in progress',
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_hasActions)
              PopupMenuButton<_SessionAction>(
                key: ValueKey<String>('sessionActions-${session.id.value}'),
                tooltip: 'Session actions for ${session.title}',
                onSelected: (action) {
                  switch (action) {
                    case _SessionAction.rename:
                      onRename?.call();
                    case _SessionAction.clearName:
                      onClearName?.call();
                    case _SessionAction.autoName:
                      onAutoName?.call();
                    case _SessionAction.delete:
                      onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (onRename != null)
                    const PopupMenuItem(
                      value: _SessionAction.rename,
                      child: ListTile(
                        leading: Icon(Icons.drive_file_rename_outline_rounded),
                        title: Text('Rename'),
                      ),
                    ),
                  if (onClearName != null)
                    const PopupMenuItem(
                      value: _SessionAction.clearName,
                      child: ListTile(
                        leading: Icon(Icons.backspace_outlined),
                        title: Text('Clear custom name'),
                      ),
                    ),
                  if (onAutoName != null)
                    const PopupMenuItem(
                      value: _SessionAction.autoName,
                      child: ListTile(
                        leading: Icon(Icons.auto_awesome_outlined),
                        title: Text('Generate name'),
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: _SessionAction.delete,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              Tooltip(
                message: 'Updated $modified',
                child: const Icon(Icons.chevron_right_rounded, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionDeleteConfirmation extends StatelessWidget {
  const _SessionDeleteConfirmation({
    required this.session,
    required this.onCancel,
    required this.onConfirm,
  });

  final PiSessionSummary session;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Semantics(
    key: ValueKey<String>(
      'sessionDeleteConfirmationSemantics-${session.id.value}',
    ),
    container: true,
    liveRegion: true,
    label: 'Confirm deletion of ${session.title}',
    child: Container(
      key: ValueKey<String>('sessionDeleteConfirmation-${session.id.value}'),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Delete “${session.title}”?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The session file will be removed. Child sessions are reparented; projects, worktrees, and branches are not deleted.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                key: const Key('sessionDeleteCancelButton'),
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('sessionDeleteConfirmButton'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: onConfirm,
                child: const Text('Delete session'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SessionBrowserState extends StatelessWidget {
  const _SessionBrowserState({
    required this.icon,
    required this.title,
    required this.message,
    this.progress = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool progress;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Semantics(
        liveRegion: progress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress)
              const CircularProgressIndicator()
            else
              Icon(
                icon,
                size: 42,
                color: Theme.of(context).colorScheme.outline,
              ),
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('sessionBrowserEmptyAction'),
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

final class _MoveSessionSelectionIntent extends Intent {
  const _MoveSessionSelectionIntent(this.delta);

  final int delta;
}

final class _ActivateSessionSelectionIntent extends Intent {
  const _ActivateSessionSelectionIntent();
}
