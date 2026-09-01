part of 'branch_navigator.dart';

class BranchNavigatorView extends StatelessWidget {
  const BranchNavigatorView({
    this.tree,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onNavigate,
    this.onFork,
    this.onClone,
    super.key,
  });

  final PiSessionTree? tree;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<PiSessionTreeNode>? onNavigate;
  final ValueChanged<PiSessionTreeNode>? onFork;
  final VoidCallback? onClone;

  @override
  Widget build(BuildContext context) {
    final currentTree = tree;
    return Semantics(
      container: true,
      label: currentTree == null
          ? 'Session branches'
          : 'Session branches, ${currentTree.nodes.length} entries',
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BranchNavigatorHeader(
              tree: currentTree,
              isLoading: isLoading,
              onClone: currentTree?.canCloneActiveBranch == true
                  ? onClone
                  : null,
            ),
            if (isLoading) const LinearProgressIndicator(),
            if (errorMessage != null)
              Semantics(
                liveRegion: true,
                child: MaterialBanner(
                  key: const Key('branchNavigatorErrorBanner'),
                  content: Text(errorMessage!),
                  leading: Icon(
                    Icons.account_tree_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  actions: [
                    if (onRetry != null)
                      TextButton(
                        key: const Key('branchNavigatorRetryButton'),
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            if (currentTree == null || currentTree.nodes.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Text(
                  isLoading
                      ? 'Loading the active session tree…'
                      : 'No branch entries are available yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              SizedBox(
                height: 184,
                child: ListView.builder(
                  key: const Key('branchNavigatorList'),
                  itemCount: currentTree.nodes.length,
                  itemBuilder: (context, index) {
                    final node = currentTree.nodes[index];
                    return _BranchNavigatorEntry(
                      node: node,
                      activeLeafId: currentTree.activeLeafEntryId,
                      onNavigate: onNavigate == null
                          ? null
                          : () => onNavigate!(node),
                      onFork: node.canFork && onFork != null
                          ? () => onFork!(node)
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BranchNavigatorHeader extends StatelessWidget {
  const _BranchNavigatorHeader({
    required this.tree,
    required this.isLoading,
    required this.onClone,
  });

  final PiSessionTree? tree;
  final bool isLoading;
  final VoidCallback? onClone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
    child: Row(
      children: [
        const Icon(Icons.account_tree_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tree == null
                ? 'Branches'
                : 'Branches · ${tree!.activePathEntryIds.length} active',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          key: const Key('branchNavigatorCloneButton'),
          tooltip: 'Clone active branch into a new session',
          onPressed: isLoading ? null : onClone,
          icon: const Icon(Icons.copy_all_outlined),
        ),
      ],
    ),
  );
}

class _BranchNavigatorEntry extends StatelessWidget {
  const _BranchNavigatorEntry({
    required this.node,
    required this.activeLeafId,
    required this.onNavigate,
    required this.onFork,
  });

  final PiSessionTreeNode node;
  final PiSessionTreeEntryId? activeLeafId;
  final VoidCallback? onNavigate;
  final VoidCallback? onFork;

  @override
  Widget build(BuildContext context) {
    final activeLeaf = node.id == activeLeafId;
    final actionLabel = node.canEditFromHere
        ? 'Edit from here'
        : 'Continue from here';
    final description = node.text.trim().isEmpty
        ? _entryKindLabel(node.kind)
        : node.text.trim();
    return Semantics(
      key: ValueKey<String>('branchEntrySemantics-${node.id.value}'),
      selected: activeLeaf,
      label:
          '${_entryKindLabel(node.kind)}${activeLeaf ? ', active leaf' : ''}: $description',
      child: ListTile(
        key: ValueKey<String>('branchEntry-${node.id.value}'),
        dense: true,
        selected: node.isOnActivePath,
        contentPadding: EdgeInsets.only(
          left: 12 + (node.depth.clamp(0, 7) * 12),
          right: 6,
        ),
        leading: Icon(
          activeLeaf
              ? Icons.radio_button_checked
              : node.hasChildren
              ? Icons.call_split_rounded
              : Icons.circle_outlined,
          size: 16,
        ),
        title: Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: node.label == null
            ? null
            : Text(node.label!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              key: ValueKey<String>('branchNavigate-${node.id.value}'),
              tooltip: actionLabel,
              onPressed: onNavigate,
              icon: Icon(
                node.canEditFromHere
                    ? Icons.edit_note_rounded
                    : Icons.alt_route_rounded,
                size: 19,
              ),
            ),
            if (node.canFork)
              IconButton(
                key: ValueKey<String>('branchFork-${node.id.value}'),
                tooltip: 'Fork from this user message into a new session',
                onPressed: onFork,
                icon: const Icon(Icons.fork_right_rounded, size: 19),
              ),
          ],
        ),
      ),
    );
  }
}

String _entryKindLabel(PiSessionTreeEntryKind kind) => switch (kind) {
  PiSessionTreeEntryKind.userMessage => 'User message',
  PiSessionTreeEntryKind.assistantMessage => 'Assistant message',
  PiSessionTreeEntryKind.toolMessage => 'Tool message',
  PiSessionTreeEntryKind.customMessage => 'Custom message',
  PiSessionTreeEntryKind.thinkingLevel => 'Thinking level change',
  PiSessionTreeEntryKind.modelChange => 'Model change',
  PiSessionTreeEntryKind.compaction => 'Compaction',
  PiSessionTreeEntryKind.branchSummary => 'Branch summary',
  PiSessionTreeEntryKind.custom => 'Extension state',
  PiSessionTreeEntryKind.label => 'Label',
  PiSessionTreeEntryKind.sessionInfo => 'Session metadata',
};
