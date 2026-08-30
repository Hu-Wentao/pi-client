import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/branch_navigator/branch_navigator.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets(
    'virtualizes flat entries and exposes accessible branch actions',
    (tester) async {
      final tree = _tree(200);
      PiSessionTreeNode? navigated;
      PiSessionTreeNode? forked;
      var cloned = false;

      await tester.pumpWidget(
        componentTestApp(
          SizedBox(
            height: 320,
            child: BranchNavigatorView(
              tree: tree,
              onNavigate: (node) => navigated = node,
              onFork: (node) => forked = node,
              onClone: () => cloned = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('branchNavigatorList')), findsOneWidget);
      expect(find.byType(ListTile).evaluate().length, lessThan(200));
      expect(
        tester
            .getSemantics(
              find.byKey(
                const ValueKey<String>('branchEntrySemantics-entry-0'),
              ),
            )
            .label,
        contains('User message'),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('branchNavigate-entry-0')),
      );
      expect(navigated?.id, PiSessionTreeEntryId('entry-0'));
      await tester.tap(
        find.byKey(const ValueKey<String>('branchFork-entry-0')),
      );
      expect(forked?.id, PiSessionTreeEntryId('entry-0'));
      await tester.tap(find.byKey(const Key('branchNavigatorCloneButton')));
      expect(cloned, isTrue);
    },
  );

  testWidgets('shows retryable errors without dropping existing tree state', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      componentTestApp(
        SizedBox(
          height: 360,
          child: BranchNavigatorView(
            tree: _tree(2),
            errorMessage: 'Refresh the branch tree.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Refresh the branch tree.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('branchEntry-entry-0')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('branchNavigatorRetryButton')));
    expect(retried, isTrue);
  });
}

PiSessionTree _tree(int count) {
  final nodes = List<PiSessionTreeNode>.generate(count, (index) {
    final user = index.isEven;
    return PiSessionTreeNode(
      id: PiSessionTreeEntryId('entry-$index'),
      parentId: index == 0 ? null : PiSessionTreeEntryId('entry-${index - 1}'),
      kind: user
          ? PiSessionTreeEntryKind.userMessage
          : PiSessionTreeEntryKind.assistantMessage,
      text: user ? 'User prompt $index' : 'Assistant reply $index',
      createdAt: DateTime.utc(2026, 1, 1).add(Duration(seconds: index)),
      depth: index,
      isOnActivePath: true,
      hasChildren: index + 1 < count,
      canEditFromHere: user,
      canFork: user,
    );
  });
  return PiSessionTree(
    sessionId: PiSessionId('branch-session'),
    nodes: nodes,
    activePathEntryIds: nodes.map((node) => node.id),
    activeLeafEntryId: nodes.lastOrNull?.id,
    canCloneActiveBranch: nodes.isNotEmpty,
    adminRevision: PiSessionAdminRevision('revision-branch-session-1'),
  );
}
