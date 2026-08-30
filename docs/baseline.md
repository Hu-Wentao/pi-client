---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>BASE-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>BASE-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    raw: {source: body}
  queries:
    baseline_by_id:
      when: {pattern: '^BASE-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level]
      expect: {max_record_lines: 40, max_record_bytes: 10240, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client durable baseline

Default review level: L6.

## BASE-PI-001 - Runtime ownership

- Status: Active
- Review level: L9
- Pi Client presentation and transport code must not read or rewrite Pi runtime directories directly.
- The current desktop source routes Workspace behavior through the app-owned `PiNodeApi`, a first-party Protobuf transport, and a first-party Pi Node that owns reviewed Pi SDK lifecycle, sessions, tools, project trust, and host operations.
- Connect-only clients consume a Pi Node transport and must not execute host operations locally.
- Current source contains no `PiWebGateway`, pi-web HTTP/SSE runtime, or pi-web smoke tool. The immutable public `v0.0.2` Preview remains historical compatibility evidence only and is not a current-source adapter or an independent-release claim.

## BASE-PI-002 - Credential and payload handling

- Status: Active
- Review level: L6
- Current source has no pi-web URL/password configuration and no Dio HTTP/SSE client or interceptor path. The historical `v0.0.2` Basic Auth handling remains release-scoped evidence and must not be reintroduced into first-party runtime state.
- Flutter serializable state must not contain reusable provider, Node, or Friday credentials. First-party Provider credentials remain Pi Node-owned when provider flows are implemented.
- Local Direct reserves stdout for bounded binary protocol frames; transport stderr is drained without decoding or application logging, and Pi Node diagnostics emit only stable redacted codes.
- Prompts, messages, tool output, project paths, credentials, and raw provider failures must not enter transport diagnostics, Relay payload logs, screenshots, or generated public evidence.

## BASE-PI-003 - Contract and state ownership

- Status: Active
- Review level: L6
- `WorkspacePage` owns the page-scoped `WorkspaceViewModel` provider.
- `workspace.c.dart` owns the stable contract and types; `.vm.dart` owns API/business state; `.v.dart` owns Widgets; `.srv.dart` owns transport adaptation.
- UI callbacks dispatch events for API/state work; the ViewModel owns no `BuildContext` or router calls.

## BASE-PI-004 - Platform and toolchain

- Status: Active
- Review level: L9
- One Flutter project targets Android, iOS, macOS, Windows, Linux, and Web.
- Flutter `3.41.6` is fixed by `.fvmrc`; platform directories and `.metadata` must remain aligned with that toolchain.
- macOS remains at 11.0 or newer and keeps a native title bar with a 1280 × 820 default content viewport and 900 × 640 minimum.
- iOS requires 15.0 or newer because the pinned ObjectBox Flutter library does not support the Flutter template's iOS 13.0 target.
- Android delegates its minimum SDK to the pinned Flutter toolchain; other minimum platform versions remain owned by generated platform configuration and require an explicit compatibility decision before they change.
- Project versioning starts at `0.0.1`; public compatibility surfaces remain unstable during `0.x`.

## BASE-PI-005 - Legacy upstream compatibility

- Status: Active
- Review level: L6
- Historical `v0.0.2` compatibility evidence and the bounded completeness snapshot remain pinned to `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`v0.8.11`, MIT).
- The current source tree has removed the legacy gateway, its URL/password UI, Dio HTTP/SSE runtime, compatibility tests, and smoke tool. Published `v0.0.2` artifacts and their evidence remain immutable historical facts.
- Pi-web is not the target runtime, semantic requirement authority, protocol authority, or cross-platform host. No platform may copy its implementation or promote routes, schemas, events, or internal types into first-party contracts.
- Post-`v0.0.2` work uses the project-owned Pi Node domain, typed `PiNodeApi`, and unpublished first-party protocol; this source cutover does not by itself prove a packaged or published independent release.
- Pi-web branding, screenshots, icons, substantial implementation, and deployment artifacts are not treated as Pi Client-owned assets.

## BASE-PI-006 - Platform execution roles

- Status: Active
- Review level: L9
- macOS, Windows, and Linux are Agent-host-capable clients. Current source provides their shared lazy local-process composition through an app-owned `PiNodeApi`, desktop host controller, stdio Local Direct transport, and first-party Pi Node entrypoint.
- Android, iOS, and Web are remote-client-only: they must not embed Pi SDK, launch an Agent runtime, expose host tools, or claim host filesystem authority. Until a remote transport is configured, current composition fails explicitly instead of acquiring local host authority.
- `PlatformCapabilities` is the application-wide code authority for this role mapping; feature code must not duplicate ad hoc platform checks.
- A reproducible host-targeted runtime Capsule builder exists, but Agent-host capability and source composition do not prove that a Capsule is bundled into every desktop app, that Windows/Linux packages are qualified, or that an independent public release exists.

## BASE-PI-007 - Preview distribution and product-site integrity

- Status: Active
- Review level: L9
- The current public version target is `0.0.2+2`; the macOS app name is `Pi Client`, and the release asset identity is `v0.0.2/Pi-Client-0.0.2-macOS-universal.zip`.
- The macOS Preview is a Universal `arm64 + x86_64` ZIP, not a signed, notarized, sandbox-trusted, or DMG distribution. User-facing surfaces must disclose that boundary before download or installation.
- Unsigned Preview storage uses `fr_storage_unsigned_preview` and a fixed public key that provides no secrecy; standard signed desktop storage remains in `fr_storage` with platform secure storage. Preview preferences do not automatically migrate to the signed channel.
- The Landing Page uses the Pi Client-owned SVG and sanitized Flutter screenshot. It must not use Flutter/pi-web branding, production paths, credentials, private prompts, or real tool output.
- GitHub Pages may deploy only while its exact current-version GitHub Release asset is public. A passing local site build is not publication evidence.
- Current pi-web compatibility is transitional and does not authorize a WebAssembly build or weaken the planned independent, versioned Pi SDK/transport boundary.

## BASE-PI-008 - Product authority and 1.0 completeness

- Status: Active
- Review level: L9
- The user-approved `1.0.0` completeness baseline is the user-visible and reachable capability set observed in pi-web `v0.8.11` at commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`.
- `docs/requirements.md` is the semantic authority for Pi Client outcomes, constraints, platform adaptations, and acceptance; `docs/benchmark.md` is a bounded omission check only.
- Hidden, disabled, test-only, or unreachable behavior is not strict parity. Built-in subagent creation is excluded because the fixed snapshot hard-disables runtime creation and exposes no ordinary Settings path to its configuration; existing child-session visibility remains in scope.
- A later pi-web release does not change Pi Client scope without a new project decision and requirement change.
- Completeness never authorizes importing, copying, calling, deploying, or requiring pi-web runtime, source, routes, schemas, events, protocol, components, or artifacts.
- `PLAN-PI-004` owns the P0-P11 implementation path; `PLAN-PI-002` remains the Friday Workspace parallel track, and `PLAN-PI-001` remains Superseded.
