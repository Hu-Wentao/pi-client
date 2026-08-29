---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>REQ-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>REQ-PI-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    priority: {source: label, labels: [Priority, 优先级]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    raw: {source: body}
  queries:
    requirement_by_id:
      when: {pattern: '^REQ-PI-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, priority, review_level]
      expect: {max_record_lines: 45, max_record_bytes: 10240, structured: true, min_confidence: 1.0}
    requirements_by_status:
      match: {source: field, field: status, operator: eq}
      select: [title, priority, review_level]
      expect: {max_total_bytes: 65536, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client requirements

Default review level: L6. Requirements derived directly from the user-provided MVP objective are L9.

## REQ-PI-001 - Connect to the local pi-web gateway

- Status: Active
- Priority: Must
- Review level: L9
- Actor and goal: A user can configure a reachable pi-web server and know whether the client connected.
- Constraints: The default is loopback; an optional pi-web Basic Auth password must not be persisted, placed in URLs, or logged.
- Source: MVP plan plus `DEC-004`.
- Acceptance: The UI exposes URL/password inputs, connection progress, success, failure, and retry; the live smoke tool reads `GET /api/sessions` from pi-web `0.8.11`.

## REQ-PI-002 - Find and continue pi sessions

- Status: Active
- Priority: Must
- Review level: L9
- Actor and goal: A user can refresh session summaries, select a session, and read its visible message history.
- Constraints: Session data remains authoritative in pi-web; the client does not read pi JSONL files directly.
- Source: MVP plan, pi-web feature baseline, and `DEC-005`.
- Acceptance: Session loading, empty, error, selected, and message-history states are observable; switching selection discards stale loads and attaches the selected SSE stream.

## REQ-PI-003 - Run and stop the agent

- Status: Active
- Priority: Must
- Review level: L9
- Actor and goal: A user can create a session for an absolute cwd, submit a prompt, observe incremental output, and stop the active run.
- Constraints: Pi-web owns runtime execution; prompt transport uncertainty must not be reported as definite rejection unless pi-web says `accepted: false`.
- Source: MVP plan, pi-web behavior, and `DEC-005`.
- Acceptance: Focused tests cover create/send/stream/final-refresh/abort behavior, and SSE disconnect enters reconnecting state and starts a replacement stream for the still-selected session.

## REQ-PI-004 - Provide reproducible macOS delivery

- Status: Active
- Priority: Must
- Review level: L9
- Actor and goal: A contributor can build, test, and run the MVP on the chosen target platform.
- Constraints: Flutter is fixed with FVM; the initial version is `0.0.1`; minimum macOS is 11.0.
- Source: MVP plan, `DEC-002`, and `DEC-008`.
- Acceptance: FVM configuration, lockfile, generated sources, tests, a Debug `.app`, and run/build instructions are present.

## REQ-PI-005 - Preserve a bounded open-source comparison

- Status: Active
- Priority: Must
- Review level: L9
- Actor and goal: Reviewers can identify the exact pi-web source, license, implemented P0 boundary, and deferred differences.
- Constraints: No friday-swarm or friday-relay dependency; no copied pi-web branding or production data.
- Source: MVP plan, `DEC-003`, and `DEC-005`.
- Acceptance: README, LICENSE, benchmark, differences, contribution instructions, and per-choice decision records are present and queryable.
