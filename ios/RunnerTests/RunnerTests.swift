import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testSharedTextIsConsumedOnce() throws {
    let suiteName = "shopping_guardian_shared_text_test"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    let store = SharedTextStore(defaults: defaults)

    store.save("  【京东】https://3.cn/ios-share-test  ")

    XCTAssertEqual(store.consume(), "【京东】https://3.cn/ios-share-test")
    XCTAssertNil(store.consume())
    defaults.removePersistentDomain(forName: suiteName)
  }

  func testVisionRecognizesCartPrice() throws {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 500))
    let image = renderer.image { context in
      UIColor.white.setFill()
      context.cgContext.fill(CGRect(x: 0, y: 0, width: 900, height: 500))
      let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 72, weight: .medium),
        .foregroundColor: UIColor.black,
      ]
      "JD CART\nTEST PRODUCT\nY399 x1".draw(
        in: CGRect(x: 40, y: 40, width: 820, height: 420),
        withAttributes: attributes
      )
    }

    let lines = try VisionTextRecognizer.recognize(image)

    XCTAssertTrue(lines.joined(separator: " ").contains("399"))
  }

}
