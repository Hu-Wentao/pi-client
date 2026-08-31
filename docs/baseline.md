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
- Review level: L9
- Pi Client presentation and transport code must not read or rewrite Pi runtime directories directly.
- On an Agent-host-capable desktop, a first-party host integration owns Pi SDK lifecycle, sessions, tools, project trust, and host filesystem access behind the versioned Pi transport boundary.
- Connect-only clients consume that transport and must not execute host operations locally.
- `PiWebGateway` remains a legacy MVP adapter only; new product behavior must not add a runtime or build dependency on pi-web.

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
- Review level: L9
- One Flutter project targets Android, iOS, macOS, Windows, Linux, and Web.
- Flutter `3.41.6` is fixed by `.fvmrc`; platform directories and `.metadata` must remain aligned with that toolchain.
- macOS remains at 11.0 or newer and keeps a native title bar with a 1280 × 820 default content viewport and 900 × 640 minimum.
- iOS requires 15.0 or newer because the pinned ObjectBox Flutter library does not support the Flutter template's iOS 13.0 target.
- Android delegates its minimum SDK to the pinned Flutter toolchain; other minimum platform versions remain owned by generated platform configuration and require an explicit compatibility decision before they change.
- Project versioning starts at `0.0.1`; public compatibility surfaces remain unstable during `0.x`.

## BASE-PI-005 - Legacy upstream compatibility

- Status: Active
- Review level: L6
- Evidence for the legacy MVP adapter remains pinned to `agegr/pi-web` commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT).
- Pi-web is not the target runtime, protocol authority, or cross-platform host. No new platform may copy its implementation or promote its HTTP routes into the first-party Pi transport contract.
- Any maintenance of the legacy adapter requires focused compatibility tests; its future removal requires the migration and release notes already required by `DEC-012`.
- Pi-web branding, screenshots, icons, and substantial implementation are not treated as Pi Client-owned assets.

## BASE-PI-006 - Platform execution roles

- Status: Active
- Review level: L9
- macOS, Windows, and Linux are Agent-host-capable clients: they may connect to another host or use a future first-party integration to run Pi SDK and host an Agent.
- Android, iOS, and Web are remote-client-only: they may connect to an Agent host but must not embed Pi SDK, launch an Agent runtime, expose host tools, or claim host filesystem authority.
- `PlatformCapabilities` is the application-wide code authority for this role mapping; feature code must not duplicate ad hoc platform checks.
- Agent-host capability does not prove that the Pi SDK runtime is implemented or available in the current release.

## BASE-PI-007 - Archived Preview and product-site integrity

- Status: Active
- Review level: L9
- The immutable historical release identity remains `0.0.2+2` and `v0.0.2/Pi-Client-0.0.2-macOS-universal.zip`; its Tag, bytes, checksum, signing disclosures, storage boundary, and recorded deployment evidence must not be rewritten.
- The historical macOS Preview is not the current product entry. The Landing Page must not render its download URL, version, installation flow, signing warning, runtime adapter, or Workspace screenshot.
- The current product site presents Pi Client as an independent, open-source Flutter client with six platform targets. It may state the verified execution-role contract, but must label undelivered Host runtime and transport work as active development rather than current capability.
- Product-site visuals use Pi Client-owned brand and platform-role assets only. They must not contain production paths, credentials, private prompts, real tool output, archived runtime branding, or unverified feature claims.
- The canonical product-site origin is `https://pi.wyattcoder.top/`; English is served at `/` and Simplified Chinese at `/zh-cn/`. The inherited `https://wyattcoder.top/pi-client/` path is not an accepted production target.
- Historical release metadata may remain machine-readable for release verification without being imported by the rendered product page. Existing Pages Release-asset admission remains unchanged until a separate release-workflow decision replaces it.
- A passing local site build is source evidence only. Current publication requires an exact successful Pages run plus production canonical, content-exclusion, asset, HTTPS, and accessibility evidence.

## BASE-PI-008 - Cross-platform build and Preview release integrity

- Status: Active
- Review level: L6
- Pull requests and main changes use shared generation, formatting, analysis, test, release-contract, and site gates before platform builds; Android, iOS, macOS, Windows, Linux, and Web build on an appropriate native GitHub runner.
- `pubspec.yaml` is the version and build-number authority. `release/release.json` selects a versioned Artifact Profile but must not redefine version identity; the current `macos-preview-v1` remains bound to the immutable macOS-only `v0.0.2` history.
- A future six-platform Preview is built from one full commit, standardized by project-owned scripts, and aggregated before publication. Missing, extra, duplicate, symbolic-link, or zero-byte artifacts are release failures.
- Every aggregated Preview records product version, build number, full commit, Flutter version, platform, architecture, execution role, host-runtime inclusion and filename-boundary evidence, runtime baseline, signing state, installability, size, and SHA-256 in `artifact-manifest.json`; `SHA256SUMS` is a deterministic checksum projection.
- Android, iOS, and Web release metadata must remain `remote-client-only`; macOS, Windows, and Linux may remain `agent-host-capable`, but all artifacts record `hostRuntimeIncluded: false` until a separately accepted Pi SDK Host implementation exists. Current evidence scans package path names, contained framework symlink targets, and reserved future Host names; it does not claim semantic inspection of arbitrary binary contents.
- Preview signing state is fail-closed and explicit: Android Release must not fall back to Debug signing; iOS is no-codesign; macOS and Windows remain unsigned until their respective identity and trust workflows are configured. Web uses the standard JavaScript target until a separate WASM compatibility decision and evidence exist.
- Publishing remains a manual, separately authorized transition. The candidate version must be stable and monotonic. It creates an annotated immutable Tag only after qualification or resumes only the same annotated Tag/full commit with the original qualification run ID and exact retained aggregate bundle. A matching Draft may receive missing assets after existing bytes are verified; only one failed `starter/0-byte` expected asset may be deleted under a revalidated Draft boundary, while uploaded assets and every public Release are read-only. Draft publication and annotated-Tag-bound Pages deployment occur only after exact service-set and downloaded-byte verification.
