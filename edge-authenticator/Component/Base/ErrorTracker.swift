import Foundation
import RxCocoa
import RxSwift

final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()

    init() {}

    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onError: { [weak self] error in
                self?._subject.onNext(error)
            })
            .catch { _ in
                return Observable.empty()
            }
    }

    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    func asObservable() -> Observable<Error> {
        return _subject.asObservable()
    }
    
    func asDriver() -> Driver<Error> {
        return _subject.asDriverOnErrorJustComplete()
    }

    deinit {
        _subject.onCompleted()
    }
}

// MARK: - Extensions
extension ObservableConvertibleType {
    func trackError(_ errorTracker: ErrorTracker) -> Observable<Element> {
        return errorTracker.trackError(from: self)
    }
}
