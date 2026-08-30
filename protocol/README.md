# Pi Client Protocol Protobuf Spike

This directory is an unpublished implementation spike. It is evidence for a
future protocol decision; it is **not** Protocol 1.0, a compatibility promise,
or a production integration.

## Wire boundary

`PiTransportFrame` is the only public Protobuf wire envelope. Its operation
`oneof` now covers:

- an ordered client protocol offer and an accepted or rejected server
  handshake;
- health requests and responses;
- list, get, and create session requests and responses;
- prompt and abort commands;
- request rejection and command acceptance or rejection;
- per-session message-added, message-delta, running-changed, and
  command-completed events;
- generic health event streams;
- cancellation and flow-control window updates;
- bounded transfers and correlated stable errors.

The spike deliberately does not use:

- gRPC or Connect as the core wire;
- CBOR;
- pi-web routes, SSE payloads, names, or types;
- Pi SDK DTOs;
- a parallel JSON wire or JSON test-vector format;
- an upstream experimental Pi protocol.

The four-byte big-endian length prefix in `src/ipc_length_prefix.ts` and
`dart/lib/src/ipc_length_prefix.dart` is stream-IPC framing only. It is not a
Protobuf field and is not required by message-oriented transports.

## Identifier and version semantics

The schema separates multiplexing counters from opaque resource identities:

- `frame_sequence`, `request_id`, and `event_sequence` are non-zero `uint64`
  values. TypeScript represents them as `bigint`; Dart preserves all 64 bits in
  `fixnum.Int64`, including values above signed 64-bit maximum.
- session, message, command, stream, transfer, client-instance, and
  node-instance identifiers are opaque strings bounded by UTF-8 byte length.
- a request cancellation and an error correlation use `uint64 request_id`;
  stream and transfer targets remain string identifiers.

`ProtocolVersion` is the numeric SemVer core `major.minor.patch`. In this `v0`
package, `major` must be zero. Offers are non-empty, duplicate-free, and ordered
by client preference. Selection is exact: the server must select one version
from the offered list. No compatibility range is inferred from SemVer because
minor versions before 1.0 can be incompatible.

Prerelease and build metadata are intentionally excluded from wire protocol
identity. `implementation_version` and `node_version` are separate metadata and
must be complete SemVer 2.0.0 strings, including optional prerelease or build
metadata.

Capabilities are known, non-zero, duplicate-free enum values. The accepted
capabilities are expected to be a subset of the client offer; that stateful
subset check belongs to the handshake coordinator rather than the stateless
frame codec.

## Core domain snapshots

The schema mirrors the current hand-written Flutter semantic boundary without
importing Flutter production code:

- `SessionSummarySnapshot` owns session identity, title, working directory,
  millisecond timestamps, running state, and unread state.
- `SessionDetailSnapshot` owns one summary and a bounded ordered message list.
- `MessageSnapshot` supports user, assistant, tool, and system roles, text,
  creation time, and streaming state.
- prompt and abort are commands with both `request_id` and idempotency-oriented
  `command_id` correlation.
- `CommandAccepted` means server admission only. Completion arrives on the
  session event stream. The Flutter boundary's `CommandUncertain` remains a
  local disconnect/admission-ambiguity result and is not a server wire message.
- a failed `CommandCompletedEvent` requires a stable error; a successful one
  must not include an error.

A session stream carries both `stream_id` and `session_id`. This preserves
transport multiplexing while allowing a future Flutter adapter to expose the
per-session semantic stream and sequence-gap behavior already modeled by the
hand-written boundary.

## Stable error mapping

Unknown numeric error enums are protocol violations. Known wire codes map to
the hand-written Flutter boundary as follows:

| Protobuf error code | Flutter semantic code |
| --- | --- |
| `AUTHENTICATION_REQUIRED` | `authenticationRequired` |
| `PERMISSION_DENIED` | `permissionDenied` |
| `NOT_FOUND` | `notFound` |
| `INVALID_REQUEST` | `invalidRequest` |
| `CONFLICT`, `ALREADY_EXISTS` | `conflict` |
| `NODE_BUSY`, `RESOURCE_EXHAUSTED` | `nodeBusy` |
| `PROTOCOL_VERSION_UNSUPPORTED` | `protocolMismatch` |
| other known remote codes | `remoteRejected` |

Malformed Protobuf, missing typed operations, unknown enum values, and violated
bounds map to the local malformed/protocol-violation path rather than to a
remote application rejection. `safe_message` is optional, bounded display text
and must never carry credentials, raw provider errors, prompts, or tool data.

## Differences from the previous v0 spike

The earlier unpublished spike is intentionally not wire-compatible with this
shape:

- `BootstrapHello` was replaced by directional client offer and server
  accepted/rejected handshake operations.
- protocol versions changed from one `major/minor` pair to an ordered list of
  exact `major/minor/patch` versions.
- request identifiers changed from strings to non-zero `uint64` values; domain
  and transport resource identifiers remain strings.
- operation field numbers were regrouped by handshake, core domain, stream,
  control, transfer, and error concerns.
- stable errors now use Pi Client semantic codes and optional `safe_message`
  instead of a required generic message.
- session snapshots, message roles, commands, and per-session events are now
  typed Protobuf operations.
- frame, request, stream, and transfer counters are validated as non-zero where
  zero cannot be a valid identity.

These changes are acceptable only because `v0` has never been published. They
do not freeze a future `v1` schema.

## Hard limits

Both handwritten codecs enforce the same ceilings before production
integration:

- encoded `PiTransportFrame`: 8 MiB;
- transfer chunk payload: 1 MiB;
- identifier: 128 UTF-8 bytes;
- short text: 1 KiB;
- prompt, message, and delta text: 1 MiB;
- working-directory path: 32 KiB;
- stable error safe message: 4 KiB;
- protocol versions per offer: 16;
- advertised capabilities: 32;
- sessions per list response: 4,096;
- messages per session snapshot: 16,384;
- SHA-256 digest: zero or 32 bytes.

The 8 MiB frame limit remains authoritative even when a collection count limit
would otherwise permit more content. These values remain open to review before
a v1 freeze.

## Exact local tooling

- Bun: `1.4.0` (repository package-manager policy)
- Node.js: `>=22.19.0`
- Buf CLI: `1.72.0`
- Protobuf-ES runtime and generator: `2.14.0`
- TypeScript: `7.0.2`
- Flutter/FVM: `3.41.6`, providing Dart `3.11.4`
- Dart `protobuf`: `6.0.0`
- Dart `protoc_plugin`: `25.0.0`

`bun.lock` and `dart/pubspec.lock` commit the resolved transitive graphs. Buf
invokes `tools/protoc-gen-dart.mjs`, which runs the package-local Dart generator
through FVM; no global `buf`, `protoc`, or `protoc-gen-dart` installation is
required. The codegen command also normalizes generated text files to one final
newline because Protobuf-ES `2.14.0` emits an extra blank line at EOF.

Buf's `STANDARD` lint accepts version suffixes beginning at v1, not the
intentional unpublished `v0` package. `buf.yaml` therefore excludes only
`PACKAGE_VERSION_SUFFIX`; all other standard lint rules remain enabled.

Protobuf-ES `2.14.0` emits TypeScript `enum` declarations. Node.js `24.14.1`
reported `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX` when its strip-only loader tried to
execute that generated source directly. The smallest local fallback is
`tsconfig.node.json`: the pinned TypeScript compiler emits ignored JavaScript
under `.build/node/`, and Node's native test runner executes that output. Bun
continues to test the committed TypeScript directly.

## Reproduce

From this directory:

```text
bun install --frozen-lockfile
cd dart && fvm dart pub get --enforce-lockfile && cd ..
bun run format:check
bun run lint
bun run build
bun run codegen:check
bun run vectors:check
bun run typecheck
bun run test:bun
bun run test:node
bun run analyze:dart
bun run test:dart
```

The binary vectors prove TypeScript-to-Dart and Dart-to-TypeScript decoding,
full-range `uint64` handling, unknown-field preservation, and rejection of
unknown operations and enum values. Regeneration checks run code generation
and vector generation twice and require no changes.

## Remaining v1 questions

This spike does not decide:

- the operation that opens, resumes, and closes a session event stream;
- reconnect cursors, replay retention, and sequence-gap recovery;
- stateful handshake enforcement and capability dependencies;
- command idempotency retention and uncertain-admission recovery;
- authentication, authorization, project trust, and allowed-root claims;
- snapshot pagination and deferred large message/media retrieval;
- transport ordering guarantees and frame-sequence rollover policy;
- exact production limits, compatibility policy, or v1 field numbers.
