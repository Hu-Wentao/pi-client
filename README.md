# Pi Client

Pi Client is an independent, cross-platform Flutter client for the [pi coding agent](https://github.com/earendil-works/pi). One codebase targets Android, iOS, macOS, Windows, Linux, and Web.

Pi Client owns its application architecture, Pi Node service, protocol, transports, product requirements, and release process. Early planning consulted the information structure of a separate Web client. That consultation does not define any current requirement, protocol, implementation, compatibility target, runtime dependency, build dependency, or product relationship.

## Architecture

```text
Flutter Pi Client
  -> app-owned PiNodeApi
     -> project-owned Pi Protocol and transport
        -> first-party Pi Node
           -> reviewed public Pi SDK boundary
```

The desktop Local Direct path runs Pi Node as a separate process. Pi Node owns the Pi SDK lifecycle, project trust, sessions, tools, host operations, and future provider credentials. Flutter owns presentation, navigation, transient interaction state, and non-sensitive preferences.

The platform roles and current connectivity are intentionally different:

| Platform | Product role | Current source connectivity |
| --- | --- | --- |
| macOS, Windows, Linux | Agent-host-capable client | Local Direct source is implemented; supported packaging and release qualification are incomplete |
| Android, iOS, Web | Remote client only | Remote transport is not implemented |

Android, iOS, and Web must not embed the Pi SDK, launch an Agent runtime, expose host tools, or obtain host filesystem authority.

## Current source status

The current source includes:

- A typed `PiNodeApi` and first-party Protobuf protocol implementation for Dart and TypeScript.
- A first-party Pi Node that integrates reviewed public Pi SDK package entry points.
- A desktop Local Direct transport, host controller, and verified runtime Capsule tooling.
- Workspace behavior for project trust, session discovery and administration, paged history, branching, export, prompts, ordered events, and cancellation.
- Focused Dart, TypeScript, cross-language protocol, cross-process, runtime Capsule, and platform-role tests.

The first-party architecture is implemented in source, but it is not yet a supported public release. The public `v0.0.2` prerelease predates this architecture and remains historical release evidence only. Do not use that artifact to infer the current source setup or runtime design.

Friday Workspace, native authentication, end-to-end encrypted remote transport, full remote-client connectivity, and the remaining `1.0.0` feature set are still planned or incomplete. Local Direct remains independent of Friday services.

## Set up the repository

Install these prerequisites:

- [FVM](https://fvm.app/)
- Bun `1.4.0`
- Node.js `22.19.0`
- The native toolchain for your target platform

The repository selects Flutter `3.41.6` through `.fvmrc`.

Install the Flutter dependencies:

```bash
fvm install
fvm flutter pub get
```

Install and build the protocol and Pi Node packages:

```bash
(
  cd protocol
  bun install --frozen-lockfile
)

(
  cd node
  bun install --frozen-lockfile
  bun run build
)
```

## Run a desktop development build

A normal source build does not silently download or trust an Agent runtime. For local development, build Pi Node and pass the complete development runtime configuration explicitly.

The following macOS or Linux example runs the app with the local Node.js executable and built Pi Node entry point:

```bash
ROOT="$(pwd -P)"

fvm flutter run -d DEVICE_ID \
  --dart-define=PI_CLIENT_ALLOW_DEVELOPMENT_RUNTIME_FALLBACK=true \
  --dart-define=PI_CLIENT_DEVELOPMENT_NODE_EXECUTABLE="$(command -v node)" \
  --dart-define=PI_CLIENT_DEVELOPMENT_NODE_ENTRYPOINT="$ROOT/node/dist/stdio-main.js" \
  --dart-define=PI_CLIENT_DEVELOPMENT_NODE_CWD="$ROOT" \
  --dart-define=PI_CLIENT_DEVELOPMENT_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
```

Replace `DEVICE_ID` with a desktop device from this command:

```bash
fvm flutter devices
```

Release builds reject the development fallback. Packaged desktop applications must contain a compatible, integrity-verified runtime Capsule.

## Run the checks

Run the Flutter checks from the repository root:

```bash
fvm dart format --output=none --set-exit-if-changed lib test tool
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
```

Run the protocol and Pi Node checks:

```bash
(
  cd protocol
  bun run check
)

(
  cd node
  bun run check
)
```

## Build a platform target

Build each native desktop target on its target operating system. Android, iOS, macOS, and Web can be built from a configured macOS development host.

```bash
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
fvm flutter build macos --debug
fvm flutter build web
```

Run the corresponding command on a Windows or Linux host:

```bash
fvm flutter build windows --debug
fvm flutter build linux --debug
```

These ordinary Flutter build commands do not qualify a release or prove that a runtime Capsule is bundled. Release signing, packaging, artifact inspection, and platform acceptance use separate repository workflows.

## Security boundaries

An Agent host can access projects and run tools with the permissions of its host process. Pi Client applies these boundaries:

- Pi Node authorizes project access before loading project resources.
- Local Direct reserves standard output for bounded protocol frames and keeps diagnostics redacted.
- Flutter serializable state must not contain reusable provider, Node, or Friday credentials.
- Mobile and Web builds must not package desktop host runtime code.
- A missing, incompatible, or integrity-invalid runtime Capsule fails closed.
- Remote transports must add explicit authentication, authorization, and encryption without weakening Local Direct.

Do not commit credentials, local sessions, provider data, signing material, private prompts, or tool output.

## Current limitations

The current source does not yet provide:

- A supported independent public release.
- A frozen public protocol version or complete reconnect and replay behavior.
- Production acceptance evidence for provider-backed prompt, cancellation, restart, and recovery flows.
- Complete LAN or Friday Workspace transport, pairing, authentication, or end-to-end encryption.
- Complete files, Git, worktree, model, provider, settings, skills, packages, extensions, localization, accessibility, and release workflows required for `1.0.0`.
- Full signed and qualified artifacts for every supported platform.

Android, iOS, and Web require a future remote transport. Until that transport is configured, they fail explicitly instead of acquiring desktop host authority.

## Troubleshooting and support

| Problem | What to check |
| --- | --- |
| The desktop runtime is unavailable | Build Pi Node and provide every absolute development fallback path, or use an application package that contains a verified runtime Capsule. |
| The runtime Capsule is rejected | Confirm that its target platform, architecture, source commit, package versions, and integrity manifest match the application. |
| A project cannot open | Confirm that the project path exists and that Pi Node granted trust before loading project resources. |
| A prompt does not execute | Confirm that the Pi SDK runtime has a working model-provider configuration and that the session is not already running an incompatible command. |
| A mobile or Web client cannot connect | A supported remote transport is not implemented yet. These platforms cannot start a local Agent host. |

To report a bug or request a feature, open a [GitHub issue](https://github.com/Hu-Wentao/pi-client/issues). Include the Pi Client version, target platform, Flutter version, host type, and relevant redacted error text. Do not include credentials, private prompts, project data, or tool output.

## License

Pi Client is available under the [MIT License](LICENSE).
