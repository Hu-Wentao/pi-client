---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: mixed}
  records:
    boundary: {source: heading, levels: [2], pattern: '^(?P<id>CONTRIB-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$'}
    key: {source: heading, pattern: '^(?P<id>CONTRIB-[0-9]{3})(?:[ ：:-]+(?P<title>.*))?$', group: id}
  fields:
    title: {source: heading, group: title}
    status: {source: label, labels: [Status, 状态]}
    raw: {source: body}
  queries:
    section_by_id:
      when: {pattern: '^CONTRIB-[0-9]{3}$'}
      match: {source: key, operator: eq}
      select: [title, status]
      expect: {max_record_lines: 70, max_record_bytes: 12288, structured: true, min_confidence: 1.0}
  maintenance: {query_contract: {mode: locked}}
---
# Contributing to Pi Client

## CONTRIB-001 - Development setup

- Status: Active

1. Install FVM.
2. Run `fvm install` and `fvm flutter pub get`.
3. Start pi-web `0.8.11` on loopback for live smoke testing.
4. Run `fvm flutter run -d macos`.

Do not commit credentials, local pi sessions, provider data, `.agents/` skill copies, `.fvm/`, `.dart_tool/`, build output, CocoaPods output, or captured user prompts.

## CONTRIB-002 - Architecture changes

- Status: Active

- Treat `lib/app/workspace/workspace.c.dart` as the source contract.
- Keep route ownership in `workspace.page.dart`, state and API work in `workspace.vm.dart`, rendering in `workspace.v.dart`, and pi-web transport in `workspace.srv.dart`.
- Use typed `go_router_builder` routes.
- Keep pi-web as the runtime and session authority; do not read or mutate pi files directly from Flutter.
- Add a separate queryable decision document and immutable decision tag when an implementation problem requires choosing among alternatives.

## CONTRIB-003 - Required checks

- Status: Active

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
fvm flutter build macos --debug
```

When the UI intentionally changes, review the rendered result before running:

```bash
fvm flutter test test/workspace_golden_test.dart --update-goldens
```

## CONTRIB-004 - Pull request scope

- Status: Active

Keep changes focused. Update requirements, baselines, comparison scope, tests, generated files, and compatibility notes only when the behavior they own changes. List breaking changes explicitly; Pi Client remains unstable while its version is `0.x`.
