import RxSwift
import UIKit
import SafariServices

class BaseViewController: UIViewController {

    public let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        setUpViews()
        bindActions()
    }

    open func setUpViews() {}

    open func bindActions() {}

    func hideNavigationBar(_ hide: Bool, animated: Bool = false) {
        self.navigationController?.setNavigationBarHidden(hide, animated: animated)
    }

    @objc func popThis() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }

    public func setNavigationBarTransparent(isTransparent: Bool) {
        if isTransparent {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        } else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
        }
        navigationController?.navigationBar.isTranslucent = isTransparent
    }

    open override var shouldAutorotate: Bool {
        return false
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public func showAlert(
        title: String? = "", message: String?,
        positiveTitle: String = "OK", positiveAction: (() -> Void)? = nil,
        negativeTitle: String? = nil, negativeAction: (() -> Void)? = nil
    ) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let negativeTitle = negativeTitle {
            alertController.addAction(UIAlertAction(title: negativeTitle, style: .default, handler: { (_) in
                alertController.dismiss(animated: true, completion: nil)
                negativeAction?()
            }))
        }

        alertController.addAction(UIAlertAction(title: positiveTitle, style: .default, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
            positiveAction?()
        }))

        present(alertController, animated: true, completion: nil)
    }

    public func showHideFullLoading(_ show: Bool) {
        if show {
            FullLoading.shared.show(in: self.view)
        } else {
            FullLoading.shared.hide()
        }
    }

    public func openUrlInSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
