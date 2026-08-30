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
# pi-web comparison baseline

Reference: `https://github.com/agegr/pi-web`, commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948`, package `0.8.11`, MIT.

## BENCH-PI-001 - Session workspace

- Status: Verified
- Disposition: Implemented
- Pi-web behavior: list sessions with project/cwd context and running state; open visible history.
- Pi Client scope: load/refresh summaries, select one session, render core message roles, preserve last successful data on retryable errors.
- Evidence owner: service, ViewModel, Widget, app, live gateway smoke.

## BENCH-PI-002 - New session and prompt lifecycle

- Status: Verified
- Disposition: Implemented
- Pi-web behavior: create a runtime from cwd, send prompt commands, observe events, abort.
- Pi Client scope: `ensure_session`, prompt, abort, optimistic user message, SSE deltas, final authoritative reload, reconnect for the selected session.
- Evidence owner: `workspace_view_model_test.dart` and `workspace_gateway_test.dart`.

## BENCH-PI-003 - Connection and authentication

- Status: Verified
- Disposition: Implemented
- Pi-web behavior: loopback by default; optional Basic Auth with username `pi`.
- Pi Client scope: configurable http(s) base URL and password, URL validation, Basic Auth header, no credential URL/log/model persistence.
- Evidence owner: gateway and ViewModel tests plus security baseline.

## BENCH-PI-004 - File, Git, and worktree tools

- Status: Deferred
- Disposition: Deferred candidate
- Pi-web behavior: file browser/upload/watch/preview, Git status/diff, and worktree operations.
- Pi Client scope: not implemented in MVP.
- Reason: these features require additional filesystem, upload, preview, and destructive-operation contracts beyond the core agent loop.
- Governance: This comparison entry is a candidate only; implementation requires explicit acceptance in a current requirement or plan.

## BENCH-PI-005 - Models, skills, plugins, and subagents

- Status: Deferred
- Disposition: Deferred candidate
- Pi-web behavior: provider login/API keys, model discovery/testing, skill/plugin management, subagents, system prompt, and tool selection.
- Pi Client scope: not implemented in MVP.
- Reason: the MVP assumes pi-web/pi is already configured and does not copy credential-management surfaces.
- Governance: This comparison entry is a candidate only; implementation requires explicit acceptance in a current requirement or plan.

## BENCH-PI-006 - Advanced conversation features

- Status: Deferred
- Disposition: Deferred candidate
- Pi-web behavior: branch/fork, rename/delete/export, compaction, queues, extension UI, bash, rich Markdown/media, notifications, and multi-panel file tabs.
- Pi Client scope: historical bash/tool text can render, but advanced controls and rich presentation are deferred.
- Reason: P0 freezes the smallest complete find/continue/run/stop flow.
- Governance: This comparison entry is a candidate only; implementation requires explicit acceptance in a current requirement or plan.

## BENCH-PI-007 - Platform matrix

- Status: Superseded
- Disposition: Project-owned requirement
- Pi-web behavior: browser/PWA layouts across desktop and mobile browsers.
- Pi Client scope: Android, iOS, macOS, Windows, Linux, and Web are first-party targets; macOS, Windows, and Linux are Agent-host-capable, while Android, iOS, and Web are connect-only clients.
- Reason: the platform matrix now comes directly from `DEC-014`, `REQ-PI-010`, and `REQ-PI-011`, not from comparison with pi-web.
- Governance: This record remains historical comparison context only. PWA behavior is still deferred unless a separate project requirement accepts it.
