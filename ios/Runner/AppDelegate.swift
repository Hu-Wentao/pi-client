import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
  UIDocumentPickerDelegate
{
  private static let sessionExportChannel =
    "io.github.huwentao.pi_client/session_export"

  private var exportChannel: FlutterMethodChannel?
  private var pendingExportResult: FlutterResult?
  private var pendingExportURL: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: Self.sessionExportChannel,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleSessionExportCall(call, result: result)
    }
    exportChannel = channel
  }

  private func handleSessionExportCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "saveExport" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard pendingExportResult == nil else {
      result(
        FlutterError(
          code: "export_busy",
          message: "Another session export picker is active.",
          details: nil
        )
      )
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let temporaryPath = arguments["temporaryPath"] as? String,
      let fileName = arguments["fileName"] as? String,
      let contentType = arguments["contentType"] as? String,
      !temporaryPath.isEmpty,
      !fileName.isEmpty,
      !contentType.isEmpty,
      FileManager.default.fileExists(atPath: temporaryPath)
    else {
      result(
        FlutterError(
          code: "invalid_export",
          message: "The session export request is incomplete.",
          details: nil
        )
      )
      return
    }
    guard let presenter = activeViewController() else {
      result(
        FlutterError(
          code: "picker_failed",
          message: "The session export picker is unavailable.",
          details: nil
        )
      )
      return
    }

    let sourceURL = URL(fileURLWithPath: temporaryPath)
    pendingExportResult = result
    pendingExportURL = sourceURL
    let picker = UIDocumentPickerViewController(forExporting: [sourceURL], asCopy: true)
    picker.delegate = self
    presenter.present(picker, animated: true)
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    finishPendingExport(saved: !urls.isEmpty)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    finishPendingExport(saved: false)
  }

  private func finishPendingExport(saved: Bool) {
    let result = pendingExportResult
    pendingExportResult = nil
    pendingExportURL = nil
    result?(saved)
  }

  private func activeViewController() -> UIViewController? {
    let root = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController
    var current = root
    while let presented = current?.presentedViewController {
      current = presented
    }
    return current
  }
}
