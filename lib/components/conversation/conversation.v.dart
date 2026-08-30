part of 'conversation.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({
    required this.messages,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.editableMessageIds = const <PiMessageId>{},
    this.forkableMessageIds = const <PiMessageId>{},
    this.onEditFromHere,
    this.onForkFromHere,
    this.branchActionsEnabled = true,
    this.scrollController,
    this.followLatest = true,
    super.key,
  });

  final PiSessionSummary? session;
  final List<PiMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Set<PiMessageId> editableMessageIds;
  final Set<PiMessageId> forkableMessageIds;
  final ValueChanged<PiMessage>? onEditFromHere;
  final ValueChanged<PiMessage>? onForkFromHere;
  final bool branchActionsEnabled;
  final ScrollController? scrollController;
  final bool followLatest;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final ScrollController _ownedScrollController = ScrollController();

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController;

  @override
  void didUpdateWidget(ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.followLatest ||
        !_tailChanged(oldWidget.messages, widget.messages)) {
      return;
    }
    final followFromEmpty = oldWidget.messages.isEmpty;
    final shouldFollow = followFromEmpty || _isNearTail();
    if (!shouldFollow) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (followFromEmpty) {
        _jumpToTail();
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToTail());
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToTail() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  bool _isNearTail() {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.extentAfter <= 96;
  }

  bool _tailChanged(List<PiMessage> oldMessages, List<PiMessage> newMessages) {
    if (oldMessages.length != newMessages.length) return true;
    if (oldMessages.isEmpty) return false;
    final oldTail = oldMessages.last;
    final newTail = newMessages.last;
    return oldTail.id != newTail.id ||
        oldTail.text != newTail.text ||
        oldTail.isStreaming != newTail.isStreaming;
  }

  @override
  void dispose() {
    _ownedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: widget.session == null
        ? 'Conversation'
        : 'Conversation for ${widget.session!.title}',
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConversationHeader(session: widget.session),
          if (widget.isLoading && widget.messages.isNotEmpty)
            Semantics(
              label: 'Refreshing conversation',
              child: const LinearProgressIndicator(),
            ),
          if (widget.errorMessage != null)
            Semantics(
              liveRegion: true,
              child: MaterialBanner(
                key: const Key('conversationErrorBanner'),
                content: Text(widget.errorMessage!),
                leading: Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                actions: [
                  if (widget.onRetry != null)
                    TextButton(
                      key: const Key('conversationRetryButton'),
                      onPressed: widget.onRetry,
                      child: const Text('Retry'),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          Expanded(child: _buildTimeline(context)),
        ],
      ),
    ),
  );

  Widget _buildTimeline(BuildContext context) {
    if (widget.isLoading && widget.messages.isEmpty) {
      return const _ConversationEmptyState(
        progress: true,
        icon: Icons.sync_rounded,
        title: 'Loading conversation',
        message: 'Fetching messages from Pi Node.',
      );
    }
    if (widget.session == null) {
      return const _ConversationEmptyState(
        icon: Icons.chat_outlined,
        title: 'Select a session',
        message: 'Choose a Pi session to view its conversation.',
      );
    }
    if (widget.messages.isEmpty) {
      return const _ConversationEmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'Ready for a prompt',
        message: 'This session has no visible messages yet.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 520 ? 12.0 : 20.0;
        final bubbleWidth = constraints.maxWidth < 800
            ? constraints.maxWidth - horizontalPadding * 2
            : 760.0;
        return Semantics(
          label: 'Message timeline, ${widget.messages.length} messages',
          explicitChildNodes: true,
          child: ListView.separated(
            key: const Key('conversationTimeline'),
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              16,
            ),
            itemCount: widget.messages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              final editable = widget.editableMessageIds.contains(message.id);
              final forkable = widget.forkableMessageIds.contains(message.id);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PiMessageBubble(message: message, maxWidth: bubbleWidth),
                  if (message.role == PiMessageRole.user &&
                      (editable || forkable))
                    _MessageBranchActions(
                      message: message,
                      enabled: widget.branchActionsEnabled,
                      onEditFromHere: editable && widget.onEditFromHere != null
                          ? () => widget.onEditFromHere!(message)
                          : null,
                      onForkFromHere: forkable && widget.onForkFromHere != null
                          ? () => widget.onForkFromHere!(message)
                          : null,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MessageBranchActions extends StatelessWidget {
  const _MessageBranchActions({
    required this.message,
    required this.enabled,
    required this.onEditFromHere,
    required this.onForkFromHere,
  });

  final PiMessage message;
  final bool enabled;
  final VoidCallback? onEditFromHere;
  final VoidCallback? onForkFromHere;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Branch actions for user message',
    child: Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 4,
        children: [
          if (onEditFromHere != null)
            TextButton.icon(
              key: ValueKey<String>('messageEditFromHere-${message.id.value}'),
              onPressed: enabled ? onEditFromHere : null,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Edit from here'),
            ),
          if (onForkFromHere != null)
            TextButton.icon(
              key: ValueKey<String>('messageForkFromHere-${message.id.value}'),
              onPressed: enabled ? onForkFromHere : null,
              icon: const Icon(Icons.fork_right_rounded, size: 18),
              label: const Text('Fork'),
            ),
        ],
      ),
    ),
  );
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.session});

  final PiSessionSummary? session;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session?.title ?? 'Conversation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                session?.workingDirectory ??
                    'No session is currently selected.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (session?.isRunning ?? false)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Tooltip(
              message: 'Agent running',
              child: Semantics(
                label: 'Agent running',
                child: const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        if (session?.hasUnread ?? false)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Tooltip(
              message: 'Unread activity',
              child: Semantics(
                label: 'Unread activity',
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ConversationEmptyState extends StatelessWidget {
  const _ConversationEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.progress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool progress;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
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
                size: 44,
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
          ],
        ),
      ),
    ),
  );
}
