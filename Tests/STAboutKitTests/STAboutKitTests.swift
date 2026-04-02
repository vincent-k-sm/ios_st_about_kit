import XCTest
@testable import STAboutKit

final class STAboutKitTests: XCTestCase {
    func testConfigurationReviewURL() {
        let config = STAboutConfiguration(
            appName: "TestApp",
            appId: "123456789",
            appVersion: "1.0.0",
            buildNumber: "1",
            termsOfServiceURL: "https://example.com/terms",
            privacyPolicyURL: "https://example.com/privacy",
            appStoreWebURL: "https://apps.apple.com/app/id123456789",
            shareMessage: "Check out TestApp!",
            sceneTitle: "Settings"
        )

        XCTAssertEqual(config.reviewURL, "https://apps.apple.com/app/id123456789?action=write-review")
        XCTAssertEqual(config.fullVersion, "1.0.0 (1)")
        XCTAssertNil(config.kakaoOpenChatURL)
    }
}
