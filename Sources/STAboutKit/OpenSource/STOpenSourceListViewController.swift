//
//  STOpenSourceListViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

// MARK: - License Model

public struct STLicenseItem {
    public let name: String
    public let licenseText: String

    public init(name: String, licenseText: String) {
        self.name = name
        self.licenseText = licenseText
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
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    // MARK: - License Loading

    private func loadLicenses() {
        // Bundle.allFrameworks에서 SPM 패키지 이름 추출
        var items: [STLicenseItem] = []
        let excludePrefixes = ["com.apple.", "libswift", "UIKit", "Foundation", "CoreFoundation"]

        for bundle in Bundle.allFrameworks {
            guard let bundleId = bundle.bundleIdentifier else { continue }

            // 시스템 프레임워크 제외
            let isSystem = excludePrefixes.contains(where: { bundleId.hasPrefix($0) })
            if isSystem { continue }

            // 번들 경로에서 패키지명 추출
            let path = bundle.bundlePath
            let name = (path as NSString).lastPathComponent
                .replacingOccurrences(of: ".framework", with: "")
                .replacingOccurrences(of: ".bundle", with: "")

            // LICENSE 파일 검색
            let licenseText = Self.findLicenseInBundle(bundle) ?? "This package is used under its original license terms."

            if !name.isEmpty {
                items.append(STLicenseItem(name: name, licenseText: licenseText))
            }
        }

        // 중복 제거 + 정렬
        var seen = Set<String>()
        self.licenses = items
            .filter { seen.insert($0.name).inserted }
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.tableView.reloadData()
    }

    private static func findLicenseInBundle(_ bundle: Bundle) -> String? {
        let candidates = ["LICENSE", "LICENSE.md", "LICENSE.txt", "LICENCE", "License"]
        for candidate in candidates {
            if let url = bundle.url(forResource: candidate, withExtension: nil) {
                return try? String(contentsOf: url, encoding: .utf8)
            }
            // 확장자 분리
            let name = (candidate as NSString).deletingPathExtension
            let ext = (candidate as NSString).pathExtension
            if !ext.isEmpty, let url = bundle.url(forResource: name, withExtension: ext) {
                return try? String(contentsOf: url, encoding: .utf8)
            }
        }
        return nil
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
        self.textView.text = self.license.licenseText
    }
}
