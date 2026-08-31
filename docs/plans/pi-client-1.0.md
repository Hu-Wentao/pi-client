---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary:
      source: heading
      levels: [2]
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
    key:
      source: heading
      pattern: '^(?P<id>PLAN-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'
      group: id
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    target: {source: label, labels: [Target, 目标]}
    raw: {source: body}
  queries:
    plan_by_id:
      when: {pattern: '^PLAN-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level, target]
      expect: {max_record_lines: 360, max_record_bytes: 65536, structured: true, min_confidence: 1.0}
    plans_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, review_level, target]
      expect: {max_total_bytes: 131072, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client 1.0 实施计划

默认评审级别：L3。用户批准的完整性目标、独立实现、平台执行角色和安全边界为 L9；已接受决策与当前仓库事实为 L6；未冻结的实现细节为 L3。

## PLAN-PI-004 - 独立 Pi Client 完整功能至 1.0.0

- Status: Active
- Review level: L9（目标与边界）/ L3（阶段与实现路径）
- Target: 项目自有的 Pi Client 在 `1.0.0` 前完成所有 release-scoped Must requirements，并提供受支持的六平台客户端与桌面 Agent 宿主交付。

### 权威与计划关系

- `DEC-020` 建立项目自有产品权威；`docs/requirements.md` 独立拥有产品语义、约束、完整性和可观察验收。
- `PLAN-PI-001` 继续保持 Superseded，并且不授权任何实现。
- `PLAN-PI-002` 是 Friday Workspace、Native OIDC、E2EE 和 WebAssembly 的并行轨道；它不得阻塞 Local Direct 功能完整性。
- `PLAN-PI-003` 仅保留为 `v0.0.2` Landing Page 与 Preview 的历史记录，不拥有当前 `1.0.0` 范围或验收权威。
- 初始探索资料仅作为历史记录，不参与当前需求、完整性、架构、协议、实现、兼容性、运行时、构建、部署或发布判断。

### 完整性定义

`1.0.0` 功能完整性要求：

1. 每个 release-scoped Must requirement 均为 Active，且所有验收条款具有适当、可追溯的验证证据。
2. 所有平台适配均满足项目需求定义的等价结果与平台安全边界。
3. 代码、依赖、构建、协议、发布和运行时仅依赖项目批准并拥有的合同与组件。
4. Android、iOS 和 Web 保持 connect-only；macOS、Windows 和 Linux 可以运行项目自有 Pi Node。
5. Friday Workspace 完成前，Local Direct 仍可独立达到全部桌面功能完整性。

### 目标系统边界

```text
Flutter Pi Client
  -> project-owned typed PiNodeClient
     -> Local IPC / paired LAN / Friday Workspace transports
        -> first-party Pi Node
           -> reviewed Pi SDK Runtime boundary
           -> session, project trust, files, Git, worktrees
           -> model/provider/settings, skills/packages, extension UI
```

- Flutter owns presentation, navigation, transient interaction state, and non-secret preferences.
- Pi Node owns Pi SDK lifecycle, provider credentials, project trust, host files, shell, Git, worktrees, resources, and authorization.
- The protocol owns version negotiation, request/command/stream identity, cancellation, ordering, backpressure, reconnect cursors, stable errors, and limits.
- Friday Relay owns only the control and opaque transport responsibilities accepted by `DEC-013` and `PLAN-PI-002`.
- Feature modules depend on `PiNodeClient`, not on a concrete transport or Pi SDK type.

### Phase path

| Phase | Status | Primary scope | Exit gate |
| --- | --- | --- | --- |
| P0 | Complete | Governance, project-owned scope, requirement and verification ownership | Scope is fully classified; dependencies and architecture spikes have recorded decisions |
| P1 | Source substantially complete | Protocol, Pi Node skeleton, desktop host controller | One typed prompt round trip works through project-owned runtime; crash/restart/version gates pass |
| P2 | Source substantially complete | Local Direct migration and legacy adapter removal | Existing MVP uses only project-owned runtime; obsolete configuration paths remain absent |
| P3 | Planned | Project, session, history, branch, and app shell | `REQ-PI-014` through `REQ-PI-016` and `REQ-PI-030` have complete evidence |
| P4 | Planned | Agent, composer, shell, and rich messages | `REQ-PI-017` through `REQ-PI-020` have complete evidence |
| P5 | Planned | Files, Git, and worktrees | `REQ-PI-021` through `REQ-PI-023` and applicable security clauses have complete evidence |
| P6 | Planned | Models, providers, and settings | `REQ-PI-024` through `REQ-PI-026` have complete evidence and secret scans pass |
| P7 | Planned | Skills, packages, and extension UI | `REQ-PI-027` through `REQ-PI-029` have complete evidence |
| P8 | Planned | Localization, theme, responsive UX, notifications, and accessibility | `REQ-PI-031` and `REQ-PI-032` pass platform and accessibility acceptance |
| P9 | Planned | Six-platform host/client conformance and packaging | Desktop host and connect-only roles pass artifact inspection and supported builds |
| P10 | Planned | Friday Workspace, Native OIDC, E2EE, and WebAssembly | `PLAN-PI-002` cross-project gates pass without weakening Local Direct |
| P11 | Planned | Release qualification and `1.0.0` publication | All Must requirements are Active, no gaps remain, and immutable production artifacts are verified |

### P0-P2 progress at `c10178c`

- P0 is complete: `BASE-PI-008`, `REQ-PI-001` through `REQ-PI-034`, and their verification records establish project-owned scope, lifecycle semantics, and verification ownership.
- P1 source is substantially complete: the repository contains a first-party Pi SDK domain, fail-closed project-trust coordinator, private Protobuf `0.1.0-dev.0` package with Dart/TypeScript codecs and vectors, stdio protocol server, Flutter codec/client, desktop host controller, Local Direct process transport, cross-process fixtures, and a reproducible host-targeted runtime Capsule builder.
- P2 source is substantially complete: application composition owns `PiNodeApi`; Workspace list/load/create/prompt/abort/event behavior uses typed first-party APIs; and current source contains no obsolete compatibility adapter, endpoint credential UI, legacy HTTP streaming runtime, compatibility test, or smoke tool.
- These statuses describe source implementation only. They do not activate `REQ-PI-006`, `REQ-PI-009`, or `REQ-PI-013`, publish Protocol 1.0, prove a provider-backed production prompt, bundle a Capsule into supported desktop packages, qualify project-trust UX, or establish an independent public release.

### P0 - Freeze governance and technical preflight

Deliverables:

- Preserve accepted project decisions and keep requirements as the current semantic authority.
- Retain initial exploration records as historical evidence without using them as current scope input.
- Deprecate `REQ-PI-001` through `REQ-PI-003` for post-`v0.0.2` work while retaining immutable release evidence.
- Establish Planned requirements and verification owners for every accepted domain.
- Complete bounded dependency evaluations and spikes for Pi SDK entry points, Node runtime, protocol codec/code generation, Local IPC/WebSocket, sidecar packaging, secure storage, rich previews, and standard E2EE.
- Record unresolved technical choices as decisions before they become compatibility surfaces.

Exit conditions:

- Every release-scoped capability maps to a project-owned requirement and verification owner.
- Every Planned requirement has a primary verification owner and known gap.
- No plan or baseline treats an exploratory external implementation as current semantic or implementation input.
- Pi SDK lifecycle, project-trust-before-resource-load, process boundary, protocol encoding, and packaging choices are accepted or explicitly blocked.

### P1 - Establish Protocol, Pi Node, and desktop host

Deliverables:

- Create independently versioned Pi Protocol and Pi Node packages with cross-language test vectors.
- Integrate only reviewed public Pi SDK entry points; prohibit `dist/**` and third-party internal objects at the Flutter boundary.
- Implement handshake, capabilities, stable errors, command admission, ordered streams, cancellation, reconnect, backpressure, and limits.
- Implement desktop host start, health, restart, crash detection, shutdown, version check, and redacted logs.
- Make mobile and Web host APIs explicitly unsupported and artifact-excludable.

Exit conditions:

- A Flutter fixture starts or reaches Pi Node, opens a trusted test project, completes one prompt, receives terminal state, and cancels a second run.
- Dart and TypeScript encode/decode the same valid, unknown-field, invalid, oversized, cancelled, and incompatible-version vectors.
- Pi Node restart and host shutdown do not corrupt sessions or leak secrets.

### P2 - Complete Local Direct and remove obsolete compatibility paths

Deliverables:

- Migrate session list/detail, new session, prompt, stream, and abort to `PiNodeClient`.
- Replace raw maps and legacy reducers with project-owned DTOs and state machines.
- Keep obsolete compatibility adapters, endpoint credential UI, smoke tooling, and legacy build/runtime references absent.
- Update README, Landing Page, support, migration, and rollback guidance.

Exit conditions:

- `REQ-PI-006`, `REQ-PI-009`, and `REQ-PI-013` pass Local Direct evidence through project-owned runtime.
- Repository and produced artifacts contain no unapproved external runtime, source, route, schema, event, or protocol dependency.
- Release as the first independent architecture milestone; recommended identity is `0.1.0` because the legacy configuration is removed.

### P3 - Deliver projects and sessions

Deliverables:

- Split the current workspace into app shell, node connection, project browser, session browser, conversation, and composer ownership.
- Implement project selection, recent/default project, identity, trust, allowed roots, and workspace restore.
- Implement session family, running/unread, lazy creation, rename/auto-name, delete/reparent, export, pagination, deferred content, branch navigation, edit-from-here, and independent session creation.
- Preserve existing child/subagent session visibility without adding unaccepted built-in creation to the release gate.

Exit conditions:

- Deep, orphaned, cyclic, removed-worktree, stale-response, and concurrent-selection fixtures preserve deterministic project and session state.
- Destructive session operations identify the exact target and recover from failure.

### P4 - Deliver Agent, composer, shell, and messages

Deliverables:

- Implement prompt admission, optimistic input, ordered streaming, abort, retry, compaction, reload, steer, follow-up, queue, and refresh recovery.
- Implement draft/history, image limits, slash palette, templates, skills, extension commands, file/line mentions, model/thinking/tool selection, and shell modes.
- Implement sanitized Markdown/GFM/math/Mermaid/ANSI/code/image/tool/diff/written-file/process/usage rendering and oversized fallbacks.

Exit conditions:

- Duplicate, missing, late, out-of-order, disconnected, uncertain, cancelled, and replaced-run cases cannot restore stale output or report false success.
- Shell is unavailable on connect-only platforms and cannot escape project authorization.

### P5 - Deliver files, Git, and worktrees

Deliverables:

- Implement canonical path, allowed-root, symbolic-link, range, upload, download, watch, cancel, and backpressure services.
- Implement Explorer, search, conflict handling, tabs, source and rich previews, live refresh, mentions, and written-file navigation.
- Implement Git status/diff and safe worktree list/switch/create/remove with two-step dirty force removal.

Exit conditions:

- Traversal, symbolic-link escape, unauthorized roots, oversized files, slow consumers, watch races, and cancelled transfers fail closed.
- Worktree removal never deletes a branch and old session history remains discoverable.

### P6 - Deliver models, providers, and settings

Deliverables:

- Implement model catalog, scope, selection, thinking, discovery, metadata fill/undo, test, default, and reload.
- Implement provider OAuth, device, manual, API-key, logout, dual-auth deduplication, expiry, and redacted status.
- Implement global/project settings, system prompt, tool definitions, retry, compaction, tool presets, and Windows shell settings.

Exit conditions:

- Provider secrets exist only in Pi Node-owned secure storage and are absent from Flutter state, Relay, URLs, logs, screenshots, crash reports, and test artifacts.
- Project settings remain trust-gated and failed writes preserve prior valid state.

### P7 - Deliver skills, packages, and extension UI

Deliverables:

- Implement skill listing, dormancy, invocation, search, install, update checks, updates, source, and scope.
- Implement package inventory, install, update, enable, disable, remove, resource listing, privilege disclosure, and reload.
- Implement native standard extension dialogs and a bounded custom terminal bridge.

Exit conditions:

- Blocking UI requests pass timeout, cancel, disconnect, replacement, and stale-response tests.
- Package and skill operations show source/scope and cannot bypass project trust or host authorization.

### P8 - Complete product experience

Deliverables:

- Complete English, Simplified Chinese, and Traditional Chinese localization.
- Complete light/dark/system themes, desktop/narrow/mobile layouts, resizable panels, restoration, safe areas, reduced motion, and offline states.
- Complete shortcuts, clipboard, sounds, native notifications, deep links, and update checks.

Exit conditions:

- Keyboard, focus order, screen reader, contrast, 200% zoom, reduced motion, IME, and representative viewport acceptance pass on supported platform surfaces.
- Platform differences are classified as Exact, Native-adapted, or Not-applicable with user impact.

### P9 - Qualify six platform roles

Deliverables:

- Qualify macOS, Windows, and Linux as Agent-host-capable releases.
- Qualify Android, iOS, and Web as connect-only releases.
- Inspect artifacts for forbidden Pi SDK, Node runtime, shell host, and host filesystem code on mobile/Web.
- Establish platform signing, icons, minimum versions, deep links, notifications, installers, and update channels.

Exit conditions:

- `REQ-PI-010`, `REQ-PI-011`, and platform clauses of `REQ-PI-034` pass on appropriate hosts.
- Unsupported hosting fails explicitly rather than silently degrading or exposing permissions.

### P10 - Complete Friday Workspace in parallel

Deliverables and gates remain owned by `PLAN-PI-002`:

- Friday personal Workspace, paid entitlement, managed origin, Node enrollment, access grants, outbound tunnel, Native public OIDC, E2EE, and WebAssembly hosting.
- One `PiNodeClient` behavior suite must pass through Local Direct and Friday transports.
- Friday Relay must not persist or decrypt Pi prompts, messages, file names/content, Git diffs, tool data, or provider credentials.

Exit conditions:

- Friday runtime evidence is complete in both projects; pi-client tests do not claim Friday identity, billing, hostname, or tunnel success on behalf of friday-relay.
- Local Direct remains fully functional without Friday identity or entitlement.

### P11 - Qualify and publish 1.0.0

Deliverables:

- Freeze supported protocol and migration promises for major version 1.
- Produce immutable source tag, artifact manifest, checksums, SBOM, license inventory, signatures, notarization where applicable, and rollback instructions.
- Complete requirements status review and the full verification matrix.
- Publish user documentation that presents only the supported project-owned runtime and prerequisites.

Exit conditions:

- Every Must requirement is Active and every acceptance clause has appropriate evidence.
- Every release-scoped Must requirement has complete acceptance evidence.
- Known gaps, blocked external evidence, and unsupported platforms are zero for the declared `1.0.0` support matrix.
- Pi Client, Pi Node, Pi Protocol, and exact Pi SDK identities are bound to the released artifacts.

### Release milestones

| Version | Minimum product milestone |
| --- | --- |
| `0.1.0` | P1-P2: project-owned Pi Node, Local Direct, and removal of obsolete runtime dependence |
| `0.2.0` | P3: projects, sessions, history, branches, and existing child-session visibility |
| `0.3.0` | P4: Agent, composer, shell, and rich messages |
| `0.4.0` | P5: files, Git, and worktrees |
| `0.5.0` | P6-P7: models, providers, settings, skills, packages, and extension UI |
| `0.6.0` | P8-P9: complete product UX and six-platform execution-role qualification |
| `0.7.0` | P10: Friday Workspace and WebAssembly, when cross-project gates pass |
| `1.0.0` | P11: project-owned completeness, security, compatibility, signed distribution, and production acceptance |

Milestone numbers are planning identities, not release authorization. A release occurs only from an exact validated commit under current release governance.

### Common verification gates

- Protocol: schema lint, breaking-change review, generated no-diff, cross-language vectors, unknown input, property tests, fuzzing, limits, cancellation, and backpressure.
- Pi Node: SDK lifecycle, project trust, single-writer/session replacement, path and symbolic-link security, destructive Git/worktree operations, credential redaction, crash/restart/shutdown.
- Flutter: format, generation, analysis, focused ViewModel concurrency, Widget interaction, Golden, route/contract validation, keyboard, accessibility, and six-platform builds.
- Transport: identical accepted behavior fixtures on in-memory, Local IPC, paired LAN, and Friday transports where available.
- Security: pairing, node key pinning, scoped authorization, grant expiry/replay, E2EE tamper, secret scans, Relay payload opacity, and connect-only artifact inspection.
- Release: exact source, immutable tag, artifact manifest, checksums, signatures, SBOM, license inventory, installation, startup, update, rollback, and production smoke evidence.

### Compatibility and rollback

- `v0.0.2` remains an immutable historical compatibility Preview. It is not rewritten or republished.
- The removed legacy endpoint credential configuration is an intentional `0.x` Breaking Change documented by historical release notes; current source and releases must not claim that configuration still exists.
- Pi Client, Pi Node, and Pi Protocol use separate SemVer identities; handshake rejects incompatible majors and never downgrades authentication or encryption.
- At `1.0.0`, APIs, protocol, configuration, persisted state, deep links, and release channels follow same-major compatibility and deprecation rules.
- A failed phase does not restore obsolete compatibility adapters; repair proceeds on the project-owned architecture or rolls back to the last immutable release.

### Current gaps

- The Protobuf `0.2.0-dev.0` package is private and unpublished. Stream open/resume/close, reconnect cursors, replay retention, stateful backpressure, authentication, pairing, LAN Direct, Friday transport equivalence, and Protocol 1.0 compatibility policy remain incomplete.
- The production cross-process SDK evidence covers offline handshake, session list/create/get, and Workspace creation. Prompt/abort ordering, uncertain admission, framing pressure, incompatible versions, and process-exit behavior are cross-process fixture evidence; a real provider-backed production prompt, cancellation, restart, and session recovery are not yet proven.
- The fail-closed project-trust coordinator and focused tests exist, but the production app has no complete trust-decision UX or operational evidence for protected project resources. Provider authentication and secure credential lifecycle remain unimplemented.
- The runtime Capsule builder verifies a host-targeted Node/Pi Node payload, manifest, checksums, and forbidden-artifact scan, but no supported desktop application currently bundles and qualifies that Capsule. Windows/Linux packaging, signed/notarized desktop distribution, and the first independent public release remain incomplete.
- README and Landing Page describe current source-only development and provide no binary CTA. The public `v0.0.2` Release remains immutable historical evidence outside current delivery surfaces.
- Friday Workspace contracts remain blocked as recorded by `VER-PI-008` and `VER-PI-009`; rich previews, E2EE, mobile store identity, WebAssembly compatibility, and production accessibility evidence remain Planned.
