//
//  InquiryPresenter.swift
//  STAboutKit
//

import Foundation

protocol InquiryPresentationLogic {
    func presentValidation(response: Inquiry.Validation.Response)
    func presentSubmitResult(response: Inquiry.SubmitInquiry.Response)
}

final class InquiryPresenter: InquiryPresentationLogic {
    deinit { }

    // MARK: - Properties

    weak var viewController: InquiryDisplayLogic?

    // MARK: - Presentation Logic

    func presentValidation(response: Inquiry.Validation.Response) {
        let viewModel = Inquiry.Validation.ViewModel(
            isValid: response.isValid,
            errorMessage: response.errorMessage
        )
        self.viewController?.displayValidation(viewModel: viewModel)
    }

    func presentSubmitResult(response: Inquiry.SubmitInquiry.Response) {
        let message: String
        if response.success {
            message = I18N.inquiry_success_message
        }
        else {
            message = response.errorMessage ?? I18N.inquiry_failed_message
        }

        let viewModel = Inquiry.SubmitInquiry.ViewModel(
            isSuccess: response.success,
            message: message
        )
        self.viewController?.displaySubmitResult(viewModel: viewModel)
    }
}
