---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>REQ-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>REQ-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    priority: {source: label, labels: [Priority, 优先级]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    raw: {source: body}
  queries:
    requirement_by_id:
      when: {pattern: '^REQ-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, priority, review_level]
      expect: {max_record_lines: 45, max_record_bytes: 10240, structured: true, min_confidence: 1.0}
    requirements_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, priority, review_level]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client requirements

Default review level: L6. User-directed product scope and safety boundaries are L9. These project-owned requirements are the sole semantic authority for implementation, completeness, and acceptance; initial exploration records have no ongoing product authority.

## REQ-PI-001 - Connect to the local pi-web gateway

- Status: Deprecated
- Priority: Must
- Review level: L9
- Actor and goal: A `v0.0.2` user can configure the historical pi-web compatibility gateway and see whether it connected.
- Release scope: Satisfied and evidenced only for the immutable `v0.0.2` Preview; it is not a post-`v0.0.2` product target.
- Constraints: The password remains ephemeral and must not enter URLs, persisted state, screenshots, or logs.
- Replacement: `REQ-PI-006`, `REQ-PI-009`, and `REQ-PI-013` replace this gateway outcome with first-party Pi Node connectivity.
- Acceptance: Historical evidence remains in `VER-PI-001` through `VER-PI-003`; no new feature may depend on this requirement.

## REQ-PI-002 - Find and continue pi sessions through pi-web

- Status: Deprecated
- Priority: Must
- Review level: L9
- Actor and goal: A `v0.0.2` user can browse and continue sessions exposed by the historical compatibility gateway.
- Release scope: Satisfied and evidenced only for the immutable `v0.0.2` Preview.
- Constraints: This record does not authorize direct JSONL access or make pi-web session semantics authoritative.
- Replacement: `REQ-PI-015` and `REQ-PI-016` own the independent session and history outcomes.
- Acceptance: Historical loading, selection, message, stale-load, and stream evidence remains in `VER-PI-002` through `VER-PI-004`.

## REQ-PI-003 - Run and stop the agent through pi-web

- Status: Deprecated
- Priority: Must
- Review level: L9
- Actor and goal: A `v0.0.2` user can create, prompt, observe, and stop an Agent through the historical compatibility gateway.
- Release scope: Satisfied and evidenced only for the immutable `v0.0.2` Preview.
- Constraints: This record does not authorize pi-web HTTP, SSE, command, or event semantics in the first-party protocol.
- Replacement: `REQ-PI-013`, `REQ-PI-017`, `REQ-PI-018`, and `REQ-PI-019` own independent runtime interaction.
- Acceptance: Historical prompt, stream, refresh, reconnect, and abort evidence remains in `VER-PI-001` through `VER-PI-003`.

## REQ-PI-004 - Provide reproducible macOS delivery

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A contributor can build, test, package, and run the current macOS application with the project-pinned toolchain and first-party Pi Node.
- Constraints: Flutter is fixed with FVM; minimum macOS is 11.0; a release package must bind its verified runtime Capsule, source identity, architecture, signing state, and trust limitations.
- Source: `DEC-008`, `DEC-014`, and `PLAN-PI-004`.
- Acceptance: Locked dependencies, generated sources, tests, app build, Capsule installation and verification, bundled-app end-to-end execution, artifact inspection, and accurate build/run guidance remain reproducible.

## REQ-PI-005 - Preserve the historical exploration record

- Status: Superseded
- Priority: Must
- Review level: L9
- Actor and goal: Reviewers could trace the initial exploratory comparison, its license, exclusions, and independent implementation boundary.
- Constraints: This comparison is historical evidence only and has no ongoing role in requirements, completeness, architecture, protocol, implementation, compatibility, runtime, build, deployment, or release.
- Source: `DEC-003`, `DEC-012`, and `DEC-019`.
- Superseded by: `DEC-020`; project-owned Must requirements and their acceptance evidence define `1.0.0` completeness.

## REQ-PI-006 - Keep Local Direct independent

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can connect a native Pi Client to their local or LAN Pi Node without a Friday identity, subscription, or available central service.
- Constraints: Local Direct uses node-local pairing and authorization; Friday entitlement must not disable or change an existing Local Direct capability.
- Source: `PLAN-PI-002`, `PLAN-PI-004`, and `DEC-013`.
- Acceptance: The full supported Direct workflow remains available while Friday Relay is unreachable and no Friday account exists.

## REQ-PI-007 - Provide one personal Friday Workspace

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: An authenticated Friday user can access at most one personal Pi Workspace at its platform-managed origin.
- Constraints: Friday Relay owns identity, entitlement, Workspace, hostname, and Node binding; Pi Client consumes safe projections only.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: Anonymous, provisioning, subscription-required, active, suspended, and node-offline outcomes are visible; another user, origin, Workspace, or Node is denied.

## REQ-PI-008 - Use platform-safe Friday authentication

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: Native and Web Pi Clients can authenticate with Friday Relay without embedding a client secret or implementing Friday account security.
- Constraints: Native uses a system browser and public-client PKCE with OS secure storage; Web uses canonical Friday authentication and a host-only session without browser-readable long-lived tokens.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: Approved callbacks and handoffs succeed; unapproved origins, callbacks, handoffs, and browser token persistence fail closed.

## REQ-PI-009 - Use one private Pi transport contract

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user receives equivalent Pi behavior through Local Direct and Friday Workspace transports.
- Constraints: Product features depend on one versioned first-party contract; Friday Relay must not persist, log, or decrypt Pi payloads; cryptography uses an evaluated standard.
- Source: `PLAN-PI-002`, `PLAN-PI-004`, and `DEC-013`.
- Acceptance: Direct and remote transports pass the same behavior fixtures; remote evidence also proves grant binding, payload opacity, tamper rejection, and bounded revocation.

## REQ-PI-010 - Build one client for all supported platforms

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A contributor can build the same Pi Client product for Android, iOS, macOS, Windows, Linux, and Web.
- Constraints: One Flutter source tree and version own shared behavior; platform identity, signing, packaging, and secure capabilities remain native configuration.
- Source: `DEC-014` and `PLAN-PI-004`.
- Acceptance: Shared analysis and tests pass, each platform builds on an appropriate host, and release-readiness evidence identifies platform-specific gaps without claiming unsupported execution roles.

## REQ-PI-011 - Separate desktop Agent hosts from connect-only clients

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can host an Agent on macOS, Windows, or Linux and connect from any supported Pi Client platform.
- Constraints: Android, iOS, and Web never embed Pi SDK or obtain local Agent, tool, project-trust, shell, or host-filesystem authority.
- Source: `DEC-014` and `PLAN-PI-004`.
- Acceptance: Desktop host lifecycle and isolation pass platform tests; mobile and Web artifacts reject hosting and contain no host runtime.

## REQ-PI-012 - Provide a public product and download entry

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A prospective user can understand Pi Client, inspect current limits, and obtain the exact current supported release.
- Constraints: The site describes delivered behavior only; release trust, signing, platform, and migration limits are disclosed before download.
- Source: `PLAN-PI-004`.
- Acceptance: Maintained English and Simplified Chinese routes expose valid release links, metadata, responsive keyboard access, browser evidence, and current security notices.

## REQ-PI-013 - Run Pi through a first-party Pi Node

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A desktop user can start or connect to a project-owned Pi Node that runs the reviewed Pi SDK boundary.
- Constraints: Pi Node owns SDK lifecycle, sessions, tools, resources, credentials, and host operations behind typed Pi Client contracts; Pi SDK internals do not become public DTOs.
- Source: `DEC-014` and `PLAN-PI-004`.
- Acceptance: Pi Client negotiates a compatible Node, starts a session, completes a prompt, receives ordered output, cancels work, survives Node restart, and reports incompatible versions.

## REQ-PI-014 - Select and trust projects

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can select, validate, revisit, and trust an allowed project directory before project resources or privileged operations load.
- Constraints: Project identity handles repositories and linked worktrees; trust and allowed-root checks precede project-scoped resources, files, shell, packages, and destructive actions.
- Source: `PLAN-PI-004`.
- Acceptance: Directory picker, recent/default project, invalid path, untrusted, trusted, moved, and unavailable states are observable; untrusted resources remain unloaded.

## REQ-PI-015 - Browse and manage sessions

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can browse, restore, create, name, rename, auto-name, delete, and export sessions grouped by project.
- Constraints: Running, unread, parent/child, worktree, context, cost, and compaction summaries remain attributable to the correct session; destructive actions require explicit targets.
- Source: `PLAN-PI-004`.
- Acceptance: Loading, empty, error, refresh, restored, running, unread, renamed, exported, deleted, and recovery outcomes are observable, including deep and orphaned session relationships.

## REQ-PI-016 - Navigate session history and branches

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can load earlier history, edit from an earlier point, navigate in-session branches, and create an independent session from a prior message.
- Constraints: In-session navigation and independent session creation remain distinct; stale branch or history responses cannot replace the active selection.
- Source: `PLAN-PI-004`.
- Acceptance: Pagination, deferred content, branch selection, edit-from-here, independent fork, deep-tree navigation, cancellation, and failure recovery are observable without corrupting either session.

## REQ-PI-017 - Run resilient Agent turns

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can prompt, stream, stop, retry, compact, reload, steer, follow up, and reconcile an Agent run.
- Constraints: Commands expose accepted, rejected, or uncertain admission; events are ordered, deduplicated, cancellable, resumable, and isolated from stale sessions or runs.
- Source: `PLAN-PI-004`.
- Acceptance: Active, reconnecting, retrying, compacting, stopped, completed, failed, uncertain, and recovered states are observable across disconnect, refresh, duplicate, late, and replaced-run scenarios.

## REQ-PI-018 - Compose prompts and queued interactions

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can prepare and submit text, images, commands, files, model choices, thinking levels, tool presets, and queued interactions.
- Constraints: Drafts, input history, input method editor composition, attachment limits, slash sources, dormant skills, and file mentions preserve user intent across page and session transitions.
- Source: `PLAN-PI-004`.
- Acceptance: Draft restore, history recall, image validation/compression, slash palette, prompt template, skill, extension command, `@` file/line mention, steer, follow-up, queue recall, and disabled-state outcomes are observable.

## REQ-PI-019 - Run secure project-scoped remote shells

- Status: Planned
- Priority: Must
- Target: 1.1
- Review level: L9
- Actor and goal: An authorized user can run, observe, control, stop, reconnect to, and retrieve bounded project command or PTY output from a local or remote Pi Node.
- Constraints: Shell execution is project-trust-gated, allowed-root-scoped, bound to one authorized Node and writer, protected by transport authorization and E2EE when remote, and never exposed as an arbitrary transport proxy. Android, iOS, and Web remain remote clients and never host local command or PTY execution.
- Source: `DEC-014`, `DEC-022`, and `PLAN-PI-008`.
- Acceptance: Accepted/rejected/uncertain admission, non-interactive command and interactive PTY modes, structured cwd and environment policy, streaming stdout/stderr or terminal frames, input, resize, backpressure, reconnect cursor, truncation, authorized full-output retrieval, timeout, cancellation, process-tree termination, nonzero exit, Windows Shell profile, custom Extension terminal interaction, replay rejection, and unsupported-host states are observable.
- Release boundary: This requirement is not release-scoped for `1.0.0`; Pi Client `1.0` contains no built-in command execution, PTY, remote Shell, mobile/Web Shell, or custom Extension terminal bridge.

## REQ-PI-020 - Read rich conversation output

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can understand user, assistant, thinking, tool, shell, custom, error, compaction, and usage output while it streams and after reload.
- Constraints: Rich content is sanitized and bounded; unknown content remains inspectable without being misreported as success; deferred and oversized content cannot freeze the UI.
- Source: `PLAN-PI-004`.
- Acceptance: Markdown, GFM, math, Mermaid, ANSI, highlighted code, images, tool details, diffs, written files, process details, usage/cost/context, copy, deferred content, and oversized fallbacks are observable.

## REQ-PI-021 - Browse and preview project files

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can browse, search, upload, download, watch, mention, and preview files within authorized project roots.
- Constraints: Canonical paths, real paths, allowed roots, symbolic links, binary limits, ranges, cancellation, and backpressure are enforced by Pi Node.
- Source: `PLAN-PI-004`.
- Acceptance: Tree, search, upload conflict, live refresh, multi-tab state, source, Markdown/HTML, image, audio, PDF, DOCX, download, wrap, mode, line mention, and unsupported-preview outcomes are observable.

## REQ-PI-022 - Inspect Git changes

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can inspect repository branch identity, status, changed files, totals, and working-tree diffs.
- Constraints: The accepted product scope does not include stage, commit, push, pull, or arbitrary Git command execution.
- Source: `PLAN-PI-004`.
- Acceptance: Clean, modified, added, deleted, renamed, conflicted, untracked, binary, unavailable, and refresh states are observable with correct working-tree-to-HEAD diffs.

## REQ-PI-023 - Manage Git worktrees safely

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A desktop user can list, switch, create, and remove Git worktrees while preserving project and session identity.
- Constraints: Dirty removal requires evidence and a separate force confirmation; removing a worktree does not delete its branch or session history.
- Source: `PLAN-PI-004`.
- Acceptance: Root-only visibility, branch reuse/create, switch, dirty refusal, confirmed force removal, prunable records, removed-worktree session grouping, and platform path differences are observable.

## REQ-PI-024 - Configure models and thinking

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can list, scope, select, configure, discover, enrich, and test models and thinking levels.
- Constraints: Model scope follows reviewed Pi SDK semantics; ambiguous or empty scope is visible; changes reload runtime state without exposing provider secrets.
- Source: `PLAN-PI-004`.
- Acceptance: Default, automatic, explicit, unavailable, scoped, pinned-thinking, custom-provider, discovery, metadata-fill, undo, test-success, test-failure, and reload outcomes are observable.

## REQ-PI-025 - Authenticate model providers securely

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can add, replace, and remove provider authentication through supported OAuth, device-code, manual-code, and API-key flows.
- Constraints: Credentials remain in Pi Node secure ownership; Pi Client, Friday Relay, routes, models, logs, screenshots, and crash reports never contain reusable secret values.
- Source: `PLAN-PI-004`.
- Acceptance: Capability-driven provider listing, dual-auth deduplication, login, callback/device/manual continuation, replacement, logout, cancellation, expiry, invalid code/key, and redacted status outcomes are observable.

## REQ-PI-026 - Manage global and project settings

- Status: Planned
- Priority: Must
- Target: 1.0
- Review level: L9
- Actor and goal: A user can inspect and change global or trusted-project settings that affect appearance and Pi runtime behavior.
- Constraints: Project writes require trust; scope and reload impact are explicit; settings do not bypass provider, package, tool, or platform ownership. Windows Shell profiles are owned by the `1.1` remote Shell requirement rather than this `1.0` setting outcome.
- Source: `DEC-022` and `PLAN-PI-004`.
- Acceptance: Theme, locale, default model, thinking, retry, compaction, system prompt, tool definitions, tool presets, scope warning, save, reload-required, validation, and rollback states are observable.

## REQ-PI-027 - Manage skills

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can list, search, install, invoke, make dormant, check, and update global and trusted-project skills.
- Constraints: Pi Node uses the reviewed Pi resource/package boundary; project actions require trust; edits preserve unrelated skill content and source attribution.
- Source: `PLAN-PI-004`.
- Acceptance: Source grouping, dormancy, manual invocation, search, install scope, already-installed, update available, up-to-date, unsupported update, failure, and runtime reload outcomes are observable.

## REQ-PI-028 - Manage Pi packages and resources

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can inspect, install, update, enable, disable, remove, and reload Pi packages and their resolved resources.
- Constraints: Source, version or ref, scope, trust, resource inventory, full host-code privilege, and reload impact are shown before relevant actions.
- Source: `PLAN-PI-004`.
- Acceptance: npm, Git, and local sources; global/project scope; installed/loaded/disabled/error states; resource counts; update; removal; enable/disable; reload; and failure recovery are observable.

## REQ-PI-029 - Host standard extension interactions

- Status: Planned
- Priority: Must
- Target: 1.0
- Review level: L9
- Actor and goal: A user can respond to standard extension input and observe extension notifications, status, widgets, titles, and editor changes through native Flutter controls.
- Constraints: Blocking requests carry identity, timeout, cancellation, disconnect recovery, and stale-response rejection. Arbitrary custom terminal UI is excluded from `1.0` and is governed with `REQ-PI-019` by `PLAN-PI-008` for `1.1`.
- Source: `DEC-022` and `PLAN-PI-004`.
- Acceptance: Select, confirm, input, editor, notify, status, widget, title, editor text, extension error, timeout, cancel, disconnect, stale response, and replacement outcomes are observable.

## REQ-PI-030 - Open existing subagent sessions

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can identify, inspect, and open existing child or subagent sessions with their parent relationship and status.
- Constraints: Creating or configuring built-in subagents is not an accepted product requirement; third-party plugin behavior is not inherited implicitly.
- Source: `PLAN-PI-004`.
- Acceptance: Existing child sessions appear in the correct family, expose profile/status/activity, open independently, survive deep/orphaned metadata safely, and do not emit duplicate parent completion notifications.

## REQ-PI-031 - Provide localized adaptive product experience

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can operate Pi Client in English, Simplified Chinese, or Traditional Chinese across desktop, narrow, mobile, and Web layouts.
- Constraints: Theme, language, layout, focus, semantics, safe areas, and reduced motion use native platform conventions rather than reproducing browser CSS or PWA mechanics.
- Source: `DEC-014` and `PLAN-PI-004`.
- Acceptance: Light, dark, system, locale switching, responsive navigation, resizable/restored panels, keyboard-only operation, screen-reader semantics, 200% zoom, safe-area, and reduced-motion states are verified.

## REQ-PI-032 - Notify and accelerate user control

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can use shortcuts, clipboard actions, completion sound, notifications, deep links, and update notices without losing session context.
- Constraints: Permission and background behavior are platform-adapted; subagent/internal completions do not create duplicate or misleading notices.
- Source: `PLAN-PI-004`.
- Acceptance: Shortcut conflicts, copy, sound unlock/toggle, foreground/background completion, attention-needed, notification click, permission denial, deep link, update available, offline, and unsupported-platform outcomes are observable.

## REQ-PI-033 - Enforce host authorization and secret boundaries

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can grant only the project, file, tool, package, model, remote, and version-applicable Shell scopes needed for a Pi Client operation.
- Constraints: Project trust, allowed roots, canonical path checks, symbolic-link escape prevention, node pairing, scoped grants, secret redaction, bounded streams, and destructive confirmations fail closed. The `1.0` external-terminal action consumes only the current Node-validated project identity and creates no Shell grant, command, environment, output, PTY, or transport authority; remote Shell scopes begin with `REQ-PI-019` in `1.1`.
- Source: `DEC-013`, `DEC-014`, `DEC-022`, and `PLAN-PI-004`.
- Acceptance: Unauthorized roots, traversal, symbolic-link escape, stale/replayed grant, wrong Node, secret logging, oversized frames/uploads, unbounded streams, unconfirmed destructive actions, and attempts to use the `1.0` external-terminal boundary as a command proxy are rejected with stable user-visible errors.

## REQ-PI-034 - Publish supported 1.0 releases

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can install, verify, start, update, and recover a supported Pi Client `1.0.0` release for each declared platform role.
- Constraints: Release identity binds the Pi Client, Pi Node, protocol, exact Pi SDK, immutable source, artifact manifest, checksums, software bill of materials, licenses, signing, and platform evidence.
- Source: `DEC-014` and `PLAN-PI-004`.
- Acceptance: Declared desktop host artifacts and connect-only client artifacts install and start on supported systems; signatures, notarization where applicable, checksums, update/rollback, migration, and absence of host runtime on mobile/Web are verified.

## REQ-PI-035 - Qualify independent development artifacts without publishing

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A maintainer can qualify one source commit across Android, iOS, macOS, Windows, Linux, Web JavaScript, and WebAssembly without turning an unpublished development version into a public release.
- Constraints: The retained `independent-six-platform-development-v1` Profile remains publication-disabled for source-only qualification; desktop artifacts contain verified first-party Runtime Capsules, while Android, iOS, and Web remain connect-only; development qualification cannot create or mutate any release identity.
- Source: `DEC-016`, `DEC-021`, `DEC-023`, and `PLAN-PI-007`.
- Acceptance: Native-runner builds, per-target evidence, aggregate manifest/checksums, exact commit identity, desktop Capsule verification, mobile/Web connect-only scans, and publication-denial tests pass without creating or mutating any release identity.

## REQ-PI-036 - Present an independent truthful product landing

- Status: Active
- Priority: Must
- Review level: L6
- Actor and goal: A visitor can understand Pi Client as an independent Flutter client, its current source capabilities, its desktop-host/mobile-Web role split, and the exact state of the public macOS Preview.
- Constraints: Canonical production identity is `https://pi.wyattcoder.top/`; copy must not name legacy runtime products, advertise unpublished versions, render stale workspace screenshots, or expose a Homebrew command before the exact public Preview Release and Tap Cask are verified. Ordinary main builds remain source-only; release-bound Pages builds may expose the stable Homebrew command without hardcoding a version.
- Source: `DEC-017`, `DEC-021`, `DEC-023`, and `PLAN-PI-005`.
- Acceptance: Ordinary source output contains the independent identity and source-only disclosure; the exact release-bound output contains the verified Homebrew command, macOS Preview scope, signing/trust notice, and current platform roles; both routes exclude legacy identities, stale screenshots, secrets, and private operational content.

## REQ-PI-037 - Publish and synchronize the Homebrew Preview from exact release evidence

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A macOS user can install the current Pi Client Preview through a stable Homebrew command, and each later Preview release updates the same Tap Cask to its exact published asset.
- Constraints: The `independent-first-party-preview-v1` Profile is publication-enabled only for explicitly dispatched Preview releases; each release requires an annotated Tag and commit identity, a public Universal first-party Runtime Capsule artifact, exact SHA-256, signing/trust disclosure, dedicated Tap authorization, and no Gatekeeper bypass.
- Source: `DEC-018`, `DEC-021`, `DEC-023`, and `PLAN-PI-006`.
- Acceptance: Cask generation rejects unpublished, mismatched, placeholder, non-Universal, connect-only, or non-runtime evidence; the release workflow updates `Hu-Wentao/homebrew-tap/Casks/pi-client.rb` after public asset readback; a clean Homebrew install verifies the exact version, architecture, Runtime Capsule, quarantine, and uninstall behavior.

## REQ-PI-038 - Open the trusted desktop project in an external terminal

- Status: Planned
- Priority: Must
- Target: 1.0
- Review level: L9
- Actor and goal: A desktop user can open the current Pi Node-validated project in a system external terminal at its canonical working directory.
- Constraints: The action is visible only for a selected project whose trust status is `trusted` or `notRequired`, accepts only its `PiProjectIdentity`, and is limited to macOS, Windows, and Linux. It does not execute `pi` or any other command, copy or generate commands, accept arbitrary arguments or environment, capture output, provide stdin or PTY, create a Shell grant, use a file URL, or cross Pi Protocol/Friday Transport. Android, iOS, and Web return unsupported and expose no action.
- Source: `DEC-022` and `PLAN-PI-004`.
- Acceptance: Exact canonical cwd, spaces and command metacharacters without Shell interpolation, Node-canonicalized symbolic-link identity, no selected or untrusted project, desktop availability, missing-terminal unsupported state, redacted launch failure, stale project switch, keyboard activation, screen-reader semantics, 200% text scale, and connect-only artifact absence are observable.
