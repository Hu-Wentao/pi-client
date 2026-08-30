enum PlatformAuthCallbackResult { completed, ignored }

abstract interface class PlatformAuthAdapter {
  Future<void> beginLogin();

  Future<PlatformAuthCallbackResult> completeLoginCallback();

  Future<void> logout();
}
