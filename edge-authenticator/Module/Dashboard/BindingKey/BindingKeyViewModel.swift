import RxCocoa
import Foundation
import RxSwift

class BindingKeyViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
    //Coordinator Output
    let routeToOTPVerify = PublishSubject<Void>()


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
extension BindingKeyViewModel {
    
}
// MARK: - API calls
extension BindingKeyViewModel {

}
// MARK: - Mapping & Data
private extension BindingKeyViewModel {
    
}
