/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Present Node-validated project identity, bounded directory browsing, session-derived known projects, manual-path validation, and explicit Project Trust approval without owning business state.
/// Public Views:
/// - [ProjectBrowserView] — project selector driven by typed Node snapshots and callbacks.
/// - [ProjectTrustDialogView] — explicit approval surface for project-local resources before a resource-bearing session opens; `ProjectTrustDialog` is its semantic dialog factory.
/// Widget Tree:
/// - [ProjectBrowserView] > [ListTile] (selected identity), [TextField] (manual path), [FilledButton] (validate), [ExpansionTile] (directory browser), [ListView] (bounded child directories), [ListTile] × N (known projects), [MaterialBanner] (error)
/// - [ProjectTrustDialogView] > [AlertDialog], [ListView] (trust reasons), [TextButton] (cancel), [FilledButton] (approve)
/// Theme: material

part of 'project_browser.dart';
