part of 'conversation.dart';

const int _maxConversationPreviewBytes = 1024 * 1024;
const Duration _streamingParseDebounce = Duration(milliseconds: 180);
const Duration _liveRegionThrottle = Duration(milliseconds: 700);

class ConversationView extends StatefulWidget {
  const ConversationView({
    required this.entries,
    this.session,
    this.projectId,
    this.piNodeApi,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.canLoadOlder = false,
    this.isLoadingOlder = false,
    this.onLoadOlder,
    this.editableEntryIds = const <PiSessionTreeEntryId>{},
    this.forkableEntryIds = const <PiSessionTreeEntryId>{},
    this.onEditFromHere,
    this.onForkFromHere,
    this.branchActionsEnabled = true,
    this.scrollController,
    this.followLatest = true,
    this.onEntryRendered,
    super.key,
  });

  final PiSessionSummary? session;
  final List<PiConversationEntry> entries;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool canLoadOlder;
  final bool isLoadingOlder;
  final VoidCallback? onLoadOlder;
  final Set<PiSessionTreeEntryId> editableEntryIds;
  final Set<PiSessionTreeEntryId> forkableEntryIds;
  final ValueChanged<PiConversationEntry>? onEditFromHere;
  final ValueChanged<PiConversationEntry>? onForkFromHere;
  final bool branchActionsEnabled;
  final ScrollController? scrollController;
  final bool followLatest;

  /// Optional performance-test observer. It is called only when an entry's
  /// revision-aware semantic subtree is replaced, not for unchanged peers.
  final ConversationEntryRenderObserver? onEntryRendered;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final ScrollController _ownedScrollController = ScrollController();
  final GlobalKey _timelineViewportKey = GlobalKey(
    debugLabel: 'conversation timeline viewport',
  );
  final Map<String, GlobalKey> _entryKeys = <String, GlobalKey>{};
  _OlderHistoryAnchor? _olderHistoryAnchor;
  DeferredImageController? _imageController;
  Timer? _announcementTimer;
  String? _pendingAnnouncement;
  String? _announcement;

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController;

  @override
  void initState() {
    super.initState();
    _replaceImageController();
  }

  @override
  void didUpdateWidget(ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.piNodeApi != widget.piNodeApi) {
      _replaceImageController();
    }
    if (oldWidget.session?.id != widget.session?.id) {
      final oldSessionId = oldWidget.session?.id;
      if (oldSessionId != null) {
        unawaited(_imageController?.cancelSession(oldSessionId));
      }
      _announcementTimer?.cancel();
      _announcementTimer = null;
      _pendingAnnouncement = null;
      _announcement = null;
      _entryKeys.clear();
    } else {
      final currentEntryIds = widget.entries
          .map((entry) => entry.identity.entryId)
          .toSet();
      _entryKeys.removeWhere(
        (entryId, _) => !currentEntryIds.contains(entryId),
      );
    }
    final olderAnchor = _olderHistoryAnchor;
    if (olderAnchor != null && widget.entries.length > olderAnchor.entryCount) {
      _olderHistoryAnchor = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreOlderHistoryAnchor(olderAnchor);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _restoreOlderHistoryAnchor(olderAnchor),
        );
      });
      return;
    }
    if (!widget.isLoadingOlder && oldWidget.isLoadingOlder) {
      _olderHistoryAnchor = null;
    }
    if (_tailChanged(oldWidget.entries, widget.entries)) {
      _scheduleLiveAnnouncement();
    }
    if (!widget.followLatest ||
        !_tailChanged(oldWidget.entries, widget.entries)) {
      return;
    }
    final followFromEmpty = oldWidget.entries.isEmpty;
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

  void _replaceImageController() {
    final previous = _imageController;
    final api = widget.piNodeApi;
    _imageController = api == null ? null : DeferredImageController(api: api);
    if (previous != null) unawaited(previous.dispose());
  }

  void _scheduleLiveAnnouncement() {
    if (widget.entries.isEmpty) return;
    final tail = widget.entries.last;
    _pendingAnnouncement = tail.finalized
        ? '${_entryLabel(tail)} complete'
        : '${_entryLabel(tail)} updated';
    if (_announcementTimer != null) return;
    _announcementTimer = Timer(_liveRegionThrottle, () {
      _announcementTimer = null;
      if (!mounted) return;
      final next = _pendingAnnouncement;
      _pendingAnnouncement = null;
      if (next == null) return;
      setState(() => _announcement = next);
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

  void _requestOlderHistory() {
    if (_scrollController.hasClients) {
      final visibleAnchor = _firstVisibleEntryAnchor();
      _olderHistoryAnchor = _OlderHistoryAnchor(
        entryCount: widget.entries.length,
        pixels: _scrollController.position.pixels,
        maxExtent: _scrollController.position.maxScrollExtent,
        entryId: visibleAnchor?.entryId,
        viewportOffset: visibleAnchor?.viewportOffset,
      );
    }
    widget.onLoadOlder?.call();
  }

  _VisibleEntryAnchor? _firstVisibleEntryAnchor() {
    final viewportBox =
        _timelineViewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null || !viewportBox.attached) return null;
    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + viewportBox.size.height;
    for (final entry in widget.entries) {
      final entryBox =
          _entryKeys[entry.identity.entryId]?.currentContext?.findRenderObject()
              as RenderBox?;
      if (entryBox == null || !entryBox.attached) continue;
      final entryTop = entryBox.localToGlobal(Offset.zero).dy;
      final entryBottom = entryTop + entryBox.size.height;
      if (entryBottom >= viewportTop && entryTop <= viewportBottom) {
        return _VisibleEntryAnchor(
          entryId: entry.identity.entryId,
          viewportOffset: entryTop - viewportTop,
        );
      }
    }
    return null;
  }

  void _restoreOlderHistoryAnchor(_OlderHistoryAnchor anchor) {
    if (!mounted || !_scrollController.hasClients) return;
    final target = _restoredAnchorOffset(anchor);
    final fallbackAddedExtent =
        _scrollController.position.maxScrollExtent - anchor.maxExtent;
    _scrollController.jumpTo(
      (target ?? anchor.pixels + fallbackAddedExtent).clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  double? _restoredAnchorOffset(_OlderHistoryAnchor anchor) {
    final entryId = anchor.entryId;
    final previousViewportOffset = anchor.viewportOffset;
    if (entryId == null || previousViewportOffset == null) return null;
    final viewportBox =
        _timelineViewportKey.currentContext?.findRenderObject() as RenderBox?;
    final entryBox =
        _entryKeys[entryId]?.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null ||
        entryBox == null ||
        !viewportBox.attached ||
        !entryBox.attached) {
      return null;
    }
    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final entryTop = entryBox.localToGlobal(Offset.zero).dy;
    final currentViewportOffset = entryTop - viewportTop;
    return _scrollController.position.pixels +
        currentViewportOffset -
        previousViewportOffset;
  }

  bool _tailChanged(
    List<PiConversationEntry> oldEntries,
    List<PiConversationEntry> newEntries,
  ) {
    if (oldEntries.length != newEntries.length) return true;
    if (oldEntries.isEmpty) return false;
    final oldTail = oldEntries.last;
    final newTail = newEntries.last;
    return oldTail.identity.entryId != newTail.identity.entryId ||
        oldTail.revision != newTail.revision ||
        oldTail.finalized != newTail.finalized;
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    final controller = _imageController;
    _imageController = null;
    if (controller != null) unawaited(controller.dispose());
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
          if (widget.isLoading && widget.entries.isNotEmpty)
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
          if (_announcement != null)
            SizedBox.square(
              dimension: 1,
              child: Semantics(liveRegion: true, label: _announcement),
            ),
          Expanded(child: _buildTimeline(context)),
        ],
      ),
    ),
  );

  Widget _buildTimeline(BuildContext context) {
    if (widget.isLoading && widget.entries.isEmpty) {
      return const _ConversationEmptyState(
        progress: true,
        icon: Icons.sync_rounded,
        title: 'Loading conversation',
        message: 'Fetching semantic entries from Pi Node.',
      );
    }
    if (widget.session == null) {
      return const _ConversationEmptyState(
        icon: Icons.chat_outlined,
        title: 'Select a session',
        message: 'Choose a Pi session to view its conversation.',
      );
    }
    if (widget.entries.isEmpty) {
      return const _ConversationEmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'Ready for a prompt',
        message: 'This session has no visible entries yet.',
      );
    }

    final projection = _ConversationProjection.fromEntries(widget.entries);
    return Column(
      children: [
        if (widget.canLoadOlder || widget.isLoadingOlder)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Center(
              child: OutlinedButton.icon(
                key: const Key('conversationLoadOlderButton'),
                onPressed: widget.isLoadingOlder ? null : _requestOlderHistory,
                icon: widget.isLoadingOlder
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.history_rounded, size: 18),
                label: Text(
                  widget.isLoadingOlder ? 'Loading older…' : 'Load older',
                ),
              ),
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            key: _timelineViewportKey,
            builder: (context, constraints) {
              final showMinimap = constraints.maxWidth >= 1000;
              final horizontalPadding = constraints.maxWidth < 520
                  ? 12.0
                  : 20.0;
              final contentWidth = showMinimap
                  ? constraints.maxWidth - 52
                  : constraints.maxWidth;
              final bubbleWidth = contentWidth < 800
                  ? contentWidth - horizontalPadding * 2
                  : 760.0;
              final timeline = Semantics(
                label:
                    'Conversation timeline, ${widget.entries.length} semantic entries',
                explicitChildNodes: true,
                child: ListView.separated(
                  key: const Key('conversationTimeline'),
                  controller: _scrollController,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  cacheExtent: 640,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    16,
                  ),
                  itemCount: projection.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = projection.items[index];
                    final entry = item.entry;
                    final treeId = PiSessionTreeEntryId(entry.identity.entryId);
                    final persistedUser =
                        entry is PiUserConversationEntry &&
                        entry.identity.scope ==
                            PiConversationIdentityScope.persistent;
                    final editable =
                        persistedUser &&
                        widget.editableEntryIds.contains(treeId);
                    final forkable =
                        persistedUser &&
                        widget.forkableEntryIds.contains(treeId);
                    return Column(
                      key: _entryKeys.putIfAbsent(
                        entry.identity.entryId,
                        () => GlobalKey(
                          debugLabel: 'entry ${entry.identity.entryId}',
                        ),
                      ),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ConversationEntryTile(
                          key: ValueKey<String>(
                            'conversation-entry-${entry.identity.entryId}',
                          ),
                          entry: entry,
                          groupedToolResults: item.groupedToolResults,
                          sessionId: widget.session!.id,
                          projectId: widget.projectId,
                          piNodeApi: widget.piNodeApi,
                          imageController: _imageController,
                          maxWidth: bubbleWidth.clamp(240, 760),
                          onRendered: widget.onEntryRendered,
                        ),
                        if (persistedUser && (editable || forkable))
                          _MessageBranchActions(
                            entry: entry,
                            enabled: widget.branchActionsEnabled,
                            onEditFromHere:
                                editable && widget.onEditFromHere != null
                                ? () => widget.onEditFromHere!(entry)
                                : null,
                            onForkFromHere:
                                forkable && widget.onForkFromHere != null
                                ? () => widget.onForkFromHere!(entry)
                                : null,
                          ),
                      ],
                    );
                  },
                ),
              );
              return Row(
                children: [
                  Expanded(child: timeline),
                  if (showMinimap)
                    _ActivityMinimap(
                      entries: projection.items
                          .map((item) => item.entry)
                          .toList(growable: false),
                      controller: _scrollController,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _ConversationProjection {
  const _ConversationProjection(this.items);

  factory _ConversationProjection.fromEntries(
    List<PiConversationEntry> entries,
  ) {
    final toolResults = <String, List<PiToolResultConversationEntry>>{};
    for (final entry in entries) {
      if (entry case PiToolResultConversationEntry(:final toolCallId)) {
        toolResults.putIfAbsent(toolCallId, () => []).add(entry);
      }
    }
    final groupedIds = <String>{};
    final items = <_ConversationProjectionItem>[];
    for (final entry in entries) {
      if (entry is PiAssistantConversationEntry) {
        final callIds = <String>{
          ...entry.parts.whereType<PiToolCallConversationPart>().map(
            (part) => part.toolCallId,
          ),
          ...entry.toolActivities.map((activity) => activity.toolCallId),
        };
        final grouped = <PiToolResultConversationEntry>[];
        for (final callId in callIds) {
          final matches = toolResults[callId];
          if (matches == null) continue;
          grouped.addAll(matches);
          groupedIds.addAll(matches.map((result) => result.identity.entryId));
        }
        items.add(_ConversationProjectionItem(entry, grouped));
        continue;
      }
      if (entry is PiToolResultConversationEntry &&
          groupedIds.contains(entry.identity.entryId)) {
        continue;
      }
      items.add(_ConversationProjectionItem(entry, const []));
    }
    return _ConversationProjection(List.unmodifiable(items));
  }

  final List<_ConversationProjectionItem> items;
}

final class _ConversationProjectionItem {
  const _ConversationProjectionItem(this.entry, this.groupedToolResults);

  final PiConversationEntry entry;
  final List<PiToolResultConversationEntry> groupedToolResults;
}

class _ConversationEntryTile extends StatefulWidget {
  const _ConversationEntryTile({
    required this.entry,
    required this.groupedToolResults,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.maxWidth,
    required this.onRendered,
    super.key,
  });

  final PiConversationEntry entry;
  final List<PiToolResultConversationEntry> groupedToolResults;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final double maxWidth;
  final ConversationEntryRenderObserver? onRendered;

  @override
  State<_ConversationEntryTile> createState() => _ConversationEntryTileState();
}

class _ConversationEntryTileState extends State<_ConversationEntryTile> {
  Timer? _parseTimer;
  late bool _fullParseReady;
  String? _cachedSignature;
  Widget? _cachedChild;

  @override
  void initState() {
    super.initState();
    _fullParseReady = widget.entry.finalized;
  }

  @override
  void didUpdateWidget(covariant _ConversationEntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.identity.entryId != widget.entry.identity.entryId) {
      _parseTimer?.cancel();
      _fullParseReady = widget.entry.finalized;
      _invalidate();
      return;
    }
    if (oldWidget.entry.revision == widget.entry.revision &&
        _resultSignature(oldWidget.groupedToolResults) ==
            _resultSignature(widget.groupedToolResults) &&
        oldWidget.sessionId == widget.sessionId &&
        oldWidget.maxWidth == widget.maxWidth &&
        oldWidget.projectId == widget.projectId &&
        oldWidget.piNodeApi == widget.piNodeApi &&
        oldWidget.imageController == widget.imageController) {
      return;
    }
    if (!widget.entry.finalized) {
      _parseTimer?.cancel();
      _fullParseReady = false;
    } else if (!oldWidget.entry.finalized ||
        oldWidget.entry.revision != widget.entry.revision) {
      _fullParseReady = false;
      _parseTimer?.cancel();
      _parseTimer = Timer(_streamingParseDebounce, () {
        if (!mounted) return;
        setState(() {
          _fullParseReady = true;
          _invalidate();
        });
      });
    }
    _invalidate();
  }

  void _invalidate() {
    _cachedSignature = null;
    _cachedChild = null;
  }

  @override
  void dispose() {
    _parseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signature =
        '${widget.entry.identity.entryId}:${widget.entry.revision}:'
        '${widget.entry.finalized}:$_fullParseReady:'
        '${_resultSignature(widget.groupedToolResults)}:${widget.maxWidth}';
    if (_cachedSignature != signature || _cachedChild == null) {
      _cachedSignature = signature;
      widget.onRendered?.call(
        widget.entry.identity.entryId,
        widget.entry.revision,
      );
      _cachedChild = _ConversationEntryCard(
        entry: widget.entry,
        groupedToolResults: widget.groupedToolResults,
        sessionId: widget.sessionId,
        projectId: widget.projectId,
        piNodeApi: widget.piNodeApi,
        imageController: widget.imageController,
        maxWidth: widget.maxWidth,
        lightweight: !_fullParseReady,
      );
    }
    return RepaintBoundary(child: _cachedChild!);
  }
}

String _resultSignature(List<PiToolResultConversationEntry> results) => results
    .map((result) => '${result.identity.entryId}:${result.revision}')
    .join('|');

class _ConversationEntryCard extends StatelessWidget {
  const _ConversationEntryCard({
    required this.entry,
    required this.groupedToolResults,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.maxWidth,
    required this.lightweight,
  });

  final PiConversationEntry entry;
  final List<PiToolResultConversationEntry> groupedToolResults;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final double maxWidth;
  final bool lightweight;

  @override
  Widget build(BuildContext context) => switch (entry) {
    PiUserConversationEntry() => _messageCard(context, user: true),
    PiAssistantConversationEntry() => _messageCard(context, user: false),
    PiToolResultConversationEntry() => _standaloneToolResult(context),
    PiBashConversationEntry() => _bashCard(context),
    PiCustomConversationEntry() => _customCard(context),
    PiCompactionConversationEntry() => _compactionCard(context),
    PiBranchSummaryConversationEntry() => _branchSummaryCard(context),
    PiMarkerConversationEntry() => _markerCard(context),
    PiUnknownConversationEntry() => _unknownCard(context),
  };

  Widget _messageCard(BuildContext context, {required bool user}) {
    final scheme = Theme.of(context).colorScheme;
    final assistant = entry is PiAssistantConversationEntry
        ? entry as PiAssistantConversationEntry
        : null;
    final raw = _entryRawText(entry);
    final plain = _plainText(raw);
    return Semantics(
      container: true,
      label:
          '${user ? 'You' : 'Pi'} message${entry.finalized ? '' : ', streaming'}',
      child: Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: user
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: !entry.finalized
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EntryHeader(
                    entry: entry,
                    label: user ? 'You' : 'Pi',
                    icon: user
                        ? Icons.person_outline_rounded
                        : Icons.auto_awesome_rounded,
                    subtitle: assistant == null
                        ? null
                        : '${assistant.provider} · ${assistant.model}',
                    rawText: raw,
                    plainText: plain,
                  ),
                  const SizedBox(height: 8),
                  _EntryPartsView(
                    entry: entry,
                    sessionId: sessionId,
                    projectId: projectId,
                    piNodeApi: piNodeApi,
                    imageController: imageController,
                    lightweight: lightweight,
                    defaultFormat: _TextFormat.markdown,
                  ),
                  if (assistant?.safeErrorMessage case final error?) ...[
                    const SizedBox(height: 8),
                    _ExpandableStatusPanel(
                      key: ValueKey<String>(
                        'assistant-error-${entry.identity.entryId}',
                      ),
                      title: 'Provider error',
                      icon: Icons.error_outline_rounded,
                      tone: _StatusTone.error,
                      initiallyExpanded: true,
                      child: SelectableText(error),
                    ),
                  ],
                  if (assistant != null &&
                      (assistant.parts.any(
                            (part) => part is PiToolCallConversationPart,
                          ) ||
                          assistant.toolActivities.isNotEmpty ||
                          groupedToolResults.isNotEmpty)) ...[
                    const SizedBox(height: 8),
                    _ToolActivityGroup(
                      assistant: assistant,
                      results: groupedToolResults,
                      sessionId: sessionId,
                      projectId: projectId,
                      piNodeApi: piNodeApi,
                      imageController: imageController,
                      lightweight: lightweight,
                    ),
                  ],
                  if (entry.metrics case final metrics?) ...[
                    const SizedBox(height: 8),
                    _MetricsFooter(metrics: metrics),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _standaloneToolResult(BuildContext context) {
    final result = entry as PiToolResultConversationEntry;
    return _ToolResultCard(
      result: result,
      sessionId: sessionId,
      projectId: projectId,
      piNodeApi: piNodeApi,
      imageController: imageController,
      lightweight: lightweight,
      grouped: false,
    );
  }

  Widget _bashCard(BuildContext context) {
    final bash = entry as PiBashConversationEntry;
    final failed =
        bash.cancelled || (bash.exitCode != null && bash.exitCode != 0);
    final output = _entryText(entry);
    return _BoundedCard(
      maxWidth: maxWidth,
      semanticLabel: 'Shell execution${failed ? ', failed' : ', succeeded'}',
      child: ExpansionTile(
        key: ValueKey<String>('bash-${entry.identity.entryId}'),
        initiallyExpanded: failed,
        leading: Icon(
          failed ? Icons.terminal_rounded : Icons.check_circle_outline_rounded,
          color: failed
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Shell'),
        subtitle: Text(
          bash.command,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: _EntryStatusChip(
          label: bash.cancelled
              ? 'Cancelled'
              : bash.exitCode == null
              ? (entry.finalized ? 'Complete' : 'Running')
              : 'Exit ${bash.exitCode}',
          tone: failed ? _StatusTone.error : _StatusTone.success,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (bash.truncated) const Chip(label: Text('Output truncated')),
              if (bash.excludedFromContext)
                const Chip(label: Text('Excluded from context')),
              _CopyActions(
                entryId: entry.identity.entryId,
                rawText: '${bash.command}\n$output',
                plainText: _plainText(output),
              ),
            ],
          ),
          if (output.isNotEmpty) ...[
            const SizedBox(height: 10),
            _RichTextPart(
              text: output,
              format: _TextFormat.ansi,
              lightweight: lightweight,
            ),
          ],
          if (entry.metrics case final metrics?) ...[
            const SizedBox(height: 8),
            _MetricsFooter(metrics: metrics),
          ],
        ],
      ),
    );
  }

  Widget _customCard(BuildContext context) {
    final custom = entry as PiCustomConversationEntry;
    return _SemanticEventCard(
      maxWidth: maxWidth,
      entry: entry,
      title: custom.customType,
      subtitle: custom.display
          ? 'Extension message'
          : 'Extension state (not marked for transcript display)',
      icon: Icons.extension_outlined,
      parts: _EntryPartsView(
        entry: entry,
        sessionId: sessionId,
        projectId: projectId,
        piNodeApi: piNodeApi,
        imageController: imageController,
        lightweight: lightweight,
        defaultFormat: custom.display
            ? _TextFormat.markdown
            : _TextFormat.plain,
      ),
      details: custom.safeDetails,
    );
  }

  Widget _compactionCard(BuildContext context) {
    final value = entry as PiCompactionConversationEntry;
    return _SemanticEventCard(
      maxWidth: maxWidth,
      entry: entry,
      title: 'Context compacted',
      subtitle:
          '${value.tokensBefore} tokens before compaction${value.fromHook ? ' · hook' : ''}',
      icon: Icons.compress_rounded,
      parts: _EntryPartsView(
        entry: entry,
        sessionId: sessionId,
        projectId: projectId,
        piNodeApi: piNodeApi,
        imageController: imageController,
        lightweight: lightweight,
        defaultFormat: _TextFormat.markdown,
      ),
      details: value.safeDetails,
    );
  }

  Widget _branchSummaryCard(BuildContext context) {
    final value = entry as PiBranchSummaryConversationEntry;
    return _SemanticEventCard(
      maxWidth: maxWidth,
      entry: entry,
      title: 'Branch summary',
      subtitle: value.fromHook ? 'Generated by hook' : 'Conversation branch',
      icon: Icons.fork_right_rounded,
      parts: _EntryPartsView(
        entry: entry,
        sessionId: sessionId,
        projectId: projectId,
        piNodeApi: piNodeApi,
        imageController: imageController,
        lightweight: lightweight,
        defaultFormat: _TextFormat.markdown,
      ),
      details: value.safeDetails,
    );
  }

  Widget _markerCard(BuildContext context) {
    final marker = entry as PiMarkerConversationEntry;
    final presentation = switch (marker.markerKind) {
      PiConversationMarkerKind.thinkingLevel => (
        Icons.psychology_outlined,
        'Thinking level',
        marker.thinkingLevel ?? 'Changed',
      ),
      PiConversationMarkerKind.modelChange => (
        Icons.model_training_outlined,
        'Model changed',
        '${marker.provider ?? 'Provider'} · ${marker.model ?? 'Model'}',
      ),
      PiConversationMarkerKind.label => (
        Icons.label_outline_rounded,
        'Session label',
        marker.label ?? 'Label updated',
      ),
      PiConversationMarkerKind.sessionInfo => (
        Icons.info_outline_rounded,
        'Session information',
        marker.label ?? 'Session metadata updated',
      ),
    };
    return _CompactEventCard(
      maxWidth: maxWidth,
      semanticLabel: '${presentation.$2}: ${presentation.$3}',
      icon: presentation.$1,
      title: presentation.$2,
      subtitle: presentation.$3,
    );
  }

  Widget _unknownCard(BuildContext context) {
    final unknown = entry as PiUnknownConversationEntry;
    return _SemanticEventCard(
      maxWidth: maxWidth,
      entry: entry,
      title: 'Unsupported conversation entry',
      subtitle: unknown.sourceType,
      icon: Icons.help_outline_rounded,
      parts: _EntryPartsView(
        entry: entry,
        sessionId: sessionId,
        projectId: projectId,
        piNodeApi: piNodeApi,
        imageController: imageController,
        lightweight: true,
        defaultFormat: _TextFormat.plain,
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  const _EntryHeader({
    required this.entry,
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.rawText,
    required this.plainText,
  });

  final PiConversationEntry entry;
  final String label;
  final IconData icon;
  final String? subtitle;
  final String rawText;
  final String plainText;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(
      entry.createdAt.toLocal(),
    ).format(context);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, size: 16),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          time,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (!entry.finalized)
          const SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        _CopyActions(
          entryId: entry.identity.entryId,
          rawText: rawText,
          plainText: plainText,
        ),
      ],
    );
  }
}

class _CopyActions extends StatelessWidget {
  const _CopyActions({
    required this.entryId,
    required this.rawText,
    required this.plainText,
  });

  final String entryId;
  final String rawText;
  final String plainText;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 2,
    children: [
      IconButton(
        key: ValueKey<String>('copyRaw-$entryId'),
        tooltip: 'Copy raw content',
        visualDensity: VisualDensity.compact,
        onPressed: rawText.isEmpty
            ? null
            : () => _copy(context, rawText, 'Raw content copied'),
        icon: const Icon(Icons.content_copy_rounded, size: 17),
      ),
      IconButton(
        key: ValueKey<String>('copyPlain-$entryId'),
        tooltip: 'Copy plain text',
        visualDensity: VisualDensity.compact,
        onPressed: plainText.isEmpty
            ? null
            : () => _copy(context, plainText, 'Plain text copied'),
        icon: const Icon(Icons.text_snippet_outlined, size: 17),
      ),
    ],
  );

  Future<void> _copy(BuildContext context, String text, String notice) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(notice)));
  }
}

class _EntryPartsView extends StatelessWidget {
  const _EntryPartsView({
    required this.entry,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.lightweight,
    required this.defaultFormat,
  });

  final PiConversationEntry entry;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final bool lightweight;
  final _TextFormat defaultFormat;

  @override
  Widget build(BuildContext context) {
    final visibleParts = entry.parts
        .where((part) => part is! PiToolCallConversationPart)
        .toList(growable: false);
    if (visibleParts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < visibleParts.length; index += 1) ...[
          _ConversationPartView(
            entry: entry,
            part: visibleParts[index],
            sessionId: sessionId,
            projectId: projectId,
            piNodeApi: piNodeApi,
            imageController: imageController,
            lightweight: lightweight,
            defaultFormat: defaultFormat,
          ),
          if (index + 1 < visibleParts.length) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ConversationPartView extends StatelessWidget {
  const _ConversationPartView({
    required this.entry,
    required this.part,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.lightweight,
    required this.defaultFormat,
  });

  final PiConversationEntry entry;
  final PiConversationPart part;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final bool lightweight;
  final _TextFormat defaultFormat;

  @override
  Widget build(BuildContext context) => switch (part) {
    PiTextConversationPart(:final text, :final contentReference) =>
      text != null
          ? _RichTextPart(
              text: text,
              format: _detectTextFormat(text, defaultFormat: defaultFormat),
              lightweight: lightweight,
            )
          : _DeferredTextPreview(
              api: piNodeApi,
              request: _contentRequest(contentReference!),
              defaultFormat: defaultFormat,
              lightweight: lightweight,
            ),
    PiThinkingConversationPart() => _ThinkingPartView(
      entry: entry,
      part: part as PiThinkingConversationPart,
      sessionId: sessionId,
      projectId: projectId,
      piNodeApi: piNodeApi,
      lightweight: lightweight,
    ),
    PiImageConversationPart(:final contentReference) =>
      imageController != null && projectId != null
          ? DeferredImageView(
              key: ValueKey<String>(
                'deferred-image-${entry.identity.entryId}-${part.partId}-${part.revision}',
              ),
              controller: imageController!,
              projectId: projectId!,
              binding: _binding(contentReference),
              reference: contentReference,
              maxHeight: 520,
            )
          : _ContentUnavailableCard(
              icon: Icons.image_outlined,
              title: contentReference.displayName,
              message: 'Image content requires an active Pi Node connection.',
            ),
    PiUnsupportedConversationPart(:final sourceType) => _ContentUnavailableCard(
      icon: Icons.extension_off_outlined,
      title: 'Unsupported content',
      message: sourceType,
    ),
    PiToolCallConversationPart() => const SizedBox.shrink(),
  };

  PiMessageContentRequest _contentRequest(
    PiMessageContentReference reference,
  ) => PiMessageContentRequest(
    projectId: projectId ?? PiProjectId('unavailable-project'),
    binding: _binding(reference),
    reference: reference,
  );

  PiMessageContentBinding _binding(PiMessageContentReference reference) =>
      PiMessageContentBinding(
        sessionId: sessionId,
        entryId: entry.identity.entryId,
        partId: part.partId,
        entryRevision: entry.revision,
        partRevision: part.revision,
        contentId: reference.contentId,
      );
}

class _ThinkingPartView extends StatelessWidget {
  const _ThinkingPartView({
    required this.entry,
    required this.part,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.lightweight,
  });

  final PiConversationEntry entry;
  final PiThinkingConversationPart part;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final bool lightweight;

  @override
  Widget build(BuildContext context) {
    final status = switch (part.visibility) {
      PiThinkingVisibility.visible => 'Visible reasoning',
      PiThinkingVisibility.redacted => 'Reasoning redacted by the provider',
      PiThinkingVisibility.deferred => 'Reasoning deferred by the provider',
    };
    Widget child;
    if (part.visibility != PiThinkingVisibility.visible) {
      child = Text(
        part.visibility == PiThinkingVisibility.redacted
            ? 'Private reasoning was not exposed to Pi Client.'
            : 'The provider returned a deferred response without exposing a private handle.',
      );
    } else if (part.text case final text?) {
      child = _RichTextPart(
        text: text,
        format: _TextFormat.markdown,
        lightweight: lightweight,
      );
    } else if (part.contentReference case final reference?) {
      child = _DeferredTextPreview(
        api: piNodeApi,
        request: PiMessageContentRequest(
          projectId: projectId ?? PiProjectId('unavailable-project'),
          binding: PiMessageContentBinding(
            sessionId: sessionId,
            entryId: entry.identity.entryId,
            partId: part.partId,
            entryRevision: entry.revision,
            partRevision: part.revision,
            contentId: reference.contentId,
          ),
          reference: reference,
        ),
        defaultFormat: _TextFormat.markdown,
        lightweight: lightweight,
      );
    } else {
      child = const Text('Reasoning content is unavailable.');
    }
    return Semantics(
      container: true,
      label: 'Thinking, $status, collapsed by default',
      child: Card.outlined(
        child: ExpansionTile(
          key: ValueKey<String>(
            'thinking-${entry.identity.entryId}-${part.partId}',
          ),
          initiallyExpanded: false,
          leading: const Icon(Icons.psychology_outlined),
          title: const Text('Thinking'),
          subtitle: Text(status),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [child],
        ),
      ),
    );
  }
}

class _RichTextPart extends StatelessWidget {
  const _RichTextPart({
    required this.text,
    required this.format,
    required this.lightweight,
  });

  final String text;
  final _TextFormat format;
  final bool lightweight;

  @override
  Widget build(BuildContext context) {
    final preview = _boundedPreviewText(text);
    final rendered = _boundedPreviewText(preview.text, maxBytes: 32 * 1024);
    final child = switch (format) {
      _TextFormat.markdown => MarkdownBody(
        data: rendered.text,
        streaming: lightweight,
        limits: const MarkdownRenderLimits(
          maxTextCharacters: 100000,
          maxAstNodes: 4000,
          maxDepth: 32,
          maxTableRows: 100,
          maxTableColumns: 20,
          maxCodeCharacters: 50000,
          maxMathCharacters: 4096,
          maxDiagramCharacters: 20000,
        ),
      ),
      _TextFormat.ansi => _BoundedPreview(
        child: AnsiText(
          rendered.text,
          semanticLabel: _boundedSemantic(
            const AnsiParser().parse(rendered.text).plainText,
          ),
        ),
      ),
      _TextFormat.json => CodeBlockView(
        code: rendered.text,
        language: 'json',
        lightweight: lightweight,
        maxCharacters: _maxConversationPreviewBytes,
      ),
      _TextFormat.unifiedDiff => DiffView(
        patch: rendered.text,
        height: 320,
        showToolbar: !lightweight,
      ),
      _TextFormat.code => CodeBlockView(
        code: rendered.text,
        lightweight: lightweight,
        maxCharacters: _maxConversationPreviewBytes,
      ),
      _TextFormat.plain => SelectionArea(
        child: Text(
          rendered.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ),
    };
    if (!preview.truncated && !rendered.truncated) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Semantics(
          liveRegion: true,
          child: Text(
            preview.truncated
                ? 'Preview limited to 1 MiB.'
                : 'Long content shortened for responsive rendering.',
            key: Key(
              preview.truncated
                  ? 'conversationPreviewLimit'
                  : 'conversationRenderLimit',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeferredTextPreview extends StatefulWidget {
  const _DeferredTextPreview({
    required this.api,
    required this.request,
    required this.defaultFormat,
    required this.lightweight,
  });

  final PiNodeApi? api;
  final PiMessageContentRequest request;
  final _TextFormat defaultFormat;
  final bool lightweight;

  @override
  State<_DeferredTextPreview> createState() => _DeferredTextPreviewState();
}

class _DeferredTextPreviewState extends State<_DeferredTextPreview> {
  PiMessageContentHandle? _handle;
  String? _text;
  String? _error;
  bool _truncated = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _DeferredTextPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api ||
        !_sameBinding(oldWidget.request.binding, widget.request.binding) ||
        oldWidget.request.reference.contentId !=
            widget.request.reference.contentId) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final previous = _handle;
    _handle = null;
    if (previous != null) await previous.cancel();
    if (!mounted || generation != _generation) return;
    final api = widget.api;
    if (api == null) {
      setState(() {
        _text = null;
        _truncated = false;
        _error = 'Text content requires an active Pi Node connection.';
      });
      return;
    }
    setState(() {
      _text = null;
      _error = null;
      _truncated = false;
    });
    try {
      final handle = await api.getMessageContent(widget.request);
      if (!mounted || generation != _generation) {
        await handle.cancel();
        return;
      }
      _handle = handle;
      final builder = BytesBuilder(copy: false);
      var truncated = false;
      await for (final chunk in handle.bytes) {
        if (!mounted || generation != _generation) {
          await handle.cancel();
          return;
        }
        final remaining = _maxConversationPreviewBytes - builder.length;
        if (remaining <= 0) {
          truncated = true;
          await handle.cancel();
          break;
        }
        if (chunk.length > remaining) {
          builder.add(chunk.sublist(0, remaining));
          truncated = true;
          await handle.cancel();
          break;
        }
        builder.add(chunk);
      }
      if (!truncated) await handle.done;
      final bytes = builder.takeBytes();
      if (!truncated) {
        if (bytes.length != widget.request.reference.totalBytes ||
            !_sameByteList(
              sha256.convert(bytes).bytes,
              widget.request.reference.sha256,
            )) {
          throw const FormatException(
            'Message content integrity check failed.',
          );
        }
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _handle = null;
        _text = utf8.decode(bytes, allowMalformed: true);
        _truncated = truncated;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _handle = null;
        _error = 'The deferred text preview could not be loaded safely.';
      });
    }
  }

  @override
  void dispose() {
    _generation += 1;
    final handle = _handle;
    _handle = null;
    if (handle != null) unawaited(handle.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _text;
    if (text != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _RichTextPart(
            text: text,
            format: _detectTextFormat(
              text,
              defaultFormat: widget.defaultFormat,
            ),
            lightweight: widget.lightweight,
          ),
          if (_truncated)
            Text(
              'Deferred preview limited to 1 MiB.',
              key: const Key('deferredTextPreviewLimit'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
        ],
      );
    }
    if (_error case final error?) {
      return _ContentUnavailableCard(
        icon: Icons.text_snippet_outlined,
        title: widget.request.reference.displayName,
        message: error,
        onRetry: _load,
      );
    }
    return Semantics(
      liveRegion: true,
      label: 'Loading deferred text preview',
      child: const LinearProgressIndicator(key: Key('deferredTextLoading')),
    );
  }
}

class _ToolActivityGroup extends StatelessWidget {
  const _ToolActivityGroup({
    required this.assistant,
    required this.results,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.lightweight,
  });

  final PiAssistantConversationEntry assistant;
  final List<PiToolResultConversationEntry> results;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final bool lightweight;

  @override
  Widget build(BuildContext context) {
    final calls = assistant.parts
        .whereType<PiToolCallConversationPart>()
        .toList();
    final activities = <String, PiToolActivity>{
      for (final activity in assistant.toolActivities)
        activity.toolCallId: activity,
    };
    final resultsByCall = <String, List<PiToolResultConversationEntry>>{};
    for (final result in results) {
      resultsByCall.putIfAbsent(result.toolCallId, () => []).add(result);
    }
    final callIds = <String>{
      ...calls.map((call) => call.toolCallId),
      ...activities.keys,
      ...resultsByCall.keys,
    };
    final projections = <_ToolProjection>[];
    for (final callId in callIds) {
      final callIndex = calls.indexWhere((call) => call.toolCallId == callId);
      final call = callIndex < 0 ? null : calls[callIndex];
      final activity = activities[callId];
      projections.add(
        _ToolProjection(
          callId: callId,
          toolName:
              call?.toolName ??
              activity?.toolName ??
              resultsByCall[callId]?.firstOrNull?.toolName ??
              'Tool',
          sourceOrdinal:
              activity?.sourceOrdinal ??
              (callIndex < 0 ? 0x7fffffff : callIndex),
          call: call,
          activity: activity,
          results: resultsByCall[callId] ?? const [],
        ),
      );
    }
    projections.sort((left, right) {
      final ordinal = left.sourceOrdinal.compareTo(right.sourceOrdinal);
      return ordinal != 0 ? ordinal : left.callId.compareTo(right.callId);
    });
    return Semantics(
      container: true,
      label: '${projections.length} tool activities in source order',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < projections.length; index += 1) ...[
            _ToolActivityCard(
              projection: projections[index],
              sessionId: sessionId,
              projectId: projectId,
              piNodeApi: piNodeApi,
              imageController: imageController,
              lightweight: lightweight,
            ),
            if (index + 1 < projections.length) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

final class _ToolProjection {
  const _ToolProjection({
    required this.callId,
    required this.toolName,
    required this.sourceOrdinal,
    required this.call,
    required this.activity,
    required this.results,
  });

  final String callId;
  final String toolName;
  final int sourceOrdinal;
  final PiToolCallConversationPart? call;
  final PiToolActivity? activity;
  final List<PiToolResultConversationEntry> results;
}

enum _ToolVisualStatus {
  queued,
  running,
  succeeded,
  failed,
  cancelled,
  blocked,
}

class _ToolActivityCard extends StatelessWidget {
  const _ToolActivityCard({
    required this.projection,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.lightweight,
  });

  final _ToolProjection projection;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final bool lightweight;

  @override
  Widget build(BuildContext context) {
    final status = _toolStatus(projection);
    final presentation = _toolStatusPresentation(status);
    final progress = projection.activity?.progressBasisPoints;
    final expanded =
        status == _ToolVisualStatus.failed ||
        status == _ToolVisualStatus.blocked ||
        status == _ToolVisualStatus.running;
    return Semantics(
      container: true,
      label:
          '${projection.toolName} tool, ${presentation.label}${progress == null ? '' : ', ${(progress / 100).toStringAsFixed(0)} percent'}',
      child: Card.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpansionTile(
              key: ValueKey<String>('tool-activity-${projection.callId}'),
              initiallyExpanded: expanded,
              leading: Icon(
                presentation.icon,
                color: presentation.color(context),
              ),
              title: Text(projection.toolName),
              subtitle: Text('Tool activity ${projection.sourceOrdinal + 1}'),
              trailing: _EntryStatusChip(
                label: presentation.label,
                tone: presentation.tone,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (projection.call case final call?)
                  _SafeDetailsPanel(
                    title: 'Arguments',
                    value: call.safeArguments,
                    initiallyExpanded: false,
                  ),
                if (projection.activity case final activity?) ...[
                  const SizedBox(height: 6),
                  _SafeDetailsPanel(
                    title: 'Progress details',
                    value: activity.safeDetails,
                    initiallyExpanded:
                        status == _ToolVisualStatus.failed ||
                        status == _ToolVisualStatus.blocked,
                  ),
                ],
                for (final result in projection.results) ...[
                  const SizedBox(height: 6),
                  _ToolResultCard(
                    result: result,
                    sessionId: sessionId,
                    projectId: projectId,
                    piNodeApi: piNodeApi,
                    imageController: imageController,
                    lightweight: lightweight,
                    grouped: true,
                  ),
                ],
              ],
            ),
            if (status == _ToolVisualStatus.running || progress != null)
              LinearProgressIndicator(
                value: progress == null ? null : progress / 10000,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolResultCard extends StatelessWidget {
  const _ToolResultCard({
    required this.result,
    required this.sessionId,
    required this.projectId,
    required this.piNodeApi,
    required this.imageController,
    required this.lightweight,
    required this.grouped,
  });

  final PiToolResultConversationEntry result;
  final PiSessionId sessionId;
  final PiProjectId? projectId;
  final PiNodeApi? piNodeApi;
  final DeferredImageController? imageController;
  final bool lightweight;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final text = _entryText(result);
    final payload = _StructuredToolPayload.from(result.safeDetails, text);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (result.parts.isNotEmpty)
          _EntryPartsView(
            entry: result,
            sessionId: sessionId,
            projectId: projectId,
            piNodeApi: piNodeApi,
            imageController: imageController,
            lightweight: lightweight,
            defaultFormat: payload.preferredFormat,
          ),
        _StructuredToolResultView(payload: payload, lightweight: lightweight),
        if (result.metrics case final metrics?) ...[
          const SizedBox(height: 8),
          _MetricsFooter(metrics: metrics),
        ],
      ],
    );
    final tile = ExpansionTile(
      key: ValueKey<String>('tool-result-${result.identity.entryId}'),
      initiallyExpanded: result.isError,
      leading: Icon(
        result.isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: result.isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(grouped ? 'Result' : result.toolName),
      subtitle: Text(result.isError ? 'Tool failed' : 'Tool succeeded'),
      trailing: _EntryStatusChip(
        label: result.isError ? 'Failed' : 'Succeeded',
        tone: result.isError ? _StatusTone.error : _StatusTone.success,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [body],
    );
    if (grouped) return tile;
    return _BoundedCard(
      maxWidth: 760,
      semanticLabel:
          '${result.toolName} tool result, ${result.isError ? 'failed' : 'succeeded'}',
      child: tile,
    );
  }
}

final class _StructuredToolPayload {
  const _StructuredToolPayload({
    required this.details,
    required this.preferredFormat,
    required this.filePath,
    required this.operation,
    required this.diff,
    required this.writtenFiles,
    required this.command,
    required this.processId,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  factory _StructuredToolPayload.from(PiSafeValue details, String text) {
    final object = details is PiSafeObject ? details : null;
    final formatName = _safeStringField(object, const [
      'format',
      'contentType',
      'mimeType',
      'language',
    ]);
    final diff = _safeStringField(object, const [
      'unifiedDiff',
      'diff',
      'patch',
    ]);
    final stdout = _safeStringField(object, const ['stdout', 'output']);
    final stderr = _safeStringField(object, const ['stderr', 'errorOutput']);
    final explicit = _formatFromName(formatName);
    return _StructuredToolPayload(
      details: details,
      preferredFormat:
          explicit ??
          _detectTextFormat(
            diff ?? stdout ?? text,
            defaultFormat: _TextFormat.plain,
          ),
      filePath: _safeStringField(object, const [
        'path',
        'filePath',
        'targetPath',
        'file',
      ]),
      operation: _safeStringField(object, const [
        'operation',
        'action',
        'mutation',
        'kind',
      ]),
      diff: diff,
      writtenFiles: _safeStringListField(object, const [
        'writtenFiles',
        'files',
        'paths',
      ]),
      command: _safeStringField(object, const ['command', 'cmd']),
      processId: _safeDisplayField(object, const ['processId', 'pid']),
      exitCode: _safeDisplayField(object, const ['exitCode', 'code']),
      stdout: stdout,
      stderr: stderr,
    );
  }

  final PiSafeValue details;
  final _TextFormat preferredFormat;
  final String? filePath;
  final String? operation;
  final String? diff;
  final List<String> writtenFiles;
  final String? command;
  final String? processId;
  final String? exitCode;
  final String? stdout;
  final String? stderr;
}

class _StructuredToolResultView extends StatelessWidget {
  const _StructuredToolResultView({
    required this.payload,
    required this.lightweight,
  });

  final _StructuredToolPayload payload;
  final bool lightweight;

  @override
  Widget build(BuildContext context) {
    final hasTyped =
        payload.filePath != null ||
        payload.operation != null ||
        payload.diff != null ||
        payload.writtenFiles.isNotEmpty ||
        payload.command != null ||
        payload.processId != null ||
        payload.exitCode != null ||
        payload.stdout != null ||
        payload.stderr != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (payload.filePath != null || payload.operation != null)
          _TypedResultSummary(
            icon: Icons.edit_document,
            title: payload.operation ?? 'File mutation',
            value: payload.filePath ?? 'File updated',
          ),
        if (payload.writtenFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          _TypedResultSummary(
            icon: Icons.file_copy_outlined,
            title: 'Written files',
            value: payload.writtenFiles.join('\n'),
          ),
        ],
        if (payload.command != null ||
            payload.processId != null ||
            payload.exitCode != null) ...[
          const SizedBox(height: 8),
          _TypedResultSummary(
            icon: Icons.memory_rounded,
            title: 'Process',
            value: <String>[
              if (payload.command != null) payload.command!,
              if (payload.processId != null) 'PID ${payload.processId}',
              if (payload.exitCode != null) 'Exit ${payload.exitCode}',
            ].join(' · '),
          ),
        ],
        if (payload.stdout case final stdout?) ...[
          const SizedBox(height: 8),
          _ExpandableStatusPanel(
            title: 'Process output',
            icon: Icons.terminal_rounded,
            tone: _StatusTone.neutral,
            initiallyExpanded: false,
            child: _RichTextPart(
              text: stdout,
              format: _TextFormat.ansi,
              lightweight: lightweight,
            ),
          ),
        ],
        if (payload.stderr case final stderr?) ...[
          const SizedBox(height: 8),
          _ExpandableStatusPanel(
            title: 'Error output',
            icon: Icons.error_outline_rounded,
            tone: _StatusTone.error,
            initiallyExpanded: true,
            child: _RichTextPart(
              text: stderr,
              format: _TextFormat.ansi,
              lightweight: lightweight,
            ),
          ),
        ],
        if (payload.diff case final diff?) ...[
          const SizedBox(height: 8),
          _RichTextPart(
            text: diff,
            format: _TextFormat.unifiedDiff,
            lightweight: lightweight,
          ),
        ],
        if (!hasTyped && payload.details is! PiSafeNull)
          _SafeDetailsPanel(
            title: 'Structured result',
            value: payload.details,
            initiallyExpanded: false,
          ),
      ],
    );
  }
}

class _TypedResultSummary extends StatelessWidget {
  const _TypedResultSummary({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$title: $value',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  SelectableText(value),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SafeDetailsPanel extends StatelessWidget {
  const _SafeDetailsPanel({
    required this.title,
    required this.value,
    required this.initiallyExpanded,
  });

  final String title;
  final PiSafeValue value;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final encoded = const JsonEncoder.withIndent(
      '  ',
    ).convert(_safeValueToJson(value));
    return ExpansionTile(
      dense: true,
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        CodeBlockView(
          code: encoded,
          language: 'json',
          maxCharacters: _maxConversationPreviewBytes,
        ),
      ],
    );
  }
}

class _MetricsFooter extends StatelessWidget {
  const _MetricsFooter({required this.metrics});

  final PiConversationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final usage = metrics.usage;
    final currentContext = metrics.context;
    return Semantics(
      container: true,
      label:
          'Usage ${usage.totalTokens} tokens, cost ${metrics.cost.decimalAmount} ${metrics.cost.currencyCode}'
          '${currentContext == null ? '' : ', context ${currentContext.percentDecimal ?? currentContext.tokens ?? 'unknown'} of ${currentContext.contextWindow}'}',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _MetricChip(label: '${usage.inputTokens} in'),
          _MetricChip(label: '${usage.outputTokens} out'),
          if (usage.cacheReadTokens > 0)
            _MetricChip(label: '${usage.cacheReadTokens} cache read'),
          if (usage.cacheWriteTokens > 0)
            _MetricChip(label: '${usage.cacheWriteTokens} cache write'),
          _MetricChip(label: '${usage.totalTokens} total'),
          _MetricChip(
            label: '${metrics.cost.decimalAmount} ${metrics.cost.currencyCode}',
          ),
          if (currentContext != null)
            _MetricChip(
              label:
                  '${currentContext.percentDecimal ?? currentContext.tokens ?? '—'} / ${currentContext.contextWindow} context',
            ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

enum _StatusTone { neutral, success, warning, error }

class _EntryStatusChip extends StatelessWidget {
  const _EntryStatusChip({required this.label, required this.tone});

  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = switch (tone) {
      _StatusTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurface),
      _StatusTone.success => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      _StatusTone.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      _StatusTone.error => (scheme.errorContainer, scheme.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colors.$2),
      ),
    );
  }
}

class _ExpandableStatusPanel extends StatelessWidget {
  const _ExpandableStatusPanel({
    required this.title,
    required this.icon,
    required this.tone,
    required this.initiallyExpanded,
    required this.child,
    super.key,
  });

  final String title;
  final IconData icon;
  final _StatusTone tone;
  final bool initiallyExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: Icon(
        icon,
        color: tone == _StatusTone.error
            ? Theme.of(context).colorScheme.error
            : null,
      ),
      title: Text(title),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [child],
    ),
  );
}

class _SemanticEventCard extends StatelessWidget {
  const _SemanticEventCard({
    required this.maxWidth,
    required this.entry,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.parts,
    this.details,
  });

  final double maxWidth;
  final PiConversationEntry entry;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget parts;
  final PiSafeValue? details;

  @override
  Widget build(BuildContext context) => _BoundedCard(
    maxWidth: maxWidth,
    semanticLabel: '$title, $subtitle',
    child: ExpansionTile(
      key: ValueKey<String>('semantic-entry-${entry.identity.entryId}'),
      initiallyExpanded: false,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        parts,
        if (details case final value?) ...[
          const SizedBox(height: 8),
          _SafeDetailsPanel(
            title: 'Structured details',
            value: value,
            initiallyExpanded: false,
          ),
        ],
        if (entry.metrics case final metrics?) ...[
          const SizedBox(height: 8),
          _MetricsFooter(metrics: metrics),
        ],
      ],
    ),
  );
}

class _CompactEventCard extends StatelessWidget {
  const _CompactEventCard({
    required this.maxWidth,
    required this.semanticLabel,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final double maxWidth;
  final String semanticLabel;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => _BoundedCard(
    maxWidth: maxWidth,
    semanticLabel: semanticLabel,
    child: ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );
}

class _BoundedCard extends StatelessWidget {
  const _BoundedCard({
    required this.maxWidth,
    required this.semanticLabel,
    required this.child,
  });

  final double maxWidth;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card.outlined(child: child),
      ),
    ),
  );
}

class _BoundedPreview extends StatelessWidget {
  const _BoundedPreview({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 360),
    child: SingleChildScrollView(child: child),
  );
}

class _ContentUnavailableCard extends StatelessWidget {
  const _ContentUnavailableCard({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final FutureOr<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$title. $message',
    child: Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(icon),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(message),
                ],
              ),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: () => onRetry!.call(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ActivityMinimap extends StatefulWidget {
  const _ActivityMinimap({required this.entries, required this.controller});

  final List<PiConversationEntry> entries;
  final ScrollController controller;

  @override
  State<_ActivityMinimap> createState() => _ActivityMinimapState();
}

class _ActivityMinimapState extends State<_ActivityMinimap> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant _ActivityMinimap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = widget.controller.positions;
    final position =
        positions.length == 1 && positions.first.hasContentDimensions
        ? positions.first
        : null;
    final progress = position == null || position.maxScrollExtent <= 0
        ? 0.0
        : (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
    final visibleFraction = position == null || position.maxScrollExtent <= 0
        ? 1.0
        : (position.viewportDimension /
                  (position.maxScrollExtent + position.viewportDimension))
              .clamp(0.04, 1.0);
    final current = widget.entries.isEmpty
        ? 0
        : (progress * (widget.entries.length - 1)).round() + 1;
    return Semantics(
      container: true,
      slider: true,
      label: 'Conversation activity minimap',
      value: '$current of ${widget.entries.length}',
      increasedValue: 'Later activity',
      decreasedValue: 'Earlier activity',
      onIncrease: () => _scrollBy(0.8),
      onDecrease: () => _scrollBy(-0.8),
      child: Tooltip(
        message: 'Conversation activity minimap',
        child: GestureDetector(
          key: const Key('conversationActivityMinimap'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _jump(details.localPosition.dy),
          onVerticalDragUpdate: (details) => _jump(details.localPosition.dy),
          child: SizedBox(
            width: 48,
            height: double.infinity,
            child: CustomPaint(
              painter: _ActivityMinimapPainter(
                entries: widget.entries,
                colorScheme: Theme.of(context).colorScheme,
                progress: progress,
                visibleFraction: visibleFraction,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _jump(double dy) {
    final positions = widget.controller.positions;
    if (positions.length != 1 || !positions.first.hasContentDimensions) return;
    final position = positions.first;
    final renderBox = context.findRenderObject() as RenderBox?;
    final height = renderBox?.size.height ?? 1;
    final fraction = (dy / height).clamp(0.0, 1.0);
    widget.controller.jumpTo(position.maxScrollExtent * fraction);
  }

  void _scrollBy(double viewports) {
    final positions = widget.controller.positions;
    if (positions.length != 1 || !positions.first.hasContentDimensions) return;
    final position = positions.first;
    widget.controller.animateTo(
      (position.pixels + position.viewportDimension * viewports).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}

class _ActivityMinimapPainter extends CustomPainter {
  const _ActivityMinimapPainter({
    required this.entries,
    required this.colorScheme,
    required this.progress,
    required this.visibleFraction,
  });

  final List<PiConversationEntry> entries;
  final ColorScheme colorScheme;
  final double progress;
  final double visibleFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final background = Paint()..color = colorScheme.surfaceContainerLow;
    canvas.drawRect(Offset.zero & size, background);
    if (entries.isEmpty) return;
    const maxBars = 256;
    final barCount = entries.length.clamp(1, maxBars);
    final barHeight = size.height / barCount;
    for (var index = 0; index < barCount; index += 1) {
      final sourceIndex = entries.length == barCount
          ? index
          : ((index / barCount) * entries.length).floor().clamp(
              0,
              entries.length - 1,
            );
      final paint = Paint()..color = _entryColor(entries[sourceIndex]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            8,
            index * barHeight + 1,
            30,
            (barHeight - 2).clamp(1, 5),
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
    final viewportPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final minimumViewportHeight = size.height < 20 ? size.height : 20.0;
    final viewportHeight = (size.height * visibleFraction)
        .clamp(minimumViewportHeight, size.height)
        .toDouble();
    final top = ((size.height - viewportHeight) * progress)
        .clamp(0.0, size.height - viewportHeight)
        .toDouble();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, top, size.width - 6, viewportHeight),
      const Radius.circular(5),
    );
    canvas
      ..drawRRect(rect, viewportPaint)
      ..drawRRect(rect, borderPaint);
  }

  Color _entryColor(PiConversationEntry entry) => switch (entry) {
    PiUserConversationEntry() => colorScheme.primary,
    PiAssistantConversationEntry(:final safeErrorMessage)
        when safeErrorMessage != null =>
      colorScheme.error,
    PiAssistantConversationEntry() => colorScheme.secondary,
    PiToolResultConversationEntry(:final isError) =>
      isError ? colorScheme.error : colorScheme.tertiary,
    PiBashConversationEntry(:final exitCode)
        when exitCode != null && exitCode != 0 =>
      colorScheme.error,
    PiBashConversationEntry() => colorScheme.tertiary,
    PiCompactionConversationEntry() ||
    PiBranchSummaryConversationEntry() => colorScheme.outline,
    _ => colorScheme.outlineVariant,
  };

  @override
  bool shouldRepaint(covariant _ActivityMinimapPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.progress != progress ||
      oldDelegate.visibleFraction != visibleFraction;
}

final class _OlderHistoryAnchor {
  const _OlderHistoryAnchor({
    required this.entryCount,
    required this.pixels,
    required this.maxExtent,
    required this.entryId,
    required this.viewportOffset,
  });

  final int entryCount;
  final double pixels;
  final double maxExtent;
  final String? entryId;
  final double? viewportOffset;
}

final class _VisibleEntryAnchor {
  const _VisibleEntryAnchor({
    required this.entryId,
    required this.viewportOffset,
  });

  final String entryId;
  final double viewportOffset;
}

class _MessageBranchActions extends StatelessWidget {
  const _MessageBranchActions({
    required this.entry,
    required this.enabled,
    required this.onEditFromHere,
    required this.onForkFromHere,
  });

  final PiConversationEntry entry;
  final bool enabled;
  final VoidCallback? onEditFromHere;
  final VoidCallback? onForkFromHere;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Branch actions for persisted user entry',
    child: Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 4,
        children: [
          if (onEditFromHere != null)
            TextButton.icon(
              key: ValueKey<String>(
                'entryEditFromHere-${entry.identity.entryId}',
              ),
              onPressed: enabled ? onEditFromHere : null,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Edit from here'),
            ),
          if (onForkFromHere != null)
            TextButton.icon(
              key: ValueKey<String>(
                'entryForkFromHere-${entry.identity.entryId}',
              ),
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

enum _TextFormat { markdown, plain, ansi, json, unifiedDiff, code }

_TextFormat _detectTextFormat(
  String text, {
  required _TextFormat defaultFormat,
}) {
  final trimmed = text.trimLeft();
  if (text.contains('\u001b[') || text.contains('\u009b')) {
    return _TextFormat.ansi;
  }
  if ((trimmed.startsWith('diff --git ') ||
          (trimmed.startsWith('--- ') && text.contains('\n+++ '))) &&
      text.contains('\n@@')) {
    return _TextFormat.unifiedDiff;
  }
  if ((trimmed.startsWith('{') && trimmed.trimRight().endsWith('}')) ||
      (trimmed.startsWith('[') && trimmed.trimRight().endsWith(']'))) {
    try {
      jsonDecode(trimmed);
      return _TextFormat.json;
    } catch (_) {
      // Fall through to the caller's semantic default.
    }
  }
  return defaultFormat;
}

_TextFormat? _formatFromName(String? value) {
  final normalized = value?.toLowerCase().trim();
  return switch (normalized) {
    'markdown' || 'md' || 'text/markdown' => _TextFormat.markdown,
    'plain' || 'text' || 'text/plain' => _TextFormat.plain,
    'ansi' || 'terminal' => _TextFormat.ansi,
    'json' || 'application/json' => _TextFormat.json,
    'diff' || 'patch' || 'unifieddiff' => _TextFormat.unifiedDiff,
    'code' || 'source' => _TextFormat.code,
    _ => null,
  };
}

_ToolVisualStatus _toolStatus(_ToolProjection projection) {
  if (_safeValueSignalsBlocked(projection.activity?.safeDetails) ||
      projection.results.any(
        (result) => _safeValueSignalsBlocked(result.safeDetails),
      )) {
    return _ToolVisualStatus.blocked;
  }
  final status = projection.activity?.status;
  if (status != null) {
    return switch (status) {
      PiToolActivityStatus.pending => _ToolVisualStatus.queued,
      PiToolActivityStatus.running => _ToolVisualStatus.running,
      PiToolActivityStatus.succeeded => _ToolVisualStatus.succeeded,
      PiToolActivityStatus.failed => _ToolVisualStatus.failed,
      PiToolActivityStatus.cancelled => _ToolVisualStatus.cancelled,
    };
  }
  if (projection.results.any((result) => result.isError)) {
    return _ToolVisualStatus.failed;
  }
  if (projection.results.isNotEmpty) return _ToolVisualStatus.succeeded;
  return _ToolVisualStatus.queued;
}

({
  String label,
  IconData icon,
  _StatusTone tone,
  Color Function(BuildContext) color,
})
_toolStatusPresentation(_ToolVisualStatus status) => switch (status) {
  _ToolVisualStatus.queued => (
    label: 'Queued',
    icon: Icons.schedule_rounded,
    tone: _StatusTone.neutral,
    color: (context) => Theme.of(context).colorScheme.outline,
  ),
  _ToolVisualStatus.running => (
    label: 'Running',
    icon: Icons.sync_rounded,
    tone: _StatusTone.warning,
    color: (context) => Theme.of(context).colorScheme.tertiary,
  ),
  _ToolVisualStatus.succeeded => (
    label: 'Succeeded',
    icon: Icons.check_circle_outline_rounded,
    tone: _StatusTone.success,
    color: (context) => Theme.of(context).colorScheme.primary,
  ),
  _ToolVisualStatus.failed => (
    label: 'Failed',
    icon: Icons.error_outline_rounded,
    tone: _StatusTone.error,
    color: (context) => Theme.of(context).colorScheme.error,
  ),
  _ToolVisualStatus.cancelled => (
    label: 'Cancelled',
    icon: Icons.cancel_outlined,
    tone: _StatusTone.warning,
    color: (context) => Theme.of(context).colorScheme.tertiary,
  ),
  _ToolVisualStatus.blocked => (
    label: 'Blocked',
    icon: Icons.block_rounded,
    tone: _StatusTone.error,
    color: (context) => Theme.of(context).colorScheme.error,
  ),
};

bool _safeValueSignalsBlocked(PiSafeValue? value) {
  if (value is! PiSafeObject) return false;
  for (final field in value.fields) {
    final key = field.key.toLowerCase();
    if (key == 'blocked' && field.value is PiSafeBool) {
      return (field.value as PiSafeBool).value;
    }
    if ((key == 'status' || key == 'state' || key == 'outcome') &&
        field.value is PiSafeString &&
        (field.value as PiSafeString).value.toLowerCase() == 'blocked') {
      return true;
    }
  }
  return false;
}

String _entryLabel(PiConversationEntry entry) => switch (entry) {
  PiUserConversationEntry() => 'User message',
  PiAssistantConversationEntry() => 'Assistant response',
  PiToolResultConversationEntry() => 'Tool result',
  PiBashConversationEntry() => 'Shell execution',
  PiCustomConversationEntry() => 'Extension entry',
  PiCompactionConversationEntry() => 'Compaction entry',
  PiBranchSummaryConversationEntry() => 'Branch summary',
  PiMarkerConversationEntry() => 'Conversation marker',
  PiUnknownConversationEntry() => 'Unknown entry',
};

String _entryText(PiConversationEntry entry) => entry.parts
    .map(
      (part) => switch (part) {
        PiTextConversationPart(:final text, :final contentReference) =>
          text ?? '[Deferred content: ${contentReference!.displayName}]',
        PiThinkingConversationPart(
          visibility: PiThinkingVisibility.visible,
          :final text,
          :final contentReference,
        ) =>
          text ?? '[Deferred thinking: ${contentReference!.displayName}]',
        PiThinkingConversationPart(:final visibility) =>
          '[Thinking ${visibility.name}]',
        PiImageConversationPart(:final contentReference) =>
          '[Image: ${contentReference.displayName}]',
        PiToolCallConversationPart(:final toolName) => '[Tool call: $toolName]',
        PiUnsupportedConversationPart(:final sourceType) =>
          '[Unsupported content: $sourceType]',
      },
    )
    .join('\n');

String _entryRawText(PiConversationEntry entry) {
  final content = _entryText(entry);
  final details = switch (entry) {
    PiToolResultConversationEntry(:final safeDetails) => safeDetails,
    PiCustomConversationEntry(:final safeDetails) => safeDetails,
    PiCompactionConversationEntry(:final safeDetails) => safeDetails,
    PiBranchSummaryConversationEntry(:final safeDetails) => safeDetails,
    _ => null,
  };
  if (details == null || details is PiSafeNull) return content;
  final encoded = const JsonEncoder.withIndent(
    '  ',
  ).convert(_safeValueToJson(details));
  return content.isEmpty ? encoded : '$content\n\n$encoded';
}

String _plainText(String value) {
  final ansi = const AnsiParser().parse(value).plainText;
  return ansi
      .replaceAll(RegExp(r'```[^\n]*\n?'), '')
      .replaceAll('```', '')
      .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), r'$1')
      .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1')
      .replaceAll(RegExp(r'(^|\s)[#>*_~`-]+(?=\s|$)', multiLine: true), r'$1')
      .replaceAll(RegExp(r'[*_~`]'), '')
      .trim();
}

Object? _safeValueToJson(PiSafeValue value) => switch (value) {
  PiSafeNull() => null,
  PiSafeRedacted() => '<redacted>',
  PiSafeBool(:final value) => value,
  PiSafeInt(:final value) => value,
  PiSafeDouble(:final value) => value,
  PiSafeString(:final value) => value,
  PiSafeList(:final values) => values.map(_safeValueToJson).toList(),
  PiSafeObject(:final fields) => <String, Object?>{
    for (final field in fields) field.key: _safeValueToJson(field.value),
  },
};

PiSafeValue? _safeField(PiSafeObject? object, List<String> names) {
  if (object == null) return null;
  final normalized = names.map((name) => name.toLowerCase()).toSet();
  for (final field in object.fields) {
    if (normalized.contains(field.key.toLowerCase())) return field.value;
  }
  return null;
}

String? _safeStringField(PiSafeObject? object, List<String> names) {
  final value = _safeField(object, names);
  return value is PiSafeString ? value.value : null;
}

String? _safeDisplayField(PiSafeObject? object, List<String> names) {
  final value = _safeField(object, names);
  return switch (value) {
    PiSafeString(:final value) => value,
    PiSafeInt(:final value) => '$value',
    PiSafeDouble(:final value) => '$value',
    PiSafeBool(:final value) => '$value',
    PiSafeRedacted() => '<redacted>',
    _ => null,
  };
}

List<String> _safeStringListField(PiSafeObject? object, List<String> names) {
  final value = _safeField(object, names);
  if (value is PiSafeString) return <String>[value.value];
  if (value is! PiSafeList) return const <String>[];
  return value.values
      .whereType<PiSafeString>()
      .map((item) => item.value)
      .take(128)
      .toList(growable: false);
}

({String text, bool truncated}) _boundedPreviewText(
  String value, {
  int maxBytes = _maxConversationPreviewBytes,
}) {
  final encoded = utf8.encode(value);
  if (encoded.length <= maxBytes) {
    return (text: value, truncated: false);
  }
  var end = maxBytes;
  while (end > 0 && (encoded[end] & 0xc0) == 0x80) {
    end -= 1;
  }
  return (
    text: utf8.decode(encoded.sublist(0, end), allowMalformed: false),
    truncated: true,
  );
}

String _boundedSemantic(String value) {
  const maxCodeUnits = 4096;
  return value.length <= maxCodeUnits
      ? value
      : '${value.substring(0, maxCodeUnits)}…';
}

bool _sameByteList(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _sameBinding(
  PiMessageContentBinding left,
  PiMessageContentBinding right,
) =>
    left.sessionId == right.sessionId &&
    left.entryId == right.entryId &&
    left.partId == right.partId &&
    left.entryRevision == right.entryRevision &&
    left.partRevision == right.partRevision &&
    left.contentId == right.contentId;
