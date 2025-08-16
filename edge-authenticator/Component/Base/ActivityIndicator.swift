import Foundation
import RxSwift
import RxCocoa

class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy
    
    private let _lock = NSRecursiveLock()
    private let _behavior = BehaviorRelay<Int>(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    init() {
        _loading = _behavior.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }
    
    fileprivate func trackActivityOfSingle<O: PrimitiveSequenceType>(_ source: O) -> Single<O.Element> where O.Trait == SingleTrait {
        return source
            .do(onSuccess: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }
    
    private func subscribed() {
        _lock.lock()
        _behavior.accept(_behavior.value + 1)
        _lock.unlock()
    }
    
    private func sendStopLoading() {
        _lock.lock()
        _behavior.accept(max(0, _behavior.value - 1))
        _lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
    
    func track(_ activity: ActivityIndicator, error: ErrorTracker) -> Observable<Element> {
        return self.trackActivity(activity).trackError(error)
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Single<Element> {
        return activityIndicator.trackActivityOfSingle(self)
    }
}


