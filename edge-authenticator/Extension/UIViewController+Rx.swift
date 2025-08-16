import RxCocoa
import RxSwift
import UIKit

// MARK: - View LifeCycle
extension Reactive where Base: UIViewController {

    var viewDidLoad: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillLayoutSubviews: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewDidLayoutSubviews: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var didBecomeActive: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in }
    }
    
    var willEnterForeground: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in }
    }
    
    var didEnterBackground: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .map { _ in }
    }
}
