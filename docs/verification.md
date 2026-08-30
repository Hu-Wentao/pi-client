---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>VER-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>VER-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    requirements: {source: label, labels: [Requirements, 需求]}
    owner: {source: label, labels: [Owner, 所有者]}
    raw: {source: body}
  queries:
    verification_by_id:
      when: {pattern: '^VER-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, requirements, owner]
      expect: {max_record_lines: 45, max_record_bytes: 10240, structured: true, min_confidence: 1.0}
    verification_by_requirement:
      match: {source: field, field: requirements, operator: contains}
      select: [title, status, owner]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client verification traceability

## VER-PI-001 - Legacy v0.0.2 gateway compatibility

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-003
- Owner: `test/workspace_gateway_test.dart` and `tool/pi_web_smoke.dart`
- Evidence: URL validation, Basic Auth header, credential-free URI, SSE heartbeat/data parsing, and read-only live session listing against pi-web `0.8.11`.
- Release scope: This evidence remains valid for immutable `v0.0.2`; it does not qualify first-party Pi Node or post-`v0.0.2` product behavior.
- Scope limit: The live smoke is read-only; mutation semantics are owned by controlled ViewModel tests.

## VER-PI-002 - Legacy v0.0.2 workspace state machine

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-002, REQ-PI-003
- Owner: `test/workspace_view_model_test.dart`
- Evidence: connect/load/select, history parsing, prompt optimistic state, stream delta, abort, final authoritative refresh, reconnect, and password exclusion from JSON state.
- Release scope: This evidence remains valid for immutable `v0.0.2` and does not satisfy the replacement requirements.

## VER-PI-003 - Legacy v0.0.2 Flutter interaction

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-002, REQ-PI-003
- Owner: `test/workspace_view_test.dart` and `test/application_test.dart`
- Evidence: routed application build, connection/session controls, session click, selected history rendering, composer controls, and application-owned/external Dio boundaries.
- Release scope: This evidence remains valid for immutable `v0.0.2`; future UI verification uses first-party requirements and transports.

## VER-PI-004 - Desktop visual baseline

- Status: PASS
- Requirements: REQ-PI-002, REQ-PI-004
- Owner: `test/workspace_golden_test.dart` and `test/goldens/workspace_desktop.png`
- Evidence: fixed 1200 × 800 Flutter-rendered workspace layout with connection controls, sessions, selected messages, status line, and composer.
- Release scope: Session behavior in this record remains historical `v0.0.2` evidence; the reusable geometry evidence may continue only while the rendered contract remains applicable.
- Scope limit: Flutter's deterministic test font validates geometry rather than production glyph rasterization; the native app build and launch own real-font startup evidence.

## VER-PI-005 - Contract, generation, analysis, tests, and macOS build

- Status: PASS
- Requirements: REQ-PI-004, REQ-PI-005
- Owner: fr-mvvm-contract validator, build_runner, Flutter analyzer/test/build
- Evidence: `workspace.page.dart` passes contract and final phases; generated Freezed/JSON/typed-route files are current; analysis has no issues; all Flutter tests pass; macOS Debug `.app` builds and launches.
- Scope limit: Release signing, Apple Team identity, notarization, and distribution are outside MVP.

## VER-PI-006 - PLAN-PI-002 R0 client contract surface

- Status: PASS
- Requirements: REQ-PI-006, REQ-PI-007, REQ-PI-008, REQ-PI-009
- Owner: `test/central_access_contract_test.dart`, `test/platform_auth_adapter_test.dart`, `test/pi_transport_contract_test.dart`, and mdq contract checks
- Evidence: The pure Dart central projection, auth adapter, opaque grant, error, protocol-version, and transport interfaces compile; focused tests cover safe projection invariants, configured Workspace-origin authority, server-owned access Decisions, stable error mapping, grant redaction and trusted TTL/path/thumbprint binding contracts, defensive frame copies, and Local Direct independence; governed R0 records remain uniquely queryable.
- Scope limit: This PASS proves only the pi-client contract surface; it does not prove Pi Node, Friday Relay, platform authentication, socket/tunnel, grant issuance, E2EE, or product runtime behavior.

## VER-PI-007 - Local Direct, Pi Node, and transport conformance runtime

- Status: PARTIAL
- Requirements: REQ-PI-006, REQ-PI-009, REQ-PI-013
- Owner: `protocol/`, `node/`, `lib/api/pi_node/`, `lib/protocol/`, `lib/transport/`, `lib/platform/agent_host/`, `test/pi_node_*`, `test/local_direct_pi_transport_test.dart`, `test/protobuf_pi_protocol_codec_test.dart`, and `tool/run_pi_node_cross_process_e2e.mjs`
- Source identity: The scoped source evidence is `c10178c930a7176711ae66a9f00736be8e14ef1c`; it is not a published independent release identity.
- Protocol evidence: Private `@pi-client/protocol 0.1.0-dev.0` defines an unpublished Protobuf v0 envelope, exact `0.1.0` negotiation, stable typed session operations/events, frame and transfer limits, Dart/TypeScript codecs, generated no-diff checks, and cross-language binary vectors including unknown-field, unknown-operation, unknown-enum, and full-range `uint64` cases.
- Node evidence: First-party Pi Node source imports reviewed public Pi SDK package entry points, gates project resources through `ProjectTrustCoordinator`, owns persistent session list/create/load, prompt/abort admission and ordered events, serves bounded length-prefixed Protobuf over stdio, separates protocol stdout from redacted stderr, and has focused lifecycle/domain/protocol/trust tests.
- Flutter evidence: `PiNodeApi`, `PiNodeClient`, `ProtobufPiProtocolCodec`, stdio `LocalDirectPiTransport`, desktop `PiNodeHostController`, and app-owned provider composition exist; Workspace has cut over to typed first-party list/load/create/prompt/abort/session-event behavior with stale-load and sequence-gap recovery tests.
- Cross-process evidence: The built production Node passes offline public-SDK handshake, session list/create/get, missing-session error, and production Workspace creation. A built fixture proves accepted/rejected/uncertain commands, abort, ordered session events, split/coalesced framing, 512 KiB stderr pressure, incompatible-version rejection, process-exit uncertainty, and idempotent close.
- Capsule evidence: The repository contains a reproducible host-targeted runtime Capsule builder and verifier for pinned Node, Pi Node, Protocol, Pi SDK, manifests, checksums, read-only payloads, and forbidden artifacts; the Capsule is not yet integrated into an application release.
- Absence evidence: Current tracked source contains no `PiWebGateway`, `PiWebApi`, pi-web URL/password path, Dio HTTP/SSE runtime, gateway compatibility test, or `tool/pi_web_smoke.dart`. Immutable `v0.0.2` historical evidence remains owned by `VER-PI-001` through `VER-PI-003`.
- Gaps: Protocol v0 remains unpublished and lacks production authentication/pairing, LAN and Friday transports, reconnect/replay completion, and a frozen v1 policy. A real provider-backed production prompt/abort, protected-project trust-decision UX, Node crash restart/session recovery, Capsule bundling on supported desktops, artifact-level pi-web absence, and a public independent release are not yet evidenced.
- Lifecycle decision: `REQ-PI-006`, `REQ-PI-009`, and `REQ-PI-013` remain Planned because their complete Direct/remote equivalence, authorization, restart, packaging, operational, and release acceptance clauses are not satisfied.

## VER-PI-008 - Friday Workspace and private tunnel runtime

- Status: BLOCKED
- Requirements: REQ-PI-007, REQ-PI-009
- Owner: future cross-project friday-relay, pi-client, and Pi Node integration
- Planned evidence: Verify one-Workspace ownership, exact Host denial, entitlement outcomes, Node binding, grant renewal/revocation, tunnel routing, E2EE opacity, and Direct/remote equivalence.
- Blocker: `friday-relay@42cb0a74890700920d411604f07ff70a5bde5bd2` 已建立 `PLAN-PI-WORKSPACE-R0-CONTRACTS` 及 Workspace/commerce/enrollment/tunnel/ingress Planned requirements，但 exact Workspace domain/slug、Node cardinality、grant wire/TTL/renewal/revocation、tunnel topology/path、E2EE suite/vectors 和 Pi Protocol initial version 仍未冻结；不存在外部运行时实现声明。

## VER-PI-009 - Native and WebAssembly Friday authentication runtime

- Status: BLOCKED
- Requirements: REQ-PI-008
- Owner: future friday-relay authentication tests plus pi-client platform integration and manual platform verification
- Planned evidence: Verify native system-browser PKCE and secure storage, WebAssembly canonical handoff and host-only session, callback/handoff denial, and absence of browser-readable long-lived credentials.
- Blocker: `friday-relay@42cb0a74890700920d411604f07ff70a5bde5bd2` 已建立 Native/WASM Friday identity 的 Planned requirement，但 exact Native callback、Workspace handoff path/session profile、SameSite、Native refresh/rotation/revoke 和 public-client token lifetime 仍未冻结；不存在外部运行时实现声明。

## VER-PI-010 - Platform execution-role contract

- Status: PASS
- Requirements: REQ-PI-011
- Owner: `lib/platform/platform_capabilities.dart`, `test/platform_capabilities_test.dart`, and `test/application_test.dart`
- Evidence: Focused tests map macOS, Windows, and Linux to Agent-host-capable roles; map Android, iOS, and Web to connect-only roles; reject Fuchsia; and prove that the root provider exposes the selected capability object.
- Scope limit: This PASS proves the platform gate only. It does not prove Pi SDK availability, Agent host lifecycle, tool isolation, Local Direct, or remote transport behavior.

## VER-PI-011 - Six-platform project and build matrix

- Status: PARTIAL
- Requirements: REQ-PI-010, REQ-PI-011
- Owner: Flutter platform directories, `.metadata`, shared analyzer/tests, and per-platform Flutter build commands
- Evidence: `.metadata` tracks Android, iOS, Linux, macOS, Web, and Windows; shared analysis and all tests pass; macOS Debug, Android Debug APK, iOS Debug without code signing, and standard JavaScript Web builds succeed. iOS is fixed at 15.0 because ObjectBox requires it.
- Gap: Windows and Linux native builds require their respective operating systems. Dart WebAssembly is blocked by `flutter_secure_storage_web 1.2.1`, which still imports unsupported `dart:html` and `dart:js` libraries. Signing, store identity, production icons, and distribution remain unverified or missing for the general platform matrix; the bounded unsigned macOS Preview is tracked separately by `VER-PI-012` and `VER-PI-013`.

## VER-PI-012 - Landing Page and unsigned Preview source qualification

- Status: PASS
- Requirements: REQ-PI-004, REQ-PI-012
- Owner: `test/app_storage_test.dart`, `test/marketing_screenshot_test.dart`, `site/scripts/validate-built-site.mjs`, Astro checks, Flutter checks, and local macOS build inspection
- Evidence: Distribution-channel tests prove standard/Preview directory and key selection without changing Windows/Linux debug storage; the committed 1280 × 800 screenshot renders synthetic data with real Flutter fonts and icons, with cross-host raster variance bounded to 0.02%; brand generation is source-controlled; English and Chinese static routes build with exact metadata, base-aware assets, exact `v0.0.2` CTA, and no client JavaScript; Flutter analysis/tests and macOS build gates qualify the source.
- Scope limit: This PASS proves committed source and locally executable workflow logic only. It does not prove a pushed tag, public GitHub Release asset, GitHub-hosted workflow run, Pages deployment, notarization, Gatekeeper trust, or production-browser acceptance.

## VER-PI-013 - Public Release and GitHub Pages acceptance

- Status: PARTIAL
- Requirements: REQ-PI-012
- Owner: `.github/workflows/release-macos.yml`, `.github/workflows/pages.yml`, GitHub Release evidence, and production manual accessibility/browser verification
- Evidence: Annotated `v0.0.2` resolves to `ac2b492cf595a715fc5e86f7e850ae5bcaf4c942`; Release build run `33308958703` passed generation, analysis, 35 tests, Debug build, unsigned Universal build, bundle/architecture/Gatekeeper checks, launch without Keychain `-34018`, packaging, tag creation, and Draft upload. Draft release `379262752` was reconciled after the workflow's tag lookup returned 404; the exact uploaded ZIP and SHA-256 were downloaded, checksum-verified, unpacked, and inspected before publication. Pages run `33309764563` deployed both locales from `c6318263fd4309460d392697eef84eee24c96058`; production HTML, canonical URLs, assets, direct download, Cloudflare command integrity, responsive Chrome rendering, and Lighthouse 94/100/100/100 were verified.
- Gap: Safari WebDriver is blocked until **Allow Remote Automation** is enabled. VoiceOver and 200% zoom still require manual acceptance. HTTPS works through Cloudflare, but GitHub Pages cannot enforce HTTPS for the inherited custom domain and HTTP does not currently redirect; changing that shared domain behavior requires separate Cloudflare governance authority.

## VER-PI-014 - 1.0 parity governance integrity

- Status: PASS
- Requirements: REQ-PI-005
- Owner: persistent mdq contracts, exact/negative queries, link checks, and source review of the fixed pi-web snapshot
- Evidence: `DEC-016`, `PLAN-PI-004`, `BENCH-PI-001` through `BENCH-PI-015`, and `REQ-PI-001` through `REQ-PI-034` are uniquely queryable; every observed domain maps to project-owned requirements, native adaptation, or explicit exclusion.
- Scope limit: This PASS proves P0 governance structure and bounded source classification only. It does not prove any Planned runtime feature or `1.0.0` completeness.

## VER-PI-015 - Project, session, history, and child-session behavior

- Status: PLANNED
- Requirements: REQ-PI-014, REQ-PI-015, REQ-PI-016, REQ-PI-030
- Owner: future Pi Node integration, Flutter ViewModel/Widget tests, deep-tree fixtures, and desktop E2E
- Planned evidence: Verify project selection/trust, workspace restore, session lifecycle, running/unread state, pagination, branches, edit-from-here, independent sessions, exports, destructive recovery, and existing child-session visibility.
- Gap: `VER-PI-007` proves the basic first-party session list/create/load foundation and Workspace cutover only. Project selection and trust UX, restore, naming, deletion, export, pagination, branch/fork behavior, child-session presentation, and the full P3 module split remain unimplemented or unevidenced.

## VER-PI-016 - Agent, composer, shell, and rich conversation behavior

- Status: PLANNED
- Requirements: REQ-PI-017, REQ-PI-018, REQ-PI-019, REQ-PI-020
- Owner: future protocol fixtures, Pi Node runtime integration, focused Flutter concurrency/Widget tests, Golden tests, and desktop E2E
- Planned evidence: Verify command admission, streaming order, retry, compaction, queue, drafts, attachments, commands, mentions, shell, rich renderers, deferred/oversized content, disconnect recovery, and stale-event rejection.
- Gap: `VER-PI-007` proves basic typed prompt/abort admission, ordered session events, optimistic Workspace state, and sequence-gap recovery only. Retry, compaction, reload/steer/follow-up queues, full composer inputs, desktop shell, rich rendering, provider-backed production turns, and the complete P4 recovery matrix remain unimplemented or unevidenced.

## VER-PI-017 - File, Git, and worktree behavior

- Status: PLANNED
- Requirements: REQ-PI-021, REQ-PI-022, REQ-PI-023
- Owner: future Pi Node filesystem/Git integration, Flutter file workspace tests, destructive-operation tests, and desktop E2E
- Planned evidence: Verify allowed file workflows and previews, Git status/diff, worktree list/switch/create/remove, dirty refusal, explicit force confirmation, cancellation, large files, watches, and session preservation.
- Gap: Pi Node file, Git, and worktree services and Flutter workspace UI are not implemented.

## VER-PI-018 - Model, provider, and settings behavior

- Status: PLANNED
- Requirements: REQ-PI-024, REQ-PI-025, REQ-PI-026
- Owner: future Pi SDK model/auth integration, Pi Node secure-storage tests, Flutter settings tests, provider-flow integration, and manual platform verification
- Planned evidence: Verify model scope/selection/discovery/test/reload, OAuth/device/manual/API-key flows, logout, secret redaction, global/project settings, trust gates, validation, and rollback.
- Gap: Pi Node model, provider, credential, and settings services are not implemented.

## VER-PI-019 - Skill, package, and extension interaction behavior

- Status: PLANNED
- Requirements: REQ-PI-027, REQ-PI-028, REQ-PI-029
- Owner: future Pi resource/package integration, Flutter settings tests, extension dialog fixtures, terminal-bridge tests, and desktop E2E
- Planned evidence: Verify skill dormancy/search/install/update, package inventory/install/update/enable/disable/remove/reload, privilege disclosure, and all standard/custom extension UI lifecycle states.
- Gap: First-party resource/package services and extension UI bridge are not implemented.

## VER-PI-020 - Localized adaptive UX and supported release artifacts

- Status: PLANNED
- Requirements: REQ-PI-010, REQ-PI-011, REQ-PI-031, REQ-PI-032, REQ-PI-034
- Owner: Flutter platform builds, localization tests, responsive/Golden/keyboard/accessibility tests, artifact inspection, signing checks, and manual platform acceptance
- Planned evidence: Verify three locales, themes, layouts, restoration, IME, notifications, shortcuts, clipboard, safe areas, reduced motion, screen readers, 200% zoom, desktop-host artifacts, connect-only artifacts, signing, installation, update, and rollback.
- Gap: Windows/Linux host evidence, mobile/Web release artifacts, signed/notarized production desktop artifacts, and full accessibility acceptance are missing.

## VER-PI-021 - Host authorization and secret-boundary security

- Status: PLANNED
- Requirements: REQ-PI-033
- Owner: future protocol and Pi Node adversarial suites, credential scans, transport tests, artifact scans, and operational review
- Planned evidence: Reject unauthorized roots, traversal, symbolic-link escape, wrong Node, stale/replayed grants, secret logging, oversized frames/uploads, unbounded streams, and unconfirmed destructive operations.
- Gap: `VER-PI-007` proves a fail-closed project-trust coordinator, bounded Protobuf frames, and redacted stdio diagnostics only. User trust decisions, allowed-root and symbolic-link enforcement for host services, Node pairing, scoped grants, replay protection, production stream/backpressure limits, provider secret storage, artifact scans, and adversarial operational evidence remain incomplete.

## VER-PI-022 - 1.0 completeness and release audit

- Status: PLANNED
- Requirements: REQ-PI-005, REQ-PI-034
- Owner: final requirement status review, benchmark-to-requirement audit, release manifest verification, installation matrix, and production operational acceptance
- Planned evidence: Prove every Must requirement is Active with complete clauses, every benchmark record has a final disposition, all release identities and artifacts are immutable and verified, and no pi-web dependency or unsupported host runtime remains.
- Gap: P0 governance is complete and P1/P2 source implementation is substantially complete as scoped by `VER-PI-007`, but their full acceptance and independent release evidence remain incomplete. P3 through P11 are not complete, so this audit cannot pass from documentation, source foundations, or partial platform builds alone.
