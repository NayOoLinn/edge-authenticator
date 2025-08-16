import RxSwift
import UIKit

protocol Coordinator: AnyObject {
    associatedtype Route
    
    var storyboard: UIStoryboard { get }
    var navigationController: UINavigationController { get }
    var disposeBag: DisposeBag { get }

    func start(with viewController: UIViewController) -> UINavigationController
    func push(viewController: UIViewController, animated: Bool)
    func present(viewController: UIViewController)
    func changeLastViewController(to toViewController: UIViewController)
    func isVisible(controllerName: String) -> Bool
    func popTo(viewController type: UIViewController.Type)
    func set(to viewController: UIViewController)
    func change(root: UIViewController)
}

extension Coordinator {

    @discardableResult
    func start(with viewController: UIViewController) -> UINavigationController {
        set(to: viewController)
        return navigationController
    }

    func push(viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    func present(viewController: UIViewController) {
        navigationController.present(viewController, animated: true)
    }

    func changeLastViewController(to toViewController: UIViewController) {
        var vcs = navigationController.viewControllers
        if vcs.count > 0 {
            vcs.removeLast()
        }
        vcs.append(toViewController)
        navigationController.setViewControllers(vcs, animated: true)
    }

    func isVisible(controllerName: String) -> Bool {
        if let paybillVC = NSClassFromString(controllerName),
           let isCurrent = navigationController.visibleViewController?.isKind(of: paybillVC),
           isCurrent {
            return true
        }
        return false
    }

    func popTo(viewController type: UIViewController.Type) {
        var toViewController: UIViewController?
        for viewController in navigationController.viewControllers {
            if viewController.isKind(of: type) {
                toViewController = viewController
                break
            }
        }

        guard let viewController = toViewController else {
            navigationController.popViewController(animated: true)
            return
        }
        navigationController.popToViewController(viewController, animated: true)
    }

    func set(to viewController: UIViewController) {
        guard let _ = navigationController.topViewController else {
            navigationController.setViewControllers([viewController], animated: true)
            return
        }
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func change(root: UIViewController) {
        guard let window = UIApplication.keyWindow else { return }

        UIView.transition(
            with: window,
            duration: 0.6,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = root
            },
            completion: nil
        )
    }
}
