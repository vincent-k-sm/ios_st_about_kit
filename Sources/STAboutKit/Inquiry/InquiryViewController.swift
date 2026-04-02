//
//  InquiryViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

protocol InquiryDisplayLogic: AnyObject {
    func displayValidation(viewModel: Inquiry.Validation.ViewModel)
    func displaySubmitResult(viewModel: Inquiry.SubmitInquiry.ViewModel)
}

public final class InquiryViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = STAboutColors.background
        scrollView.keyboardDismissMode = .none
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.background
        return view
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_email_label
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        return label
    }()

    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: I18N.inquiry_email_placeholder,
            attributes: [.foregroundColor: STAboutColors.textTertiary]
        )
        textField.font = STAboutTypography.body
        textField.textColor = STAboutColors.textPrimary
        textField.backgroundColor = STAboutColors.inputBackground
        textField.layer.cornerRadius = 8
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.emailTextFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    private lazy var subjectLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_title_label
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        return label
    }()

    private lazy var subjectTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: I18N.inquiry_title_placeholder,
            attributes: [.foregroundColor: STAboutColors.textTertiary]
        )
        textField.font = STAboutTypography.body
        textField.textColor = STAboutColors.textPrimary
        textField.backgroundColor = STAboutColors.inputBackground
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        textField.delegate = self
        return textField
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_content_label
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        return label
    }()

    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = STAboutTypography.body
        textView.textColor = STAboutColors.textPrimary
        textView.backgroundColor = STAboutColors.inputBackground
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.delegate = self
        return textView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_content_placeholder
        label.font = STAboutTypography.body
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    private lazy var environmentInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.inputBackground
        view.layer.cornerRadius = 8

        let label = UILabel()
        label.numberOfLines = 0
        label.font = STAboutTypography.caption2
        label.textColor = STAboutColors.textTertiary
        label.text = Self.environmentInfoText()

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        return view
    }()

    private lazy var attachmentLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_attachment_label
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        label.isHidden = true
        return label
    }()

    private lazy var attachmentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(I18N.inquiry_submit, for: .normal)
        button.titleLabel?.font = STAboutTypography.bodyBold
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = STAboutColors.primary
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(self.submitButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var previousInquiryLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_history_label
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        label.isHidden = true
        return label
    }()

    private lazy var previousInquiryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private lazy var domainDropdownContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.isHidden = true
        return view
    }()

    private lazy var domainDropdownView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = STAboutColors.cardBackground
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.separatorColor = STAboutColors.separator
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.isScrollEnabled = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DomainCell")
        return tableView
    }()

    // MARK: - Data

    private let emailDomains: [String] = [
        "naver.com",
        "gmail.com",
        "daum.net",
        "kakao.com",
        "hanmail.net",
        "nate.com",
        "icloud.com",
        "outlook.com",
        "yahoo.com"
    ]

    private var filteredDomains: [String] = []

    // MARK: - Properties

    private var interactor: InquiryBusinessLogic?
    private var isSubmitting = false
    private var attachmentItems: [Inquiry.AttachmentItem] = []
    private var loadedRecords: [InquiryRecord] = []
    private var domainDropdownHeightConstraint: Constraint?

    // MARK: - Initialization

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: - Setup

    private func setup() {
        let viewController = self
        let interactor = InquiryInteractor()
        let presenter = InquiryPresenter()

        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: - Public Configuration

    /// 첨부 파일 제공자를 통해 첨부 파일 설정
    /// - Parameter provider: 첨부 파일 제공자
    public func configure(attachmentProvider: InquiryAttachmentProvider) {
        let attachments = attachmentProvider.provideAttachments()
        self.attachmentItems = attachments.map { Inquiry.AttachmentItem(attachment: $0) }
    }

    /// 첨부 파일 직접 설정
    /// - Parameter attachments: 첨부할 파일 목록
    public func configure(attachments: [InquiryAttachment]) {
        self.attachmentItems = attachments.map { Inquiry.AttachmentItem(attachment: $0) }
    }

    /// 본문 사전 입력
    /// - Parameter body: 미리 채워넣을 본문 텍스트
    private var prefillBody: String?
    private var prefillSubject: String?
    public func configure(prefillBody: String, subject: String = "광고 미제거 신고") {
        self.prefillBody = prefillBody
        self.prefillSubject = subject
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupKeyboardObservers()
        self.setupTapGesture()
        self.updateAttachmentUI()
        self.updateNavigationButton()
        self.loadPreviousEmail()
        if let subject = self.prefillSubject {
            self.subjectTextField.text = subject
        }
        if let body = self.prefillBody {
            self.messageTextView.text = body
            self.placeholderLabel.isHidden = true
        }
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = I18N.inquiry_nav_title

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)

        self.contentView.addSubview(self.emailLabel)
        self.contentView.addSubview(self.emailTextField)
        self.contentView.addSubview(self.subjectLabel)
        self.contentView.addSubview(self.subjectTextField)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.messageTextView)
        self.messageTextView.addSubview(self.placeholderLabel)
        self.contentView.addSubview(self.environmentInfoView)
        self.contentView.addSubview(self.attachmentLabel)
        self.contentView.addSubview(self.attachmentStackView)
        self.contentView.addSubview(self.submitButton)
        self.submitButton.addSubview(self.loadingIndicator)
        self.contentView.addSubview(self.previousInquiryLabel)
        self.contentView.addSubview(self.previousInquiryStackView)

        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        self.emailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(STAboutSpacing.lg)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.height.equalTo(48)
        }

        self.subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(STAboutSpacing.lg)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.subjectTextField.snp.makeConstraints { make in
            make.top.equalTo(self.subjectLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.height.equalTo(48)
        }

        self.messageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subjectTextField.snp.bottom).offset(STAboutSpacing.lg)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.messageTextView.snp.makeConstraints { make in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.height.equalTo(200)
        }

        self.placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(13)
        }

        self.environmentInfoView.snp.makeConstraints { make in
            make.top.equalTo(self.messageTextView.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.attachmentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.environmentInfoView.snp.bottom).offset(STAboutSpacing.lg)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.attachmentStackView.snp.makeConstraints { make in
            make.top.equalTo(self.attachmentLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.submitButton.snp.makeConstraints { make in
            make.top.equalTo(self.attachmentStackView.snp.bottom).offset(STAboutSpacing.xl)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.height.equalTo(52)
        }

        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.previousInquiryLabel.snp.makeConstraints { make in
            make.top.equalTo(self.submitButton.snp.bottom).offset(STAboutSpacing.xl)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.previousInquiryStackView.snp.makeConstraints { make in
            make.top.equalTo(self.previousInquiryLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.bottom.equalToSuperview().offset(-STAboutSpacing.container)
        }

        self.view.addSubview(self.domainDropdownContainer)
        self.domainDropdownContainer.addSubview(self.domainDropdownView)

        self.domainDropdownContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.emailTextField)
            make.top.equalTo(self.emailTextField.snp.bottom).offset(4)
            self.domainDropdownHeightConstraint = make.height.equalTo(0).constraint
        }

        self.domainDropdownView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(tapGesture)
    }

    private func updateAttachmentUI() {
        let hasAttachments = !self.attachmentItems.isEmpty
        self.attachmentLabel.isHidden = !hasAttachments
        self.attachmentStackView.isHidden = !hasAttachments

        // 기존 뷰 제거
        self.attachmentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 첨부 파일 뷰 추가
        for (index, item) in self.attachmentItems.enumerated() {
            let attachmentView = self.createAttachmentItemView(item: item, index: index)
            self.attachmentStackView.addArrangedSubview(attachmentView)
        }
    }

    private func createAttachmentItemView(item: Inquiry.AttachmentItem, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = STAboutColors.inputBackground
        containerView.layer.cornerRadius = 8

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "doc.fill")
        iconImageView.tintColor = STAboutColors.textSecondary
        iconImageView.contentMode = .scaleAspectFit

        let filenameLabel = UILabel()
        filenameLabel.text = item.filename
        filenameLabel.font = STAboutTypography.body
        filenameLabel.textColor = STAboutColors.textPrimary
        filenameLabel.lineBreakMode = .byTruncatingMiddle

        let sizeLabel = UILabel()
        sizeLabel.text = item.fileSize
        sizeLabel.font = STAboutTypography.caption1
        sizeLabel.textColor = STAboutColors.textSecondary

        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = STAboutColors.textTertiary
        deleteButton.tag = index
        deleteButton.addTarget(self, action: #selector(self.deleteAttachmentTapped(_:)), for: .touchUpInside)

        containerView.addSubview(iconImageView)
        containerView.addSubview(filenameLabel)
        containerView.addSubview(sizeLabel)
        containerView.addSubview(deleteButton)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        filenameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
        }

        sizeLabel.snp.makeConstraints { make in
            make.leading.equalTo(filenameLabel)
            make.top.equalTo(filenameLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-10)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(52)
        }

        return containerView
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
        self.hideDomainDropdown()
    }

    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""

        guard let atIndex = text.firstIndex(of: "@") else {
            self.hideDomainDropdown()
            return
        }

        let domainPart = String(text[text.index(after: atIndex)...])

        if domainPart.isEmpty {
            self.filteredDomains = self.emailDomains
        }
        else {
            self.filteredDomains = self.emailDomains.filter { $0.hasPrefix(domainPart) }
        }

        // 이미 완전한 도메인이 입력된 경우 숨김
        if self.emailDomains.contains(domainPart) {
            self.hideDomainDropdown()
            return
        }

        if self.filteredDomains.isEmpty {
            self.hideDomainDropdown()
        }
        else {
            self.showDomainDropdown()
        }
    }

    @objc private func submitButtonTapped() {
        guard !self.isSubmitting else { return }

        self.view.endEditing(true)

        let email = self.emailTextField.text ?? ""
        let subject = self.subjectTextField.text ?? ""
        let message = self.messageTextView.text ?? ""

        let request = Inquiry.Validation.Request(
            email: email,
            subject: subject,
            message: message
        )
        self.interactor?.validateInput(request: request)
    }

    @objc private func loadPreviousInquiryTapped() {
        let allRecords = InquiryHistoryStore.shared.fetchAll()
        let loadedIds = Set(self.loadedRecords.map { $0.id })
        let availableRecords = allRecords.filter { !loadedIds.contains($0.id) }

        guard !availableRecords.isEmpty else {
            let message = allRecords.isEmpty ? I18N.inquiry_no_history : I18N.inquiry_all_loaded
            self.showAlert(title: I18N.common_alert, message: message)
            return
        }

        let selectVC = InquirySelectViewController(records: availableRecords)
        selectVC.onSelected = { [weak self] selectedRecords in
            guard let self = self else { return }
            for record in selectedRecords {
                self.appendPreviousInquiry(record)
            }
        }
        let nav = UINavigationController(rootViewController: selectVC)
        self.present(nav, animated: true)
    }

    @objc private func deleteAttachmentTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < self.attachmentItems.count else { return }

        self.attachmentItems.remove(at: index)
        self.updateAttachmentUI()
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }

    // MARK: - Private Methods

    private func setSubmitting(_ submitting: Bool) {
        self.isSubmitting = submitting

        if submitting {
            self.submitButton.setTitle("", for: .normal)
            self.loadingIndicator.startAnimating()
            self.submitButton.isEnabled = false
        }
        else {
            self.submitButton.setTitle(I18N.inquiry_submit, for: .normal)
            self.loadingIndicator.stopAnimating()
            self.submitButton.isEnabled = true
        }
    }

    private func showDomainDropdown() {
        let maxVisibleCount = min(self.filteredDomains.count, 5)
        let height = CGFloat(maxVisibleCount) * 44.0

        self.domainDropdownHeightConstraint?.update(offset: height)
        self.domainDropdownContainer.isHidden = false
        self.domainDropdownView.reloadData()
        self.view.bringSubviewToFront(self.domainDropdownContainer)
    }

    private func hideDomainDropdown() {
        self.domainDropdownContainer.isHidden = true
        self.domainDropdownHeightConstraint?.update(offset: 0)
    }

    private func selectDomain(_ domain: String) {
        guard let text = self.emailTextField.text,
              let atIndex = text.firstIndex(of: "@")
        else { return }

        let localPart = String(text[text.startIndex...atIndex])
        self.emailTextField.text = localPart + domain
        self.hideDomainDropdown()
        self.subjectTextField.becomeFirstResponder()
    }

    private func updateNavigationButton() {
        let hasRecords = !InquiryHistoryStore.shared.fetchAll().isEmpty

        if hasRecords {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "clock.arrow.circlepath"),
                style: .plain,
                target: self,
                action: #selector(self.loadPreviousInquiryTapped)
            )
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    private func loadPreviousEmail() {
        let records = InquiryHistoryStore.shared.fetchAll()
        if let lastEmail = records.first?.email, !lastEmail.isEmpty {
            self.emailTextField.text = lastEmail
        }
    }

    private func appendPreviousInquiry(_ record: InquiryRecord) {
        self.loadedRecords.append(record)
        self.previousInquiryLabel.isHidden = false

        let cardView = self.createPreviousInquiryCard(record)
        self.previousInquiryStackView.addArrangedSubview(cardView)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    private func createPreviousInquiryCard(_ record: InquiryRecord) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = STAboutColors.cardBackground
        cardView.layer.cornerRadius = 12

        let label = UILabel()
        label.numberOfLines = 0
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textSecondary

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"

        var text = "ID: \(record.id)\n"
        text += "제목: \(record.subject)\n"
        text += "일시: \(dateFormatter.string(from: record.createdAt))\n\n"
        text += record.message

        if record.status == .replied, let reply = record.reply {
            text += "\n\n--- 답변"
            if let repliedAt = record.repliedAt {
                text += " (\(dateFormatter.string(from: repliedAt)))"
            }
            text += " ---\n"
            text += reply
        }

        label.text = text

        cardView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        return cardView
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: I18N.common_confirm, style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true)
    }

    private static func environmentInfoText() -> String {
        if let provider = InquiryConfig.environmentInfoProvider {
            return provider()
        }

        // fallback: 기본 기기 정보만
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"

        var model = device.model
        var sysInfo = utsname()
        uname(&sysInfo)
        let machine = withUnsafePointer(to: &sysInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        if !machine.isEmpty {
            model = machine
        }

        let info = "기기: \(model) | iOS \(device.systemVersion) | 앱 v\(appVersion) (\(buildNumber))"
        return info
    }
}

// MARK: - InquiryDisplayLogic

extension InquiryViewController: InquiryDisplayLogic {

    func displayValidation(viewModel: Inquiry.Validation.ViewModel) {
        if viewModel.isValid {
            // 유효성 검사 통과 -> 제출 진행
            self.setSubmitting(true)

            let email = self.emailTextField.text ?? ""
            let subject = self.subjectTextField.text ?? ""
            var message = self.messageTextView.text ?? ""
            let attachments = self.attachmentItems.map { $0.attachment }

            message += "\n\n--- 환경 정보 ---\n\(Self.environmentInfoText())"

            if !self.loadedRecords.isEmpty {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"

                message += "\n\n--- 이전 문의 내역 ---"
                for record in self.loadedRecords {
                    message += "\n\n[ID: \(record.id)]"
                    message += "\n제목: \(record.subject)"
                    message += "\n일시: \(dateFormatter.string(from: record.createdAt))"
                    message += "\n내용: \(record.message)"
                    if record.status == .replied, let reply = record.reply {
                        message += "\n답변: \(reply)"
                    }
                }
            }

            let request = Inquiry.SubmitInquiry.Request(
                email: email,
                subject: subject,
                message: message,
                attachments: attachments
            )
            self.interactor?.submitInquiry(request: request)
        }
        else {
            // 유효성 검사 실패
            self.showAlert(title: I18N.inquiry_input_error, message: viewModel.errorMessage ?? I18N.inquiry_input_error_message)
        }
    }

    func displaySubmitResult(viewModel: Inquiry.SubmitInquiry.ViewModel) {
        self.setSubmitting(false)

        if viewModel.isSuccess {
            self.showAlert(title: I18N.inquiry_success, message: viewModel.message, completion: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
        }
        else {
            self.showAlert(title: I18N.inquiry_failed, message: viewModel.message)
        }
    }
}

// MARK: - UITextFieldDelegate

extension InquiryViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.hideDomainDropdown()
            self.subjectTextField.becomeFirstResponder()
        }
        else if textField == self.subjectTextField {
            self.messageTextView.becomeFirstResponder()
        }
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            self.hideDomainDropdown()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate (Domain Dropdown)

extension InquiryViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDomains.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell", for: indexPath)
        let domain = self.filteredDomains[indexPath.row]
        cell.textLabel?.text = "@\(domain)"
        cell.textLabel?.font = STAboutTypography.body
        cell.textLabel?.textColor = STAboutColors.textPrimary
        cell.backgroundColor = STAboutColors.cardBackground
        cell.selectionStyle = .default
        let selectedBgView = UIView()
        selectedBgView.backgroundColor = STAboutColors.inputBackground
        cell.selectedBackgroundView = selectedBgView
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let domain = self.filteredDomains[indexPath.row]
        self.selectDomain(domain)
    }
}

// MARK: - UITextViewDelegate

extension InquiryViewController: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
