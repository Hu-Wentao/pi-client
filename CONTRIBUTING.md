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

1. Install FVM, Bun `1.4.0`, Node.js `22.19.0`, and the native toolchain for your target platform.
2. Run `fvm install` and `fvm flutter pub get`.
3. Run `(cd protocol && bun install --frozen-lockfile)`.
4. Run `(cd node && bun install --frozen-lockfile && bun run build)`.
5. For Landing Page work, run `(cd site && bun install --frozen-lockfile)`.
6. Run `fvm flutter devices` and choose a desktop device ID.
7. Follow [Run a desktop development build](README.md#run-a-desktop-development-build). A normal source build contains no runtime Capsule, so development requires the documented explicit local process configuration.

Do not commit credentials, local pi sessions, provider data, developer-team identities, signing files, `.agents/` skill copies, `.fvm/`, `.dart_tool/`, build output, CocoaPods output, or captured user prompts.

## CONTRIB-002 - Architecture changes

- Status: Active

- Treat `lib/app/workspace/workspace.c.dart` as the current workspace source contract.
- Keep route ownership in `workspace.page.dart`, state and API work in `workspace.vm.dart`, rendering in `workspace.v.dart`, and transport adaptation in `workspace.srv.dart`.
- Keep Pi Client transport on the project-owned protocol. Do not inherit routes, payloads, names, or types from consulted clients.
- Use `PlatformCapabilities` as the only platform execution-role authority. macOS, Windows, and Linux may host the first-party Pi Node; Android, iOS, and Web remain connect-only.
- Keep Pi Node and runtime Capsule implementations behind a desktop-only host boundary. Mobile and Web builds must not import or package them.
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

Windows and Linux builds require their respective operating systems. Record unavailable build targets as verification gaps; do not infer success from Dart analysis alone. CI qualifies both standard JavaScript and WebAssembly Web builds, and both must remain connect-only.

For Landing Page changes, run:

```bash
cd site
bun install --frozen-lockfile
ASTRO_TELEMETRY_DISABLED=1 bun run check
ASTRO_TELEMETRY_DISABLED=1 bun run build
bun run validate
PUBLIC_HOMEBREW_PREVIEW_ENABLED=true ASTRO_TELEMETRY_DISABLED=1 bun run build
PUBLIC_HOMEBREW_PREVIEW_ENABLED=true bun run validate
```

When the UI intentionally changes, review the rendered result before running:

```bash
fvm flutter test test/workspace_golden_test.dart --update-goldens
```

## CONTRIB-004 - Pull request scope

- Status: Active

Keep changes focused. Update requirements, baselines, comparison scope, tests, generated files, and compatibility notes only when the behavior they own changes. List breaking changes explicitly; Pi Client remains unstable while its version is `0.x`.

## CONTRIB-005 - Brand, screenshot, and release maintenance

- Status: Active

- Edit `assets/brand/pi-client-mark.svg` and `assets/brand/social-card.svg` as the brand sources, then run `cd site && bun run brand`. Commit the generated product mark, social card, and every macOS App Icon size together.
- Flutter Golden fixtures remain product-behavior evidence, not Landing Page assets. Update them only after intentional UI review, and keep all fixture paths, sessions, prompts, and output synthetic.
- Keep release metadata synchronized across `pubspec.yaml`, `site/package.json`, `release/release.json`, release notes, artifact contracts, and workflow-generated asset names. The current `0.1.0+3` identity uses the `independent-first-party-preview-v1` publication-enabled Preview Profile.
- Desktop Preview artifacts must contain the exact first-party Runtime Capsule and pass bundle verification. The macOS Homebrew artifact must be Universal and ad-hoc signed; Android, iOS, JavaScript Web, and WebAssembly remain connect-only.
- Do not manually move, overwrite, delete, or reuse a release tag or published asset. The aggregate Preview workflow binds one exact commit, publishes the Release last, and updates the Tap only after public asset readback.
- Homebrew Cask generation requires exact public Tag, commit, asset, SHA-256, Universal architecture, and runtime evidence. The release workflow updates `Hu-Wentao/homebrew-tap/Casks/pi-client.rb` with the dedicated `HOMEBREW_TAP_TOKEN`.
- Publishing a Release, dispatching release-bound Pages, enabling Pages, updating a Tap, pushing tags, and creating decision tags require explicit current authorization; the Preview release workflow also requires the configured Tap credential.
