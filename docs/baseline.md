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
- Review level: L6
- Pi-web owns pi session files, runtime processes, model/provider configuration, tools, project trust, and filesystem access.
- Pi Client must use the pi-web HTTP/SSE boundary and must not read or rewrite `~/.pi/agent` directly.
- Friday-swarm and friday-relay remain outside the MVP runtime.

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
- Review level: L6
- The MVP target is macOS 11.0 or newer.
- Flutter `3.41.6` is fixed by `.fvmrc`.
- The native content viewport defaults to 1280 × 820 with a 900 × 640 minimum; the system title bar remains native.
- Project versioning starts at `0.0.1`; public compatibility surfaces remain unstable during `0.x`.

## BASE-PI-005 - Upstream compatibility

- Status: Active
- Review level: L6
- Observable behavior and protocol evidence are pinned to `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT).
- Pi-web's HTTP routes are not declared as a stable public API. Upstream movement requires an explicit compatibility decision, focused adapter tests, live smoke, and release notes.
- Pi-web branding, screenshots, icons, and substantial implementation are not treated as Pi Client-owned assets.
