/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Browse, filter, refresh, create, keyboard-select, rename, clear custom names, generate names, and explicitly confirm deletion of first-party Pi sessions while presenting loading, progress, empty, and retryable error states.
/// Public Views:
/// - [SessionBrowserView] — responsive session browser driven only by `PiSessionSummary` inputs and callbacks.
/// Widget Tree:
/// - [SessionBrowserView] > [TextField], [IconButton] (refresh), [ListView], [ListTile] × N, [PopupMenuButton] (session actions), [AlertDialog] (rename), [FilledButton] (inline delete confirmation), [FilledButton] (empty/create), [MaterialBanner] (error)
/// Theme: material

part of 'session_browser.dart';
