import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var sharedTextChannel: FlutterMethodChannel?
  private let sharedTextStore = SharedTextStore()
  private var cartOCRPicker: CartOCRPicker?
  private let notificationBridge = LocalNotificationBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .sound])
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
    let notificationChannel = FlutterMethodChannel(
      name: "shopping_guardian/notifications",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    notificationChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(false)
        return
      }
      self.notificationBridge.handle(call, result: result)
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    guard let channel = sharedTextChannel else { return }
    guard let text = sharedTextStore.consume() else { return }
    channel.invokeMethod("onSharedText", arguments: text)
  }
}
