# Pi Client

Pi Client is a Flutter client for the [pi coding agent](https://github.com/earendil-works/pi). One codebase targets Android, iOS, macOS, Windows, Linux, and Web.

Visit the [Pi Client product page](https://wyattcoder.top/pi-client/) for the bilingual overview, sanitized product screenshot, and current release download.

Pi Client `0.0.2` is an early macOS Preview. Its current workspace connects through [pi-web](https://github.com/agegr/pi-web) `0.8.11` as a transitional compatibility bridge while the project works toward its own versioned, Pi SDK-based transport.

The platform roles are intentionally different:

| Platform | Connect to an Agent host | Run Pi SDK and host an Agent |
| --- | --- | --- |
| macOS, Windows, Linux | Yes | Platform capability is allowed; the runtime integration is not implemented yet |
| Android, iOS, Web | Yes | No |

Android, iOS, and Web are connect-only clients. They must not embed Pi SDK, launch an Agent runtime, expose host tools, or obtain host filesystem authority.

## Current implementation status

The repository contains all six Flutter platform projects and a tested `PlatformCapabilities` contract for the platform roles. The actual desktop Pi SDK host, Pi Node transport, Friday authentication, tunnel, and end-to-end encryption are still planned.

The current workspace screen remains the legacy MVP implementation. It connects to pi-web `0.8.11` for session and Agent interactions. This adapter is retained for migration and verification only; pi-web is not the target Pi Client runtime or protocol authority.

The repository also contains six-platform CI and a future cross-platform Preview Release pipeline. This automation does not change the current public download: `v0.0.2` remains the immutable macOS-only Preview. A later version must explicitly select the six-platform Artifact Profile before it can qualify Android, iOS, macOS, Windows, Linux, and Web assets from one commit.

## What you can do today

With the legacy workspace adapter, you can:

- Connect to a reachable pi-web service.
- Browse and refresh session summaries.
- Open a session and read its visible message history.
- Create a session for an absolute project directory.
- Send prompts and watch Agent output as it arrives.
- Stop an active Agent run.
- See connection, loading, error, streaming, and reconnecting states.

Pi-web continues to own sessions, models, tools, provider credentials, project access, and Agent execution for this legacy path.

## Download the macOS Preview

The current downloadable artifact is a Universal macOS Preview for Apple silicon and Intel Macs. Other platform projects are source/build baselines and do not yet have published downloads.

1. Download both files from the [`v0.0.2` prerelease](https://github.com/Hu-Wentao/pi-client/releases/tag/v0.0.2):

   - [`Pi-Client-0.0.2-macOS-universal.zip`](https://github.com/Hu-Wentao/pi-client/releases/download/v0.0.2/Pi-Client-0.0.2-macOS-universal.zip)
   - [`Pi-Client-0.0.2-macOS-universal.zip.sha256`](https://github.com/Hu-Wentao/pi-client/releases/download/v0.0.2/Pi-Client-0.0.2-macOS-universal.zip.sha256)

2. From the directory that contains both files, verify the download:

   ```bash
   shasum -a 256 -c Pi-Client-0.0.2-macOS-universal.zip.sha256
   ```

3. Extract the ZIP.

4. In Finder, Control-click `Pi Client.app`, select **Open**, then confirm **Open** in the warning dialog.

> **Unsigned Preview:** Version `0.0.2` is not signed with an Apple Developer ID and is not notarized. Gatekeeper warnings are expected. Install it only if you trust this repository and the checksum. Do not remove quarantine metadata with a shell command. A signed, notarized DMG is not available yet.

The unsigned Preview stores only non-sensitive preferences in `fr_storage_unsigned_preview`. Its fixed public storage key avoids unavailable Keychain entitlements and provides no secrecy. A future signed release will use the standard secure-storage path and will not automatically inherit Preview preferences. The pi-web password is never persisted.

## Set up the project

You need [FVM](https://fvm.app/) and the native toolchain for the platform that you want to build. The repository selects Flutter `3.41.6` through `.fvmrc`. The current native minimums include macOS 11.0 and iOS 15.0; Android uses the minimum SDK from the pinned Flutter toolchain.

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

## Run the legacy workspace

To use the current workspace features, start pi-web and keep it running:

```bash
npx @agegr/pi-web@0.8.11 --no-open
```

The default address is `http://127.0.0.1:30141`. Loopback reaches the same device as Pi Client, so a mobile device or browser normally needs a host URL that it can reach over the network. Use HTTPS for remote connections; the Android and iOS projects do not enable unrestricted cleartext traffic.

If pi-web uses `PI_WEB_PASSWORD`, enter the same password in Pi Client. The Basic Authentication username is fixed to `pi`.

To set a different initial URL when running from source, use `PI_CLIENT_BASE_URL`:

```bash
fvm flutter run -d DEVICE_ID \
  --dart-define=PI_CLIENT_BASE_URL=https://pi.example.com
```

Pi Client does not accept a password through `--dart-define`.

## Build a platform target

Run each native desktop build on its target operating system. Android, iOS, macOS, and Web can be built from a configured macOS development host.

```bash
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
fvm flutter build macos --debug
fvm flutter build web
```

Run these commands on their corresponding desktop hosts:

```bash
fvm flutter build windows --debug
fvm flutter build linux --debug
```

Release signing, store registration, and distribution credentials are not configured for the general platform matrix. Only the explicitly disclosed unsigned macOS Preview is currently public.

The future Preview profile intentionally keeps these boundaries visible:

- Android produces unsigned Release APKs that require downstream signing.
- iOS produces a no-codesign archive, not an installable App Store IPA.
- macOS remains an unsigned Universal ZIP until Developer ID and notarization are configured.
- Windows produces an unsigned Portable ZIP; Linux produces an amd64 archive that still requires compatible desktop libraries such as libsecret.
- Web compiles the Dart application to JavaScript; Flutter renderer framework assets may still include WebAssembly inside the static-site ZIP.
- Every Preview manifest records `hostRuntimeIncluded: false`; desktop host capability does not imply that Pi SDK is bundled.

## Keep access secure

An Agent host can access projects and run tools with the permissions of its host process. Keep a development host bound to loopback unless you have intentionally configured authenticated remote access.

For remote access:

- Use HTTPS or a trusted virtual private network.
- Use a strong credential when the current legacy gateway requires one.
- Do not expose an unprotected Agent host directly to the internet.
- Configure browser cross-origin resource sharing only for explicitly trusted Web origins.

Pi Client keeps the legacy pi-web password in memory for the current page lifecycle. It does not add the password to URLs, persist it in workspace state, or include request and response payloads in application logs.

## Current limitations

The current release:

- Publishes only an unsigned macOS Preview today; the six-platform CI/Preview pipeline is source-controlled but Android, iOS, Windows, Linux, and Web downloads require a later version qualification and separately authorized publication.
- Does not include the desktop Pi SDK Agent host runtime.
- Does not include the first-party Pi Node transport, Friday Workspace runtime, tunnel, or end-to-end encryption.
- Builds Flutter Web with the standard JavaScript target; WebAssembly remains blocked by the current `flutter_secure_storage_web` dependency.
- Retains a legacy pi-web adapter whose HTTP routes are not a stable public API.
- Has no Apple signing, notarization, store delivery, or signed DMG evidence.
- Requires Windows and Linux build evidence from their respective operating systems.
- Does not include file browsing, uploads, Git diffs, worktree controls, model selection, provider login, skill management, plugin management, or subagent configuration.
- Does not include session rename, deletion, export, branching, compaction controls, rich Markdown, or media rendering.

## Troubleshooting and support

| Problem | What to check |
| --- | --- |
| The status shows **Unavailable** | Confirm that the legacy gateway is running, the URL is reachable from the client device, and the password matches `PI_WEB_PASSWORD`. |
| A mobile device cannot reach `127.0.0.1` | Use the Agent host's reachable network URL instead of the mobile device's loopback address. |
| A Web build cannot connect | Confirm that the host uses HTTPS as required and permits the Web origin through its cross-origin policy. |
| No sessions appear after connecting | Select **Refresh sessions**, or create a session with an absolute path that exists on the Agent host. |
| A prompt does not execute | Confirm that the current host runtime has a working model provider configuration. |
| A live response reconnects repeatedly | Check the host process and network path, then reopen the session or select **Retry** when shown. |

To report a bug or request a feature, open a [GitHub issue](https://github.com/Hu-Wentao/pi-client/issues). Include the Pi Client version, target platform, Flutter version, host type, and relevant error text. Do not include passwords, provider credentials, private prompts, or tool output.

To contribute code or documentation, see [Contributing to Pi Client](CONTRIBUTING.md).

## License and attribution

Pi Client is available under the [MIT License](LICENSE).

The legacy adapter is an independent implementation based on observable behavior from pi-web commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT). Pi-web is Copyright (c) 2026 agegr. Pi-web remains a reference and migration input, not a target runtime dependency for the first-party Pi Client architecture.
