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
        let updateUI: Driver<String?>
    }
    
    //Coordinator Output
    let routeToOTPVerify = PublishSubject<Void>()

    let key: String?
    init(key: String?) {
        self.key = key
    }

    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let updateUI = input.onViewAppear
            .map { self.key }
        
        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            updateUI: updateUI.asDriverOnErrorNever()
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
