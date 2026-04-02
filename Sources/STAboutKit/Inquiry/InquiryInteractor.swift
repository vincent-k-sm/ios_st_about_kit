//
//  InquiryInteractor.swift
//  STAboutKit
//

import Foundation

protocol InquiryBusinessLogic {
    func validateInput(request: Inquiry.Validation.Request)
    func submitInquiry(request: Inquiry.SubmitInquiry.Request)
    func fetchStatuses(inquiryIds: [String]) async -> [Inquiry.StatusResult]
    func syncWithServer() async -> [InquiryRecord]
}

protocol InquiryDataStore { }

final class InquiryInteractor: InquiryBusinessLogic, InquiryDataStore {
    deinit { }

    // MARK: - Properties

    var presenter: InquiryPresentationLogic?

    private let worker: InquiryWorkerProtocol

    // MARK: - Initialization

    init(worker: InquiryWorkerProtocol = InquiryWorker()) {
        self.worker = worker
    }

    // MARK: - Business Logic

    func validateInput(request: Inquiry.Validation.Request) {
        let email = request.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = request.subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = request.message.trimmingCharacters(in: .whitespacesAndNewlines)

        // 빈 값 체크
        if email.isEmpty {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_email)
            self.presenter?.presentValidation(response: response)
            return
        }

        if subject.isEmpty {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_title)
            self.presenter?.presentValidation(response: response)
            return
        }

        if message.isEmpty {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_content)
            self.presenter?.presentValidation(response: response)
            return
        }

        // 이메일 형식 체크
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_email_format)
            self.presenter?.presentValidation(response: response)
            return
        }

        // 길이 체크
        if subject.count > 200 {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_title_length)
            self.presenter?.presentValidation(response: response)
            return
        }

        if message.count > 5000 {
            let response = Inquiry.Validation.Response(isValid: false, errorMessage: I18N.inquiry_error_content_length)
            self.presenter?.presentValidation(response: response)
            return
        }

        let response = Inquiry.Validation.Response(isValid: true, errorMessage: nil)
        self.presenter?.presentValidation(response: response)
    }

    func submitInquiry(request: Inquiry.SubmitInquiry.Request) {
        let email = request.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = request.subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = request.message.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            let workerResponse = await self.worker.submitInquiry(
                email: email,
                subject: subject,
                message: message,
                attachments: request.attachments
            )

            await MainActor.run {
                if workerResponse.success, let inquiryId = workerResponse.inquiryId {
                    let record = InquiryRecord(
                        id: inquiryId,
                        email: email,
                        subject: subject,
                        message: message,
                        createdAt: Date(),
                        status: .pending,
                        reply: nil,
                        repliedAt: nil
                    )
                    InquiryHistoryStore.shared.save(record)
                }

                self.presenter?.presentSubmitResult(response: workerResponse)
            }
        }
    }

    func fetchStatuses(inquiryIds: [String]) async -> [Inquiry.StatusResult] {
        return await self.worker.fetchStatuses(inquiryIds: inquiryIds)
    }

    func syncWithServer() async -> [InquiryRecord] {
        let deviceId = InquiryConfig.deviceId
        let serverResults = await self.worker.fetchInquiries(deviceId: deviceId)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let serverRecords: [InquiryRecord] = serverResults.map { result in
            let createdAt: Date
            if let dateString = result.createdAt {
                createdAt = dateFormatter.date(from: dateString) ?? Date()
            }
            else {
                createdAt = Date()
            }

            let repliedAt: Date?
            if let repliedAtString = result.repliedAt {
                repliedAt = dateFormatter.date(from: repliedAtString)
            }
            else {
                repliedAt = nil
            }

            let status: InquiryStatus = result.status == "답변완료" ? .replied : .pending

            return InquiryRecord(
                id: result.inquiryId,
                email: result.email ?? "",
                subject: result.subject,
                message: result.message,
                createdAt: createdAt,
                status: status,
                reply: result.reply,
                repliedAt: repliedAt
            )
        }

        InquiryHistoryStore.shared.merge(serverRecords)
        return InquiryHistoryStore.shared.fetchAll()
    }
}
