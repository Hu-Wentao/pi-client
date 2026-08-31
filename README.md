---
mdq:
  version: 2
  dialect: gfm
  actors: {read: mixed, write: mixed}
  records:
    boundary: {source: heading, levels: [2]}
    key: {source: heading}
  fields:
    title: {source: heading}
    raw: {source: body}
  maintenance: {query_contract: {mode: locked}}
---
# Pi Client

Pi Client is an independent, open-source Flutter client for the [pi coding agent](https://github.com/earendil-works/pi). One codebase targets Android, iOS, macOS, Windows, Linux, and Web.

Visit [pi.wyattcoder.top](https://pi.wyattcoder.top/) for the bilingual product overview.

## Product direction

Pi Client keeps client presentation, platform policy, transport, and host execution behind project-owned boundaries. The project does not make every platform equally privileged:

| Platform | Connect to an Agent host | Host an Agent locally |
| --- | --- | --- |
| macOS, Windows, Linux | Yes | Host-capable by contract; the public runtime is still under development |
| Android, iOS, Web | Yes | No |

Android, iOS, and Web are connect-only clients. They must not embed the Agent runtime, launch host tools, or obtain host filesystem authority.

Desktop host capability is an execution-role contract, not evidence that a host runtime is included in a current public build.

## Project status

The repository currently provides:

- One Flutter project with Android, iOS, macOS, Windows, Linux, and Web targets.
- A tested `PlatformCapabilities` contract for desktop host-capable and mobile/Web connect-only roles.
- Shared routing, state-management, storage, analysis, and test foundations.
- Cross-platform CI and Preview release automation with explicit signing and packaging boundaries.
- Public requirements, baselines, plans, decisions, and verification records under [`docs/`](docs/).

The independent runtime and transport are under active development. Pi Client does not currently promote an installable build as the product entry. Follow the repository and [GitHub Releases](https://github.com/Hu-Wentao/pi-client/releases) for future delivery updates.

Earlier Preview assets remain available as immutable project history. They are not presented as the current product path and are not modified or replaced by current development.

## Set up the project

You need [FVM](https://fvm.app/), Flutter platform toolchains, and the native build tools for the target you want to use. The repository selects Flutter `3.41.6` through `.fvmrc`.

Install the selected Flutter SDK and dependencies:

```bash
fvm install
fvm flutter pub get
```

List available devices:

```bash
fvm flutter devices
```

Run the app by replacing `DEVICE_ID` with a listed device ID:

```bash
fvm flutter run -d DEVICE_ID
```

The current native minimums include macOS 11.0 and iOS 15.0. Android uses the minimum SDK selected by the pinned Flutter toolchain. Other platform requirements remain in their native project configuration.

## Build a platform target

Android, iOS, macOS, and Web can be built from a configured macOS development host:

```bash
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
fvm flutter build macos --debug
fvm flutter build web
```

Run desktop builds on their corresponding operating systems:

```bash
fvm flutter build windows --debug
fvm flutter build linux --debug
```

Release signing, notarization, store registration, installers, and production distribution credentials are not implied by a successful development build. The release automation records each platform's signing and installability boundaries explicitly.

## Validate changes

Run the shared checks before submitting a change:

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
node --test test/release_contract_test.mjs test/preview_artifacts_test.mjs test/workflow_policy_test.mjs
node tool/release_metadata.mjs
```

For Landing Page changes:

```bash
cd site
bun install --frozen-lockfile
bun run brand
ASTRO_TELEMETRY_DISABLED=1 bun run check
ASTRO_TELEMETRY_DISABLED=1 bun run build
bun run validate
```

## Security boundaries

An Agent host can access projects and run tools with the permissions of its host process. Product work must preserve these boundaries:

- Connect-only platforms do not obtain local host execution or filesystem authority.
- Host integration remains desktop-only and must stay behind the first-party transport boundary.
- Credentials, prompts, messages, tool output, and project data must not enter URLs, screenshots, repository files, or payload logs.
- Remote access must use an authenticated and encrypted path appropriate for the target environment.
- Planned capabilities are not described as delivered until their verification owner records executable evidence.

## Current limitations

- The first-party Agent host runtime and complete transport integration are still under development.
- A current installable product release is not promoted from the Landing Page.
- Formal platform signing, notarization, store delivery, and installer trust remain separate release-readiness work.
- Windows and Linux builds require evidence from their respective operating systems.
- Platform capability contracts prove role boundaries, not complete runtime availability.

## Support and contribution

To report a bug or request a feature, open a [GitHub issue](https://github.com/Hu-Wentao/pi-client/issues). Include the Pi Client version or commit, target platform, Flutter version, host type, and relevant error text. Do not include credentials, private prompts, project data, or tool output.

To contribute code or documentation, see [Contributing to Pi Client](CONTRIBUTING.md).

## License

Pi Client is available under the [MIT License](LICENSE).
