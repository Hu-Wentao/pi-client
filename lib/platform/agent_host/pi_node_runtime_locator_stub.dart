import 'pi_node_host_controller.dart';
import 'pi_node_runtime_locator_types.dart';

PiNodeRuntimeLocator createPlatformPiNodeRuntimeLocator() =>
    const _UnsupportedPiNodeRuntimeLocator();

final class _UnsupportedPiNodeRuntimeLocator implements PiNodeRuntimeLocator {
  const _UnsupportedPiNodeRuntimeLocator();

  @override
  Future<PiNodeDesktopProcessConfiguration> locate() =>
      Future<PiNodeDesktopProcessConfiguration>.error(
        const PiNodeRuntimeLocationException(
          PiNodeRuntimeLocationErrorCode.unsupportedPlatform,
        ),
      );
}
