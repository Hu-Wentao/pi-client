import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:pi_client/widgets/renderer_dependencies/renderer_dependency_inventory.dart';

/// Capabilities:
/// - Render bounded inline or display TeX through a KaTeX-compatible pure
///   Dart/Flutter parser with strict expansion and command limits.
/// - Expose selectable source through a keyboard-accessible copy action without
///   evaluating links, HTML, file access, or user-defined macros.
/// State Ownership: none
/// Public Widgets:
/// - [MathView] — pure presentation for one validated TeX expression.
class MathView extends StatelessWidget {
  const MathView({
    required this.expression,
    this.displayMode = false,
    this.showCopyButton,
    this.maxCharacters,
    super.key,
  });

  static const int defaultInlineMaxCharacters = 512;
  static const int defaultDisplayMaxCharacters = 4096;
  static const int maxBraceDepth = 24;
  static const int maxCommands = 256;
  static const int maxMacroExpansions = 64;

  final String expression;
  final bool displayMode;
  final bool? showCopyButton;
  final int? maxCharacters;

  @override
  Widget build(BuildContext context) {
    ensureRendererDependencyLicensesRegistered();
    final result = SafeMathExpression.parse(
      expression,
      displayMode: displayMode,
      maxCharacters:
          maxCharacters ??
          (displayMode
              ? defaultDisplayMaxCharacters
              : defaultInlineMaxCharacters),
    );
    if (result.error != null) {
      return _MathFailure(
        error: result.error!,
        showCopyButton: showCopyButton ?? displayMode,
        source: result.source,
      );
    }

    final math = Semantics(
      label: '${displayMode ? 'Display' : 'Inline'} formula: ${result.source}',
      image: true,
      child: Math.tex(
        result.source,
        key: const Key('math-rendered-expression'),
        mathStyle: displayMode ? MathStyle.display : MathStyle.text,
        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        settings: const TexParserSettings(
          maxExpand: maxMacroExpansions,
          strict: Strict.error,
        ),
        onErrorFallback: (error) => _MathFailure(
          error: 'The formula could not be rendered safely.',
          source: result.source,
          showCopyButton: false,
        ),
      ),
    );

    if (!displayMode) return math;

    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCopyButton ?? true)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                key: const Key('math-copy-button'),
                tooltip: 'Copy formula',
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: result.source)),
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: math,
          ),
        ],
      ),
    );
  }
}

/// App-owned, validated representation of one TeX expression.
final class SafeMathExpression {
  const SafeMathExpression._({required this.source, this.error});

  factory SafeMathExpression.parse(
    String source, {
    required bool displayMode,
    required int maxCharacters,
  }) {
    final safeLimit = maxCharacters.clamp(
      1,
      displayMode
          ? MathView.defaultDisplayMaxCharacters
          : MathView.defaultInlineMaxCharacters,
    );
    final sanitized = source
        .replaceAll(
          RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'),
          '\uFFFD',
        )
        .trim();
    if (sanitized.isEmpty) {
      return const SafeMathExpression._(
        source: '',
        error: 'The formula is empty.',
      );
    }
    if (sanitized.length > safeLimit) {
      return SafeMathExpression._(
        source: sanitized.substring(0, safeLimit),
        error: 'The formula exceeds the safe rendering limit.',
      );
    }

    var depth = 0;
    var commandCount = 0;
    for (var index = 0; index < sanitized.length; index++) {
      final character = sanitized.codeUnitAt(index);
      if (character == 0x7B) {
        depth++;
        if (depth > MathView.maxBraceDepth) {
          return SafeMathExpression._(
            source: sanitized,
            error: 'The formula nesting depth exceeds the safe limit.',
          );
        }
      } else if (character == 0x7D) {
        depth--;
        if (depth < 0) {
          return SafeMathExpression._(
            source: sanitized,
            error: 'The formula contains unmatched braces.',
          );
        }
      } else if (character == 0x5C) {
        commandCount++;
        if (commandCount > MathView.maxCommands) {
          return SafeMathExpression._(
            source: sanitized,
            error: 'The formula contains too many commands.',
          );
        }
      }
    }
    if (depth != 0) {
      return SafeMathExpression._(
        source: sanitized,
        error: 'The formula contains unmatched braces.',
      );
    }

    final blocked = _blockedTexCommand.firstMatch(sanitized);
    if (blocked != null) {
      return SafeMathExpression._(
        source: sanitized,
        error: 'The formula contains a blocked command.',
      );
    }
    return SafeMathExpression._(source: sanitized);
  }

  final String source;
  final String? error;
}

final RegExp _blockedTexCommand = RegExp(
  r'\\(?:href|url|includegraphics|htmlClass|htmlId|htmlStyle|htmlData|class|style|newcommand|renewcommand|providecommand|def|gdef|edef|xdef|let|futurelet|input|include|openin|openout|read|write|usepackage|require)\b',
  caseSensitive: false,
);

class _MathFailure extends StatelessWidget {
  const _MathFailure({
    required this.error,
    required this.source,
    required this.showCopyButton,
  });

  final String error;
  final String source;
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Formula rendering error: $error',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  error,
                  key: const Key('math-rendering-error'),
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              if (showCopyButton && source.isNotEmpty)
                IconButton(
                  key: const Key('math-copy-button'),
                  tooltip: 'Copy formula',
                  color: scheme.onErrorContainer,
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: source)),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
