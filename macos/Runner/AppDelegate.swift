import Cocoa
import FlutterMacOS
import Vision

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "shopping_guardian/cart_ocr",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickAndRecognize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.pickAndRecognize(result: result)
    }
    let exportChannel = FlutterMethodChannel(
      name: "shopping_guardian/file_export",
      binaryMessenger: controller.engine.binaryMessenger
    )
    exportChannel.setMethodCallHandler { call, result in
      guard call.method == "saveJson",
            let arguments = call.arguments as? [String: Any],
            let content = arguments["content"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      let panel = NSSavePanel()
      panel.nameFieldStringValue = "shopping-guardian-export.json"
      panel.allowedFileTypes = ["json"]
      guard panel.runModal() == .OK, let url = panel.url else {
        result(false)
        return
      }
      do {
        try content.write(to: url, atomically: true, encoding: .utf8)
        result(true)
      } catch {
        result(FlutterError(code: "export_failed", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func pickAndRecognize(result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.allowedFileTypes = ["png", "jpg", "jpeg", "heic"]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    guard panel.runModal() == .OK, let url = panel.url else {
      result(nil)
      return
    }

    let hasAccess = url.startAccessingSecurityScopedResource()
    defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }
    guard let image = NSImage(contentsOf: url),
          let data = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: data),
          let cgImage = bitmap.cgImage else {
      result(FlutterError(code: "invalid_image", message: "无法读取这张图片", details: nil))
      return
    }

    let request = VNRecognizeTextRequest { request, error in
      if let error {
        result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
        return
      }
      let observations = (request.results as? [VNRecognizedTextObservation] ?? []).sorted {
        if abs($0.boundingBox.midY - $1.boundingBox.midY) > 0.012 {
          return $0.boundingBox.midY > $1.boundingBox.midY
        }
        return $0.boundingBox.minX < $1.boundingBox.minX
      }
      result(observations.compactMap { $0.topCandidates(1).first?.string })
    }
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["zh-Hans", "en-US"]
    request.usesLanguageCorrection = true

    do {
      try VNImageRequestHandler(cgImage: cgImage).perform([request])
    } catch {
      result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
