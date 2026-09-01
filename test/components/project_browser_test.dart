import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/project_browser/project_browser.dart';

import '../support/fake_pi_node_api.dart';
import 'support/component_test_support.dart';

void main() {
  testWidgets(
    'browses bounded directories and validates only through callbacks',
    (tester) async {
      final selected = fakeProject(
        '/Projects/restricted',
        trustStatus: PiProjectTrustStatus.approvalRequired,
      );
      final known = fakeProject('/Projects/known');
      final browsed = <String>[];
      final validated = <String>[];
      final selectedProjects = <PiProject>[];

      await tester.pumpWidget(
        componentTestApp(
          SingleChildScrollView(
            child: ProjectBrowserView(
              selectedProject: selected,
              knownProjects: <PiKnownProject>[
                PiKnownProject(
                  project: known,
                  lastSessionAt: DateTime.utc(2026, 1, 2),
                  sessionCount: 2,
                ),
              ],
              directory: PiDirectoryListing(
                canonicalDirectory: '/Projects',
                parentDirectory: '/',
                children: <PiDirectoryEntry>[
                  PiDirectoryEntry(
                    name: 'linked',
                    canonicalPath: '/Projects/real-target',
                    isSymbolicLink: true,
                  ),
                ],
                truncated: true,
              ),
              onBrowseDirectory: browsed.add,
              onValidatePath: validated.add,
              onProjectSelected: selectedProjects.add,
            ),
          ),
        ),
      );

      expect(find.text('Approval required'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('projectBrowserManualPathField')),
        '/Projects/manual',
      );
      await tester.tap(find.byKey(const Key('projectBrowserValidateButton')));
      expect(validated, <String>['/Projects/manual']);

      await tester.tap(
        find.byKey(const Key('projectBrowserDirectoryExpansion')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Symbolic link · canonical target'), findsOneWidget);
      await tester.tap(find.text('linked'));
      expect(browsed, <String>['/Projects/real-target']);

      await tester.tap(find.byKey(const Key('projectBrowserKnownExpansion')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('known'));
      expect(selectedProjects.single, known);
      expect(find.textContaining('bounded first set'), findsOneWidget);
    },
  );

  testWidgets(
    'hides the external-terminal action without a selected trusted project',
    (tester) async {
      await tester.pumpWidget(
        componentTestApp(
          ProjectBrowserView(
            knownProjects: const <PiKnownProject>[],
            onBrowseDirectory: (_) {},
            onValidatePath: (_) {},
            onProjectSelected: (_) {},
            onOpenExternalTerminal: () {},
          ),
        ),
      );
      expect(
        find.byKey(const Key('projectBrowserOpenExternalTerminal')),
        findsNothing,
      );

      final restricted = fakeProject(
        '/Projects/restricted',
        trustStatus: PiProjectTrustStatus.approvalRequired,
      );
      await tester.pumpWidget(
        componentTestApp(
          ProjectBrowserView(
            selectedProject: restricted,
            knownProjects: const <PiKnownProject>[],
            onBrowseDirectory: (_) {},
            onValidatePath: (_) {},
            onProjectSelected: (_) {},
            onOpenExternalTerminal: () {},
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('projectBrowserOpenExternalTerminal')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'requires an explicit trust action and names detected resources',
    (tester) async {
      final project = fakeProject(
        '/Projects/restricted',
        trustStatus: PiProjectTrustStatus.approvalRequired,
      );
      var approved = false;

      await tester.pumpWidget(
        componentTestApp(
          ProjectTrustDialog(
            project: project,
            onApprove: () => approved = true,
          ),
        ),
      );

      expect(find.text('Trust this project?'), findsOneWidget);
      expect(find.text('Project .pi/settings.json'), findsOneWidget);
      expect(find.textContaining('may execute'), findsOneWidget);
      expect(find.byKey(const Key('projectTrustDialogPath')), findsOneWidget);
      await tester.tap(find.byKey(const Key('projectTrustApproveButton')));
      expect(approved, isTrue);
    },
  );
}
