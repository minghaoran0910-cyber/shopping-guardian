import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var sharedTextChannel: FlutterMethodChannel?
  private let sharedTextStore = SharedTextStore()
  private var cartOCRPicker: CartOCRPicker?

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
    let ocrChannel = FlutterMethodChannel(
      name: "shopping_guardian/cart_ocr",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    ocrChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickAndRecognize",
            let presenter = self?.window?.rootViewController else {
        result(FlutterMethodNotImplemented)
        return
      }
      if self?.cartOCRPicker == nil {
        self?.cartOCRPicker = CartOCRPicker(presenter: presenter)
      }
      self?.cartOCRPicker?.pick(result: result)
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    guard let channel = sharedTextChannel else { return }
    guard let text = sharedTextStore.consume() else { return }
    channel.invokeMethod("onSharedText", arguments: text)
  }
}
