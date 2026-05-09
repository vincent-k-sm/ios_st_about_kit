//
//  STAboutDesign.swift
//  STAboutKit
//

import UIKit

// MARK: - Theme (앱별 brand 컬러 오버라이드)

public enum STAboutTheme {
    /// nil 이면 기본 블루(#1F6FFF). 앱 시작 시 설정 권장.
    public static var primary: UIColor?
    /// nil 이면 기본 빨강(#F04452).
    public static var danger: UIColor?
}

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

    static var primary: UIColor {
        STAboutTheme.primary ?? UIColor(stHex: "#1F6FFF")
    }
    static var danger: UIColor {
        STAboutTheme.danger ?? UIColor(stHex: "#F04452")
    }

    static let chipBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#3A3A3C")
            : UIColor(stHex: "#F2F3F5")
    }

    static let cardBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#3A3A3C")
            : UIColor(stHex: "#F5F7FA")
    }

    static let inputBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#3A3A3C")
            : UIColor(stHex: "#EBEEF5")
    }

    static let separator = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(stHex: "#38383A")
            : UIColor(stHex: "#F2F3F5")
    }
}

// MARK: - Typography

enum STAboutTypography {
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let caption1 = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let caption1Bold = UIFont.systemFont(ofSize: 13, weight: .semibold)
    static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
}

// MARK: - Spacing

enum STAboutSpacing {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    static let container: CGFloat = 20
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
