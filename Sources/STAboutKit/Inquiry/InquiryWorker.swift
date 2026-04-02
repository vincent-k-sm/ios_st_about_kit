//
//  InquiryWorker.swift
//  STAboutKit
//

import Foundation

protocol InquiryWorkerProtocol {
    func submitInquiry(
        email: String,
        subject: String,
        message: String,
        attachments: [InquiryAttachment]
    ) async -> Inquiry.SubmitInquiry.Response

    func fetchStatuses(inquiryIds: [String]) async -> [Inquiry.StatusResult]
    func fetchInquiries(deviceId: String) async -> [Inquiry.ServerInquiryResult]
}

final class InquiryWorker: InquiryWorkerProtocol {
    deinit { }

    // MARK: - Submit Inquiry

    func submitInquiry(
        email: String,
        subject: String,
        message: String,
        attachments: [InquiryAttachment]
    ) async -> Inquiry.SubmitInquiry.Response {
        guard let url = URL(string: InquiryConfig.apiURL) else {
            return Inquiry.SubmitInquiry.Response(
                success: false,
                inquiryId: nil,
                errorMessage: I18N.inquiry_error_url
            )
        }

        var body: [String: Any] = [
            "spreadsheetId": InquiryConfig.spreadsheetId,
            "serviceName": InquiryConfig.serviceName,
            "slackWebhookUrl": InquiryConfig.slackWebhookUrl,
            "replyFromName": InquiryConfig.replyFromName,
            "deviceId": InquiryConfig.deviceId,
            "email": email,
            "subject": subject,
            "message": message
        ]

        if !attachments.isEmpty {
            body["attachments"] = attachments.map { [
                "filename": $0.filename,
                "mimeType": $0.mimeType,
                "data": $0.data
            ] }
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            STAboutLog.d("Submit response:\n\(data.prettyJson ?? String(data: data, encoding: .utf8) ?? "(binary)")")
            let apiResponse = try JSONDecoder().decode(InquirySubmitAPIResponse.self, from: data)

            if apiResponse.success {
                return Inquiry.SubmitInquiry.Response(
                    success: true,
                    inquiryId: apiResponse.inquiryId,
                    errorMessage: nil
                )
            }
            else {
                return Inquiry.SubmitInquiry.Response(
                    success: false,
                    inquiryId: nil,
                    errorMessage: apiResponse.error ?? I18N.inquiry_failed_message
                )
            }
        }
        catch {
            STAboutLog.e("Inquiry submit failed: \(error)")
            return Inquiry.SubmitInquiry.Response(
                success: false,
                inquiryId: nil,
                errorMessage: I18N.inquiry_error_network
            )
        }
    }

    // MARK: - Fetch Statuses

    func fetchStatuses(inquiryIds: [String]) async -> [Inquiry.StatusResult] {
        guard !inquiryIds.isEmpty else { return [] }

        let ids = inquiryIds.joined(separator: ",")
        let urlString = "\(InquiryConfig.apiURL)?action=statusBatch&spreadsheetId=\(InquiryConfig.spreadsheetId)&serviceName=\(InquiryConfig.serviceName)&inquiryIds=\(ids)"

        guard let url = URL(string: urlString) else {
            STAboutLog.e("Invalid status batch URL")
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            STAboutLog.d("StatusBatch response:\n\(data.prettyJson ?? String(data: data, encoding: .utf8) ?? "(binary)")")
            let response = try JSONDecoder().decode(Inquiry.StatusBatchResponse.self, from: data)

            if response.isSuccess {
                return response.results ?? []
            }

            if let message = response.message {
                STAboutLog.w("Status batch API: \(message)")
            }
            return []
        }
        catch {
            STAboutLog.e("Status batch fetch failed: \(error)")
            return []
        }
    }
    // MARK: - Fetch Inquiries by DeviceId

    func fetchInquiries(deviceId: String) async -> [Inquiry.ServerInquiryResult] {
        let urlString = "\(InquiryConfig.apiURL)?action=fetchByDeviceId&spreadsheetId=\(InquiryConfig.spreadsheetId)&serviceName=\(InquiryConfig.serviceName)&deviceId=\(deviceId)"

        guard let url = URL(string: urlString) else {
            STAboutLog.e("Invalid fetchByDeviceId URL")
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            STAboutLog.d("FetchByDeviceId response:\n\(data.prettyJson ?? String(data: data, encoding: .utf8) ?? "(binary)")")
            let response = try JSONDecoder().decode(Inquiry.FetchByDeviceResponse.self, from: data)

            if response.isSuccess {
                return response.results ?? []
            }

            return []
        }
        catch {
            STAboutLog.e("FetchByDeviceId failed: \(error)")
            return []
        }
    }
}

// MARK: - Private Response Model

private struct InquirySubmitAPIResponse: Codable {
    let success: Bool
    let inquiryId: String?
    let error: String?
}
