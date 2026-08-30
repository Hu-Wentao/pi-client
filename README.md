# Pi Client

Pi Client is a native macOS desktop client for the [pi coding agent](https://github.com/earendil-works/pi). It connects to a separately running [pi-web](https://github.com/agegr/pi-web) service, giving you a focused desktop interface for existing pi sessions and live agent runs.

Pi Client is an early release. The current version targets macOS and pi-web `0.8.11`.

## What you can do

Use Pi Client to:

- Connect to a local or remote pi-web service.
- Browse and refresh your pi session list.
- Open a session and read its visible message history.
- Create a session for an absolute project directory.
- Send prompts and watch agent output as it arrives.
- Stop an active agent run.
- See connection, loading, error, streaming, and reconnecting states.

Pi-web continues to manage your sessions, models, tools, provider credentials, and project access. Pi Client provides the native desktop interface and does not replace the pi runtime.

## Before you begin

You need:

- macOS 11.0 or newer.
- A working Flutter macOS toolchain and [FVM](https://fvm.app/). The repository selects Flutter `3.41.6` through `.fvmrc`.
- Node.js and `npx` to run pi-web `0.8.11`.
- A model provider configured for pi if you want the agent to execute prompts.

The default pi-web address is `http://127.0.0.1:30141`.

## Start Pi Client

1. Start pi-web in a terminal and keep it running:

   ```bash
   npx @agegr/pi-web@0.8.11 --no-open
   ```

   If your pi-web service uses `PI_WEB_PASSWORD`, you will enter the same password in Pi Client.

2. Clone and run Pi Client from source:

   ```bash
   git clone https://github.com/Hu-Wentao/pi-client.git
   cd pi-client
   fvm install
   fvm flutter pub get
   fvm flutter run -d macos
   ```

3. Wait for the Pi Client window to open. The connection form initially uses `http://127.0.0.1:30141`.

## Use Pi Client

1. Enter the pi-web URL and, if configured, its password.
2. Select **Connect**. The status changes to **Connected** when Pi Client can reach pi-web.
3. Continue an existing session by selecting it from **Sessions**.
4. To create a session, enter an absolute project path in **New session cwd**, then select **Create session**.
5. Enter a prompt in the message field, then select **Send prompt**.
6. To interrupt a running agent, select **Stop agent**.

Select **Refresh sessions** when you want to reload the session list. Pi Client automatically reconnects the live event stream for the selected session after a temporary stream interruption.

## Configure the connection

You can change the pi-web URL in the connection form before selecting **Connect**. Both HTTP and HTTPS URLs are accepted.

To set a different initial URL when running from source, use `PI_CLIENT_BASE_URL`:

```bash
fvm flutter run -d macos \
  --dart-define=PI_CLIENT_BASE_URL=https://pi.example.com
```

Replace `https://pi.example.com` with your pi-web address. Enter the password only in the runtime connection form. Pi Client does not accept a password through `--dart-define`.

When pi-web uses Basic Authentication, its username is fixed to `pi`; Pi Client supplies that username automatically.

## Keep access secure

Pi-web exposes a coding agent that can access projects and run tools with the permissions of its host process. Keep pi-web bound to loopback unless you have intentionally configured remote access.

For remote access:

- Use a strong `PI_WEB_PASSWORD`.
- Put pi-web behind a trusted HTTPS reverse proxy or VPN.
- Do not rely on Basic Authentication alone to encrypt network traffic.
- Do not expose an unprotected pi-web service directly to the internet.

Pi Client keeps the password in memory for the current page lifecycle. It does not store the password in workspace data, add it to URLs, or include request and response payloads in application logs.

## Current limitations

The current release:

- Supports macOS 11.0 or newer only.
- Targets the observable behavior of pi-web `0.8.11`; pi-web does not declare these HTTP routes as a stable public API.
- Requires model and provider setup to be completed outside Pi Client.
- Does not include file browsing, uploads, Git diffs, or worktree controls.
- Does not include model selection, provider login, skill management, plugin management, or subagent configuration.
- Does not include session rename, deletion, export, branching, compaction controls, rich Markdown, or media rendering.

## Troubleshooting and support

Use these checks for common problems:

| Problem | What to check |
| --- | --- |
| The status shows **Unavailable** | Confirm that pi-web is running, the URL is correct, and the password matches `PI_WEB_PASSWORD`. |
| No sessions appear after connecting | Select **Refresh sessions**, or create a session with an absolute project path. |
| A prompt does not execute | Confirm that the pi runtime has a working model provider configuration. |
| A remote server cannot connect | Confirm that the HTTPS proxy or VPN can reach pi-web and that the configured URL is reachable from the Mac. |
| A live response reconnects repeatedly | Check the pi-web process and the network path, then reopen the session or select **Retry** when shown. |

To report a bug or request a feature, open a [GitHub issue](https://github.com/Hu-Wentao/pi-client/issues). Include the Pi Client version, macOS version, pi-web version, and relevant error text. Do not include passwords, provider credentials, private prompts, or tool output.

To contribute code or documentation, see [Contributing to Pi Client](CONTRIBUTING.md).

## License and attribution

Pi Client is available under the [MIT License](LICENSE).

Pi Client is an independent implementation based on observable behavior from pi-web commit `28bab3c25f5f6770c9b0b745ebbfec1c27f7b948` (`0.8.11`, MIT). Pi-web is Copyright (c) 2026 agegr.
