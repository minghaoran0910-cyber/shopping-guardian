import Social
import UIKit

final class ShareViewController: SLComposeServiceViewController {
  private let sharedTextStore = SharedTextStore()

  override func isContentValid() -> Bool {
    let hasComment = !(contentText ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .isEmpty
    return hasComment || hasSupportedAttachment
  }

  override func didSelectPost() {
    Task { @MainActor in
      let sharedText = await collectSharedText()
      sharedTextStore.save(sharedText)
      extensionContext?.completeRequest(returningItems: nil)
    }
  }

  override func configurationItems() -> [Any]! {
    []
  }

  private var hasSupportedAttachment: Bool {
    extensionContext?.inputItems
      .compactMap { $0 as? NSExtensionItem }
      .flatMap { $0.attachments ?? [] }
      .contains { provider in
        provider.hasItemConformingToTypeIdentifier("public.url") ||
          provider.hasItemConformingToTypeIdentifier("public.plain-text")
      } == true
  }

  private func collectSharedText() async -> String {
    var values: [String] = []
    let comment = (contentText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if !comment.isEmpty {
      values.append(comment)
    }

    let providers = extensionContext?.inputItems
      .compactMap { $0 as? NSExtensionItem }
      .flatMap { $0.attachments ?? [] } ?? []
    for provider in providers {
      if let url = await loadString(from: provider, typeIdentifier: "public.url") {
        values.append(url)
      } else if let text = await loadString(
        from: provider,
        typeIdentifier: "public.plain-text"
      ) {
        values.append(text)
      }
    }
    return values.reduce(into: [String]()) { result, value in
      if !result.contains(value) { result.append(value) }
    }.joined(separator: "\n")
  }

  private func loadString(
    from provider: NSItemProvider,
    typeIdentifier: String
  ) async -> String? {
    guard provider.hasItemConformingToTypeIdentifier(typeIdentifier) else { return nil }
    return await withCheckedContinuation { continuation in
      provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, _ in
        let value: String?
        if let url = item as? URL {
          value = url.absoluteString
        } else if let url = item as? NSURL {
          value = url.absoluteString
        } else if let text = item as? String {
          value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
          value = nil
        }
        continuation.resume(returning: value?.isEmpty == false ? value : nil)
      }
    }
  }
}
