part of 'project_browser.dart';

class ProjectBrowserView extends StatefulWidget {
  const ProjectBrowserView({
    required this.knownProjects,
    required this.onBrowseDirectory,
    required this.onValidatePath,
    required this.onProjectSelected,
    this.selectedProject,
    this.directory,
    this.isLoading = false,
    this.isBrowsing = false,
    this.isValidating = false,
    this.errorMessage,
    super.key,
  });

  final PiProject? selectedProject;
  final List<PiKnownProject> knownProjects;
  final PiDirectoryListing? directory;
  final bool isLoading;
  final bool isBrowsing;
  final bool isValidating;
  final String? errorMessage;
  final ValueChanged<String> onBrowseDirectory;
  final ValueChanged<String> onValidatePath;
  final ValueChanged<PiProject> onProjectSelected;

  @override
  State<ProjectBrowserView> createState() => _ProjectBrowserViewState();
}

class _ProjectBrowserViewState extends State<ProjectBrowserView> {
  late final TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(
      text: widget.selectedProject?.identity.canonicalWorkingDirectory ?? '',
    );
  }

  @override
  void didUpdateWidget(ProjectBrowserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous =
        oldWidget.selectedProject?.identity.canonicalWorkingDirectory;
    final current = widget.selectedProject?.identity.canonicalWorkingDirectory;
    if (current != null && current != previous) {
      _pathController.value = TextEditingValue(
        text: current,
        selection: TextSelection.collapsed(offset: current.length),
      );
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.selectedProject;
    final directory = widget.directory;
    final busy = widget.isLoading || widget.isBrowsing || widget.isValidating;

    return Semantics(
      container: true,
      label: 'Project browser',
      child: Card(
        key: const Key('projectBrowserCard'),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isLoading) const LinearProgressIndicator(),
            ListTile(
              key: const Key('projectBrowserSelectedProject'),
              leading: Icon(
                project?.identity.isGitRepository == true
                    ? Icons.account_tree_outlined
                    : Icons.folder_outlined,
              ),
              title: Text(
                project == null
                    ? 'No project selected'
                    : _projectLabel(project),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                project?.identity.canonicalWorkingDirectory ??
                    'Validate a directory through Pi Node.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: project == null
                  ? null
                  : _TrustStatusChip(status: project.trust.status),
            ),
            if (widget.errorMessage case final error?)
              MaterialBanner(
                key: const Key('projectBrowserErrorBanner'),
                content: Text(error),
                leading: Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                actions: const <Widget>[SizedBox.shrink()],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('projectBrowserManualPathField'),
                      controller: _pathController,
                      enabled: !busy,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: busy ? null : widget.onValidatePath,
                      decoration: const InputDecoration(
                        labelText: 'Project directory',
                        hintText: '/Projects/example',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    key: const Key('projectBrowserValidateButton'),
                    onPressed: busy
                        ? null
                        : () => widget.onValidatePath(_pathController.text),
                    icon: widget.isValidating
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Validate'),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              key: const Key('projectBrowserDirectoryExpansion'),
              initiallyExpanded: false,
              title: const Text('Browse directories'),
              subtitle: Text(
                directory?.canonicalDirectory ?? 'Node-side bounded listing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                if (directory == null)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text('No directory listing is available.'),
                  )
                else ...[
                  if (directory.parentDirectory case final parent?)
                    ListTile(
                      key: const Key('projectBrowserParentDirectory'),
                      dense: true,
                      leading: const Icon(Icons.drive_folder_upload_outlined),
                      title: const Text('Parent directory'),
                      subtitle: Text(
                        parent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      enabled: !busy,
                      onTap: busy
                          ? null
                          : () => widget.onBrowseDirectory(parent),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 190),
                    child: ListView.builder(
                      key: const Key('projectBrowserDirectoryList'),
                      shrinkWrap: true,
                      itemCount: directory.children.length,
                      itemBuilder: (context, index) {
                        final child = directory.children[index];
                        return ListTile(
                          key: ValueKey<String>(child.canonicalPath),
                          dense: true,
                          leading: Icon(
                            child.isSymbolicLink
                                ? Icons.folder_copy_outlined
                                : Icons.folder_outlined,
                          ),
                          title: Text(child.name),
                          subtitle: child.isSymbolicLink
                              ? const Text('Symbolic link · canonical target')
                              : null,
                          enabled: !busy,
                          onTap: busy
                              ? null
                              : () => widget.onBrowseDirectory(
                                  child.canonicalPath,
                                ),
                          trailing: IconButton(
                            tooltip: 'Validate this directory as a project',
                            onPressed: busy
                                ? null
                                : () => widget.onValidatePath(
                                    child.canonicalPath,
                                  ),
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (directory.truncated)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(
                        'Only the bounded first set of child directories is shown.',
                      ),
                    ),
                ],
              ],
            ),
            if (widget.knownProjects.isNotEmpty)
              ExpansionTile(
                key: const Key('projectBrowserKnownExpansion'),
                title: const Text('Recent projects'),
                subtitle: Text(
                  '${widget.knownProjects.length} from Pi sessions',
                ),
                children: widget.knownProjects
                    .map(
                      (known) => ListTile(
                        key: ValueKey<PiProjectId>(
                          known.project.identity.projectId,
                        ),
                        dense: true,
                        selected:
                            known.project.identity.projectId ==
                            project?.identity.projectId,
                        leading: const Icon(Icons.history_rounded),
                        title: Text(
                          _projectLabel(known.project),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${known.sessionCount} session${known.sessionCount == 1 ? '' : 's'} · '
                          '${known.project.identity.canonicalWorkingDirectory}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _TrustStatusChip(
                          status: known.project.trust.status,
                        ),
                        enabled: !busy,
                        onTap: busy
                            ? null
                            : () => widget.onProjectSelected(known.project),
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }
}

class ProjectTrustDialogView extends StatelessWidget {
  const ProjectTrustDialogView({
    required this.project,
    required this.onApprove,
    this.isApproving = false,
    super.key,
  });

  final PiProject project;
  final bool isApproving;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const Key('projectTrustDialog'),
    icon: const Icon(Icons.security_rounded),
    title: const Text('Trust this project?'),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval allows Pi to load project-local settings and resources. '
              'Extensions and project packages may execute with the Pi Node host permissions.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              project.identity.canonicalWorkingDirectory,
              key: const Key('projectTrustDialogPath'),
            ),
            const SizedBox(height: 12),
            Text(
              'Detected reasons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ...project.trust.reasons
                .where(
                  (reason) =>
                      reason != PiProjectTrustReason.savedApproval &&
                      reason != PiProjectTrustReason.savedDenial,
                )
                .map(
                  (reason) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text(_trustReasonLabel(reason)),
                  ),
                ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        key: const Key('projectTrustCancelButton'),
        onPressed: isApproving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        key: const Key('projectTrustApproveButton'),
        onPressed: isApproving ? null : onApprove,
        icon: isApproving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.verified_user_outlined),
        label: const Text('Trust project'),
      ),
    ],
  );
}

// ignore: non_constant_identifier_names
Widget ProjectTrustDialog({
  required PiProject project,
  required VoidCallback onApprove,
  bool isApproving = false,
  Key? key,
}) => ProjectTrustDialogView(
  key: key,
  project: project,
  onApprove: onApprove,
  isApproving: isApproving,
);

class _TrustStatusChip extends StatelessWidget {
  const _TrustStatusChip({required this.status});

  final PiProjectTrustStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      PiProjectTrustStatus.notRequired => (
        'Restricted',
        Theme.of(context).colorScheme.secondary,
        Icons.shield_outlined,
      ),
      PiProjectTrustStatus.trusted => (
        'Trusted',
        Theme.of(context).colorScheme.primary,
        Icons.verified_user_outlined,
      ),
      PiProjectTrustStatus.approvalRequired => (
        'Approval required',
        Theme.of(context).colorScheme.tertiary,
        Icons.gpp_maybe_outlined,
      ),
      PiProjectTrustStatus.denied => (
        'Not trusted',
        Theme.of(context).colorScheme.error,
        Icons.gpp_bad_outlined,
      ),
    };
    return Tooltip(
      message: label,
      child: Chip(
        key: const Key('projectTrustStatusChip'),
        avatar: Icon(icon, size: 16, color: color),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

String _projectLabel(PiProject project) {
  final path =
      project.identity.gitRoot ?? project.identity.canonicalWorkingDirectory;
  final segments = path
      .split(RegExp(r'[/\\]'))
      .where((value) => value.isNotEmpty);
  final name = segments.isEmpty ? path : segments.last;
  final branch = project.identity.branch;
  return branch == null ? name : '$name · $branch';
}

String _trustReasonLabel(PiProjectTrustReason reason) => switch (reason) {
  PiProjectTrustReason.piSettings => 'Project .pi/settings.json',
  PiProjectTrustReason.piExtensions => 'Project Pi extensions',
  PiProjectTrustReason.piSkills => 'Project Pi skills',
  PiProjectTrustReason.piPrompts => 'Project prompt templates',
  PiProjectTrustReason.piThemes => 'Project Pi themes',
  PiProjectTrustReason.piSystemPrompt => 'Project system prompt files',
  PiProjectTrustReason.agentSkills => 'Project or ancestor .agents/skills',
  PiProjectTrustReason.savedApproval => 'Saved approval',
  PiProjectTrustReason.savedDenial => 'Saved denial',
};
