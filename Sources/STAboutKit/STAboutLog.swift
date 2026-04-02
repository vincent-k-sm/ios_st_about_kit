//
//  STAboutLog.swift
//  STAboutKit
//

import Foundation
import os.log

enum STAboutLog {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "STAboutKit",
        category: "STAboutKit"
    )

    static func d(_ message: String) { self.logger.debug("\(message)") }
    static func i(_ message: String) { self.logger.info("\(message)") }
    static func w(_ message: String) { self.logger.warning("\(message)") }
    static func e(_ message: String) { self.logger.error("\(message)") }
}
