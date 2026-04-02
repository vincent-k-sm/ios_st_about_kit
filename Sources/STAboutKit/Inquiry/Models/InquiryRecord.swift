//
//  InquiryRecord.swift
//  STAboutKit
//

import Foundation

enum InquiryStatus: String, Codable {
    case pending = "대기중"
    case replied = "답변완료"
}

struct InquiryRecord: Codable, Identifiable {
    let id: String
    let email: String
    let subject: String
    let message: String
    let createdAt: Date
    var status: InquiryStatus
    var reply: String?
    var repliedAt: Date?
}
