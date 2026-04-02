//
//  STAboutModels.swift
//  STAboutKit
//

import UIKit

// MARK: - Section Model

public struct STAboutSection {
    public let headerTitle: String?
    public let items: [STAboutItem]

    public init(headerTitle: String? = nil, items: [STAboutItem]) {
        self.headerTitle = headerTitle
        self.items = items
    }
}

// MARK: - Item Model

public struct STAboutItem {
    public let title: String
    public let iconName: String
    public let iconColor: UIColor
    public let accessory: Accessory
    public let isDestructive: Bool
    public let action: () -> Void

    public enum Accessory {
        case arrow
        case label(String)
        case none
    }

    public init(
        title: String,
        iconName: String,
        iconColor: UIColor = .secondaryLabel,
        accessory: Accessory = .arrow,
        isDestructive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.accessory = accessory
        self.isDestructive = isDestructive
        self.action = action
    }
}
