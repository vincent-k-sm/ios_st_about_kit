//
//  STAboutDesign.swift
//  STAboutKit
//

import UIKit

// MARK: - Colors

enum STAboutColors {

    static let background = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#1C1C1E")
            : UIColor(stHex: "#F3F6FC")
    }

    static let backgroundWhite = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#2C2C2E")
            : UIColor.white
    }

    static let textPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(stHex: "#1C1E21")
    }

    static let textSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#ABABAB")
            : UIColor(stHex: "#4B5563")
    }

    static let textTertiary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#8E8E93")
            : UIColor(stHex: "#6B7280")
    }

    static let primary = UIColor(stHex: "#1F6FFF")
    static let danger = UIColor(stHex: "#F04452")

    static let chipBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#3A3A3C")
            : UIColor(stHex: "#F2F3F5")
    }
}

// MARK: - Typography

enum STAboutTypography {
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let caption1 = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let caption1Bold = UIFont.systemFont(ofSize: 13, weight: .semibold)
}

// MARK: - Spacing

enum STAboutSpacing {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}

// MARK: - Radius

enum STAboutRadius {
    static let sm: CGFloat = 8
}

// MARK: - UIColor Hex Initializer

extension UIColor {
    convenience init(stHex hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
