/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Present a scalable flat session-tree navigator, active path and leaf state, in-session continuation, independent fork, clone availability, loading, and retryable errors without recursively building the tree.
/// Public Views:
/// - [BranchNavigatorView] — virtualized session-tree navigation driven by typed Pi Node models and callbacks.
/// Widget Tree:
/// - [BranchNavigatorView] > [_BranchNavigatorHeader], [MaterialBanner] (error), [ListView] > [ListTile] × N, [IconButton] (continue/edit, fork, clone)
/// Theme: material

part of 'branch_navigator.dart';
