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
