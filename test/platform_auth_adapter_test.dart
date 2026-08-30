import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/platform/auth/platform_auth_adapter.dart';

void main() {
  test(
    'PlatformAuthAdapter is implementable without credential values',
    () async {
      final adapter = _FakePlatformAuthAdapter(
        PlatformAuthCallbackResult.completed,
      );
      final ignoredAdapter = _FakePlatformAuthAdapter(
        PlatformAuthCallbackResult.ignored,
      );

      await adapter.beginLogin();
      expect(
        await adapter.completeLoginCallback(),
        PlatformAuthCallbackResult.completed,
      );
      expect(
        await ignoredAdapter.completeLoginCallback(),
        PlatformAuthCallbackResult.ignored,
      );
      await adapter.logout();
    },
  );
}

final class _FakePlatformAuthAdapter implements PlatformAuthAdapter {
  const _FakePlatformAuthAdapter(this.result);

  final PlatformAuthCallbackResult result;

  @override
  Future<void> beginLogin() async {}

  @override
  Future<PlatformAuthCallbackResult> completeLoginCallback() async => result;

  @override
  Future<void> logout() async {}
}
