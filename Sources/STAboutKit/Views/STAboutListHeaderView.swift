//
//  STAboutListHeaderView.swift
//  STAboutKit
//

import SnapKit
import UIKit

final class STAboutListHeaderView: UITableViewHeaderFooterView {
    deinit { }

    static var stIdentifier: String {
        return String(describing: self)
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = STAboutTypography.caption1Bold
        label.textColor = STAboutColors.textTertiary
        return label
    }()

    // MARK: - Initialization

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.contentView.backgroundColor = STAboutColors.background

        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(STAboutSpacing.lg)
            make.trailing.equalToSuperview().inset(STAboutSpacing.lg)
            make.bottom.equalToSuperview().inset(STAboutSpacing.sm)
        }
    }

    // MARK: - Configuration

    func configure(title: String) {
        self.titleLabel.text = title.uppercased()
    }
}
