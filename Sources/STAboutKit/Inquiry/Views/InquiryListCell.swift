//
//  InquiryListCell.swift
//  STAboutKit
//

import SnapKit
import UIKit

final class InquiryListCell: UITableViewCell {
    deinit { }

    static let reuseIdentifier = "InquiryListCell"

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.cardBackground
        view.layer.cornerRadius = 12
        return view
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
        label.textColor = STAboutColors.textSecondary
        return label
    }()

    private lazy var statusBadgeContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private lazy var statusBadge: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption2
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = STAboutColors.textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.contentView.addSubview(self.containerView)
        self.containerView.addSubview(self.subjectLabel)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.statusBadgeContainer)
        self.statusBadgeContainer.addSubview(self.statusBadge)
        self.containerView.addSubview(self.chevronImageView)

        self.containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.trailing.equalToSuperview().inset(STAboutSpacing.lg)
        }

        self.statusBadgeContainer.snp.makeConstraints { make in
            make.trailing.equalTo(self.chevronImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        self.statusBadge.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        self.chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }

        self.subjectLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.statusBadgeContainer.snp.leading).offset(-8)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subjectLabel.snp.bottom).offset(4)
            make.leading.equalTo(self.subjectLabel)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    // MARK: - Configure

    func configure(with record: InquiryRecord) {
        self.subjectLabel.text = record.subject

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        self.dateLabel.text = formatter.string(from: record.createdAt)

        switch record.status {
            case .pending:
                self.statusBadge.text = I18N.inquiry_status_pending
                self.statusBadge.textColor = STAboutColors.textSecondary
                self.statusBadgeContainer.backgroundColor = STAboutColors.inputBackground

            case .replied:
                self.statusBadge.text = I18N.inquiry_status_replied
                self.statusBadge.textColor = .white
                self.statusBadgeContainer.backgroundColor = STAboutColors.primary
        }
    }
}
