part of 'prompt_composer.dart';

class PromptComposerView extends StatefulWidget {
  const PromptComposerView({
    required this.onSubmitted,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onStop,
    this.enabled = true,
    this.isSubmitting = false,
    this.isRunning = false,
    this.clearOnSubmit = true,
    this.hintText = 'Ask Pi to inspect, change, or explain the project…',
    this.disabledHint = 'Select a session before sending a prompt.',
    this.errorMessage,
    super.key,
  });

  final ValueChanged<String> onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onStop;
  final bool enabled;
  final bool isSubmitting;
  final bool isRunning;
  final bool clearOnSubmit;
  final String hintText;
  final String disabledHint;
  final String? errorMessage;

  @override
  State<PromptComposerView> createState() => _PromptComposerViewState();
}

class _PromptComposerViewState extends State<PromptComposerView> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'prompt composer');
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(PromptComposerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final draft = _controller.text;
      _controller.removeListener(_handleTextChanged);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController(text: draft);
      _controller.addListener(_handleTextChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'prompt composer');
    }
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  bool get _canSubmit =>
      widget.enabled &&
      !widget.isSubmitting &&
      !widget.isRunning &&
      _controller.text.trim().isNotEmpty;

  Object? _submit(_SubmitPromptIntent intent) {
    if (!_canSubmit) return null;
    final composing = _controller.value.composing;
    if (composing.isValid && !composing.isCollapsed) return null;
    final prompt = _controller.text.trim();
    widget.onSubmitted(prompt);
    if (widget.clearOnSubmit) _controller.clear();
    _focusNode.requestFocus();
    return null;
  }

  Object? _insertNewline(_InsertPromptNewlineIntent intent) {
    if (!widget.enabled || widget.isSubmitting) return null;
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final nextText = value.text.replaceRange(start, end, '\n');
    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
    return null;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Prompt composer',
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 440;
            final editor = Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter):
                    _SubmitPromptIntent(),
                SingleActivator(LogicalKeyboardKey.numpadEnter):
                    _SubmitPromptIntent(),
                SingleActivator(LogicalKeyboardKey.enter, shift: true):
                    _InsertPromptNewlineIntent(),
                SingleActivator(LogicalKeyboardKey.numpadEnter, shift: true):
                    _InsertPromptNewlineIntent(),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  _SubmitPromptIntent: CallbackAction<_SubmitPromptIntent>(
                    onInvoke: _submit,
                  ),
                  _InsertPromptNewlineIntent:
                      CallbackAction<_InsertPromptNewlineIntent>(
                        onInvoke: _insertNewline,
                      ),
                },
                child: TextField(
                  key: const Key('promptComposerField'),
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled && !widget.isSubmitting,
                  minLines: 1,
                  maxLines: narrow ? 6 : 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Prompt',
                    hintText: widget.enabled
                        ? widget.hintText
                        : widget.disabledHint,
                    helperText: 'Enter to send · Shift+Enter for a new line',
                    errorText: widget.errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            );
            final action = _PromptComposerAction(
              canSubmit: _canSubmit,
              isSubmitting: widget.isSubmitting,
              isRunning: widget.isRunning,
              onSubmit: () => _submit(const _SubmitPromptIntent()),
              onStop: widget.onStop,
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  editor,
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: editor),
                const SizedBox(width: 10),
                action,
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _PromptComposerAction extends StatelessWidget {
  const _PromptComposerAction({
    required this.canSubmit,
    required this.isSubmitting,
    required this.isRunning,
    required this.onSubmit,
    required this.onStop,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final bool isRunning;
  final VoidCallback onSubmit;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return Semantics(
        label: 'Submitting prompt',
        liveRegion: true,
        child: const IconButton.filled(
          key: Key('promptComposerSubmittingButton'),
          tooltip: 'Submitting prompt',
          onPressed: null,
          icon: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (isRunning) {
      return IconButton.filledTonal(
        key: const Key('promptComposerStopButton'),
        tooltip: 'Stop agent',
        onPressed: onStop,
        icon: const Icon(Icons.stop_rounded),
      );
    }
    return IconButton.filled(
      key: const Key('promptComposerSendButton'),
      tooltip: 'Send prompt',
      onPressed: canSubmit ? onSubmit : null,
      icon: const Icon(Icons.arrow_upward_rounded),
    );
  }
}

final class _SubmitPromptIntent extends Intent {
  const _SubmitPromptIntent();
}

final class _InsertPromptNewlineIntent extends Intent {
  const _InsertPromptNewlineIntent();
}
