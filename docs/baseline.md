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
- On an Agent-host-capable desktop, a first-party host integration owns Pi SDK lifecycle, sessions, tools, project trust, and host filesystem access behind the versioned Pi transport boundary.
- Connect-only clients consume that transport and must not execute host operations locally.
- `PiWebGateway` remains a legacy MVP adapter only; new product behavior must not add a runtime or build dependency on pi-web.

## BASE-PI-002 - Credential and payload handling

- Status: Active
- Review level: L6
- The optional Basic Auth password exists only in private ViewModel/service memory for the current page lifecycle.
- The password must not enter route state, `WorkspaceModel`, JSON generation, URL user-info, repository files, screenshots, or logs.
- Request/response headers and bodies remain disabled in Dio logging because they can contain credentials, prompts, messages, tool output, and project data.

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
- Evidence for the legacy MVP adapter remains pinned to `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT).
- Pi-web is not the target runtime, protocol authority, or cross-platform host. No new platform may copy its implementation or promote its HTTP routes into the first-party Pi transport contract.
- Any maintenance of the legacy adapter requires focused compatibility tests; its future removal requires the migration and release notes already required by `DEC-012`.
- Pi-web branding, screenshots, icons, and substantial implementation are not treated as Pi Client-owned assets.

## BASE-PI-006 - Platform execution roles

- Status: Active
- Review level: L9
- macOS, Windows, and Linux are Agent-host-capable clients: they may connect to another host or use a future first-party integration to run Pi SDK and host an Agent.
- Android, iOS, and Web are remote-client-only: they may connect to an Agent host but must not embed Pi SDK, launch an Agent runtime, expose host tools, or claim host filesystem authority.
- `PlatformCapabilities` is the application-wide code authority for this role mapping; feature code must not duplicate ad hoc platform checks.
- Agent-host capability does not prove that the Pi SDK runtime is implemented or available in the current release.
