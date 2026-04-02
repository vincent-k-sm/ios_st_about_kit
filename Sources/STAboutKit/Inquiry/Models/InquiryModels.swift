//
//  InquiryModels.swift
//  STAboutKit
//

import Foundation

// MARK: - Attachment Model

public struct InquiryAttachment: Codable {
    public let filename: String
    public let mimeType: String
    public let data: String  // Base64 encoded

    public init(filename: String, mimeType: String, data: Data) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = data.base64EncodedString()
    }

    public init(filename: String, mimeType: String, base64Data: String) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = base64Data
    }
}

// MARK: - Attachment Provider Protocol

/// 문의 화면에 첨부 파일을 주입하기 위한 프로토콜
/// 로그 파일, 스크린샷 등 다양한 첨부 파일을 외부에서 주입할 수 있음
public protocol InquiryAttachmentProvider {
    /// 첨부할 파일 목록 반환
    func provideAttachments() -> [InquiryAttachment]
}

// MARK: - Default Attachment Providers

/// 로그 파일 첨부 제공자
public final class LogFileAttachmentProvider: InquiryAttachmentProvider {
    deinit { }

    private let logFileURL: URL?

    public init(logFileURL: URL?) {
        self.logFileURL = logFileURL
    }

    public func provideAttachments() -> [InquiryAttachment] {
        guard let url = self.logFileURL,
              let data = try? Data(contentsOf: url)
        else {
            return []
        }

        let filename = url.lastPathComponent
        return [InquiryAttachment(filename: filename, mimeType: "text/plain", data: data)]
    }
}

/// 여러 첨부 파일 제공자를 합치는 복합 제공자
public final class CompositeAttachmentProvider: InquiryAttachmentProvider {
    deinit { }

    private let providers: [InquiryAttachmentProvider]

    public init(providers: [InquiryAttachmentProvider]) {
        self.providers = providers
    }

    public func provideAttachments() -> [InquiryAttachment] {
        return self.providers.flatMap { $0.provideAttachments() }
    }
}

/// 직접 첨부 파일 데이터를 주입하는 제공자
public final class DirectAttachmentProvider: InquiryAttachmentProvider {
    deinit { }

    private let attachments: [InquiryAttachment]

    public init(attachments: [InquiryAttachment]) {
        self.attachments = attachments
    }

    public func provideAttachments() -> [InquiryAttachment] {
        return self.attachments
    }
}

// MARK: - Inquiry Models

public enum Inquiry {

    // MARK: - Attachment Display

    public struct AttachmentItem {
        public let filename: String
        public let fileSize: String
        public let attachment: InquiryAttachment

        public init(attachment: InquiryAttachment) {
            self.filename = attachment.filename
            self.attachment = attachment

            // Base64 디코딩하여 원본 크기 계산
            if let data = Data(base64Encoded: attachment.data) {
                self.fileSize = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
            }
            else {
                self.fileSize = I18N.common_unknown
            }
        }
    }

    // MARK: - Submit Inquiry

    public enum SubmitInquiry {

        public struct Request {
            let email: String
            let subject: String
            let message: String
            let attachments: [InquiryAttachment]
        }

        public struct Response {
            let success: Bool
            let inquiryId: String?
            let errorMessage: String?
        }

        public struct ViewModel {
            let isSuccess: Bool
            let message: String
        }
    }

    // MARK: - Validation

    public enum Validation {

        public struct Request {
            let email: String
            let subject: String
            let message: String
        }

        public struct Response {
            let isValid: Bool
            let errorMessage: String?
        }

        public struct ViewModel {
            let isValid: Bool
            let errorMessage: String?
        }
    }

    // MARK: - Status Batch

    public struct StatusResult: Codable {
        public let inquiryId: String
        public let status: String
        public let reply: String?
        public let repliedAt: String?
    }

    public struct StatusBatchResponse: Codable {
        public let success: Bool?
        public let results: [StatusResult]?
        public let error: String?
        public let status: String?
        public let message: String?

        public var isSuccess: Bool {
            return self.success == true
        }
    }

    // MARK: - Fetch By DeviceId

    public struct ServerInquiryResult: Codable {
        public let inquiryId: String
        public let email: String?
        public let subject: String
        public let message: String
        public let createdAt: String?
        public let status: String
        public let reply: String?
        public let repliedAt: String?
    }

    public struct FetchByDeviceResponse: Codable {
        public let success: Bool?
        public let results: [ServerInquiryResult]?
        public let error: String?

        public var isSuccess: Bool {
            return self.success == true
        }
    }
}
