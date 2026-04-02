//
//  STAboutListViewController.swift
//  STAboutKit
//

import SnapKit
import StoreKit
import UIKit

open class STAboutListViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = STAboutColors.background
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 62, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(STAboutListCell.self, forCellReuseIdentifier: STAboutListCell.stIdentifier)
        tableView.register(STAboutListHeaderView.self, forHeaderFooterViewReuseIdentifier: STAboutListHeaderView.stIdentifier)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    // MARK: - Properties

    public let configuration: STAboutConfiguration
    private var allSections: [[STAboutItem]] = []
    private var sectionTitles: [String?] = []

    // MARK: - Initialization

    public init(configuration: STAboutConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.buildSections()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buildSections()
        self.tableView.reloadData()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = self.configuration.sceneTitle

        self.view.addSubview(self.tableView)
        self.hidesBottomBarWhenPushed = true
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Section Building

    private func buildSections() {
        var sections: [[STAboutItem]] = []
        var titles: [String?] = []

        // Help 섹션
        var helpItems: [STAboutItem] = []

        if self.configuration.faqURL != nil {
            helpItems.append(STAboutItem(
                title: I18N.menu_faq,
                iconName: "questionmark.circle",
                action: { [weak self] in
                    guard let self = self else { return }
                    self.openURL(self.configuration.faqURL ?? "", title: I18N.menu_faq)
                }
            ))
        }

        helpItems.append(STAboutItem(
            title: I18N.menu_contact,
            iconName: "envelope",
            action: { [weak self] in
                self?.handleContact()
            }
        ))

        sections.append(helpItems)
        titles.append(I18N.section_help)

        // Share 섹션
        var shareItems: [STAboutItem] = []

        shareItems.append(STAboutItem(
            title: I18N.menu_share,
            iconName: "square.and.arrow.up",
            action: { [weak self] in
                self?.handleShareApp()
            }
        ))

        shareItems.append(STAboutItem(
            title: I18N.menu_review,
            iconName: "star",
            action: { [weak self] in
                self?.handleWriteReview()
            }
        ))

        sections.append(shareItems)
        titles.append(I18N.section_share)

        // Additional 섹션
        let additional = self.additionalSections()
        for section in additional {
            sections.append(section.items)
            titles.append(section.headerTitle)
        }

        // Info 섹션
        var infoItems: [STAboutItem] = []

        infoItems.append(STAboutItem(
            title: I18N.menu_open_source,
            iconName: "chevron.left.forwardslash.chevron.right",
            action: { [weak self] in
                self?.showOpenSourceList()
            }
        ))

        infoItems.append(STAboutItem(
            title: I18N.menu_privacy,
            iconName: "hand.raised",
            action: { [weak self] in
                guard let self = self else { return }
                self.openURL(self.configuration.privacyPolicyURL, title: I18N.menu_privacy)
            }
        ))

        infoItems.append(STAboutItem(
            title: I18N.menu_terms,
            iconName: "doc.text",
            action: { [weak self] in
                guard let self = self else { return }
                self.openURL(self.configuration.termsOfServiceURL, title: I18N.menu_terms)
            }
        ))

        infoItems.append(STAboutItem(
            title: I18N.menu_version,
            iconName: "info.circle",
            accessory: .label(self.configuration.appVersion),
            action: { [weak self] in
                guard let self = self else { return }
                let urlString = "https://apps.apple.com/app/id\(self.configuration.appId)"
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            }
        ))

        sections.append(infoItems)
        titles.append(I18N.section_info)

        self.allSections = sections
        self.sectionTitles = titles
    }

    // MARK: - Open Override Points

    /// 프로젝트별 추가 섹션. Share와 Info 사이에 삽입됩니다.
    open func additionalSections() -> [STAboutSection] {
        return []
    }

    /// 토스트 메시지 표시
    open func showToast(_ message: String) { }

    /// 문의하기 커스텀 처리. 기본: 카카오톡 옵션이 있으면 ActionSheet, 없으면 이메일.
    /// 완전히 커스텀하려면 오버라이드.
    open func handleContactAction() {
        guard self.configuration.inquiryConfig != nil else { return }
        let listVC = InquiryListViewController()
        self.navigationController?.pushViewController(listVC, animated: true)
    }

    // MARK: - Private Methods

    private func handleContact() {
        guard let kakaoURL = self.configuration.kakaoOpenChatURL else {
            self.handleContactAction()
            return
        }

        let alert = UIAlertController(
            title: I18N.contact_action_title,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: I18N.contact_inquiry, style: .default, handler: { [weak self] _ in
            self?.handleContactAction()
        }))

        alert.addAction(UIAlertAction(title: I18N.contact_kakao, style: .default, handler: { [weak self] _ in
            guard let url = URL(string: kakaoURL) else { return }
            UIApplication.shared.open(url)
        }))

        alert.addAction(UIAlertAction(title: I18N.common_cancel, style: .cancel))

        self.present(alert, animated: true)
    }

    private func handleShareApp() {
        let message = self.configuration.shareMessage
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        self.present(activityVC, animated: true)
    }

    private func handleWriteReview() {
        guard let url = URL(string: self.configuration.reviewURL) else { return }
        UIApplication.shared.open(url)
    }

    private func showOpenSourceList() {
        let openSourceVC = STOpenSourceListViewController()
        self.navigationController?.pushViewController(openSourceVC, animated: true)
    }

    private func openURL(_ urlString: String, title: String = "") {
        let webVC = STAboutWebViewController(title: title, urlString: urlString)
        self.navigationController?.pushViewController(webVC, animated: true)
    }

    /// 추가 섹션 갱신
    public func reloadSections() {
        self.buildSections()
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension STAboutListViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.allSections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allSections[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.stDequeueCell(type: STAboutListCell.self, for: indexPath)
        let item = self.allSections[indexPath.section][indexPath.row]

        var statusText: String? = nil
        if case let .label(text) = item.accessory {
            statusText = text
        }

        cell.configure(
            title: item.title,
            icon: item.iconName,
            isDestructive: item.isDestructive,
            statusText: statusText,
            showArrow: {
                if case .arrow = item.accessory { return true }
                return false
            }()
        )

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: STAboutListHeaderView.stIdentifier
        ) as? STAboutListHeaderView else { return nil }

        headerView.configure(title: self.sectionTitles[section] ?? "")
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDelegate

extension STAboutListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.allSections[indexPath.section][indexPath.row]
        item.action()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}
