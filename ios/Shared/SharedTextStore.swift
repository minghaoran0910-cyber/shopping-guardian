import Foundation

struct SharedTextStore {
  static let appGroup = "group.com.shoppingguardian.shoppingGuardian"
  static let pendingKey = "pending_shared_text"

  private let defaults: UserDefaults?

  init(defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) {
    self.defaults = defaults
  }

  func save(_ text: String) {
    let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else { return }
    defaults?.set(value, forKey: Self.pendingKey)
  }

  func consume() -> String? {
    guard let value = defaults?.string(forKey: Self.pendingKey)?
      .trimmingCharacters(in: .whitespacesAndNewlines),
      !value.isEmpty else {
      return nil
    }
    defaults?.removeObject(forKey: Self.pendingKey)
    return value
  }
}
