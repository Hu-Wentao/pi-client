---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>BENCH-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>BENCH-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    disposition: {source: label, labels: [Disposition, 处置]}
    raw: {source: body}
  queries:
    benchmark_by_id:
      when: {pattern: '^BENCH-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, disposition]
      expect: {max_record_lines: 55, max_record_bytes: 12288, structured: true, min_confidence: 1.0}
    benchmark_by_disposition:
      match: {source: field, field: disposition, operator: eq}
      select: [title, status]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# pi-web observed capability inventory

Reference snapshot: [`agegr/pi-web`](https://github.com/agegr/pi-web) `v0.8.11`, commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`, MIT.

This inventory is bounded to user-visible capabilities that are reachable in the fixed snapshot. It supports completeness review under `DEC-016`; it does not define Pi Client routes, DTOs, events, protocol, implementation, deployment, or acceptance semantics. `docs/requirements.md` is the semantic authority.

## BENCH-PI-001 - Snapshot and independence boundary

- Status: Frozen
- Disposition: Governance baseline
- Observed capability: The fixed product presents a local coding-agent workspace with project, session, Agent, file, Git, model, resource, and settings surfaces.
- Pi Client treatment: Every reachable domain is represented below and mapped to project-owned requirements; no moving pi-web branch can change the `1.0.0` scope automatically.
- Excluded evidence: Internal routes, schemas, event names, test-only behavior, hidden controls, implementation bugs, build scripts, branding, and deployment mechanics.
- Evidence owner: Fixed tag/commit identity, pi-web README, and bounded user-facing source inspection.

## BENCH-PI-002 - Projects, directories, and trust

- Status: Observed
- Disposition: Strict parity
- Observed capability: Select and validate a directory, use recent or default projects, restore project context, group linked worktrees, and require trust before project resources load.
- Pi Client treatment: Provide equivalent user outcomes through first-party Project and Pi Node contracts, including invalid, untrusted, trusted, moved, and unavailable states.
- Requirements: `REQ-PI-014` and `REQ-PI-033`.

## BENCH-PI-003 - Session catalog and lifecycle

- Status: Observed
- Disposition: Strict parity
- Observed capability: Browse sessions by project, restore a prior session, show running and unread activity, create lazily, rename, auto-name, delete, export, and inspect session statistics.
- Pi Client treatment: Preserve user-visible lifecycle and recovery outcomes without reading pi-web data or adopting its session representations.
- Requirements: `REQ-PI-015`.

## BENCH-PI-004 - History, branching, and independent sessions

- Status: Observed
- Disposition: Strict parity
- Observed capability: Load earlier history and deferred content, navigate in-session branches, edit from an earlier point, and create an independent session from a previous message.
- Pi Client treatment: Keep branch navigation and independent session creation as separate domain operations with stale-response protection and deep-tree handling.
- Requirements: `REQ-PI-016`.

## BENCH-PI-005 - Agent lifecycle and recovery

- Status: Observed
- Disposition: Strict parity
- Observed capability: Start and resume Agent work, stream output, abort, retry, compact, abort compaction, reload, steer, follow up, queue input, and reconcile activity after refresh or disconnect.
- Pi Client treatment: Express the same outcomes through accepted/rejected/uncertain commands and ordered first-party streams, not through pi-web command or event shapes.
- Requirements: `REQ-PI-013` and `REQ-PI-017`.

## BENCH-PI-006 - Composer, commands, and project shell

- Status: Observed
- Disposition: Strict parity
- Observed capability: Preserve drafts and input history; attach images; choose model, thinking, and tools; use slash commands, skills, prompt templates, extension commands, file mentions, and context-included or excluded shell commands.
- Pi Client treatment: Adapt input, attachment, shell, and keyboard behavior to Flutter and each platform while preserving observable intent and failure states.
- Requirements: `REQ-PI-018` and `REQ-PI-019`.

## BENCH-PI-007 - Conversation presentation

- Status: Observed
- Disposition: Strict parity
- Observed capability: Present user, assistant, thinking, tool, shell, custom, error, compaction, and usage content with Markdown, GFM, math, Mermaid, ANSI, code, images, diffs, written files, process details, and oversized-content protection.
- Pi Client treatment: Provide sanitized, bounded Flutter renderers and keep unknown or deferred content inspectable without converting it into a successful known state.
- Requirements: `REQ-PI-020`.

## BENCH-PI-008 - File workspace

- Status: Observed
- Disposition: Strict parity
- Observed capability: Browse and search an allowed project tree, upload and download files, watch changes, mention files or lines, keep multiple tabs, and view source, Markdown/HTML, image, audio, PDF, DOCX, and diff modes.
- Pi Client treatment: Pi Node owns allowed roots, canonical path checks, ranges, watching, uploads, downloads, and backpressure; Flutter owns tabs and previews.
- Requirements: `REQ-PI-021` and `REQ-PI-033`.

## BENCH-PI-009 - Git status, diffs, and worktrees

- Status: Observed
- Disposition: Strict parity
- Observed capability: Show branch and changed-file status, working-tree diffs, and line totals; list, switch, create, and remove worktrees with dirty-state force confirmation while preserving branches and session history.
- Pi Client treatment: Keep Git inspection bounded to observed outcomes and govern destructive worktree removal as a separate confirmed operation.
- Requirements: `REQ-PI-022`, `REQ-PI-023`, and `REQ-PI-033`.

## BENCH-PI-010 - Models, providers, and settings

- Status: Observed
- Disposition: Strict parity
- Observed capability: Select and scope models and thinking; configure, discover, enrich, and test models; authenticate providers with supported OAuth, device, manual, or API-key flows; edit global and project runtime settings.
- Pi Client treatment: Pi Node owns credentials and runtime configuration; Flutter receives redacted status and explicit scope, validation, reload, and rollback outcomes.
- Requirements: `REQ-PI-024`, `REQ-PI-025`, `REQ-PI-026`, and `REQ-PI-033`.

## BENCH-PI-011 - Skills and Pi packages

- Status: Observed
- Disposition: Strict parity
- Observed capability: List skill and package sources, control skill dormancy, search and install skills, check and apply skill updates, and install, update, enable, disable, remove, inventory, and reload packages.
- Pi Client treatment: Use reviewed Pi resource and package APIs, show source/scope/privilege, and trust-gate project actions instead of reproducing pi-web package code.
- Requirements: `REQ-PI-027`, `REQ-PI-028`, and `REQ-PI-033`.

## BENCH-PI-012 - Extension interaction host

- Status: Observed
- Disposition: Strict parity
- Observed capability: Render blocking select, confirm, input, editor, and custom terminal interactions plus notifications, status items, widgets, titles, and editor-text changes.
- Pi Client treatment: Map standard interactions to native Flutter controls and arbitrary custom terminal UI to a bounded headless bridge with request identity and lifecycle handling.
- Requirements: `REQ-PI-029`.

## BENCH-PI-013 - Existing subagent sessions and unreachable creation

- Status: Observed
- Disposition: Partial strict parity
- Observed capability: Existing child or subagent sessions are grouped with their parent, expose status and profile context, and can be opened from the session family.
- Unreachable capability: Built-in subagent creation is not a reachable `v0.8.11` product capability. The runtime enable predicate always returns false, the ordinary Settings panel omits the Agents section, and the built-in profile editor/toggle component is not mounted from a user-visible path.
- Parity consequence: Strict parity requires existing child-session discovery, status, and opening only. Built-in subagent creation, profile editing, and its hidden toggle are excluded from the `1.0.0` completeness gate; third-party plugin behavior is not inherited automatically.
- Requirements: `REQ-PI-030`.

## BENCH-PI-014 - Language, theme, layout, and navigation

- Status: Observed
- Disposition: Native adaptation
- Observed capability: English, Simplified Chinese, and Traditional Chinese; light, dark, and system themes; responsive desktop/mobile navigation; resizable panels; tab and workspace restoration; keyboard and clipboard actions.
- Pi Client treatment: Preserve outcomes with native Flutter layout, focus, accessibility, safe-area, and platform conventions rather than matching browser DOM, CSS, or storage mechanics.
- Requirements: `REQ-PI-031` and `REQ-PI-032`.

## BENCH-PI-015 - Notifications, updates, and access posture

- Status: Observed
- Disposition: Native adaptation
- Observed capability: Completion sound, foreground/background notifications, attention-needed notices, notification navigation, application update notices, local-by-default access, optional authentication, and explicit remote-access warnings.
- Pi Client treatment: Use native notification, update, pairing, secure transport, and release mechanisms. Browser PWA installation, loopback server binding, and Basic Auth are not exact parity mechanisms.
- Requirements: `REQ-PI-006`, `REQ-PI-007`, `REQ-PI-008`, `REQ-PI-009`, `REQ-PI-032`, `REQ-PI-033`, and `REQ-PI-034`.
