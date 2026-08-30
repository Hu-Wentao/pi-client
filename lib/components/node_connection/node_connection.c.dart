/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Present first-party Pi Node connection state with compact and detailed entries, protocol negotiation context, recovery actions, and accessible progress semantics.
/// Public Views:
/// - [NodeConnectionView] — detailed connection status and context-sensitive connect, retry, or disconnect actions; the module also exposes the compact NodeConnectionBadge widget.
/// Widget Tree:
/// - [NodeConnectionView] > [NodeConnectionBadge], [LinearProgressIndicator] (connecting/closing), [FilledButton] (connect/retry), [OutlinedButton] (disconnect)
/// Theme: material

part of 'node_connection.dart';
