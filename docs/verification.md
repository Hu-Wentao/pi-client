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

## VER-PI-005 - Contract, generation, analysis, tests, and macOS source build

- Status: PARTIAL
- Requirements: REQ-PI-004
- Owner: fr-mvvm-contract validator, build_runner, Flutter analyzer/test/build
- Evidence: `workspace.page.dart` passes contract and final phases; generated Freezed/JSON/typed-route files are current; analysis has no issues; all Flutter tests pass; macOS Debug `.app` builds and launches.
- Gap: This source-build evidence does not prove runtime Capsule installation, bundled-app end-to-end execution, artifact inspection, release signing, notarization, or supported distribution required by current `REQ-PI-004`.

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
- Absence evidence: Current tracked source and runtime composition contain only project-owned transport and Node paths; legacy endpoint credentials, compatibility adapters, and HTTP streaming tools are absent. Immutable `v0.0.2` historical evidence remains owned by `VER-PI-001` through `VER-PI-003`.
- Gaps: Protocol v0 remains unpublished and lacks production authentication/pairing, LAN and Friday transports, reconnect/replay completion, and a frozen v1 policy. A real provider-backed production prompt/abort, protected-project trust-decision UX, Node crash restart/session recovery, Capsule bundling on supported desktops, artifact-level external-runtime absence, and a public project-owned release are not yet evidenced.
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
- Gap: Windows and Linux native builds require their respective operating systems. Dart WebAssembly is blocked by `flutter_secure_storage_web 1.2.1`, which still imports unsupported `dart:html` and `dart:js` libraries. Signing, store identity, production icons, and supported distribution remain unverified or missing for the general platform matrix; historical release evidence is scoped separately by `VER-PI-012` and `VER-PI-013`.

## VER-PI-012 - Historical Landing Page and unsigned Preview source qualification

- Status: HISTORICAL PASS
- Requirements: REQ-PI-004, REQ-PI-012
- Owner: immutable `v0.0.2` source and release evidence
- Evidence: At the historical release commit, distribution-channel tests, the sanitized screenshot, brand generation, bilingual static routes, exact release CTA, Flutter checks, and macOS build gates passed within the recorded scope.
- Scope limit: This result applies only to immutable `v0.0.2` evidence. The current Landing Page is source-only, has no download CTA, and requires its own current site validation; this historical PASS does not satisfy current `REQ-PI-004` or `REQ-PI-012`.

## VER-PI-013 - Historical public Release and GitHub Pages acceptance

- Status: HISTORICAL PARTIAL
- Requirements: REQ-PI-012
- Owner: immutable `v0.0.2` tag, GitHub Release, workflow, and Pages evidence
- Evidence: Annotated `v0.0.2` resolves to `ac2b492cf595a715fc5e86f7e850ae5bcaf4c942`; recorded workflow, artifact, checksum, publication, production HTML, responsive Chrome, and Lighthouse checks passed within that release scope.
- Gap: The historical Safari, VoiceOver, zoom, HTTPS-enforcement, signing, notarization, and trust gaps remain unresolved for `v0.0.2`. They neither describe nor satisfy a future supported release.

## VER-PI-014 - Historical exploration governance integrity

- Status: SUPERSEDED
- Requirements: REQ-PI-005
- Owner: persistent mdq contracts, exact/negative queries, link checks, and historical source review
- Evidence: The initial exploratory classification and its project-owned requirement mappings were uniquely queryable when this check passed.
- Scope limit: This record is retained as historical governance evidence only; it does not define current scope or prove any Planned runtime feature or `1.0.0` completeness.

## VER-PI-015 - Project, session, history, and child-session behavior

- Status: PLANNED
- Requirements: REQ-PI-014, REQ-PI-015, REQ-PI-016, REQ-PI-030
- Owner: future Pi Node integration, Flutter ViewModel/Widget tests, deep-tree fixtures, and desktop E2E
- Planned evidence: Verify project selection/trust, workspace restore, session lifecycle, running/unread state, pagination, branches, edit-from-here, independent sessions, exports, destructive recovery, and existing child-session visibility.
- Gap: `VER-PI-007` proves the basic first-party session list/create/load foundation and Workspace cutover only. Project selection and trust UX, restore, naming, deletion, export, pagination, branch/fork behavior, child-session presentation, and the full P3 module split remain unimplemented or unevidenced.

## VER-PI-016 - Agent, composer, and rich conversation behavior

- Status: PLANNED
- Requirements: REQ-PI-017, REQ-PI-018, REQ-PI-020
- Owner: protocol fixtures, Pi Node runtime integration, focused Flutter concurrency/Widget tests, Golden tests, and desktop E2E
- Planned evidence: Verify command admission, streaming order, retry, compaction, queue, drafts, attachments, slash/skill/template/extension commands, file mentions, rich renderers, historical Shell/Process cards, deferred/oversized content, disconnect recovery, and stale-event rejection without claiming Shell execution.
- Gap: Basic typed prompt/abort admission, ordered session events, optimistic Workspace state, sequence-gap recovery, and several structured rich renderers have focused evidence. Retry, compaction, reload/steer/follow-up queues, full composer inputs, provider-backed production turns, and the complete P4 recovery matrix remain incomplete or unevidenced. Built-in and remote Shell are intentionally outside this `1.0` verification owner.

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

## VER-PI-019 - Skill, package, and standard extension interaction behavior

- Status: PLANNED
- Requirements: REQ-PI-027, REQ-PI-028, REQ-PI-029
- Owner: future Pi resource/package integration, Flutter settings tests, standard Extension dialog fixtures, and desktop E2E
- Planned evidence: Verify skill dormancy/search/install/update, package inventory/install/update/enable/disable/remove/reload, privilege disclosure, and Select/Confirm/Input/Editor/Notify/Status/Widget/Title/Editor Text lifecycle states including timeout, cancel, disconnect, stale response, and replacement.
- Gap: First-party resource/package services and standard Extension UI bridge are not implemented. Arbitrary custom terminal UI is a `1.1` outcome owned by `VER-PI-030`, not this `1.0` record.

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
- Requirements: REQ-PI-034
- Owner: final project-owned requirement status review, release manifest verification, installation matrix, and production operational acceptance
- Planned evidence: Prove every release-scoped Must requirement is Active with complete acceptance evidence, all release identities and artifacts are immutable and verified, no external runtime or compatibility dependency remains, and no unsupported host runtime is present.
- Gap: P0 governance is complete and P1/P2 source implementation is substantially complete as scoped by `VER-PI-007`, but their full acceptance and project-owned release evidence remain incomplete. P3 through P11 are not complete, so this audit cannot pass from documentation, source foundations, or partial platform builds alone.

## VER-PI-023 - Independent development Release contract and local tooling

- Status: PASS
- Requirements: REQ-PI-005, REQ-PI-006, REQ-PI-034, REQ-PI-035
- Evidence: `release/release.json`, `tool/release_contract.mjs`, `tool/release_metadata.mjs`, `tool/preview_artifacts.mjs`, `tool/homebrew_cask.mjs`, `tool/homebrew_tap.mjs`, `.gitattributes`, `dart_test.yaml`, `.github/workflows/ci.yml`, `.github/workflows/release-preview.yml`, `.github/workflows/release-desktop-candidates.yml`, and their Node test suites prove the `0.1.0+3` first-party publication-enabled Preview Profile, truthful desktop Capsule inclusion, Universal macOS target, mobile/Web connect-only roles, deterministic manifest/checksum behavior, exact recovery policy, Tap update idempotence, stable desktop signing denial, macOS-only Golden execution, Windows `<version>+<build>` file identity, and LF-preserved strict Release inputs.
- Scope: This is source and local policy/tooling evidence. It does not claim a remote qualification run, public Release, Tap mutation, installable `0.1.0`, or production acceptance.

## VER-PI-024 - Native six-platform qualification and publication recovery

- Status: PLANNED
- Requirements: REQ-PI-035
- Owner: GitHub Actions native runners, aggregate artifact verifier, Release readback, and Pages release-dispatch evidence
- Planned evidence: One exact commit produces all nine Preview application artifacts and manifest/checksums; desktop candidates pass Capsule verification and E2E; macOS is Universal; mobile/Web pass connect-only scans; retry uses the original qualification run; publication uses an annotated Tag, Draft-first readback, no overwrite, publish-last, Tap Cask readback, and a clean Homebrew smoke.
- Gap: The local Preview contract and workflow are implemented, but no remote `v0.1.0` qualification, public Release, Tap update, Homebrew installation, or release-bound Pages deployment is evidenced by this source change.

## VER-PI-025 - Independent Landing Page source and production identity

- Status: PASS
- Requirements: REQ-PI-036
- Evidence: Astro build and `site/scripts/validate-built-site.mjs` validate both ordinary source-only output and the release-bound Homebrew Preview output; Pages governance preserves canonical `pi.wyattcoder.top`; the current production endpoint remains the source-only variant until the exact public Preview Release is deployed.
- Scope: Local site evidence proves the conditional Homebrew section and its trust notice, not a remote binary release or production installation.

## VER-PI-026 - Homebrew public installation

- Status: PLANNED
- Requirements: REQ-PI-037
- Owner: the `independent-first-party-preview-v1` Release workflow, authorized public Tap repository, fresh Homebrew client, and exact asset readback
- Planned evidence: Generate Cask from explicit Tag/commit/asset/SHA-256 evidence, update and read back the authorized Tap change, install the exact Universal runtime-bearing asset, verify version, architecture, Runtime Capsule, quarantine, Gatekeeper behavior, and uninstall.
- Gap: Local source tests prove the fail-closed evidence contract and deterministic Tap update, but the public `v0.1.0` Release, Tap commit, clean Homebrew install, and production Pages deployment remain outstanding. Historical `v0.0.3` evidence in `VER-PI-028` does not satisfy this first-party Runtime Capsule requirement.

## VER-PI-027 - Historical v0.0.3 six-platform Preview delivery

- Status: HISTORICAL PASS
- Requirements: REQ-PI-010, REQ-PI-012
- Owner: immutable transitional `v0.0.3`, GitHub Actions runs `33371971805`, `33372753316`, and `33373334624`, Release readback, and Pages admission
- Evidence: Transitional commit `8f8d7e922cfe05f729c164d21ebb683e79ef1ac0` passed its `six-platform-preview-v1` qualification and six native runner jobs, retained the aggregate manifest/checksum bundle, created annotated Tag object `af5ccee0103c7fbe7108cb459de7adb3b2d10e12`, recovered publication from the original qualification run without rebuilding, downloaded and verified all 11 public assets, and deployed the exact-Tag Pages source.
- Scope limit: This evidence belongs only to the immutable `v0.0.3` transitional lineage. Its desktop artifacts declared no first-party Host runtime and it does not activate the current `0.1.0+3` Profile, satisfy current `VER-PI-024`, advertise a current download, or authorize any remote mutation.

## VER-PI-028 - Historical v0.0.3 unsigned Homebrew delivery

- Status: HISTORICAL PASS
- Requirements: REQ-PI-037
- Owner: immutable transitional `v0.0.3`, public asset checksum, `Hu-Wentao/homebrew-tap@7ec1023866376f83ddda6164b77cd1e2e673cdc4`, Homebrew install/uninstall, bundle inspection, `codesign`, and `spctl`
- Evidence: The historical `Pi-Client-0.0.3-macOS-universal.zip` resolved to SHA-256 `44ca05689220759ae1ca45bb7fbb8aa049874449604918f670d03d6bf53f5623`; the public Tap Cask matched those bytes, passed style, installed `/Applications/Pi Client.app`, preserved quarantine, exposed version `0.0.3` build `3` and Universal app/framework slices, retained ad-hoc/no-Team signing with expected Gatekeeper rejection, and uninstalled cleanly.
- Scope limit: This was an unsigned, unnotarized transitional Preview without the current first-party Runtime Capsule contract. It does not make Homebrew available for the independent build, does not satisfy `VER-PI-026`, and does not authorize a new Cask, Tag, Release, or deployment.

## VER-PI-029 - Trusted-project external-terminal behavior

- Status: PARTIAL
- Requirements: REQ-PI-038
- Owner: focused external-terminal launcher tests, Workspace/Project Browser Widget tests, full Flutter/Protocol/Pi Node suites, ACDD final validation, macOS/iOS/Android/Web JS/WebAssembly source builds, fake-executable process smoke, and connect-only artifact scans
- Evidence: The app-owned launcher accepts only `PiProjectIdentity`; macOS uses `/usr/bin/open -a Terminal <canonical-cwd>`, Windows uses `wt.exe -d <canonical-cwd>` with a no-command `cmd.exe` cwd fallback only when Windows Terminal is absent, and Linux uses a bounded terminal allowlist with exact working-directory argv, detached process mode, and `runInShell: false`. Tests cover spaces/metacharacters, canonical identity, no selected/untrusted project, unsupported platforms, redacted failure and unsupported feedback, stale project switch, keyboard activation, semantics, 200% text scale, conditional Web selection, and a real detached fake-executable launch without opening a visible terminal. Generated-source comparison, format, analyze, Flutter, Protocol, Pi Node, release/workflow/site, ACDD, mdq, link, duplicate-ID, and diff checks pass. Debug macOS, unsigned iOS, Android, Web JavaScript, and WebAssembly builds pass; Web executable scans reject known desktop terminal/process signatures, and Android/iOS/Web packaging scans remain free of Shell/PTY host and remote-command-executor paths.
- Gap: Windows and Linux native-runner launch behavior and actual installed-terminal availability still require their platform CI/manual acceptance. Automation intentionally does not open a user-visible Terminal.app, so macOS production Terminal availability remains a release-time smoke rather than this source check. `REQ-PI-038` therefore remains Planned.

## VER-PI-030 - 1.1 secure remote Shell and terminal bridge

- Status: PLANNED
- Requirements: REQ-PI-019
- Owner: future Protocol 1.x conformance, Pi Node Shell/PTY integration, Local Direct and Friday Transport E2E, mobile/Web remote-client tests, desktop native-runner tests, Extension terminal fixtures, adversarial security suites, and connect-only artifact scans
- Planned evidence: Verify project-scoped command and PTY admission, cwd/environment policy, stdout/stderr or terminal frames, input, resize, backpressure, reconnect/resume, writer lease, timeout, cancellation, process-tree termination, Windows Shell profiles, arbitrary Extension terminal UI, remote grants, replay rejection, E2EE opacity, and absence of local Shell/PTY host code from Android/iOS/Web.
- Gap: `1.0` deliberately contains no Shell request/event/stream, built-in executor, PTY, output capture, remote Shell, mobile/Web Shell, Windows Shell setting, or custom Extension terminal bridge. Implementation begins only under `PLAN-PI-008` after `1.0.0`.

## VER-PI-031 - Automatic Homebrew Cask synchronization

- Status: PLANNED
- Requirements: REQ-PI-037
- Owner: public Preview publish workflow, `HOMEBREW_TAP_TOKEN`, `Hu-Wentao/homebrew-tap`, Cask readback, and macOS Homebrew smoke runner
- Planned evidence: A public Preview publish binds one annotated Tag, exact commit, exact macOS Universal asset, and real SHA-256; the workflow updates only `Casks/pi-client.rb`, reads back identical bytes, installs the Cask on a clean macOS runner, verifies app version/build, both architectures, the first-party Runtime Capsule, quarantine, Gatekeeper behavior, and uninstall; later Preview releases repeat the same path with a new Cask version and checksum.
- Gap: The local deterministic generator, Tap updater, release workflow, and page gate are implemented, but no remote `v0.1.0` publish, Tap mutation, or fresh-client evidence has been completed.
