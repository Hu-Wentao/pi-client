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
- The current desktop source routes Workspace behavior through the app-owned `PiNodeApi`, a project-owned Protobuf transport, and a project-owned Pi Node that owns reviewed Pi SDK lifecycle, sessions, tools, project trust, and host operations.
- Connect-only clients consume a Pi Node transport and must not execute host operations locally.
- Current source contains only the project-owned runtime path. The immutable public `v0.0.2` Preview remains historical compatibility evidence only and is not a current-source adapter or an independent-release claim.

## BASE-PI-002 - Credential and payload handling

- Status: Active
- Review level: L6
- Current source has no user-configured runtime endpoint credential path or legacy HTTP streaming client path. Historical `v0.0.2` transport credentials remain release-scoped evidence and must not be reintroduced into current runtime state.
- Flutter serializable state must not contain reusable provider, Node, or Friday credentials. Project-owned Provider credentials remain Pi Node-owned when provider flows are implemented.
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

## BASE-PI-005 - Project-owned product boundary

- Status: Active
- Review level: L6
- Historical `v0.0.2` artifacts and their release-scoped evidence remain immutable historical facts, but exploratory comparisons have no ongoing authority.
- Current requirements, completeness, architecture, protocol, implementation, compatibility, runtime, build, deployment, and release are owned by this project.
- No platform may import an exploratory source's implementation or promote its routes, schemas, events, internal types, branding, screenshots, icons, or deployment artifacts into project-owned contracts or assets.
- Current work uses the project-owned Pi Node domain, typed `PiNodeApi`, and project-owned protocol; source cutover does not by itself prove a packaged or published release.

## BASE-PI-006 - Platform execution roles

- Status: Active
- Review level: L9
- macOS, Windows, and Linux are Agent-host-capable clients. Current source provides their shared lazy local-process composition through an app-owned `PiNodeApi`, desktop host controller, stdio Local Direct transport, and first-party Pi Node entrypoint.
- Android, iOS, and Web are remote-client-only: they must not embed Pi SDK, launch an Agent runtime, expose host tools, or claim host filesystem authority. Until a remote transport is configured, current composition fails explicitly instead of acquiring local host authority.
- `PlatformCapabilities` is the application-wide code authority for this role mapping; feature code must not duplicate ad hoc platform checks.
- A reproducible host-targeted runtime Capsule builder exists, but Agent-host capability and source composition do not prove that a Capsule is bundled into every desktop app, that Windows/Linux packages are qualified, or that an independent public release exists.

## BASE-PI-007 - Distribution and product-site integrity

- Status: Active
- Review level: L9
- The source version remains `0.0.2+2` during development, but no supported independent public release currently exists. Version metadata alone is not a release claim.
- The immutable public `v0.0.2` artifact is historical evidence only. The current Landing Page must not present it as the current product or offer a binary download.
- Historical unsigned-Preview storage and trust limitations remain release-scoped facts. Future packages must disclose their own exact signing, notarization, sandbox, storage, migration, platform, and architecture state.
- The Landing Page uses the Pi Client-owned SVG and sanitized Flutter screenshot. It must not use third-party product branding, production paths, credentials, private prompts, or real tool output.
- GitHub Pages may publish a source-only project status page. A release CTA may appear only after the exact supported artifact is authorized, public, and verified.
- A passing site build, release workflow, or source version does not prove publication, installation, or production acceptance.

## BASE-PI-008 - Product authority and 1.0 completeness

- Status: Active
- Review level: L9
- `DEC-017` establishes project-owned product authority; `docs/requirements.md` is the semantic authority for Pi Client outcomes, constraints, platform adaptations, and acceptance.
- `1.0.0` completeness requires every project-owned Must requirement in release scope to be Active and every acceptance clause to have appropriate verification evidence.
- Independently accepted requirements remain in scope until superseded through project governance; exploratory comparisons do not add, remove, or reinterpret product scope.
- Completeness never authorizes importing, copying, calling, deploying, or requiring an external runtime, source, route, schema, event, protocol, component, or artifact.
- `PLAN-PI-004` owns the P0-P11 implementation path; `PLAN-PI-002` remains the Friday Workspace parallel track, and `PLAN-PI-001` remains Superseded.
