//
//  STAboutWebViewController.swift
//  STAboutKit
//

import SnapKit
import UIKit
import WebKit

final class STAboutWebViewController: UIViewController {
    deinit { }

    // MARK: - UI Components

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Properties

    private let urlString: String
    private let pageTitle: String

    // MARK: - Initialization

    init(title: String, urlString: String) {
        self.pageTitle = title
        self.urlString = urlString
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
        self.loadPage()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.view.backgroundColor = STAboutColors.background
        self.navigationItem.title = self.pageTitle

        self.view.addSubview(self.webView)
        self.view.addSubview(self.activityIndicator)

        self.webView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Private Methods

    private func loadPage() {
        guard let url = URL(string: self.urlString) else { return }
        self.activityIndicator.startAnimating()
        self.webView.load(URLRequest(url: url))
    }
}

// MARK: - WKNavigationDelegate

extension STAboutWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
    }
}
