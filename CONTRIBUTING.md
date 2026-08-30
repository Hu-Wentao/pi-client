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

1. Install FVM and Bun `1.4.0`.
2. Run `fvm install` and `fvm flutter pub get`.
3. Run `cd site && bun install` for Landing Page work.
4. Start pi-web `0.8.11` on loopback for live smoke testing.
5. Run `fvm flutter run -d macos`.

Do not commit credentials, local pi sessions, provider data, `.agents/` skill copies, `.fvm/`, `.dart_tool/`, build output, CocoaPods output, or captured user prompts.

## CONTRIB-002 - Architecture changes

- Status: Active

- Treat `lib/app/workspace/workspace.c.dart` as the source contract.
- Keep route ownership in `workspace.page.dart`, state and API work in `workspace.vm.dart`, rendering in `workspace.v.dart`, and pi-web transport in `workspace.srv.dart`.
- Use typed `go_router_builder` routes.
- Treat pi-web `0.8.11` only as the current Preview's transitional runtime and session authority; do not read or mutate pi files directly from Flutter, and do not expand pi-web into the long-term product identity.
- Add a separate queryable decision document and immutable decision tag when an implementation problem requires choosing among alternatives.

## CONTRIB-003 - Required checks

- Status: Active

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
fvm flutter build macos --debug
cd site
bun install --frozen-lockfile
ASTRO_TELEMETRY_DISABLED=1 bun run check
ASTRO_TELEMETRY_DISABLED=1 bun run build
bun run validate
```

Run `node tool/release_metadata.mjs` whenever the app version, release asset, or Landing Page download CTA changes.

When the UI intentionally changes, review the rendered result before running:

```bash
fvm flutter test test/workspace_golden_test.dart --update-goldens
```

## CONTRIB-004 - Pull request scope

- Status: Active

Keep changes focused. Update requirements, baselines, comparison scope, tests, generated files, and compatibility notes only when the behavior they own changes. List breaking changes explicitly; Pi Client remains unstable while its version is `0.x`.

## CONTRIB-005 - Brand, screenshot, and release maintenance

- Status: Active

- Edit `assets/brand/pi-client-mark.svg` as the product-mark source, then run `cd site && bun run brand`. Commit the generated favicon, social card, and every macOS App Icon size together.
- Generate the marketing screenshot with `fvm flutter test test/marketing_screenshot_test.dart --update-goldens`. Use only synthetic paths, sessions, prompts, and output; inspect the final pixels before committing.
- Keep release metadata synchronized across `pubspec.yaml`, `site/src/content/copy.ts`, release notes, and workflow-generated asset names.
- Do not manually create, move, overwrite, or delete a release tag or published asset. The manual Release workflow owns admission, Universal build checks, ZIP/checksum upload, and publication.
- The `unsigned-preview` channel is not signed or notarized. Do not remove its Gatekeeper disclosure, claim that its public fixed key is secret, or merge its preferences directory with the future signed channel.
- Publishing a Release, dispatching Pages, enabling Pages, pushing tags, and creating the `DEC-014` decision tag require explicit current authorization.
