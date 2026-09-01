import 'dart:async';

import 'pi_transport.dart';

/// A connected in-memory transport pair for protocol and conformance tests.
final class InMemoryPiTransportPair {
  factory InMemoryPiTransportPair() {
    final firstIncoming = StreamController<PiTransportFrame>.broadcast(
      sync: true,
    );
    final secondIncoming = StreamController<PiTransportFrame>.broadcast(
      sync: true,
    );
    final state = _InMemoryPairState(firstIncoming, secondIncoming);
    return InMemoryPiTransportPair._(
      _InMemoryPiTransport(state, firstIncoming, secondIncoming),
      _InMemoryPiTransport(state, secondIncoming, firstIncoming),
    );
  }

  const InMemoryPiTransportPair._(this.first, this.second);

  final PiTransport first;
  final PiTransport second;
}

final class _InMemoryPiTransport implements PiTransport {
  const _InMemoryPiTransport(
    this._state,
    this._incomingController,
    this._peerIncomingController,
  );

  final _InMemoryPairState _state;
  final StreamController<PiTransportFrame> _incomingController;
  final StreamController<PiTransportFrame> _peerIncomingController;

  @override
  Stream<PiTransportFrame> get incoming => _incomingController.stream;

  @override
  Future<void> get done => _state.done;

  @override
  Future<void> close() => _state.close();

  @override
  Future<void> send(PiTransportFrame frame) async {
    if (_state.isClosed) {
      throw const PiTransportException(PiTransportErrorCode.closed);
    }
    _peerIncomingController.add(PiTransportFrame(frame.bytes));
  }
}

final class _InMemoryPairState {
  _InMemoryPairState(this._firstIncoming, this._secondIncoming);

  final StreamController<PiTransportFrame> _firstIncoming;
  final StreamController<PiTransportFrame> _secondIncoming;
  final Completer<void> _done = Completer<void>();
  Future<void>? _closeFuture;
  bool isClosed = false;

  Future<void> get done => _done.future;

  Future<void> close() => _closeFuture ??= _close();

  Future<void> _close() async {
    isClosed = true;
    await Future.wait<void>(<Future<void>>[
      _firstIncoming.close(),
      _secondIncoming.close(),
    ]);
    if (!_done.isCompleted) _done.complete();
  }
}
