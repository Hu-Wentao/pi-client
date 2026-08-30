/// Figma:
/// - Frame: none
/// - Page Title: none
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied for this reusable component
/// Figma Data:
/// - none
/// State Ownership: none
/// Capabilities:
/// - Present a responsive first-party Pi conversation timeline with session context, shared message bubbles, accessible edit-from-here and fork actions for eligible user entries, automatic tail following, and loading, empty, and retryable error states.
/// Public Views:
/// - [ConversationView] — session conversation timeline driven only by `PiSessionSummary`, `PiMessage`, and callbacks.
/// Widget Tree:
/// - [ConversationView] > [_ConversationHeader], [MaterialBanner] (error), [ListView], [PiMessageBubble] × N, [_MessageBranchActions] (eligible user messages), [_ConversationEmptyState] (empty)
/// Theme: material

part of 'conversation.dart';
