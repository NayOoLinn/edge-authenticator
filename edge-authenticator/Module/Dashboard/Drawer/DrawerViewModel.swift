import RxCocoa
import RxSwift

class DrawerViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
    }

    //Coordinator Output
//    let routeToDetail = PublishSubject<String>()


    func transform(input: Input) -> Output {

        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()

        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver()
        )
    }
}
// MARK: - Business Logic
extension DrawerViewModel {
    
}
