//
//  InquirySelectViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

final class InquirySelectViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InquirySelectCell.self, forCellReuseIdentifier: InquirySelectCell.reuseIdentifier)
        tableView.rowHeight = 144
        return tableView
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(I18N.inquiry_select_done, for: .normal)
        button.titleLabel?.font = STAboutTypography.bodyBold
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = STAboutColors.primary
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(self.confirmTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Data

    private var records: [InquiryRecord]
    private var selectedIds: Set<String> = []
    var onSelected: (([InquiryRecord]) -> Void)?

    // MARK: - Initialization

    init(records: [InquiryRecord]) {
        self.records = records.sorted(by: { $0.createdAt > $1.createdAt })
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = I18N.inquiry_select_title
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: I18N.common_cancel,
            style: .plain,
            target: self,
            action: #selector(self.cancelTapped)
        )

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.confirmButton)

        self.confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-STAboutSpacing.lg)
            make.height.equalTo(52)
        }

        self.tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.confirmButton.snp.top).offset(-STAboutSpacing.sm)
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        self.dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        let selected = self.records.filter { self.selectedIds.contains($0.id) }
            .sorted(by: { $0.createdAt > $1.createdAt })
        self.onSelected?(selected)
        self.dismiss(animated: true)
    }

    // MARK: - Private Methods

    private func updateConfirmButton() {
        let count = self.selectedIds.count
        let hasSelection = count > 0

        self.confirmButton.isEnabled = hasSelection
        self.confirmButton.alpha = hasSelection ? 1.0 : 0.5
        self.confirmButton.setTitle(hasSelection ? String(format: I18N.inquiry_select_done_count, count) : I18N.inquiry_select_done, for: .normal)
    }
}

// MARK: - UITableViewDataSource

extension InquirySelectViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: InquirySelectCell.reuseIdentifier,
            for: indexPath
        ) as? InquirySelectCell
        else {
            return UITableViewCell()
        }

        let record = self.records[indexPath.row]
        let isSelected = self.selectedIds.contains(record.id)
        cell.configure(with: record, isChecked: isSelected)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension InquirySelectViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let record = self.records[indexPath.row]

        if self.selectedIds.contains(record.id) {
            self.selectedIds.remove(record.id)
        }
        else {
            self.selectedIds.insert(record.id)
        }

        tableView.reloadRows(at: [indexPath], with: .none)
        self.updateConfirmButton()
    }
}

// MARK: - InquirySelectCell

private final class InquirySelectCell: UITableViewCell {
    deinit { }

    static let reuseIdentifier = "InquirySelectCell"

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.cardBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = STAboutColors.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    private lazy var subjectLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.bodyBold
        label.textColor = STAboutColors.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1
        label.textAlignment = .right
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textSecondary
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.contentView.addSubview(self.containerView)
        self.containerView.addSubview(self.checkImageView)
        self.containerView.addSubview(self.idLabel)
        self.containerView.addSubview(self.subjectLabel)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.statusLabel)
        self.containerView.addSubview(self.messageLabel)

        self.containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.bottom.equalToSuperview().offset(-4)
        }

        self.checkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(22)
        }

        self.idLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.checkImageView.snp.trailing).offset(10)
            make.centerY.equalTo(self.checkImageView)
        }

        self.statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(self.checkImageView)
        }

        self.subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(self.checkImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subjectLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(14)
        }

        self.messageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
    }

    // MARK: - Configure

    func configure(with record: InquiryRecord, isChecked: Bool) {
        let checkIcon = isChecked ? "checkmark.circle.fill" : "circle"
        self.checkImageView.image = UIImage(systemName: checkIcon)

        self.idLabel.text = record.id
        self.subjectLabel.text = record.subject

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        self.dateLabel.text = dateFormatter.string(from: record.createdAt)

        if record.status == .replied {
            self.statusLabel.text = I18N.inquiry_status_replied
            self.statusLabel.textColor = STAboutColors.primary
        }
        else {
            self.statusLabel.text = I18N.inquiry_status_pending
            self.statusLabel.textColor = STAboutColors.textTertiary
        }

        self.messageLabel.text = record.message

        self.containerView.layer.borderWidth = isChecked ? 1.5 : 0
        self.containerView.layer.borderColor = isChecked ? STAboutColors.primary.cgColor : nil
    }
}
