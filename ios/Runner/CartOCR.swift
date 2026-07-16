import Flutter
import PhotosUI
import UIKit
import Vision

final class CartOCRPicker: NSObject, PHPickerViewControllerDelegate, UIDocumentPickerDelegate {
  private weak var presenter: UIViewController?
  private var result: FlutterResult?

  init(presenter: UIViewController) {
    self.presenter = presenter
  }

  func pick(result: @escaping FlutterResult) {
    guard self.result == nil else {
      result(FlutterError(code: "ocr_busy", message: "已经在读取一张图片。", details: nil))
      return
    }
    guard let presenter else {
      result(FlutterError(code: "picker_unavailable", message: "暂时无法打开图片选择器。", details: nil))
      return
    }
    self.result = result
    if #available(iOS 14.0, *) {
      var configuration = PHPickerConfiguration(photoLibrary: .shared())
      configuration.filter = .images
      configuration.selectionLimit = 1
      let picker = PHPickerViewController(configuration: configuration)
      picker.delegate = self
      presenter.present(picker, animated: true)
    } else {
      let picker = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
      picker.delegate = self
      picker.allowsMultipleSelection = false
      presenter.present(picker, animated: true)
    }
  }

  @available(iOS 14.0, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    guard let provider = results.first?.itemProvider else {
      finish(nil)
      return
    }
    provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
      if let error {
        self?.finish(FlutterError(
          code: "image_read_failed",
          message: error.localizedDescription,
          details: nil
        ))
        return
      }
      self?.recognize(object as? UIImage)
    }
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else {
      finish(nil)
      return
    }
    let hasAccess = url.startAccessingSecurityScopedResource()
    let image = (try? Data(contentsOf: url)).flatMap(UIImage.init(data:))
    if hasAccess { url.stopAccessingSecurityScopedResource() }
    recognize(image)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    finish(nil)
  }

  private func recognize(_ image: UIImage?) {
    guard let image else {
      finish(FlutterError(code: "invalid_image", message: "无法读取这张图片。", details: nil))
      return
    }
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        self?.finish(try VisionTextRecognizer.recognize(image))
      } catch {
        self?.finish(FlutterError(
          code: "ocr_failed",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
  }

  private func finish(_ value: Any?) {
    DispatchQueue.main.async { [weak self] in
      guard let callback = self?.result else { return }
      self?.result = nil
      callback(value)
    }
  }
}

enum VisionTextRecognizer {
  static func recognize(_ image: UIImage) throws -> [String] {
    guard let cgImage = image.cgImage else {
      throw VisionTextError.invalidImage
    }
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["zh-Hans", "en-US"]
    request.usesLanguageCorrection = true
    try VNImageRequestHandler(
      cgImage: cgImage,
      orientation: image.imageOrientation.visionOrientation
    ).perform([request])
    return (request.results ?? []).sorted {
      if abs($0.boundingBox.midY - $1.boundingBox.midY) > 0.012 {
        return $0.boundingBox.midY > $1.boundingBox.midY
      }
      return $0.boundingBox.minX < $1.boundingBox.minX
    }.compactMap { $0.topCandidates(1).first?.string }
  }
}

private enum VisionTextError: Error {
  case invalidImage
}

private extension UIImage.Orientation {
  var visionOrientation: CGImagePropertyOrientation {
    switch self {
    case .up: .up
    case .down: .down
    case .left: .left
    case .right: .right
    case .upMirrored: .upMirrored
    case .downMirrored: .downMirrored
    case .leftMirrored: .leftMirrored
    case .rightMirrored: .rightMirrored
    @unknown default: .up
    }
  }
}
