//
//  InquiryConfig.swift
//  STAboutKit
//

import Foundation
import UIKit

enum InquiryConfig {

    static var apiURL: String = ""
    static var spreadsheetId: String = ""
    static var slackWebhookUrl: String = ""
    static var deviceIdProvider: (() -> String)?
    static var environmentInfoProvider: (() -> String)?

    static var replyFromName: String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "고객지원"
        return "\(appName) 고객지원"
    }

    static var serviceName: String {
        return Bundle.main.bundleIdentifier ?? "UNKNOWN"
    }

    static var deviceId: String {
        return self.deviceIdProvider?() ?? ""
    }
}
