import RxSwift
import UIKit

class AppCoordinator: Coordinator {

    static func start(window: UIWindow) -> AppCoordinator {
        let navController = BaseNavigationViewController()
        navController.navigationBar.isTranslucent = false
        window.rootViewController = navController
        window.makeKeyAndVisible()
        return AppCoordinator(navigationController: navController)
    }
    
    enum Route {
        case splash
        case home
    }

    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    let navigationController: UINavigationController
    let disposeBag = DisposeBag()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigate(to: .splash)
    }

    func navigate(to route: Route) {
        switch route {
        case .splash:
            setRootSplash()
        case .home:
            changeToHome()
        }
    }

    private func setRootSplash() {
        let viewModel = SplashViewModel()

        viewModel.routeToHome.subscribe(onNext: { [weak self] in
            self?.navigate(to: .home)
        }).disposed(by: disposeBag)

        let viewController = SplashViewController.instantiate(from: storyboard)
        viewController.viewModel = viewModel

        start(with: viewController)
    }

    private func changeToHome() {
        let dashboardCoordinator = DashboardCoordinator(navigationController: BaseNavigationViewController())
        change(root: dashboardCoordinator.navigationController)
    }
}
