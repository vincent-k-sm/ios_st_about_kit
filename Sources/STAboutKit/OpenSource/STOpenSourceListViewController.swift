//
//  STOpenSourceListViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

// MARK: - License Model

public struct STLicenseItem: Codable {
    public let name: String
    public let license: String

    public init(name: String, license: String) {
        self.name = name
        self.license = license
    }
}

// MARK: - Open Source List VC

final class STOpenSourceListViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = STAboutColors.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LicenseCell")
        tableView.rowHeight = 52
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Licenses.json not found.\nAdd generate-licenses.sh to Build Phase."
        label.font = STAboutTypography.caption1
        label.textColor = STAboutColors.textTertiary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Data

    private var licenses: [STLicenseItem] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadLicenses()
    }

    // MARK: - Setup

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = I18N.menu_open_source

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyLabel)

        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - License Loading

    private func loadLicenses() {
        guard let url = Bundle.main.url(forResource: "Licenses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([STLicenseItem].self, from: data)
        else {
            self.emptyLabel.isHidden = false
            self.tableView.isHidden = true
            return
        }

        self.licenses = items.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension STOpenSourceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.licenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LicenseCell", for: indexPath)
        let item = self.licenses[indexPath.row]
        cell.textLabel?.text = item.name
        cell.textLabel?.font = STAboutTypography.body
        cell.textLabel?.textColor = STAboutColors.textPrimary
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = STAboutColors.backgroundWhite
        return cell
    }
}

// MARK: - UITableViewDelegate

extension STOpenSourceListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.licenses[indexPath.row]
        let detailVC = STOpenSourceDetailViewController(license: item)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Detail VC

private final class STOpenSourceDetailViewController: UIViewController {
    deinit { }

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = STAboutTypography.caption1
        textView.textColor = STAboutColors.textSecondary
        textView.backgroundColor = STAboutColors.background
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()

    private let license: STLicenseItem

    init(license: STLicenseItem) {
        self.license = license
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = self.license.name

        self.view.addSubview(self.textView)
        self.textView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.textView.text = self.license.license
    }
}
