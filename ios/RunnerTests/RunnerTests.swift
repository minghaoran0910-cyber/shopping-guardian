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

}
