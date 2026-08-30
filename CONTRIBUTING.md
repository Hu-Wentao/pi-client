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

1. Install FVM, Bun `1.4.0`, and the native toolchain for your target platform.
2. Run `fvm install` and `fvm flutter pub get`.
3. For Landing Page work, run `cd site && bun install`.
4. Run `fvm flutter devices` and choose a device ID.
5. For legacy workspace smoke testing, start pi-web `0.8.11` on a URL that the client device can reach.
6. Run `fvm flutter run -d DEVICE_ID`.

Do not commit credentials, local pi sessions, provider data, developer-team identities, signing files, `.agents/` skill copies, `.fvm/`, `.dart_tool/`, build output, CocoaPods output, or captured user prompts.

## CONTRIB-002 - Architecture changes

- Status: Active

- Treat `lib/app/workspace/workspace.c.dart` as the current workspace source contract.
- Keep route ownership in `workspace.page.dart`, state and API work in `workspace.vm.dart`, rendering in `workspace.v.dart`, and transport adaptation in `workspace.srv.dart`.
- Treat `PiWebGateway` as a legacy adapter. Do not add new product or platform dependencies on pi-web.
- Use `PlatformCapabilities` as the only platform execution-role authority. macOS, Windows, and Linux may host an Agent; Android, iOS, and Web remain connect-only.
- Keep future Pi SDK and Agent host implementations behind a desktop-only host boundary. Mobile and Web builds must not import or package them.
- Use typed `go_router_builder` routes and keep host filesystem access outside presentation code.
- Add a separate queryable decision document and immutable decision tag when an implementation problem requires choosing among alternatives.

## CONTRIB-003 - Required checks

- Status: Active

Run the shared checks for every change:

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
```

Run the applicable platform builds on configured hosts:

```bash
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
fvm flutter build macos --debug
fvm flutter build web
fvm flutter build windows --debug
fvm flutter build linux --debug
```

Windows and Linux builds require their respective operating systems. Record unavailable build targets as verification gaps; do not infer success from Dart analysis alone. The current Web build uses the standard JavaScript target because `flutter_secure_storage_web 1.2.1` is not compatible with Dart WebAssembly.

For Landing Page changes, run:

```bash
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
- Keep release metadata synchronized across `pubspec.yaml`, `site/package.json`, `site/src/content/copy.ts`, release notes, and workflow-generated asset names.
- Do not manually move, overwrite, or delete a release tag or published asset. The manual Release workflow owns admission, Universal build checks, ZIP/checksum upload, and publication.
- The `unsigned-preview` channel is not signed, notarized, or effectively sandboxed. Do not remove its Gatekeeper disclosure, claim that its public fixed key is secret, or merge its preferences directory with the future signed channel.
- Publishing a Release, dispatching Pages, enabling Pages, pushing tags, and creating decision tags require explicit current authorization.
