import RxCocoa
import RxSwift

extension ObservableType {

    func catchErrorJustComplete() -> Observable<Element> {
        self.catch { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { error in
            return Driver.empty()
        }
    }

    func asDriverOnErrorNever() -> Driver<Element> {
        asDriver { error in
            return .never()
        }
    }

    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
}
