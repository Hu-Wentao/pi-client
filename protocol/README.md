# Pi Client Protocol Protobuf Spike

This directory is an unpublished implementation spike. It is evidence for a
future protocol decision; it is **not** Protocol 1.0, a compatibility promise,
or a production integration.

## Wire boundary

`PiTransportFrame` is the only public binary envelope in the spike. Its typed
operation `oneof` covers bootstrap hello, unary health, event streams,
cancellation, flow-control window updates, bounded transfers, and stable error
codes. Request, stream, transfer, connection, and peer identifiers are flat
strings rather than generated wrapper types.

The spike deliberately does not use:

- gRPC or Connect as the core wire;
- CBOR;
- pi-web routes, SSE payloads, or types;
- an upstream experimental Pi protocol;
- a parallel JSON wire or JSON test-vector format.

The four-byte big-endian length prefix in `src/ipc_length_prefix.ts` and
`dart/lib/src/ipc_length_prefix.dart` is stream-IPC framing only. It is not a
Protobuf field and is not required by message-oriented transports.

## Hard limits

Both handwritten codecs enforce the same initial ceilings before production
integration:

- encoded `PiTransportFrame`: 8 MiB;
- transfer chunk payload: 1 MiB;
- identifier: 128 UTF-8 bytes;
- short text: 1 KiB;
- stable error message: 4 KiB;
- SHA-256 digest: zero or 32 bytes;
- advertised capabilities: 32 entries.

These values are spike inputs and remain open to review before a v1 freeze.

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

The binary files in `test-vectors/` prove TypeScript-to-Dart and Dart-to-
TypeScript decoding, `uint64` values above JavaScript's safe integer range, and
unknown-field preservation. Regeneration checks run code generation and vector
generation twice and require no changes.
