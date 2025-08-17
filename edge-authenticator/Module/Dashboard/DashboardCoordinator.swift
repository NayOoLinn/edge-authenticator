import RxSwift
import UIKit

class DashboardCoordinator: Coordinator {

    enum Route {
        case home
        case drawer
        case qrScan
        case bindingKey(String?)
        case otpVerify
    }

    let storyboard = UIStoryboard(name: "Dashboard", bundle: .main)
    let navigationController: UINavigationController
    let disposeBag = DisposeBag()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigate(to: .home)
    }

    func navigate(to route: Route) {
        switch route {
        case .home:
            setRootHome()
        case .drawer:
            routeToDrawer()
        case .qrScan:
            routeToQRScan()
        case .bindingKey(let key):
            routeToBindingKey(key: key)
        case .otpVerify:
            routeToOtpVerify()
        }
    }

    private func setRootHome() {
        let viewModel = HomeViewModel()

        let viewController = HomeViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel

        viewModel.routeToDrawer.subscribe(onNext: {
            self.navigate(to: .drawer)
        }).disposed(by: disposeBag)
        
        viewModel.routeToQrScan.subscribe(onNext: {
            self.navigate(to: .qrScan)
        }).disposed(by: disposeBag)
        
        viewModel.routeToBindingKey.subscribe(onNext: {
            self.navigate(to: .bindingKey(nil))
        }).disposed(by: disposeBag)

        start(with: viewController)
    }
    
    private func routeToDrawer() {
        let viewModel = DrawerViewModel()
        let viewController = DrawerViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController: viewController)
    }

    private func routeToQRScan() {

        let viewModel = QrScanViewModel()
        let viewController = QrScanViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel

        viewModel.routeToBindingKey.subscribe(onNext: { [weak self] in
            self?.navigate(to: .bindingKey($0))
        }).disposed(by: disposeBag)
        
        push(viewController: viewController)
    }
    
    private func routeToBindingKey(key: String?) {

        let viewModel = BindingKeyViewModel(key: key)
        
        let viewController = BindingKeyViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel
        
        viewModel.routeToOTPVerify.subscribe(onNext: {
            self.navigate(to: .otpVerify)
        }).disposed(by: disposeBag)

        push(viewController: viewController)
    }

    private func routeToOtpVerify() {

        let viewModel = OtpVerifyViewModel()
        let viewController = OtpVerifyViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel

        push(viewController: viewController)
    }
    
//    private func routeToWebView(data: WebViewViewController.DisplayModel) {
//        let viewContoller = WebViewViewController(nibName: WebViewViewController.className, bundle: nil)
//        viewContoller.displayModel = data
//        viewContoller.modalPresentationStyle = .pageSheet
//        present(viewController: viewContoller)
//    }

}

