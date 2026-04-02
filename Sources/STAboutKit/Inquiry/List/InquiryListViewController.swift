//
//  InquiryListViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

public final class InquiryListViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InquiryListCell.self, forCellReuseIdentifier: InquiryListCell.reuseIdentifier)
        tableView.refreshControl = self.refreshControl
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        return control
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = I18N.inquiry_list_empty
        label.font = STAboutTypography.body
        label.textColor = STAboutColors.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var emptyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(I18N.inquiry_list_first, for: .normal)
        button.titleLabel?.font = STAboutTypography.bodyBold
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = STAboutColors.primary
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(self.newInquiryTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Data

    private var records: [InquiryRecord] = []
    private let interactor = InquiryInteractor()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecords()
        self.syncWithServer()
    }

    // MARK: - Setup

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = I18N.inquiry_list_title

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(self.newInquiryTapped)
        )

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateView)
        self.emptyStateView.addSubview(self.emptyLabel)
        self.emptyStateView.addSubview(self.emptyButton)

        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.xxxl)
        }

        self.emptyLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.emptyButton.snp.makeConstraints { make in
            make.top.equalTo(self.emptyLabel.snp.bottom).offset(STAboutSpacing.xxl)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc private func newInquiryTapped() {
        let inquiryVC = InquiryViewController()
        self.navigationController?.pushViewController(inquiryVC, animated: true)
    }

    @objc private func handleRefresh() {
        self.syncWithServer()
    }

    // MARK: - Private Methods

    private func loadRecords() {
        self.records = InquiryHistoryStore.shared.fetchAll()
        self.tableView.reloadData()
        self.updateEmptyState()
    }

    private func updateEmptyState() {
        self.emptyStateView.isHidden = !self.records.isEmpty
        self.tableView.isHidden = self.records.isEmpty
    }

    private func syncWithServer() {
        Task {
            let updatedRecords = await self.interactor.syncWithServer()

            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.records = updatedRecords
                self.tableView.reloadData()
                self.updateEmptyState()
                self.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension InquiryListViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InquiryListCell.reuseIdentifier, for: indexPath) as? InquiryListCell
        else {
            return UITableViewCell()
        }

        let record = self.records[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension InquiryListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = self.records[indexPath.row]
        let threadVC = InquiryThreadViewController(record: record)
        self.navigationController?.pushViewController(threadVC, animated: true)
    }
}
