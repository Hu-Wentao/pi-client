import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pi_client/widgets/code_block_view/code_block_view.dart';
import 'package:pi_client/widgets/math_view/math_view.dart';
import 'package:pi_client/widgets/mermaid_view/mermaid_view.dart';
import 'package:pi_client/widgets/renderer_dependencies/renderer_dependency_inventory.dart';

/// Called for a sanitized Markdown link after the user activates it.
typedef MarkdownLinkCallback = void Function(Uri uri);

/// Resolves a sanitized image URI without giving the renderer network or file
/// access of its own.
typedef MarkdownImageBuilder =
    Widget? Function(BuildContext context, Uri uri, String description);

/// Capabilities:
/// - Parse bounded GFM-like Markdown into an app-owned sanitized AST and render
///   headings, lists, task lists, tables, blockquotes, emphasis, links, code,
///   TeX, Mermaid, and the raw HTML allowlist `br/kbd/sub/sup/mark`.
/// - Block executable/local URL schemes and remote images by default, while
///   exposing only explicit app callbacks for safe navigation and images.
/// State Ownership: none
/// Public Widgets:
/// - [MarkdownBody] — pure presentation for one bounded Markdown document.
class MarkdownBody extends StatefulWidget {
  const MarkdownBody({
    required this.data,
    this.streaming = false,
    this.onOpenLink,
    this.imageBuilder,
    this.allowRemoteImages = false,
    this.limits = const MarkdownRenderLimits(),
    super.key,
  });

  final String data;

  /// Uses smaller limits and skips syntax, TeX, and Mermaid work while tokens
  /// are still arriving.
  final bool streaming;
  final MarkdownLinkCallback? onOpenLink;
  final MarkdownImageBuilder? imageBuilder;
  final bool allowRemoteImages;
  final MarkdownRenderLimits limits;

  @override
  State<MarkdownBody> createState() => _MarkdownBodyState();
}

/// Hard Markdown parser and renderer limits.
final class MarkdownRenderLimits {
  const MarkdownRenderLimits({
    this.maxTextCharacters = 100000,
    this.maxAstNodes = 4000,
    this.maxDepth = 32,
    this.maxTableRows = 100,
    this.maxTableColumns = 20,
    this.maxCodeCharacters = 50000,
    this.maxMathCharacters = 4096,
    this.maxDiagramCharacters = 20000,
  });

  final int maxTextCharacters;
  final int maxAstNodes;
  final int maxDepth;
  final int maxTableRows;
  final int maxTableColumns;
  final int maxCodeCharacters;
  final int maxMathCharacters;
  final int maxDiagramCharacters;

  MarkdownRenderLimits forStreaming() => MarkdownRenderLimits(
    maxTextCharacters: maxTextCharacters.clamp(1, 16000),
    maxAstNodes: maxAstNodes.clamp(1, 800),
    maxDepth: maxDepth.clamp(1, 12),
    maxTableRows: maxTableRows.clamp(1, 20),
    maxTableColumns: maxTableColumns.clamp(1, 10),
    maxCodeCharacters: maxCodeCharacters.clamp(1, 8000),
    maxMathCharacters: maxMathCharacters.clamp(1, 1024),
    maxDiagramCharacters: maxDiagramCharacters.clamp(1, 4000),
  );
}

class _MarkdownBodyState extends State<MarkdownBody> {
  late _SafeMarkdownDocument _document;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(covariant MarkdownBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.streaming != widget.streaming ||
        oldWidget.limits != widget.limits) {
      _parse();
    }
  }

  void _parse() {
    _document = _SafeMarkdownParser(
      widget.streaming ? widget.limits.forStreaming() : widget.limits,
    ).parse(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    ensureRendererDependencyLicensesRegistered();
    final renderer = _MarkdownWidgetRenderer(
      context: context,
      onOpenLink: widget.onOpenLink,
      imageBuilder: widget.imageBuilder,
      allowRemoteImages: widget.allowRemoteImages,
      streaming: widget.streaming,
      limits: widget.streaming ? widget.limits.forStreaming() : widget.limits,
    );
    final children = <Widget>[
      for (final node in _document.children) ...[
        renderer.block(node),
        const SizedBox(height: 10),
      ],
      if (_document.wasLimited)
        Semantics(
          liveRegion: true,
          label: 'Markdown content was limited for safe rendering',
          child: Text(
            'Some content was omitted at the safe rendering limit.',
            key: const Key('markdown-limit-notice'),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];
    if (children.isNotEmpty && children.last is SizedBox) {
      children.removeLast();
    }
    return SelectionArea(
      child: Semantics(
        container: true,
        label: widget.streaming
            ? 'Streaming Markdown content'
            : 'Markdown content',
        child: Column(
          key: const Key('markdown-body'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

enum _SafeMarkdownTag {
  paragraph,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  blockquote,
  unorderedList,
  orderedList,
  listItem,
  table,
  tableHead,
  tableBody,
  tableRow,
  tableHeaderCell,
  tableCell,
  strong,
  emphasis,
  strikethrough,
  inlineCode,
  codeBlock,
  link,
  image,
  hardBreak,
  horizontalRule,
  kbd,
  subscript,
  superscript,
  mark,
  inlineMath,
  displayMath,
  mermaid,
  plain,
}

sealed class _SafeMarkdownNode {
  const _SafeMarkdownNode();

  String get plainText;
}

final class _SafeMarkdownText extends _SafeMarkdownNode {
  const _SafeMarkdownText(this.text);

  final String text;

  @override
  String get plainText => text;
}

final class _SafeMarkdownElement extends _SafeMarkdownNode {
  const _SafeMarkdownElement({
    required this.tag,
    this.children = const <_SafeMarkdownNode>[],
    this.value,
    this.uri,
    this.language,
    this.checked,
    this.truncated = false,
    this.remoteImage = false,
  });

  final _SafeMarkdownTag tag;
  final List<_SafeMarkdownNode> children;
  final String? value;
  final Uri? uri;
  final String? language;
  final bool? checked;
  final bool truncated;
  final bool remoteImage;

  @override
  String get plainText =>
      value ?? children.map((child) => child.plainText).join();
}

final class _SafeMarkdownDocument {
  const _SafeMarkdownDocument({
    required this.children,
    required this.wasLimited,
  });

  final List<_SafeMarkdownNode> children;
  final bool wasLimited;
}

final class _SafeMarkdownParser {
  _SafeMarkdownParser(this.limits);

  final MarkdownRenderLimits limits;
  var _nodeCount = 0;
  var _wasLimited = false;
  var _tableRows = 0;
  late _HtmlPreprocessResult _html;

  _SafeMarkdownDocument parse(String source) {
    final sanitized = source.replaceAll(
      RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'),
      '\uFFFD',
    );
    final input = sanitized.length <= limits.maxTextCharacters
        ? sanitized
        : sanitized.substring(0, limits.maxTextCharacters);
    _wasLimited = input.length < sanitized.length;
    _html = _preprocessHtml(input);
    final extensionSet = md.ExtensionSet(
      <md.BlockSyntax>[
        const _DisplayMathSyntax(),
        ...md.ExtensionSet.gitHubWeb.blockSyntaxes,
      ],
      <md.InlineSyntax>[
        _InlineMathSyntax(),
        ...md.ExtensionSet.gitHubWeb.inlineSyntaxes.where(
          (syntax) => syntax is! md.InlineHtmlSyntax,
        ),
      ],
    );
    final parsed = md.Document(
      extensionSet: extensionSet,
      encodeHtml: false,
    ).parse(_html.source);
    final converted = _convertChildren(parsed, 0);
    return _SafeMarkdownDocument(
      children: List<_SafeMarkdownNode>.unmodifiable(converted),
      wasLimited: _wasLimited,
    );
  }

  List<_SafeMarkdownNode> _convertChildren(List<md.Node>? nodes, int depth) {
    if (nodes == null || nodes.isEmpty) return const <_SafeMarkdownNode>[];
    final converted = <_SafeMarkdownNode>[];
    for (final node in nodes) {
      final safe = _convert(node, depth);
      if (safe != null) converted.addAll(safe);
      if (_nodeCount >= limits.maxAstNodes) {
        _wasLimited = true;
        break;
      }
    }
    return _nestHtmlMarkers(converted);
  }

  List<_SafeMarkdownNode>? _convert(md.Node node, int depth) {
    if (_nodeCount >= limits.maxAstNodes) {
      _wasLimited = true;
      return null;
    }
    _nodeCount++;
    if (depth > limits.maxDepth) {
      _wasLimited = true;
      return const <_SafeMarkdownNode>[
        _SafeMarkdownText('[Content omitted: nesting limit]'),
      ];
    }
    if (node is md.Text) return _splitHtmlTokens(node.text);
    if (node is! md.Element) return const <_SafeMarkdownNode>[];

    if (node.tag == 'table') {
      _tableRows = 0;
      final tableChildren = _convertChildren(node.children, depth + 1);
      return <_SafeMarkdownNode>[
        _SafeMarkdownElement(
          tag: _SafeMarkdownTag.table,
          children: tableChildren,
        ),
      ];
    }

    final children = _convertChildren(node.children, depth + 1);
    switch (node.tag) {
      case 'p':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.paragraph,
            children: children,
          ),
        ];
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final level = int.parse(node.tag.substring(1));
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(tag: _headingTag(level), children: children),
        ];
      case 'blockquote':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.blockquote,
            children: children,
          ),
        ];
      case 'ul':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.unorderedList,
            children: children,
          ),
        ];
      case 'ol':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.orderedList,
            children: children,
          ),
        ];
      case 'li':
        final checkbox = node.children
            ?.whereType<md.Element>()
            .where((child) => child.tag == 'input')
            .firstOrNull;
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.listItem,
            children: children
                .where((child) => child is! _SafeHtmlInputMarker)
                .toList(growable: false),
            checked: checkbox?.attributes.containsKey('checked'),
          ),
        ];
      case 'input':
        return const <_SafeMarkdownNode>[_SafeHtmlInputMarker()];
      case 'thead':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.tableHead,
            children: children,
          ),
        ];
      case 'tbody':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.tableBody,
            children: children,
          ),
        ];
      case 'tr':
        _tableRows++;
        if (_tableRows > limits.maxTableRows) {
          _wasLimited = true;
          return const <_SafeMarkdownNode>[];
        }
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.tableRow,
            children: children
                .take(limits.maxTableColumns)
                .toList(growable: false),
          ),
        ];
      case 'th':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.tableHeaderCell,
            children: children,
          ),
        ];
      case 'td':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.tableCell,
            children: children,
          ),
        ];
      case 'strong':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.strong,
            children: children,
          ),
        ];
      case 'em':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.emphasis,
            children: children,
          ),
        ];
      case 'del':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.strikethrough,
            children: children,
          ),
        ];
      case 'code':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.inlineCode,
            value: node.textContent,
          ),
        ];
      case 'pre':
        return <_SafeMarkdownNode>[_codeBlock(node)];
      case 'a':
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.link,
            children: children,
            uri: _safeLinkUri(node.attributes['href']),
          ),
        ];
      case 'img':
        final uri = _safeImageUri(node.attributes['src']);
        return <_SafeMarkdownNode>[
          _SafeMarkdownElement(
            tag: _SafeMarkdownTag.image,
            value: node.attributes['alt'] ?? node.textContent,
            uri: uri,
            remoteImage:
                uri?.hasAuthority == true ||
                uri?.scheme == 'http' ||
                uri?.scheme == 'https',
          ),
        ];
      case 'br':
        return const <_SafeMarkdownNode>[
          _SafeMarkdownElement(tag: _SafeMarkdownTag.hardBreak),
        ];
      case 'hr':
        return const <_SafeMarkdownNode>[
          _SafeMarkdownElement(tag: _SafeMarkdownTag.horizontalRule),
        ];
      case 'pi-math-inline':
        return <_SafeMarkdownNode>[
          _boundedValueElement(
            _SafeMarkdownTag.inlineMath,
            node.textContent,
            limits.maxMathCharacters,
          ),
        ];
      case 'pi-math-block':
        return <_SafeMarkdownNode>[
          _boundedValueElement(
            _SafeMarkdownTag.displayMath,
            node.textContent,
            limits.maxMathCharacters,
          ),
        ];
      default:
        return children;
    }
  }

  _SafeMarkdownElement _codeBlock(md.Element pre) {
    final code = pre.children?.whereType<md.Element>().firstOrNull;
    final rawClass = code?.attributes['class'];
    final language = rawClass?.startsWith('language-') == true
        ? rawClass!.substring('language-'.length).trim().toLowerCase()
        : null;
    final value = code?.textContent ?? pre.textContent;
    if (language == 'mermaid') {
      return _boundedValueElement(
        _SafeMarkdownTag.mermaid,
        value,
        limits.maxDiagramCharacters,
      );
    }
    if (language == 'math' || language == 'tex' || language == 'latex') {
      return _boundedValueElement(
        _SafeMarkdownTag.displayMath,
        value,
        limits.maxMathCharacters,
      );
    }
    final bounded = value.length <= limits.maxCodeCharacters
        ? value
        : value.substring(0, limits.maxCodeCharacters);
    if (bounded.length < value.length) _wasLimited = true;
    return _SafeMarkdownElement(
      tag: _SafeMarkdownTag.codeBlock,
      value: bounded,
      language: language,
      truncated: bounded.length < value.length,
    );
  }

  _SafeMarkdownElement _boundedValueElement(
    _SafeMarkdownTag tag,
    String value,
    int limit,
  ) {
    final bounded = value.length <= limit ? value : value.substring(0, limit);
    if (bounded.length < value.length) _wasLimited = true;
    return _SafeMarkdownElement(
      tag: tag,
      value: bounded,
      truncated: bounded.length < value.length,
    );
  }

  List<_SafeMarkdownNode> _splitHtmlTokens(String text) {
    final result = <_SafeMarkdownNode>[];

    bool addNode(_SafeMarkdownNode node) {
      if (_nodeCount >= limits.maxAstNodes) {
        _wasLimited = true;
        return false;
      }
      _nodeCount++;
      result.add(node);
      return true;
    }

    var cursor = 0;
    for (final match in _htmlTokenPattern.allMatches(text)) {
      if (match.start > cursor &&
          !addNode(_SafeMarkdownText(text.substring(cursor, match.start)))) {
        break;
      }
      final token = _html.tokens[int.parse(match.group(1)!)];
      if (!addNode(_SafeHtmlMarker(token))) break;
      cursor = match.end;
    }
    if (cursor < text.length && _nodeCount < limits.maxAstNodes) {
      addNode(_SafeMarkdownText(text.substring(cursor)));
    }
    return result;
  }
}

final class _SafeHtmlInputMarker extends _SafeMarkdownNode {
  const _SafeHtmlInputMarker();

  @override
  String get plainText => '';
}

final class _SafeHtmlMarker extends _SafeMarkdownNode {
  const _SafeHtmlMarker(this.token);

  final _HtmlToken token;

  @override
  String get plainText => '';
}

final class _HtmlFrame {
  _HtmlFrame(this.tag);

  final _SafeMarkdownTag tag;
  final List<_SafeMarkdownNode> children = <_SafeMarkdownNode>[];
}

List<_SafeMarkdownNode> _nestHtmlMarkers(List<_SafeMarkdownNode> nodes) {
  final root = _HtmlFrame(_SafeMarkdownTag.plain);
  final stack = <_HtmlFrame>[root];
  for (final node in nodes) {
    if (node is! _SafeHtmlMarker) {
      stack.last.children.add(node);
      continue;
    }
    final tag = _htmlTag(node.token.name);
    if (tag == null) continue;
    if (node.token.name == 'br') {
      stack.last.children.add(
        const _SafeMarkdownElement(tag: _SafeMarkdownTag.hardBreak),
      );
    } else if (!node.token.closing) {
      stack.add(_HtmlFrame(tag));
    } else if (stack.length > 1 && stack.last.tag == tag) {
      final frame = stack.removeLast();
      stack.last.children.add(
        _SafeMarkdownElement(
          tag: frame.tag,
          children: List<_SafeMarkdownNode>.unmodifiable(frame.children),
        ),
      );
    }
  }
  while (stack.length > 1) {
    final unclosed = stack.removeLast();
    stack.last.children.addAll(unclosed.children);
  }
  return root.children;
}

_SafeMarkdownTag? _htmlTag(String value) => switch (value) {
  'kbd' => _SafeMarkdownTag.kbd,
  'sub' => _SafeMarkdownTag.subscript,
  'sup' => _SafeMarkdownTag.superscript,
  'mark' => _SafeMarkdownTag.mark,
  'br' => _SafeMarkdownTag.hardBreak,
  _ => null,
};

_SafeMarkdownTag _headingTag(int level) => switch (level) {
  1 => _SafeMarkdownTag.heading1,
  2 => _SafeMarkdownTag.heading2,
  3 => _SafeMarkdownTag.heading3,
  4 => _SafeMarkdownTag.heading4,
  5 => _SafeMarkdownTag.heading5,
  _ => _SafeMarkdownTag.heading6,
};

Uri? _safeLinkUri(String? value) {
  if (value == null || value.length > 2048) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null) return null;
  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'javascript' || scheme == 'data' || scheme == 'file') {
    return null;
  }
  if (scheme.isNotEmpty &&
      scheme != 'http' &&
      scheme != 'https' &&
      scheme != 'mailto') {
    return null;
  }
  return uri;
}

Uri? _safeImageUri(String? value) {
  final uri = _safeLinkUri(value);
  if (uri == null || uri.scheme == 'mailto') return null;
  return uri;
}

final class _HtmlToken {
  const _HtmlToken(this.name, this.closing);

  final String name;
  final bool closing;
}

final class _HtmlPreprocessResult {
  const _HtmlPreprocessResult(this.source, this.tokens);

  final String source;
  final List<_HtmlToken> tokens;
}

final RegExp _htmlTokenPattern = RegExp(r'\uE000PIH(\d+)\uE001');

_HtmlPreprocessResult _preprocessHtml(String source) {
  final tokens = <_HtmlToken>[];
  final output = StringBuffer();
  String? fenceCharacter;
  var fenceLength = 0;
  final lines = source.split('\n');
  for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    final fence = RegExp(r'^\s{0,3}(`{3,}|~{3,})').firstMatch(line);
    if (fence != null) {
      final marker = fence.group(1)!;
      if (fenceCharacter == null) {
        fenceCharacter = marker[0];
        fenceLength = marker.length;
      } else if (marker[0] == fenceCharacter && marker.length >= fenceLength) {
        fenceCharacter = null;
        fenceLength = 0;
      }
      output.write(line);
    } else if (fenceCharacter != null) {
      output.write(line);
    } else {
      var cursor = 0;
      for (final match in _rawHtmlPattern.allMatches(line)) {
        output.write(line.substring(cursor, match.start));
        final tag = _allowedHtmlPattern.firstMatch(match.group(0)!);
        if (tag != null) {
          final name = tag.group(2)!.toLowerCase();
          final closing = tag.group(1) != null;
          final index = tokens.length;
          tokens.add(_HtmlToken(name, closing));
          output.write('\uE000PIH$index\uE001');
        }
        cursor = match.end;
      }
      output.write(line.substring(cursor));
    }
    if (lineIndex != lines.length - 1) output.writeln();
  }
  return _HtmlPreprocessResult(output.toString(), tokens);
}

final RegExp _rawHtmlPattern = RegExp(r'<!--[\s\S]*?-->|<[^>\n]{1,1024}>');
final RegExp _allowedHtmlPattern = RegExp(
  r'^<\s*(/)?\s*(br|kbd|sub|sup|mark)\b[^>]*?/?>$',
  caseSensitive: false,
);

final class _DisplayMathSyntax extends md.BlockSyntax {
  const _DisplayMathSyntax();

  @override
  RegExp get pattern => RegExp(r'^\s{0,3}\$\$\s*$');

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();
    final content = <String>[];
    while (!parser.isDone) {
      if (pattern.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      }
      content.add(parser.current.content);
      parser.advance();
    }
    return md.Element.text('pi-math-block', content.join('\n'));
  }
}

final class _InlineMathSyntax extends md.InlineSyntax {
  _InlineMathSyntax()
    : super(r'\$(?!\$)([^$\n]+?)\$(?!\$)', startCharacter: 0x24);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('pi-math-inline', match.group(1)!));
    return true;
  }
}

final class _MarkdownWidgetRenderer {
  const _MarkdownWidgetRenderer({
    required this.context,
    required this.onOpenLink,
    required this.imageBuilder,
    required this.allowRemoteImages,
    required this.streaming,
    required this.limits,
  });

  final BuildContext context;
  final MarkdownLinkCallback? onOpenLink;
  final MarkdownImageBuilder? imageBuilder;
  final bool allowRemoteImages;
  final bool streaming;
  final MarkdownRenderLimits limits;

  Widget block(_SafeMarkdownNode node) {
    if (node is _SafeMarkdownText) return _paragraph(<_SafeMarkdownNode>[node]);
    if (node is! _SafeMarkdownElement) return const SizedBox.shrink();
    return switch (node.tag) {
      _SafeMarkdownTag.paragraph => _paragraph(node.children),
      _SafeMarkdownTag.heading1 ||
      _SafeMarkdownTag.heading2 ||
      _SafeMarkdownTag.heading3 ||
      _SafeMarkdownTag.heading4 ||
      _SafeMarkdownTag.heading5 ||
      _SafeMarkdownTag.heading6 => _heading(node),
      _SafeMarkdownTag.blockquote => _blockquote(node),
      _SafeMarkdownTag.unorderedList => _list(node, ordered: false),
      _SafeMarkdownTag.orderedList => _list(node, ordered: true),
      _SafeMarkdownTag.table => _table(node),
      _SafeMarkdownTag.codeBlock => CodeBlockView(
        code: node.value ?? '',
        language: node.language,
        lightweight: streaming,
        maxCharacters: limits.maxCodeCharacters,
      ),
      _SafeMarkdownTag.displayMath =>
        streaming
            ? CodeBlockView(
                code: node.value ?? '',
                language: 'tex',
                lightweight: true,
                maxCharacters: limits.maxMathCharacters,
              )
            : MathView(
                expression: node.value ?? '',
                displayMode: true,
                maxCharacters: limits.maxMathCharacters,
              ),
      _SafeMarkdownTag.mermaid => MermaidView(
        source: node.value ?? '',
        streaming: streaming,
        limits: MermaidRenderLimits(
          maxSourceCharacters: limits.maxDiagramCharacters,
        ),
      ),
      _SafeMarkdownTag.horizontalRule => const Divider(),
      _ => _paragraph(<_SafeMarkdownNode>[node]),
    };
  }

  Widget _paragraph(List<_SafeMarkdownNode> children) => Text.rich(
    TextSpan(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
      children: _inline(children),
    ),
  );

  Widget _heading(_SafeMarkdownElement node) {
    final style = switch (node.tag) {
      _SafeMarkdownTag.heading1 => Theme.of(context).textTheme.headlineMedium,
      _SafeMarkdownTag.heading2 => Theme.of(context).textTheme.headlineSmall,
      _SafeMarkdownTag.heading3 => Theme.of(context).textTheme.titleLarge,
      _SafeMarkdownTag.heading4 => Theme.of(context).textTheme.titleMedium,
      _SafeMarkdownTag.heading5 => Theme.of(context).textTheme.titleSmall,
      _ => Theme.of(context).textTheme.labelLarge,
    };
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          style: style?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
          children: _inline(node.children),
        ),
      ),
    );
  }

  Widget _blockquote(_SafeMarkdownElement node) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: BorderDirectional(
          start: BorderSide(color: scheme.primary, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final child in node.children) block(child)],
        ),
      ),
    );
  }

  Widget _list(_SafeMarkdownElement node, {required bool ordered}) {
    var ordinal = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in node.children)
          if (child is _SafeMarkdownElement &&
              child.tag == _SafeMarkdownTag.listItem)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    child: child.checked == null
                        ? Text(
                            ordered ? '${ordinal++}.' : '•',
                            textAlign: TextAlign.center,
                          )
                        : Semantics(
                            label: child.checked!
                                ? 'Completed task'
                                : 'Incomplete task',
                            child: Icon(
                              child.checked!
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              size: 19,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final itemChild in child.children)
                          block(itemChild),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _table(_SafeMarkdownElement node) {
    final rows = <TableRow>[];
    final rowNodes = _descendants(node, _SafeMarkdownTag.tableRow);
    for (final row in rowNodes) {
      final cells = row.children
          .whereType<_SafeMarkdownElement>()
          .where(
            (cell) =>
                cell.tag == _SafeMarkdownTag.tableCell ||
                cell.tag == _SafeMarkdownTag.tableHeaderCell,
          )
          .toList(growable: false);
      if (cells.isEmpty) continue;
      rows.add(
        TableRow(
          decoration:
              cells.any((cell) => cell.tag == _SafeMarkdownTag.tableHeaderCell)
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                )
              : null,
          children: [
            for (final cell in cells)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: cell.tag == _SafeMarkdownTag.tableHeaderCell
                          ? FontWeight.w700
                          : null,
                    ),
                    children: _inline(cell.children),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360),
        child: Table(
          key: const Key('markdown-table'),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          children: rows,
        ),
      ),
    );
  }

  List<InlineSpan> _inline(
    List<_SafeMarkdownNode> nodes, {
    TextStyle? inheritedStyle,
  }) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is _SafeMarkdownText) {
        spans.add(TextSpan(text: node.text, style: inheritedStyle));
        continue;
      }
      if (node is! _SafeMarkdownElement) continue;
      switch (node.tag) {
        case _SafeMarkdownTag.strong:
          spans.addAll(
            _inline(
              node.children,
              inheritedStyle:
                  inheritedStyle?.merge(
                    const TextStyle(fontWeight: FontWeight.bold),
                  ) ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        case _SafeMarkdownTag.emphasis:
          spans.addAll(
            _inline(
              node.children,
              inheritedStyle:
                  inheritedStyle?.merge(
                    const TextStyle(fontStyle: FontStyle.italic),
                  ) ??
                  const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        case _SafeMarkdownTag.strikethrough:
          spans.addAll(
            _inline(
              node.children,
              inheritedStyle:
                  inheritedStyle?.merge(
                    const TextStyle(decoration: TextDecoration.lineThrough),
                  ) ??
                  const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          );
        case _SafeMarkdownTag.inlineCode:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  child: Text(
                    node.value ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          );
        case _SafeMarkdownTag.link:
          spans.add(_linkSpan(node));
        case _SafeMarkdownTag.image:
          spans.add(_imageSpan(node));
        case _SafeMarkdownTag.hardBreak:
          spans.add(const TextSpan(text: '\n'));
        case _SafeMarkdownTag.kbd:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  child: Text(
                    node.plainText,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          );
        case _SafeMarkdownTag.subscript:
        case _SafeMarkdownTag.superscript:
          spans.add(
            WidgetSpan(
              alignment: node.tag == _SafeMarkdownTag.superscript
                  ? PlaceholderAlignment.top
                  : PlaceholderAlignment.bottom,
              child: Text(
                node.plainText,
                textScaler: MediaQuery.textScalerOf(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          );
        case _SafeMarkdownTag.mark:
          spans.addAll(
            _inline(
              node.children,
              inheritedStyle:
                  inheritedStyle?.merge(
                    TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                    ),
                  ) ??
                  TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                  ),
            ),
          );
        case _SafeMarkdownTag.inlineMath:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: streaming
                  ? Text(
                      node.value ?? '',
                      style: const TextStyle(fontFamily: 'monospace'),
                    )
                  : MathView(
                      expression: node.value ?? '',
                      maxCharacters: limits.maxMathCharacters,
                    ),
            ),
          );
        default:
          spans.addAll(_inline(node.children, inheritedStyle: inheritedStyle));
      }
    }
    return spans;
  }

  InlineSpan _linkSpan(_SafeMarkdownElement node) {
    final uri = node.uri;
    final enabled = uri != null && onOpenLink != null;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Semantics(
        link: true,
        label: enabled
            ? 'Open link ${node.plainText}'
            : 'Blocked link ${node.plainText}',
        child: InkWell(
          key: Key(enabled ? 'markdown-safe-link' : 'markdown-blocked-link'),
          onTap: enabled ? () => onOpenLink!(uri) : null,
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: enabled
                    ? TextDecoration.underline
                    : TextDecoration.lineThrough,
              ),
              children: _inline(node.children),
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan _imageSpan(_SafeMarkdownElement node) {
    final uri = node.uri;
    final description = node.value?.trim().isNotEmpty == true
        ? node.value!
        : 'image';
    final remoteBlocked = node.remoteImage && !allowRemoteImages;
    final resolved = uri != null && !remoteBlocked && imageBuilder != null
        ? imageBuilder!(context, uri, description)
        : null;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child:
          resolved ??
          Semantics(
            image: true,
            label: remoteBlocked
                ? 'Remote image blocked: $description'
                : 'Image unavailable: $description',
            child: Chip(
              key: Key(
                remoteBlocked
                    ? 'markdown-remote-image-blocked'
                    : 'markdown-image-unavailable',
              ),
              avatar: const Icon(Icons.image_not_supported_outlined, size: 16),
              label: Text(remoteBlocked ? 'Remote image blocked' : description),
            ),
          ),
    );
  }
}

Iterable<_SafeMarkdownElement> _descendants(
  _SafeMarkdownElement root,
  _SafeMarkdownTag tag,
) sync* {
  for (final child in root.children) {
    if (child is! _SafeMarkdownElement) continue;
    if (child.tag == tag) yield child;
    yield* _descendants(child, tag);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
