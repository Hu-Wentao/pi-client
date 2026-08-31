import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pi_client/widgets/renderer_dependencies/renderer_dependency_inventory.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/csharp.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/diff.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/powershell.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/ruby.dart';
import 'package:re_highlight/languages/rust.dart';
import 'package:re_highlight/languages/shell.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/languages/swift.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart';

/// Capabilities:
/// - Render bounded source code with an explicit language grammar, selectable
///   text, keyboard-accessible copy action, and plain-text fallback.
/// State Ownership: none
/// Public Widgets:
/// - [CodeBlockView] — pure presentation for one bounded source-code block.
class CodeBlockView extends StatelessWidget {
  const CodeBlockView({
    required this.code,
    this.language,
    this.lightweight = false,
    this.showCopyButton = true,
    this.maxCharacters = defaultMaxCharacters,
    this.highlightCharacterLimit = defaultHighlightCharacterLimit,
    super.key,
  });

  static const int defaultMaxCharacters = 50000;
  static const int defaultHighlightCharacterLimit = 20000;

  final String code;
  final String? language;

  /// Disables regex grammar evaluation while content is still streaming.
  final bool lightweight;
  final bool showCopyButton;
  final int maxCharacters;
  final int highlightCharacterLimit;

  @override
  Widget build(BuildContext context) {
    ensureRendererDependencyLicensesRegistered();
    final safeCode = _boundedCode(code, maxCharacters);
    final wasTruncated = safeCode.length < _sanitizeCode(code).length;
    final normalizedLanguage = _normalizeLanguage(language);
    final baseStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          height: 1.45,
          color: Theme.of(context).colorScheme.onSurface,
        ) ??
        const TextStyle(fontFamily: 'monospace', height: 1.45);
    final highlighted =
        !lightweight &&
            safeCode.length <= highlightCharacterLimit &&
            normalizedLanguage != null
        ? _CodeHighlighter.highlight(
            safeCode,
            normalizedLanguage,
            baseStyle,
            Theme.of(context).colorScheme,
          )
        : null;
    final label = normalizedLanguage ?? 'plain text';
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label:
          '$label code block${wasTruncated ? ', truncated to $maxCharacters characters' : ''}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      key: const Key('code-language-label'),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  if (showCopyButton)
                    IconButton(
                      key: const Key('code-copy-button'),
                      tooltip: 'Copy code',
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: safeCode)),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: SelectionArea(
                child: Text.rich(
                  highlighted ?? TextSpan(text: safeCode, style: baseStyle),
                  key: Key(
                    highlighted == null
                        ? 'code-plain-text'
                        : 'code-highlighted-text',
                  ),
                  softWrap: false,
                  textScaler: MediaQuery.textScalerOf(context),
                ),
              ),
            ),
            if (wasTruncated)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
                child: Text(
                  'Code was truncated at the safe rendering limit.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _sanitizeCode(String value) => value.replaceAll(
  RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'),
  '\uFFFD',
);

String _boundedCode(String value, int limit) {
  final safeLimit = limit.clamp(1, CodeBlockView.defaultMaxCharacters);
  final sanitized = _sanitizeCode(value);
  if (sanitized.length <= safeLimit) return sanitized;
  return sanitized.substring(0, safeLimit);
}

String? _normalizeLanguage(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty || normalized == 'text') {
    return null;
  }
  return _languageAliases[normalized] ?? normalized;
}

const _languageAliases = <String, String>{
  'c++': 'cpp',
  'cs': 'csharp',
  'c#': 'csharp',
  'htm': 'xml',
  'html': 'xml',
  'js': 'javascript',
  'jsx': 'javascript',
  'md': 'markdown',
  'ps1': 'powershell',
  'py': 'python',
  'rb': 'ruby',
  'sh': 'bash',
  'shell': 'bash',
  'ts': 'typescript',
  'tsx': 'typescript',
  'yml': 'yaml',
};

abstract final class _CodeHighlighter {
  static final Highlight _engine = _createEngine();

  static TextSpan? highlight(
    String code,
    String language,
    TextStyle baseStyle,
    ColorScheme scheme,
  ) {
    if (_engine.getLanguage(language) == null) return null;
    try {
      final result = _engine.highlight(code: code, language: language);
      final renderer = TextSpanRenderer(baseStyle, _theme(scheme));
      result.render(renderer);
      return renderer.span;
    } on Object {
      return null;
    }
  }

  static Highlight _createEngine() =>
      Highlight()..registerLanguages(<String, Mode>{
        'bash': langBash,
        'c': langC,
        'cpp': langCpp,
        'csharp': langCsharp,
        'css': langCss,
        'dart': langDart,
        'diff': langDiff,
        'go': langGo,
        'java': langJava,
        'javascript': langJavascript,
        'json': langJson,
        'kotlin': langKotlin,
        'markdown': langMarkdown,
        'powershell': langPowershell,
        'python': langPython,
        'ruby': langRuby,
        'rust': langRust,
        'shell': langShell,
        'sql': langSql,
        'swift': langSwift,
        'typescript': langTypescript,
        'xml': langXml,
        'yaml': langYaml,
      });

  static Map<String, TextStyle> _theme(
    ColorScheme scheme,
  ) => <String, TextStyle>{
    'root': TextStyle(color: scheme.onSurface),
    'keyword': TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
    'selector-tag': TextStyle(color: scheme.primary),
    'literal': TextStyle(color: scheme.tertiary),
    'number': TextStyle(color: scheme.tertiary),
    'string': TextStyle(color: scheme.secondary),
    'regexp': TextStyle(color: scheme.secondary),
    'title': TextStyle(color: scheme.primary),
    'title.function_': TextStyle(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
    ),
    'type': TextStyle(color: scheme.tertiary),
    'built_in': TextStyle(color: scheme.tertiary),
    'comment': TextStyle(
      color: scheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    ),
    'doctag': TextStyle(color: scheme.secondary),
    'meta': TextStyle(color: scheme.onSurfaceVariant),
    'variable': TextStyle(color: scheme.onSurface),
    'attr': TextStyle(color: scheme.primary),
    'attribute': TextStyle(color: scheme.primary),
    'symbol': TextStyle(color: scheme.tertiary),
    'addition': TextStyle(
      color: scheme.onTertiaryContainer,
      backgroundColor: scheme.tertiaryContainer,
    ),
    'deletion': TextStyle(
      color: scheme.onErrorContainer,
      backgroundColor: scheme.errorContainer,
    ),
    'strong': const TextStyle(fontWeight: FontWeight.bold),
    'emphasis': const TextStyle(fontStyle: FontStyle.italic),
  };
}
