import RxCocoa
import Foundation
import RxSwift

class QrScanViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    //Coordinator Output
    let routeToBindingKey = PublishSubject<AuthCodeData>()

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
        )
    }
}
// MARK: - Business Logic
extension QrScanViewModel {
    
}
// MARK: - API calls
extension QrScanViewModel {

}
// MARK: - Mapping & Data
private extension QrScanViewModel {
    
}
