//
//  STAboutListCell.swift
//  STAboutKit
//

import SnapKit
import UIKit

final class STAboutListCell: UITableViewCell {
    deinit { }

    // MARK: - UI Components

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = STAboutColors.chipBackground
        view.layer.cornerRadius = STAboutRadius.sm
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = STAboutColors.textSecondary
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.body
        label.textColor = STAboutColors.textPrimary
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = STAboutColors.textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.iconImageView.image = nil
        self.statusLabel.text = nil
        self.statusLabel.isHidden = true
        self.titleLabel.textColor = STAboutColors.textPrimary
        self.iconImageView.tintColor = STAboutColors.textSecondary
        self.arrowImageView.isHidden = false
        self.selectionStyle = .default
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.backgroundColor = STAboutColors.backgroundWhite
        self.selectionStyle = .default

        self.contentView.addSubview(self.iconContainerView)
        self.iconContainerView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.statusLabel)

        self.iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(STAboutSpacing.lg)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }

        self.iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconContainerView.snp.trailing).offset(STAboutSpacing.md)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(self.statusLabel.snp.leading).offset(-STAboutSpacing.sm)
        }

        self.statusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.arrowImageView.snp.leading).offset(-STAboutSpacing.sm)
            make.centerY.equalToSuperview()
        }
        self.statusLabel.isHidden = true

        self.arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
    }

    // MARK: - Configuration

    func configure(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        statusText: String? = nil,
        showArrow: Bool = true
    ) {
        self.titleLabel.text = title
        self.iconImageView.image = UIImage(systemName: icon)

        if isDestructive {
            self.titleLabel.textColor = STAboutColors.danger
            self.iconImageView.tintColor = STAboutColors.danger
        }

        if let statusText = statusText {
            self.statusLabel.text = statusText
            self.statusLabel.isHidden = false
        }

        self.arrowImageView.isHidden = !showArrow

        if !showArrow && statusText != nil {
            self.selectionStyle = .none
        }
    }
}
