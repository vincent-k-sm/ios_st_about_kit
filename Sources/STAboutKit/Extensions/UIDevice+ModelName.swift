//
//  UIDevice+ModelName.swift
//  STAboutKit
//

import UIKit

extension UIDevice {
    static var machineIdentifier: String {
        var sysInfo = utsname()
        uname(&sysInfo)
        return withUnsafePointer(to: &sysInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }

    public static var modelName: String {
        let identifier = self.machineIdentifier

        // Simulator
        if identifier == "x86_64" || identifier == "arm64" {
            return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"].flatMap { Self.mapIdentifier($0) } ?? identifier
        }

        return Self.mapIdentifier(identifier) ?? identifier
    }

    private static func mapIdentifier(_ id: String) -> String? {
        let mapping: [String: String] = [
            // iPhone 16
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,5": "iPhone 16e",
            // iPhone 15
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            // iPhone 14
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            // iPhone 13
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,5": "iPhone 13",
            "iPhone14,4": "iPhone 13 mini",
            // iPhone 12
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone13,2": "iPhone 12",
            "iPhone13,1": "iPhone 12 mini",
            // iPhone SE
            "iPhone14,6": "iPhone SE (3rd)",
            "iPhone12,8": "iPhone SE (2nd)",
            // iPad
            "iPad16,3": "iPad Pro 13\" (M4)",
            "iPad16,4": "iPad Pro 13\" (M4)",
            "iPad16,5": "iPad Pro 11\" (M4)",
            "iPad16,6": "iPad Pro 11\" (M4)",
            "iPad14,8": "iPad Air 13\" (M2)",
            "iPad14,9": "iPad Air 13\" (M2)",
            "iPad14,10": "iPad Air 11\" (M2)",
            "iPad14,11": "iPad Air 11\" (M2)",
        ]

        return mapping[id]
    }
}
