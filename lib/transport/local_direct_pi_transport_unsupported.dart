import 'local_direct_pi_transport_config.dart';
import 'pi_transport.dart';

/// Unsupported Local Direct boundary used by web and other non-IO targets.
final class LocalDirectPiTransport implements PiTransport {
  LocalDirectPiTransport._();

  static Future<LocalDirectPiTransport> start(
    LocalDirectPiProcessConfiguration configuration,
  ) => Future<LocalDirectPiTransport>.error(
    const PiTransportException(PiTransportErrorCode.unsupported),
  );

  @override
  Stream<PiTransportFrame> get incoming => Stream<PiTransportFrame>.error(
    const PiTransportException(PiTransportErrorCode.unsupported),
  );

  @override
  Future<void> get done => Future<void>.error(
    const PiTransportException(PiTransportErrorCode.unsupported),
  );

  @override
  Future<void> close() => Future<void>.error(
    const PiTransportException(PiTransportErrorCode.unsupported),
  );

  @override
  Future<void> send(PiTransportFrame frame) => Future<void>.error(
    const PiTransportException(PiTransportErrorCode.unsupported),
  );
}
