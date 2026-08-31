/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Present a virtualized, responsive first-party Pi semantic conversation timeline with entry-specific user, assistant, tool, shell, custom, compaction, branch, marker, and forward-compatible fallback cards.
/// - Render bounded Markdown, code, math, Mermaid, ANSI, JSON, unified diff, safe structured tool details, verified deferred images, and deferred text previews without network or file access from renderers.
/// - Group tool calls, progress, and results beneath their originating assistant in source order; preserve pagination anchors, follow live output, throttle live-region announcements, and expose a desktop activity minimap.
/// - Offer copy-raw/copy-plain actions and accessible edit-from-here/fork actions only for persisted tree-backed user entries.
/// Public Views:
/// - [ConversationView] — semantic conversation timeline driven by `PiConversationEntry`, project/session identity, optional Pi Node content access, and callbacks.
/// Widget Tree:
/// - [ConversationView] > [_ConversationHeader], [MaterialBanner] (error), [ListView] > [_ConversationEntryTile] × visible entries, [_ActivityMinimap] (wide desktop), [_MessageBranchActions] (eligible persisted user entries), [_ConversationEmptyState] (empty)
/// Theme: material

part of 'conversation.dart';

typedef ConversationEntryRenderObserver =
    void Function(String entryId, int revision);
