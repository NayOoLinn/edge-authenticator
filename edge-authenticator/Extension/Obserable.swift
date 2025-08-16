import RxSwift

public extension Observable {
    func onNext(_ onNext: @escaping (_ value: Element) -> Void) -> Observable<Element> {
        self.do(onNext: { onNext($0) })
    }
}

