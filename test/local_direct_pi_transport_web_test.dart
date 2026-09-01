import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/platform/agent_host/pi_node_host_controller.dart';
import 'package:pi_client/platform/platform_capabilities.dart';
import 'package:pi_client/transport/local_direct_pi_transport.dart';
import 'package:pi_client/transport/pi_transport.dart';

void main() {
  test(
    'web Local Direct and host seams fail with typed unsupported errors',
    () async {
      if (!kIsWeb) return;

      final processConfiguration = LocalDirectPiProcessConfiguration(
        executable: 'node',
        arguments: const <String>['server'],
      );
      await expectLater(
        LocalDirectPiTransport.start(processConfiguration),
        throwsA(
          isA<PiTransportException>().having(
            (error) => error.code,
            'code',
            PiTransportErrorCode.unsupported,
          ),
        ),
      );

      final controller = LocalProcessPiNodeHostController(
        capabilities: PlatformCapabilities.resolve(
          isWeb: true,
          targetPlatform: TargetPlatform.linux,
        ),
        configuration: PiNodeDesktopProcessConfiguration(
          nodeExecutable: 'node',
          serverArguments: const <String>['server'],
        ),
      );
      await expectLater(
        controller.start(),
        throwsA(
          isA<PiNodeHostException>().having(
            (error) => error.code,
            'code',
            PiNodeHostErrorCode.unsupportedPlatform,
          ),
        ),
      );
      await controller.close();
    },
  );
}
