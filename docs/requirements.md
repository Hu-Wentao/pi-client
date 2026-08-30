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

## REQ-PI-006 - Keep Local Direct independent

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user can connect a native Pi Client to their own local or LAN Pi Node without a Friday Relay identity, subscription, or available central service.
- Constraints: Local Direct uses a node-local pairing and authorization boundary; Friday Workspace entitlement must not disable or change an existing Local Direct capability.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: The Local Direct flow can be verified with Friday Relay unavailable and without a Friday account or paid entitlement.

## REQ-PI-007 - Provide one personal Friday Workspace

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: An authenticated Friday Relay user can access at most one personal Pi Workspace at its unique platform-managed origin.
- Constraints: Friday Relay owns identity, paid entitlement, Workspace ownership, hostname, and Node binding; Pi Client consumes only safe projections and does not infer authorization from billing or identity data.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: The client exposes anonymous, provisioning, subscription-required, active, suspended, and node-offline outcomes for the server-selected personal Workspace; another user, hostname, Workspace, or Node is denied.

## REQ-PI-008 - Use platform-safe Friday authentication

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: Native and WebAssembly Pi Clients can authenticate with Friday Relay without embedding a client secret or implementing Friday password, Passkey, or account-recovery logic.
- Constraints: Native authentication uses a system browser and public-client PKCE with credentials restricted to OS secure storage; WebAssembly uses canonical Friday authentication and a host-only Workspace session without browser-readable long-lived tokens.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: Platform adapters keep native and WebAssembly authentication surfaces separate, reject unapproved callbacks or handoffs, and expose only the safe session projection required by Pi Client.

## REQ-PI-009 - Use one private Pi transport contract

- Status: Planned
- Priority: Must
- Review level: L9
- Actor and goal: A user receives equivalent Pi product behavior whether the client reaches Pi Node through Local Direct or Friday Workspace.
- Constraints: Product features depend on one versioned Pi transport contract; Friday Relay may authorize and route remote access but must not persist, log, or decrypt Pi payloads; the E2EE protocol must use an evaluated standard rather than custom cryptography.
- Source: `PLAN-PI-002` and `DEC-013`.
- Acceptance: Direct and remote transports pass the same Pi behavior conformance suite, while remote evidence also proves grant binding, encrypted payload opacity, tamper rejection, and bounded revocation.
