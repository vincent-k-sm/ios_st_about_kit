//
//  I18N.swift
//  STAboutKit
//

import Foundation

struct I18N {

    // MARK: - Common

    static let common_cancel = "stabout_common_cancel".localized

    // MARK: - Sections

    static let section_help = "stabout_section_help".localized
    static let section_share = "stabout_section_share".localized
    static let section_info = "stabout_section_info".localized

    // MARK: - Menu Items

    static let menu_faq = "stabout_menu_faq".localized
    static let menu_contact = "stabout_menu_contact".localized
    static let menu_share = "stabout_menu_share".localized
    static let menu_review = "stabout_menu_review".localized
    static let menu_privacy = "stabout_menu_privacy".localized
    static let menu_terms = "stabout_menu_terms".localized
    static let menu_version = "stabout_menu_version".localized

    // MARK: - Contact Action Sheet

    static let contact_action_title = "stabout_contact_action_title".localized
    static let contact_inquiry = "stabout_contact_inquiry".localized
    static let contact_kakao = "stabout_contact_kakao".localized
}

// MARK: - String Extension

private extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
}
