import 'package:flutter/foundation.dart';

/// Exact third-party packages used by Pi Client's safe rich-text renderers.
///
/// Flutter's build tool collects each package's complete `LICENSE` file into
/// the platform license bundle. This code-owned inventory keeps the package,
/// version, purpose, license identifier, and runtime boundary reviewable next
/// to the widgets that use them.
const rendererDependencyInventory = <RendererDependency>[
  RendererDependency(
    package: 'markdown',
    version: '7.3.1',
    license: 'BSD-3-Clause',
    source: 'https://pub.dev/packages/markdown/versions/7.3.1',
    purpose: 'CommonMark/GFM parsing into an app-owned sanitized AST',
    runtimeBoundary:
        'Pure Dart; no network, platform channel, HTML renderer, or JavaScript',
  ),
  RendererDependency(
    package: 'flutter_math_fork',
    version: '0.7.4',
    license: 'Apache-2.0',
    source: 'https://pub.dev/packages/flutter_math_fork/versions/0.7.4',
    purpose: 'Bounded KaTeX-compatible TeX parsing and native Flutter layout',
    runtimeBoundary:
        'Dart/Flutter rendering; no WebView, CDN, or user-source evaluation; the conditional CanvasKit probe passed the repository WASM build',
  ),
  RendererDependency(
    package: 're_highlight',
    version: '0.0.3',
    license: 'MIT',
    source: 'https://pub.dev/packages/re_highlight/versions/0.0.3',
    purpose: 'Bounded, explicitly registered source-code grammars',
    runtimeBoundary:
        'Pure Dart regex grammar engine; unknown and oversized input falls back to plain text',
  ),
];

/// Exact candidates trialed but intentionally not added to the application.
const rendererDependencyEvaluations = <RendererDependencyEvaluation>[
  RendererDependencyEvaluation(
    package: 'mermaid_flutter',
    version: '0.1.0',
    license: 'MIT',
    outcome: 'not selected',
    evidence:
        'Requires Dart ^3.12.0 while Pi Client is pinned to Dart 3.11.4; source fallback was rejected and Pi Client instead owns a bounded native AST/painter for the required diagram families.',
  ),
  RendererDependencyEvaluation(
    package: 'mermaid_core',
    version: '0.1.0',
    license: 'MIT with bundled Apache-2.0 dagre and OFL-1.1 KaTeX font notices',
    outcome: 'not selected',
    evidence:
        'Requires Dart ^3.12.0 and elk ^0.1.0; lowering three package SDK constraints would create a large vendored fork before compatibility evidence exists.',
  ),
  RendererDependencyEvaluation(
    package: 'highlight',
    version: '0.7.0',
    license: 'MIT',
    outcome: 'not selected',
    evidence:
        'Its SDK constraint is <3.0.0, so it cannot satisfy the Dart 3.11.4 application boundary.',
  ),
  RendererDependencyEvaluation(
    package: 'syntax_highlight',
    version: '0.5.0',
    license: 'BSD-3-Clause',
    outcome: 'not selected',
    evidence:
        'Adds super_clipboard and its platform surface for a read-only renderer; re_highlight provides explicitly registered pure-Dart grammars with a smaller capability boundary.',
  ),
];

/// One exact renderer dependency and its reviewed runtime boundary.
final class RendererDependency {
  const RendererDependency({
    required this.package,
    required this.version,
    required this.license,
    required this.source,
    required this.purpose,
    required this.runtimeBoundary,
  });

  final String package;
  final String version;
  final String license;
  final String source;
  final String purpose;
  final String runtimeBoundary;
}

/// One exact dependency trial that did not enter the runtime manifest.
final class RendererDependencyEvaluation {
  const RendererDependencyEvaluation({
    required this.package,
    required this.version,
    required this.license,
    required this.outcome,
    required this.evidence,
  });

  final String package;
  final String version;
  final String license;
  final String outcome;
  final String evidence;
}

bool _registered = false;

/// Adds a concise renderer inventory to Flutter's license page once.
///
/// Complete license terms remain supplied by Flutter's generated dependency
/// license bundle from each pinned package's `LICENSE` file.
void ensureRendererDependencyLicensesRegistered() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(
    () => Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
      for (final dependency in rendererDependencyInventory)
        LicenseEntryWithLineBreaks(
          <String>[dependency.package],
          '''
${dependency.package} ${dependency.version}
SPDX-License-Identifier: ${dependency.license}
Source: ${dependency.source}
Purpose: ${dependency.purpose}
Runtime boundary: ${dependency.runtimeBoundary}

The complete license text is included in Pi Client's generated Flutter dependency license bundle.
''',
        ),
    ]),
  );
}
