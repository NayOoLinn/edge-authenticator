import RxCocoa
import RxSwift

class SplashViewModel: BaseViewModel, ViewModel {

    struct Input {
        let onViewAppear: Observable<Void>
    }

    struct Output {
        let fullLoading: Driver<Bool>
        let error: Driver<Error>
        let routeToHome: Driver<Void>
    }

    // Coordinator Output
    let routeToHome = PublishSubject<Void>()

    func transform(input: Input) -> Output {
        
        let activityIndicatorFull = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let routeToHome = input.onViewAppear
            .delay(.seconds(1), scheduler: MainScheduler.instance)

        return Output(
            fullLoading: activityIndicatorFull.asDriver(),
            error: errorTracker.asDriver(),
            routeToHome: routeToHome.asDriverOnErrorNever()
        )
    }
}
