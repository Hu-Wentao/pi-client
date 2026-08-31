import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pi_client/widgets/code_block_view/code_block_view.dart';
import 'package:pi_client/widgets/renderer_dependencies/renderer_dependency_inventory.dart';

/// Capabilities:
/// - Parse and paint bounded app-owned Mermaid ASTs for common flowchart,
///   sequence, state, class, ER, pie, and Gantt diagrams.
/// - Render with native Flutter canvas operations only: no WebView, HTML, CDN,
///   JavaScript, external process, or network access.
/// State Ownership: none
/// Public Widgets:
/// - [MermaidView] — pure presentation for one sanitized Mermaid diagram.
class MermaidView extends StatelessWidget {
  const MermaidView({
    required this.source,
    this.streaming = false,
    this.showCopyButton = true,
    this.limits = const MermaidRenderLimits(),
    super.key,
  });

  final String source;

  /// Defers diagram parsing while a fence is still receiving tokens.
  final bool streaming;
  final bool showCopyButton;
  final MermaidRenderLimits limits;

  @override
  Widget build(BuildContext context) {
    ensureRendererDependencyLicensesRegistered();
    if (streaming) {
      return Semantics(
        container: true,
        label: 'Mermaid diagram preview pending until streaming completes',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Diagram preview updates when the message is complete.',
              key: const Key('mermaid-streaming-notice'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            CodeBlockView(
              key: const Key('mermaid-streaming-source'),
              code: source,
              language: 'mermaid',
              lightweight: true,
              maxCharacters: limits.maxSourceCharacters,
              showCopyButton: showCopyButton,
            ),
          ],
        ),
      );
    }

    final parseResult = _SafeMermaidDocument.parse(source, limits: limits);
    if (parseResult.error != null || parseResult.ast == null) {
      return _MermaidFailure(
        error: parseResult.error ?? 'The diagram could not be parsed.',
        source: parseResult.safeSource,
        showCopyButton: showCopyButton,
      );
    }

    final ast = parseResult.ast!;
    final scale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
      1.0,
      2.5,
    );
    final painter = _MermaidPainter(
      ast: ast,
      scheme: Theme.of(context).colorScheme,
      textScale: scale,
    );
    final kindName = ast.kind.semanticName;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      image: true,
      label: ast.semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
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
                      ast.title?.isNotEmpty == true ? ast.title! : kindName,
                      key: const Key('mermaid-diagram-title'),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  if (showCopyButton)
                    IconButton(
                      key: const Key('mermaid-copy-button'),
                      tooltip: 'Copy diagram source',
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: parseResult.safeSource),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: RepaintBoundary(
                key: Key('mermaid-boundary-${ast.kind.name}'),
                child: CustomPaint(
                  key: Key('mermaid-canvas-${ast.kind.name}'),
                  size: painter.preferredSize,
                  painter: painter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hard limits applied before and during Mermaid parsing and painting.
final class MermaidRenderLimits {
  const MermaidRenderLimits({
    this.maxSourceCharacters = 20000,
    this.maxLines = 400,
    this.maxNodes = 64,
    this.maxEdges = 160,
    this.maxLabelCharacters = 256,
    this.maxMembersPerNode = 32,
    this.maxCanvasDimension = 4096,
  });

  final int maxSourceCharacters;
  final int maxLines;
  final int maxNodes;
  final int maxEdges;
  final int maxLabelCharacters;
  final int maxMembersPerNode;
  final double maxCanvasDimension;
}

/// Result of converting Mermaid source into an app-owned sanitized AST.
final class _SafeMermaidDocument {
  const _SafeMermaidDocument._({
    required this.safeSource,
    this.ast,
    this.error,
  });

  factory _SafeMermaidDocument.parse(
    String source, {
    MermaidRenderLimits limits = const MermaidRenderLimits(),
  }) {
    final sanitized = _sanitizeSource(source);
    if (sanitized.length > limits.maxSourceCharacters) {
      return _SafeMermaidDocument._(
        safeSource: sanitized.substring(0, limits.maxSourceCharacters),
        error: 'The diagram exceeds the safe source limit.',
      );
    }
    final lines = sanitized.split('\n');
    if (lines.length > limits.maxLines) {
      return _SafeMermaidDocument._(
        safeSource: sanitized,
        error: 'The diagram has too many lines.',
      );
    }
    if (sanitized.contains('%%{')) {
      return _SafeMermaidDocument._(
        safeSource: sanitized,
        error: 'Mermaid initialization directives are not allowed.',
      );
    }
    if (RegExp(
      r'^\s*(?:click|href|linkStyle)\b',
      caseSensitive: false,
      multiLine: true,
    ).hasMatch(sanitized)) {
      return _SafeMermaidDocument._(
        safeSource: sanitized,
        error:
            'Interactive Mermaid links and style directives are not allowed.',
      );
    }

    try {
      final meaningful = lines
          .map((line) => line.trimRight())
          .where(
            (line) => line.trim().isNotEmpty && !line.trim().startsWith('%%'),
          )
          .toList(growable: false);
      if (meaningful.isEmpty) {
        throw const _MermaidParseException('The diagram is empty.');
      }
      final header = meaningful.first.trim();
      final body = meaningful.skip(1).toList(growable: false);
      final _MermaidAst ast;
      if (RegExp(
        r'^(?:flowchart|graph)\b',
        caseSensitive: false,
      ).hasMatch(header)) {
        ast = _parseFlowchart(header, body, limits);
      } else if (header.toLowerCase() == 'sequencediagram') {
        ast = _parseSequence(body, limits);
      } else if (RegExp(
        r'^statediagram(?:-v2)?$',
        caseSensitive: false,
      ).hasMatch(header)) {
        ast = _parseState(body, limits);
      } else if (header.toLowerCase() == 'classdiagram') {
        ast = _parseClass(body, limits);
      } else if (header.toLowerCase() == 'erdiagram') {
        ast = _parseEr(body, limits);
      } else if (header.toLowerCase() == 'pie') {
        ast = _parsePie(body, limits);
      } else if (header.toLowerCase() == 'gantt') {
        ast = _parseGantt(body, limits);
      } else {
        throw const _MermaidParseException(
          'Supported diagrams are flowchart, sequence, state, class, ER, pie, and Gantt.',
        );
      }
      return _SafeMermaidDocument._(safeSource: sanitized, ast: ast);
    } on _MermaidParseException catch (error) {
      return _SafeMermaidDocument._(
        safeSource: sanitized,
        error: error.message,
      );
    } on Object {
      return _SafeMermaidDocument._(
        safeSource: sanitized,
        error: 'The diagram could not be parsed safely.',
      );
    }
  }

  final String safeSource;
  final _MermaidAst? ast;
  final String? error;
}

enum _MermaidKind {
  flowchart('Flowchart'),
  sequence('Sequence diagram'),
  state('State diagram'),
  classDiagram('Class diagram'),
  er('Entity relationship diagram'),
  pie('Pie chart'),
  gantt('Gantt chart');

  const _MermaidKind(this.semanticName);

  final String semanticName;
}

sealed class _MermaidAst {
  const _MermaidAst({required this.kind, this.title});

  final _MermaidKind kind;
  final String? title;
  String get semanticLabel;
  MermaidRenderLimits get limits;
  Size measure(double textScale, MermaidRenderLimits limits);
  void paint(Canvas canvas, Size size, ColorScheme scheme, double textScale);
}

enum _DiagramDirection { topDown, leftRight, bottomUp, rightLeft }

enum _GraphNodeShape {
  rectangle,
  rounded,
  diamond,
  circle,
  state,
  classBox,
  entity,
}

final class _GraphNode {
  const _GraphNode({
    required this.id,
    required this.label,
    this.shape = _GraphNodeShape.rectangle,
    this.members = const <String>[],
  });

  final String id;
  final String label;
  final _GraphNodeShape shape;
  final List<String> members;
}

final class _GraphEdge {
  const _GraphEdge({
    required this.from,
    required this.to,
    this.label,
    this.operatorLabel,
    this.dashed = false,
  });

  final String from;
  final String to;
  final String? label;
  final String? operatorLabel;
  final bool dashed;
}

final class _GraphAst extends _MermaidAst {
  const _GraphAst({
    required super.kind,
    required this.direction,
    required this.nodes,
    required this.edges,
    required this.limits,
    super.title,
  });

  final _DiagramDirection direction;
  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  @override
  final MermaidRenderLimits limits;

  @override
  String get semanticLabel =>
      '${kind.semanticName}, ${nodes.length} nodes, ${edges.length} connections';

  @override
  Size measure(double textScale, MermaidRenderLimits limits) =>
      _GraphLayout(this, textScale).size;

  @override
  void paint(Canvas canvas, Size size, ColorScheme scheme, double textScale) {
    final layout = _GraphLayout(this, textScale);
    final linePaint = Paint()
      ..color = scheme.outline
      ..strokeWidth = 1.6 * textScale
      ..style = PaintingStyle.stroke;
    for (final edge in edges) {
      final from = layout.rects[edge.from];
      final to = layout.rects[edge.to];
      if (from == null || to == null) continue;
      final start = _edgePoint(from, to.center);
      final end = _edgePoint(to, from.center);
      if (edge.dashed) {
        _drawDashedLine(canvas, start, end, linePaint);
      } else {
        canvas.drawLine(start, end, linePaint);
      }
      _drawArrow(canvas, start, end, linePaint);
      final label = edge.label ?? edge.operatorLabel;
      if (label != null && label.isNotEmpty) {
        _paintText(
          canvas,
          label,
          Offset(
            (start.dx + end.dx) / 2,
            (start.dy + end.dy) / 2 - 16 * textScale,
          ),
          math.max(80, (end - start).distance),
          TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11 * textScale,
            backgroundColor: scheme.surfaceContainerLow,
          ),
          textAlign: TextAlign.center,
        );
      }
    }

    for (final node in nodes) {
      final rect = layout.rects[node.id]!;
      final fill = node.shape == _GraphNodeShape.circle
          ? scheme.tertiaryContainer
          : scheme.primaryContainer;
      final nodePaint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;
      final border = Paint()
        ..color = scheme.outline
        ..strokeWidth = 1.4 * textScale
        ..style = PaintingStyle.stroke;
      switch (node.shape) {
        case _GraphNodeShape.diamond:
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.center.dy)
            ..lineTo(rect.center.dx, rect.bottom)
            ..lineTo(rect.left, rect.center.dy)
            ..close();
          canvas
            ..drawPath(path, nodePaint)
            ..drawPath(path, border);
        case _GraphNodeShape.circle:
          canvas
            ..drawOval(rect, nodePaint)
            ..drawOval(rect, border);
        case _GraphNodeShape.rounded:
        case _GraphNodeShape.state:
          final rounded = RRect.fromRectAndRadius(
            rect,
            Radius.circular(18 * textScale),
          );
          canvas
            ..drawRRect(rounded, nodePaint)
            ..drawRRect(rounded, border);
        case _GraphNodeShape.rectangle:
        case _GraphNodeShape.classBox:
        case _GraphNodeShape.entity:
          final rounded = RRect.fromRectAndRadius(
            rect,
            Radius.circular(6 * textScale),
          );
          canvas
            ..drawRRect(rounded, nodePaint)
            ..drawRRect(rounded, border);
      }
      final titleHeight = node.members.isEmpty ? rect.height : 34 * textScale;
      _paintText(
        canvas,
        node.label,
        Offset(rect.left + 8 * textScale, rect.top + 9 * textScale),
        rect.width - 16 * textScale,
        TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 13 * textScale,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: node.members.isEmpty ? 2 : 1,
      );
      if (node.members.isNotEmpty) {
        canvas.drawLine(
          Offset(rect.left, rect.top + titleHeight),
          Offset(rect.right, rect.top + titleHeight),
          border,
        );
        for (var index = 0; index < node.members.length; index++) {
          _paintText(
            canvas,
            node.members[index],
            Offset(
              rect.left + 8 * textScale,
              rect.top + titleHeight + (index * 20 + 4) * textScale,
            ),
            rect.width - 16 * textScale,
            TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 10.5 * textScale,
              fontFamily: 'monospace',
            ),
          );
        }
      }
    }
  }
}

final class _GraphLayout {
  _GraphLayout(_GraphAst ast, this.scale) {
    final levels = _levels(ast);
    final levelGroups = <int, List<_GraphNode>>{};
    for (final node in ast.nodes) {
      levelGroups
          .putIfAbsent(levels[node.id] ?? 0, () => <_GraphNode>[])
          .add(node);
    }
    final sortedLevels = levelGroups.keys.toList()..sort();
    final reversed =
        ast.direction == _DiagramDirection.bottomUp ||
        ast.direction == _DiagramDirection.rightLeft;
    if (reversed) sortedLevels.setAll(0, sortedLevels.reversed);
    final horizontal =
        ast.direction == _DiagramDirection.leftRight ||
        ast.direction == _DiagramDirection.rightLeft;
    const marginBase = 24.0;
    final margin = marginBase * scale;
    final levelGap = 90 * scale;
    final siblingGap = 32 * scale;
    var maxCross = 0.0;
    var main = margin;
    for (final level in sortedLevels) {
      final group = levelGroups[level]!;
      var cross = margin;
      var maxMainForLevel = 0.0;
      for (final node in group) {
        final nodeSize = _nodeSize(node, scale);
        final rect = horizontal
            ? Rect.fromLTWH(main, cross, nodeSize.width, nodeSize.height)
            : Rect.fromLTWH(cross, main, nodeSize.width, nodeSize.height);
        rects[node.id] = rect;
        cross += (horizontal ? nodeSize.height : nodeSize.width) + siblingGap;
        maxMainForLevel = math.max(
          maxMainForLevel,
          horizontal ? nodeSize.width : nodeSize.height,
        );
      }
      maxCross = math.max(maxCross, cross);
      main += maxMainForLevel + levelGap;
    }
    final raw = horizontal
        ? Size(main + margin, maxCross + margin)
        : Size(maxCross + margin, main + margin);
    size = Size(
      raw.width.clamp(220, ast.limits.maxCanvasDimension),
      raw.height.clamp(140, ast.limits.maxCanvasDimension),
    );
  }

  final double scale;
  final Map<String, Rect> rects = <String, Rect>{};
  late final Size size;

  static Size _nodeSize(_GraphNode node, double scale) {
    final width = (node.label.length * 7.2 + 40).clamp(110, 220) * scale;
    final memberHeight = node.members.isEmpty
        ? 0
        : node.members.length * 20 + 10;
    final height = (node.members.isEmpty ? 58 : 38 + memberHeight) * scale;
    if (node.shape == _GraphNodeShape.circle) {
      final side = math.max(width, height).clamp(64 * scale, 120 * scale);
      return Size.square(side);
    }
    return Size(width, height);
  }

  static Map<String, int> _levels(_GraphAst ast) {
    final levels = <String, int>{for (final node in ast.nodes) node.id: 0};
    final indegree = <String, int>{for (final node in ast.nodes) node.id: 0};
    final outgoing = <String, List<String>>{};
    for (final edge in ast.edges) {
      if (!indegree.containsKey(edge.from) || !indegree.containsKey(edge.to)) {
        continue;
      }
      indegree[edge.to] = indegree[edge.to]! + 1;
      outgoing.putIfAbsent(edge.from, () => <String>[]).add(edge.to);
    }
    final queue = <String>[
      for (final entry in indegree.entries)
        if (entry.value == 0) entry.key,
    ];
    var cursor = 0;
    while (cursor < queue.length) {
      final current = queue[cursor++];
      for (final next in outgoing[current] ?? const <String>[]) {
        levels[next] = math.max(levels[next]!, levels[current]! + 1);
        indegree[next] = indegree[next]! - 1;
        if (indegree[next] == 0) queue.add(next);
      }
    }
    return levels;
  }
}

final class _SequenceParticipant {
  const _SequenceParticipant(this.id, this.label, {this.actor = false});

  final String id;
  final String label;
  final bool actor;
}

final class _SequenceEvent {
  const _SequenceEvent({
    required this.from,
    required this.to,
    required this.label,
    this.dashed = false,
  });

  final String from;
  final String to;
  final String label;
  final bool dashed;
}

final class _SequenceAst extends _MermaidAst {
  const _SequenceAst({
    required this.participants,
    required this.events,
    required this.limits,
    super.title,
  }) : super(kind: _MermaidKind.sequence);

  final List<_SequenceParticipant> participants;
  final List<_SequenceEvent> events;
  @override
  final MermaidRenderLimits limits;

  @override
  String get semanticLabel =>
      'Sequence diagram, ${participants.length} participants, ${events.length} messages';

  @override
  Size measure(double textScale, MermaidRenderLimits limits) => _boundedCanvas(
    Size(
      ((participants.length - 1) * 170 + 180) * textScale,
      (110 + events.length * 66) * textScale,
    ),
    limits,
  );

  @override
  void paint(Canvas canvas, Size size, ColorScheme scheme, double textScale) {
    final centers = <String, double>{};
    final headerPaint = Paint()
      ..color = scheme.primaryContainer
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = scheme.outline
      ..strokeWidth = 1.4 * textScale
      ..style = PaintingStyle.stroke;
    for (var index = 0; index < participants.length; index++) {
      final centerX = (90 + index * 170) * textScale;
      centers[participants[index].id] = centerX;
      final rect = Rect.fromCenter(
        center: Offset(centerX, 35 * textScale),
        width: 130 * textScale,
        height: 44 * textScale,
      );
      final rounded = RRect.fromRectAndRadius(
        rect,
        Radius.circular(8 * textScale),
      );
      canvas
        ..drawRRect(rounded, headerPaint)
        ..drawRRect(rounded, border)
        ..drawLine(
          Offset(centerX, rect.bottom),
          Offset(centerX, size.height - 18 * textScale),
          border..color = scheme.outlineVariant,
        );
      border.color = scheme.outline;
      _paintText(
        canvas,
        participants[index].label,
        Offset(rect.left + 6 * textScale, rect.top + 12 * textScale),
        rect.width - 12 * textScale,
        TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 12 * textScale,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
    }

    for (var index = 0; index < events.length; index++) {
      final event = events[index];
      final startX = centers[event.from];
      final endX = centers[event.to];
      if (startX == null || endX == null) continue;
      final y = (88 + index * 66) * textScale;
      final start = Offset(startX, y);
      final end = Offset(endX, y);
      border.color = scheme.outline;
      if (event.dashed) {
        _drawDashedLine(canvas, start, end, border);
      } else {
        canvas.drawLine(start, end, border);
      }
      _drawArrow(canvas, start, end, border);
      _paintText(
        canvas,
        event.label,
        Offset(math.min(startX, endX) + 8 * textScale, y - 24 * textScale),
        math.max(80 * textScale, (endX - startX).abs() - 16 * textScale),
        TextStyle(color: scheme.onSurface, fontSize: 11 * textScale),
        textAlign: TextAlign.center,
      );
    }
  }
}

final class _PieSlice {
  const _PieSlice(this.label, this.value);

  final String label;
  final double value;
}

final class _PieAst extends _MermaidAst {
  const _PieAst({required this.slices, required this.limits, super.title})
    : super(kind: _MermaidKind.pie);

  final List<_PieSlice> slices;
  @override
  final MermaidRenderLimits limits;

  @override
  String get semanticLabel => 'Pie chart, ${slices.length} slices';

  @override
  Size measure(double textScale, MermaidRenderLimits limits) => _boundedCanvas(
    Size(520 * textScale, math.max(260, 54 + slices.length * 30) * textScale),
    limits,
  );

  @override
  void paint(Canvas canvas, Size size, ColorScheme scheme, double textScale) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    final center = Offset(135 * textScale, size.height / 2);
    final radius = 105 * textScale;
    var start = -math.pi / 2;
    for (var index = 0; index < slices.length; index++) {
      final sweep = slices[index].value / total * math.pi * 2;
      final color = _chartColor(index, scheme);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = color,
      );
      start += sweep;
      final legendY = (28 + index * 30) * textScale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            280 * textScale,
            legendY,
            18 * textScale,
            18 * textScale,
          ),
          Radius.circular(4 * textScale),
        ),
        Paint()..color = color,
      );
      final percent = slices[index].value / total * 100;
      _paintText(
        canvas,
        '${slices[index].label}  ${percent.toStringAsFixed(1)}%',
        Offset(308 * textScale, legendY),
        190 * textScale,
        TextStyle(color: scheme.onSurface, fontSize: 12 * textScale),
      );
    }
  }
}

final class _GanttTask {
  const _GanttTask({
    required this.label,
    required this.section,
    required this.start,
    required this.end,
    required this.done,
  });

  final String label;
  final String section;
  final DateTime start;
  final DateTime end;
  final bool done;
}

final class _GanttAst extends _MermaidAst {
  const _GanttAst({required this.tasks, required this.limits, super.title})
    : super(kind: _MermaidKind.gantt);

  final List<_GanttTask> tasks;
  @override
  final MermaidRenderLimits limits;

  @override
  String get semanticLabel => 'Gantt chart, ${tasks.length} tasks';

  @override
  Size measure(double textScale, MermaidRenderLimits limits) => _boundedCanvas(
    Size(760 * textScale, (68 + tasks.length * 42) * textScale),
    limits,
  );

  @override
  void paint(Canvas canvas, Size size, ColorScheme scheme, double textScale) {
    final minDate = tasks
        .map((task) => task.start)
        .reduce((left, right) => left.isBefore(right) ? left : right);
    final maxDate = tasks
        .map((task) => task.end)
        .reduce((left, right) => left.isAfter(right) ? left : right);
    final totalDays = math.max(1, maxDate.difference(minDate).inDays + 1);
    final chartLeft = 230 * textScale;
    final chartWidth = size.width - chartLeft - 20 * textScale;
    final dayWidth = chartWidth / totalDays;
    final grid = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = textScale;
    for (var day = 0; day <= totalDays; day++) {
      final x = chartLeft + day * dayWidth;
      canvas.drawLine(
        Offset(x, 24 * textScale),
        Offset(x, size.height - 16 * textScale),
        grid,
      );
    }
    for (var index = 0; index < tasks.length; index++) {
      final task = tasks[index];
      final y = (52 + index * 42) * textScale;
      _paintText(
        canvas,
        task.section.isEmpty ? task.label : '${task.section} · ${task.label}',
        Offset(8 * textScale, y - 9 * textScale),
        210 * textScale,
        TextStyle(color: scheme.onSurface, fontSize: 11 * textScale),
      );
      final startDay = task.start.difference(minDate).inHours / 24;
      final durationDays = math.max(
        0.5,
        task.end.difference(task.start).inHours / 24,
      );
      final rect = Rect.fromLTWH(
        chartLeft + startDay * dayWidth,
        y - 12 * textScale,
        math.max(8 * textScale, durationDays * dayWidth),
        24 * textScale,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(5 * textScale)),
        Paint()..color = task.done ? scheme.tertiary : scheme.primary,
      );
    }
    _paintText(
      canvas,
      _dateLabel(minDate),
      Offset(chartLeft, 4 * textScale),
      100 * textScale,
      TextStyle(color: scheme.onSurfaceVariant, fontSize: 10 * textScale),
    );
    _paintText(
      canvas,
      _dateLabel(maxDate),
      Offset(size.width - 110 * textScale, 4 * textScale),
      100 * textScale,
      TextStyle(color: scheme.onSurfaceVariant, fontSize: 10 * textScale),
      textAlign: TextAlign.end,
    );
  }
}

final class _MermaidPainter extends CustomPainter {
  _MermaidPainter({
    required this.ast,
    required this.scheme,
    required this.textScale,
  }) : preferredSize = ast.measure(textScale, ast.limits);

  final _MermaidAst ast;
  final ColorScheme scheme;
  final double textScale;
  final Size preferredSize;

  @override
  void paint(Canvas canvas, Size size) =>
      ast.paint(canvas, size, scheme, textScale);

  @override
  bool shouldRepaint(covariant _MermaidPainter oldDelegate) =>
      oldDelegate.ast != ast ||
      oldDelegate.scheme != scheme ||
      oldDelegate.textScale != textScale;
}

_GraphAst _parseFlowchart(
  String header,
  List<String> lines,
  MermaidRenderLimits limits,
) {
  final directionToken = header
      .split(RegExp(r'\s+'))
      .skip(1)
      .firstOrNull
      ?.toUpperCase();
  final direction = _parseDirection(directionToken);
  final nodes = <String, _GraphNode>{};
  final edges = <_GraphEdge>[];
  String? title;
  for (final raw in lines) {
    for (final statement in raw.split(';')) {
      final line = statement.trim();
      if (line.isEmpty || line == 'end' || line.startsWith('subgraph ')) {
        continue;
      }
      if (line.startsWith('title ')) {
        title = _label(line.substring(6), limits);
        continue;
      }
      final edge = RegExp(
        r'^(.+?)\s*(-->|---|-.->|==>)\s*(?:\|([^|]*)\|\s*)?(.+)$',
      ).firstMatch(line);
      if (edge != null) {
        final from = _parseNodeToken(edge.group(1)!, limits);
        final to = _parseNodeToken(edge.group(4)!, limits);
        _putNode(nodes, from, limits);
        _putNode(nodes, to, limits);
        _addEdge(
          edges,
          _GraphEdge(
            from: from.id,
            to: to.id,
            label: _nullableLabel(edge.group(3), limits),
            dashed: edge.group(2) == '-.->',
          ),
          limits,
        );
        continue;
      }
      final node = _parseNodeToken(line, limits);
      _putNode(nodes, node, limits);
    }
  }
  if (nodes.isEmpty) {
    throw const _MermaidParseException('The flowchart has no nodes.');
  }
  return _GraphAst(
    kind: _MermaidKind.flowchart,
    direction: direction,
    nodes: List<_GraphNode>.unmodifiable(nodes.values),
    edges: List<_GraphEdge>.unmodifiable(edges),
    limits: limits,
    title: title,
  );
}

_SequenceAst _parseSequence(List<String> lines, MermaidRenderLimits limits) {
  final participants = <String, _SequenceParticipant>{};
  final events = <_SequenceEvent>[];
  String? title;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    final participant = RegExp(
      r'^(participant|actor)\s+([A-Za-z_][\w.-]*)(?:\s+as\s+(.+))?$',
      caseSensitive: false,
    ).firstMatch(line);
    if (participant != null) {
      _putParticipant(
        participants,
        _SequenceParticipant(
          participant.group(2)!,
          _label(participant.group(3) ?? participant.group(2)!, limits),
          actor: participant.group(1)!.toLowerCase() == 'actor',
        ),
        limits,
      );
      continue;
    }
    final message = RegExp(
      r'^([A-Za-z_][\w.-]*)\s*(-->>|->>|-->|->|--x|-x)\s*([A-Za-z_][\w.-]*)\s*:\s*(.+)$',
    ).firstMatch(line);
    if (message != null) {
      final from = message.group(1)!;
      final to = message.group(3)!;
      _putParticipant(participants, _SequenceParticipant(from, from), limits);
      _putParticipant(participants, _SequenceParticipant(to, to), limits);
      if (events.length >= limits.maxEdges) {
        throw const _MermaidParseException(
          'The sequence diagram has too many messages.',
        );
      }
      events.add(
        _SequenceEvent(
          from: from,
          to: to,
          label: _label(message.group(4)!, limits),
          dashed: message.group(2)!.startsWith('--'),
        ),
      );
      continue;
    }
    if (RegExp(
      r'^(?:activate|deactivate|autonumber|loop|alt|else|opt|par|and|rect|end)\b',
      caseSensitive: false,
    ).hasMatch(line)) {
      continue;
    }
  }
  if (participants.isEmpty) {
    throw const _MermaidParseException(
      'The sequence diagram has no participants.',
    );
  }
  return _SequenceAst(
    participants: List<_SequenceParticipant>.unmodifiable(participants.values),
    events: List<_SequenceEvent>.unmodifiable(events),
    limits: limits,
    title: title,
  );
}

_GraphAst _parseState(List<String> lines, MermaidRenderLimits limits) {
  final nodes = <String, _GraphNode>{};
  final edges = <_GraphEdge>[];
  var direction = _DiagramDirection.topDown;
  String? title;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty || line == '}' || line == 'end') continue;
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    final directionMatch = RegExp(
      r'^direction\s+(TB|TD|BT|LR|RL)$',
      caseSensitive: false,
    ).firstMatch(line);
    if (directionMatch != null) {
      direction = _parseDirection(directionMatch.group(1));
      continue;
    }
    final declaration = RegExp(
      r'^state\s+(?:"([^"]+)"\s+as\s+)?([A-Za-z_][\w.-]*)(?:\s*\{)?$',
      caseSensitive: false,
    ).firstMatch(line);
    if (declaration != null) {
      _putNode(
        nodes,
        _GraphNode(
          id: declaration.group(2)!,
          label: _label(declaration.group(1) ?? declaration.group(2)!, limits),
          shape: _GraphNodeShape.state,
        ),
        limits,
      );
      continue;
    }
    final transition = RegExp(
      r'^(\[\*\]|[A-Za-z_][\w.-]*)\s*-->\s*(\[\*\]|[A-Za-z_][\w.-]*)(?:\s*:\s*(.+))?$',
    ).firstMatch(line);
    if (transition != null) {
      final from = transition.group(1)!;
      final to = transition.group(2)!;
      _putNode(nodes, _stateNode(from, limits), limits);
      _putNode(nodes, _stateNode(to, limits), limits);
      _addEdge(
        edges,
        _GraphEdge(
          from: from,
          to: to,
          label: _nullableLabel(transition.group(3), limits),
        ),
        limits,
      );
    }
  }
  if (nodes.isEmpty) {
    throw const _MermaidParseException('The state diagram has no states.');
  }
  return _GraphAst(
    kind: _MermaidKind.state,
    direction: direction,
    nodes: List<_GraphNode>.unmodifiable(nodes.values),
    edges: List<_GraphEdge>.unmodifiable(edges),
    limits: limits,
    title: title,
  );
}

_GraphAst _parseClass(List<String> lines, MermaidRenderLimits limits) {
  final nodes = <String, _GraphNode>{};
  final edges = <_GraphEdge>[];
  var direction = _DiagramDirection.topDown;
  String? title;
  String? openClass;
  final members = <String, List<String>>{};
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (line == '}') {
      openClass = null;
      continue;
    }
    if (openClass != null) {
      _addMember(members, openClass, line, limits);
      continue;
    }
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    final directionMatch = RegExp(
      r'^direction\s+(TB|TD|BT|LR|RL)$',
      caseSensitive: false,
    ).firstMatch(line);
    if (directionMatch != null) {
      direction = _parseDirection(directionMatch.group(1));
      continue;
    }
    final declaration = RegExp(
      r'^class\s+([A-Za-z_][\w.-]*)(?:\s*\{)?$',
      caseSensitive: false,
    ).firstMatch(line);
    if (declaration != null) {
      final id = declaration.group(1)!;
      _putNode(
        nodes,
        _GraphNode(id: id, label: id, shape: _GraphNodeShape.classBox),
        limits,
      );
      if (line.endsWith('{')) openClass = id;
      continue;
    }
    final inlineMember = RegExp(
      r'^([A-Za-z_][\w.-]*)\s*:\s*(.+)$',
    ).firstMatch(line);
    if (inlineMember != null) {
      final id = inlineMember.group(1)!;
      _putNode(
        nodes,
        _GraphNode(id: id, label: id, shape: _GraphNodeShape.classBox),
        limits,
      );
      _addMember(members, id, inlineMember.group(2)!, limits);
      continue;
    }
    final relation = RegExp(
      r'^([A-Za-z_][\w.-]*)\s*(<\|--|--\|>|\*--|--\*|o--|--o|-->|<--|\.\.>|<\.\.)\s*([A-Za-z_][\w.-]*)(?:\s*:\s*(.+))?$',
    ).firstMatch(line);
    if (relation != null) {
      final from = relation.group(1)!;
      final to = relation.group(3)!;
      _putNode(
        nodes,
        _GraphNode(id: from, label: from, shape: _GraphNodeShape.classBox),
        limits,
      );
      _putNode(
        nodes,
        _GraphNode(id: to, label: to, shape: _GraphNodeShape.classBox),
        limits,
      );
      _addEdge(
        edges,
        _GraphEdge(
          from: from,
          to: to,
          label: _nullableLabel(relation.group(4), limits),
          operatorLabel: relation.group(2),
          dashed: relation.group(2)!.contains('..'),
        ),
        limits,
      );
    }
  }
  final rebuilt = <_GraphNode>[
    for (final node in nodes.values)
      _GraphNode(
        id: node.id,
        label: node.label,
        shape: node.shape,
        members: List<String>.unmodifiable(
          members[node.id] ?? const <String>[],
        ),
      ),
  ];
  if (rebuilt.isEmpty) {
    throw const _MermaidParseException('The class diagram has no classes.');
  }
  return _GraphAst(
    kind: _MermaidKind.classDiagram,
    direction: direction,
    nodes: rebuilt,
    edges: List<_GraphEdge>.unmodifiable(edges),
    limits: limits,
    title: title,
  );
}

_GraphAst _parseEr(List<String> lines, MermaidRenderLimits limits) {
  final nodes = <String, _GraphNode>{};
  final members = <String, List<String>>{};
  final edges = <_GraphEdge>[];
  String? openEntity;
  String? title;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (line == '}') {
      openEntity = null;
      continue;
    }
    if (openEntity != null) {
      _addMember(members, openEntity, line, limits);
      continue;
    }
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    final entity = RegExp(r'^([A-Za-z_][\w.-]*)\s*\{$').firstMatch(line);
    if (entity != null) {
      openEntity = entity.group(1)!;
      _putNode(
        nodes,
        _GraphNode(
          id: openEntity,
          label: openEntity,
          shape: _GraphNodeShape.entity,
        ),
        limits,
      );
      continue;
    }
    final relation = RegExp(
      r'^([A-Za-z_][\w.-]*)\s*([|}{o]{1,3}--[|}{o]{1,3})\s*([A-Za-z_][\w.-]*)\s*:\s*(.+)$',
    ).firstMatch(line);
    if (relation != null) {
      final from = relation.group(1)!;
      final to = relation.group(3)!;
      _putNode(
        nodes,
        _GraphNode(id: from, label: from, shape: _GraphNodeShape.entity),
        limits,
      );
      _putNode(
        nodes,
        _GraphNode(id: to, label: to, shape: _GraphNodeShape.entity),
        limits,
      );
      _addEdge(
        edges,
        _GraphEdge(
          from: from,
          to: to,
          label: _label(relation.group(4)!, limits),
          operatorLabel: relation.group(2),
        ),
        limits,
      );
    }
  }
  final rebuilt = <_GraphNode>[
    for (final node in nodes.values)
      _GraphNode(
        id: node.id,
        label: node.label,
        shape: node.shape,
        members: List<String>.unmodifiable(
          members[node.id] ?? const <String>[],
        ),
      ),
  ];
  if (rebuilt.isEmpty) {
    throw const _MermaidParseException('The ER diagram has no entities.');
  }
  return _GraphAst(
    kind: _MermaidKind.er,
    direction: _DiagramDirection.leftRight,
    nodes: rebuilt,
    edges: List<_GraphEdge>.unmodifiable(edges),
    limits: limits,
    title: title,
  );
}

_PieAst _parsePie(List<String> lines, MermaidRenderLimits limits) {
  final slices = <_PieSlice>[];
  String? title;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty || line.toLowerCase() == 'showdata') continue;
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    final slice = RegExp(
      r'^"([^"]+)"\s*:\s*([0-9]+(?:\.[0-9]+)?)$',
    ).firstMatch(line);
    if (slice == null) continue;
    if (slices.length >= limits.maxNodes) {
      throw const _MermaidParseException('The pie chart has too many slices.');
    }
    final value = double.parse(slice.group(2)!);
    if (value > 0 && value.isFinite) {
      slices.add(_PieSlice(_label(slice.group(1)!, limits), value));
    }
  }
  if (slices.isEmpty) {
    throw const _MermaidParseException('The pie chart has no positive slices.');
  }
  return _PieAst(
    slices: List<_PieSlice>.unmodifiable(slices),
    limits: limits,
    title: title,
  );
}

_GanttAst _parseGantt(List<String> lines, MermaidRenderLimits limits) {
  final tasks = <_GanttTask>[];
  var section = '';
  String? title;
  var cursor = DateTime.utc(2024, 1, 1);
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty ||
        RegExp(
          r'^(?:dateFormat|axisFormat|tickInterval|excludes|todayMarker)\b',
          caseSensitive: false,
        ).hasMatch(line)) {
      continue;
    }
    if (line.startsWith('title ')) {
      title = _label(line.substring(6), limits);
      continue;
    }
    if (line.startsWith('section ')) {
      section = _label(line.substring(8), limits);
      continue;
    }
    final colon = line.indexOf(':');
    if (colon <= 0) continue;
    if (tasks.length >= limits.maxEdges) {
      throw const _MermaidParseException('The Gantt chart has too many tasks.');
    }
    final label = _label(line.substring(0, colon), limits);
    final tokens = line
        .substring(colon + 1)
        .split(',')
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    final done = tokens.any((token) => token.toLowerCase() == 'done');
    DateTime? start;
    DateTime? end;
    Duration? duration;
    for (final token in tokens) {
      start ??= _tryDate(token);
      if (start != null && token != _dateLabel(start)) {
        final candidateEnd = _tryDate(token);
        if (candidateEnd != null && candidateEnd != start) end = candidateEnd;
      }
      duration ??= _tryDuration(token);
    }
    start ??= cursor;
    end ??= start.add(duration ?? const Duration(days: 1));
    if (!end.isAfter(start)) end = start.add(const Duration(days: 1));
    cursor = end;
    tasks.add(
      _GanttTask(
        label: label,
        section: section,
        start: start,
        end: end,
        done: done,
      ),
    );
  }
  if (tasks.isEmpty) {
    throw const _MermaidParseException('The Gantt chart has no tasks.');
  }
  return _GanttAst(
    tasks: List<_GanttTask>.unmodifiable(tasks),
    limits: limits,
    title: title,
  );
}

String _sanitizeSource(String source) => source
    .replaceAll(
      RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'),
      '\uFFFD',
    )
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]{0,1024}>'), '')
    .trim();

_DiagramDirection _parseDirection(String? token) =>
    switch (token?.toUpperCase()) {
      'LR' => _DiagramDirection.leftRight,
      'RL' => _DiagramDirection.rightLeft,
      'BT' => _DiagramDirection.bottomUp,
      _ => _DiagramDirection.topDown,
    };

_GraphNode _parseNodeToken(String token, MermaidRenderLimits limits) {
  final value = token.trim();
  if (value == '[*]') {
    return const _GraphNode(
      id: '[*]',
      label: '',
      shape: _GraphNodeShape.circle,
    );
  }
  final idMatch = RegExp(r'^([A-Za-z_][\w.-]*)(.*)$').firstMatch(value);
  if (idMatch == null) {
    throw const _MermaidParseException(
      'A diagram node has an invalid identifier.',
    );
  }
  final id = idMatch.group(1)!;
  final suffix = idMatch.group(2)!.trim();
  if (suffix.isEmpty) return _GraphNode(id: id, label: id);
  if (suffix.startsWith('((') && suffix.endsWith('))')) {
    return _GraphNode(
      id: id,
      label: _label(suffix.substring(2, suffix.length - 2), limits),
      shape: _GraphNodeShape.circle,
    );
  }
  if (suffix.startsWith('{') && suffix.endsWith('}')) {
    return _GraphNode(
      id: id,
      label: _label(suffix.substring(1, suffix.length - 1), limits),
      shape: _GraphNodeShape.diamond,
    );
  }
  if (suffix.startsWith('(') && suffix.endsWith(')')) {
    return _GraphNode(
      id: id,
      label: _label(suffix.substring(1, suffix.length - 1), limits),
      shape: _GraphNodeShape.rounded,
    );
  }
  if (suffix.startsWith('[') && suffix.endsWith(']')) {
    return _GraphNode(
      id: id,
      label: _label(suffix.substring(1, suffix.length - 1), limits),
    );
  }
  return _GraphNode(id: id, label: _label(suffix, limits));
}

_GraphNode _stateNode(String id, MermaidRenderLimits limits) => id == '[*]'
    ? const _GraphNode(id: '[*]', label: '', shape: _GraphNodeShape.circle)
    : _GraphNode(
        id: id,
        label: _label(id, limits),
        shape: _GraphNodeShape.state,
      );

void _putNode(
  Map<String, _GraphNode> nodes,
  _GraphNode node,
  MermaidRenderLimits limits,
) {
  if (!nodes.containsKey(node.id) && nodes.length >= limits.maxNodes) {
    throw const _MermaidParseException('The diagram has too many nodes.');
  }
  final current = nodes[node.id];
  if (current == null || current.label == current.id || current.label.isEmpty) {
    nodes[node.id] = node;
  }
}

void _addEdge(
  List<_GraphEdge> edges,
  _GraphEdge edge,
  MermaidRenderLimits limits,
) {
  if (edges.length >= limits.maxEdges) {
    throw const _MermaidParseException('The diagram has too many connections.');
  }
  edges.add(edge);
}

void _putParticipant(
  Map<String, _SequenceParticipant> participants,
  _SequenceParticipant participant,
  MermaidRenderLimits limits,
) {
  if (!participants.containsKey(participant.id) &&
      participants.length >= limits.maxNodes) {
    throw const _MermaidParseException(
      'The sequence diagram has too many participants.',
    );
  }
  participants.putIfAbsent(participant.id, () => participant);
}

void _addMember(
  Map<String, List<String>> members,
  String id,
  String member,
  MermaidRenderLimits limits,
) {
  final list = members.putIfAbsent(id, () => <String>[]);
  if (list.length >= limits.maxMembersPerNode) {
    throw const _MermaidParseException('A diagram node has too many members.');
  }
  list.add(_label(member, limits));
}

String _label(String value, MermaidRenderLimits limits) {
  final clean = value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]{0,1024}>'), '')
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r"^['`]|['`]$"), '')
      .replaceAll(RegExp(r'^"|"$'), '')
      .trim();
  if (clean.length <= limits.maxLabelCharacters) return clean;
  return '${clean.substring(0, limits.maxLabelCharacters - 1)}…';
}

String? _nullableLabel(String? value, MermaidRenderLimits limits) {
  if (value == null || value.trim().isEmpty) return null;
  return _label(value, limits);
}

Offset _edgePoint(Rect rect, Offset toward) {
  final delta = toward - rect.center;
  if (delta.dx.abs() > delta.dy.abs()) {
    return Offset(delta.dx >= 0 ? rect.right : rect.left, rect.center.dy);
  }
  return Offset(rect.center.dx, delta.dy >= 0 ? rect.bottom : rect.top);
}

void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
  final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
  const spread = math.pi / 7;
  final length = 10 * paint.strokeWidth;
  final first = Offset(
    end.dx - length * math.cos(angle - spread),
    end.dy - length * math.sin(angle - spread),
  );
  final second = Offset(
    end.dx - length * math.cos(angle + spread),
    end.dy - length * math.sin(angle + spread),
  );
  canvas
    ..drawLine(end, first, paint)
    ..drawLine(end, second, paint);
}

void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
  final distance = (end - start).distance;
  if (distance == 0) return;
  final direction = (end - start) / distance;
  var offset = 0.0;
  while (offset < distance) {
    final dashEnd = math.min(offset + 7 * paint.strokeWidth, distance);
    canvas.drawLine(
      start + direction * offset,
      start + direction * dashEnd,
      paint,
    );
    offset += 12 * paint.strokeWidth;
  }
}

void _paintText(
  Canvas canvas,
  String text,
  Offset offset,
  double maxWidth,
  TextStyle style, {
  TextAlign textAlign = TextAlign.start,
  int maxLines = 1,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
    maxLines: maxLines,
    ellipsis: '…',
  )..layout(maxWidth: math.max(1, maxWidth));
  painter.paint(canvas, offset);
}

Size _boundedCanvas(Size size, MermaidRenderLimits limits) => Size(
  size.width.clamp(120, limits.maxCanvasDimension),
  size.height.clamp(100, limits.maxCanvasDimension),
);

Color _chartColor(int index, ColorScheme scheme) {
  final colors = <Color>[
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.error,
    scheme.primaryContainer,
    scheme.secondaryContainer,
    scheme.tertiaryContainer,
    scheme.inversePrimary,
  ];
  return colors[index % colors.length];
}

DateTime? _tryDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  try {
    return DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  } on Object {
    return null;
  }
}

Duration? _tryDuration(String value) {
  final match = RegExp(
    r'^(\d+)([dhw])$',
    caseSensitive: false,
  ).firstMatch(value);
  if (match == null) return null;
  final count = int.parse(match.group(1)!);
  return switch (match.group(2)!.toLowerCase()) {
    'h' => Duration(hours: count),
    'w' => Duration(days: count * 7),
    _ => Duration(days: count),
  };
}

String _dateLabel(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

final class _MermaidFailure extends StatelessWidget {
  const _MermaidFailure({
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
      label: 'Mermaid rendering error: $error',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  key: const Key('mermaid-rendering-error'),
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              if (showCopyButton && source.isNotEmpty)
                IconButton(
                  key: const Key('mermaid-copy-button'),
                  tooltip: 'Copy diagram source',
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

final class _MermaidParseException implements Exception {
  const _MermaidParseException(this.message);

  final String message;
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
