import 'package:flutter/material.dart';

/// State Ownership: none
/// Capabilities:
/// - Parse a bounded subset of ANSI SGR styling without executing terminal
///   control, cursor, or OSC sequences.
/// - Render selectable, accessible ANSI output as safe Flutter text.
/// Public Widgets:
/// - [AnsiText] — pure presentation for bounded ANSI terminal output.
/// Public Models:
/// - [AnsiParser] — app-owned safe ANSI parser.
/// - [AnsiDocument] — immutable plain text and styled runs.
final class AnsiParser {
  const AnsiParser({
    this.maxInputCodeUnits = 1024 * 1024,
    this.maxSequenceCodeUnits = 4096,
    this.maxParameters = 32,
    this.maxRuns = 20000,
  });

  final int maxInputCodeUnits;
  final int maxSequenceCodeUnits;
  final int maxParameters;
  final int maxRuns;

  AnsiDocument parse(String input) {
    if (maxInputCodeUnits <= 0 ||
        maxSequenceCodeUnits <= 0 ||
        maxParameters <= 0 ||
        maxRuns <= 0) {
      throw StateError('ANSI parser limits must be positive.');
    }

    final truncated = input.length > maxInputCodeUnits;
    final source = truncated ? input.substring(0, maxInputCodeUnits) : input;
    final runs = <AnsiRun>[];
    final plain = StringBuffer();
    final pending = StringBuffer();
    var style = const AnsiStyle();
    var unsafeSequenceSeen = false;
    var runLimitReached = false;

    void flush() {
      if (pending.isEmpty || runLimitReached) return;
      if (runs.length >= maxRuns) {
        runLimitReached = true;
        return;
      }
      final text = pending.toString();
      pending.clear();
      if (runs.isNotEmpty && runs.last.style == style) {
        final previous = runs.removeLast();
        runs.add(AnsiRun(text: '${previous.text}$text', style: style));
      } else {
        runs.add(AnsiRun(text: text, style: style));
      }
    }

    void append(String text) {
      if (runLimitReached) return;
      pending.write(text);
      plain.write(text);
    }

    var index = 0;
    while (index < source.length && !runLimitReached) {
      final codeUnit = source.codeUnitAt(index);
      if (codeUnit == 0x1b) {
        unsafeSequenceSeen = true;
        flush();
        final consumed = _consumeEscape(source, index);
        if (consumed.sgrParameters != null) {
          style = _applySgr(style, consumed.sgrParameters!);
        }
        index = consumed.nextIndex;
        continue;
      }

      if (codeUnit == 0x0d) {
        append('\n');
        index +=
            index + 1 < source.length && source.codeUnitAt(index + 1) == 0x0a
            ? 2
            : 1;
        continue;
      }
      if (codeUnit == 0x0a || codeUnit == 0x09) {
        append(String.fromCharCode(codeUnit));
        index += 1;
        continue;
      }
      if (codeUnit < 0x20 ||
          codeUnit == 0x7f ||
          (codeUnit >= 0x80 && codeUnit <= 0x9f)) {
        unsafeSequenceSeen = true;
        index += 1;
        continue;
      }

      append(source[index]);
      index += 1;
    }
    flush();

    if (truncated || runLimitReached) {
      const marker = '…';
      plain.write(marker);
      if (runs.isEmpty) {
        runs.add(AnsiRun(text: marker, style: style));
      } else if (runs.length >= maxRuns || runs.last.style == style) {
        final previous = runs.removeLast();
        runs.add(
          AnsiRun(text: '${previous.text}$marker', style: previous.style),
        );
      } else {
        runs.add(AnsiRun(text: marker, style: style));
      }
    }

    return AnsiDocument(
      runs: runs,
      plainText: plain.toString(),
      truncated: truncated || runLimitReached,
      unsafeSequenceSeen: unsafeSequenceSeen,
    );
  }

  _ConsumedEscape _consumeEscape(String source, int start) {
    if (start + 1 >= source.length) {
      return _ConsumedEscape(nextIndex: start + 1);
    }
    final introducer = source.codeUnitAt(start + 1);
    if (introducer == 0x5b) {
      return _consumeCsi(source, start);
    }
    if (introducer == 0x5d) {
      return _consumeOsc(source, start);
    }

    // Single-character and two-character escape commands are discarded. They
    // never become text and are never interpreted by Flutter.
    return _ConsumedEscape(nextIndex: (start + 2).clamp(0, source.length));
  }

  _ConsumedEscape _consumeCsi(String source, int start) {
    final sequenceEnd = (start + maxSequenceCodeUnits).clamp(0, source.length);
    var index = start + 2;
    while (index < sequenceEnd) {
      final value = source.codeUnitAt(index);
      if (value >= 0x40 && value <= 0x7e) {
        if (value != 0x6d) {
          return _ConsumedEscape(nextIndex: index + 1);
        }
        final body = source.substring(start + 2, index);
        final parameters = _parseSgrParameters(body);
        return _ConsumedEscape(nextIndex: index + 1, sgrParameters: parameters);
      }
      index += 1;
    }

    // An unterminated or overlong CSI is discarded through the first plausible
    // final byte, or to the bounded source end. This prevents its parameters
    // from leaking into visible output as fake terminal content.
    while (index < source.length) {
      final value = source.codeUnitAt(index);
      index += 1;
      if (value >= 0x40 && value <= 0x7e) break;
    }
    return _ConsumedEscape(nextIndex: index);
  }

  _ConsumedEscape _consumeOsc(String source, int start) {
    var index = start + 2;
    final sequenceEnd = (start + maxSequenceCodeUnits).clamp(0, source.length);
    while (index < source.length) {
      final value = source.codeUnitAt(index);
      if (value == 0x07) {
        return _ConsumedEscape(nextIndex: index + 1);
      }
      if (value == 0x1b &&
          index + 1 < source.length &&
          source.codeUnitAt(index + 1) == 0x5c) {
        return _ConsumedEscape(nextIndex: index + 2);
      }
      index += 1;
      if (index >= sequenceEnd) {
        // Keep scanning only for the terminator, without retaining or rendering
        // any OSC payload. The complete input is already bounded to 1 MiB.
        while (index < source.length) {
          final tail = source.codeUnitAt(index);
          if (tail == 0x07) return _ConsumedEscape(nextIndex: index + 1);
          if (tail == 0x1b &&
              index + 1 < source.length &&
              source.codeUnitAt(index + 1) == 0x5c) {
            return _ConsumedEscape(nextIndex: index + 2);
          }
          index += 1;
        }
        break;
      }
    }
    return _ConsumedEscape(nextIndex: source.length);
  }

  List<int>? _parseSgrParameters(String body) {
    if (body.isEmpty) return const <int>[0];
    final raw = body.split(';');
    if (raw.length > maxParameters) return null;
    final result = <int>[];
    for (final value in raw) {
      if (value.isEmpty) {
        result.add(0);
        continue;
      }
      if (!RegExp(r'^\d{1,3}$').hasMatch(value)) return null;
      final parsed = int.tryParse(value);
      if (parsed == null || parsed > 255) return null;
      result.add(parsed);
    }
    return result;
  }
}

final class AnsiDocument {
  AnsiDocument({
    required Iterable<AnsiRun> runs,
    required this.plainText,
    required this.truncated,
    required this.unsafeSequenceSeen,
  }) : runs = List<AnsiRun>.unmodifiable(runs);

  final List<AnsiRun> runs;
  final String plainText;
  final bool truncated;
  final bool unsafeSequenceSeen;
}

final class AnsiRun {
  const AnsiRun({required this.text, required this.style});

  final String text;
  final AnsiStyle style;
}

final class AnsiStyle {
  const AnsiStyle({
    this.foreground,
    this.background,
    this.bold = false,
    this.dim = false,
    this.italic = false,
    this.underline = false,
    this.inverse = false,
  });

  final Color? foreground;
  final Color? background;
  final bool bold;
  final bool dim;
  final bool italic;
  final bool underline;
  final bool inverse;

  AnsiStyle copyWith({
    Color? foreground,
    bool clearForeground = false,
    Color? background,
    bool clearBackground = false,
    bool? bold,
    bool? dim,
    bool? italic,
    bool? underline,
    bool? inverse,
  }) => AnsiStyle(
    foreground: clearForeground ? null : foreground ?? this.foreground,
    background: clearBackground ? null : background ?? this.background,
    bold: bold ?? this.bold,
    dim: dim ?? this.dim,
    italic: italic ?? this.italic,
    underline: underline ?? this.underline,
    inverse: inverse ?? this.inverse,
  );

  @override
  bool operator ==(Object other) =>
      other is AnsiStyle &&
      foreground == other.foreground &&
      background == other.background &&
      bold == other.bold &&
      dim == other.dim &&
      italic == other.italic &&
      underline == other.underline &&
      inverse == other.inverse;

  @override
  int get hashCode => Object.hash(
    foreground,
    background,
    bold,
    dim,
    italic,
    underline,
    inverse,
  );
}

class AnsiText extends StatelessWidget {
  const AnsiText(
    this.data, {
    this.parser = const AnsiParser(),
    this.style,
    this.semanticLabel,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String data;
  final AnsiParser parser;
  final TextStyle? style;
  final String? semanticLabel;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final document = parser.parse(data);
    final theme = Theme.of(context);
    final baseStyle =
        style ??
        theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace') ??
        const TextStyle(fontFamily: 'monospace');
    final defaultForeground = baseStyle.color ?? theme.colorScheme.onSurface;
    final defaultBackground = theme.colorScheme.surface;

    return Semantics(
      container: true,
      label: semanticLabel ?? _boundedSemanticText(document.plainText),
      child: ExcludeSemantics(
        child: SelectableText.rich(
          TextSpan(
            style: baseStyle,
            children: <InlineSpan>[
              for (final run in document.runs)
                TextSpan(
                  text: run.text,
                  style: _textStyleFor(
                    run.style,
                    defaultForeground,
                    defaultBackground,
                  ),
                ),
            ],
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

_TextStyleColors _resolvedColors(
  AnsiStyle style,
  Color defaultForeground,
  Color defaultBackground,
) {
  final foreground = style.foreground ?? defaultForeground;
  final background = style.background;
  if (!style.inverse) {
    return _TextStyleColors(foreground: foreground, background: background);
  }
  return _TextStyleColors(
    foreground: background ?? defaultBackground,
    background: foreground,
  );
}

TextStyle _textStyleFor(
  AnsiStyle style,
  Color defaultForeground,
  Color defaultBackground,
) {
  final colors = _resolvedColors(style, defaultForeground, defaultBackground);
  return TextStyle(
    color: style.dim
        ? colors.foreground.withValues(alpha: 0.68)
        : colors.foreground,
    backgroundColor: colors.background,
    fontWeight: style.bold ? FontWeight.w700 : null,
    fontStyle: style.italic ? FontStyle.italic : null,
    decoration: style.underline ? TextDecoration.underline : null,
  );
}

String _boundedSemanticText(String value) {
  const maxSemanticCodeUnits = 4096;
  if (value.length <= maxSemanticCodeUnits) return value;
  return '${value.substring(0, maxSemanticCodeUnits)}…';
}

AnsiStyle _applySgr(AnsiStyle original, List<int> parameters) {
  var style = original;
  var index = 0;
  while (index < parameters.length) {
    final parameter = parameters[index];
    switch (parameter) {
      case 0:
        style = const AnsiStyle();
      case 1:
        style = style.copyWith(bold: true);
      case 2:
        style = style.copyWith(dim: true);
      case 3:
        style = style.copyWith(italic: true);
      case 4:
        style = style.copyWith(underline: true);
      case 7:
        style = style.copyWith(inverse: true);
      case 22:
        style = style.copyWith(bold: false, dim: false);
      case 23:
        style = style.copyWith(italic: false);
      case 24:
        style = style.copyWith(underline: false);
      case 27:
        style = style.copyWith(inverse: false);
      case >= 30 && <= 37:
        style = style.copyWith(foreground: _ansi16Color(parameter - 30));
      case 39:
        style = style.copyWith(clearForeground: true);
      case >= 40 && <= 47:
        style = style.copyWith(background: _ansi16Color(parameter - 40));
      case 49:
        style = style.copyWith(clearBackground: true);
      case >= 90 && <= 97:
        style = style.copyWith(foreground: _ansi16Color(parameter - 90 + 8));
      case >= 100 && <= 107:
        style = style.copyWith(background: _ansi16Color(parameter - 100 + 8));
      case 38 || 48:
        final colorResult = _extendedColor(parameters, index + 1);
        if (colorResult != null) {
          style = parameter == 38
              ? style.copyWith(foreground: colorResult.color)
              : style.copyWith(background: colorResult.color);
          index = colorResult.lastIndex;
        }
      default:
        // Unsupported SGR values are intentionally ignored.
        break;
    }
    index += 1;
  }
  return style;
}

_ExtendedColor? _extendedColor(List<int> parameters, int index) {
  if (index >= parameters.length) return null;
  if (parameters[index] == 5 && index + 1 < parameters.length) {
    return _ExtendedColor(
      color: _ansi256Color(parameters[index + 1]),
      lastIndex: index + 1,
    );
  }
  if (parameters[index] == 2 && index + 3 < parameters.length) {
    return _ExtendedColor(
      color: Color.fromARGB(
        255,
        parameters[index + 1],
        parameters[index + 2],
        parameters[index + 3],
      ),
      lastIndex: index + 3,
    );
  }
  return null;
}

Color _ansi16Color(int index) => _ansi16Palette[index.clamp(0, 15)];

Color _ansi256Color(int index) {
  final bounded = index.clamp(0, 255);
  if (bounded < 16) return _ansi16Palette[bounded];
  if (bounded < 232) {
    final cube = bounded - 16;
    final red = cube ~/ 36;
    final green = (cube % 36) ~/ 6;
    final blue = cube % 6;
    int channel(int value) => value == 0 ? 0 : 55 + value * 40;
    return Color.fromARGB(255, channel(red), channel(green), channel(blue));
  }
  final gray = 8 + (bounded - 232) * 10;
  return Color.fromARGB(255, gray, gray, gray);
}

const _ansi16Palette = <Color>[
  Color(0xff000000),
  Color(0xffaa0000),
  Color(0xff00aa00),
  Color(0xffaa5500),
  Color(0xff0000aa),
  Color(0xffaa00aa),
  Color(0xff00aaaa),
  Color(0xffaaaaaa),
  Color(0xff555555),
  Color(0xffff5555),
  Color(0xff55ff55),
  Color(0xffffff55),
  Color(0xff5555ff),
  Color(0xffff55ff),
  Color(0xff55ffff),
  Color(0xffffffff),
];

final class _ConsumedEscape {
  const _ConsumedEscape({required this.nextIndex, this.sgrParameters});

  final int nextIndex;
  final List<int>? sgrParameters;
}

final class _ExtendedColor {
  const _ExtendedColor({required this.color, required this.lastIndex});

  final Color color;
  final int lastIndex;
}

final class _TextStyleColors {
  const _TextStyleColors({required this.foreground, this.background});

  final Color foreground;
  final Color? background;
}
