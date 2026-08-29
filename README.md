---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: machine}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>DOC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>DOC-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    review_level: {source: label, labels: [Review level, 评审级别]}
    raw: {source: body}
  queries:
    section_by_id:
      when: {pattern: '^DOC-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status, review_level]
      expect: {max_record_lines: 80, max_record_bytes: 16384, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client

Default review level: L6. The MVP objective and explicit exclusions are L9; implementation details independently reconciled with the project contracts are L3.

## DOC-001 - Overview

- Status: Active
- Review level: L6

Pi Client is a native Flutter macOS client for the [pi coding agent](https://github.com/earendil-works/pi). It connects to a separately running [pi-web](https://github.com/agegr/pi-web) process and reuses pi-web's ownership of local sessions, models, tools, and project access.

The MVP is an independent implementation based on observable behavior from `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT).

Implemented P0 behavior:

- Configure a pi-web URL and optional Basic Auth password.
- Check the connection and load/refresh session summaries.
- Create a session from an absolute working directory.
- Open session history and render user, assistant, tool, custom, and bash messages.
- Submit prompts, receive incremental SSE output, reconnect the selected session stream, and stop an active run.
- Render loading, empty, connection-error, conversation-error, streaming, and reconnecting states.

## DOC-002 - Requirements

- Status: Active
- Review level: L6

- macOS 11.0 or newer.
- [FVM](https://fvm.app/) with Flutter `3.41.6`.
- A locally reachable pi-web `0.8.11` service. The default URL is `http://127.0.0.1:30141`.
- A configured pi model provider when prompts should execute.

Start pi-web:

```bash
npx @agegr/pi-web@0.8.11 --no-open
```

If pi-web uses `PI_WEB_PASSWORD`, enter that password in Pi Client. Pi-web's Basic Auth username is fixed to `pi`.

## DOC-003 - Run

- Status: Active
- Review level: L3

```bash
fvm install
fvm flutter pub get
fvm flutter run -d macos
```

Override the initial server URL without storing credentials:

```bash
fvm flutter run -d macos \
  --dart-define=PI_CLIENT_BASE_URL=http://127.0.0.1:30141
```

The password is accepted only through the runtime connection form. It is not serialized into `WorkspaceModel`, written to storage, added to URLs, or logged by the Dio interceptor.

## DOC-004 - Validate

- Status: Active
- Review level: L3

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
fvm flutter build macos --debug
```

Run the read-only live gateway smoke check while pi-web is running:

```bash
fvm dart run tool/pi_web_smoke.dart http://127.0.0.1:30141
```

The desktop layout screenshot baseline is `test/goldens/workspace_desktop.png`. Regenerate it only after an intentional UI review:

```bash
fvm flutter test test/workspace_golden_test.dart --update-goldens
```

## DOC-005 - Architecture

- Status: Active
- Review level: L3

```text
lib/main.dart                         application and storage initialization
lib/app_router.dart                   typed route aggregation
lib/core/                             Env, Theme, Locale, Dio, root providers
lib/app/workspace/workspace.c.dart    source contract and immutable state
lib/app/workspace/workspace.page.dart typed route and page-owned provider
lib/app/workspace/workspace.vm.dart   HTTP/SSE interaction state machine
lib/app/workspace/workspace.v.dart    desktop workspace UI
lib/app/workspace/workspace.srv.dart  pi-web HTTP/SSE adapter
test/                                 service, ViewModel, Widget, app, and Golden evidence
```

Ownership boundary:

- pi-web owns session files, pi runtime processes, models, tools, worktree/file security, and provider credentials.
- Pi Client owns connection input, presentation state, request adaptation, SSE reconnection, and Flutter rendering.
- The client does not read `~/.pi/agent` directly and does not embed or reimplement the Node pi runtime.

## DOC-006 - Security and remote access

- Status: Active
- Review level: L6

Pi-web exposes a high-privilege coding agent. Keep it bound to loopback by default. For remote access, follow pi-web's guidance: use a strong password plus trusted HTTPS reverse proxy or VPN. Basic Auth alone does not encrypt transport.

Pi Client disables Dio request headers, request bodies, response headers, and response bodies in application logs. Do not add credential, prompt, session payload, or tool-result logging.

## DOC-007 - MVP differences

- Status: Active
- Review level: L6

Deferred from pi-web `0.8.11`:

- File explorer, upload, previews, and Git diff.
- Git worktree creation/switch/removal.
- Model/provider login, model testing, and model selection.
- Plugin, skill, subagent, system-prompt, and tool configuration.
- Session rename, delete, export, branching, compaction controls, queued steering/follow-up, extension dialogs, rich Markdown/media, notifications, and PWA behavior.
- Android, iOS, Web, Windows, and Linux release targets.

See `docs/benchmark.md` for the frozen comparison and acceptance boundary.

## DOC-008 - Project governance

- Status: Active
- Review level: L6

- Requirements: `docs/requirements.md`
- Durable baselines: `docs/baseline.md`
- pi-web comparison and known differences: `docs/benchmark.md`
- Verification ownership: `docs/verification.md`
- Individual recommended-option records: `docs/decisions/`
- Contribution workflow: `CONTRIBUTING.md`

Every accepted option has its own Markdown record and immutable `decision/NNN-*` Git tag.

## DOC-009 - License and attribution

- Status: Active
- Review level: L6

Pi Client is licensed under MIT; see `LICENSE`.

Pi-web is Copyright (c) 2026 agegr and licensed under MIT. This repository does not copy the pi-web name, screenshots, icons, or substantial source implementation as project-owned assets. Its pinned source is used as behavioral and protocol evidence.
