//
//  InquiryThreadViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

public final class InquiryThreadViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.refreshControl = self.refreshControl
        return scrollView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        return control
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()

    // 내 문의 카드
    private lazy var inquiryCardView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.cardBackground
        return view
    }()

    private lazy var inquiryAccentBar: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.primary
        return view
    }()

    private lazy var inquirySenderLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        label.text = I18N.inquiry_thread_me
        return label
    }()

    private lazy var inquiryDateLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption2
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    private lazy var inquirySubjectLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var inquiryMessageLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.body
        label.textColor = STAboutColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    // 구분선
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.inputBackground
        return view
    }()

    // 답변 카드
    private lazy var replyCardView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.cardBackground
        return view
    }()

    private lazy var replyAccentBar: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.textTertiary
        return view
    }()

    private lazy var replySenderLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.primary
        label.text = InquiryConfig.replyFromName
        return label
    }()

    private lazy var replyDateLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption2
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    private lazy var replyMessageTextView: UITextView = {
        let textView = UITextView()
        textView.font = STAboutTypography.body
        textView.textColor = STAboutColors.textPrimary
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.linkTextAttributes = [
            .foregroundColor: STAboutColors.primary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return textView
    }()

    // 대기 중 뷰
    private lazy var pendingCardView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.cardBackground
        return view
    }()

    private lazy var pendingAccentBar: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.textTertiary
        return view
    }()

    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_thread_waiting
        label.font = STAboutTypography.body
        label.textColor = STAboutColors.textSecondary
        return label
    }()

    private lazy var pendingSubLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_thread_refresh
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    // MARK: - Data

    private var record: InquiryRecord
    private let interactor = InquiryInteractor()

    // MARK: - Initialization

    init(record: InquiryRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.configureContent()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.record.status == .pending {
            self.refreshStatus()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = I18N.inquiry_thread_title

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentStackView)

        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(STAboutSpacing.lg)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.bottom.equalToSuperview().offset(-STAboutSpacing.lg)
            make.width.equalToSuperview().offset(-STAboutSpacing.lg * 2)
        }

        self.setupInquiryCard()
        self.setupDivider()
        self.setupReplyCard()
        self.setupPendingCard()
    }

    private func setupInquiryCard() {
        self.contentStackView.addArrangedSubview(self.inquiryCardView)
        self.inquiryCardView.addSubview(self.inquiryAccentBar)
        self.inquiryCardView.addSubview(self.inquirySenderLabel)
        self.inquiryCardView.addSubview(self.inquiryDateLabel)
        self.inquiryCardView.addSubview(self.inquirySubjectLabel)
        self.inquiryCardView.addSubview(self.inquiryMessageLabel)

        self.inquiryAccentBar.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }

        self.inquirySenderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(self.inquiryAccentBar.snp.trailing).offset(14)
        }

        self.inquiryDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.inquirySenderLabel)
            make.leading.equalTo(self.inquirySenderLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-14)
        }

        self.inquirySubjectLabel.snp.makeConstraints { make in
            make.top.equalTo(self.inquirySenderLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.inquiryAccentBar.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        self.inquiryMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.inquirySubjectLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.inquiryAccentBar.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    private func setupDivider() {
        self.contentStackView.addArrangedSubview(self.dividerView)

        self.dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setupReplyCard() {
        self.contentStackView.addArrangedSubview(self.replyCardView)
        self.replyCardView.addSubview(self.replyAccentBar)
        self.replyCardView.addSubview(self.replySenderLabel)
        self.replyCardView.addSubview(self.replyDateLabel)
        self.replyCardView.addSubview(self.replyMessageTextView)

        self.replyAccentBar.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }

        self.replySenderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(self.replyAccentBar.snp.trailing).offset(14)
        }

        self.replyDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.replySenderLabel)
            make.leading.equalTo(self.replySenderLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-14)
        }

        self.replyMessageTextView.snp.makeConstraints { make in
            make.top.equalTo(self.replySenderLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.replyAccentBar.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    private func setupPendingCard() {
        self.contentStackView.addArrangedSubview(self.pendingCardView)
        self.pendingCardView.addSubview(self.pendingAccentBar)
        self.pendingCardView.addSubview(self.pendingLabel)
        self.pendingCardView.addSubview(self.pendingSubLabel)

        self.pendingAccentBar.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }

        self.pendingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(STAboutSpacing.xxl)
            make.leading.equalTo(self.pendingAccentBar.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        self.pendingSubLabel.snp.makeConstraints { make in
            make.top.equalTo(self.pendingLabel.snp.bottom).offset(STAboutSpacing.sm)
            make.leading.equalTo(self.pendingAccentBar.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-STAboutSpacing.xxl)
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        self.refreshStatus()
    }

    // MARK: - Private Methods

    private func configureContent() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"

        self.inquirySubjectLabel.text = self.record.subject
        self.inquiryMessageLabel.text = self.record.message
        self.inquiryDateLabel.text = dateFormatter.string(from: self.record.createdAt)

        self.updateReplySection()
    }

    private func updateReplySection() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"

        switch self.record.status {
            case .replied:
                self.dividerView.isHidden = false
                self.replyCardView.isHidden = false
                self.pendingCardView.isHidden = true

                self.replyMessageTextView.text = self.record.reply ?? ""
                if let repliedAt = self.record.repliedAt {
                    self.replyDateLabel.text = dateFormatter.string(from: repliedAt)
                }
                else {
                    self.replyDateLabel.text = ""
                }

            case .pending:
                self.dividerView.isHidden = false
                self.replyCardView.isHidden = true
                self.pendingCardView.isHidden = false
        }
    }

    private func refreshStatus() {
        guard self.record.status == .pending else {
            self.refreshControl.endRefreshing()
            return
        }

        Task {
            let results = await self.interactor.fetchStatuses(inquiryIds: [self.record.id])

            await MainActor.run { [weak self] in
                guard let self = self else { return }

                if let result = results.first, result.status == "답변완료" {
                    self.record.status = .replied
                    self.record.reply = result.reply
                    if let repliedAtString = result.repliedAt {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.record.repliedAt = formatter.date(from: repliedAtString)
                    }
                    InquiryHistoryStore.shared.update(self.record)
                    self.updateReplySection()
                }

                self.refreshControl.endRefreshing()
            }
        }
    }
}
