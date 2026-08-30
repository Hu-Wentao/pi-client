import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';

void main() {
  final vectorDirectory = Directory('../test-vectors')
    ..createSync(recursive: true);
  final frame = PiTransportFrame(
    frameSequence: Int64(-1),
    sessionEventStream: SessionEventStreamEnvelope(
      streamId: 'session-events-dart-1',
      sessionId: 'session-dart-1',
      eventSequence: Int64(-1),
      commandCompleted: CommandCompletedEvent(
        commandId: 'command-dart-1',
        succeeded: false,
        error: StableError(
          code: ErrorCode.ERROR_CODE_CONFLICT,
          retryable: false,
          safeMessage: 'The command could not be completed.',
        ),
      ),
    ),
  );
  File.fromUri(
    vectorDirectory.uri.resolve('dart_session_event.pb'),
  ).writeAsBytesSync(encodeTransportFrame(frame));

  final directoryFrame = PiTransportFrame(
    frameSequence: Int64(8),
    browseDirectoryResponse: BrowseDirectoryResponse(
      requestId: Int64(12),
      directory: DirectoryListingSnapshot(
        canonicalDirectory: '/tmp/pi-client-projects',
        parentDirectory: '/tmp',
        children: [
          DirectoryEntrySnapshot(
            name: 'alpha',
            canonicalPath: '/tmp/pi-client-projects/alpha',
            isSymbolicLink: false,
          ),
          DirectoryEntrySnapshot(
            name: 'linked-beta',
            canonicalPath: '/tmp/pi-client-projects/beta',
            isSymbolicLink: true,
          ),
        ],
        truncated: true,
      ),
    ),
  );
  File.fromUri(
    vectorDirectory.uri.resolve('dart_directory_listing.pb'),
  ).writeAsBytesSync(encodeTransportFrame(directoryFrame));
}
