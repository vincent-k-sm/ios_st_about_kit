//
//  STAboutConfiguration.swift
//  STAboutKit
//

import Foundation

public struct STAboutConfiguration {

    // MARK: - App Info

    public let appName: String
    public let appId: String
    public let appVersion: String
    public let buildNumber: String

    // MARK: - URLs

    public let termsOfServiceURL: String
    public let privacyPolicyURL: String
    public let faqURL: String?
    public let appStoreWebURL: String

    // MARK: - Contact

    public let kakaoOpenChatURL: String?

    // MARK: - Share

    public let shareMessage: String

    // MARK: - Scene Title

    public let sceneTitle: String

    // MARK: - Computed

    public var fullVersion: String {
        return "\(self.appVersion) (\(self.buildNumber))"
    }

    public var reviewURL: String {
        return "https://apps.apple.com/app/id\(self.appId)?action=write-review"
    }

    // MARK: - Initialization

    public init(
        appName: String,
        appId: String,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
        buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
        termsOfServiceURL: String,
        privacyPolicyURL: String,
        faqURL: String? = nil,
        appStoreWebURL: String,
        kakaoOpenChatURL: String? = nil,
        shareMessage: String,
        sceneTitle: String
    ) {
        self.appName = appName
        self.appId = appId
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.termsOfServiceURL = termsOfServiceURL
        self.privacyPolicyURL = privacyPolicyURL
        self.faqURL = faqURL
        self.appStoreWebURL = appStoreWebURL
        self.kakaoOpenChatURL = kakaoOpenChatURL
        self.shareMessage = shareMessage
        self.sceneTitle = sceneTitle
    }
}
