import Flutter
import UserNotifications

final class LocalNotificationBridge {
  private let center: UNUserNotificationCenter

  init(center: UNUserNotificationCenter = .current()) {
    self.center = center
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let id = arguments["id"] as? String,
          !id.isEmpty else {
      result(FlutterError(code: "invalid_notification", message: "提醒信息不完整。", details: nil))
      return
    }
    switch call.method {
    case "schedule":
      guard let title = arguments["title"] as? String,
            !title.isEmpty,
            let timestamp = (arguments["timestamp"] as? NSNumber)?.int64Value,
            timestamp > 0 else {
        result(FlutterError(code: "invalid_notification", message: "提醒信息不完整。", details: nil))
        return
      }
      schedule(id: id, title: title, timestamp: timestamp, result: result)
    case "cancel":
      center.removePendingNotificationRequests(withIdentifiers: [id])
      center.removeDeliveredNotifications(withIdentifiers: [id])
      result(nil)
    case "isDelivered":
      center.getDeliveredNotifications { [self] notifications in
        complete(result, with: notifications.contains { $0.request.identifier == id })
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func schedule(
    id: String,
    title: String,
    timestamp: Int64,
    result: @escaping FlutterResult
  ) {
    center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
      if let error {
        DispatchQueue.main.async { result(FlutterError(
          code: "notification_failed",
          message: error.localizedDescription,
          details: nil
        )) }
        return
      }
      guard granted, let self else {
        DispatchQueue.main.async { result(false) }
        return
      }
      let content = UNMutableNotificationContent()
      content.title = "购物守护者"
      content.body = "冷静期结束了，再看看「\(title)」还想不想买。"
      content.sound = .default
      let requestedDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
      let interval = max(1, requestedDate.timeIntervalSinceNow)
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
      let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
      center.add(request) { error in
        if let error {
          self.complete(result, with: FlutterError(
            code: "notification_failed",
            message: error.localizedDescription,
            details: nil
          ))
        } else {
          self.complete(result, with: true)
        }
      }
    }
  }

  private func complete(_ result: @escaping FlutterResult, with value: Any?) {
    DispatchQueue.main.async {
      result(value)
    }
  }
}
