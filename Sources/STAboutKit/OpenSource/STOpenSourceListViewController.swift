//
//  STOpenSourceListViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit

// MARK: - License Model

struct STLicenseItem {
    let name: String
    let licenseText: String
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
        var items: [STLicenseItem] = []

        // SPM 체크아웃 디렉토리에서 LICENSE 파일 검색
        let checkoutPaths = Self.findSPMCheckoutPaths()

        for path in checkoutPaths {
            let packageName = (path as NSString).lastPathComponent
            let licensePath = Self.findLicenseFile(in: path)

            if let licensePath = licensePath,
               let text = try? String(contentsOfFile: licensePath, encoding: .utf8) {
                items.append(STLicenseItem(name: packageName, licenseText: text))
            }
            else {
                items.append(STLicenseItem(name: packageName, licenseText: "License file not found."))
            }
        }

        self.licenses = items.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.tableView.reloadData()
    }

    // MARK: - SPM Path Discovery

    private static func findSPMCheckoutPaths() -> [String] {
        var paths: [String] = []

        // DerivedData 기반 SPM checkouts
        let homeDir = NSHomeDirectory()
        let derivedDataBase = "\(homeDir)/Library/Developer/Xcode/DerivedData"

        if let derivedDataContents = try? FileManager.default.contentsOfDirectory(atPath: derivedDataBase) {
            for dir in derivedDataContents {
                let checkoutsPath = "\(derivedDataBase)/\(dir)/SourcePackages/checkouts"
                if FileManager.default.fileExists(atPath: checkoutsPath) {
                    if let packages = try? FileManager.default.contentsOfDirectory(atPath: checkoutsPath) {
                        for pkg in packages {
                            let fullPath = "\(checkoutsPath)/\(pkg)"
                            var isDir: ObjCBool = false
                            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                                paths.append(fullPath)
                            }
                        }
                    }
                    break
                }
            }
        }

        return paths
    }

    private static func findLicenseFile(in directory: String) -> String? {
        let candidates = ["LICENSE", "LICENSE.md", "LICENSE.txt", "LICENCE", "LICENCE.md", "License", "license"]
        for candidate in candidates {
            let path = "\(directory)/\(candidate)"
            if FileManager.default.fileExists(atPath: path) {
                return path
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
