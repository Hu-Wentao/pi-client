import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// State Ownership: none
/// Capabilities:
/// - Parse app-owned unified patches into files, hunks, and typed lines.
/// - Render accessible wrapped or side-by-side diffs with virtualized rows.
/// - Copy the bounded patch projection without interpreting file paths.
/// Public Widgets:
/// - [DiffView] — pure presentation for a unified patch.
/// Public Models:
/// - [UnifiedDiffParser] — bounded app-owned unified patch parser.
/// - [UnifiedDiffDocument] — immutable parsed patch.
enum DiffLayoutMode { auto, wrapped, sideBySide }

enum UnifiedDiffLineKind {
  fileHeader,
  metadata,
  hunkHeader,
  addition,
  deletion,
  context,
  noNewline,
  binary,
  unknown,
}

final class UnifiedDiffParser {
  const UnifiedDiffParser({
    this.maxPatchCodeUnits = 4 * 1024 * 1024,
    this.maxLines = 100000,
    this.maxLineCodeUnits = 64 * 1024,
  });

  final int maxPatchCodeUnits;
  final int maxLines;
  final int maxLineCodeUnits;

  UnifiedDiffDocument parse(String patch) {
    if (maxPatchCodeUnits <= 0 || maxLines <= 0 || maxLineCodeUnits <= 0) {
      throw StateError('Diff parser limits must be positive.');
    }
    final inputTruncated = patch.length > maxPatchCodeUnits;
    final bounded = inputTruncated
        ? patch.substring(0, maxPatchCodeUnits)
        : patch;
    final normalized = bounded.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final sourceLines = normalized.split('\n');
    final lineLimitReached = sourceLines.length > maxLines;
    final parsedLines = <UnifiedDiffLine>[];
    final files = <UnifiedDiffFile>[];
    final preamble = <UnifiedDiffLine>[];
    _MutableFile? currentFile;
    _MutableHunk? currentHunk;
    var oldLine = 0;
    var newLine = 0;

    void finishHunk() {
      final hunk = currentHunk;
      if (hunk == null) return;
      currentFile ??= _MutableFile(index: files.length);
      currentFile!.hunks.add(hunk.build());
      currentHunk = null;
    }

    void finishFile() {
      finishHunk();
      final file = currentFile;
      if (file == null) return;
      files.add(file.build());
      currentFile = null;
    }

    final count = sourceLines.length.clamp(0, maxLines);
    for (var index = 0; index < count; index += 1) {
      var raw = sourceLines[index];
      var lineTruncated = false;
      if (raw.length > maxLineCodeUnits) {
        raw = '${raw.substring(0, maxLineCodeUnits)}…';
        lineTruncated = true;
      }

      if (raw.startsWith('diff --git ')) {
        finishFile();
        currentFile = _MutableFile(index: files.length);
        final paths = _parseDiffGitPaths(raw);
        currentFile!
          ..oldPath = paths.$1
          ..newPath = paths.$2;
        final line = UnifiedDiffLine(
          kind: UnifiedDiffLineKind.fileHeader,
          text: raw,
          fileIndex: currentFile!.index,
          truncated: lineTruncated,
        );
        currentFile!.headers.add(line);
        parsedLines.add(line);
        continue;
      }

      if (raw.startsWith('--- ')) {
        finishHunk();
        currentFile ??= _MutableFile(index: files.length);
        currentFile!.oldPath = _parseHeaderPath(raw.substring(4));
        final line = UnifiedDiffLine(
          kind: UnifiedDiffLineKind.fileHeader,
          text: raw,
          fileIndex: currentFile!.index,
          truncated: lineTruncated,
        );
        currentFile!.headers.add(line);
        parsedLines.add(line);
        continue;
      }

      if (raw.startsWith('+++ ')) {
        currentFile ??= _MutableFile(index: files.length);
        currentFile!.newPath = _parseHeaderPath(raw.substring(4));
        final line = UnifiedDiffLine(
          kind: UnifiedDiffLineKind.fileHeader,
          text: raw,
          fileIndex: currentFile!.index,
          truncated: lineTruncated,
        );
        currentFile!.headers.add(line);
        parsedLines.add(line);
        continue;
      }

      final hunkMatch = _hunkHeader.firstMatch(raw);
      if (hunkMatch != null) {
        finishHunk();
        currentFile ??= _MutableFile(index: files.length);
        oldLine = int.tryParse(hunkMatch.group(1)!) ?? 0;
        newLine = int.tryParse(hunkMatch.group(3)!) ?? 0;
        currentHunk = _MutableHunk(
          index: currentFile!.hunks.length,
          oldStart: oldLine,
          oldCount: int.tryParse(hunkMatch.group(2) ?? '') ?? 1,
          newStart: newLine,
          newCount: int.tryParse(hunkMatch.group(4) ?? '') ?? 1,
          heading: hunkMatch.group(5)?.trim() ?? '',
        );
        final line = UnifiedDiffLine(
          kind: UnifiedDiffLineKind.hunkHeader,
          text: raw,
          fileIndex: currentFile!.index,
          hunkIndex: currentHunk!.index,
          truncated: lineTruncated,
        );
        currentHunk!.lines.add(line);
        parsedLines.add(line);
        continue;
      }

      final kind = _classifyLine(raw, currentHunk != null);
      final fileIndex = currentFile?.index;
      final hunkIndex = currentHunk?.index;
      int? lineOld;
      int? lineNew;
      if (currentHunk != null) {
        switch (kind) {
          case UnifiedDiffLineKind.deletion:
            lineOld = oldLine;
            oldLine += 1;
          case UnifiedDiffLineKind.addition:
            lineNew = newLine;
            newLine += 1;
          case UnifiedDiffLineKind.context:
            lineOld = oldLine;
            lineNew = newLine;
            oldLine += 1;
            newLine += 1;
          default:
            break;
        }
      }
      final line = UnifiedDiffLine(
        kind: kind,
        text: raw,
        oldLineNumber: lineOld,
        newLineNumber: lineNew,
        fileIndex: fileIndex,
        hunkIndex: hunkIndex,
        truncated: lineTruncated,
      );
      parsedLines.add(line);
      if (currentHunk != null) {
        currentHunk!.lines.add(line);
      } else if (currentFile != null) {
        currentFile!.headers.add(line);
      } else {
        preamble.add(line);
      }
    }
    finishFile();

    final truncated = inputTruncated || lineLimitReached;
    if (truncated) {
      final marker = UnifiedDiffLine(
        kind: UnifiedDiffLineKind.metadata,
        text: '… patch truncated by renderer safety limit …',
        truncated: true,
      );
      parsedLines.add(marker);
      preamble.add(marker);
    }

    return UnifiedDiffDocument(
      source: normalized,
      lines: parsedLines,
      files: files,
      preamble: preamble,
      truncated: truncated,
      originalCodeUnits: patch.length,
    );
  }
}

final class UnifiedDiffDocument {
  UnifiedDiffDocument({
    required this.source,
    required Iterable<UnifiedDiffLine> lines,
    required Iterable<UnifiedDiffFile> files,
    required Iterable<UnifiedDiffLine> preamble,
    required this.truncated,
    required this.originalCodeUnits,
  }) : lines = List<UnifiedDiffLine>.unmodifiable(lines),
       files = List<UnifiedDiffFile>.unmodifiable(files),
       preamble = List<UnifiedDiffLine>.unmodifiable(preamble);

  final String source;
  final List<UnifiedDiffLine> lines;
  final List<UnifiedDiffFile> files;
  final List<UnifiedDiffLine> preamble;
  final bool truncated;
  final int originalCodeUnits;

  int get additions =>
      lines.where((line) => line.kind == UnifiedDiffLineKind.addition).length;
  int get deletions =>
      lines.where((line) => line.kind == UnifiedDiffLineKind.deletion).length;
}

final class UnifiedDiffFile {
  UnifiedDiffFile({
    required this.index,
    required this.oldPath,
    required this.newPath,
    required Iterable<UnifiedDiffLine> headers,
    required Iterable<UnifiedDiffHunk> hunks,
  }) : headers = List<UnifiedDiffLine>.unmodifiable(headers),
       hunks = List<UnifiedDiffHunk>.unmodifiable(hunks);

  final int index;
  final String? oldPath;
  final String? newPath;
  final List<UnifiedDiffLine> headers;
  final List<UnifiedDiffHunk> hunks;

  String get displayPath => newPath ?? oldPath ?? 'Unknown file';
}

final class UnifiedDiffHunk {
  UnifiedDiffHunk({
    required this.index,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.heading,
    required Iterable<UnifiedDiffLine> lines,
  }) : lines = List<UnifiedDiffLine>.unmodifiable(lines);

  final int index;
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final String heading;
  final List<UnifiedDiffLine> lines;
}

final class UnifiedDiffLine {
  const UnifiedDiffLine({
    required this.kind,
    required this.text,
    this.oldLineNumber,
    this.newLineNumber,
    this.fileIndex,
    this.hunkIndex,
    this.truncated = false,
  });

  final UnifiedDiffLineKind kind;
  final String text;
  final int? oldLineNumber;
  final int? newLineNumber;
  final int? fileIndex;
  final int? hunkIndex;
  final bool truncated;
}

class DiffView extends StatefulWidget {
  const DiffView({
    required this.patch,
    this.parser = const UnifiedDiffParser(),
    this.layoutMode = DiffLayoutMode.auto,
    this.height = 440,
    this.showToolbar = true,
    this.copyHandler,
    super.key,
  });

  final String patch;
  final UnifiedDiffParser parser;
  final DiffLayoutMode layoutMode;
  final double height;
  final bool showToolbar;
  final FutureOr<void> Function(String patch)? copyHandler;

  @override
  State<DiffView> createState() => _DiffViewState();
}

class _DiffViewState extends State<DiffView> {
  late UnifiedDiffDocument _document;
  DiffLayoutMode? _userMode;

  @override
  void initState() {
    super.initState();
    _document = widget.parser.parse(widget.patch);
  }

  @override
  void didUpdateWidget(covariant DiffView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patch != widget.patch || oldWidget.parser != widget.parser) {
      _document = widget.parser.parse(widget.patch);
    }
    if (oldWidget.layoutMode != widget.layoutMode) _userMode = null;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final automatic = constraints.maxWidth >= 880
          ? DiffLayoutMode.sideBySide
          : DiffLayoutMode.wrapped;
      final effectiveMode =
          _userMode ??
          (widget.layoutMode == DiffLayoutMode.auto
              ? automatic
              : widget.layoutMode);
      final rows = effectiveMode == DiffLayoutMode.sideBySide
          ? _sideBySideRows(_document.lines)
          : _document.lines.map(_DiffVisualRow.wrapped).toList(growable: false);

      return Semantics(
        container: true,
        label:
            'Unified diff, ${_document.files.length} files, '
            '${_document.additions} additions, ${_document.deletions} deletions'
            '${_document.truncated ? ', truncated' : ''}',
        explicitChildNodes: true,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showToolbar)
                _DiffToolbar(
                  document: _document,
                  mode: effectiveMode,
                  onModeChanged: (mode) => setState(() => _userMode = mode),
                  onCopy: _copy,
                ),
              SizedBox(
                height: widget.height,
                child: SelectionArea(
                  child: ListView.builder(
                    key: const Key('diffVirtualizedList'),
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemCount: rows.length,
                    itemBuilder: (context, index) => _DiffRowWidget(
                      key: ValueKey<String>('diff-row-$index'),
                      row: rows[index],
                      mode: effectiveMode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _copy() async {
    final handler = widget.copyHandler;
    if (handler != null) {
      await handler(_document.source);
    } else {
      await Clipboard.setData(ClipboardData(text: _document.source));
    }
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Diff copied')));
  }
}

class _DiffToolbar extends StatelessWidget {
  const _DiffToolbar({
    required this.document,
    required this.mode,
    required this.onModeChanged,
    required this.onCopy,
  });

  final UnifiedDiffDocument document;
  final DiffLayoutMode mode;
  final ValueChanged<DiffLayoutMode> onModeChanged;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainer,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${document.files.length} files · +${document.additions} '
            '−${document.deletions}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SegmentedButton<DiffLayoutMode>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<DiffLayoutMode>>[
              ButtonSegment<DiffLayoutMode>(
                value: DiffLayoutMode.wrapped,
                label: Text('Wrapped'),
                icon: Icon(Icons.wrap_text_rounded),
              ),
              ButtonSegment<DiffLayoutMode>(
                value: DiffLayoutMode.sideBySide,
                label: Text('Side by side'),
                icon: Icon(Icons.view_column_outlined),
              ),
            ],
            selected: <DiffLayoutMode>{mode},
            onSelectionChanged: (selection) => onModeChanged(selection.single),
          ),
          IconButton(
            key: const Key('diffCopyButton'),
            tooltip: 'Copy diff',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_all_outlined),
          ),
        ],
      ),
    ),
  );
}

class _DiffRowWidget extends StatelessWidget {
  const _DiffRowWidget({required this.row, required this.mode, super.key});

  final _DiffVisualRow row;
  final DiffLayoutMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == DiffLayoutMode.sideBySide && !row.isSpanning) {
      return Semantics(
        container: true,
        label: row.sideBySideSemanticLabel,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DiffCell(line: row.oldLine, oldSide: true)),
              SizedBox(
                width: 1,
                child: ColoredBox(color: Theme.of(context).dividerColor),
              ),
              Expanded(child: _DiffCell(line: row.newLine, oldSide: false)),
            ],
          ),
        ),
      );
    }
    final line = row.spanningLine ?? row.oldLine ?? row.newLine!;
    return Semantics(
      container: true,
      label: _lineSemanticLabel(line),
      child: ExcludeSemantics(
        child: _DiffCell(line: line, oldSide: line.newLineNumber == null),
      ),
    );
  }
}

class _DiffCell extends StatelessWidget {
  const _DiffCell({required this.line, required this.oldSide});

  final UnifiedDiffLine? line;
  final bool oldSide;

  @override
  Widget build(BuildContext context) {
    final current = line;
    if (current == null) {
      return const SizedBox(height: 30);
    }
    final colors = _lineColors(current.kind, Theme.of(context).colorScheme);
    final lineNumber = oldSide ? current.oldLineNumber : current.newLineNumber;
    final number = lineNumber?.toString() ?? '';
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                number,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.foreground.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                current.text,
                softWrap: true,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.foreground,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_DiffVisualRow> _sideBySideRows(List<UnifiedDiffLine> lines) {
  final rows = <_DiffVisualRow>[];
  var index = 0;
  while (index < lines.length) {
    final line = lines[index];
    if (line.kind == UnifiedDiffLineKind.deletion) {
      final deletions = <UnifiedDiffLine>[];
      final additions = <UnifiedDiffLine>[];
      while (index < lines.length &&
          lines[index].kind == UnifiedDiffLineKind.deletion) {
        deletions.add(lines[index]);
        index += 1;
      }
      while (index < lines.length &&
          lines[index].kind == UnifiedDiffLineKind.addition) {
        additions.add(lines[index]);
        index += 1;
      }
      final count = deletions.length > additions.length
          ? deletions.length
          : additions.length;
      for (var pair = 0; pair < count; pair += 1) {
        rows.add(
          _DiffVisualRow.paired(
            oldLine: pair < deletions.length ? deletions[pair] : null,
            newLine: pair < additions.length ? additions[pair] : null,
          ),
        );
      }
      continue;
    }
    if (line.kind == UnifiedDiffLineKind.addition) {
      rows.add(_DiffVisualRow.paired(newLine: line));
      index += 1;
      continue;
    }
    if (line.kind == UnifiedDiffLineKind.context) {
      rows.add(_DiffVisualRow.paired(oldLine: line, newLine: line));
      index += 1;
      continue;
    }
    rows.add(_DiffVisualRow.spanning(line));
    index += 1;
  }
  return rows;
}

final class _DiffVisualRow {
  const _DiffVisualRow._({this.oldLine, this.newLine, this.spanningLine});

  factory _DiffVisualRow.wrapped(UnifiedDiffLine line) =>
      _DiffVisualRow._(spanningLine: line);

  factory _DiffVisualRow.spanning(UnifiedDiffLine line) =>
      _DiffVisualRow._(spanningLine: line);

  factory _DiffVisualRow.paired({
    UnifiedDiffLine? oldLine,
    UnifiedDiffLine? newLine,
  }) => _DiffVisualRow._(oldLine: oldLine, newLine: newLine);

  final UnifiedDiffLine? oldLine;
  final UnifiedDiffLine? newLine;
  final UnifiedDiffLine? spanningLine;

  bool get isSpanning => spanningLine != null;

  String get sideBySideSemanticLabel {
    final oldDescription = oldLine == null
        ? 'Old side empty'
        : _lineSemanticLabel(oldLine!);
    final newDescription = newLine == null
        ? 'New side empty'
        : _lineSemanticLabel(newLine!);
    return '$oldDescription; $newDescription';
  }
}

UnifiedDiffLineKind _classifyLine(String raw, bool inHunk) {
  if (raw.startsWith('Binary files ') || raw == 'GIT binary patch') {
    return UnifiedDiffLineKind.binary;
  }
  if (raw.startsWith('\\ No newline at end of file')) {
    return UnifiedDiffLineKind.noNewline;
  }
  if (inHunk) {
    if (raw.startsWith('+')) return UnifiedDiffLineKind.addition;
    if (raw.startsWith('-')) return UnifiedDiffLineKind.deletion;
    if (raw.startsWith(' ')) return UnifiedDiffLineKind.context;
    if (raw.isEmpty) return UnifiedDiffLineKind.context;
  }
  if (raw.startsWith('index ') ||
      raw.startsWith('new file mode ') ||
      raw.startsWith('deleted file mode ') ||
      raw.startsWith('similarity index ') ||
      raw.startsWith('rename from ') ||
      raw.startsWith('rename to ') ||
      raw.startsWith('old mode ') ||
      raw.startsWith('new mode ')) {
    return UnifiedDiffLineKind.metadata;
  }
  return UnifiedDiffLineKind.unknown;
}

(String?, String?) _parseDiffGitPaths(String raw) {
  final match = RegExp(r'^diff --git a/(.+) b/(.+)$').firstMatch(raw);
  if (match == null) return (null, null);
  return (match.group(1), match.group(2));
}

String? _parseHeaderPath(String raw) {
  final withoutTimestamp = raw.split('\t').first.trim();
  if (withoutTimestamp == '/dev/null') return null;
  if (withoutTimestamp.startsWith('a/') || withoutTimestamp.startsWith('b/')) {
    return withoutTimestamp.substring(2);
  }
  return withoutTimestamp.isEmpty ? null : withoutTimestamp;
}

String _lineSemanticLabel(UnifiedDiffLine line) {
  final content = line.text.length > 512
      ? '${line.text.substring(0, 512)}…'
      : line.text;
  return switch (line.kind) {
    UnifiedDiffLineKind.fileHeader => 'File header: $content',
    UnifiedDiffLineKind.metadata => 'Diff metadata: $content',
    UnifiedDiffLineKind.hunkHeader => 'Hunk header: $content',
    UnifiedDiffLineKind.addition =>
      'Added line ${line.newLineNumber ?? ''}: $content',
    UnifiedDiffLineKind.deletion =>
      'Removed line ${line.oldLineNumber ?? ''}: $content',
    UnifiedDiffLineKind.context =>
      'Context line ${line.newLineNumber ?? line.oldLineNumber ?? ''}: $content',
    UnifiedDiffLineKind.noNewline => 'No newline marker',
    UnifiedDiffLineKind.binary => 'Binary diff: $content',
    UnifiedDiffLineKind.unknown => 'Diff text: $content',
  };
}

_LineColors _lineColors(UnifiedDiffLineKind kind, ColorScheme scheme) =>
    switch (kind) {
      UnifiedDiffLineKind.addition => _LineColors(
        background: Color.alphaBlend(
          Colors.green.withValues(alpha: 0.13),
          scheme.surface,
        ),
        foreground: scheme.onSurface,
      ),
      UnifiedDiffLineKind.deletion => _LineColors(
        background: Color.alphaBlend(
          Colors.red.withValues(alpha: 0.13),
          scheme.surface,
        ),
        foreground: scheme.onSurface,
      ),
      UnifiedDiffLineKind.hunkHeader => _LineColors(
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      UnifiedDiffLineKind.fileHeader => _LineColors(
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      UnifiedDiffLineKind.metadata ||
      UnifiedDiffLineKind.noNewline ||
      UnifiedDiffLineKind.binary => _LineColors(
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurfaceVariant,
      ),
      UnifiedDiffLineKind.context || UnifiedDiffLineKind.unknown => _LineColors(
        background: scheme.surface,
        foreground: scheme.onSurface,
      ),
    };

final class _MutableFile {
  _MutableFile({required this.index});

  final int index;
  String? oldPath;
  String? newPath;
  final List<UnifiedDiffLine> headers = <UnifiedDiffLine>[];
  final List<UnifiedDiffHunk> hunks = <UnifiedDiffHunk>[];

  UnifiedDiffFile build() => UnifiedDiffFile(
    index: index,
    oldPath: oldPath,
    newPath: newPath,
    headers: headers,
    hunks: hunks,
  );
}

final class _MutableHunk {
  _MutableHunk({
    required this.index,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.heading,
  });

  final int index;
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final String heading;
  final List<UnifiedDiffLine> lines = <UnifiedDiffLine>[];

  UnifiedDiffHunk build() => UnifiedDiffHunk(
    index: index,
    oldStart: oldStart,
    oldCount: oldCount,
    newStart: newStart,
    newCount: newCount,
    heading: heading,
    lines: lines,
  );
}

final class _LineColors {
  const _LineColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

final _hunkHeader = RegExp(
  r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(?: ?(.*))?$',
);
