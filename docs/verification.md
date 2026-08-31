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

## VER-PI-001 - Gateway request and SSE compatibility

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-003
- Owner: `test/workspace_gateway_test.dart` and `tool/pi_web_smoke.dart`
- Evidence: URL validation, Basic Auth header, credential-free URI, SSE heartbeat/data parsing, and read-only live `GET /api/sessions` against pi-web `0.8.11`.
- Scope limit: The live smoke is read-only; mutation semantics are owned by controlled ViewModel tests.

## VER-PI-002 - Workspace state machine

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-002, REQ-PI-003
- Owner: `test/workspace_view_model_test.dart`
- Evidence: connect/load/select, history parsing, prompt optimistic state, stream delta, abort, final authoritative refresh, reconnect, and password exclusion from JSON state.

## VER-PI-003 - Flutter UI interaction

- Status: PASS
- Requirements: REQ-PI-001, REQ-PI-002, REQ-PI-003
- Owner: `test/workspace_view_test.dart` and `test/application_test.dart`
- Evidence: routed application build, connection/session controls, session click, selected history rendering, composer controls, and application-owned/external Dio boundaries.

## VER-PI-004 - Desktop visual baseline

- Status: PASS
- Requirements: REQ-PI-002, REQ-PI-004
- Owner: `test/workspace_golden_test.dart` and `test/goldens/workspace_desktop.png`
- Evidence: fixed 1200 × 800 Flutter-rendered workspace layout with connection controls, sessions, selected messages, status line, and composer.
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

## VER-PI-007 - Local Direct and transport conformance runtime

- Status: PLANNED
- Requirements: REQ-PI-006, REQ-PI-009
- Owner: future pi-client and Pi Node integration/conformance suite
- Planned evidence: Run the same accepted Pi behavior fixtures through Local Direct and the unified transport contract while Friday Relay is unavailable.
- Gap: Pi Node, the versioned Pi protocol, Local Direct transport, and runtime conformance fixtures are not implemented in this repository.

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
- Owner: Flutter platform directories, `.metadata`, shared analyzer/tests, per-platform Flutter build commands, and `.github/workflows/ci.yml`
- Evidence: `.metadata` tracks Android, iOS, Linux, macOS, Web, and Windows; shared analysis and all tests pass; macOS Debug, Android Debug APK, iOS Debug without code signing, and standard JavaScript Web builds succeed. The CI source now assigns all six builds to native GitHub runners and keeps Web on JavaScript. iOS is fixed at 15.0 because ObjectBox requires it.
- Gap: The new GitHub-hosted matrix has not yet produced a merged-commit run, so Windows/Linux and hosted iOS/macOS evidence remain pending. Dart WebAssembly is blocked by `flutter_secure_storage_web 1.2.1`. Signing, store identity, production icons, and formal distribution remain unverified or missing; Preview workflow source is tracked by `VER-PI-014`, while hosted qualification/publication is tracked by `VER-PI-015`.

## VER-PI-012 - Landing Page and unsigned Preview source qualification

- Status: PASS
- Requirements: REQ-PI-004, REQ-PI-012
- Owner: `test/app_storage_test.dart`, `test/marketing_screenshot_test.dart`, `site/scripts/validate-built-site.mjs`, Astro checks, Flutter checks, and local macOS build inspection
- Evidence: Distribution-channel tests prove standard/Preview directory and key selection without changing Windows/Linux debug storage; the committed 1280 × 800 screenshot renders synthetic data with real Flutter fonts and icons, with cross-host raster variance bounded to 0.02%; brand generation is source-controlled; English and Chinese static routes build with exact metadata, base-aware assets, exact `v0.0.2` CTA, and no client JavaScript; Flutter analysis/tests and macOS build gates qualify the source.
- Scope limit: This PASS proves committed source and locally executable workflow logic only. It does not prove a pushed tag, public GitHub Release asset, GitHub-hosted workflow run, Pages deployment, notarization, Gatekeeper trust, or production-browser acceptance.

## VER-PI-013 - Public Release and GitHub Pages acceptance

- Status: PARTIAL
- Requirements: REQ-PI-012
- Owner: historical `.github/workflows/release-macos.yml@ac2b492`, current `.github/workflows/pages.yml`, GitHub Release evidence, and production manual accessibility/browser verification
- Evidence: Annotated `v0.0.2` resolves to `ac2b492cf595a715fc5e86f7e850ae5bcaf4c942`; Release build run `33308958703` passed generation, analysis, 35 tests, Debug build, unsigned Universal build, bundle/architecture/Gatekeeper checks, launch without Keychain `-34018`, packaging, tag creation, and Draft upload. Draft release `379262752` was reconciled after the historical workflow's tag lookup returned 404; the exact uploaded ZIP and SHA-256 were downloaded, checksum-verified, unpacked, and inspected before publication. Historical Pages run `33309764563` deployed the retired inherited path. Corrective Pages run `33356691081` successfully built and deployed `da201f2ae74970651bf4feab582e9a9f0965982c`; GitHub Pages readback reports `cname=pi.wyattcoder.top`, workflow builds, an approved certificate for `pi.wyattcoder.top`, and `https_enforced=true`. Host transaction `pi-pages-dns-20260831T042531Z-7bd4164b` created the exact DNS-only CNAME to `hu-wentao.github.io` and verified public propagation. Production checks observed HTTP `301`, HTTPS `200` for `/` and `/zh-cn/`, `200` for required assets, canonical `pi.wyattcoder.top` metadata, no retired root-relative `/pi-client/` asset paths, and a successful exact Release download.
- Gap: Safari WebDriver remains blocked until **Allow Remote Automation** is enabled. The corrected domain still needs representative Chrome visual/Lighthouse, VoiceOver, and 200% zoom acceptance; historical Lighthouse 94/100/100/100 applies only to the retired path.

## VER-PI-014 - Cross-platform Release contract and workflow source

- Status: PASS
- Requirements: REQ-PI-010, REQ-PI-011, REQ-PI-013
- Owner: `tool/release_contract.mjs`, `tool/release_metadata.mjs`, `tool/preview_artifacts.mjs`, Node release tests, workflow policy tests, actionlint, and local Flutter/Astro checks
- Evidence: Focused tests validate generic and monotonic SemVer resolution, active-Profile-independent tests plus immutable synthesized `0.0.2+2` compatibility, the future six-platform file/role/runtime-baseline contract, isolated platform Artifact sources, package filename-boundary evidence with contained Framework symlinks, deterministic manifest/checksum output, commit binding, missing/extra/wrong-source/duplicate/unsafe-name/zero-byte rejection, SHA-pinned Actions, exact-run bundle recovery, bounded Draft starter repair, concurrent-publication rejection, annotated-Tag Pages binding, recoverable fail-closed Tag/Draft/public states, and JavaScript Dart application policy. Local shared checks and actual unsigned Android split APK, no-codesign iOS archive, unsigned Universal macOS bundle, and standard JavaScript Web builds qualify the source without changing the public version.
- Scope limit: This PASS proves repository source and locally available hosts. It does not prove GitHub runner availability, Windows/Linux runtime output, a six-platform Actions bundle, a new Tag, or a public cross-platform Prerelease.

## VER-PI-015 - GitHub-hosted six-platform qualification and Preview publication

- Status: PLANNED
- Requirements: REQ-PI-010, REQ-PI-013
- Owner: `.github/workflows/ci.yml`, `.github/workflows/release-preview.yml`, GitHub Actions artifacts, GitHub Release readback, and Pages admission
- Planned evidence: One full commit passes the six-platform native runner matrix; `qualify` emits the exact `six-platform-preview-v1` bundle and matching stage evidence/manifest/checksums; an independently authorized `publish` creates the annotated Tag or resumes it with the original qualification run ID and exact retained bundle, verifies every existing, repaired starter, or newly uploaded Draft asset by service metadata and downloaded SHA-256, publishes the Prerelease, and dispatches Pages from that annotated Tag only after the complete asset set is public.
- Gap: The current release contract intentionally remains `macos-preview-v1` for immutable `v0.0.2`, and no next-version `qualify` or `publish` run is authorized or available yet. Formal platform signing and store delivery remain outside this Preview verification.
