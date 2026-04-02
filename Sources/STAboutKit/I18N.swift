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

    // MARK: - Common (Inquiry)

    static let common_confirm = "stabout_common_confirm".localized
    static let common_save = "stabout_common_save".localized
    static let common_add = "stabout_common_add".localized
    static let common_unknown = "stabout_common_unknown".localized
    static let common_alert = "stabout_common_alert".localized

    // MARK: - Inquiry

    static let inquiry_nav_title = "stabout_inquiry_nav_title".localized
    static let inquiry_email_label = "stabout_inquiry_email_label".localized
    static let inquiry_email_placeholder = "stabout_inquiry_email_placeholder".localized
    static let inquiry_title_label = "stabout_inquiry_title_label".localized
    static let inquiry_title_placeholder = "stabout_inquiry_title_placeholder".localized
    static let inquiry_content_label = "stabout_inquiry_content_label".localized
    static let inquiry_content_placeholder = "stabout_inquiry_content_placeholder".localized
    static let inquiry_attachment_label = "stabout_inquiry_attachment_label".localized
    static let inquiry_submit = "stabout_inquiry_submit".localized
    static let inquiry_history_label = "stabout_inquiry_history_label".localized
    static let inquiry_no_history = "stabout_inquiry_no_history".localized
    static let inquiry_all_loaded = "stabout_inquiry_all_loaded".localized
    static let inquiry_input_error = "stabout_inquiry_input_error".localized
    static let inquiry_input_error_message = "stabout_inquiry_input_error_message".localized
    static let inquiry_success = "stabout_inquiry_success".localized
    static let inquiry_success_message = "stabout_inquiry_success_message".localized
    static let inquiry_failed = "stabout_inquiry_failed".localized
    static let inquiry_failed_message = "stabout_inquiry_failed_message".localized

    // MARK: - Inquiry Validation

    static let inquiry_error_email = "stabout_inquiry_error_email".localized
    static let inquiry_error_title = "stabout_inquiry_error_title".localized
    static let inquiry_error_content = "stabout_inquiry_error_content".localized
    static let inquiry_error_email_format = "stabout_inquiry_error_email_format".localized
    static let inquiry_error_title_length = "stabout_inquiry_error_title_length".localized
    static let inquiry_error_content_length = "stabout_inquiry_error_content_length".localized
    static let inquiry_error_network = "stabout_inquiry_error_network".localized
    static let inquiry_error_url = "stabout_inquiry_error_url".localized

    // MARK: - Inquiry List

    static let inquiry_list_title = "stabout_inquiry_list_title".localized
    static let inquiry_list_empty = "stabout_inquiry_list_empty".localized
    static let inquiry_list_first = "stabout_inquiry_list_first".localized
    static let inquiry_status_pending = "stabout_inquiry_status_pending".localized
    static let inquiry_status_replied = "stabout_inquiry_status_replied".localized

    // MARK: - Inquiry Select

    static let inquiry_select_title = "stabout_inquiry_select_title".localized
    static let inquiry_select_done = "stabout_inquiry_select_done".localized
    static let inquiry_select_done_count = "stabout_inquiry_select_done_count".localized

    // MARK: - Inquiry Thread

    static let inquiry_thread_title = "stabout_inquiry_thread_title".localized
    static let inquiry_thread_me = "stabout_inquiry_thread_me".localized
    static let inquiry_thread_waiting = "stabout_inquiry_thread_waiting".localized
    static let inquiry_thread_refresh = "stabout_inquiry_thread_refresh".localized
}

// MARK: - String Extension

private extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
}
