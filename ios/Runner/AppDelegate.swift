import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var sharedTextChannel: FlutterMethodChannel?
  private let sharedTextStore = SharedTextStore()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "shopping_guardian/shared_text",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getInitialText" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.sharedTextStore.consume())
    }
    sharedTextChannel = channel
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    guard let channel = sharedTextChannel else { return }
    guard let text = sharedTextStore.consume() else { return }
    channel.invokeMethod("onSharedText", arguments: text)
  }
}
