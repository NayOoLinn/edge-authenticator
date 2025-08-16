import RxSwift
import RxCocoa
import UIKit
import WebKit

class WebViewViewController: BaseViewController {

    @IBOutlet weak var webView: WKWebView!

    public var displayModel: DisplayModel?

    override func setUpViews() {

        guard let displayModel = displayModel else {
            return
        }

        webView.navigationDelegate = self
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.isUserInteractionEnabled = true
        webView.isOpaque = false
        webView.scrollView.showsVerticalScrollIndicator = false

        if let url = URL(string: displayModel.urlString) {
            showHideFullLoading(true)
            webView.load(URLRequest(url: url))
        }
    }

}

extension WebViewViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showHideFullLoading(false)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showHideFullLoading(false)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        showHideFullLoading(false)
    }
}
// MARK: - Display Model
extension WebViewViewController {
    struct DisplayModel {
        let urlString: String
    }
}
